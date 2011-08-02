package TSDB::Schema::Result::Station;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('stations');
__PACKAGE__->add_columns(
                         tiploc      => { data_type => 'char', size => 7 },
                         # Aachen, for example, appears to have no crs.
                         crs         => { data_type => 'char', size => 3, is_nullable => 1 },
                         nlc         => { data_type => 'char', size => 6 },
                         tps_description => { data_type => 'char', size => 26, is_nullable => 1 },
                         stanox      => { data_type => 'char', size => 5 },
                         capri_description => { data_type => 'char', size => 16, is_nullable => 1 },
                        );

__PACKAGE__->set_primary_key('tiploc');
__PACKAGE__->add_unique_constraint(['crs']);

__PACKAGE__->has_many('schedule_stops', 'TSDB::Schema::Result::ScheduleLocation', { 'foreign.tiploc_code' => 'self.tiploc' } );
__PACKAGE__->has_many('station_lines', 'TSDB::Schema::Result::StationLine', { 'foreign.station_tiploc' => 'self.tiploc' } );
__PACKAGE__->might_have('station_location', 'TSDB::Schema::Result::StationLocation', { 'foreign.tiploc' => 'self.tiploc' }, { proxy => [qw/name operator lat lon gridref/] } );

'the buck stops here';
