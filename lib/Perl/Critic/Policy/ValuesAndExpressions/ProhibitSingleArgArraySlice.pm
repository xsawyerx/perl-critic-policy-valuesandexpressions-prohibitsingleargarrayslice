package Perl::Critic::Policy::ValuesAndExpressions::ProhibitSingleArgArraySlice;
# ABSTRACT: Prohibit using an array slice with only one index

use strict;
use warnings;

use Perl::Critic::Utils qw(:severities :classification :ppi);
use parent 'Perl::Critic::Policy';

our $VERSION = '0.001';

use constant 'DESC' => 'Single argument to array slice';
use constant 'EXPL' => 'Using an array slice returns a list, '
                     . 'even when accessing a single value. '
                     . 'Instead, please rewrite this as a a '
                     . 'single value access, not array slice.';

sub supported_parameters { () }
sub default_severity     {$SEVERITY_HIGHEST}
sub default_themes       {'bugs'}
sub applies_to           {'PPI::Token::Symbol'}

# TODO Check for a function in the subscript? Strict mode?

sub violates {
    my ( $self, $elem ) = @_;
    $elem->isa('PPI::Token::Symbol')
        or return ();

    substr( "$elem", 0, 1 ) eq '@'
        or return ();

    my $next = $elem->snext_sibling;
    $next->isa('PPI::Structure::Subscript')
        or return ();

    my @children = $next->children;
    @children > 1
        and return ();

    @children == 1
        and return $self->violation( DESC(), EXPL(), $next );

    return $self->violation(
        'Empty subscript',
        'You have an array slice with an empty subscript',
        $next,
    );
}

1;

__END__

=head1 DESCRIPTION

When using an array slice C<@foo[]>, you can retrieve multiple values by
giving more than one index. Sometimes, however, either due to typo or
inexperience, we might only provide a single index. This is a problem due
to the list context enforced.

Perl warns you about this, but it will only do this during runtime. This
policy allows you to detect it statically.

  # scalar context, single value retrieved
  my $one_value = $array[$index];            # ok

  # List context, multiple values retrieved
  my @values    = @array[ $index1, $index2 ] # ok

  # List context, single value retrived - the size of the array!
  # Perl will warn you, but only in runtime
  my $value     = @array[$index];            # not ok

=head1 CONFIGURATION

This policy is not configurable except for the standard options.

=head1 SEE ALSO

L<Perl::Critic>