-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Wed Jul 13 13:32:25 2011
-- 

BEGIN TRANSACTION;

--
-- Table: schedules
--
DROP TABLE schedules;

CREATE TABLE schedules (
  train_uid char(6) NOT NULL,
  schedule_order integer NOT NULL,
  runs_from timestamp NOT NULL,
  runs_to timestamp NOT NULL,
  days_run char(7) NOT NULL,
  bh_running char(1),
  status char(1) NOT NULL,
  category char(2) NOT NULL,
  train_identity char(4) NOT NULL,
  headcode char(4),
  course_indicator char(1) NOT NULL,
  service_code char(8) NOT NULL,
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
  uic_code char(5),
  atoc_code char(2) NOT NULL,
  ats_code char(1) NOT NULL,
  PRIMARY KEY (train_uid, schedule_order)
);

--
-- Table: stations
--
DROP TABLE stations;

CREATE TABLE stations (
  tiploc char(7) NOT NULL,
  crs char(3) NOT NULL,
  name varchar(64) NOT NULL,
  lat float,
  lon float,
  PRIMARY KEY (tiploc)
);

CREATE UNIQUE INDEX stations_crs ON stations (crs);

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
-- Table: schedule_locations
--
DROP TABLE schedule_locations;

CREATE TABLE schedule_locations (
  train_uid char(6) NOT NULL,
  schedule_order integer NOT NULL,
  location_order integer NOT NULL,
  tiploc char(7) NOT NULL,
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
  FOREIGN KEY(tiploc) REFERENCES stations(tiploc)
);

CREATE INDEX schedule_locations_idx_train_uid_schedule_order ON schedule_locations (train_uid, schedule_order);

CREATE INDEX schedule_locations_idx_tiploc ON schedule_locations (tiploc);

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

COMMIT;
