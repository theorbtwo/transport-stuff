use strict;
use warnings;
use Test::More;


use Catalyst::Test 'tsdb';
use tsdb::Controller::Journey;

ok( request('/journey')->is_success, 'Request should succeed' );
done_testing();
