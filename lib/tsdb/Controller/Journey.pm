package tsdb::Controller::Journey;
use Moose;
use namespace::autoclean;
use Time::ParseDate;
use DateTime;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

tsdb::Controller::Journey - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched tsdb::Controller::Journey in Journey.');
}

sub base :PathPart('journey') :Chained('/') :CaptureArgs(0) {
}

# /journey/create
sub create :PathPart('create') :Chained('base') :CaptureArgs(0) {
}

# /journey/create/find_train - display/find train from A to B
sub find_train :PathPart('find_train') :Chained('create') :Args(0) {
  my ($self, $c) = @_;

  # submitted date/time/station
  if($c->req->param) {
    # FIXME: Error handling.
    my $date = DateTime->from_epoch(epoch => scalar parsedate($c->req->param('date'),
                                                              ZONE => 'Europe/London',
                                                              UK => 1,
                                                             ),
                                   );
    $c->stash('trains' => scalar $c->model('DB::ScheduleLocation')
              ->find_station_day(date => $date,
                                 tiploc => $c->req->param('tiploc'),
                                )
              ->taking_on_passengers
              ->search({}, { order_by => ['departure'] })
             );
    $c->stash('template', 'journey/choose_train.tt');
  }
  # display form
}


=head1 AUTHOR

James Mastros,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
