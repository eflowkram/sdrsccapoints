CREATE DATABASE sdr_points;

CREATE TABLE clubs  (
    id int(10) NOT NULL AUTO_INCREMENT,
    name varchar(20),
    primary key (id)
);

CREATE TABLE event (
    id int(10) NOT NULL AUTO_INCREMENT,
    date, 
    club_id int(10)
    primary key (id)
)

CREATE TABLE classes (
    id int(10) NOT NULL AUTO_INCREMENT,
    long_name varchar(50),
    short_name varchar(50),
    primary key (id)
);   

CREATE TABLE driver (
    id int(10) NOT NULL AUTO_INCREMENT,
    first_name varchar(50),
    last_name varchar(50),
    car_number int(10) unique,
    primary key (id)
);

CREATE TABLE event_results (
    id int(10) NOT NULL AUTO_INCREMENT,
    event_date date,
    driver_id int(10),
    class_id int(10),
    run1 decimal(10,3),
    run2 decimal(10,3),
    run3 decimal(10,3),
    run4 decimal(10,3),
    run5 decimal(10,3),
    place int(10),
    final_time decimal(10,3),
    points decimal(10,3),
    cone_count int(10),
    dnf_count int(10),
    sound_violations int(10),
    primary key (id)
    unique (event_date,driver_id)
);

CREATE TABLE pax_results (
    id int(10) NOT NULL AUTO_INCREMENT,
    event_date date,
    driver_id int(10),
    club_id int(10),
    pax_time decimal(10,3),
    points  decimal(10,3),
    primary key (id),
    unique (event_date,driver_id)
);
-- MySQL dump 10.19  Distrib 10.3.31-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: sdr_points
-- ------------------------------------------------------
-- Server version	10.3.31-MariaDB-0+deb10u1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `sdr_points`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `sdr_points` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;

USE `sdr_points`;

--
-- Table structure for table `classes`
--

DROP TABLE IF EXISTS `classes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classes` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `long_name` varchar(50) DEFAULT NULL,
  `short_name` varchar(50) DEFAULT NULL,
  `class_order` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `short_name` (`short_name`)
) ENGINE=InnoDB AUTO_INCREMENT=130 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `club_points`
--

DROP TABLE IF EXISTS `club_points`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `club_points` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `club_id` int(10) DEFAULT NULL,
  `event_id` int(10) DEFAULT NULL,
  `club_points` decimal(10,4) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `club_event` (`club_id`,`event_id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `club_points2`
--

DROP TABLE IF EXISTS `club_points2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `club_points2` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `club_id` int(10) DEFAULT NULL,
  `event_id` int(10) DEFAULT NULL,
  `club_points` decimal(10,4) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `club_temp`
--

DROP TABLE IF EXISTS `club_temp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `club_temp` (
  `club_id` int(10) DEFAULT NULL,
  `points` decimal(10,4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `clubs`
--

DROP TABLE IF EXISTS `clubs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clubs` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `driver_temp`
--

DROP TABLE IF EXISTS `driver_temp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `driver_temp` (
  `driver_id` int(10) DEFAULT NULL,
  `points` decimal(10,3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `drivers`
--

DROP TABLE IF EXISTS `drivers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `drivers` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `car_number` int(10) DEFAULT NULL,
  `club_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `car_number` (`car_number`)
) ENGINE=InnoDB AUTO_INCREMENT=243 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `event_results`
--

DROP TABLE IF EXISTS `event_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event_results` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `event_date` date DEFAULT NULL,
  `event_id` int(10) DEFAULT NULL,
  `driver_id` int(10) DEFAULT NULL,
  `class_id` int(10) DEFAULT NULL,
  `run1` decimal(10,3) DEFAULT NULL,
  `run2` decimal(10,3) DEFAULT NULL,
  `run3` decimal(10,3) DEFAULT NULL,
  `run4` decimal(10,3) DEFAULT NULL,
  `run5` decimal(10,3) DEFAULT NULL,
  `place` int(10) DEFAULT NULL,
  `final_time` decimal(10,3) DEFAULT NULL,
  `points` decimal(10,3) DEFAULT NULL,
  `cone_count` int(10) DEFAULT NULL,
  `dnf_count` int(10) DEFAULT NULL,
  `sound_violations` int(10) DEFAULT NULL,
  `run_count` int(10) DEFAULT NULL,
  `club_points` tinyint(1) DEFAULT NULL,
  `nat_event` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `event_date` (`event_date`,`driver_id`)
) ENGINE=InnoDB AUTO_INCREMENT=676 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `events` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `event_date` date DEFAULT NULL,
  `club_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pax_results`
--

DROP TABLE IF EXISTS `pax_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pax_results` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `event_date` date DEFAULT NULL,
  `pax_place` int(10) DEFAULT NULL,
  `driver_id` int(10) DEFAULT NULL,
  `club_id` int(10) DEFAULT NULL,
  `pax_time` decimal(10,3) DEFAULT NULL,
  `points` decimal(10,3) DEFAULT NULL,
  `nat_event` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `event_date` (`event_date`,`driver_id`)
) ENGINE=InnoDB AUTO_INCREMENT=375 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pax_temp`
--

DROP TABLE IF EXISTS `pax_temp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pax_temp` (
  `driver_id` int(10) DEFAULT NULL,
  `car_number` int(10) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `club` varchar(10) DEFAULT NULL,
  `points_1` decimal(10,3) DEFAULT NULL,
  `points_2` decimal(10,3) DEFAULT NULL,
  `points_3` decimal(10,3) DEFAULT NULL,
  `points_4` decimal(10,3) DEFAULT NULL,
  `total_points` decimal(10,3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `pax_view`
--

DROP TABLE IF EXISTS `pax_view`;
/*!50001 DROP VIEW IF EXISTS `pax_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `pax_view` (
  `car_number` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `club` tinyint NOT NULL,
  `event_points` tinyint NOT NULL,
  `points` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `po`
--

DROP TABLE IF EXISTS `po`;
/*!50001 DROP VIEW IF EXISTS `po`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `po` (
  `short_name` tinyint NOT NULL,
  `car_number` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `event_points` tinyint NOT NULL,
  `points` tinyint NOT NULL,
  `runs` tinyint NOT NULL,
  `cones` tinyint NOT NULL,
  `dnf` tinyint NOT NULL,
  `sound` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `points_out`
--

DROP TABLE IF EXISTS `points_out`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `points_out` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `class_id` int(10) DEFAULT NULL,
  `place` int(10) DEFAULT NULL,
  `driver_id` int(10) DEFAULT NULL,
  `points1` decimal(10,3) DEFAULT NULL,
  `points2` decimal(10,3) DEFAULT NULL,
  `total_points` decimal(10,3) DEFAULT NULL,
  `cone_count` int(10) DEFAULT NULL,
  `dnf_count` int(10) DEFAULT NULL,
  `sound_violations` int(10) DEFAULT NULL,
  `run_count` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Current Database: `sdr_points`
--

USE `sdr_points`;

--
-- Final view structure for view `pax_view`
--

/*!50001 DROP TABLE IF EXISTS `pax_view`*/;
/*!50001 DROP VIEW IF EXISTS `pax_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`markw`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `pax_view` AS select `drivers`.`car_number` AS `car_number`,concat(`drivers`.`first_name`,' ',substr(`drivers`.`last_name`,1,1)) AS `name`,`clubs`.`name` AS `club`,group_concat(`pax_results`.`points` order by `events`.`id` ASC separator ',') AS `event_points`,sum(`pax_results`.`points`) AS `points` from (((`pax_results` join `drivers` on(`pax_results`.`driver_id` = `drivers`.`id`)) join `clubs` on(`pax_results`.`club_id` = `clubs`.`id`)) join `events` on(`pax_results`.`event_date` = `events`.`event_date`)) group by `pax_results`.`driver_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `po`
--

/*!50001 DROP TABLE IF EXISTS `po`*/;
/*!50001 DROP VIEW IF EXISTS `po`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`markw`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `po` AS select `classes`.`short_name` AS `short_name`,`drivers`.`car_number` AS `car_number`,concat(`drivers`.`first_name`,' ',substr(`drivers`.`last_name`,1,1)) AS `name`,group_concat('event',' ',`events`.`id`,'=',`event_results`.`points` separator ',') AS `event_points`,sum(`event_results`.`points`) AS `points`,sum(`event_results`.`run_count`) AS `runs`,sum(`event_results`.`cone_count`) AS `cones`,sum(`event_results`.`dnf_count`) AS `dnf`,sum(`event_results`.`sound_violations`) AS `sound` from (((`event_results` join `classes` on(`event_results`.`class_id` = `classes`.`id`)) join `drivers` on(`event_results`.`driver_id` = `drivers`.`id`)) join `events` on(`event_results`.`event_date` = `events`.`event_date`)) group by `event_results`.`class_id`,`event_results`.`driver_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-10-27 20:57:45
