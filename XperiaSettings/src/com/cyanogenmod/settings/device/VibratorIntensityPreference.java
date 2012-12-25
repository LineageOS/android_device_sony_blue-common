/*
 * Copyright (C) 2011 The CyanogenMod Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.cyanogenmod.settings.device;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Vibrator;
import android.preference.DialogPreference;
import android.preference.PreferenceManager;
import android.util.AttributeSet;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.SeekBar;
import android.widget.TextView;
import android.util.Log;

/**
 * Special preference type that allows configuration of both the ring volume and
 * notification volume.
 */
public class VibratorIntensityPreference extends DialogPreference implements OnClickListener {

    private static final String TAG = "XperiaSettings_Vibrator";

    private static final int[] SEEKBAR_ID = new int[] {
            R.id.vibrator_seekbar
    };

    private static final int[] VALUE_DISPLAY_ID = new int[] {
            R.id.vibrator_value
    };

    private static final String[] FILE_PATH = new String[] {
            "/sys/devices/i2c-12/12-0049/intensity",
    };

    private vibratorSeekBar mSeekBars[] = new vibratorSeekBar[1];
    private static final int MAX_VALUE = 8;
    private static final int OFFSET_VALUE = 0;

    // Track instances to know when to restore original color
    // (when the orientation changes, a new dialog is created before the old one
    // is destroyed)
    private static int sInstances = 0;

    public VibratorIntensityPreference(Context context, AttributeSet attrs) {
        super(context, attrs);

        setDialogLayoutResource(R.layout.preference_dialog_vibrator_intensity);
    }

    @Override
    protected void onBindDialogView(View view) {
        super.onBindDialogView(view);

        sInstances++;

        for (int i = 0; i < SEEKBAR_ID.length; i++) {
            SeekBar seekBar = (SeekBar) view.findViewById(SEEKBAR_ID[i]);
            TextView valueDisplay = (TextView) view.findViewById(VALUE_DISPLAY_ID[i]);
            if (i < 3)
                mSeekBars[i] = new vibratorSeekBar(seekBar, valueDisplay, FILE_PATH[i], OFFSET_VALUE, MAX_VALUE);
            else
                mSeekBars[i] = new vibratorSeekBar(seekBar, valueDisplay, FILE_PATH[i], 0, 6);
        }

        SetupButtonClickListener(view);
    }

    private void SetupButtonClickListener(View view) {
        Button mTestButton = (Button)view.findViewById(R.id.vibrator_test);
        mTestButton.setOnClickListener(this);

        Button mResetButton = (Button)view.findViewById(R.id.vibrator_reset);
        mResetButton.setOnClickListener(this);
    }

    @Override
    protected void onDialogClosed(boolean positiveResult) {
        super.onDialogClosed(positiveResult);

        sInstances--;

        if (positiveResult) {
            for (vibratorSeekBar csb : mSeekBars) {
                csb.save();
            }
        } else if (sInstances == 0) {
            for (vibratorSeekBar csb : mSeekBars) {
                csb.reset();
            }
        }
    }

    /**
     * Restore vibrator intensity from SharedPreferences. (Write to kernel.)
     *
     * @param context The context to read the SharedPreferences from
     */
    public static void restore(Context context) {
        if (!isSupported()) {
            return;
        }

        SharedPreferences sharedPrefs = PreferenceManager.getDefaultSharedPreferences(context);

        Boolean bFirstTime = sharedPrefs.getBoolean("FirstTimevibrator", true);
        for (String filePath : FILE_PATH) {
            String sDefaultValue = Utils.readOneLine(filePath);
            int iValue = sharedPrefs.getInt(filePath, Integer.valueOf(sDefaultValue));
            if (bFirstTime)
                Utils.writeValue(filePath, "4");
            else
                Utils.writeValue(filePath, String.valueOf((long) iValue));
        }
        if (bFirstTime)
        {
            SharedPreferences.Editor editor = sharedPrefs.edit();
            editor.putBoolean("FirstTimevibrator", false);
            editor.commit();
        }
    }

    /**
     * Check whether the running kernel supports setting vibrator intensity or not.
     *
     * @return Wether vibrator intensity is supported or not
     */
    public static boolean isSupported() {
        boolean supported = true;
        for (String filePath : FILE_PATH) {
            if (!Utils.fileExists(filePath)) {
                supported = false;
            }
        }

        return supported;
    }

    class vibratorSeekBar implements SeekBar.OnSeekBarChangeListener {

        private String mFilePath;

        private int mOriginal;

        private SeekBar mSeekBar;

        private TextView mValueDisplay;

        private int iOffset;

        private int iMax;

        public vibratorSeekBar(SeekBar seekBar, TextView valueDisplay, String filePath, Integer offsetValue, Integer maxValue) {
            int iValue;

            mSeekBar = seekBar;
            mValueDisplay = valueDisplay;
            mFilePath = filePath;
            iOffset = offsetValue;
            iMax = maxValue;

            SharedPreferences sharedPreferences = getSharedPreferences();

            // Read original value
            if (Utils.fileExists(mFilePath)) {
                String sDefaultValue = Utils.readOneLine(mFilePath);
                iValue = Integer.valueOf(sDefaultValue);
            } else {
                iValue = iMax - iOffset;
            }
            mOriginal = iValue;

            mSeekBar.setMax(iMax);

            reset();
            mSeekBar.setOnSeekBarChangeListener(this);
        }

        public void reset() {
            int iValue;

            iValue = mOriginal + iOffset;
            mSeekBar.setProgress(iValue);
            updateValue(mOriginal);
        }

        public void save() {
            int iValue;

            iValue = mSeekBar.getProgress() - iOffset;
            Editor editor = getEditor();
            editor.putInt(mFilePath, iValue);
            editor.commit();
        }

        @Override
        public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
            int iValue;

            iValue = progress - iOffset;
            Utils.writeValue(mFilePath, String.valueOf((long) iValue));
            updateValue(iValue);
        }

        @Override
        public void onStartTrackingTouch(SeekBar seekBar) {
            // Do nothing
        }

        @Override
        public void onStopTrackingTouch(SeekBar seekBar) {
            // Do nothing
        }

        private void updateValue(int progress) {
            mValueDisplay.setText(String.format("%d", (int) progress));
        }

        public void setNewValue(int iValue) {
            mOriginal = iValue;
            reset();
        }

        public void resetDefault() {
            mSeekBar.setProgress(MAX_VALUE);
            updateValue(MAX_VALUE);
            Utils.writeValue(mFilePath, String.valueOf(MAX_VALUE));
        }
    }

    public void onClick(View v) {
        switch(v.getId()) {
            case R.id.vibrator_test:
                testVibrator();
                break;
            case R.id.vibrator_reset:
                mSeekBars[1].resetDefault();
                break;
        }
    }

    public void testVibrator() {
        Vibrator vib = (Vibrator) this.getContext().getSystemService(Context.VIBRATOR_SERVICE);
        vib.vibrate(1000);
    }
}
