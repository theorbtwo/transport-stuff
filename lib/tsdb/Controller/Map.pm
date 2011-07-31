package tsdb::Controller::Map;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

tsdb::Controller::Map - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched tsdb::Controller::Map in Map.');
}

sub current_trains :Local {
    my ($self, $c) = @_;
    my $bbox = $c->req->param('bbox');
    my ($west, $south, $east, $north) = split(/,/, $bbox);

    my $locations = $c->model('DB::Station')
      ->search(
               {
                lat => {-between => [$south, $north]},
                lon => {-between => [$west, $east]},
               },
              );

    my $in_stations = [];
    while my ($location = $locations->next) {
      push @$in_stations, $location->tiploc;
    }

    my $day = DateTime->now;
    my $dow = 1 << $day->dow-1;
    
    my $schedulelocations = $schema->resultset('ScheduleLocation')
      ->search(
               {
                -and => [
                         {
                          tiploc_code => {-in => $in_stations},
                          # Should these be >=, <=?
                          'schedule.runs_to' => {'>', $dtf->format_datetime($day)},
                          'schedule.runs_from' => {'<', $dtf->format_datetime($day)}
                         },
                         # FIXME: It really seems like there should be a better WTD this.
                         \"(schedule.days_run & $dow) != 0"
                        ],
               },
               {
                order_by => [ 'me.train_uid', 'me.schedule_order' ],
                prefetch => 'schedule',
               });

}

=head1 AUTHOR

Jess Robinson,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
