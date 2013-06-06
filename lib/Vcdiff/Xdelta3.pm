package Vcdiff::Xdelta3;

use strict;

use Vcdiff;

our $VERSION = '0.100';

require XSLoader;
XSLoader::load('Vcdiff::Xdelta3', $VERSION);



sub diff {
  my ($source, $input, $output) = @_;

  my ($source_fileno, $source_str, $input_fileno, $input_str, $output_fileno, $output_str);

  $source_fileno = $input_fileno = $output_fileno = -1;

  if (!defined $source) {
    die "diff needs source argument";
  } elsif (ref $source eq 'GLOB') {
    $source_fileno = fileno($source);
  } else {
    $source_str = $source;
  }

  if (!defined $input) {
    die "diff needs target argument";
  } elsif (ref $input eq 'GLOB') {
    $input_fileno = fileno($input);
  } else {
    $input_str = $input;
  }

  if (defined $output) {
    die "output argument to diff should be a file handle or undef"
      if ref $output ne 'GLOB';

    $output_fileno = fileno($output);
  } else {
    $output_str = '';
  }

  _encode($source_fileno, $source_str, $input_fileno, $input_str, $output_fileno, $output_str);

  return $output_str if !defined $output;
}


sub patch {
  my ($source, $input, $output) = @_;

  my ($source_fileno, $source_str, $input_fileno, $input_str, $output_fileno, $output_str);

  $source_fileno = $input_fileno = $output_fileno = -1;

  if (!defined $source) {
    die "patch needs source argument";
  } elsif (ref $source eq 'GLOB') {
    $source_fileno = fileno($source);
  } else {
    $source_str = $source;
  }

  if (!defined $input) {
    die "patch needs delta argument";
  } elsif (ref $input eq 'GLOB') {
    $input_fileno = fileno($input);
  } else {
    $input_str = $input;
  }

  if (defined $output) {
    die "output argument to patch should be a file handle or undef"
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

Vcdiff::Xdelta3 - Xdelta3 backend for Vcdiff

=head1 SYNOPSIS

    use Vcdiff::Xdelta3;

    my $delta = Vcdiff::Xdelta3::diff($source, $target);

    ## ... send the $delta string to someone who has $source ...

    my $target2 = Vcdiff::Xdelta3::patch($source, $delta);

    ## $target2 is the same as $targe

This module is a backend to the L<Vcdiff> module and isn't usually used directly.


=head1 DESCRIPTION

Xdelta3 is a delta encoding library by Joshua MacDonald. The xdelta3 source code is embedded into this module and built as a shared object. The xdelta3 binary is not built.


=head1 PROS

=over

=item *

Doesn't have arbitrary size limitations on source, target, or delta files.

=back


=head1 CONS

=over

=item *

GPL licensed

=back


=head1 SEE ALSO

L<Vcdiff-Xdelta3 github repo|https://github.com/hoytech/Vcdiff-Xdelta3>

L<Vcdiff>

L<Official Xdelta3 website|http://xdelta.org/>


=head1 AUTHOR

Doug Hoyte, C<< <doug@hcsw.org> >>


=head1 COPYRIGHT & LICENSE

Copyright 2013 Doug Hoyte.

This module includes xdelta3 which is copyright Joshua P. MacDonald. xdelta3 is licensed under the GNU GPL 2 which can be found in the inc/COPYING file of this distribution.

Because of xdelta3's license, this module is licensed under the GNU GPL 2.
