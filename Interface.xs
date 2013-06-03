#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <stdio.h>
#include <stdlib.h>

#include "xdelta3.h"

#define BUF_SIZE XD3_DEFAULT_WINSIZE

#ifndef MIN
#define MIN(x,y) ((x)<(y)?(x):(y))
#endif

int encode_decode(int encode,
                  int source_fd, unsigned char *source_str, off_t source_str_size,
                  int input_fd, unsigned char *input_str, off_t input_str_size,
                  int output_fd) {
  int r, ret;
  xd3_stream stream;
  xd3_config config;
  xd3_source source;
  unsigned char *ibuf;
  int ibuf_len;
  FILE *source_file = NULL;
  FILE *input_file = NULL;
  FILE *output_file = NULL;

  if (source_fd > -1) {
    source_file = fdopen(source_fd, "rb");
  }
  if (input_fd > -1) {
    input_file = fdopen(input_fd, "rb");
  }
  if (output_fd > -1) {
    output_file = fdopen(output_fd, "wb");
  }

  memset(&stream, 0, sizeof (stream));
  memset(&source, 0, sizeof (source));

  xd3_init_config(&config, 0);
  config.winsize = BUF_SIZE;
  xd3_config_stream(&stream, &config);

  source.blksize = BUF_SIZE;
  source.curblkno = 0;

  if (source_file) {
    source.curblk = malloc(source.blksize);
    r = fseek(source_file, 0, SEEK_SET);
    source.onblk = fread((void*)source.curblk, 1, source.blksize, source_file);
  } else {
    source.curblk = source_str;
    source.onblk = MIN(source.blksize, source_str_size);
  }

  xd3_set_source(&stream, &source);

  if (input_file) {
    ibuf = malloc(BUF_SIZE);
    fseek(input_file, 0, SEEK_SET);
  } else {
    ibuf = input_str;
    ibuf_len = 0;
  }

  do
  {
    if (input_file) {
      ibuf_len = fread(ibuf, 1, BUF_SIZE, input_file);
    } else {
      ibuf += ibuf_len;
      ibuf_len = MIN(BUF_SIZE, input_str_size - (ibuf - input_str));
    }

    if (ibuf_len < BUF_SIZE) {
      xd3_set_flags(&stream, XD3_FLUSH | stream.flags);
    }
    xd3_avail_input(&stream, ibuf, ibuf_len);

process:
    if (encode)
      ret = xd3_encode_input(&stream);
    else
      ret = xd3_decode_input(&stream);

    switch (ret) {
    case XD3_INPUT:
      continue;

    case XD3_OUTPUT:
      r = fwrite(stream.next_out, 1, stream.avail_out, output_file);
      if (r != (int)stream.avail_out)
        return r;
      xd3_consume_output(&stream);
      goto process;

    case XD3_GETSRCBLK:
      source.curblkno = source.getblkno;

      if (source_file) {
        r = fseek(source_file, source.blksize * source.getblkno, SEEK_SET);
        source.onblk = fread((void*)source.curblk, 1,
                             source.blksize, source_file);
      } else {
        source.curblk = source_str + (source.blksize * source.getblkno);
        source.onblk = MIN(source.blksize, source_str_size - (source.blksize * source.getblkno));
      }
      goto process;

    case XD3_GOTHEADER:
    case XD3_WINSTART:
    case XD3_WINFINISH:
      goto process;

    default:
      return ret;

    }

  } while (ibuf_len == BUF_SIZE);

  if (source_file) {
    free((void*)source.curblk);
    fclose(source_file);
  }

  if (input_file) {
    free(ibuf);
    fclose(input_file);
  }

  if (output_file) {
    fclose(output_file);
  }

  xd3_close_stream(&stream);
  xd3_free_stream(&stream);

  return 0;
}



MODULE = Vcdiff::Xdelta3		PACKAGE = Vcdiff::Xdelta3

PROTOTYPES: ENABLE



void
_encode(source_fd, source_sv, input_fd, input_sv, output_fd)
        int source_fd
        SV *source_sv
        int input_fd
        SV *input_sv
        int output_fd
    CODE:
        unsigned char *source_str = NULL;
        size_t source_str_size = 0;
        unsigned char *input_str = NULL;
        size_t input_str_size = 0;

        if (source_fd == -1) {
          source_str_size = SvCUR(source_sv);
          source_str = SvPV(source_sv, source_str_size);
        }

        if (input_fd == -1) {
          input_str_size = SvCUR(input_sv);
          input_str = SvPV(input_sv, input_str_size);
        }

        encode_decode(1,
                      source_fd, source_str, (off_t) source_str_size,
                      input_fd, input_str, (off_t) input_str_size,
                      output_fd);



void
_decode(source_fd, source_sv, input_fd, input_sv, output_fd)
        int source_fd
        SV *source_sv
        int input_fd
        SV *input_sv
        int output_fd
    CODE:
        unsigned char *source_str = NULL;
        size_t source_str_size = 0;
        unsigned char *input_str = NULL;
        size_t input_str_size = 0;

        if (source_fd == -1) {
          source_str_size = SvCUR(source_sv);
          source_str = SvPV(source_sv, source_str_size);
        }

        if (input_fd == -1) {
          input_str_size = SvCUR(input_sv);
          input_str = SvPV(input_sv, input_str_size);
        }

        encode_decode(0,
                      source_fd, source_str, (off_t) source_str_size,
                      input_fd, input_str, (off_t) input_str_size,
                      output_fd);
