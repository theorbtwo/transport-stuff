package TSDB::Schema::Result::Step;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/Ordered/);
__PACKAGE__->table('steps');
__PACKAGE__->add_columns(
                         journey_id => { data_type => 'integer' },
                         step_order => { data_type => 'integer' },
                         departure_date => { data_type => 'date' },
                         train_uid => { data_type => 'char', size => 6 },
                         schedule_order => { data_type => 'integer' },
                         departure_tiploc => { data_type => 'char', size => 7},
                         arrival_tiploc => { data_type => 'char', size => 7},
                         );
__PACKAGE__->set_primary_key('journey_id', 'step_order');
__PACKAGE__->grouping_column(qw/journey_id/);
__PACKAGE__->position_column('step_order');

__PACKAGE__->belongs_to('journey', 'TSDB::Schema::Result::Journey', 'journey_id');
__PACKAGE__->belongs_to('departure_station', 'TSDB::Schema::Result::Station', 'departure_tiploc');
__PACKAGE__->belongs_to('arrival_station', 'TSDB::Schema::Result::Station', 'arrival_tiploc');
__PACKAGE__->belongs_to('schedule', 'TSDB::Schema::Result::Schedule', { 'foreign.train_uid' => 'self.train_uid', 'foreign.schedule_order', => 'self.schedule_order' });
__PACKAGE__->belongs_to('departure_schedule_location', 'TSDB::Schema::Result::ScheduleLocation', { 'foreign.train_uid' => 'self.train_uid', 
                                                                                                   'foreign.tiploc_code' => 'self.departure_tiploc', 
                                                                                                   'foreign.schedule_order', => 'self.schedule_order' });
__PACKAGE__->belongs_to('arrival_schedule_location', 'TSDB::Schema::Result::ScheduleLocation', { 'foreign.train_uid' => 'self.train_uid', 
                                                                                                 'foreign.tiploc_code' => 'self.arrival_tiploc', 
                                                                                                 'foreign.schedule_order', => 'self.schedule_order' });


'I would walk 500 miles. And I would walk 500 more. Just to be that man who walked a thousand miles to fall down at your door';
