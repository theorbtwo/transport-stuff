#!/usr/bin/perl
use warnings;
use strict;
use LWP::Simple 'mirror';
use HTML::TreeBuilder;
use Data::Dump::Streamer;
$|=1;

# http://deaves47.users.btopenworld.com/CRS/CRSx.htm
# (Where x is a..z.)
# gives name, crs, nlc, tiploc, stanox.

for my $letter ('a'..'z') {
  my $url = "http://deaves47.users.btopenworld.com/stations/station$letter.htm";
  my $file = "data/deaves47/station$letter.htm";

  my $res = mirror($url, $file);
  print "$file: $res\n";
  # 200, OK  304, not updated.
  if ($res != 200 and $res != 304) {
    die "Error fetching $file from $url: $res";
  }

  my $tree = HTML::TreeBuilder->new_from_file($file);
  my $table = $tree->look_down(_tag => 'th',
                               sub {
                                 $_[0]->as_text eq 'Station'
                               })->look_up(_tag => 'table');

  my $rows = [$table->look_down(_tag => 'tr')];

  while (@$rows) {
    my $row = shift @$rows;

    next if $row->look_down(_tag => 'th');

    my @tds = $row->look_down(_tag => 'td');

    # This is a "see also" line, or similar strangeness.
    # Dunbridge
    next if ($tds[1]->attr('colspan'));
    next if (($tds[3]->attr('colspan')||1) == 6);

    # Closed stations are uninteresting for current purposes.
    next if $tds[3]->as_text =~ m/closed/i;

    my $data;

    $row->dump;

    $data->{name} = as_first_text($tds[0]);

    # 3: Status, not interesting.
    # 4: opwner, not interesting.
    $data->{operator} = $tds[5]->as_text;
    $data->{operator} =~ s/\xA0/ /g;

    if (lc($data->{operator}) eq 'n/a') {
      $data->{operator} = undef;
    }

    $data->{lon} = $tds[6]->as_text;
    $data->{lon} = undef if $data->{lon} eq "\xA0";

    $data->{lat} = $tds[7]->as_text;
    $data->{lat} = undef if $data->{lat} eq "\xA0";

    $data->{gridref} = $tds[8]->as_text;
    $data->{gridref} = undef if $data->{gridref} eq "\xA0";

    $data->{elrs}[0]{text} = $tds[1]->as_text;
    $data->{elrs}[0]{distance} = dist_to_m($tds[2]->as_text);

    for my $count (2 .. ($tds[0]->attr('rowspan') || 1)) {
      if ($count > 1) {
        $row = shift @$rows;
        @tds = $row->look_down(_tag=>'td');

        $row->dump;
      }

      my $line = {};

      $line->{elr} = $tds[0]->as_text;
      $line->{distance} = dist_to_m($tds[1]->as_text);

      push @{$data->{elrs}}, $line;
    }

    Dump $data;
  }
}

sub as_first_text {
  my ($e) = @_;

  if (!ref $e) {
    $e =~ s/\xA0/ /g;
    return $e;
  } else {
    return as_first_text(($e->content_list)[0]);
  }
}

sub dist_to_m {
  my ($text) = @_;
  # Get rid of non-breaking spaces.
  $text =~ s/\xA0/ /g;

  my ($miles, $chains) = $text =~ m/(\d+)m (\d+)ch/
    or die "Cannot get miles and chains from ".$text;
  
  # 80 chains to the mile, according to both drPoggs and units.dat.
  # 1609.344 meters to the mile, according to units.dat.
  return (($miles + $chains/80) * 1609.344);
}
