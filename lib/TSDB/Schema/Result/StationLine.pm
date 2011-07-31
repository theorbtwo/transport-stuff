package TSDB::Schema::Result::StationLine;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('station_lines');
__PACKAGE__->add_columns(
    line_elr => { data_type => 'varchar', size => 4 },
    station_tiploc => { data_type => 'char', size => 7 },
    );

__PACKAGE__->set_primary_key('line_elr', 'station_tiploc');

__PACKAGE__->belongs_to('line', 'TSDB::Schema::Result::Line', 'line_elr');
__PACKAGE__->belongs_to('station', 'TSDB::Schema::Result::Station', 'station_tiploc');

'cross country';
