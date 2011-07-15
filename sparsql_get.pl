#!/usr/bin/perl
use LWP::UserAgent;
use XML::Simple;
use Data::Dump::Streamer;
use JSON::Any;
use Geo::Coordinates::OSGB 'grid_to_ll';
use TSDB::Schema;
use Term::ProgressBar;

my $schema = TSDB::Schema->connect('dbi:SQLite:/tmp/tsdb.sqlite') or die;

my $ua = LWP::UserAgent->new;
$ua->env_proxy(1);
my $response = $ua->post('http://services.data.gov.uk/transport/sparql',
          {
           query => <<'END_SPARSQL'
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX naptan: <http://transport.data.gov.uk/def/naptan/>
SELECT DISTINCT ?item
WHERE {
?item rdf:type naptan:Station .

}
 
OFFSET 0
END_SPARSQL
          });

if (!$response->is_success) {
  print $response->content;
  die;
}

my $list_xml = XMLin($response->content);

my $j = JSON::Any->new;

my $progress = Term::ProgressBar->new({count => 0+@{$list_xml->{results}{result}},
                                       ETA => 'linear',
                                      });
my $next_update = 0;

my $n=0;

for my $result (@{$list_xml->{results}{result}}) {
  my $uri = $result->{binding}{uri};
  $uri .= ".json";

  $response = $ua->get($uri);
  if (!$response->is_success) {
    print $response->content;
    die $response->status_line . " when trying to GET $uri";
  }

  my $json = $j->from_json($response->content);
  my $pt = $json->{result}{primaryTopic};

  my ($lat, $lon) = grid_to_ll($pt->{easting}, $pt->{northing});

  my $name = $schema->storage->dbh->quote($pt->{name});
  print "INSERT INTO stations (tiploc, crs, name, lat, lon) VALUES($pt->{tiploc}, $pt->{crs}, $name, $lat, $lon);\n";

  # $schema->resultset('Station')->create({
  #                                        crs => $pt->{crs},
  #                                        tiploc => $pt->{tiploc},
  #                                        name => $pt->{name},
  #                                        lat => $lat,
  #                                        lon => $lon
  #                                       }) or die;

  $n++;

  if ($n >= $next_update) {
    $next_update = $progress->update($n);
  }
}

$progress->update($n);

