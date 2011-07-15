package TSDB::Schema::Result::Station;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('stations');
__PACKAGE__->add_columns(
                         tiploc      => { data_type => 'char', size => 7 },
                         crs         => { data_type => 'char', size => 3 },
                         name        => { data_type => 'varchar', size => 64 },
                         lat         => { data_type => 'float', is_nullable => 1 },
                         lon         => { data_type => 'float', is_nullable => 1 },
                         );

__PACKAGE__->set_primary_key('tiploc');
__PACKAGE__->add_unique_constraint(['crs']);

__PACKAGE__->has_many('schedule_stops', 'TSDB::Schema::Result::ScheduleLocation', { 'foreign.tiploc_code' => 'self.tiploc' } );

'the buck stops here';
