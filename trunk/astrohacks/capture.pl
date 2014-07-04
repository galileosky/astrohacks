#!/usr/bin/perl
#
# capture one 600-second image

use lib '.';
use strict;
use Astro;

my $duration = $ARGV[0] || 30;
$duration =~ s/\D//g;

my $temp = sprintf("%d", $ARGV[1] || 25);
my $bin = $ARGV[2] || "2x2";
my $outfile = $ARGV[3];

print STDERR "Capturing $duration seconds at $temp C with binmode $bin\n";
my $filename = Astro::captureSBIG( $duration, $temp, $bin );

if (defined($outfile)) {
	`/bin/mv -f $filename $outfile`;
}
print STDERR "Captured file $outfile\n";
