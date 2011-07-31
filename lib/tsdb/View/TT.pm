package tsdb::View::TT;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
                    TEMPLATE_EXTENSION => '.tt',
                    # STRICT => 1,
                    render_die => 1,
);

=head1 NAME

tsdb::View::TT - TT View for tsdb

=head1 DESCRIPTION

TT View for tsdb.

=head1 SEE ALSO

L<tsdb>

=head1 AUTHOR

James Mastros,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
