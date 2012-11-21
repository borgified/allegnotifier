#!/usr/bin/env perl

use warnings;
use strict;

use XML::Simple;
use LWP::Simple;

my $url="http://acss.alleg.net/CSSServer/StatsRest.svc/GetActivePlayers?token=AF3BE0FE-B9BA-4424-94C0-93744259D50A";

my $xml = XMLin(get($url));

#use Data::Dumper qw(Dumper);
#print Dumper $xml;
#exit;
my $x=0;

#print @{$$xml{'ActivePlayerData'}};

my $output;

foreach my $item (@{$$xml{'ActivePlayerData'}}){
	$output=$output."$$item{'PlayerName'}\($$item{'Rank'}\) ";
}

print $output;
