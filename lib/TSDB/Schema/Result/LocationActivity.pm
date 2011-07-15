package TSDB::Schema::Result::LocationActivity;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('location_activities');
__PACKAGE__->add_columns(
                         train_uid => { data_type => 'char', size => 6 },
                         schedule_order => { data_type => 'integer' },
                         location_order => { data_type => 'integer' },
                         activity => { data_type => 'char', size => 2 },
                        );

__PACKAGE__->set_primary_key(qw/train_uid schedule_order location_order activity/);
__PACKAGE__->belongs_to('schedule_location', 'TSDB::Schema::Result::ScheduleLocation', { 'foreign.train_uid' => 'self.train_uid',
                                                                                'foreign.schedule_order' => 'self.schedule_order',
                                                                                'foreign.location_order' => 'self.location_order'});

'all done';
