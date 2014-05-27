use strict;

use ExtUtils::MakeMaker;

my %args = (
    NAME => 'Vcdiff::Xdelta3',
    VERSION_FROM => 'lib/Vcdiff/Xdelta3.pm',
    PREREQ_PM => {
      'Vcdiff' => '0.505',
      'Carp' => 0,
    },
    LIBS => [],
    DEFINE => '',
    INC => '-Iinc/',
    OBJECT => 'inc/xdelta3.o Interface.o',
    LDFROM => 'xdelta3.o Interface.o',
    LICENSE => 'gpl_2',
    dist => {
      PREOP => 'pod2text $(VERSION_FROM) > $(DISTVNAME)/README',
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
