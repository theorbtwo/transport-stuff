package TSDB::Schema::Result::CateringCodes;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('catering_codes');
__PACKAGE__->add_columns(
                         train_uid => {
                                       data_type => 'char',
                                       size => 6,
                                      },
                         schedule_order => {
                                            data_type => 'integer',
                                            },
                         catering_code => {
                                           data_type => 'char',
                                           size => 1,
                                          },
                         );
__PACKAGE__->set_primary_key(qw/train_uid schedule_order catering_code/);
__PACKAGE__->belongs_to('schedule', 'TSDB::Schema::Result::Schedule',  { 'foreign.train_uid' => 'self.train_uid', 'foreign.schedule_order' => 'self.schedule_order'});

'done';
