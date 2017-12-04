use strict;
use warnings;
use Syntax::Keyword::EachPerOp;
use Test::More;

my %stuff = (a => 1, b => 2, c => 3, '' => 4);
my $iter;
while (my ($key, $value) = each %stuff) {
  is $stuff{$key}, $value, "value of $key is $value";
  $iter++;
  is keys(%stuff), 4, '4 keys';
  is values(%stuff), 4, '4 values';
  my $iter_inner;
  while (defined(my $key = each %stuff)) {
    ok exists $stuff{$key}, "key $key exists";
    $iter_inner++;
  }
  is $iter_inner, 4, '4 inner iterations';
}
is $iter, 4, '4 outer iterations';

my @things = qw(foo bar baz);
undef $iter;
while (my ($i, $elem) = each @things) {
  is $things[$i], $elem, "value of $i is $elem";
  $iter++;
  if ("$]" >= 5.012) {
    is keys(@things), 3, '3 indexes';
    is values(@things), 3, '3 elements';
  }
  my $iter_inner;
  while (defined(my $i = each @things)) {
    ok $i <= $#things, "index $i exists";
    $iter_inner++;
  }
  is $iter_inner, 3, '3 inner iterations';
}
is $iter, 3, '3 outer iterations';

done_testing;
