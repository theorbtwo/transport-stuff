#!/usr/bin/perl
use 5.10.0;
use warnings;
use strict;
use Data::Dump::Streamer 'Dump', 'Dumper';
use DateTime;
use Time::HiRes 'time';
use TSDB::Schema;
$|=1;

my $train_category = {
                      OL => 'London Underground/Metro Service',
                      OU => 'Unadvertised Ordinary Passenger',
                      OO => 'Ordinary Passenger',
                      OS => 'Staff Train',
                      OW => 'Mixed',
                      #Express Passenger Trains
                      XC => 'Channel Tunnel',
                      XD => 'Sleeper (Europe Night Services)',
                      XI => 'International',
                      XR => 'Motorail',
                      XU => 'Unadvertised Express',
                      XX => 'Express Passenger',
                      XZ => 'Sleeper (Domestic)',
                      #Buses
                      BR => 'Bus - Replacement due to engineering work',
                      BS => 'Bus - WTT Service',
                      #Empty Coaching Stock Trains',
                      EE => 'Empty Coaching Stock (ECS)',
                      EL => 'ECS, London Underground/Metro Service.',
                      ES => 'ECS & Staff',
                      #Parcels and Postal Trains
                      JJ => 'Postal',
                      PM => 'Post Office Controlled Parcels',
                      PP => 'Parcels',
                      PV => 'Empty NPCCS',
                      #Departmental Trains
                      DD => 'Departmental',
                      DH => 'Civil Engineer',
                      DI => 'Mechanical & Electrical Engineer',
                      DQ => 'Stores',
                      DT => 'Test',
                      DY => 'Signal & Telecommunications Engineer',
                      #Light Locomotives
                      ZB => 'Locomotive & Brake Van',
                      ZZ => 'Light Locomotive',

                      #(Freight Categories currently under review)
                      #Railfreight Distribution
                      J2 => 'RfD Automotive (Components)',
                      H2 => 'RfD Automotive (Vehicles)',
                      J3 => 'RfD Edible Products (UK Contracts)',
                      J4 => 'RfD Industrial Minerals (UK Contracts)',
                      J5 => 'RfD Chemicals (UK Contracts)',
                      J6 => 'RfD Building Materials (UK Contracts)',
                      J8 => 'RfD General Merchandise (UK Contracts)',
                      H8 => 'RfD European',
                      J9 => 'RfD Freightliner (Contracts)',
                      H9 => 'RfD Freightliner (Other)',
                      #Trainload Freight
                      A0 => 'Coal (Distributive)',
                      E0 => 'Coal (Electricity) MGR',
                      B0 => 'Coal (Other) and Nuclear',
                      B1 => 'Metals',
                      B4 => 'Aggregates',
                      B5 => 'Domestic and Industrial Waste',
                      B6 => 'Building Materials (TLF)',
                      B7 => 'Petroleum Products',
                      #Railfreight Distribution (Channel Tunnel)
                      H0 => 'RfD European Channel Tunnel (Mixed Business)',
                      H1 => 'RfD European Channel Tunnel Intermodal',
                      H3 => 'RfD European Channel Tunnel Automotive',
                      H4 => 'RfD European Channel Tunnel Contract Services',
                      H5 => 'RfD European Channel Tunnel Haulmark',
                      H6 => 'RfD European Channel Tunnel Joint Venture',
                     };

my $formattings = {
                   # Header line, section 4.1.
                   'HD' => [
                            # [mainframe_ident => 20, ],  -- offically, this is one long field.
                            [junk_1 => 5],
                            [user_1 => 6],
                            [junk_2 => 3],
                            [date_gen => 6, 'yymmdd'],
                            [extract_date => 6, 'ddmmyy'],
                            [extract_time => 4, 'hhmm'],
                            # current-file-ref
                            [user_2 => 6],
                            [user_rotation => 1], # a..z, repeats every 26 extracts.
                            # last-file-ref
                            [user_3 => 6],
                            [user_prev_rotation => 1],
                            [update_or_full => 1],
                            [generator_version => 1],
                            [extract_start_date => 6, 'ddmmyy'],
                            [extract_end_date => 6, 'ddmmyy'],
                            [spare => 20],
                           ],

                   # TIPLOC insert, section 4.11.  Documentation is rather sketchy.
                   'TI' => [
                            [tiploc_code => 7, 'tiploc'],
                            [capitals_identification => 2],
                            [nlc => 6], # "nalco", "national location code"
                            [nlc_check_character => 1],
                            [tps_description => 26],
                            [stanox => 5],
                            [po_mcp_code => 4], # not used
                            [crs_code => 3],
                            [capri_description => 16],
                            [spare => 8],
                           ],

                   # AA association, section 4.10
                   'AA' => [
                            # N=new, D=delete, R=revise
                            [transaction_type => 1],
                            # the docs use the terms "main train" and
                            # "associated train", which I find
                            # confusing.
                            [main_train_uid => 6],
                            [secondary_train_uid => 6],
                            [association_start_date => 6, 'yymmdd'],
                            # 999999 if ongoing (no end date).
                            [association_end_date => 6, 'yymmdd'],
                            [days_of_week => 7, 'days_of_week'],
                            # JJ, VV, or NP.
                            # - JJ=Join
                            # - VV=divide
                            # - NP=next (?)
                            [assoc_cat_for_main => 1,],
                            [assoc_cat_for_secondary => 1,],
                            # S=standard (same day).
                            # N=next day (across midnight).
                            # P=previous day
                            [assoc_date_ind => 1],
                            # tiploc where this association applies (where it happens)?
                            [assoc_location => 7],
                            # The documentaton on these is *very* confusing.
                            [location_suffix_for_main => 1],
                            [location_suffix_for_secondary => 1],
                            [unused => 1], # unused, always T.
                            # P, passenger use
                            # O, operating use only
                            [assoc_type => 1],
                            [spare => 31],
                            # C - short term plan cancel
                            # N - new short term plan
                            # P - perm assoc
                            # O - short term plan overlay of perm assoc.
                            [stp_indicator => 1],
                           ],

                   # Basic Schedule
                   'BS' => [
                            [transaction_type => 1],
                            [train_uid => 6],
                            [runs_from => 6, 'yymmdd'],
                            [runs_to => 6, 'yymmdd'],
                            # mtwtfss
                            [days_run => 7, 'days_of_week'],
                            [bh_running => 1, 'enum',
                             {
                              ' ' => 'Runs on bank holidays',
                              'X' => 'Does not run on specified Bank Holiday Mondays',
                              'E' => 'Does not run on specified Edinburgh Holiday dates', # (no longer used).
                              'G' => 'Does not run on specified Glasgow Holiday dates',
                             }
                            ],
                            [status => 1, 'enum',
                             {'P'=>'Passenger & Parcels (Permanent)',
                              '1'=>'Passenger & Parcels (Short Term Plan)',
                              'B'=>'Bus (Permanent)',
                              '5'=>'Bus (Short Term Plan)',
                              'T'=>'Trip (Permanent)',
                             }],
                            [category => 2, 'enum', $train_category],
                            [train_identity => 4],
                            [headcode => 4],
                            # not used, always 1
                            [course_indicator => 1],
                            [service_code => 8],
                            [portion_id => 1],
                            [power_type => 3, 'enum',
                             {
                              '   ' => undef,
                              'D  ' => 'Diesel',
                              'DMU' => 'Diesel Mechanical Multiple Unit',
                              'HST' => 'High Speed Train',
                             }],
                            [timing_load => 4, 'timing_load'],
                            # in mph
                            [speed => 3],
                            [operating_characteristics => 6, 'enum',
                             # FIXME: actually a split, 1.
                             {
                              '      ' => undef,
                              'D     ' => 'DOO (Coaching stock)',
                              'DQ    ' => 'DOO, runs as required',
                              'Q     ' => 'runs as required',
                             }
                            ],
                            [train_class => 1, 'enum',
                             {
                              ' ' => 'First & Standard',
                              'B' => 'First & Standard',
                              'S' => 'Standard only'
                             }],
                            [sleepers => 1],
                            [reservations => 1],
                            [connection_indicator => 1],
                            [catering_codes => 4, 'split',
                             [1, 'catering_code'],
                             #{
                             # '    ' => undef,
                             # 'C   ' => 'Buffet service',
                             # 'T   ' => 'Trolley service',
                             # 'H   ' => 'Hot food available',
                             # 'R   ' => 'Resturant',
                             #}],
                            ],
                            [service_branding => 4],
                            [spare => 1],
                           ],
                   #  Basic Schedule Extra Details
                   'BX' => [
                            [traction_class => 4],
                            [uic_code => 5],
                            [atoc_code => 2],
                            [ats_code => 1],
                            [rsid => 8],
                            [data_source => 1],
                            [spare => 57],
                           ],
                   # 'LOWSTBRYW 1150 11503         TB'
                   # Origin Location
                   'LO' => [
                            [tiploc_code => 7, 'tiploc'],
                            [tiploc_instance => 1],
                            [departure => 5, 'hhmmh'],
                            [public_departure => 4, 'hhmmh'],
                            [platform => 3],
                            [departure_line => 3],
                            [engineering_allowance => 2, 'nh'],
                            [pathing_allowance => 2, 'nh'],
                            [activities => 12, 'activity'],
                            [performance_allowance => 2, 'nh'],
                            [spare => 37],
                           ],
                   # LIAVNCLFF 1204 1204H     120412041        T R
                   # 4.5   Intermediate Location
                   'LI' => [
                            [tiploc_code => 7, 'tiploc'],
                            [tiploc_instance => 1],
                            [arrival => 5, 'hhmmh'],
                            [departure => 5, 'hhmmh'],
                            [pass => 5, 'hhmmh'],
                            [public_arrival => 4, 'hhmmh'],
                            [public_departure => 4, 'hhmmh'],
                            [platform => 3],
                            [departure_line => 3],
                            [arrival_line => 3],
                            [activities => 12, 'activity'],
                            [engineering_allowance => 2, 'nh'],
                            [pathing_allowance => 2, 'nh'],
                            [performance_allowance => 2, 'nh'],
                            [spare => 20],
                           ],
                   # line terminates
                   'LT' => [
                            [tiploc_code => 7, 'tiploc'],
                            [tiploc_instance => 1],
                            [arrival => 5, 'hhmmh'],
                            [public_arrival => 4, 'hhmmh'],
                            [platform => 3],
                            [arrival_line => 3],
                            [activities => 12, 'activity'],
                            [spare => 43],
                           ],
                   # change en route
                   'CR' => [
                            [tiploc_code => 7, 'tiploc'],
                            [tiploc_instance => 1],
                            [category => 2, 'enum', $train_category],
                            [train_identity => 4],
                            [headcode => 4],
                            [course_indicator => 1],
                            [service_code => 8],
                            [portion_id => 1],
                            [power_type => 3],
                            [timing_load => 4],
                            [speed => 3],
                            [operating_characteristics => 6],
                            [train_class => 1],
                            [sleepers => 1],
                            [reservations => 1],
                            [connection_indicator => 1],
                            [catering_code => 4],
                            [service_branding => 4],
                            [traction_class => 4],
                            [uic_code => 5],
                            [rsid => 8],
                            [spare => 5],
                           ],
                  };


my $schema = TSDB::Schema->connect('dbi:SQLite:/home/theorb/tsdb.sqlite') or die;

local $/="\cM\cJ";
my $schedule = {};
my $start_time = time;
my $last_report_time = time;
my $line_n = 0;
while (my $rest = <>) {
  if (time - $last_report_time > 5) {
    printf "Processed %d lines in %d seconds = %f lines/second\n",
      $line_n, time-$start_time, $line_n / (time - $start_time);
    $last_report_time = time;
  }
  $line_n++;

  chomp $rest;

  # There seems to be some leading garbage at the front of the file.
  if ($rest =~ m/\n/) {
    $rest =~ s/.*\n//s;
  }

  # print "Raw: $rest\n";

  my ($type) = substr($rest, 0, 2, '');

  # tsdbexplorer/lib/tsdbexplorer.rb line 321
  # http://www.atoc.org/clientfiles/File/RSPDocuments/20070801.pdf

  my $formatting = $formattings->{$type};
  if (!$formatting) {
    warn "Don't know formatting for line type $type, rest of line '$rest'";
  }

  my $data;

  for my $format_spec (@$formatting) {
    my ($name, $length, $filter, $extra) = @$format_spec;
    my $value = substr($rest, 0, $length, '');

    given ($filter) {
      when (undef) {
        # nothing happens
      }

      when ('days_of_week') {
        #Days Run is a 7-character binary field with each character  set to 1 (train runs) or 0 (train 
        #does not run).  Position 1 = Monday, 2 = Tuesday, etc.  through to 7 = Sunday
        my $bits;
        for (0..7) {
          my $v = substr($value, 0, 1, '');
          $bits += 1<<$_ if $v;
        }
        $value = $bits;
      }

      when ('ddmmyy') {
        $value =~ m/(..)(..)(..)/ or die;
        $value = DateTime->new(year=>2000+$3, month=>$2, day=>$1, time_zone=>'Europe/London');
      }
      
      when ('yymmdd') {
        if ($value eq '999999') {
          $value = undef;
        } else {
          $value =~ m/(..)(..)(..)/ or die;
          $value = DateTime->new(year=>2000+$1, month=>$2, day=>$3, time_zone=>'Europe/London');
        }
      }
      
      when ('hhmmh') {
        if ($value =~ m/^ +/) {
          $value = undef;
        } else {
          $value =~ m/(..)(..)(h?)/ or die;
          # This creates a datetime object, which isn't the right way to do time-of-day -- should do a duration object instead.
          #$value = DateTime->new(year => 0, hour => $1, minute=>$2, second=>$3 ? 30 : 0);
          $value  = $1 * 60*60;
          $value += $2 * 60;
          $value += 30 if $3;
        }
      }

      when ('hhmm') {
        if ($value =~ m/^ +/) {
          $value = undef;
        } else {
          $value =~ m/(..)(..)(h?)/ or die;
          # This creates a datetime object, which isn't the right way to do time-of-day -- should do a duration object instead.
          #$value = DateTime->new(year => 0, hour => $1, minute=>$2, second=>$3 ? 30 : 0);
          $value  = $1 * 60*60;
          $value += $2 * 60;
          $value += 30 if $3;
        }
      }
      
      when ('nh') {
        if ($value =~ m/^ +$/) {
          $value = 0;
        } else {
          $value =~ m/^(\d+| )([H ]?)$/ or die "Invalid value '$value' for an nh column";
          $value = 60*($1||0) + 30*($2 eq 'H');
        }
      }
      
      when ('strip') {
        $value =~ s/^\s+//;
        $value =~ s/\s+$//;
      }
      
      when ('enum') {
        # (For dumping with dds, we want text here.  For inserting into a database,
        # we explicitly do not; it should be a translation table in the database somewhere.)
        # if (exists $extra->{$value}) {
        #   $value = $extra->{$value};
        # } else {
        #   die "Uknown value '$value' in enum for field named $name";
        # }
      }
      
      when ('activity') {
        # This is a 12-character field consisting of 6 2-character sub-fields, each of which is an enum.
        my @activities = grep {$_ ne '  '} ($value =~ m/(..)/g);
        my $activity_names = {
                              'A ' =>  'Stops or shunts for other trains to pass',
# 'AE' =>  'Attach/detach assisting locomotive',
# 'BL' =>  'Stops for banking locomotive',
                              'C ' =>  'Stops to change trainmen',
                              'D ' =>  'Stops to set down passengers',
                              '-D' =>  'Stops to detach vehicles',
# 'E ' =>  'Stops for examinationy',
# 'G ' =>  'National Rail Timetable data to add',
# 'H ' =>  'Notional activity to prevent WTT timing columns merge',
# 'HH ' =>  'As H, where a third column is involved',
                              'K ' =>  'Passenger count point',
# 'KC' =>  ' Ticket collection and examination point',
# 'KE' =>  ' Ticket examination point',
# 'KF' =>  ' Ticket Examination Point, 1st Class only',
# 'KS' =>  ' Selective Ticket Examination Point',
# 'L ' =>  'Stops to change locomotives',
                              'N ' =>  'Stop not advertised',
                              'OP' =>  'Stops for other operating reasons',
# 'OR' =>  ' Train Locomotive on rear',
                              'PR' =>  'Propelling between points shown',
                              'R ' =>  'Stops when required',
                              'RM' =>  'Reversing movement, or driver changes ends',
                              'RR' =>  'Stops for locomotive to run round train',
                              'S ' =>  'Stops for railway personnel only',
                              'T ' =>  'Stops to take up and set down passengers',
                              '-T' =>  'Stops to attach and detach vehicles',
                              'TB' =>  'Train begins (Origin)',
                              'TF' =>  'Train finishes (Destination)',
# 'TS' =>  ' Detail Consist for TOPS Direct requested by EWS',
                              'TW' =>  'Stops (or at pass) for tablet, staff or token.',
                              'U ' =>  'Stops to take up passengers',
                              '-U' =>  'Stops to attach vehicles',
                              'W ' =>  'Stops for watering of coaches',
                              'X ' =>  'Passes another train at crossing point on single line',
                             };

        # For putting in the db, don't translate these now.
        #@activities = map {$activity_names->{$_} || die "Don't know name for activitiy '$_'"} @activities;
        @activities = map {+{activity => $_}} @activities;
        $value = \@activities;
      }

      when ('timing_load') {
        $value = sprintf("%-4s%-3s", $data->{power_type}||'    ', $value);

        # my $power_type = $data->{power_type};
        # my $timing_loads = {
        #                     'Diesel Mechanical Multiple Unit-A   '=>'Class 14x series 2-axle',
        #                     'Diesel Mechanical Multiple Unit-E   '=>'Class 158',
        #                     'Diesel Mechanical Multiple Unit-N   '=>'Class 165/0',
        #                     'Diesel Mechanical Multiple Unit-S   '=>'Class 150, 153, 155 or 156',
        #                     'Diesel Mechanical Multiple Unit-T   '=>'Class 165/1 or 166',
                            
        #                    };
        # if ($value =~ m/^(\d+) *$/) {
        #   # Used with D, E, or ED.
        #   # expected load, in tonnes.
        #   $value = $1;
        # } elsif ($value eq '    ') {
        #   $value = undef;
        # } else {
        #   if (exists $timing_loads->{"$power_type-$value"}) {
        #     # not for db version!
        #     #$value = $timing_loads->{"$power_type-$value"}
        #   } else {
        #     die "Unknown timing load '$power_type-$value'";
        #   }
        # }
      }

      when ('tiploc') {
        state $tiplocs = {
                          'AVNCLFF' => 'Avoncliff Rail Station',
                          'BATHSPA' => 'Bath Spa',
                          'BRDFDJN' => 'Bradford Junction',
                          'BRDFDOA' => 'Bradford-on-Avon Rail Station',
                          'BTHMPTJ' => 'Bathampton Junction',
                          'FRESHFD' => 'Freshford Rail Station',
                          'TRWBRDG' => 'Trowbridge',
                          'OLDFLDP' => 'Oldfield Park',
                          'WSTBRYW' => 'Westbury (Wilts) Rail Station',
                          'KEYNSHM' => 'Keynsham Rail Station',
                          'NSMRSTJ' => 'North Somerset Junction',
                         };

        if (exists $tiplocs->{$value}) {
          #$value = $tiplocs->{$value};
        } else {
          #warn "Unknown tiploc code $value";
        }
      }

      when ('split') {
        my ($field_len, $column_name) = @$extra;
        my $new_value = [];
        while ($value !~ m/^ *$/) {
          push @$new_value, {$column_name => substr($value, 0, $field_len, '')};
        }
        $value = $new_value;
      }

      default {
        die "Unknown filter $filter for type $type, key $name, value $value";
      }
    }

    if (defined $value) {
      $value =~ s/ +$//;
      if ($value eq '') {
        $value = undef;
      }
    }
    
    $data->{$name} = $value;
  }

  delete $data->{spare};

  given ($type) {
    when ('BS') {
      if (keys %$schedule) {
        #Dump $schedule;

        # Certian fields which are useless (generally, marked as unused in the pdf) we do
        # not carry over in the database.
        delete $schedule->{$_} for qw<data_source traction_class rsid>;

        # if transaction_type isn't N, we shouldn't be doing a ->create... but we
        # don't handle that yet.
        die unless $schedule->{transaction_type} eq 'N';
        delete $schedule->{transaction_type};

        $schema->resultset('Schedule')->create($schedule);
      }
      
      # Done dealing with the old one, time to overwrite it.
      $schedule = $data;
    }
    when ('BX') {
      for my $k (keys %$data) {
        $schedule->{$k} = $data->{$k};
      }
    }
    when (['LO', 'LI', 'LT']) {
      push @{$schedule->{locations}}, $data;
    }
    when ('CR') {
      # For the time being, we ignore change-en-route.
    }
    when (['TI', 'AA']) {
      # ignore this for now.
    }
    default {
      Dump $data;

      # warn "don't know how to stuff record type $type";
    }
  }
}
