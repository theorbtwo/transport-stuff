package TSDB::Schema::ResultSet::ScheduleLocation;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

# Given a station, and a date, finds a resultset of ScheduleLocations
# that touch that station on that date.  (You will probably want to
# build a function on top of this that narrows the time range, or what
# sort of touching is needed -- as written, arriving, departing, or
# passing through is allowed.)
sub find_station_day {
  my ($self, %args) = @_;
  my ($date, $tiploc) = @args{qw/date tiploc/};
  
  # FIXME: This code doesn't check that we aren't in an overridden
  # schedule.  That is, we shouldn't return schedulelocations where
  # there is another applicable scedule with the same train_uid, and a
  # higher schedule_order, which also is on the specified date.

  my $dow = 1 << ($date->dow-1);
  # Whew, but that's a mouthful, sugar?
  my $dtf = $self->result_source->schema->storage->datetime_parser;
  my $dtf_date = $dtf->format_datetime($date);
  my $rs = $self->search( { 
                           -and => [
                                    {
                                     tiploc_code => $tiploc,
                                     # Should these be >=, <=?
                                     'schedule.runs_to' => {'>', $dtf_date},
                                     'schedule.runs_from' => {'<', $dtf_date},
                                    },
                                    # FIXME: It really seems like there should be a better WTD this.
                                    \"(schedule.days_run & $dow) != 0"
                                   ],
                          },
                          {
                           order_by => [ 'me.train_uid', 'me.schedule_order' ],
                           prefetch => 'schedule',
                          });

  return $rs;
}

sub taking_on_passengers {
  my ($self) = @_;

  $self->search({
                 # Actually continues on from here -- not terminating, not just passing through.
                 departure => {'!=', undef},
                 'activities.activity' => ['T ', # "Stops to take up and set down passengers
                                           'TB', # "Train begins" -- fixme, do we really need this?
                                           'U ', # "Stops to take up passengers"
                                          ],
                },
                {
                 join => 'activities',
                });
}

sub setting_down_passengers {
  my ($self) = @_;

  $self->search({
                 # You can get off the train here -- not just passing through, can get out.
                 arrival => {'!=', undef},
                 'activities.activity' => ['T ', # "Stops to take up and set down passengers
                                           'TF', # "Train finishes" -- fixme, do we really need this?
                                           'D ', # "Stops to set down passengers
                                          ],
                },
                {
                 join => 'activities',
                });
}


'To infinity and beyond!';
