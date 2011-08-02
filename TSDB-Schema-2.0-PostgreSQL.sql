-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Mon Aug  1 11:45:07 2011
-- 
--
-- Table: lines
--
DROP TABLE "lines" CASCADE;
CREATE TABLE "lines" (
  "elr" character varying(4) NOT NULL,
  "name" character varying(64) NOT NULL,
  PRIMARY KEY ("elr")
);

--
-- Table: schedules
--
DROP TABLE "schedules" CASCADE;
CREATE TABLE "schedules" (
  "train_uid" character(6) NOT NULL,
  "schedule_order" integer NOT NULL,
  "runs_from" timestamp NOT NULL,
  "runs_to" timestamp,
  "days_run" character(7) NOT NULL,
  "bh_running" character(1),
  "status" character(1),
  "category" character(2),
  "train_identity" character(4),
  "headcode" character(4),
  "course_indicator" character(1) NOT NULL,
  "service_code" character(8),
  "portion_id" character(1),
  "power_type" character(3),
  "timing_load" character(7),
  "speed" integer,
  "operating_characteristics" character(6),
  "train_class" character(1),
  "sleepers" character(1),
  "reservations" character(1),
  "connection_indicator" character(1),
  "service_branding" character(4),
  "stp_indicator" character(1) NOT NULL,
  "uic_code" character(5),
  "atoc_code" character(2),
  "ats_code" character(1),
  PRIMARY KEY ("train_uid", "schedule_order")
);

--
-- Table: station_locations
--
DROP TABLE "station_locations" CASCADE;
CREATE TABLE "station_locations" (
  "tiploc" character(7) NOT NULL,
  "name" character varying(64) NOT NULL,
  "operator" character varying(64),
  "lat" numeric,
  "lon" numeric,
  "gridref" character(8),
  PRIMARY KEY ("tiploc")
);

--
-- Table: stations
--
DROP TABLE "stations" CASCADE;
CREATE TABLE "stations" (
  "tiploc" character(7) NOT NULL,
  "crs" character(3),
  "nlc" character(6) NOT NULL,
  "tps_description" character(26),
  "stanox" character(5) NOT NULL,
  "capri_description" character(16),
  PRIMARY KEY ("tiploc"),
  CONSTRAINT "stations_crs" UNIQUE ("crs")
);

--
-- Table: users
--
DROP TABLE "users" CASCADE;
CREATE TABLE "users" (
  "id" serial NOT NULL,
  "username" character varying(50) NOT NULL,
  "email" character varying(255) NOT NULL,
  "password" character varying(255) NOT NULL,
  PRIMARY KEY ("id")
);

--
-- Table: catering_codes
--
DROP TABLE "catering_codes" CASCADE;
CREATE TABLE "catering_codes" (
  "train_uid" character(6) NOT NULL,
  "schedule_order" integer NOT NULL,
  "catering_code" character(1) NOT NULL,
  PRIMARY KEY ("train_uid", "schedule_order", "catering_code")
);
CREATE INDEX "catering_codes_idx_train_uid_schedule_order" on "catering_codes" ("train_uid", "schedule_order");

--
-- Table: journeys
--
DROP TABLE "journeys" CASCADE;
CREATE TABLE "journeys" (
  "id" serial NOT NULL,
  "name" character varying(255) NOT NULL,
  "user_id" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "journeys_idx_user_id" on "journeys" ("user_id");

--
-- Table: schedule_locations
--
DROP TABLE "schedule_locations" CASCADE;
CREATE TABLE "schedule_locations" (
  "train_uid" character(6) NOT NULL,
  "schedule_order" integer NOT NULL,
  "location_order" integer NOT NULL,
  "tiploc_code" character(7) NOT NULL,
  "tiploc_instance" character(1),
  "arrival" timestamp,
  "public_arrival" timestamp,
  "departure" timestamp,
  "public_departure" timestamp,
  "pass" timestamp,
  "platform" character(3),
  "arrival_line" character(3),
  "departure_line" character(3),
  "engineering_allowance" numeric,
  "pathing_allowance" numeric,
  "performance_allowance" numeric,
  PRIMARY KEY ("train_uid", "schedule_order", "location_order")
);
CREATE INDEX "schedule_locations_idx_train_uid_schedule_order" on "schedule_locations" ("train_uid", "schedule_order");
CREATE INDEX "schedule_locations_idx_tiploc_code" on "schedule_locations" ("tiploc_code");

--
-- Table: station_lines
--
DROP TABLE "station_lines" CASCADE;
CREATE TABLE "station_lines" (
  "line_elr" character varying(4) NOT NULL,
  "station_tiploc" character(7) NOT NULL,
  PRIMARY KEY ("line_elr", "station_tiploc")
);
CREATE INDEX "station_lines_idx_line_elr" on "station_lines" ("line_elr");
CREATE INDEX "station_lines_idx_station_tiploc" on "station_lines" ("station_tiploc");

--
-- Table: location_activities
--
DROP TABLE "location_activities" CASCADE;
CREATE TABLE "location_activities" (
  "train_uid" character(6) NOT NULL,
  "schedule_order" integer NOT NULL,
  "location_order" integer NOT NULL,
  "activity" character(2) NOT NULL,
  PRIMARY KEY ("train_uid", "schedule_order", "location_order", "activity")
);
CREATE INDEX "location_activities_idx_train_uid_schedule_order_location_order" on "location_activities" ("train_uid", "schedule_order", "location_order");

--
-- Table: steps
--
DROP TABLE "steps" CASCADE;
CREATE TABLE "steps" (
  "journey_id" integer NOT NULL,
  "step_order" integer NOT NULL,
  "departure_date" date NOT NULL,
  "train_uid" character(6) NOT NULL,
  "schedule_order" integer NOT NULL,
  "departure_tiploc" character(7) NOT NULL,
  "arrival_tiploc" character(7) NOT NULL,
  PRIMARY KEY ("journey_id", "step_order")
);
CREATE INDEX "steps_idx_train_uid_schedule_order_arrival_tiploc" on "steps" ("train_uid", "schedule_order", "arrival_tiploc");
CREATE INDEX "steps_idx_arrival_tiploc" on "steps" ("arrival_tiploc");
CREATE INDEX "steps_idx_train_uid_schedule_order_departure_tiploc" on "steps" ("train_uid", "schedule_order", "departure_tiploc");
CREATE INDEX "steps_idx_departure_tiploc" on "steps" ("departure_tiploc");
CREATE INDEX "steps_idx_journey_id" on "steps" ("journey_id");
CREATE INDEX "steps_idx_train_uid_schedule_order" on "steps" ("train_uid", "schedule_order");

--
-- Foreign Key Definitions
--

ALTER TABLE "catering_codes" ADD FOREIGN KEY ("train_uid", "schedule_order")
  REFERENCES "schedules" ("train_uid", "schedule_order") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "journeys" ADD FOREIGN KEY ("user_id")
  REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "schedule_locations" ADD FOREIGN KEY ("train_uid", "schedule_order")
  REFERENCES "schedules" ("train_uid", "schedule_order") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "schedule_locations" ADD FOREIGN KEY ("tiploc_code")
  REFERENCES "stations" ("tiploc") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "station_lines" ADD FOREIGN KEY ("line_elr")
  REFERENCES "lines" ("elr") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "station_lines" ADD FOREIGN KEY ("station_tiploc")
  REFERENCES "stations" ("tiploc") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "location_activities" ADD FOREIGN KEY ("train_uid", "schedule_order", "location_order")
  REFERENCES "schedule_locations" ("train_uid", "schedule_order", "location_order") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "steps" ADD FOREIGN KEY ("train_uid", "schedule_order", "arrival_tiploc")
  REFERENCES "schedule_locations" ("train_uid", "schedule_order", "tiploc_code") DEFERRABLE;

ALTER TABLE "steps" ADD FOREIGN KEY ("arrival_tiploc")
  REFERENCES "stations" ("tiploc") DEFERRABLE;

ALTER TABLE "steps" ADD FOREIGN KEY ("train_uid", "schedule_order", "departure_tiploc")
  REFERENCES "schedule_locations" ("train_uid", "schedule_order", "tiploc_code") DEFERRABLE;

ALTER TABLE "steps" ADD FOREIGN KEY ("departure_tiploc")
  REFERENCES "stations" ("tiploc") DEFERRABLE;

ALTER TABLE "steps" ADD FOREIGN KEY ("journey_id")
  REFERENCES "journeys" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "steps" ADD FOREIGN KEY ("train_uid", "schedule_order")
  REFERENCES "schedules" ("train_uid", "schedule_order") DEFERRABLE;

