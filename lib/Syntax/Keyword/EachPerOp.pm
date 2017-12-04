package Syntax::Keyword::EachPerOp;

use strict;
use warnings;
use Exporter 'import';
use Devel::Callsite;

our $VERSION = '0.001';

our @EXPORT = 'each';

my %iterators;

sub each (\[@%]) {
  my ($structure) = @_;
  my $id = join '$', callsite(), context(), 0+$structure;
  my $is_hash = ref($structure) eq 'HASH';
  $iterators{$id} = [$is_hash ? keys %$structure : 0..$#$structure]
    unless exists $iterators{$id};
  if (@{$iterators{$id}}) {
    my $key = shift @{$iterators{$id}};
    return wantarray ? ($key, $is_hash ? $structure->{$key} : $structure->[$key]) : $key;
  } else {
    delete $iterators{$id};
    return ();
  }
}

1;

=head1 NAME

Syntax::Keyword::EachPerOp - A per-op each function

=head1 SYNOPSIS

  use Syntax::Keyword::EachPerOp;
  
  while (my ($k, $v) = each %stuff) {
    # these now will not break the loop
    my $all_keys = keys %stuff;
    my $all_values = values %stuff;
    # and is re-entrant
    while (my ($inner_k, $inner_v) = each %stuff) {
      ...
    }
  }
  
  # other normal usage supported
  while (defined(my $key = each %stuff)) { ... }
  while (my ($i, $e) = each @stuff) { ... }
  while (defined(my $index = each @stuff)) { ... }

=head1 DESCRIPTION

The L<each|perlfunc/each> function can be problematic as it is implemented as
an iterator in the hash or array itself. This means it cannot be nested as the
iterator will be shared between the loops, and furthermore, the
L<keys|perlfunc/keys> and L<values|perlfunc/values> functions share this
iterator so can cause the same problems. This module provides an L</each>
function that iterates locally to the op itself, so it can be nested and used
with C<keys> and C<values> as expected.

=head1 FUNCTIONS

The L</each> function is exported by default.

=head2 each

  my ($key, $value) = each %hash;
  my $key = each %hash;
  my ($index, $element) = each @array;
  my $index = each @array;

Returns the next key-value (or index-element) pair in list context, or
key/index in scalar context, of the given hash or array. When no more pairs
remain, returns an empty list, or C<undef> in scalar context.

The keys or indexes of the data structure are stored for iteration the first
time C<each> is called in a particular location, so deleting or adding elements
will not affect the ongoing iteration.

=head1 CAVEATS

Since this version of C<each> will not be implicitly wrapped in a C<defined>
check when alone in a while loop condition, you must explicitly check if the
return value is defined when iterating over the scalar-context form of this
function, to avoid inadvertently halting the loop when a falsey key or index is
returned.

  while (my $key = each %hash) {          # wrong
  while (defined(my $key = each %hash)) { # right

L</each> calls L<keys|perlfunc/keys> internally, so do not use this version of
each (or the core version!) within a core call to L<each|perlfunc/each> on the
same structure.

The behavior of implicitly assigning to C<$_> when called without assignment in
a while loop condition is not supported.

As this version of C<each> is tied to the op that calls it, if you call it
within another loop or function and it does not complete the iteration, then it
will resume the same iteration the next time through. This is also true of the
core C<each> function, since it is tied to the hash or array itself. Unlike the
core function which can be reset by calling C<keys> or C<values> on the data
structure, it is not possible to reset this function's iterator except by
allowing it to iterate to the end.

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Dan Book <dbook@cpan.org>

=head1 CREDITS

L<"each_pair" in Var::Pairs|Var::Pairs/"each_pair %hash"> by Damian Conway for
inspiration.

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2017 by Dan Book.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=head1 SEE ALSO

L<Perl::Critic::Policy::Freenode::Each>
