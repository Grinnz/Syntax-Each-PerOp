use strict;
use warnings;
use Syntax::Each::PerOp;
use Test::More;

my %stuff = (a => 1, b => 2, c => 3, '' => 4);
my $iter;
my $numkeys = keys %stuff;
while (my ($key, $value) = each %stuff) {
  is $stuff{$key}, $value, "value of $key is $value";
  $iter++;
  
  is 0+@{[keys(%stuff)]}, $numkeys, "$numkeys keys";
  is 0+@{[values(%stuff)]}, $numkeys, "$numkeys values";
  is_deeply +{%stuff}, \%stuff, "list access";
  
  my $iter_inner;
  while (defined(my $key = each %stuff)) {
    ok exists $stuff{$key}, "key $key exists";
    $iter_inner++;
  }
  is $iter_inner, $numkeys, "$numkeys inner iterations";
  
  $stuff{"new_$key"} = delete $stuff{$key};
}
is $iter, 4, '4 outer iterations';
is keys(%stuff), 4, '4 keys remain';

my @things = qw(foo bar baz);
undef $iter;
$numkeys = @things;
while (my ($i, $elem) = each @things) {
  is $things[$i], $elem, "value of $i is $elem";
  $iter++;
  
  if ("$]" >= 5.012) {
    # string-eval to avoid compilation failures
    eval q{
      is keys(@things), $numkeys, "$numkeys indexes";
      is values(@things), $numkeys, "$numkeys elements";
    1} or die $@;
  }
  
  is_deeply [@things], \@things, "list access";
  
  my $iter_inner;
  while (defined(my $i = each @things)) {
    ok $i <= $#things, "index $i exists";
    $iter_inner++;
  }
  is $iter_inner, $numkeys, "$numkeys inner iterations";
  
  push @things, scalar(@things);
  $numkeys++;
}
is $iter, 3, '3 outer iterations';
is 0+@things, 6, '3 elements added';

ok !(eval 'each \%stuff; 1'), 'no hashrefs';
ok !(eval 'each \@things; 1'), 'no arrayrefs';

my $lastkey;
$numkeys = keys %stuff;
for my $i (1..$numkeys+2) {
  my $iterated;
  while (my $k = each %stuff) {
    $iterated = 1;
    isnt $k, $lastkey, 'different key';
    $lastkey = $k;
    last;
  }
  if ($i == $numkeys+1) {
    ok !$iterated, 'iteration completed';
  } else {
    ok $iterated, 'iteration continued';
  }
}

done_testing;
