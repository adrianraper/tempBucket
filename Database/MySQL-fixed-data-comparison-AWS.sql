mysqldump.exe --no-create-info=FALSE --order-by-primary=FALSE --force=FALSE --no-data=FALSE --tz-utc=TRUE --flush-privileges=FALSE --compress=FALSE --replace=FALSE 
--insert-ignore=FALSE --extended-insert=TRUE --quote-names=TRUE --hex-blob=FALSE --complete-insert=FALSE --add-locks=TRUE --port=3306 --disable-keys=TRUE 
--delayed-insert=FALSE --create-options=TRUE --delete-master-logs=FALSE --comments=TRUE 
--max_allowed_packet=1G --flush-logs=FALSE --dump-date=TRUE --lock-tables=TRUE --allow-keywords=FALSE --events=FALSE 
--default-character-set=utf8 
--host=claritylive.cjxpltmvwbov.ap-southeast-1.rds.amazonaws.com --user=clarity 
"rack80829" "T_PackageContents" "T_MessageType" "T_ProductLanguage" "T_Language" "T_DatabaseVersion" "T_Offer" "T_Package" "T_Product" "T_AccountStatus" "T_LicenceType" "T_Triggers" "T_Reseller" "T_ApprovalStatus" "T_TermsConditions" "T_AccountType"
CREATE DATABASE  IF NOT EXISTS `rack80829` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `rack80829`;
-- MySQL dump 10.13  Distrib 5.5.9, for Win32 (x86)
--
-- Host: claritylive.cjxpltmvwbov.ap-southeast-1.rds.amazonaws.com    Database: rack80829
-- ------------------------------------------------------
-- Server version	5.1.50-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `T_PackageContents`
--

DROP TABLE IF EXISTS `T_PackageContents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_PackageContents` (
  `F_PackageID` smallint(5) NOT NULL,
  `F_ProductCode` smallint(5) NOT NULL,
  `F_CourseID` bigint(19) DEFAULT NULL,
  PRIMARY KEY (`F_PackageID`,`F_ProductCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `T_PackageContents`
--

LOCK TABLES `T_PackageContents` WRITE;
/*!40000 ALTER TABLE `T_PackageContents` DISABLE KEYS */;
INSERT INTO `T_PackageContents` VALUES (1,9,NULL),(1,33,NULL),(1,39,NULL),(1,49,NULL),(2,10,NULL),(2,38,NULL),(2,40,NULL),(2,43,NULL),(2,1001,NULL),(3,12,NULL),(4,13,NULL),(5,38,NULL),(5,1001,NULL);
/*!40000 ALTER TABLE `T_PackageContents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `T_MessageType`
--

DROP TABLE IF EXISTS `T_MessageType`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_MessageType` (
  `F_Type` smallint(6) NOT NULL,
  `F_Description` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`F_Type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `T_MessageType`
--

LOCK TABLES `T_MessageType` WRITE;
/*!40000 ALTER TABLE `T_MessageType` DISABLE KEYS */;
INSERT INTO `T_MessageType` VALUES (0,'Internal Clarity messages'),(1,'Subscription reminders'),(2,'Usage statistics'),(3,'Service announcements'),(4,'Support announcements'),(5,'Upgrade announcements'),(6,'Product news');
/*!40000 ALTER TABLE `T_MessageType` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `T_ProductLanguage`
--

DROP TABLE IF EXISTS `T_ProductLanguage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_ProductLanguage` (
  `F_ProductCode` smallint(5) NOT NULL,
  `F_LanguageCode` varchar(16) NOT NULL,
  `F_ContentLocation` varchar(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `T_ProductLanguage`
--

LOCK TABLES `T_ProductLanguage` WRITE;
/*!40000 ALTER TABLE `T_ProductLanguage` DISABLE KEYS */;
INSERT INTO `T_ProductLanguage` VALUES (1,'NAMEN',''),(45,'EN','IssuesInEnglish2-International'),(46,'EN','ConnectedSpeech-International'),(9,'EN','TenseBuster-International'),(9,'NAMEN','TenseBuster-NAmerican'),(10,'EN','BusinessWriting-International'),(10,'NAMEN','BusinessWriting-NAmerican'),(1,'EN',''),(2,'EN',''),(11,'EN','Reactions'),(12,'EN','RoadToIELTS-Academic'),(13,'EN','RoadToIELTS-General'),(3,'EN','StudySkillsSuccess-International'),(3,'NAMEN','StudySkillsSuccess-NAmerican'),(20,'NAMEN','MyCanada'),(21,'NAMEN','MyCanada'),(14,'EN','BULATS'),(15,'EN','GEPT'),(16,'EN','HolisticEnglish'),(17,'NAMEN','LamourDesTemps'),(18,'EN','EU'),(19,'EN','AGU'),(34,'EN','Peacekeeper'),(33,'EN','ActiveReading-International'),(33,'NAMEN','ActiveReading-NAmerican'),(9,'ZHO','TenseBuster-NAmerican'),(36,'EN','ILATest'),(10,'INDEN','BusinessWriting-Indian'),(38,'EN','ItsYourJob'),(38,'NAMEN','ItsYourJob-NAmerican'),(39,'BREN','ClearPronunciation-International'),(1001,'EN','ItsYourJob'),(1001,'NAMEN','ItsYourJob-NAmerican'),(1001,'INDEN','ItsYourJob-Indian'),(37,'INDEN','ClarityEnglishSuccess'),(40,'EN','EnglishForHotelStaff'),(35,'ORIG','CSCS'),(35,'REREC','CSCS'),(41,'EN','SunOnJapanese'),(42,'EN','LanguageKey'),(43,'ORIG','CSCS'),(44,'EN','PracticalPlacementTest'),(45,'NAMEN','IssuesInEnglish2-NAmerican'),(46,'NAMEN','ConnectedSpeech-NAmerican'),(38,'INDEN','ItsYourJob-Indian'),(43,'REREC','CSCS'),(47,'EN','i-Read'),(36,'JP','ILATest-Japanese'),(49,'EN','StudySkillsSuccessV9-International'),(49,'NAMEN','StudySkillsSuccessV9-NAmerican'),(48,'EN','AccessUK'),(46,'AUSEN','ConnectedSpeech-Australian'),(50,'BREN','ClearPronunciation2-International');
/*!40000 ALTER TABLE `T_ProductLanguage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `T_Language`
--

DROP TABLE IF EXISTS `T_Language`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_Language` (
  `F_LanguageCode` varchar(16) NOT NULL,
  `F_Description` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `T_Language`
--

LOCK TABLES `T_Language` WRITE;
/*!40000 ALTER TABLE `T_Language` DISABLE KEYS */;
INSERT INTO `T_Language` VALUES ('BREN','British English'),('AUSEN','Australian English'),('ORIG','Original recordings'),('EN','International English'),('NAMEN','North American English'),('INDEN','Indian English'),('ZHO','简体中文 (Putonghua)'),('TH','ภาษาไทย (Thai)'),('ES','Español (Spanish)'),('CHI','繁體中文 (Cantonese)'),('FR','français (French)'),('MS','Melayu (Malay)'),('SV','Svenska (Swedish)'),('REREC','Clearer recordings');
/*!40000 ALTER TABLE `T_Language` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `T_DatabaseVersion`
--

DROP TABLE IF EXISTS `T_DatabaseVersion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_DatabaseVersion` (
  `F_VersionNumber` int(10) NOT NULL,
  `F_ReleaseDate` datetime NOT NULL,
  `F_Comments` varchar(1024) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `T_DatabaseVersion`
--

LOCK TABLES `T_DatabaseVersion` WRITE;
/*!40000 ALTER TABLE `T_DatabaseVersion` DISABLE KEYS */;
INSERT INTO `T_DatabaseVersion` VALUES (1,'2007-01-01 00:00:00','original'),(2,'2009-01-30 00:00:00','Results Manager V3'),(3,'2009-06-15 00:00:00','To include licence information in Accounts'),(4,'2009-08-06 00:00:00','Optimising indexes'),(5,'2009-10-22 00:00:00','Add T_Score.F_CourseID'),(6,'2011-06-27 00:00:00','Add T_ScoreAnonymous'),(7,'2011-09-01 00:00:00','licence clearance date');
/*!40000 ALTER TABLE `T_DatabaseVersion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `T_Offer`
--

DROP TABLE IF EXISTS `T_Offer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_Offer` (
  `F_OfferID` smallint(5) NOT NULL,
  `F_OfferName` varchar(100) NOT NULL,
  `F_PackageID` smallint(5) NOT NULL,
  `F_Duration` smallint(5) DEFAULT NULL,
  `F_Currency` varchar(3) NOT NULL DEFAULT 'HKD',
  `F_Price` decimal(18,2) NOT NULL DEFAULT '0.00',
  `F_OfferStartDate` datetime DEFAULT NULL,
  `F_OfferEndDate` datetime DEFAULT NULL,
  PRIMARY KEY (`F_OfferID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `T_Offer`
--

LOCK TABLES `T_Offer` WRITE;
/*!40000 ALTER TABLE `T_Offer` DISABLE KEYS */;
INSERT INTO `T_Offer` VALUES (1,'General English 1-year',1,365,'USD',99.99,'2011-05-25 00:00:00',NULL),(2,'General English 3-months',1,92,'USD',29.99,'2011-01-01 00:00:00',NULL),(3,'General English 1-month',1,31,'USD',19.99,'2011-01-01 00:00:00',NULL),(4,'Career English 1-year',2,365,'USD',99.99,'2011-05-25 00:00:00',NULL),(5,'Career English 3-months',2,92,'USD',29.99,'2011-05-25 00:00:00',NULL),(6,'Career English 1-month',2,31,'USD',19.99,'2011-05-25 00:00:00',NULL),(7,'iLearnIELTS Academic',3,122,'GBP',99.99,'2011-05-01 00:00:00','2012-04-30 23:59:59'),(8,'iLearnIELTS General Training',4,122,'GBP',99.99,'2011-05-01 00:00:00',NULL),(9,'General English 1-year SchoolNet',1,365,'HKD',538.00,'2011-05-30 00:00:00',NULL),(10,'Career English 1-year SchoolNet',2,365,'HKD',538.00,'2011-05-30 00:00:00',NULL),(11,'IYJ Bee Crazy June 2011',5,31,'HKD',38.00,'2011-06-01 00:00:00','2011-07-31 00:00:00');
/*!40000 ALTER TABLE `T_Offer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `T_Package`
--

DROP TABLE IF EXISTS `T_Package`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_Package` (
  `F_PackageID` smallint(5) NOT NULL,
  `F_PackageName` varchar(128) NOT NULL,
  PRIMARY KEY (`F_PackageID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `T_Package`
--

LOCK TABLES `T_Package` WRITE;
/*!40000 ALTER TABLE `T_Package` DISABLE KEYS */;
INSERT INTO `T_Package` VALUES (1,'General English for CLS'),(2,'Career English for CLS'),(3,'Road to IELTS Academic for iLearnIELTS'),(4,'Road to IELTS General Training for iLearnIELTS'),(5,'It\'s Your Job');
/*!40000 ALTER TABLE `T_Package` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `T_Product`
--

DROP TABLE IF EXISTS `T_Product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_Product` (
  `F_ProductCode` smallint(5) NOT NULL,
  `F_ProductName` varchar(100) NOT NULL,
  `F_ProductImageURL` varchar(1024) DEFAULT NULL,
  `F_DisplayOrder` smallint(5) DEFAULT NULL,
  UNIQUE KEY `Index_14` (`F_ProductCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `T_Product`
--

LOCK TABLES `T_Product` WRITE;
/*!40000 ALTER TABLE `T_Product` DISABLE KEYS */;
INSERT INTO `T_Product` VALUES (1,'Author Plus',NULL,5),(2,'Results Manager',NULL,0),(3,'Study Skills Success',NULL,7),(9,'Tense Buster',NULL,1),(10,'Business Writing',NULL,6),(11,'Reactions!',NULL,999),(12,'Road to IELTS Academic',NULL,3),(13,'Road to IELTS General Training',NULL,4),(14,'BULATS',NULL,888),(15,'GEPT',NULL,888),(16,'Holistic English',NULL,888),(17,'L\'amour des temps',NULL,50),(18,'EGU',NULL,100),(19,'AGU',NULL,100),(20,'My Canada',NULL,50),(33,'Active Reading',NULL,2),(34,'Peacekeeper',NULL,50),(35,'Call Center Communication Skills',NULL,50),(36,'LearnEnglish Level Test',NULL,50),(37,'Clarity English Success',NULL,50),(38,'It\'s Your Job, Practice Centre',NULL,9),(39,'Clear Pronunciation',NULL,10),(40,'English for Hotel Staff',NULL,11),(41,'Sun On Japanese',NULL,50),(42,'Language Key English Test',NULL,50),(43,'Customer Service Communication Skills',NULL,50),(44,'Practical Placement Test',NULL,13),(45,'Issues in English 2',NULL,20),(46,'Connected Speech',NULL,21),(47,'HCT\'s i-Read',NULL,888),(48,'Access UK',NULL,12),(49,'Study Skills Success V9',NULL,7),(50,'Clear Pronunciation 2',NULL,10),(1001,'It\'s Your Job',NULL,8);
/*!40000 ALTER TABLE `T_Product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `T_AccountStatus`
--

DROP TABLE IF EXISTS `T_AccountStatus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_AccountStatus` (
  `F_Status` int(10) DEFAULT NULL,
  `F_Description` varchar(32) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `T_AccountStatus`
--

LOCK TABLES `T_AccountStatus` WRITE;
/*!40000 ALTER TABLE `T_AccountStatus` DISABLE KEYS */;
INSERT INTO `T_AccountStatus` VALUES (0,'Account created'),(1,'Reviewed and approved'),(2,'Active'),(3,'Suspended'),(4,'xxCustomized'),(5,'xxInternal testing'),(6,'xxTrial'),(7,'xx'),(8,'Account details changed'),(9,'Waiting for T&C to be accepted'),(10,'Changes approved'),(0,'Account created'),(1,'Reviewed and approved'),(2,'Active'),(3,'Suspended'),(4,'xxCustomized'),(5,'xxInternal testing'),(6,'xxTrial'),(7,'xx'),(8,'Account details changed'),(9,'Waiting for T&C to be accepted'),(10,'Changes approved');
/*!40000 ALTER TABLE `T_AccountStatus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `T_LicenceType`
--

DROP TABLE IF EXISTS `T_LicenceType`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_LicenceType` (
  `F_Status` smallint(5) NOT NULL,
  `F_Description` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `T_LicenceType`
--

LOCK TABLES `T_LicenceType` WRITE;
/*!40000 ALTER TABLE `T_LicenceType` DISABLE KEYS */;
INSERT INTO `T_LicenceType` VALUES (1,'Learner Tracking'),(2,'Anonymous Access'),(3,'Network/Concurrent Tracking'),(4,'Single'),(5,'Individual'),(6,'Transferable Tracking');
/*!40000 ALTER TABLE `T_LicenceType` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `T_Triggers`
--

DROP TABLE IF EXISTS `T_Triggers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_Triggers` (
  `F_TriggerID` int(10) NOT NULL,
  `F_Name` varchar(128) DEFAULT NULL,
  `F_RootID` int(10) DEFAULT NULL,
  `F_GroupID` int(10) DEFAULT NULL,
  `F_TemplateID` int(10) NOT NULL,
  `F_Condition` varchar(1024) DEFAULT NULL,
  `F_ValidFromDate` datetime DEFAULT NULL,
  `F_ValidToDate` datetime DEFAULT NULL,
  `F_Executor` varchar(32) DEFAULT NULL,
  `F_Frequency` varchar(50) DEFAULT NULL,
  `F_MessageType` smallint(6) NOT NULL DEFAULT '1',
  PRIMARY KEY (`F_TriggerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `T_Triggers`
--

LOCK TABLES `T_Triggers` WRITE;
/*!40000 ALTER TABLE `T_Triggers` DISABLE KEYS */;
INSERT INTO `T_Triggers` VALUES (1,'Subscription reminder 30 days',NULL,NULL,1,'method=getAccounts&expiryDate={now}+30d&accountType=1&notLicenceType=5',NULL,'2011-07-19 00:00:00','email','daily',1),(2,'Clarity learner motivation',163,10379,10,'method=getUsers&registrationDate={now}-4d&accountType=1','2009-01-01 00:00:00','2009-06-30 00:00:00','email','daily',1),(6,'Subscription reminder 7 days',NULL,NULL,2,'method=getAccounts&expiryDate={now}+7d&accountType=1&notLicenceType=5',NULL,'2011-07-19 00:00:00','email','daily',1),(7,'Subscription reminder 0 days',NULL,NULL,3,'method=getAccounts&expiryDate={now}&accountType=1&notLicenceType=5',NULL,'2011-07-19 00:00:00','email','daily',1),(8,'Subscription expired a week ago',NULL,NULL,4,'method=getAccounts&expiryDate={now}-7d&accountType=1&notLicenceType=5',NULL,'2011-07-19 00:00:00','email','daily',1),(10,'Terms and conditions accepted',NULL,NULL,0,'method=dbChange&select=select F_RootID from T_AccountRoot where F_AccountStatus=3 and F_TermsConditions=2&update=update T_AccountRoot set F_AccountStatus=4 where F_RootID in (select F_RootID from T_AccountRoot where F_AccountStatus=3 and F_TermsConditions=2)',NULL,NULL,'sql','hourly',0),(11,'Trial about to end 1 day',NULL,NULL,5,'method=getAccounts&expiryDate={now}+1d&accountType=2',NULL,'2038-12-31 00:00:00','email','daily',1),(12,'Trial about to end 7 days',NULL,NULL,6,'method=getAccounts&expiryDate={now}+7d&accountType=2',NULL,NULL,'email','daily',1),(14,'Its Your Job. Unit 1 email',NULL,NULL,2131,'method=getAccounts&productCode=1001&userStartDate={now}-1d&contactMethod=email',NULL,'2010-05-01 00:00:00','email','daily',1),(15,'Its Your Job. Unit 2 email',NULL,NULL,2132,'method=getAccounts&productCode=1001&userStartDate={now}-1f&contactMethod=email',NULL,'2010-05-01 00:00:00','email','daily',1),(16,'CLS. Subscription ends in 7 days',NULL,NULL,2129,'method=getAccounts&expiryDate={now}+7d&licenceType=5',NULL,NULL,'email','daily',1),(18,'CLS. Subscription ends today',NULL,NULL,2130,'method=getAccounts&expiryDate={now}&licenceType=5',NULL,NULL,'email','daily',1),(19,'Its Your Job. Unit 3 email',NULL,NULL,2133,'method=getAccounts&productCode=1001&userStartDate={now}-2f&contactMethod=email',NULL,'2010-05-01 00:00:00','email','daily',1),(20,'Its Your Job. Unit 4 email',NULL,NULL,2134,'method=getAccounts&productCode=1001&userStartDate={now}-3f&contactMethod=email',NULL,'2010-05-01 00:00:00','email','daily',1),(21,'Its Your Job. Unit 5 email',NULL,NULL,2135,'method=getAccounts&productCode=1001&userStartDate={now}-4f&contactMethod=email',NULL,'2010-05-01 00:00:00','email','daily',1),(22,'Its Your Job. Unit 6 email',NULL,NULL,2136,'method=getAccounts&productCode=1001&userStartDate={now}-5f&contactMethod=email',NULL,'2010-05-01 00:00:00','email','daily',1),(23,'Its Your Job. Unit 7 email',NULL,NULL,2137,'method=getAccounts&productCode=1001&userStartDate={now}-6f&contactMethod=email',NULL,'2010-05-01 00:00:00','email','daily',1),(24,'Its Your Job. Unit 8 email',NULL,NULL,2138,'method=getAccounts&productCode=1001&userStartDate={now}-7f&contactMethod=email',NULL,'2010-05-01 00:00:00','email','daily',1),(25,'Its Your Job. Unit 9 email',NULL,NULL,2139,'method=getAccounts&productCode=1001&userStartDate={now}-8f&contactMethod=email',NULL,'2010-05-01 00:00:00','email','daily',1),(26,'Its Your Job. Unit 10 email',NULL,NULL,2140,'method=getAccounts&productCode=1001&userStartDate={now}-9f&contactMethod=email',NULL,'2010-05-01 00:00:00','email','daily',1),(30,'Early warning system',NULL,NULL,100,'method=getAccounts',NULL,'2011-07-19 00:00:00','email','weekly',1),(31,'xxMonthly statistics',NULL,NULL,20,'method=getAccounts&notLicenceType=5&accountType=1&active=true&selfHost=false',NULL,'2011-08-29 00:00:00','usageStats','monthly',2),(32,'Subscription reminder start+7',NULL,NULL,32,'method=getAccounts&startDate={now}-7d&accountType=1&notLicenceType=5',NULL,NULL,'email','daily',1),(33,'Subscription reminder usage stats',NULL,NULL,20,'method=getAccounts&startDay={day}&accountType=1&notLicenceType=5&selfHost=false&active=true',NULL,NULL,'usageStats','daily',2),(34,'Subscription reminder start+1.5m',NULL,NULL,34,'method=getAccounts&startDate={now}-1.5m&accountType=1&notLicenceType=5',NULL,NULL,'email','daily',4),(35,'Subscription reminder start+6.5m',NULL,NULL,35,'method=getAccounts&startDate={now}-6.5m&accountType=1&notLicenceType=5','2011-12-31 00:00:00',NULL,'email','daily',4),(36,'Subscription reminder end-2.5m',NULL,NULL,36,'method=getAccounts&expiryDate={now}+10w&accountType=1&notLicenceType=5',NULL,NULL,'email','daily',1),(37,'Create a quotation',NULL,NULL,37,'method=getAccounts&expiryDate={now}+11w&accountType=1&notLicenceType=5',NULL,NULL,'internalEmail','daily',0),(38,'Subscription reminder end-1.5m',NULL,NULL,38,'method=getAccounts&expiryDate={now}+45d&accountType=1&notLicenceType=5',NULL,NULL,'email','daily',1),(39,'Subscription reminder end-2w',NULL,NULL,39,'method=getAccounts&expiryDate={now}+14d&accountType=1&notLicenceType=5',NULL,NULL,'email','daily',1),(40,'Subscription reminder end tomorrow',NULL,NULL,40,'method=getAccounts&expiryDate={now}+1d&accountType=1&notLicenceType=5',NULL,NULL,'email','daily',1),(41,'Subscription reminder end today',NULL,NULL,41,'method=getAccounts&expiryDate={now}&accountType=1&notLicenceType=5',NULL,NULL,'email','daily',1),(42,'Subscription reminder ended',NULL,NULL,42,'method=getAccounts&expiryDate={now}-14d&accountType=1&notLicenceType=5',NULL,NULL,'email','daily',1),(43,'Self-host licence reminder',NULL,NULL,43,'method=getAccounts&expiryDate={now}+1m&accountType=1&notLicenceType=5&selfHost=true',NULL,NULL,'internalEmail','daily',0);
/*!40000 ALTER TABLE `T_Triggers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `T_Reseller`
--

DROP TABLE IF EXISTS `T_Reseller`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_Reseller` (
  `F_ResellerID` int(10) NOT NULL,
  `F_ResellerName` varchar(64) NOT NULL,
  `F_Remark` varchar(128) DEFAULT NULL,
  `F_Email` varchar(64) DEFAULT NULL,
  `F_DisplayOrder` smallint(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `T_Reseller`
--

LOCK TABLES `T_Reseller` WRITE;
/*!40000 ALTER TABLE `T_Reseller` DISABLE KEYS */;
INSERT INTO `T_Reseller` VALUES (0,'Not set',NULL,NULL,300),(1,'Abacus Communications Ltd',NULL,'info@abacus-communications.com',12),(2,'Bookery',NULL,'info@bookery.com.au',6),(3,'Edutech Middle East L.L.C. (Dubai, UAE)',NULL,'subramoni@edutech.com',5),(4,'Falcon Press Sdn Bhd',NULL,NULL,101),(5,'Hans Richter Laromedel',NULL,'post@richbook.se',13),(6,'Mr Kevin Coffey',NULL,'insight@paradise.net.nz',10),(7,'NAS Software Inc',NULL,'sam@nas.ca',4),(8,'Study Plan S.L.',NULL,'stephenbe@studyplan.es',102),(9,'Voice Works International Pte Ltd',NULL,NULL,103),(10,'Win Hoe Company Limited',NULL,'kima@ms14.hinet.net',9),(11,'Young India Films',NULL,'youngindiafilms@airtelbroadband.in,yif@vsnl.com',3),(12,'Clarity in Hong Kong',NULL,'kenix.wong@clarityenglish.com',2),(13,'Clarity direct',NULL,'admin@clarityenglish.com',2),(14,'P.T. Solusi Nusantara',NULL,'ervida@solusi-nusantara.com',8),(15,'Rosanna d o o',NULL,'rossana@t-2.net',104),(16,'Attica S.A.',NULL,'karine.finck@attica.fr',100),(17,'Encomium',NULL,'maryam@encomium.com',14),(18,'Source Learning System (Thailand)',NULL,'udomchai@source.co.th',11),(19,'Lingualearn Ltd',NULL,'mike@lingualearn.com',105),(20,'Lara Kytapcilik','old name for Turkey','administrator@eltturkey.com',200),(21,'Clarity online subscription',NULL,'kenix.wong@clarityenglish.com',22),(22,'Celestron Ltda',NULL,'valdenegro@celestron.cl',16),(23,'Sinirsiz Egitim Hizmetleri','new name for Turkey','administrator@eltturkey.com',17),(24,'Edict Electronics Sdn Bhd',NULL,'mary@edict.com.my',18),(25,'ThirdWave Learning, Inc.',NULL,'geri@thirdwavelearning.com',19),(27,'iLearnIELTS',NULL,'sales@ilearnIELTS.com',16),(28,'Protea Textware',NULL,'orders@proteatextware.com.au',21),(29,'The Learning Institute',NULL,'kiran@the-learninginstitute.com',105),(30,'SchoolNet',NULL,'joe@school.hk',21),(31,'BeeCrazy',NULL,'queenie.lam@clarityenglish.com,kenix.wong@clarityenglish.com',21),(32,'HKA',NULL,'philip.lam@clarityenglish.com,kenix.wong@clarityenglish.com',1),(33,'HKB',NULL,'queenie.lam@clarityenglish.com,kenix.wong@clarityenglish.com',1),(34,'Complejo de Consultoria de Idiomas',NULL,'elizabeth.pena@etciberoamerica.com',99),(35,'Micromail',NULL,'diarmuid@micromail.ie',105);
/*!40000 ALTER TABLE `T_Reseller` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `T_ApprovalStatus`
--

DROP TABLE IF EXISTS `T_ApprovalStatus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_ApprovalStatus` (
  `F_Status` int(10) NOT NULL,
  `F_Description` varchar(32) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `T_ApprovalStatus`
--

LOCK TABLES `T_ApprovalStatus` WRITE;
/*!40000 ALTER TABLE `T_ApprovalStatus` DISABLE KEYS */;
INSERT INTO `T_ApprovalStatus` VALUES (0,'created or edited'),(1,'checked'),(2,'approved'),(3,'corrected after approval'),(0,'created or edited'),(1,'checked'),(2,'approved'),(3,'corrected after approval');
/*!40000 ALTER TABLE `T_ApprovalStatus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `T_TermsConditions`
--

DROP TABLE IF EXISTS `T_TermsConditions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_TermsConditions` (
  `F_Status` int(10) NOT NULL,
  `F_Description` varchar(32) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `T_TermsConditions`
--

LOCK TABLES `T_TermsConditions` WRITE;
/*!40000 ALTER TABLE `T_TermsConditions` DISABLE KEYS */;
INSERT INTO `T_TermsConditions` VALUES (0,'Display'),(1,'Not seen'),(2,'Accepted');
/*!40000 ALTER TABLE `T_TermsConditions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `T_AccountType`
--

DROP TABLE IF EXISTS `T_AccountType`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_AccountType` (
  `F_Type` int(10) NOT NULL,
  `F_Description` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `T_AccountType`
--

LOCK TABLES `T_AccountType` WRITE;
/*!40000 ALTER TABLE `T_AccountType` DISABLE KEYS */;
INSERT INTO `T_AccountType` VALUES (0,'unknown'),(1,'Standard invoice'),(2,'Trial'),(3,'Project'),(4,'Testing'),(5,'Distributor trials'),(0,'unknown'),(1,'Standard invoice'),(2,'Trial'),(3,'Project'),(4,'Testing'),(5,'Distributor trials');
/*!40000 ALTER TABLE `T_AccountType` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-11-01 17:25:34
