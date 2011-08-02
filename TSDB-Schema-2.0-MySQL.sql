-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Mon Aug  1 11:45:07 2011
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS `lines`;

--
-- Table: `lines`
--
CREATE TABLE `lines` (
  `elr` varchar(4) NOT NULL,
  `name` varchar(64) NOT NULL,
  PRIMARY KEY (`elr`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `schedules`;

--
-- Table: `schedules`
--
CREATE TABLE `schedules` (
  `train_uid` char(6) NOT NULL,
  `schedule_order` integer NOT NULL,
  `runs_from` timestamp NOT NULL,
  `runs_to` timestamp,
  `days_run` char(7) NOT NULL,
  `bh_running` char(1),
  `status` char(1),
  `category` char(2),
  `train_identity` char(4),
  `headcode` char(4),
  `course_indicator` char(1) NOT NULL,
  `service_code` char(8),
  `portion_id` char(1),
  `power_type` char(3),
  `timing_load` char(7),
  `speed` integer,
  `operating_characteristics` char(6),
  `train_class` char(1),
  `sleepers` char(1),
  `reservations` char(1),
  `connection_indicator` char(1),
  `service_branding` char(4),
  `stp_indicator` char(1) NOT NULL,
  `uic_code` char(5),
  `atoc_code` char(2),
  `ats_code` char(1),
  PRIMARY KEY (`train_uid`, `schedule_order`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `station_locations`;

--
-- Table: `station_locations`
--
CREATE TABLE `station_locations` (
  `tiploc` char(7) NOT NULL,
  `name` varchar(64) NOT NULL,
  `operator` varchar(64),
  `lat` float,
  `lon` float,
  `gridref` char(8),
  PRIMARY KEY (`tiploc`)
);

DROP TABLE IF EXISTS `stations`;

--
-- Table: `stations`
--
CREATE TABLE `stations` (
  `tiploc` char(7) NOT NULL,
  `crs` char(3),
  `nlc` char(6) NOT NULL,
  `tps_description` char(26),
  `stanox` char(5) NOT NULL,
  `capri_description` char(16),
  PRIMARY KEY (`tiploc`),
  UNIQUE `stations_crs` (`crs`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `users`;

--
-- Table: `users`
--
CREATE TABLE `users` (
  `id` integer NOT NULL auto_increment,
  `username` varchar(50) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `catering_codes`;

--
-- Table: `catering_codes`
--
CREATE TABLE `catering_codes` (
  `train_uid` char(6) NOT NULL,
  `schedule_order` integer NOT NULL,
  `catering_code` char(1) NOT NULL,
  INDEX `catering_codes_idx_train_uid_schedule_order` (`train_uid`, `schedule_order`),
  PRIMARY KEY (`train_uid`, `schedule_order`, `catering_code`),
  CONSTRAINT `catering_codes_fk_train_uid_schedule_order` FOREIGN KEY (`train_uid`, `schedule_order`) REFERENCES `schedules` (`train_uid`, `schedule_order`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `journeys`;

--
-- Table: `journeys`
--
CREATE TABLE `journeys` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `user_id` integer,
  INDEX `journeys_idx_user_id` (`user_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `journeys_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `schedule_locations`;

--
-- Table: `schedule_locations`
--
CREATE TABLE `schedule_locations` (
  `train_uid` char(6) NOT NULL,
  `schedule_order` integer NOT NULL,
  `location_order` integer NOT NULL,
  `tiploc_code` char(7) NOT NULL,
  `tiploc_instance` char(1),
  `arrival` timestamp,
  `public_arrival` timestamp,
  `departure` timestamp,
  `public_departure` timestamp,
  `pass` timestamp,
  `platform` char(3),
  `arrival_line` char(3),
  `departure_line` char(3),
  `engineering_allowance` float,
  `pathing_allowance` float,
  `performance_allowance` float,
  INDEX `schedule_locations_idx_train_uid_schedule_order` (`train_uid`, `schedule_order`),
  INDEX `schedule_locations_idx_tiploc_code` (`tiploc_code`),
  PRIMARY KEY (`train_uid`, `schedule_order`, `location_order`),
  CONSTRAINT `schedule_locations_fk_train_uid_schedule_order` FOREIGN KEY (`train_uid`, `schedule_order`) REFERENCES `schedules` (`train_uid`, `schedule_order`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `schedule_locations_fk_tiploc_code` FOREIGN KEY (`tiploc_code`) REFERENCES `stations` (`tiploc`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `station_lines`;

--
-- Table: `station_lines`
--
CREATE TABLE `station_lines` (
  `line_elr` varchar(4) NOT NULL,
  `station_tiploc` char(7) NOT NULL,
  INDEX `station_lines_idx_line_elr` (`line_elr`),
  INDEX `station_lines_idx_station_tiploc` (`station_tiploc`),
  PRIMARY KEY (`line_elr`, `station_tiploc`),
  CONSTRAINT `station_lines_fk_line_elr` FOREIGN KEY (`line_elr`) REFERENCES `lines` (`elr`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `station_lines_fk_station_tiploc` FOREIGN KEY (`station_tiploc`) REFERENCES `stations` (`tiploc`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `location_activities`;

--
-- Table: `location_activities`
--
CREATE TABLE `location_activities` (
  `train_uid` char(6) NOT NULL,
  `schedule_order` integer NOT NULL,
  `location_order` integer NOT NULL,
  `activity` char(2) NOT NULL,
  INDEX `location_activities_idx_train_uid_schedule_order_location_order` (`train_uid`, `schedule_order`, `location_order`),
  PRIMARY KEY (`train_uid`, `schedule_order`, `location_order`, `activity`),
  CONSTRAINT `location_activities_fk_train_uid_schedule_order_location_order` FOREIGN KEY (`train_uid`, `schedule_order`, `location_order`) REFERENCES `schedule_locations` (`train_uid`, `schedule_order`, `location_order`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `steps`;

--
-- Table: `steps`
--
CREATE TABLE `steps` (
  `journey_id` integer NOT NULL,
  `step_order` integer NOT NULL,
  `departure_date` date NOT NULL,
  `train_uid` char(6) NOT NULL,
  `schedule_order` integer NOT NULL,
  `departure_tiploc` char(7) NOT NULL,
  `arrival_tiploc` char(7) NOT NULL,
  INDEX `steps_idx_train_uid_schedule_order_arrival_tiploc` (`train_uid`, `schedule_order`, `arrival_tiploc`),
  INDEX `steps_idx_arrival_tiploc` (`arrival_tiploc`),
  INDEX `steps_idx_train_uid_schedule_order_departure_tiploc` (`train_uid`, `schedule_order`, `departure_tiploc`),
  INDEX `steps_idx_departure_tiploc` (`departure_tiploc`),
  INDEX `steps_idx_journey_id` (`journey_id`),
  INDEX `steps_idx_train_uid_schedule_order` (`train_uid`, `schedule_order`),
  PRIMARY KEY (`journey_id`, `step_order`),
  CONSTRAINT `steps_fk_train_uid_schedule_order_arrival_tiploc` FOREIGN KEY (`train_uid`, `schedule_order`, `arrival_tiploc`) REFERENCES `schedule_locations` (`train_uid`, `schedule_order`, `tiploc_code`),
  CONSTRAINT `steps_fk_arrival_tiploc` FOREIGN KEY (`arrival_tiploc`) REFERENCES `stations` (`tiploc`),
  CONSTRAINT `steps_fk_train_uid_schedule_order_departure_tiploc` FOREIGN KEY (`train_uid`, `schedule_order`, `departure_tiploc`) REFERENCES `schedule_locations` (`train_uid`, `schedule_order`, `tiploc_code`),
  CONSTRAINT `steps_fk_departure_tiploc` FOREIGN KEY (`departure_tiploc`) REFERENCES `stations` (`tiploc`),
  CONSTRAINT `steps_fk_journey_id` FOREIGN KEY (`journey_id`) REFERENCES `journeys` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `steps_fk_train_uid_schedule_order` FOREIGN KEY (`train_uid`, `schedule_order`) REFERENCES `schedules` (`train_uid`, `schedule_order`)
) ENGINE=InnoDB;

SET foreign_key_checks=1;

