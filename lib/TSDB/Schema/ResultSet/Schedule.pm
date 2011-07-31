package TSDB::Schema::ResultSet::Schedule;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

# Return train + location data on/around this date.
sub find_train {
  my ($self, %args) = @_;
  my ($date, $station, $time) = @args{qw/date station time/};
  
  my $dow = 1 << ($date->dow-1);
}

'ever onwards';
