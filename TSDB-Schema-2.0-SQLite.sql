-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Mon Aug  1 11:45:07 2011
-- 

BEGIN TRANSACTION;

--
-- Table: lines
--
DROP TABLE lines;

CREATE TABLE lines (
  elr varchar(4) NOT NULL,
  name varchar(64) NOT NULL,
  PRIMARY KEY (elr)
);

--
-- Table: schedules
--
DROP TABLE schedules;

CREATE TABLE schedules (
  train_uid char(6) NOT NULL,
  schedule_order integer NOT NULL,
  runs_from timestamp NOT NULL,
  runs_to timestamp,
  days_run char(7) NOT NULL,
  bh_running char(1),
  status char(1),
  category char(2),
  train_identity char(4),
  headcode char(4),
  course_indicator char(1) NOT NULL,
  service_code char(8),
  portion_id char(1),
  power_type char(3),
  timing_load char(7),
  speed integer,
  operating_characteristics char(6),
  train_class char(1),
  sleepers char(1),
  reservations char(1),
  connection_indicator char(1),
  service_branding char(4),
  stp_indicator char(1) NOT NULL,
  uic_code char(5),
  atoc_code char(2),
  ats_code char(1),
  PRIMARY KEY (train_uid, schedule_order)
);

--
-- Table: station_locations
--
DROP TABLE station_locations;

CREATE TABLE station_locations (
  tiploc char(7) NOT NULL,
  name varchar(64) NOT NULL,
  operator varchar(64),
  lat float,
  lon float,
  gridref char(8),
  PRIMARY KEY (tiploc)
);

--
-- Table: stations
--
DROP TABLE stations;

CREATE TABLE stations (
  tiploc char(7) NOT NULL,
  crs char(3),
  nlc char(6) NOT NULL,
  tps_description char(26),
  stanox char(5) NOT NULL,
  capri_description char(16),
  PRIMARY KEY (tiploc)
);

CREATE UNIQUE INDEX stations_crs ON stations (crs);

--
-- Table: users
--
DROP TABLE users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY NOT NULL,
  username varchar(50) NOT NULL,
  email varchar(255) NOT NULL,
  password varchar(255) NOT NULL
);

--
-- Table: catering_codes
--
DROP TABLE catering_codes;

CREATE TABLE catering_codes (
  train_uid char(6) NOT NULL,
  schedule_order integer NOT NULL,
  catering_code char(1) NOT NULL,
  PRIMARY KEY (train_uid, schedule_order, catering_code),
  FOREIGN KEY(train_uid) REFERENCES schedules(train_uid)
);

CREATE INDEX catering_codes_idx_train_uid_schedule_order ON catering_codes (train_uid, schedule_order);

--
-- Table: journeys
--
DROP TABLE journeys;

CREATE TABLE journeys (
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(255) NOT NULL,
  user_id integer,
  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE INDEX journeys_idx_user_id ON journeys (user_id);

--
-- Table: schedule_locations
--
DROP TABLE schedule_locations;

CREATE TABLE schedule_locations (
  train_uid char(6) NOT NULL,
  schedule_order integer NOT NULL,
  location_order integer NOT NULL,
  tiploc_code char(7) NOT NULL,
  tiploc_instance char(1),
  arrival timestamp,
  public_arrival timestamp,
  departure timestamp,
  public_departure timestamp,
  pass timestamp,
  platform char(3),
  arrival_line char(3),
  departure_line char(3),
  engineering_allowance float,
  pathing_allowance float,
  performance_allowance float,
  PRIMARY KEY (train_uid, schedule_order, location_order),
  FOREIGN KEY(train_uid) REFERENCES schedules(train_uid),
  FOREIGN KEY(tiploc_code) REFERENCES stations(tiploc)
);

CREATE INDEX schedule_locations_idx_train_uid_schedule_order ON schedule_locations (train_uid, schedule_order);

CREATE INDEX schedule_locations_idx_tiploc_code ON schedule_locations (tiploc_code);

--
-- Table: station_lines
--
DROP TABLE station_lines;

CREATE TABLE station_lines (
  line_elr varchar(4) NOT NULL,
  station_tiploc char(7) NOT NULL,
  PRIMARY KEY (line_elr, station_tiploc),
  FOREIGN KEY(line_elr) REFERENCES lines(elr),
  FOREIGN KEY(station_tiploc) REFERENCES stations(tiploc)
);

CREATE INDEX station_lines_idx_line_elr ON station_lines (line_elr);

CREATE INDEX station_lines_idx_station_tiploc ON station_lines (station_tiploc);

--
-- Table: location_activities
--
DROP TABLE location_activities;

CREATE TABLE location_activities (
  train_uid char(6) NOT NULL,
  schedule_order integer NOT NULL,
  location_order integer NOT NULL,
  activity char(2) NOT NULL,
  PRIMARY KEY (train_uid, schedule_order, location_order, activity),
  FOREIGN KEY(train_uid) REFERENCES schedule_locations(train_uid)
);

CREATE INDEX location_activities_idx_train_uid_schedule_order_location_order ON location_activities (train_uid, schedule_order, location_order);

--
-- Table: steps
--
DROP TABLE steps;

CREATE TABLE steps (
  journey_id integer NOT NULL,
  step_order integer NOT NULL,
  departure_date date NOT NULL,
  train_uid char(6) NOT NULL,
  schedule_order integer NOT NULL,
  departure_tiploc char(7) NOT NULL,
  arrival_tiploc char(7) NOT NULL,
  PRIMARY KEY (journey_id, step_order),
  FOREIGN KEY(train_uid) REFERENCES schedule_locations(train_uid),
  FOREIGN KEY(arrival_tiploc) REFERENCES stations(tiploc),
  FOREIGN KEY(train_uid) REFERENCES schedule_locations(train_uid),
  FOREIGN KEY(departure_tiploc) REFERENCES stations(tiploc),
  FOREIGN KEY(journey_id) REFERENCES journeys(id),
  FOREIGN KEY(train_uid) REFERENCES schedules(train_uid)
);

CREATE INDEX steps_idx_train_uid_schedule_order_arrival_tiploc ON steps (train_uid, schedule_order, arrival_tiploc);

CREATE INDEX steps_idx_arrival_tiploc ON steps (arrival_tiploc);

CREATE INDEX steps_idx_train_uid_schedule_order_departure_tiploc ON steps (train_uid, schedule_order, departure_tiploc);

CREATE INDEX steps_idx_departure_tiploc ON steps (departure_tiploc);

CREATE INDEX steps_idx_journey_id ON steps (journey_id);

CREATE INDEX steps_idx_train_uid_schedule_order ON steps (train_uid, schedule_order);

COMMIT;
