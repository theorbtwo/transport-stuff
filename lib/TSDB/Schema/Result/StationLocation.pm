package TSDB::Schema::Result::StationLocation;

use strict;
use warnings;

use base 'DBIx::Class::Core';

## There is an entry in here for every station that we have location data for

__PACKAGE__->table('station_locations');
__PACKAGE__->add_columns(
                         tiploc      => { data_type => 'char', size => 7 },
                         name        => { data_type => 'varchar', size => 64 },
                         operator    => { data_type => 'varchar', size => 64, is_nullable => 1 },
                         lat         => { data_type => 'float', is_nullable => 1 },
                         lon         => { data_type => 'float', is_nullable => 1 },
                         gridref     => { data_type => 'char', size => 8, is_nullable => 1 },
                        );

__PACKAGE__->set_primary_key('tiploc');
__PACKAGE__->has_one('station', 'TSDB::Schema::Result::Station', { 'foreign.tiploc' => 'self.tiploc' } );

'the buck stops here';
