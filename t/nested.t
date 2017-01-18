use strict;
use warnings;

use Test::More;

use_ok 'Hash::Purge';

my $purger = Hash::Purge->new();

isa_ok($purger, 'Hash::Purge');

subtest 'Testing nested HashRefs' => sub {
    # 1) Single nested HashRef with undef values
    my $test = {
        foo => 'bar',
        bat => {
            baz => undef,
            qux => 'bux',
        },
    };

    my $expect = {
        foo => 'bar',
        bat => {
            qux => 'bux',
        },
    };

    my $result = $purger->purge($test);

    is_deeply($result, $expect, 'Purged nested HashRef correctly');


    # 2) Single nested HashRef with an empty HashRef
    $test = {
        foo => 'bar',
        bat => {
            baz => {},
            qux => 'bux',
        },
    };

    $expect = {
        foo => 'bar',
        bat => {
            qux => 'bux',
        },
    };

    $result = $purger->purge($test);

    is_deeply($result, $expect, 'Purged nested HashRef correctly');


    # 3) Double nested HashRef with undef values
    $test = {
        foo => 'bar',
        bat => {
            baz => {
                boo => 'zoo',
                goo => undef,
            },
            qux => 'bux',
        },
    };

    $expect = {
        foo => 'bar',
        bat => {
            baz => {
                boo => 'zoo',
            },
            qux => 'bux',
        },
    };

    $result = $purger->purge($test);

    is_deeply($result, $expect, 'Purged nested HashRef correctly');


    # 4) Double nested HashRef with empty keys
    $test = {
        foo => 'bar',
        bat => {
            baz => {
                boo => 'zoo',
                goo => {},
            },
            qux => 'bux',
        },
    };

    $expect = {
        foo => 'bar',
        bat => {
            baz => {
                boo => 'zoo',
            },
            qux => 'bux',
        },
    };

    $result = $purger->purge($test);

    is_deeply($result, $expect, 'Purged nested HashRef correctly');
};

subtest 'Testing nested ArrayRefs' => sub {
    # 1) Undef element and empty ArrayRef
    my $test = {
        foo => [
            [
                'bar',
                undef,
            ],
            [
                'baz',
                'qux',
            ],
            [],
        ]
    };

    my $expect = {
        foo => [
            [
                'bar',
            ],
            [
                'baz',
                'qux',
            ],
        ]
    };

    my $result = $purger->purge($test);

    is_deeply($result, $expect, 'Purged nested ArrayRef correctly');


    # 2) Undef as the only element, nested ArrayRef with empty ref
    # and undef as the only element
    $test = {
        foo => [undef],
        bar => [],
        baz => [
            [],
            [undef],
            ['foo'],
        ],        
    };

    my $expect = {
        baz => [
            ['foo'],
        ],
    };

    $result = $purger->purge($test);

    is_deeply($result, $expect, 'Purged nested ArrayRef correctly');
}; 

subtest 'Complex nested structures' => sub {
    my $test = {
        foo => [
            {
                bar => 'baz',
            },
            {
                bar => undef,
            },
            {}
        ],
        bat => 'qux',
        tux => {},
        lux => ['bax', undef]
    };

    my $expect = {
        foo => [
            {
                bar => 'baz',
            },
        ],
        bat => 'qux',
        lux => ['bax'],
    };

    my $result = $purger->purge($test);

    is_deeply($result, $expect, 'Purged complex nested structure correctly');


    $test = {
        foo => {
            bar => [
                {
                    baz => undef,
                    foo => 'boo,
                    qux => ['bux', 'sux', 'fux'],
                    yux => ['bux', 'sux', undef, 'fux'],
                    nux => ['bux', 'sux', {}, 'fux'],
                    mux => ['bux', 'sux', [], 'fux'],

                },
                undef,
            ],
        },
    };
};

done_testing();
