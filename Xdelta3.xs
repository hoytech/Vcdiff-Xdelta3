#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <stdio.h>
#include <stdlib.h>

#include "xdelta3.h"

#define BUF_SIZE XD3_DEFAULT_WINSIZE

int encode_decode(int encode,
                  int source_fd, unsigned char *source_str, off_t source_str_size,
                  int input_fd, unsigned char *input_str, off_t input_str_size,
                  int output_fd) {
  int r, ret;
  xd3_stream stream;
  xd3_config config;
  xd3_source source;
  void *ibuf;
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

  memset (&stream, 0, sizeof (stream));
  memset (&source, 0, sizeof (source));

  xd3_init_config(&config, XD3_ADLER32);
  config.winsize = BUF_SIZE;
  xd3_config_stream(&stream, &config);

  source.blksize = BUF_SIZE;
  source.curblk = malloc(source.blksize);
  source.curblkno = 0;

  if (source_file) {
    r = fseek(source_file, 0, SEEK_SET);
    source.onblk = fread((void*)source.curblk, 1, source.blksize, source_file);
  } else {
    // FIXME: read from str
  }

  xd3_set_source(&stream, &source);

  ibuf = malloc(BUF_SIZE);

  if (input_file) fseek(input_file, 0, SEEK_SET);

  do
  {
    ibuf_len = fread(ibuf, 1, BUF_SIZE, input_file);
    if (ibuf_len < BUF_SIZE)
    {
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
      if (source_file) {
        r = fseek(source_file, source.blksize * source.getblkno, SEEK_SET);
        if (r)
          return r;
        source.onblk = fread((void*)source.curblk, 1,
                             source.blksize, source_file);
        source.curblkno = source.getblkno;
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

  free(ibuf);

  free((void*)source.curblk);
  xd3_close_stream(&stream);
  xd3_free_stream(&stream);

  return 0;
}



MODULE = Vcdiff::Xdelta3		PACKAGE = Vcdiff::Xdelta3

PROTOTYPES: ENABLE



void
_encode(source_fd, input_fd, output_fd)
        int source_fd
        int input_fd
        int output_fd
    CODE:
        encode_decode(1, source_fd, NULL, 0, input_fd, NULL, 0, output_fd);



void
_decode(source_fd, input_fd, output_fd)
        int source_fd
        int input_fd
        int output_fd
    CODE:
        encode_decode(0, source_fd, NULL, 0, input_fd, NULL, 0, output_fd);
