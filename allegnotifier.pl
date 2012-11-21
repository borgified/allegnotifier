#!/usr/bin/env perl

use warnings;
use strict;

use XML::Simple;
use LWP::Simple;
use DBI;

use Net::Twitter;
use Scalar::Util 'blessed';


my %acss = do '/secret/acss.config';

my $url = $acss{active_players};

my $xml = XMLin(get($url));

#use Data::Dumper qw(Dumper);
#print Dumper $xml;
#exit;

my @players;

foreach my $item (@{$$xml{'ActivePlayerData'}}){
	push(@players,"$$item{'PlayerName'}\($$item{'Rank'}\)");
}

my $players=join(' ',@players);

my $my_cnf = '/secret/my_cnf.cnf';

my $dbh = DBI->connect("DBI:mysql:"
                        . ";mysql_read_default_file=$my_cnf"
                        .';mysql_read_default_group=playerbase_predictor',
                        undef,
                        undef
                        ) or die "something went wrong ($DBI::errstr)";

my $sth=$dbh->prepare("insert into currentplayers (players) values ('$players')");
$sth->execute();

#broadcast a message out via twitter if num_players > $threshold
my $threshold=14;
my $num_players=@players;

my %config = do '/secret/twitter.config';

my $consumer_key		= $config{consumer_key};
my $consumer_secret		= $config{consumer_secret};
my $token			= $config{token};
my $token_secret		= $config{token_secret};

  my $nt = Net::Twitter->new(
      traits   => [qw/OAuth API::REST/],
      consumer_key        => $consumer_key,
      consumer_secret     => $consumer_secret,
      access_token        => $token,
      access_token_secret => $token_secret,
  );

if($num_players > $threshold){
	my $result = $nt->update("there are $num_players players online right now!");
}

  if ( my $err = $@ ) {
      die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

      warn "HTTP Response Code: ", $err->code, "\n",
           "HTTP Message......: ", $err->message, "\n",
           "Twitter error.....: ", $err->error, "\n";
  }

