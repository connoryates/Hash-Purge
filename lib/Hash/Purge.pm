package Hash::Purge;

use strict;
use 5.008_005;
our $VERSION = '0.01';

sub purge {
    my ($self, $hash) = @_;

    return $hash unless defined $hash;
    return $hash unless ref($hash) and ref($hash) eq 'HASH';

    my %cleaned = ();
    while (my ($key, $val) = each %$hash) {
        if (ref($val) and ref($val) eq 'HASH') {
            if (keys %$val) {
                $cleaned{$key} = $self->clean_hash($val);
            }
        }
        elsif (ref($val) and ref($val) eq 'ARRAY') {
            $cleaned{$key} = [ grep { defined $_ } @$val ];
        }
        else {
            $cleaned{$key} = $val if defined $val;
        }
    }

    return \%cleaned;
}

1;

__END__

=encoding utf-8

=head1 NAME

Hash::Purge - Purge hashes

=head1 SYNOPSIS

  use Hash::Purge;

  my $purger = Hash::Purge->new;

  my $hash_ref = {
      key_1 => {
          sub_key_1 => ['foo', 'bar', undef],
          sub_key_2 => {},
          sub_key_3    => {
              subkey_4 => undef
          },
          sub_key_5 => {
              foo => 'bar',
          },
      },
      key_2 => undef,
      key_3 => $SCALAR_REF,
      key_4 => $CODE_REF,
      key_5 => $STRING,
  };

  my $purged = $purger->purge($hash_ref);

  __END__

  Output:

  {
     key_1 => {
         sub_key_1 => ['foo', 'bar'],
         sub_key_5 => {
             foo => 'bar',
         },
     },
     key_3 => $SCALAR_REF,
     key_4 => $CODE_REF,
     key_5 => $STRING,
  };

=head1 DESCRIPTION

Remove undefined values or empty references from your nested hash structure (or unnested)

=head1 AUTHOR

Connor Yates E<lt>connor.t.yates@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2017- Connor Yates

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
