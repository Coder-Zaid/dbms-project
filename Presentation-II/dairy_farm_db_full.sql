-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: dairy_farm_db
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `dairy_farm_db`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `dairy_farm_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `dairy_farm_db`;

--
-- Table structure for table `animal`
--

DROP TABLE IF EXISTS `animal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `animal` (
  `animal_id` int NOT NULL AUTO_INCREMENT,
  `animal_tag` varchar(50) NOT NULL,
  `breed_id` int NOT NULL,
  `gender` enum('Male','Female') NOT NULL,
  `date_of_birth` date NOT NULL,
  `status` enum('Active','Sold','Deceased','Transferred') NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`animal_id`),
  UNIQUE KEY `animal_tag` (`animal_tag`),
  KEY `fk_animal_breed` (`breed_id`),
  CONSTRAINT `fk_animal_breed` FOREIGN KEY (`breed_id`) REFERENCES `breed` (`breed_id`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `animal`
--

LOCK TABLES `animal` WRITE;
/*!40000 ALTER TABLE `animal` DISABLE KEYS */;
INSERT INTO `animal` VALUES (1,'A1001',1,'Female','2020-01-05','Active'),(2,'A1002',2,'Female','2020-02-10','Active'),(3,'A1003',3,'Female','2020-03-15','Active'),(4,'A1004',4,'Female','2020-04-20','Active'),(5,'A1005',5,'Female','2020-05-25','Active'),(6,'A1006',6,'Female','2020-06-12','Active'),(7,'A1007',7,'Female','2020-07-18','Active'),(8,'A1008',8,'Female','2020-08-22','Active'),(9,'A1009',9,'Female','2020-09-14','Active'),(10,'A1010',10,'Female','2020-10-30','Active'),(11,'A1011',11,'Female','2020-11-11','Active'),(12,'A1012',12,'Female','2020-12-08','Active'),(13,'A1013',13,'Female','2021-01-16','Active'),(14,'A1014',14,'Female','2021-02-19','Active'),(15,'A1015',15,'Female','2021-03-25','Active'),(16,'A1016',16,'Female','2021-04-14','Active'),(17,'A1017',17,'Female','2021-05-20','Active'),(18,'A1018',18,'Female','2021-06-09','Active'),(19,'A1019',19,'Female','2021-07-17','Active'),(20,'A1020',20,'Female','2021-08-21','Active'),(21,'A1021',21,'Female','2021-09-13','Active'),(22,'A1022',22,'Female','2021-10-26','Active'),(23,'A1023',23,'Female','2021-11-05','Active'),(24,'A1024',24,'Female','2021-12-18','Active'),(25,'A1025',25,'Female','2022-01-12','Active'),(26,'A1026',26,'Female','2022-02-16','Active'),(27,'A1027',27,'Female','2022-03-21','Active'),(28,'A1028',28,'Female','2022-04-09','Active'),(29,'A1029',29,'Female','2022-05-15','Active'),(30,'A1030',30,'Female','2022-06-23','Active'),(31,'A1031',31,'Female','2022-07-11','Active'),(32,'A1032',32,'Female','2022-08-19','Active'),(33,'A1033',33,'Female','2022-09-07','Active'),(34,'A1034',34,'Female','2022-10-14','Active'),(35,'A1035',35,'Female','2022-11-22','Active'),(36,'A1036',36,'Female','2022-12-17','Active'),(37,'A1037',37,'Female','2023-01-08','Active'),(38,'A1038',38,'Female','2023-02-14','Active'),(39,'A1039',39,'Female','2023-03-20','Active'),(40,'A1040',40,'Female','2023-04-25','Active'),(41,'A1041',41,'Female','2023-05-13','Active'),(42,'A1042',42,'Female','2023-06-18','Active'),(43,'A1043',43,'Female','2023-07-24','Active'),(44,'A1044',44,'Female','2023-08-16','Active'),(45,'A1045',45,'Female','2023-09-21','Active'),(46,'A1046',46,'Female','2023-10-11','Active'),(47,'A1047',47,'Female','2023-11-19','Active'),(48,'A1048',48,'Female','2023-12-15','Active'),(49,'A1049',49,'Female','2024-01-20','Active'),(50,'A1050',50,'Male','2020-06-18','Active');
/*!40000 ALTER TABLE `animal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `animal_milk_summary`
--

DROP TABLE IF EXISTS `animal_milk_summary`;
/*!50001 DROP VIEW IF EXISTS `animal_milk_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `animal_milk_summary` AS SELECT 
 1 AS `animal_id`,
 1 AS `animal_tag`,
 1 AS `breed_name`,
 1 AS `total_milk_litres`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `breed`
--

DROP TABLE IF EXISTS `breed`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `breed` (
  `breed_id` int NOT NULL AUTO_INCREMENT,
  `breed_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`breed_id`),
  UNIQUE KEY `breed_name` (`breed_name`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `breed`
--

LOCK TABLES `breed` WRITE;
/*!40000 ALTER TABLE `breed` DISABLE KEYS */;
INSERT INTO `breed` VALUES (1,'Holstein Friesian','High milk producing dairy breed'),(2,'Jersey','High butterfat dairy breed'),(3,'Gir','Indian dairy cattle breed'),(4,'Red Sindhi','Indian dairy cattle breed'),(5,'Sahiwal','Heat tolerant Indian dairy breed'),(6,'Brown Swiss','Swiss dairy cattle breed'),(7,'Ayrshire','Scottish dairy breed'),(8,'Guernsey','British dairy breed'),(9,'Milking Shorthorn','Traditional dairy breed'),(10,'Rathi','Indian dairy cattle breed'),(11,'Tharparkar','Indian dual purpose breed'),(12,'Kankrej','Indian cattle breed'),(13,'Ongole','Indian cattle breed'),(14,'Deoni','Indian dairy cattle breed'),(15,'Hariana','Indian cattle breed'),(16,'Kangayam','Indian cattle breed'),(17,'Amritmahal','Indian cattle breed'),(18,'Dangi','Indian cattle breed'),(19,'Khillari','Indian cattle breed'),(20,'Nagori','Indian cattle breed'),(21,'Hallikar','Indian cattle breed'),(22,'Krishna Valley','Indian cattle breed'),(23,'Mewati','Indian cattle breed'),(24,'Malvi','Indian cattle breed'),(25,'Nimari','Indian cattle breed'),(26,'Bargur','Indian cattle breed'),(27,'Punganur','Indian cattle breed'),(28,'Vechur','Indian cattle breed'),(29,'Kasargod Dwarf','Indian cattle breed'),(30,'Alambadi','Indian cattle breed'),(31,'Bachaur','Indian cattle breed'),(32,'Gaolao','Indian cattle breed'),(33,'Gangatiri','Indian cattle breed'),(34,'Ghumusari','Indian cattle breed'),(35,'Kenkatha','Indian cattle breed'),(36,'Motu','Indian cattle breed'),(37,'Kosali','Indian cattle breed'),(38,'Siri','Indian cattle breed'),(39,'Ponwar','Indian cattle breed'),(40,'Malaimadu','Indian cattle breed'),(41,'Umblachery','Indian cattle breed'),(42,'Vechur Cross','Crossbred dairy cattle'),(43,'Jersey Cross','Jersey crossbred cattle'),(44,'HF Cross','Holstein Friesian crossbred cattle'),(45,'Brown Swiss Cross','Brown Swiss crossbred cattle'),(46,'Sahiwal Cross','Sahiwal crossbred cattle'),(47,'Gir Cross','Gir crossbred cattle'),(48,'Red Sindhi Cross','Red Sindhi crossbred cattle'),(49,'Karan Fries','High yielding crossbred cattle'),(50,'Karan Swiss','Brown Swiss crossbred cattle');
/*!40000 ALTER TABLE `breed` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `breeding_event`
--

DROP TABLE IF EXISTS `breeding_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `breeding_event` (
  `breeding_id` int NOT NULL AUTO_INCREMENT,
  `animal_id` int NOT NULL,
  `breeding_date` date NOT NULL,
  `event_type` varchar(100) NOT NULL,
  `sire_id` int DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`breeding_id`),
  KEY `fk_breeding_animal` (`animal_id`),
  KEY `fk_breeding_sire` (`sire_id`),
  CONSTRAINT `fk_breeding_animal` FOREIGN KEY (`animal_id`) REFERENCES `animal` (`animal_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_breeding_sire` FOREIGN KEY (`sire_id`) REFERENCES `animal` (`animal_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `breeding_event`
--

LOCK TABLES `breeding_event` WRITE;
/*!40000 ALTER TABLE `breeding_event` DISABLE KEYS */;
INSERT INTO `breeding_event` VALUES (1,1,'2026-03-02','Natural Service',50,'Under observation'),(2,2,'2026-03-03','Artificial Insemination',50,'Under observation'),(3,3,'2026-03-04','Natural Service',50,'Successful'),(4,4,'2026-03-05','Artificial Insemination',50,'Under observation'),(5,5,'2026-03-06','Natural Service',50,'Under observation'),(6,6,'2026-03-07','Artificial Insemination',50,'Successful'),(7,7,'2026-03-08','Natural Service',50,'Under observation'),(8,8,'2026-03-09','Artificial Insemination',50,'Under observation'),(9,9,'2026-03-10','Natural Service',50,'Successful'),(10,10,'2026-03-11','Artificial Insemination',50,'Under observation'),(11,11,'2026-03-12','Natural Service',50,'Under observation'),(12,12,'2026-03-13','Artificial Insemination',50,'Successful'),(13,13,'2026-03-14','Natural Service',50,'Under observation'),(14,14,'2026-03-15','Artificial Insemination',50,'Under observation'),(15,15,'2026-03-16','Natural Service',50,'Successful'),(16,16,'2026-03-17','Artificial Insemination',50,'Under observation'),(17,17,'2026-03-18','Natural Service',50,'Under observation'),(18,18,'2026-03-19','Artificial Insemination',50,'Successful'),(19,19,'2026-03-20','Natural Service',50,'Under observation'),(20,20,'2026-03-21','Artificial Insemination',50,'Under observation'),(21,21,'2026-03-22','Natural Service',50,'Successful'),(22,22,'2026-03-23','Artificial Insemination',50,'Under observation'),(23,23,'2026-03-24','Natural Service',50,'Under observation'),(24,24,'2026-03-25','Artificial Insemination',50,'Successful'),(25,25,'2026-03-26','Natural Service',50,'Under observation'),(26,26,'2026-03-27','Artificial Insemination',50,'Under observation'),(27,27,'2026-03-28','Natural Service',50,'Successful'),(28,28,'2026-03-29','Artificial Insemination',50,'Under observation'),(29,29,'2026-03-30','Natural Service',50,'Under observation'),(30,30,'2026-03-31','Artificial Insemination',50,'Successful'),(31,31,'2026-04-01','Natural Service',50,'Under observation'),(32,32,'2026-04-02','Artificial Insemination',50,'Under observation'),(33,33,'2026-04-03','Natural Service',50,'Successful'),(34,34,'2026-04-04','Artificial Insemination',50,'Under observation'),(35,35,'2026-04-05','Natural Service',50,'Under observation'),(36,36,'2026-04-06','Artificial Insemination',50,'Successful'),(37,37,'2026-04-07','Natural Service',50,'Under observation'),(38,38,'2026-04-08','Artificial Insemination',50,'Under observation'),(39,39,'2026-04-09','Natural Service',50,'Successful'),(40,40,'2026-04-10','Artificial Insemination',50,'Under observation'),(41,41,'2026-04-11','Natural Service',50,'Under observation'),(42,42,'2026-04-12','Artificial Insemination',50,'Successful'),(43,43,'2026-04-13','Natural Service',50,'Under observation'),(44,44,'2026-04-14','Artificial Insemination',50,'Under observation'),(45,45,'2026-04-15','Natural Service',50,'Successful'),(46,46,'2026-04-16','Artificial Insemination',50,'Under observation'),(47,47,'2026-04-17','Natural Service',50,'Under observation'),(48,48,'2026-04-18','Artificial Insemination',50,'Successful'),(49,49,'2026-04-19','Natural Service',50,'Under observation'),(50,50,'2026-04-20','Artificial Insemination',50,'Under observation');
/*!40000 ALTER TABLE `breeding_event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer`
--

DROP TABLE IF EXISTS `buyer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer` (
  `buyer_id` int NOT NULL AUTO_INCREMENT,
  `buyer_name` varchar(150) NOT NULL,
  `contact` varchar(30) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`buyer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer`
--

LOCK TABLES `buyer` WRITE;
/*!40000 ALTER TABLE `buyer` DISABLE KEYS */;
INSERT INTO `buyer` VALUES (1,'Green Milk 1 Pvt Ltd','9100000001','Vijayawada'),(2,'Daily Dairy 2 Pvt Ltd','9100000002','Guntur'),(3,'Pure Milk 3 Pvt Ltd','9100000003','Warangal'),(4,'Farm Fresh 4 Pvt Ltd','9100000004','Secunderabad'),(5,'Fresh Dairy 5 Pvt Ltd','9100000005','Hyderabad'),(6,'Green Milk 6 Pvt Ltd','9100000006','Vijayawada'),(7,'Daily Dairy 7 Pvt Ltd','9100000007','Guntur'),(8,'Pure Milk 8 Pvt Ltd','9100000008','Warangal'),(9,'Farm Fresh 9 Pvt Ltd','9100000009','Secunderabad'),(10,'Fresh Dairy 10 Pvt Ltd','9100000010','Hyderabad'),(11,'Green Milk 11 Pvt Ltd','9100000011','Vijayawada'),(12,'Daily Dairy 12 Pvt Ltd','9100000012','Guntur'),(13,'Pure Milk 13 Pvt Ltd','9100000013','Warangal'),(14,'Farm Fresh 14 Pvt Ltd','9100000014','Secunderabad'),(15,'Fresh Dairy 15 Pvt Ltd','9100000015','Hyderabad'),(16,'Green Milk 16 Pvt Ltd','9100000016','Vijayawada'),(17,'Daily Dairy 17 Pvt Ltd','9100000017','Guntur'),(18,'Pure Milk 18 Pvt Ltd','9100000018','Warangal'),(19,'Farm Fresh 19 Pvt Ltd','9100000019','Secunderabad'),(20,'Fresh Dairy 20 Pvt Ltd','9100000020','Hyderabad'),(21,'Green Milk 21 Pvt Ltd','9100000021','Vijayawada'),(22,'Daily Dairy 22 Pvt Ltd','9100000022','Guntur'),(23,'Pure Milk 23 Pvt Ltd','9100000023','Warangal'),(24,'Farm Fresh 24 Pvt Ltd','9100000024','Secunderabad'),(25,'Fresh Dairy 25 Pvt Ltd','9100000025','Hyderabad'),(26,'Green Milk 26 Pvt Ltd','9100000026','Vijayawada'),(27,'Daily Dairy 27 Pvt Ltd','9100000027','Guntur'),(28,'Pure Milk 28 Pvt Ltd','9100000028','Warangal'),(29,'Farm Fresh 29 Pvt Ltd','9100000029','Secunderabad'),(30,'Fresh Dairy 30 Pvt Ltd','9100000030','Hyderabad'),(31,'Green Milk 31 Pvt Ltd','9100000031','Vijayawada'),(32,'Daily Dairy 32 Pvt Ltd','9100000032','Guntur'),(33,'Pure Milk 33 Pvt Ltd','9100000033','Warangal'),(34,'Farm Fresh 34 Pvt Ltd','9100000034','Secunderabad'),(35,'Fresh Dairy 35 Pvt Ltd','9100000035','Hyderabad'),(36,'Green Milk 36 Pvt Ltd','9100000036','Vijayawada'),(37,'Daily Dairy 37 Pvt Ltd','9100000037','Guntur'),(38,'Pure Milk 38 Pvt Ltd','9100000038','Warangal'),(39,'Farm Fresh 39 Pvt Ltd','9100000039','Secunderabad'),(40,'Fresh Dairy 40 Pvt Ltd','9100000040','Hyderabad'),(41,'Green Milk 41 Pvt Ltd','9100000041','Vijayawada'),(42,'Daily Dairy 42 Pvt Ltd','9100000042','Guntur'),(43,'Pure Milk 43 Pvt Ltd','9100000043','Warangal'),(44,'Farm Fresh 44 Pvt Ltd','9100000044','Secunderabad'),(45,'Fresh Dairy 45 Pvt Ltd','9100000045','Hyderabad'),(46,'Green Milk 46 Pvt Ltd','9100000046','Vijayawada'),(47,'Daily Dairy 47 Pvt Ltd','9100000047','Guntur'),(48,'Pure Milk 48 Pvt Ltd','9100000048','Warangal'),(49,'Farm Fresh 49 Pvt Ltd','9100000049','Secunderabad'),(50,'Fresh Dairy 50 Pvt Ltd','9100000050','Hyderabad');
/*!40000 ALTER TABLE `buyer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feed_issue`
--

DROP TABLE IF EXISTS `feed_issue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feed_issue` (
  `issue_id` int NOT NULL AUTO_INCREMENT,
  `feed_id` int NOT NULL,
  `animal_id` int NOT NULL,
  `issue_date` date NOT NULL,
  `quantity` decimal(10,2) NOT NULL,
  PRIMARY KEY (`issue_id`),
  KEY `fk_feed_issue_feed` (`feed_id`),
  KEY `fk_feed_issue_animal` (`animal_id`),
  CONSTRAINT `fk_feed_issue_animal` FOREIGN KEY (`animal_id`) REFERENCES `animal` (`animal_id`),
  CONSTRAINT `fk_feed_issue_feed` FOREIGN KEY (`feed_id`) REFERENCES `feed_item` (`feed_id`),
  CONSTRAINT `chk_feed_issue_quantity` CHECK ((`quantity` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feed_issue`
--

LOCK TABLES `feed_issue` WRITE;
/*!40000 ALTER TABLE `feed_issue` DISABLE KEYS */;
INSERT INTO `feed_issue` VALUES (1,1,1,'2026-04-02',11.00),(2,2,2,'2026-04-03',12.00),(3,3,3,'2026-04-04',13.00),(4,4,4,'2026-04-05',14.00),(5,5,5,'2026-04-06',15.00),(6,6,6,'2026-04-07',16.00),(7,7,7,'2026-04-08',17.00),(8,8,8,'2026-04-09',18.00),(9,9,9,'2026-04-10',19.00),(10,10,10,'2026-04-11',10.00),(11,11,11,'2026-04-12',11.00),(12,12,12,'2026-04-13',12.00),(13,13,13,'2026-04-14',13.00),(14,14,14,'2026-04-15',14.00),(15,15,15,'2026-04-16',15.00),(16,16,16,'2026-04-17',16.00),(17,17,17,'2026-04-18',17.00),(18,18,18,'2026-04-19',18.00),(19,19,19,'2026-04-20',19.00),(20,20,20,'2026-04-21',10.00),(21,21,21,'2026-04-22',11.00),(22,22,22,'2026-04-23',12.00),(23,23,23,'2026-04-24',13.00),(24,24,24,'2026-04-25',14.00),(25,25,25,'2026-04-26',15.00),(26,26,26,'2026-04-27',16.00),(27,27,27,'2026-04-28',17.00),(28,28,28,'2026-04-29',18.00),(29,29,29,'2026-04-30',19.00),(30,30,30,'2026-05-01',10.00),(31,31,31,'2026-05-02',11.00),(32,32,32,'2026-05-03',12.00),(33,33,33,'2026-05-04',13.00),(34,34,34,'2026-05-05',14.00),(35,35,35,'2026-05-06',15.00),(36,36,36,'2026-05-07',16.00),(37,37,37,'2026-05-08',17.00),(38,38,38,'2026-05-09',18.00),(39,39,39,'2026-05-10',19.00),(40,40,40,'2026-05-11',10.00),(41,41,41,'2026-05-12',11.00),(42,42,42,'2026-05-13',12.00),(43,43,43,'2026-05-14',13.00),(44,44,44,'2026-05-15',14.00),(45,45,45,'2026-05-16',15.00),(46,46,46,'2026-05-17',16.00),(47,47,47,'2026-05-18',17.00),(48,48,48,'2026-05-19',18.00),(49,49,49,'2026-05-20',19.00),(50,50,50,'2026-05-21',10.00);
/*!40000 ALTER TABLE `feed_issue` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_feed_issue` BEFORE INSERT ON `feed_issue` FOR EACH ROW BEGIN

    DECLARE current_stock DECIMAL(10,2);

    SELECT available_quantity
    INTO current_stock
    FROM feed_item
    WHERE feed_id = NEW.feed_id;

    IF current_stock IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Feed item does not exist';

    ELSEIF NEW.quantity > current_stock THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Feed issue exceeds available stock';

    END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_feed_issue` AFTER INSERT ON `feed_issue` FOR EACH ROW BEGIN

    UPDATE feed_item
    SET available_quantity =
        available_quantity - NEW.quantity
    WHERE feed_id = NEW.feed_id;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `feed_item`
--

DROP TABLE IF EXISTS `feed_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feed_item` (
  `feed_id` int NOT NULL AUTO_INCREMENT,
  `feed_name` varchar(100) NOT NULL,
  `unit` varchar(30) NOT NULL,
  `available_quantity` decimal(10,2) NOT NULL DEFAULT '0.00',
  `reorder_level` decimal(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`feed_id`),
  UNIQUE KEY `feed_name` (`feed_name`),
  CONSTRAINT `chk_feed_quantity` CHECK ((`available_quantity` >= 0)),
  CONSTRAINT `chk_reorder_level` CHECK ((`reorder_level` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feed_item`
--

LOCK TABLES `feed_item` WRITE;
/*!40000 ALTER TABLE `feed_item` DISABLE KEYS */;
INSERT INTO `feed_item` VALUES (1,'Feed Item 1','Bag',1009.00,205.00),(2,'Feed Item 2','Kg',1028.00,210.00),(3,'Feed Item 3','Kg',1047.00,215.00),(4,'Feed Item 4','Bag',1066.00,220.00),(5,'Feed Item 5','Kg',1085.00,225.00),(6,'Feed Item 6','Kg',1104.00,230.00),(7,'Feed Item 7','Bag',1123.00,235.00),(8,'Feed Item 8','Kg',1142.00,240.00),(9,'Feed Item 9','Kg',1161.00,245.00),(10,'Feed Item 10','Bag',1190.00,250.00),(11,'Feed Item 11','Kg',1209.00,255.00),(12,'Feed Item 12','Kg',1228.00,260.00),(13,'Feed Item 13','Bag',1247.00,265.00),(14,'Feed Item 14','Kg',1266.00,270.00),(15,'Feed Item 15','Kg',1285.00,275.00),(16,'Feed Item 16','Bag',1304.00,280.00),(17,'Feed Item 17','Kg',1323.00,285.00),(18,'Feed Item 18','Kg',1342.00,290.00),(19,'Feed Item 19','Bag',1361.00,295.00),(20,'Feed Item 20','Kg',1390.00,300.00),(21,'Feed Item 21','Kg',1409.00,305.00),(22,'Feed Item 22','Bag',1428.00,310.00),(23,'Feed Item 23','Kg',1447.00,315.00),(24,'Feed Item 24','Kg',1466.00,320.00),(25,'Feed Item 25','Bag',1485.00,325.00),(26,'Feed Item 26','Kg',1504.00,330.00),(27,'Feed Item 27','Kg',1523.00,335.00),(28,'Feed Item 28','Bag',1542.00,340.00),(29,'Feed Item 29','Kg',1561.00,345.00),(30,'Feed Item 30','Kg',1590.00,350.00),(31,'Feed Item 31','Bag',1609.00,355.00),(32,'Feed Item 32','Kg',1628.00,360.00),(33,'Feed Item 33','Kg',1647.00,365.00),(34,'Feed Item 34','Bag',1666.00,370.00),(35,'Feed Item 35','Kg',1685.00,375.00),(36,'Feed Item 36','Kg',1704.00,380.00),(37,'Feed Item 37','Bag',1723.00,385.00),(38,'Feed Item 38','Kg',1742.00,390.00),(39,'Feed Item 39','Kg',1761.00,395.00),(40,'Feed Item 40','Bag',1790.00,400.00),(41,'Feed Item 41','Kg',1809.00,405.00),(42,'Feed Item 42','Kg',1828.00,410.00),(43,'Feed Item 43','Bag',1847.00,415.00),(44,'Feed Item 44','Kg',1866.00,420.00),(45,'Feed Item 45','Kg',1885.00,425.00),(46,'Feed Item 46','Bag',1904.00,430.00),(47,'Feed Item 47','Kg',1923.00,435.00),(48,'Feed Item 48','Kg',1942.00,440.00),(49,'Feed Item 49','Bag',1961.00,445.00),(50,'Feed Item 50','Kg',1990.00,450.00);
/*!40000 ALTER TABLE `feed_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `health_visit`
--

DROP TABLE IF EXISTS `health_visit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `health_visit` (
  `visit_id` int NOT NULL AUTO_INCREMENT,
  `animal_id` int NOT NULL,
  `visit_date` date NOT NULL,
  `diagnosis` varchar(255) DEFAULT NULL,
  `treatment` varchar(255) DEFAULT NULL,
  `veterinarian` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`visit_id`),
  KEY `fk_health_animal` (`animal_id`),
  CONSTRAINT `fk_health_animal` FOREIGN KEY (`animal_id`) REFERENCES `animal` (`animal_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `health_visit`
--

LOCK TABLES `health_visit` WRITE;
/*!40000 ALTER TABLE `health_visit` DISABLE KEYS */;
INSERT INTO `health_visit` VALUES (1,1,'2026-01-05','Routine health check','No treatment required','Dr. Ravi'),(2,2,'2026-01-06','Mild fever','Medication prescribed','Dr. Priya'),(3,3,'2026-01-07','Routine health check','Vitamin supplement','Dr. Kumar'),(4,4,'2026-01-08','Digestive issue','Digestive medicine','Dr. Ravi'),(5,5,'2026-01-09','Routine check','No treatment required','Dr. Priya'),(6,6,'2026-01-10','Minor infection','Antibiotic treatment','Dr. Kumar'),(7,7,'2026-01-11','Routine check','Mineral supplement','Dr. Ravi'),(8,8,'2026-01-12','Mild fever','Medication prescribed','Dr. Priya'),(9,9,'2026-01-13','Routine check','No treatment required','Dr. Kumar'),(10,10,'2026-01-14','Skin irritation','Topical treatment','Dr. Ravi'),(11,11,'2026-01-15','Routine check','Vitamin supplement','Dr. Priya'),(12,12,'2026-01-16','Mild fever','Medication prescribed','Dr. Kumar'),(13,13,'2026-01-17','Routine check','No treatment required','Dr. Ravi'),(14,14,'2026-01-18','Digestive issue','Digestive medicine','Dr. Priya'),(15,15,'2026-01-19','Minor infection','Antibiotic treatment','Dr. Kumar'),(16,16,'2026-01-20','Routine check','No treatment required','Dr. Ravi'),(17,17,'2026-01-21','Mild fever','Medication prescribed','Dr. Priya'),(18,18,'2026-01-22','Routine check','Mineral supplement','Dr. Kumar'),(19,19,'2026-01-23','Skin irritation','Topical treatment','Dr. Ravi'),(20,20,'2026-01-24','Routine check','No treatment required','Dr. Priya'),(21,21,'2026-01-25','Digestive issue','Digestive medicine','Dr. Kumar'),(22,22,'2026-01-26','Mild fever','Medication prescribed','Dr. Ravi'),(23,23,'2026-01-27','Routine check','Vitamin supplement','Dr. Priya'),(24,24,'2026-01-28','Minor infection','Antibiotic treatment','Dr. Kumar'),(25,25,'2026-01-29','Routine check','No treatment required','Dr. Ravi'),(26,26,'2026-01-30','Mild fever','Medication prescribed','Dr. Priya'),(27,27,'2026-01-31','Routine check','Mineral supplement','Dr. Kumar'),(28,28,'2026-02-01','Skin irritation','Topical treatment','Dr. Ravi'),(29,29,'2026-02-02','Routine check','No treatment required','Dr. Priya'),(30,30,'2026-02-03','Digestive issue','Digestive medicine','Dr. Kumar'),(31,31,'2026-02-04','Mild fever','Medication prescribed','Dr. Ravi'),(32,32,'2026-02-05','Routine check','Vitamin supplement','Dr. Priya'),(33,33,'2026-02-06','Minor infection','Antibiotic treatment','Dr. Kumar'),(34,34,'2026-02-07','Routine check','No treatment required','Dr. Ravi'),(35,35,'2026-02-08','Mild fever','Medication prescribed','Dr. Priya'),(36,36,'2026-02-09','Routine check','Mineral supplement','Dr. Kumar'),(37,37,'2026-02-10','Skin irritation','Topical treatment','Dr. Ravi'),(38,38,'2026-02-11','Routine check','No treatment required','Dr. Priya'),(39,39,'2026-02-12','Digestive issue','Digestive medicine','Dr. Kumar'),(40,40,'2026-02-13','Mild fever','Medication prescribed','Dr. Ravi'),(41,41,'2026-02-14','Routine check','Vitamin supplement','Dr. Priya'),(42,42,'2026-02-15','Minor infection','Antibiotic treatment','Dr. Kumar'),(43,43,'2026-02-16','Routine check','No treatment required','Dr. Ravi'),(44,44,'2026-02-17','Mild fever','Medication prescribed','Dr. Priya'),(45,45,'2026-02-18','Routine check','Mineral supplement','Dr. Kumar'),(46,46,'2026-02-19','Skin irritation','Topical treatment','Dr. Ravi'),(47,47,'2026-02-20','Routine check','No treatment required','Dr. Priya'),(48,48,'2026-02-21','Digestive issue','Digestive medicine','Dr. Kumar'),(49,49,'2026-02-22','Mild fever','Medication prescribed','Dr. Ravi'),(50,50,'2026-02-23','Routine check','Vitamin supplement','Dr. Priya');
/*!40000 ALTER TABLE `health_visit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `milk_yield`
--

DROP TABLE IF EXISTS `milk_yield`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `milk_yield` (
  `yield_id` int NOT NULL AUTO_INCREMENT,
  `session_id` int NOT NULL,
  `quantity_litres` decimal(10,2) NOT NULL,
  PRIMARY KEY (`yield_id`),
  KEY `fk_yield_session` (`session_id`),
  CONSTRAINT `fk_yield_session` FOREIGN KEY (`session_id`) REFERENCES `milking_session` (`session_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_yield_quantity` CHECK ((`quantity_litres` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `milk_yield`
--

LOCK TABLES `milk_yield` WRITE;
/*!40000 ALTER TABLE `milk_yield` DISABLE KEYS */;
INSERT INTO `milk_yield` VALUES (1,1,16.00),(2,2,17.00),(3,3,18.00),(4,4,19.00),(5,5,20.00),(6,6,21.00),(7,7,22.00),(8,8,23.00),(9,9,24.00),(10,10,25.00),(11,11,15.00),(12,12,16.00),(13,13,17.00),(14,14,18.00),(15,15,19.00),(16,16,20.00),(17,17,21.00),(18,18,22.00),(19,19,23.00),(20,20,24.00),(21,21,25.00),(22,22,15.00),(23,23,16.00),(24,24,17.00),(25,25,18.00),(26,26,19.00),(27,27,20.00),(28,28,21.00),(29,29,22.00),(30,30,23.00),(31,31,24.00),(32,32,25.00),(33,33,15.00),(34,34,16.00),(35,35,17.00),(36,36,18.00),(37,37,19.00),(38,38,20.00),(39,39,21.00),(40,40,22.00),(41,41,23.00),(42,42,24.00),(43,43,25.00),(44,44,15.00),(45,45,16.00),(46,46,17.00),(47,47,18.00),(48,48,19.00),(49,49,20.00),(50,50,21.00);
/*!40000 ALTER TABLE `milk_yield` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `milking_session`
--

DROP TABLE IF EXISTS `milking_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `milking_session` (
  `session_id` int NOT NULL AUTO_INCREMENT,
  `animal_id` int NOT NULL,
  `session_date` date NOT NULL,
  `session_time` time NOT NULL,
  `session_type` enum('Morning','Evening','Other') NOT NULL,
  PRIMARY KEY (`session_id`),
  UNIQUE KEY `uq_milking_session` (`animal_id`,`session_date`,`session_time`),
  CONSTRAINT `fk_session_animal` FOREIGN KEY (`animal_id`) REFERENCES `animal` (`animal_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `milking_session`
--

LOCK TABLES `milking_session` WRITE;
/*!40000 ALTER TABLE `milking_session` DISABLE KEYS */;
INSERT INTO `milking_session` VALUES (1,1,'2026-05-02','06:00:00','Morning'),(2,2,'2026-05-03','17:00:00','Evening'),(3,3,'2026-05-04','06:00:00','Morning'),(4,4,'2026-05-05','17:00:00','Evening'),(5,5,'2026-05-06','06:00:00','Morning'),(6,6,'2026-05-07','17:00:00','Evening'),(7,7,'2026-05-08','06:00:00','Morning'),(8,8,'2026-05-09','17:00:00','Evening'),(9,9,'2026-05-10','06:00:00','Morning'),(10,10,'2026-05-11','17:00:00','Evening'),(11,11,'2026-05-12','06:00:00','Morning'),(12,12,'2026-05-13','17:00:00','Evening'),(13,13,'2026-05-14','06:00:00','Morning'),(14,14,'2026-05-15','17:00:00','Evening'),(15,15,'2026-05-16','06:00:00','Morning'),(16,16,'2026-05-17','17:00:00','Evening'),(17,17,'2026-05-18','06:00:00','Morning'),(18,18,'2026-05-19','17:00:00','Evening'),(19,19,'2026-05-20','06:00:00','Morning'),(20,20,'2026-05-21','17:00:00','Evening'),(21,21,'2026-05-22','06:00:00','Morning'),(22,22,'2026-05-23','17:00:00','Evening'),(23,23,'2026-05-24','06:00:00','Morning'),(24,24,'2026-05-25','17:00:00','Evening'),(25,25,'2026-05-26','06:00:00','Morning'),(26,26,'2026-05-27','17:00:00','Evening'),(27,27,'2026-05-28','06:00:00','Morning'),(28,28,'2026-05-29','17:00:00','Evening'),(29,29,'2026-05-30','06:00:00','Morning'),(30,30,'2026-05-31','17:00:00','Evening'),(31,31,'2026-06-01','06:00:00','Morning'),(32,32,'2026-06-02','17:00:00','Evening'),(33,33,'2026-06-03','06:00:00','Morning'),(34,34,'2026-06-04','17:00:00','Evening'),(35,35,'2026-06-05','06:00:00','Morning'),(36,36,'2026-06-06','17:00:00','Evening'),(37,37,'2026-06-07','06:00:00','Morning'),(38,38,'2026-06-08','17:00:00','Evening'),(39,39,'2026-06-09','06:00:00','Morning'),(40,40,'2026-06-10','17:00:00','Evening'),(41,41,'2026-06-11','06:00:00','Morning'),(42,42,'2026-06-12','17:00:00','Evening'),(43,43,'2026-06-13','06:00:00','Morning'),(44,44,'2026-06-14','17:00:00','Evening'),(45,45,'2026-06-15','06:00:00','Morning'),(46,46,'2026-06-16','17:00:00','Evening'),(47,47,'2026-06-17','06:00:00','Morning'),(48,48,'2026-06-18','17:00:00','Evening'),(49,49,'2026-06-19','06:00:00','Morning'),(50,50,'2026-06-20','17:00:00','Evening');
/*!40000 ALTER TABLE `milking_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment`
--

DROP TABLE IF EXISTS `payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `sale_id` int NOT NULL,
  `payment_date` date NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `payment_method` enum('Cash','Bank Transfer','UPI','Cheque','Other') NOT NULL,
  `reference_no` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`payment_id`),
  KEY `fk_payment_sale` (`sale_id`),
  CONSTRAINT `fk_payment_sale` FOREIGN KEY (`sale_id`) REFERENCES `sale` (`sale_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_payment_amount` CHECK ((`amount` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment`
--

LOCK TABLES `payment` WRITE;
/*!40000 ALTER TABLE `payment` DISABLE KEYS */;
INSERT INTO `payment` VALUES (1,1,'2026-06-02',282.00,'UPI','PAY-00001'),(2,2,'2026-06-03',343.00,'Bank Transfer','PAY-00002'),(3,3,'2026-06-04',408.00,'Cheque','PAY-00003'),(4,4,'2026-06-05',477.00,'Other','PAY-00004'),(5,5,'2026-06-06',550.00,'Cash','PAY-00005'),(6,6,'2026-06-07',225.00,'UPI','PAY-00006'),(7,7,'2026-06-08',282.00,'Bank Transfer','PAY-00007'),(8,8,'2026-06-09',343.00,'Cheque','PAY-00008'),(9,9,'2026-06-10',408.00,'Other','PAY-00009'),(10,10,'2026-06-11',477.00,'Cash','PAY-00010'),(11,11,'2026-06-12',550.00,'UPI','PAY-00011'),(12,12,'2026-06-13',225.00,'Bank Transfer','PAY-00012'),(13,13,'2026-06-14',282.00,'Cheque','PAY-00013'),(14,14,'2026-06-15',343.00,'Other','PAY-00014'),(15,15,'2026-06-16',408.00,'Cash','PAY-00015'),(16,16,'2026-06-17',477.00,'UPI','PAY-00016'),(17,17,'2026-06-18',550.00,'Bank Transfer','PAY-00017'),(18,18,'2026-06-19',225.00,'Cheque','PAY-00018'),(19,19,'2026-06-20',282.00,'Other','PAY-00019'),(20,20,'2026-06-21',343.00,'Cash','PAY-00020'),(21,21,'2026-06-22',408.00,'UPI','PAY-00021'),(22,22,'2026-06-23',477.00,'Bank Transfer','PAY-00022'),(23,23,'2026-06-24',550.00,'Cheque','PAY-00023'),(24,24,'2026-06-25',225.00,'Other','PAY-00024'),(25,25,'2026-06-26',282.00,'Cash','PAY-00025'),(26,26,'2026-06-27',343.00,'UPI','PAY-00026'),(27,27,'2026-06-28',408.00,'Bank Transfer','PAY-00027'),(28,28,'2026-06-29',477.00,'Cheque','PAY-00028'),(29,29,'2026-06-30',550.00,'Other','PAY-00029'),(30,30,'2026-07-01',225.00,'Cash','PAY-00030'),(31,31,'2026-07-02',282.00,'UPI','PAY-00031'),(32,32,'2026-07-03',343.00,'Bank Transfer','PAY-00032'),(33,33,'2026-07-04',408.00,'Cheque','PAY-00033'),(34,34,'2026-07-05',477.00,'Other','PAY-00034'),(35,35,'2026-07-06',550.00,'Cash','PAY-00035'),(36,36,'2026-07-07',225.00,'UPI','PAY-00036'),(37,37,'2026-07-08',282.00,'Bank Transfer','PAY-00037'),(38,38,'2026-07-09',343.00,'Cheque','PAY-00038'),(39,39,'2026-07-10',408.00,'Other','PAY-00039'),(40,40,'2026-07-11',477.00,'Cash','PAY-00040'),(41,41,'2026-07-12',550.00,'UPI','PAY-00041'),(42,42,'2026-07-13',225.00,'Bank Transfer','PAY-00042'),(43,43,'2026-07-14',282.00,'Cheque','PAY-00043'),(44,44,'2026-07-15',343.00,'Other','PAY-00044'),(45,45,'2026-07-16',408.00,'Cash','PAY-00045'),(46,46,'2026-07-17',477.00,'UPI','PAY-00046'),(47,47,'2026-07-18',550.00,'Bank Transfer','PAY-00047'),(48,48,'2026-07-19',225.00,'Cheque','PAY-00048'),(49,49,'2026-07-20',282.00,'Other','PAY-00049'),(50,50,'2026-07-21',343.00,'Cash','PAY-00050');
/*!40000 ALTER TABLE `payment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quality_test`
--

DROP TABLE IF EXISTS `quality_test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quality_test` (
  `test_id` int NOT NULL AUTO_INCREMENT,
  `yield_id` int NOT NULL,
  `test_date` date NOT NULL,
  `fat_percentage` decimal(5,2) DEFAULT NULL,
  `snf_percentage` decimal(5,2) DEFAULT NULL,
  `density` decimal(6,3) DEFAULT NULL,
  PRIMARY KEY (`test_id`),
  KEY `fk_quality_yield` (`yield_id`),
  CONSTRAINT `fk_quality_yield` FOREIGN KEY (`yield_id`) REFERENCES `milk_yield` (`yield_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_density` CHECK (((`density` is null) or (`density` >= 0))),
  CONSTRAINT `chk_fat` CHECK (((`fat_percentage` is null) or (`fat_percentage` >= 0))),
  CONSTRAINT `chk_snf` CHECK (((`snf_percentage` is null) or (`snf_percentage` >= 0)))
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quality_test`
--

LOCK TABLES `quality_test` WRITE;
/*!40000 ALTER TABLE `quality_test` DISABLE KEYS */;
INSERT INTO `quality_test` VALUES (1,1,'2026-05-02',3.60,8.40,1.029),(2,2,'2026-05-03',3.70,8.50,1.030),(3,3,'2026-05-04',3.80,8.60,1.031),(4,4,'2026-05-05',3.90,8.70,1.032),(5,5,'2026-05-06',4.00,8.80,1.033),(6,6,'2026-05-07',4.10,8.90,1.028),(7,7,'2026-05-08',4.20,8.30,1.029),(8,8,'2026-05-09',4.30,8.40,1.030),(9,9,'2026-05-10',4.40,8.50,1.031),(10,10,'2026-05-11',3.50,8.60,1.032),(11,11,'2026-05-12',3.60,8.70,1.033),(12,12,'2026-05-13',3.70,8.80,1.028),(13,13,'2026-05-14',3.80,8.90,1.029),(14,14,'2026-05-15',3.90,8.30,1.030),(15,15,'2026-05-16',4.00,8.40,1.031),(16,16,'2026-05-17',4.10,8.50,1.032),(17,17,'2026-05-18',4.20,8.60,1.033),(18,18,'2026-05-19',4.30,8.70,1.028),(19,19,'2026-05-20',4.40,8.80,1.029),(20,20,'2026-05-21',3.50,8.90,1.030),(21,21,'2026-05-22',3.60,8.30,1.031),(22,22,'2026-05-23',3.70,8.40,1.032),(23,23,'2026-05-24',3.80,8.50,1.033),(24,24,'2026-05-25',3.90,8.60,1.028),(25,25,'2026-05-26',4.00,8.70,1.029),(26,26,'2026-05-27',4.10,8.80,1.030),(27,27,'2026-05-28',4.20,8.90,1.031),(28,28,'2026-05-29',4.30,8.30,1.032),(29,29,'2026-05-30',4.40,8.40,1.033),(30,30,'2026-05-31',3.50,8.50,1.028),(31,31,'2026-06-01',3.60,8.60,1.029),(32,32,'2026-06-02',3.70,8.70,1.030),(33,33,'2026-06-03',3.80,8.80,1.031),(34,34,'2026-06-04',3.90,8.90,1.032),(35,35,'2026-06-05',4.00,8.30,1.033),(36,36,'2026-06-06',4.10,8.40,1.028),(37,37,'2026-06-07',4.20,8.50,1.029),(38,38,'2026-06-08',4.30,8.60,1.030),(39,39,'2026-06-09',4.40,8.70,1.031),(40,40,'2026-06-10',3.50,8.80,1.032),(41,41,'2026-06-11',3.60,8.90,1.033),(42,42,'2026-06-12',3.70,8.30,1.028),(43,43,'2026-06-13',3.80,8.40,1.029),(44,44,'2026-06-14',3.90,8.50,1.030),(45,45,'2026-06-15',4.00,8.60,1.031),(46,46,'2026-06-16',4.10,8.70,1.032),(47,47,'2026-06-17',4.20,8.80,1.033),(48,48,'2026-06-18',4.30,8.90,1.028),(49,49,'2026-06-19',4.40,8.30,1.029),(50,50,'2026-06-20',3.50,8.40,1.030);
/*!40000 ALTER TABLE `quality_test` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sale`
--

DROP TABLE IF EXISTS `sale`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sale` (
  `sale_id` int NOT NULL AUTO_INCREMENT,
  `buyer_id` int NOT NULL,
  `sale_date` date NOT NULL,
  `total_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`sale_id`),
  KEY `fk_sale_buyer` (`buyer_id`),
  CONSTRAINT `fk_sale_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyer` (`buyer_id`),
  CONSTRAINT `chk_sale_total` CHECK ((`total_amount` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sale`
--

LOCK TABLES `sale` WRITE;
/*!40000 ALTER TABLE `sale` DISABLE KEYS */;
INSERT INTO `sale` VALUES (1,1,'2026-06-02',282.00),(2,2,'2026-06-03',343.00),(3,3,'2026-06-04',408.00),(4,4,'2026-06-05',477.00),(5,5,'2026-06-06',550.00),(6,6,'2026-06-07',225.00),(7,7,'2026-06-08',282.00),(8,8,'2026-06-09',343.00),(9,9,'2026-06-10',408.00),(10,10,'2026-06-11',477.00),(11,11,'2026-06-12',550.00),(12,12,'2026-06-13',225.00),(13,13,'2026-06-14',282.00),(14,14,'2026-06-15',343.00),(15,15,'2026-06-16',408.00),(16,16,'2026-06-17',477.00),(17,17,'2026-06-18',550.00),(18,18,'2026-06-19',225.00),(19,19,'2026-06-20',282.00),(20,20,'2026-06-21',343.00),(21,21,'2026-06-22',408.00),(22,22,'2026-06-23',477.00),(23,23,'2026-06-24',550.00),(24,24,'2026-06-25',225.00),(25,25,'2026-06-26',282.00),(26,26,'2026-06-27',343.00),(27,27,'2026-06-28',408.00),(28,28,'2026-06-29',477.00),(29,29,'2026-06-30',550.00),(30,30,'2026-07-01',225.00),(31,31,'2026-07-02',282.00),(32,32,'2026-07-03',343.00),(33,33,'2026-07-04',408.00),(34,34,'2026-07-05',477.00),(35,35,'2026-07-06',550.00),(36,36,'2026-07-07',225.00),(37,37,'2026-07-08',282.00),(38,38,'2026-07-09',343.00),(39,39,'2026-07-10',408.00),(40,40,'2026-07-11',477.00),(41,41,'2026-07-12',550.00),(42,42,'2026-07-13',225.00),(43,43,'2026-07-14',282.00),(44,44,'2026-07-15',343.00),(45,45,'2026-07-16',408.00),(46,46,'2026-07-17',477.00),(47,47,'2026-07-18',550.00),(48,48,'2026-07-19',225.00),(49,49,'2026-07-20',282.00),(50,50,'2026-07-21',343.00);
/*!40000 ALTER TABLE `sale` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sale_item`
--

DROP TABLE IF EXISTS `sale_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sale_item` (
  `sale_id` int NOT NULL,
  `yield_id` int NOT NULL,
  `quantity_sold` decimal(10,2) NOT NULL,
  `rate_per_litre` decimal(10,2) NOT NULL,
  PRIMARY KEY (`sale_id`,`yield_id`),
  KEY `fk_sale_item_yield` (`yield_id`),
  CONSTRAINT `fk_sale_item_sale` FOREIGN KEY (`sale_id`) REFERENCES `sale` (`sale_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sale_item_yield` FOREIGN KEY (`yield_id`) REFERENCES `milk_yield` (`yield_id`),
  CONSTRAINT `chk_sale_quantity` CHECK ((`quantity_sold` > 0)),
  CONSTRAINT `chk_sale_rate` CHECK ((`rate_per_litre` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sale_item`
--

LOCK TABLES `sale_item` WRITE;
/*!40000 ALTER TABLE `sale_item` DISABLE KEYS */;
INSERT INTO `sale_item` VALUES (1,1,6.00,47.00),(2,2,7.00,49.00),(3,3,8.00,51.00),(4,4,9.00,53.00),(5,5,10.00,55.00),(6,6,5.00,45.00),(7,7,6.00,47.00),(8,8,7.00,49.00),(9,9,8.00,51.00),(10,10,9.00,53.00),(11,11,10.00,55.00),(12,12,5.00,45.00),(13,13,6.00,47.00),(14,14,7.00,49.00),(15,15,8.00,51.00),(16,16,9.00,53.00),(17,17,10.00,55.00),(18,18,5.00,45.00),(19,19,6.00,47.00),(20,20,7.00,49.00),(21,21,8.00,51.00),(22,22,9.00,53.00),(23,23,10.00,55.00),(24,24,5.00,45.00),(25,25,6.00,47.00),(26,26,7.00,49.00),(27,27,8.00,51.00),(28,28,9.00,53.00),(29,29,10.00,55.00),(30,30,5.00,45.00),(31,31,6.00,47.00),(32,32,7.00,49.00),(33,33,8.00,51.00),(34,34,9.00,53.00),(35,35,10.00,55.00),(36,36,5.00,45.00),(37,37,6.00,47.00),(38,38,7.00,49.00),(39,39,8.00,51.00),(40,40,9.00,53.00),(41,41,10.00,55.00),(42,42,5.00,45.00),(43,43,6.00,47.00),(44,44,7.00,49.00),(45,45,8.00,51.00),(46,46,9.00,53.00),(47,47,10.00,55.00),(48,48,5.00,45.00),(49,49,6.00,47.00),(50,50,7.00,49.00);
/*!40000 ALTER TABLE `sale_item` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_sale_item` BEFORE INSERT ON `sale_item` FOR EACH ROW BEGIN

    DECLARE collected_quantity DECIMAL(10,2);
    DECLARE already_sold DECIMAL(10,2);

    SELECT quantity_litres
    INTO collected_quantity
    FROM milk_yield
    WHERE yield_id = NEW.yield_id;

    IF collected_quantity IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Milk yield does not exist';

    END IF;

    SELECT COALESCE(SUM(quantity_sold), 0)
    INTO already_sold
    FROM sale_item
    WHERE yield_id = NEW.yield_id;

    IF already_sold + NEW.quantity_sold > collected_quantity THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Quantity sold exceeds available milk yield';

    END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_sale_item` AFTER INSERT ON `sale_item` FOR EACH ROW BEGIN

    UPDATE sale
    SET total_amount = (
        SELECT COALESCE(
            SUM(quantity_sold * rate_per_litre),
            0
        )
        FROM sale_item
        WHERE sale_id = NEW.sale_id
    )
    WHERE sale_id = NEW.sale_id;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `vaccination`
--

DROP TABLE IF EXISTS `vaccination`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vaccination` (
  `vaccination_id` int NOT NULL AUTO_INCREMENT,
  `animal_id` int NOT NULL,
  `vaccine_name` varchar(150) NOT NULL,
  `vaccination_date` date NOT NULL,
  `next_due_date` date DEFAULT NULL,
  PRIMARY KEY (`vaccination_id`),
  KEY `fk_vaccination_animal` (`animal_id`),
  CONSTRAINT `fk_vaccination_animal` FOREIGN KEY (`animal_id`) REFERENCES `animal` (`animal_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_vaccination_dates` CHECK (((`next_due_date` is null) or (`next_due_date` >= `vaccination_date`)))
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vaccination`
--

LOCK TABLES `vaccination` WRITE;
/*!40000 ALTER TABLE `vaccination` DISABLE KEYS */;
INSERT INTO `vaccination` VALUES (1,1,'HS Vaccine','2026-01-02','2026-07-02'),(2,2,'BQ Vaccine','2026-01-03','2026-07-03'),(3,3,'Brucellosis Vaccine','2026-01-04','2026-07-04'),(4,4,'FMD Vaccine','2026-01-05','2026-07-05'),(5,5,'HS Vaccine','2026-01-06','2026-07-06'),(6,6,'BQ Vaccine','2026-01-07','2026-07-07'),(7,7,'Brucellosis Vaccine','2026-01-08','2026-07-08'),(8,8,'FMD Vaccine','2026-01-09','2026-07-09'),(9,9,'HS Vaccine','2026-01-10','2026-07-10'),(10,10,'BQ Vaccine','2026-01-11','2026-07-11'),(11,11,'Brucellosis Vaccine','2026-01-12','2026-07-12'),(12,12,'FMD Vaccine','2026-01-13','2026-07-13'),(13,13,'HS Vaccine','2026-01-14','2026-07-14'),(14,14,'BQ Vaccine','2026-01-15','2026-07-15'),(15,15,'Brucellosis Vaccine','2026-01-16','2026-07-16'),(16,16,'FMD Vaccine','2026-01-17','2026-07-17'),(17,17,'HS Vaccine','2026-01-18','2026-07-18'),(18,18,'BQ Vaccine','2026-01-19','2026-07-19'),(19,19,'Brucellosis Vaccine','2026-01-20','2026-07-20'),(20,20,'FMD Vaccine','2026-01-21','2026-07-21'),(21,21,'HS Vaccine','2026-01-22','2026-07-22'),(22,22,'BQ Vaccine','2026-01-23','2026-07-23'),(23,23,'Brucellosis Vaccine','2026-01-24','2026-07-24'),(24,24,'FMD Vaccine','2026-01-25','2026-07-25'),(25,25,'HS Vaccine','2026-01-26','2026-07-26'),(26,26,'BQ Vaccine','2026-01-27','2026-07-27'),(27,27,'Brucellosis Vaccine','2026-01-28','2026-07-28'),(28,28,'FMD Vaccine','2026-01-29','2026-07-29'),(29,29,'HS Vaccine','2026-01-30','2026-07-30'),(30,30,'BQ Vaccine','2026-01-31','2026-07-31'),(31,31,'Brucellosis Vaccine','2026-02-01','2026-08-01'),(32,32,'FMD Vaccine','2026-02-02','2026-08-02'),(33,33,'HS Vaccine','2026-02-03','2026-08-03'),(34,34,'BQ Vaccine','2026-02-04','2026-08-04'),(35,35,'Brucellosis Vaccine','2026-02-05','2026-08-05'),(36,36,'FMD Vaccine','2026-02-06','2026-08-06'),(37,37,'HS Vaccine','2026-02-07','2026-08-07'),(38,38,'BQ Vaccine','2026-02-08','2026-08-08'),(39,39,'Brucellosis Vaccine','2026-02-09','2026-08-09'),(40,40,'FMD Vaccine','2026-02-10','2026-08-10'),(41,41,'HS Vaccine','2026-02-11','2026-08-11'),(42,42,'BQ Vaccine','2026-02-12','2026-08-12'),(43,43,'Brucellosis Vaccine','2026-02-13','2026-08-13'),(44,44,'FMD Vaccine','2026-02-14','2026-08-14'),(45,45,'HS Vaccine','2026-02-15','2026-08-15'),(46,46,'BQ Vaccine','2026-02-16','2026-08-16'),(47,47,'Brucellosis Vaccine','2026-02-17','2026-08-17'),(48,48,'FMD Vaccine','2026-02-18','2026-08-18'),(49,49,'HS Vaccine','2026-02-19','2026-08-19'),(50,50,'BQ Vaccine','2026-02-20','2026-08-20');
/*!40000 ALTER TABLE `vaccination` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'dairy_farm_db'
--

--
-- Current Database: `dairy_farm_db`
--

USE `dairy_farm_db`;

--
-- Final view structure for view `animal_milk_summary`
--

/*!50001 DROP VIEW IF EXISTS `animal_milk_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `animal_milk_summary` AS select `a`.`animal_id` AS `animal_id`,`a`.`animal_tag` AS `animal_tag`,`b`.`breed_name` AS `breed_name`,coalesce(sum(`y`.`quantity_litres`),0) AS `total_milk_litres` from (((`animal` `a` join `breed` `b` on((`a`.`breed_id` = `b`.`breed_id`))) left join `milking_session` `ms` on((`a`.`animal_id` = `ms`.`animal_id`))) left join `milk_yield` `y` on((`ms`.`session_id` = `y`.`session_id`))) group by `a`.`animal_id`,`a`.`animal_tag`,`b`.`breed_name` */;
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

-- Dump completed on 2026-10-07  2:14:21


-- Realistic Master Commodity and Buyer Names --
UPDATE feed_item SET feed_name = 'Alfalfa Hay (Grade A)' WHERE feed_id = 1;
UPDATE feed_item SET feed_name = 'Whole Corn Silage' WHERE feed_id = 2;
UPDATE feed_item SET feed_name = 'Cottonseed Oil Cake' WHERE feed_id = 3;
UPDATE feed_item SET feed_name = 'De-oiled Rice Bran' WHERE feed_id = 4;
UPDATE feed_item SET feed_name = 'Coarse Wheat Bran' WHERE feed_id = 5;
UPDATE feed_item SET feed_name = 'High-Protein Soybean Meal' WHERE feed_id = 6;
UPDATE feed_item SET feed_name = 'Crushed Barley Grain' WHERE feed_id = 7;
UPDATE feed_item SET feed_name = 'Multi-Mineral Feed Premix' WHERE feed_id = 8;
UPDATE feed_item SET feed_name = 'Calcium Feed Tonic' WHERE feed_id = 9;
UPDATE feed_item SET feed_name = 'Hybrid Napier Grass' WHERE feed_id = 10;
UPDATE feed_item SET feed_name = 'Rhodes Grass Hay' WHERE feed_id = 11;
UPDATE feed_item SET feed_name = 'Cane Molasses Mash' WHERE feed_id = 12;
UPDATE feed_item SET feed_name = 'Mustard Seed Cake' WHERE feed_id = 13;
UPDATE feed_item SET feed_name = 'Flaked Yellow Maize' WHERE feed_id = 14;
UPDATE feed_item SET feed_name = 'Sorghum Sudan Fodder' WHERE feed_id = 15;
UPDATE feed_item SET feed_name = 'Lucerne Green Chop' WHERE feed_id = 16;
UPDATE feed_item SET feed_name = 'Groundnut Expeller Cake' WHERE feed_id = 17;
UPDATE feed_item SET feed_name = 'Brewers Dried Yeast Mash' WHERE feed_id = 18;
UPDATE feed_item SET feed_name = 'Linseed Meal' WHERE feed_id = 19;
UPDATE feed_item SET feed_name = 'Oat Fodder Hay' WHERE feed_id = 20;
UPDATE feed_item SET feed_name = 'Berseem Clover' WHERE feed_id = 21;
UPDATE feed_item SET feed_name = 'Bypass Protein Concentrate' WHERE feed_id = 22;
UPDATE feed_item SET feed_name = 'Sodium Bicarbonate Buffer' WHERE feed_id = 23;
UPDATE feed_item SET feed_name = 'Urea Molasses Block' WHERE feed_id = 24;
UPDATE feed_item SET feed_name = 'Crushed Chickpea Husk' WHERE feed_id = 25;
UPDATE feed_item SET feed_name = 'Pigeonpea Husk (Chuni)' WHERE feed_id = 26;
UPDATE feed_item SET feed_name = 'Dry Wheat Straw (Bhusa)' WHERE feed_id = 27;
UPDATE feed_item SET feed_name = 'Sugarcane Tops Silage' WHERE feed_id = 28;
UPDATE feed_item SET feed_name = 'Sesame Seed Cake' WHERE feed_id = 29;
UPDATE feed_item SET feed_name = 'Sunflower Expeller Meal' WHERE feed_id = 30;
UPDATE feed_item SET feed_name = 'Sweet Sorghum Silage' WHERE feed_id = 31;
UPDATE feed_item SET feed_name = 'Roasted Soy Granules' WHERE feed_id = 32;
UPDATE feed_item SET feed_name = 'Probiotic Cattle Supplement' WHERE feed_id = 33;
UPDATE feed_item SET feed_name = 'Chelated Mineral Premix' WHERE feed_id = 34;
UPDATE feed_item SET feed_name = 'Rye Grass Forage' WHERE feed_id = 35;
UPDATE feed_item SET feed_name = 'Pearl Millet (Bajra) Stover' WHERE feed_id = 36;
UPDATE feed_item SET feed_name = 'Finger Millet Straw' WHERE feed_id = 37;
UPDATE feed_item SET feed_name = 'Coconut Oil Cake (Copra)' WHERE feed_id = 38;
UPDATE feed_item SET feed_name = 'Palm Kernel Meal' WHERE feed_id = 39;
UPDATE feed_item SET feed_name = 'Dry Paddy Straw' WHERE feed_id = 40;
UPDATE feed_item SET feed_name = 'Vitamin A-D3-E Emulsion' WHERE feed_id = 41;
UPDATE feed_item SET feed_name = 'Rumen-Protected Fat' WHERE feed_id = 42;
UPDATE feed_item SET feed_name = 'Toxin Binder Premix' WHERE feed_id = 43;
UPDATE feed_item SET feed_name = 'Live Yeast Culture' WHERE feed_id = 44;
UPDATE feed_item SET feed_name = 'Organic Jaggery Mash' WHERE feed_id = 45;
UPDATE feed_item SET feed_name = 'Fenugreek (Methi) Meal' WHERE feed_id = 46;
UPDATE feed_item SET feed_name = 'Desi Gram Flour Mash' WHERE feed_id = 47;
UPDATE feed_item SET feed_name = 'Subabul Leaf Fodder' WHERE feed_id = 48;
UPDATE feed_item SET feed_name = 'Stylo Legume Hay' WHERE feed_id = 49;
UPDATE feed_item SET feed_name = 'Dairy Total Mixed Ration' WHERE feed_id = 50;
UPDATE buyer SET buyer_name = 'Amul Dairy Cooperative' WHERE buyer_id = 1;
UPDATE buyer SET buyer_name = 'Mother Dairy Fruit & Veg' WHERE buyer_id = 2;
UPDATE buyer SET buyer_name = 'Karnataka Milk Fed (Nandini)' WHERE buyer_id = 3;
UPDATE buyer SET buyer_name = 'Heritage Foods Ltd' WHERE buyer_id = 4;
UPDATE buyer SET buyer_name = 'Vijaya Dairy Federation' WHERE buyer_id = 5;
UPDATE buyer SET buyer_name = 'Dodla Dairy Limited' WHERE buyer_id = 6;
UPDATE buyer SET buyer_name = 'Tamil Nadu Co-op (Aavin)' WHERE buyer_id = 7;
UPDATE buyer SET buyer_name = 'Kerala Co-op (Milma)' WHERE buyer_id = 8;
UPDATE buyer SET buyer_name = 'Creamline Dairy (Jersey)' WHERE buyer_id = 9;
UPDATE buyer SET buyer_name = 'Kwality Milk Foods Ltd' WHERE buyer_id = 10;
UPDATE buyer SET buyer_name = 'Parag Milk Foods (Gowardhan)' WHERE buyer_id = 11;
UPDATE buyer SET buyer_name = 'Hatsun Agro Product (Arokya)' WHERE buyer_id = 12;
UPDATE buyer SET buyer_name = 'Punjab State Co-op (Verka)' WHERE buyer_id = 13;
UPDATE buyer SET buyer_name = 'Haryana Dairy Fed (Vita)' WHERE buyer_id = 14;
UPDATE buyer SET buyer_name = 'Bihar State Co-op (Sudha)' WHERE buyer_id = 15;
UPDATE buyer SET buyer_name = 'Rajasthan Co-op (Saras)' WHERE buyer_id = 16;
UPDATE buyer SET buyer_name = 'Madhya Pradesh Co-op (Sanchi)' WHERE buyer_id = 17;
UPDATE buyer SET buyer_name = 'Uttar Pradesh Co-op (Parag)' WHERE buyer_id = 18;
UPDATE buyer SET buyer_name = 'Odisha State Co-op (Omfed)' WHERE buyer_id = 19;
UPDATE buyer SET buyer_name = 'Heritage Fresh Dairy Union' WHERE buyer_id = 20;
UPDATE buyer SET buyer_name = 'Tirumala Milk Products' WHERE buyer_id = 21;
UPDATE buyer SET buyer_name = 'Prabhat Dairy Industries' WHERE buyer_id = 22;
UPDATE buyer SET buyer_name = 'Dynamix Dairy Industries' WHERE buyer_id = 23;
UPDATE buyer SET buyer_name = 'Vasudhara Dairy Co-op' WHERE buyer_id = 24;
UPDATE buyer SET buyer_name = 'Sabarkantha Co-op (Sabar)' WHERE buyer_id = 25;
UPDATE buyer SET buyer_name = 'Banaskantha Co-op (Banas)' WHERE buyer_id = 26;
UPDATE buyer SET buyer_name = 'Mehsana Co-op (DudhSagar)' WHERE buyer_id = 27;
UPDATE buyer SET buyer_name = 'Surat Co-op (Sumul)' WHERE buyer_id = 28;
UPDATE buyer SET buyer_name = 'Baroda District Co-op' WHERE buyer_id = 29;
UPDATE buyer SET buyer_name = 'Panchmahal Co-op Milk' WHERE buyer_id = 30;
UPDATE buyer SET buyer_name = 'Kaira District Co-op (Anand)' WHERE buyer_id = 31;
UPDATE buyer SET buyer_name = 'Sangam Dairy Guntur' WHERE buyer_id = 32;
UPDATE buyer SET buyer_name = 'Krishna District Milk Union' WHERE buyer_id = 33;
UPDATE buyer SET buyer_name = 'Visakha Dairy Co-op' WHERE buyer_id = 34;
UPDATE buyer SET buyer_name = 'Chittoor Milk Producers' WHERE buyer_id = 35;
UPDATE buyer SET buyer_name = 'Warangal Milk Union' WHERE buyer_id = 36;
UPDATE buyer SET buyer_name = 'Karimnagar Dairy Co-op' WHERE buyer_id = 37;
UPDATE buyer SET buyer_name = 'Nalgonda-RangaReddy Union' WHERE buyer_id = 38;
UPDATE buyer SET buyer_name = 'Mother Dairy Hyderabad' WHERE buyer_id = 39;
UPDATE buyer SET buyer_name = 'Balaji Dairy Products' WHERE buyer_id = 40;
UPDATE buyer SET buyer_name = 'Godrej Jersey Milk Plant' WHERE buyer_id = 41;
UPDATE buyer SET buyer_name = 'Modern Dairies Limited' WHERE buyer_id = 42;
UPDATE buyer SET buyer_name = 'Sterling Agro (Nova)' WHERE buyer_id = 43;
UPDATE buyer SET buyer_name = 'Bega Cheese Alliance' WHERE buyer_id = 44;
UPDATE buyer SET buyer_name = 'Schreiber Dynamix Dairies' WHERE buyer_id = 45;
UPDATE buyer SET buyer_name = 'Nestle India Dairy Unit' WHERE buyer_id = 46;
UPDATE buyer SET buyer_name = 'Danone India Nutrition' WHERE buyer_id = 47;
UPDATE buyer SET buyer_name = 'CavinKare Dairy Division' WHERE buyer_id = 48;
UPDATE buyer SET buyer_name = 'Ananda Dairy Foods' WHERE buyer_id = 49;
UPDATE buyer SET buyer_name = 'Milky Mist Dairy Foods' WHERE buyer_id = 50;
