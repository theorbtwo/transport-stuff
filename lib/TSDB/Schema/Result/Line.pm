package TSDB::Schema::Result::Line;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('lines');
__PACKAGE__->add_columns(
    elr => { data_type => 'varchar', size => 4 },
    name => { data_type => 'varchar', size => 64 },
    );

__PACKAGE__->set_primary_key('elr');

__PACKAGE__->has_many('station_lines', 'TSDB::Schema::Result::StationLine', 'line_elr');

'cross country';
