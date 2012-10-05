/****************************************************************************
 ****************************************************************************
 ***
 ***   This header was automatically generated from a Linux kernel header
 ***   of the same name, to make information necessary for userspace to
 ***   call into the kernel available to libc.  It contains only constants,
 ***   structures, and macros generated from the original header, and thus,
 ***   contains no copyrightable information.
 ***
 ***   To edit the content of this header, modify the corresponding
 ***   source file (e.g. under external/kernel-headers/original/) then
 ***   run bionic/libc/kernel/tools/update_all.py
 ***
 ***   Any manual change here will be lost the next time this script will
 ***   be run. You've been warned!
 ***
 ****************************************************************************
 ****************************************************************************/
#ifndef __COMPRESS_DRIVER_H
#define __COMPRESS_DRIVER_H
#include <sound/compress_offload.h>
#include <sound/asound.h>
/* WARNING: DO NOT EDIT, AUTO-GENERATED CODE - SEE TOP FOR INSTRUCTIONS */
#include <sound/pcm.h>
struct snd_compr_ops;
struct snd_compr_runtime {
 snd_pcm_state_t state;
/* WARNING: DO NOT EDIT, AUTO-GENERATED CODE - SEE TOP FOR INSTRUCTIONS */
 struct snd_compr_ops *ops;
 void *buffer;
 size_t buffer_size;
 size_t fragment_size;
/* WARNING: DO NOT EDIT, AUTO-GENERATED CODE - SEE TOP FOR INSTRUCTIONS */
 unsigned int fragments;
 size_t hw_pointer;
 size_t app_pointer;
 wait_queue_head_t sleep;
/* WARNING: DO NOT EDIT, AUTO-GENERATED CODE - SEE TOP FOR INSTRUCTIONS */
};
struct snd_compr_stream {
 const char *name;
 struct snd_compr_ops *ops;
/* WARNING: DO NOT EDIT, AUTO-GENERATED CODE - SEE TOP FOR INSTRUCTIONS */
 struct snd_compr_runtime *runtime;
 struct snd_compr *device;
 unsigned int direction;
 void *private_data;
/* WARNING: DO NOT EDIT, AUTO-GENERATED CODE - SEE TOP FOR INSTRUCTIONS */
};
struct snd_compr_ops {
 int (*open)(struct snd_compr_stream *stream);
 int (*free)(struct snd_compr_stream *stream);
/* WARNING: DO NOT EDIT, AUTO-GENERATED CODE - SEE TOP FOR INSTRUCTIONS */
 int (*set_params)(struct snd_compr_stream *stream,
 struct snd_compr_params *params);
 int (*get_params)(struct snd_compr_stream *stream,
 struct snd_compr_params *params);
/* WARNING: DO NOT EDIT, AUTO-GENERATED CODE - SEE TOP FOR INSTRUCTIONS */
 int (*trigger)(struct snd_compr_stream *stream, int cmd);
 int (*pointer)(struct snd_compr_stream *stream,
 struct snd_compr_tstamp *tstamp);
 int (*copy)(struct snd_compr_stream *stream, const char __user *buf,
/* WARNING: DO NOT EDIT, AUTO-GENERATED CODE - SEE TOP FOR INSTRUCTIONS */
 size_t count);
 int (*mmap)(struct snd_compr_stream *stream,
 struct vm_area_struct *vma);
 int (*ack)(struct snd_compr_stream *stream);
/* WARNING: DO NOT EDIT, AUTO-GENERATED CODE - SEE TOP FOR INSTRUCTIONS */
 int (*get_caps) (struct snd_compr_stream *stream,
 struct snd_compr_caps *caps);
 int (*get_codec_caps) (struct snd_compr_stream *stream,
 struct snd_compr_codec_caps *codec);
/* WARNING: DO NOT EDIT, AUTO-GENERATED CODE - SEE TOP FOR INSTRUCTIONS */
};
struct snd_compr {
 const char *name;
 struct device *dev;
/* WARNING: DO NOT EDIT, AUTO-GENERATED CODE - SEE TOP FOR INSTRUCTIONS */
 struct mutex lock;
 struct snd_compr_ops *ops;
 struct list_head list;
 void *private_data;
/* WARNING: DO NOT EDIT, AUTO-GENERATED CODE - SEE TOP FOR INSTRUCTIONS */
};
#endif
