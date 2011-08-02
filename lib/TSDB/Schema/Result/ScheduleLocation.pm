package TSDB::Schema::Result::ScheduleLocation;
use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/Ordered/);

__PACKAGE__->table('schedule_locations');
__PACKAGE__->add_columns(
                         train_uid        => {data_type => 'char', size => '6'},
                         schedule_order   => {data_type => 'integer'},
                         location_order   => {data_type => 'integer'},
                         tiploc_code      => {data_type => 'char', size => '7'},
                         tiploc_instance  => {data_type => 'char', size => '1', is_nullable => 1},
                         arrival          => {data_type => 'timestamp', is_nullable => 1},
                         public_arrival   => {data_type => 'timestamp', is_nullable => 1},
                         departure        => {data_type => 'timestamp', is_nullable => 1},
                         public_departure => {data_type => 'timestamp', is_nullable => 1},
                         pass             => {data_type => 'timestamp', is_nullable => 1},
                         platform         => {data_type => 'char', size => '3', is_nullable => 1},
                         arrival_line     => {data_type => 'char', size => '3', is_nullable => 1},
                         departure_line   => {data_type => 'char', size => '3', is_nullable => 1},
                         # These are undef, not zero, on the final location (LT).
                         engineering_allowance => {data_type => 'float', is_nullable => 1},
                         pathing_allowance     => {data_type => 'float', is_nullable => 1},
                         # (activity is a has-many)
                         performance_allowance => {data_type => 'float', is_nullable => 1},
                        );

__PACKAGE__->set_primary_key(qw/train_uid schedule_order location_order/);
__PACKAGE__->position_column('location_order');
__PACKAGE__->grouping_column(qw/train_uid schedule_order/);

__PACKAGE__->belongs_to('schedule', 'TSDB::Schema::Result::Schedule', { 'foreign.train_uid' => 'self.train_uid', 'foreign.schedule_order' => 'self.schedule_order'});
__PACKAGE__->has_many('activities', 'TSDB::Schema::Result::LocationActivity', { 'foreign.train_uid' => 'self.train_uid',
                                                                                'foreign.schedule_order' => 'self.schedule_order',
                                                                                'foreign.location_order' => 'self.location_order'});
__PACKAGE__->belongs_to('station', 'TSDB::Schema::Result::Station', { 'foreign.tiploc' => 'self.tiploc_code' } );

# Fixme: not really a method, and not really anything to do with schedulelocation!
sub sec_to_hms {
  my ($self, $linear_s) = @_;
  my ($h, $m, $s) = (int($linear_s / (60*60)),
                     int($linear_s / 60) % 60,
                     $linear_s % 60
                    );
  sprintf "% 2d:%02d:%02d", $h, $m, $s;
}

# If you get on this train at this point, where can you get off?
sub forward_destinations {
  $_[0]->next_siblings->setting_down_passengers;
}

'where-ever you are, you are here';

