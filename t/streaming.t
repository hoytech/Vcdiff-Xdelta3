use strict;

use Test::More qw(no_plan);

use Vcdiff::Xdelta3;
use Vcdiff::Test;

Vcdiff::Test::streaming();

is($Vcdiff::backend, 'Vcdiff::Xdelta3', 'used correct backend');