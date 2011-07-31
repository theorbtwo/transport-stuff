use strict;
use warnings;
use Test::More;


use Catalyst::Test 'tsdb';
use tsdb::Controller::Map;

ok( request('/map')->is_success, 'Request should succeed' );
done_testing();
