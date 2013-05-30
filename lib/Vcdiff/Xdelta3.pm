package Vcdiff::Xdelta3;

use strict;

our $VERSION = '0.100';

require XSLoader;
XSLoader::load('Vcdiff::Xdelta3', $VERSION);



sub encode {
  my ($source_file, $input_file) = @_;

  open(my $source_fh, '<', $source_file) || die "couldn't open $source_file: $!";
  open(my $input_fh, '<', $input_file) || die "couldn't open $input_file: $!";

  _encode(fileno($source_fh), fileno($input_fh), 1);
}


sub decode {
  my ($source_file, $input_file) = @_;

  open(my $source_fh, '<', $source_file) || die "couldn't open $source_file: $!";
  open(my $input_fh, '<', $input_file) || die "couldn't open $input_file: $!";

  _decode(fileno($source_fh), fileno($input_fh), 1);
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
