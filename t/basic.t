use strict;
use Test::More;

use_ok 'Hash::Purge';

my $purger = Hash::Purge->new();

isa_ok($purger, 'Hash::Purge');

subtest 'Checking `can` methods' => sub {
    my @methods = qw(purge _purge_array _purge_scalar);

    can_ok($purger, @methods);
};

subtest 'Testing basic purge' => sub {
    # 1) One undef key
    my $test = {
        foo => undef,
        bar => 'baz',
        bat => 'qux',
    };

    my $expect = {
        bar => 'baz',
        bat => 'qux',
    };

    my $result = $purger->purge($test);

    is_deeply($result, $expect, 'Purge basis structure correctly');


    # 2) One empty HashRef with ignore_empty_ref disabled
    $test = {
        foo => {},
        bar => 'baz',
        bat => 'qux',
    };

    $expect = {
        bar => 'baz',
        bat => 'qux',
    };

    $result = $purger->purge($test);

    is_deeply($result, $expect, 'Purge basis structure correctly');

    # 3) One empty HashRef with ignore_empty_ref disabled
    $test = {
        foo => {},
        bar => 'baz',
        bat => 'qux',
    };

    $expect = {
        bar => 'baz',
        bat => 'qux',
    };

    $result = $purger->purge($test);

    is_deeply($result, $expect, 'Purge basis structure correctly');

    # 4) One empty ArrayRef with ignore_empty_ref disabled
    $test = {
        foo => [],
        bar => 'baz',
        bat => 'qux',
    };

    $expect = {
        bar => 'baz',
        bat => 'qux',
    };

    $result = $purger->purge($test);

    is_deeply($result, $expect, 'Purge basis structure correctly');


    # 5) One empty ScalarRef with ignore_empty_ref disabled
    my $var = undef;

    $test = {
        foo => \$var,
        bar => 'baz',
        bat => 'qux',
    };

    $expect = {
        bar => 'baz',
        bat => 'qux',
    };

    $result = $purger->purge($test);

    is_deeply($result, $expect, 'Purge basis structure correctly');
};

done_testing();
