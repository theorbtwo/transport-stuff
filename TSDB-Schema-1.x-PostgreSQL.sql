-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Tue Jul 12 01:18:13 2011
-- 
--
-- Table: schedules
--
DROP TABLE "schedules" CASCADE;
CREATE TABLE "schedules" (
  "train_uid" character(6) NOT NULL,
  "schedule_order" integer NOT NULL,
  "runs_from" timestamp NOT NULL,
  "runs_to" timestamp NOT NULL,
  "days_run" character(7) NOT NULL,
  "bh_running" character(1),
  "status" character(1) NOT NULL,
  "category" character(2) NOT NULL,
  "train_identity" character(4) NOT NULL,
  "headcode" character(4),
  "course_indicator" character(1) NOT NULL,
  "service_code" character(8) NOT NULL,
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
  "uic_code" character(5),
  "atoc_code" character(2) NOT NULL,
  "ats_code" character(1) NOT NULL,
  PRIMARY KEY ("train_uid", "schedule_order")
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
-- Foreign Key Definitions
--

ALTER TABLE "catering_codes" ADD FOREIGN KEY ("train_uid", "schedule_order")
  REFERENCES "schedules" ("train_uid", "schedule_order") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "schedule_locations" ADD FOREIGN KEY ("train_uid", "schedule_order")
  REFERENCES "schedules" ("train_uid", "schedule_order") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "location_activities" ADD FOREIGN KEY ("train_uid", "schedule_order", "location_order")
  REFERENCES "schedule_locations" ("train_uid", "schedule_order", "location_order") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

