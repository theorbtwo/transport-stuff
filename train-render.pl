#!/usr/bin/perl
use warnings;
use strict;
use Template;
use TSDB::Schema;
use DateTime;
use Data::Dump::Streamer 'Dump', 'Dumper';
use 5.10.0;

my $schema = TSDB::Schema->connect('dbi:SQLite:/home/theorb/tsdb.sqlite');
my $day = DateTime->new(year => 2011, month => 5, day => 2);
my $s = $schema->resultset('Schedule')->find({train_uid => 'C10150', schedule_order => 1});

print {GW => 'First Great Western'}->{$s->atoc_code}, "\n";
print {EE => 'Empty Coaching Stock',
       XX => 'Express Passenger'
     }->{$s->category}, "\n";

Dump {$s->get_columns};

my $tt = Template->new({
                        COMPILE_EXT => '.tt.pl',
                        STRICT => 1,
                       });

for my $sl ($s->locations) {
  my $dump_copy = {$sl->get_columns};
  # These fields are implied.
  delete $dump_copy->{$_} for qw<train_uid schedule_order location_order>;
  
  if (not defined $sl->arrival and not defined $sl->departure) {
    my $pass = s_to_hms($sl->pass);
    printf("%8s %s [just passing through]%s\n", 
           s_to_hms($sl->pass),
           tiploc_to_name($sl->tiploc_code),
           $sl->platform
           ? " at platform ".$sl->platform
           : ''
          );
    delete $dump_copy->{$_} for qw<pass tiploc_code platform>;
  } else {
    
    if (defined $sl->arrival) {
      my $public_difference = $sl->arrival - $sl->public_arrival;

      printf("%8s %s %s\n", 
             s_to_hms($sl->arrival),
             $sl->arrival_line
             ? "via ".$sl->arrival_line
             : '',
             $public_difference
             ? " ($public_difference sec later on public schedule)"
             : ""
            );

      delete $dump_copy->{$_} for qw<arrival public_arrival arrival_line>;
    }

    my @activities = map {
      my $text = {
                  'TB' => 'begins',
                  'T ' => 'passengers IO',
                  'TF' => 'terminates',
                 }->{$_->activity};
      if (!$text) {
        die "Activity ".$_->activity;
      }
      $text;
    } $sl->activities;

    my $activities = '';
    if (@activities) {
      $activities = '[' . join(', ', @activities) . ']';
    }

    my $platform = '';
    if (defined $sl->platform) {
      $platform = 'at platform '.$sl->platform;
      delete $dump_copy->{platform};
    }


    my $station = tiploc_to_name($sl->tiploc_code);
    delete $dump_copy->{tiploc_code};

    printf "%8s  $station $platform $activities\n", '';

    if (defined $sl->departure) {
      my $public_difference = $sl->departure - $sl->public_departure;

      printf("%8s %s %s\n", 
             s_to_hms($sl->departure),
             $sl->departure_line
             ? "via ".$sl->departure_line
             : '',
             $public_difference
             ? " ($public_difference sec later on public schedule)"
             : ""
            );

      delete $dump_copy->{$_} for qw<departure public_departure departure_line>;
    }

  }

  # Right, no we try to dump a report of interesting fields that we missed.
  for my $k (keys %$dump_copy) {
    delete $dump_copy->{$k} if not $dump_copy->{$k};
  }
  if (keys %$dump_copy) {
    Dump $dump_copy;
  }

  print "\n";
}

my %unknown;
sub tiploc_to_name {
  my ($tiploc) = @_;

  my $station = {
                 BRGEND  => 'Bridgend',
                 BRSTPWY => 'Bristol Parkway',
                 CRDFCEN => 'Cardiff Central',
                 DIDCOTP => 'Didcot Parkway',
                 NEATH   => 'Neath',
                 NWPTRTG => 'Newport (Gwent)',
                 PADTON  => 'Paddington',
                 PTALBOT => 'Port Talbot Parkway',
                 RDNGSTN => 'Reading Station',
                 SDON    => 'Swindon',
                 SWANSEA => 'Swansea',

                 ACTONW  => 'Acton West',
                 CHALLOW => 'Challow',
                 EBBWJ   => 'Ebbw Junction',
                 HLVNGTN => 'Hullavington',
                 HTRWAJN => 'Heathrow Airport Junction',
                 LDBRKJ  => 'Ladbroke Grove',
                 LWERWJN => 'Llanwern West Junction',
                 MAINDWJ => 'Maindee West Junction',
                 MDNHEAD => 'Maidenhead',
                 MRGMMJN => 'Margam Moors Junction',
                 MSHFILD => 'Marshfield',
                 PATCHWY => 'Patchway',
                 PILNING => 'Pilning',
                 PONYCLN => 'Pontyclun',
                 REDGWJN => 'Reading West Junction',
                 SEVTNLE => 'Severn Tunnel East',
                 SEVTNLJ => 'Severn Tunnel Junction',
                 SEVTNLW => 'Severn Tunnel West',
                 SLOUGH  => 'Slough',
                 STHALL  => 'Southall',
                 STORMY  => 'Stormy',
                 SWANSLE => 'Swansea Loop East',
                 TWYFORD => 'Twyford',
                 UFNGTN  => 'Uffington (Oxfordshire)',
                 WANTRD  => 'Wantage Road',
                 WSTLGHJ => 'Westerleigh Junction',
                 WTNBSTJ => 'Wootton Bassett Junction',

                 BATHSPA => 'Bath Spa',
                 BRSTLEJ => 'Bristol East Junction',
                 BRSTLTM => 'Bristol Temple Meads',
                 BTHMPTJ => 'Bathampton Junction',
                 CHIPNHM => 'Chippenham',
                 NSMRSTJ => 'North Somerset Junction',
                 THNGLEJ => 'Thingley East Junction',
                 TILHEJN => 'Tilehurst East Junction',
                }->{$tiploc};

  if (!$station) {
    warn "Unknown station tiploc $tiploc";
    $unknown{$tiploc}++;
    return $tiploc;
  }
  
  return $station;
}
END {
  for my $tiploc (sort keys %unknown) {
    printf "%-7s => '',\n", $tiploc;
  }
}

sub s_to_hms {
  my ($linear_s) = @_;
  my ($h, $m, $s) = (int($linear_s / (60*60)),
                     int($linear_s / 60) % 60,
                     $linear_s % 60
                    );
  sprintf "% 2d:%02d:%02d", $h, $m, $s;
}

__END__
$tt->process($template, $vars, $output, {binmode => ':utf8'}) or die $tt->error;

