#!/usr/bin/perl
use warnings;
use strict;
use TSDB::Schema;
use DateTime;
use 5.10.0;
$|=1;

my $schema = TSDB::Schema->connect('dbi:SQLite:/home/theorb/tsdb.sqlite');

my $day = DateTime->new(year => 2011, month => 5, day => 2);
my $dow = 1 << $day->dow-1;

my $dtf = $schema->storage->datetime_parser;
my $rs = $schema->
  resultset('ScheduleLocation')->search( { 
                                          -and => [
                                                   {
                                                    tiploc_code => 'SDON',
                                                    # Should these be >=, <=?
                                                    'schedule.runs_to' => {'>', $dtf->format_datetime($day)},
                                                    'schedule.runs_from' => {'<', $dtf->format_datetime($day)}
                                                   },
                                                   # FIXME: It really seems like there should be a better WTD this.
                                                   \"(schedule.days_run & $dow) != 0"
                                                  ],
                                         },
                                         {
                                          order_by => [ 'me.train_uid', 'me.schedule_order' ],
                                          prefetch => 'schedule',
                                         });

while (my $sl = $rs->next) {
  my $s = $sl->schedule;

  printf "%s - %s\n", $s->runs_from, $s->runs_to;
  #next if $s->runs_to < $day;
  #next if $day < $s->runs_from;
  #next if (($s->days_run & $dow) == 0);

  print "Works\n";

  my @day_letters = qw<Mon Tue Wed Thu Fri Sat Sun>;
  my $this_day_letters = '';
  for (0..6) {
    $this_day_letters .= $day_letters[$_] if
      $s->days_run & (1<<$_);
  }

  my $arrives;
  if (defined $sl->arrival) {
    $arrives = $day + DateTime::Duration->new(seconds => $sl->arrival);
  } else {
    $arrives = 'starts here / just passing through';
  }

  printf "%s+%d: %s arrives %s\n", $s->train_uid, $s->schedule_order, $this_day_letters, $arrives;

  my %cols = $sl->get_columns;
  # for my $k (sort keys %cols) {
  #   my $v = $cols{$k} // '(NULL)';
  #   print "$k: $v\n";
  # }
  print "\n";
}
