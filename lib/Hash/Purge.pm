package Hash::Purge;

use strict;
use 5.008_005;

use Carp qw(cluck confess);

our $VERSION = '0.01';

sub new {
    my ($class, %data) = @_;

    my $self = bless {
        _purge            => $data{purge}            || undef,
        _ignore_empty_ref => $data{ignore_empty_ref} || undef,
        _fatal            => $data{fatal}            || undef,
        _warnings         => $data{warnings}         || 1,
        _flag             => undef,
        _error_msg        => undef,
    }, $class;

    return $self;
}

sub purge {
    my ($self, $hash) = @_;

    $self->_handle($hash);

    $self->_error if $self->{_flag};

    my %cleaned = ();

    while (my ($key, $val) = each %$hash) {
        if (ref($val) and ref($val) eq 'HASH') {
            if (keys %$val) {
                $cleaned{$key} = $self->purge($val);
            }
            elsif ($self->{_ignore_empty_ref}) {
                $cleaned{$key} = $val;
            }
        }
        elsif (ref($val) and ref($val) eq 'ARRAY') {
            my $array = $self->_purge_array($val);
            $cleaned{$key} = $array if defined $array;
        }
        else {
            my $scalar = $self->_purge_scalar($val);
            $cleaned{$key} = $scalar if defined $scalar;
        }
    }

    return \%cleaned;
}

sub _purge_array {
    my ($self, $array) = @_;

    my @cleaned = ();

    if (@$array) {
        if (grep { defined $_ } @$array) {
            foreach my $element (@$array) {
                if (ref($element) and ref($element) eq 'ARRAY') {
                    if (@$element) {
                        if (my @defined = grep { defined $_ } @$element) {
                            push @cleaned, $self->_purge_array(\@defined);
                        }
                        elsif ($self->{_ignore_empty_ref}) {
                            # There shouldn't be any defined values
                            # in here anyways
                            push @cleaned, [];
                        }
                    }
                    elsif ($self->{_ignore_empty_ref}) {
                        push @cleaned, $element;
                    }
                    else {
                        next;
                    }
                }
                elsif (ref($element) and ref($element) eq 'HASH') {
                    my $purged_hash = $self->purge($element);
                    push @cleaned, $purged_hash if keys %$purged_hash;
                }
                elsif (ref($element) and ref($element) eq 'SCALAR') {
                    my $purged_scalar = $self->_purge_scalar($element);
                    push @cleaned, $purged_scalar if defined $purged_scalar;
                }
                elsif (!ref($element)) {
                    if ($self->{_purge}) {
                        push @cleaned, $element unless $element eq $self->{_purge};
                    }
                    else {
                        push @cleaned, $element if defined $element;
                    }
                }
                else {
                    cluck "Unknown datatype found : $element" if $self->{_warnings};
                }
            }
        }
        else {
            return undef;
        }
    }
    else {
        return undef;
    }

    return \@cleaned;
}

sub _purge_scalar {
    my ($self, $scalar) = @_;

    if (ref($scalar) and ref($scalar) eq 'SCALAR') {
        if (defined $$scalar and $self->{_purge}) {
            return $scalar unless $$scalar eq $self->{_purge};
        }
        elsif (defined $$scalar) {
            return $scalar if defined $scalar;
        }
        else {
            return undef;
        }
    }
    elsif (!ref($scalar)) {
        if ($self->{_purge}) {
            return $scalar unless $scalar eq $self->{_purge};
        }
        else {
            return $scalar if defined $scalar;
        }
    }

    return undef;
}

sub _handle {
    my ($self, $hash) = @_;

    if (not defined $hash) {
        $self->{_error_msg} = "Missing required arg! Found undefined HashRef";
        $self->{_flag}      = 1;
    }
    elsif (ref($hash) and ref($hash) ne 'HASH') {
        $self->{_error_msg} = "Argument must be a HashRef";
        $self->{_flag}      = 1;
    }
    elsif (!ref($hash)) {
        $self->{_error_msg} = "Argument is not a HashRef";
        $self->{_flag}      = 1;
    }

    return;
}

sub _error {
    my $self = shift;

    $self->{_error_msg} ||= 'Unknown error';

    if ($self->{_fatal}) {
        confess $self->{_error_msg}
    }
    elsif ($self->{_warnings}) {
        cluck $self->{_error_msg};
    }

    return;
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
