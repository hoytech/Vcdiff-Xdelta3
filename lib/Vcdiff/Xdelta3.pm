package Vcdiff::Xdelta3;

use strict;

our $VERSION = '0.100';

require XSLoader;
XSLoader::load('Vcdiff::Xdelta3', $VERSION);



sub encode {
  my ($source, $input, $output) = @_;

  my ($source_fileno, $source_str, $input_fileno, $input_str, $output_fileno, $output_str);

  $source_fileno = $input_fileno = $output_fileno = -1;

  if (ref $source eq 'GLOB') {
    $source_fileno = fileno($source);
  } else {
    $source_str = $source;
  }

  if (ref $input eq 'GLOB') {
    $input_fileno = fileno($input);
  } else {
    $input_str = $input;
  }

  if (defined $output) {
    die "output argument to encode should be a file handle or undef"
      if ref $output ne 'GLOB';

    $output_fileno = fileno($output);
  } else {
    $output_str = '';
  }

  _encode($source_fileno, $source_str, $input_fileno, $input_str, $output_fileno, $output_str);

  return $output_str if !defined $output;
}


sub decode {
  my ($source, $input, $output) = @_;

  my ($source_fileno, $source_str, $input_fileno, $input_str, $output_fileno, $output_str);

  $source_fileno = $input_fileno = $output_fileno = -1;

  if (ref $source eq 'GLOB') {
    $source_fileno = fileno($source);
  } else {
    $source_str = $source;
  }

  if (ref $input eq 'GLOB') {
    $input_fileno = fileno($input);
  } else {
    $input_str = $input;
  }

  if (defined $output) {
    die "output argument to decode should be a file handle or undef"
      if ref $output ne 'GLOB';

    $output_fileno = fileno($output);
  } else {
    $output_str = '';
  }

  _decode($source_fileno, $source_str, $input_fileno, $input_str, $output_fileno, $output_str);

  return $output_str if !defined $output;
}


1;




=head1 NAME

Vcdiff::Xdelta3 - Build and install Josh MacDonald's delta encoding library

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SEE ALSO

L<Vcdiff-Xdelta3 github repo|https://github.com/hoytech/Vcdiff-Xdelta3>

=head1 AUTHOR

Doug Hoyte, C<< <doug@hcsw.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2013 Doug Hoyte.

This module includes xdelta3 which is copyright Joshua P. MacDonald. xdelta3 is licensed under the GNU GPL 2 which can be found in the inc/COPYING file of this distribution.

Because of xdelta3's license, this module is licensed under the GNU GPL 2.
