# NAME

Hash::Purge - Purge your hash data

# SYNOPSIS

    use Hash::Purge;
    
    my $purger = Hash::Purge->new;
    
    my $hashref = {
        key1 => 'bar',
        key2 => undef,
        key3 => {
            key5 => undef,
            key6 => 7,
            key7 => {},
        },
        key4 => [undef, 3, 6],
    };

    my $cleaned_hashref = $purger->purge($hashref);
    
    # -- OUTPUT --
    
    {
        key1 => 'bar',
        key3 => {
            key6 => 7,
        },
        key4 => [3, 6],
    }

# DESCRIPTION

Hash::Purge will remove ```undef``` or specified values from your hash data. Handles nested data structures and empty references as well

# METHODS

```purge``` - Expects a HashRef, returns a HashRef

# CONSTRUCTOR

```perl
# Purge the string "foo" instead of undef
my $purger = Hash::Purge->new(
    purge => 'foo',
);
```

```perl
# Empty references ok
my $purger = Hash::Purge->new(
    empty_refs => 0,
);
```

By default, any exceptions raised will issue a warning and return ```undef```. If you would like exceptions to be fatal instead, you can specify ```fatal``` during construction:

```perl
my $purger = Hash::Purge->new(
    fatal => 1,
);
```

# AUTHOR

Connor Yates <connor.t.yates@gmail.com>

# COPYRIGHT

Copyright 2017- Connor Yates

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
