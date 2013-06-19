use strict;

use ExtUtils::MakeMaker;

# gcc -DHAVE_CONFIG_H -I.    -Wall -Wshadow -fno-builtin -Wextra -Wsign-compare -Wextra -Wno-unused-parameter -pedantic -std=c99 -DGENERIC_ENCODE_TABLES=0 -DREGRESSION_TEST=1 -DSECONDARY_DJW=1 -DSECONDARY_FGK=1 -DXD3_POSIX=1 -DXD3_USE_LARGEFILE64=1 -DXD3_MAIN=1  -DXD3_DEBUG=0 -g -O2 -MT xdelta3-xdelta3.o -MD -MP -MF .deps/xdelta3-xdelta3.Tpo -c -o xdelta3-xdelta3.o `test -f 'xdelta3.c' || echo './'`xdelta3.c

my %args = (
    NAME => 'Vcdiff::Xdelta3',
    VERSION_FROM => 'lib/Vcdiff/Xdelta3.pm',
    PREREQ_PM => {
      'Vcdiff' => '0.500',
      'Carp' => 0,
    },
    LIBS => [],
    DEFINE => '',
    INC => '-Iinc/',
    OBJECT => 'inc/xdelta3.o Interface.o',
    LDFROM => 'xdelta3.o Interface.o',
    LICENSE => 'gpl',
    dist => {
      PREOP => 'perldoc -uT lib/Vcdiff/Xdelta3.pm > README.pod; pod2text README.pod > $(DISTVNAME)/README',
    },
);


my $eummv = eval ($ExtUtils::MakeMaker::VERSION);
if ($eummv >= 6.45) {
    $args{META_MERGE} = {
        resources => {
            repository => 'git://github.com/hoytech/Vcdiff-Xdelta3.git',
            bugtracker => 'https://github.com/hoytech/Vcdiff-Xdelta3/issues',
        },
    };
}

WriteMakefile(%args);
