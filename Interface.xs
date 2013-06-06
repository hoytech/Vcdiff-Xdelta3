#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <stdio.h>
#include <stdlib.h>

#include "xdelta3.h"

#define BUF_SIZE 65536

#ifndef MIN
#define MIN(x,y) ((x)<(y)?(x):(y))
#endif

int encode_decode(int encode,
                  int source_fd, unsigned char *source_str, off_t source_str_size,
                  int input_fd, unsigned char *input_str, off_t input_str_size,
                  int output_fd, SV *output_sv) {
  int r, ret;
  xd3_stream stream;
  xd3_config config;
  xd3_source source;
  unsigned char *ibuf;
  int ibuf_len;

  memset(&stream, 0, sizeof (stream));
  memset(&source, 0, sizeof (source));

  xd3_init_config(&config, 0);
  config.winsize = BUF_SIZE;
  xd3_config_stream(&stream, &config);

  source.blksize = BUF_SIZE;
  source.curblkno = 0;

  if (source_fd != -1) {
    source.curblk = malloc(source.blksize);
    r = lseek(source_fd, 0, SEEK_SET);
    source.onblk = read(source_fd, (void*)source.curblk, source.blksize);
  } else {
    source.curblk = source_str;
    source.onblk = MIN(source.blksize, source_str_size);
  }

  xd3_set_source(&stream, &source);

  if (input_fd != -1) {
    ibuf = malloc(BUF_SIZE);
    lseek(input_fd, 0, SEEK_SET);
  } else {
    ibuf = input_str;
    ibuf_len = 0;
  }

  do
  {
    if (input_fd != -1) {
      ibuf_len = read(input_fd, ibuf, BUF_SIZE);
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
      if (output_fd != -1) {
        r = write(output_fd, stream.next_out, stream.avail_out);
        if (r != (int)stream.avail_out)
          return r;
      } else {
        sv_catpvn(output_sv, stream.next_out, stream.avail_out);
      }

      xd3_consume_output(&stream);

      goto process;

    case XD3_GETSRCBLK:
      source.curblkno = source.getblkno;

      if (source_fd > -1) {
        r = lseek(source_fd, source.blksize * source.getblkno, SEEK_SET);
        source.onblk = read(source_fd, (void*)source.curblk, source.blksize);
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

  if (source_fd != -1) {
    free((void*)source.curblk);
  }

  if (input_fd != -1) {
    free(ibuf);
  }

  xd3_close_stream(&stream);
  xd3_free_stream(&stream);

  return 0;
}



MODULE = Vcdiff::Xdelta3		PACKAGE = Vcdiff::Xdelta3

PROTOTYPES: ENABLE



void
_encode(source_fd, source_sv, input_fd, input_sv, output_fd, output_sv)
        int source_fd
        SV *source_sv
        int input_fd
        SV *input_sv
        int output_fd
        SV *output_sv
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
                      output_fd, output_sv);



void
_decode(source_fd, source_sv, input_fd, input_sv, output_fd, output_sv)
        int source_fd
        SV *source_sv
        int input_fd
        SV *input_sv
        int output_fd
        SV *output_sv
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
                      output_fd, output_sv);
