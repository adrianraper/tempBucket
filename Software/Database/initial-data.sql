-- MySQL dump 10.13  Distrib 5.1.35, for Win32 (ia32)
--
-- Host: localhost    Database: rack80829_dbo
-- ------------------------------------------------------
-- Server version	5.1.35-community-log

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
-- Dumping data for table `T_AccountStatus`
--

LOCK TABLES `T_AccountStatus` WRITE;
/*!40000 ALTER TABLE `T_AccountStatus` DISABLE KEYS */;
INSERT INTO `T_AccountStatus` VALUES (0,'Account created'),(1,'Reviewed and approved'),(2,'Active'),(3,'Suspended'),(4,'xxCustomized'),(5,'xxInternal testing'),(6,'xxTrial'),(7,'xx'),(8,'Account details changed'),(9,'Waiting for T&C to be accepted'),(10,'Changes approved');
/*!40000 ALTER TABLE `T_AccountStatus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `T_AccountType`
--

LOCK TABLES `T_AccountType` WRITE;
/*!40000 ALTER TABLE `T_AccountType` DISABLE KEYS */;
INSERT INTO `T_AccountType` VALUES (0,'unknown'),(1,'Standard invoice'),(2,'Trial'),(3,'Project'),(4,'Testing'),(5,'Distributor trials');
/*!40000 ALTER TABLE `T_AccountType` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `T_ApprovalStatus`
--

LOCK TABLES `T_ApprovalStatus` WRITE;
/*!40000 ALTER TABLE `T_ApprovalStatus` DISABLE KEYS */;
INSERT INTO `T_ApprovalStatus` VALUES (0,'created or edited'),(1,'checked'),(2,'approved'),(3,'corrected after approval');
/*!40000 ALTER TABLE `T_ApprovalStatus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `T_CourseInfo`
-- This needs to be built dynamically from T_Session

-- LOCK TABLES `T_CourseInfo` WRITE;
-- /*!40000 ALTER TABLE `T_CourseInfo` DISABLE KEYS */;
-- INSERT INTO `T_CourseInfo` VALUES (3,41),(3,42),(9,1189057932446),(9,1189060123431),(9,1190277377521),(9,1195467488046),(9,1196935701119),(10,51),(10,52),(10,53),(12,1144338842079),(12,1150899874890),(12,1150911222467),(12,1150976390861),(12,1151344082236),(12,1151344151924),(12,1151344172852),(12,1151344194684),(12,1151344221441),(12,1151344244788),(12,1151344259872),(12,1151344537052),(20,1127356511328),(20,1127357845125),(20,1127357920687),(20,1127357992828),(20,1127358251078),(20,1127358322000),(20,1127358186968),(20,1127358142750),(20,1127358076687),(20,1127358508000),(20,1127358426968),(20,1127358624812),(11,11),(11,12),(11,13),(11,14),(11,15),(33,1213672591135),(33,1217807117776),(33,1218433706785),(33,1219043007595),(33,1219045749181),(33,1219136121424),(33,1228700161377),(33,1228988755656),(33,1229305896209),(33,1229408000368),(33,1229500467299),(33,1229587840972),(20,1127358683296),(20,1127358567937),(20,1127358963453),(20,1127358755234),(20,1127358808390),(20,1127358876531),(20,1137525264734),(20,1137525265676),(20,1137525265443),(20,1137525265672),(20,1127359053765),(20,1127359133859),(20,1127359180437),(20,1127359225250),(20,1137525536796),(20,1137525590484),(20,1137525618656),(20,1137525649171),(20,1133053264812),(20,1133053294687),(20,1133053352593),(20,1133053395671),(20,1132622834500),(20,1133576095093),(20,1133576276953),(20,1136482003380),(20,1183719181687),(20,1129516169921),(20,1133051480781),(20,1129515616796),(20,1132102976797),(20,1136502031690),(20,1136722025100),(20,1138569217531),(20,1183545571140),(17,1147041259959),(17,1147041957282),(17,1154528766066),(17,1154528833713),(34,1211867131140),(43,1243826029937),(36,1242806791546),(37,1251172005384),(37,1252550696842),(37,1254132089990),(37,1252550696843),(37,1252550696844),(37,1250560407510),(38,1249436487189),(39,1250560407550),(40,1247823480500),(41,1214446640515),(41,1212645282406),(41,1209009058859),(41,1203657785046),(1001,1001),(44,1217822488903),(42,1265270833792),(42,1265277274303),(42,1265277613591),(42,1265277692759),(42,1265277724967),(42,1265277786267),(42,1265277859091),(42,1265277918305),(42,1265277980295),(42,1265278034829);
-- /*!40000 ALTER TABLE `T_CourseInfo` ENABLE KEYS */;
-- UNLOCK TABLES;

--
-- Dumping data for table `T_DatabaseVersion`
--

LOCK TABLES `T_DatabaseVersion` WRITE;
/*!40000 ALTER TABLE `T_DatabaseVersion` DISABLE KEYS */;
INSERT INTO `T_DatabaseVersion` VALUES (1,'2007-01-01 00:00:00','original'),(2,'2009-01-30 00:00:00','Results Manager V3'),(3,'2009-06-15 00:00:00','To include licence information in Accounts'),
(4,'2009-08-06 00:00:00','Optimising indexes'),(5,'2009-10-22 00:00:00','Add T_Score.F_CourseID'),
(6,'2011-06-27 00:00:00','Add T_ScoreAnonymous');
/*!40000 ALTER TABLE `T_DatabaseVersion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `T_Language`
--

LOCK TABLES `T_Language` WRITE;
/*!40000 ALTER TABLE `T_Language` DISABLE KEYS */;
INSERT INTO `T_Language` VALUES ('BREN','British English'),('AUSEN','Australian English'),('ORIG','Original recordings'),('EN','International English'),('NAMEN','North American English'),('INDEN','Indian English'),('ZHO','简体中文 (Putonghua)'),('TH','ภาษาไทย (Thai)'),('ES','Español (Spanish)'),('CHI','繁體中文 (Cantonese)'),('FR','français (French)'),('MS','Melayu (Malay)'),('SV','Svenska (Swedish)'),('REREC','Clearer recordings');
/*!40000 ALTER TABLE `T_Language` ENABLE KEYS */;
UNLOCK TABLES;


--
-- Dumping data for table `T_LicenceType`
--

LOCK TABLES `T_LicenceType` WRITE;
/*!40000 ALTER TABLE `T_LicenceType` DISABLE KEYS */;
INSERT INTO `T_LicenceType` VALUES (1,'Learner Tracking'),(2,'Anonymous Access'),(3,'Network/Concurrent Tracking'),(4,'Single'),(5,'Individual');
/*!40000 ALTER TABLE `T_LicenceType` ENABLE KEYS */;
UNLOCK TABLES;


--
-- Dumping data for table `T_Product`
--

LOCK TABLES `T_Product` WRITE;
/*!40000 ALTER TABLE `T_Product` DISABLE KEYS */;
INSERT INTO `T_Product` VALUES
(1,'Author Plus',NULL,5),
(2,'Results Manager',NULL,0),
(3,'Study Skills Success',NULL,7),
(9,'Tense Buster',NULL,1),
(10,'Business Writing',NULL,6),
(11,'Reactions!',NULL,999),
(12,'Road to IELTS Academic',NULL,3),
(13,'Road to IELTS General Training',NULL,4),
(14,'BULATS',NULL,888),
(15,'GEPT',NULL,888),
(16,'Holistic English',NULL,888),
(17,'L\'amour des temps',NULL,50),
(18,'EGU',NULL,100),
(19,'AGU',NULL,100),
(20,'My Canada',NULL,50),
(33,'Active Reading',NULL,2),
(34,'Peacekeeper',NULL,50),
(35,'Call Center Communication Skills',NULL,50),
(36,'LearnEnglish Level Test',NULL,50),
(37,'Clarity English Success',NULL,50),
(38,'It\'s Your Job, Practice Centre',NULL,9),
(39,'Clear Pronunciation',NULL,10),
(40,'English for Hotel Staff',NULL,11),
(41,'Sun On Japanese',NULL,50),
(42,'Language Key English Test',NULL,50),
(43,'Customer Service Communication Skills',NULL,50),
(44,'Clarity Test',NULL,50),
(45,'Issues in English 2',NULL,20),
(46,'Connected Speech',NULL,21),
(47,'HCT\'s i-Read',NULL,888),
(48,'York project',NULL,50),
(49,'Study Skills Success V9',NULL,7),
(1001,'It\'s Your Job',NULL,8);
/*!40000 ALTER TABLE `T_Product` ENABLE KEYS */;
UNLOCK TABLES;


--
-- Dumping data for table `T_ProductLanguage`
--

LOCK TABLES `T_ProductLanguage` WRITE;
/*!40000 ALTER TABLE `T_ProductLanguage` DISABLE KEYS */;
INSERT INTO `T_ProductLanguage` VALUES (1,'NAMEN',''),(45,'EN','IssuesInEnglish2-International'),(46,'EN','ConnectedSpeech-International'),(9,'EN','TenseBuster-International'),(9,'NAMEN','TenseBuster-NAmerican'),(10,'EN','BusinessWriting-International'),(10,'NAMEN','BusinessWriting-NAmerican'),(1,'EN',''),(2,'EN',''),(11,'EN','Reactions'),(12,'EN','RoadToIELTS-Academic'),(13,'EN','RoadToIELTS-General'),(3,'EN','StudySkillsSuccess-International'),(3,'NAMEN','StudySkillsSuccess-NAmerican'),(20,'NAMEN','MyCanada'),(21,'NAMEN','MyCanada'),(14,'EN','BULATS'),(15,'EN','GEPT'),(16,'EN','HolisticEnglish'),(17,'NAMEN','LamourDesTemps'),(18,'EN','EU'),(19,'EN','AGU'),(34,'EN','Peacekeeper'),(33,'EN','ActiveReading-International'),(33,'NAMEN','ActiveReading-NAmerican'),(9,'ZHO','TenseBuster-NAmerican'),(36,'EN','ILATest'),(10,'INDEN','BusinessWriting-Indian'),(38,'EN','ItsYourJob'),(38,'NAMEN','ItsYourJob-NAmerican'),(39,'BREN','ClearPronunciation-International'),(1001,'EN','ItsYourJob'),(1001,'NAMEN','ItsYourJob-NAmerican'),(1001,'INDEN','ItsYourJob-Indian'),(37,'INDEN','ClarityEnglishSuccess'),(40,'EN','EnglishForHotelStaff'),(35,'ORIG','CSCS'),(35,'REREC','CSCS'),(41,'EN','SunOnJapanese'),(42,'EN','LanguageKey'),
(43,'ORIG','CSCS'),(44,'EN','ClarityTest'),(45,'NAMEN','IssuesInEnglish2-NAmerican'),(46,'NAMEN','ConnectedSpeech-NAmerican'),(38,'INDEN','ItsYourJob-Indian'),(43,'REREC','CSCS'),
(47,'EN','i-Read'),
(36,'JP','ILATest-Japanese'),
(49,'EN','StudySkillsSuccessV9-International'),
(49,'NAMEN','StudySkillsSuccessV9-NAmerican'),
(48,'EN','York');
/*!40000 ALTER TABLE `T_ProductLanguage` ENABLE KEYS */;
UNLOCK TABLES;


--
-- Dumping data for table `T_Reseller`
--

LOCK TABLES `T_Reseller` WRITE;
/*!40000 ALTER TABLE `T_Reseller` DISABLE KEYS */;
INSERT INTO `T_Reseller` VALUES 
(0,'Not set',NULL,NULL,99),(1,'Abacus Communications Ltd',NULL,'info@abacus-communications.com',12),(2,'Bookery',NULL,'rthughes@bookery.com.au',6),(3,'Edutech Middle East L.L.C. (Dubai, UAE)',NULL,'sharadha@edutech.com',5),(4,'Falcon Press Sdn Bhd',NULL,'johannicholson@yahoo.com',101),(5,'Hans Richter Laromedel',NULL,'post@richter.d.se',13),(6,'Mr Kevin Coffey',NULL,'insight@paradise.net.nz',10),(7,'NAS Software Inc',NULL,'sam@nas.ca',4),(8,'Study Plan S.L.',NULL,'stephenbe@studyplan.es',102),(9,'Voice Works International Pte Ltd',NULL,NULL,103),
(10,'Win Hoe Company Limited',NULL,'kima@ms14.hinet.net',9),(11,'Young India Films',NULL,'youngindiafilms@airtelbroadband.in',3),(12,'Clarity in Hong Kong',NULL,NULL,1),(13,'Clarity direct',NULL,NULL,2),(14,'P.T. Solusi Nusantara',NULL,'rvida_lin@yahoo.com',8),(15,'Rosanna d o o',NULL,'rossana@t-2.net',104),(16,'Attica S.A.',NULL,NULL,100),(17,'Encomium',NULL,'lauren@encomium.com',14),(18,'Source Learning System (Thailand)',NULL,'anong@source.co.th',11),(19,'Lingualearn Ltd',NULL,NULL,NULL),(20,'LARA KYTAPCILIK',NULL,'administrator@eltturkey.com',7),
(21,'Clarity online subscription',NULL,'accounts@clarityenglish.com',15),(22,'Celestron Ltda',NULL,NULL,16),(23,'SINIRSIZ EGITIM HIZMETLERI ',NULL,'administrator@eltturkey.com',17),(24,'Edict Electronics Sdn Bhd',NULL,'mary@edict.com.my',18),(25,'ThirdWave Learning, Inc.',NULL,'geri@thirdwavelearning.com',19),
(27,'iLearnIELTS',NULL,'support@ilearnIELTS',16),(28,'Protea Textware',NULL,'orders@proteatextware.com.au',21),(29,'The Learning Institute',NULL,'kiran@the-learninginstitute.com',105),
(30,'SchoolNet',NULL,'Joe Tsui <joe@school.hk>',21),(31,'BeeCrazy',NULL,'queenie.lam@clarityenglish.com',21);
/*!40000 ALTER TABLE `T_Reseller` ENABLE KEYS */;
UNLOCK TABLES;


--
-- Dumping data for table `T_TermsConditions`
--

LOCK TABLES `T_TermsConditions` WRITE;
/*!40000 ALTER TABLE `T_TermsConditions` DISABLE KEYS */;
INSERT INTO `T_TermsConditions` VALUES (0,'Display'),(1,'Not seen'),(2,'Accepted');
/*!40000 ALTER TABLE `T_TermsConditions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `T_User`
--

LOCK TABLES `T_User` WRITE;
/*!40000 ALTER TABLE `T_User` DISABLE KEYS */;
INSERT INTO `T_User` VALUES (1,'DMSAdrian',0,NULL,'dms',NULL,'adrian.raper@clarityenglish.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-1,NULL,NULL,NULL,'2009-03-09 00:01:40.350',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `T_User` ENABLE KEYS */;
UNLOCK TABLES;

-- 
-- Add enough data for one account
--
LOCK TABLES `T_User` WRITE;
/*!40000 ALTER TABLE `T_User` DISABLE KEYS */;
INSERT INTO `T_User` VALUES (2,'Clarity_admin',0,NULL,'clarity88',NULL,'support@clarityenglish.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,2,0,1,NULL,'2011-06-01 00:00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `T_User` ENABLE KEYS */;
UNLOCK TABLES;
LOCK TABLES `T_Membership` WRITE;
/*!40000 ALTER TABLE `T_Membership` DISABLE KEYS */;
INSERT INTO `T_Membership` VALUES (2,1,1);
/*!40000 ALTER TABLE `T_Membership` ENABLE KEYS */;
UNLOCK TABLES;
LOCK TABLES `T_Groupstructure` WRITE;
/*!40000 ALTER TABLE `T_Groupstructure` DISABLE KEYS */;
INSERT INTO `T_Groupstructure` VALUES (1,'Clarity Testing','',1,1,NULL,21,1,1,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `T_Groupstructure` ENABLE KEYS */;
UNLOCK TABLES;
LOCK TABLES `T_AccountRoot` WRITE;
/*!40000 ALTER TABLE `T_AccountRoot` DISABLE KEYS */;
INSERT INTO `T_AccountRoot` VALUES(1,'Clarity Testing Account','clarity','support@clarityenglish.com',NULL,2,2,'INV100',12,1,NULL,1,0,1,1,0,NULL,0);
/*!40000 ALTER TABLE `T_AccountRoot` ENABLE KEYS */;
UNLOCK TABLES;

-- Add 5 rows to [dbo].[T_Package]
LOCK TABLES `T_Package` WRITE;
/*!40000 ALTER TABLE `T_Package` DISABLE KEYS */;
INSERT INTO T_Package VALUES (1, 'General English for CLS'),(2, 'Career English for CLS'),(3, 'Road to IELTS Academic for iLearnIELTS'),(4, 'Road to IELTS General Training for iLearnIELTS'),(5, 'It''s Your Job');
/*!40000 ALTER TABLE `T_Package` ENABLE KEYS */;
UNLOCK TABLES;

-- Add 13 rows to [dbo].[T_PackageContents]
LOCK TABLES `T_PackageContents` WRITE;
/*!40000 ALTER TABLE `T_PackageContents` DISABLE KEYS */;
INSERT INTO T_PackageContents VALUES (1, 9, NULL),(1, 33, NULL),(1, 39, NULL),(1, 49, NULL),(2, 10, NULL),(2, 38, NULL),(2, 40, NULL),(2, 43, NULL),(2, 1001, NULL),(3, 12, NULL),(4, 13, NULL),(5, 38, NULL),(5, 1001, NULL);
/*!40000 ALTER TABLE `T_PackageContents` ENABLE KEYS */;
UNLOCK TABLES;

-- Add 11 rows to [dbo].[T_Offer]
LOCK TABLES `T_Offer` WRITE;
/*!40000 ALTER TABLE `T_Offer` DISABLE KEYS */;
INSERT INTO T_Offer VALUES (1, 'General English 1-year', 1, 365, 'USD', 99.99, '2011-05-25 00:00:00.000', NULL)
,(2, 'General English 3-months', 1, 92, 'USD', 29.99, '2011-01-01 00:00:00.000', NULL)
,(3, 'General English 1-month', 1, 31, 'USD', 19.99, '2011-01-01 00:00:00.000', NULL)
,(4, 'Career English 1-year', 2, 365, 'USD', 99.99, '2011-05-25 00:00:00.000', NULL)
,(5, 'Career English 3-months', 2, 92, 'USD', 29.99, '2011-05-25 00:00:00.000', NULL)
,(6, 'Career English 1-month', 2, 31, 'USD', 19.99, '2011-05-25 00:00:00.000', NULL)
,(7, 'iLearnIELTS Academic', 3, 122, 'GBP', 99.99, '2011-05-01 00:00:00.000', '2012-04-30 23:59:59.000')
,(8, 'iLearnIELTS General Training', 4, 122, 'GBP', 99.99, '2011-05-01 00:00:00.000', NULL)
,(9, 'General English 1-year SchoolNet', 1, 365, 'HKD', 538.00, '2011-05-30 00:00:00.000', NULL)
,(10, 'Career English 1-year SchoolNet', 2, 365, 'HKD', 538.00, '2011-05-30 00:00:00.000', NULL)
,(11, 'IYJ Bee Crazy June 2011', 5, 31, 'HKD', 38.00, '2011-06-01 00:00:00.000', '2011-07-31 00:00:00.000');
/*!40000 ALTER TABLE `T_Offer` ENABLE KEYS */;
UNLOCK TABLES;

-- ----------------------------------------------------------------------
-- SQL data bulk transfer script generated by the MySQL Migration Toolkit
-- ----------------------------------------------------------------------

-- Disable foreign key checks
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

INSERT INTO `T_Triggers`(`F_TriggerID`, `F_Name`, `F_RootID`, `F_GroupID`, `F_TemplateID`, `F_Condition`, `F_ValidFromDate`, `F_ValidToDate`, `F_Executor`, `F_Frequency`)
VALUES (1, 'Subscription reminder 30 days', NULL, NULL, 1, 'method=getAccounts&expiryDate={now}+30d&accountType=1&notLicenceType=5', NULL, NULL, 'email', 'daily'),
  (2, 'Clarity learner motivation', 163, 10379, 10, 'method=getUsers&registrationDate={now}-4d&accountType=1', '2009-01-01 00:00:00', '2009-06-30 00:00:00', 'email', 'daily'),
  (6, 'Subscription reminder 7 days', NULL, NULL, 2, 'method=getAccounts&expiryDate={now}+7d&accountType=1&notLicenceType=5', NULL, NULL, 'email', 'daily'),
  (7, 'Subscription reminder 0 days', NULL, NULL, 3, 'method=getAccounts&expiryDate={now}&accountType=1&notLicenceType=5', NULL, NULL, 'email', 'daily'),
  (8, 'Subscription expired a week ago', NULL, NULL, 4, 'method=getAccounts&expiryDate={now}-7d&accountType=1&notLicenceType=5', NULL, NULL, 'email', 'daily'),
  (10, 'Terms and conditions accepted', NULL, NULL, 0, 'method=dbChange&select=select F_RootID from T_AccountRoot where F_AccountStatus=3 and F_TermsConditions=2&update=update T_AccountRoot set F_AccountStatus=4 where F_RootID in (select F_RootID from T_AccountRoot where F_AccountStatus=3 and F_TermsConditions=2)', NULL, NULL, 'sql', 'hourly'),
  (11, 'Trial about to end 1 day', NULL, NULL, 5, 'method=getAccounts&expiryDate={now}+1d&accountType=2', NULL, '2038-12-31 00:00:00', 'email', 'daily'),
  (12, 'Trial about to end 7 days', NULL, NULL, 6, 'method=getAccounts&expiryDate={now}+7d&accountType=2', NULL, NULL, 'email', 'daily'),
  (14, 'Its Your Job. Unit 1 email', NULL, NULL, 2131, 'method=getAccounts&productCode=1001&userStartDate={now}-1d&contactMethod=email', NULL, '2010-05-01 00:00:00', 'email', 'daily'),
  (15, 'Its Your Job. Unit 2 email', NULL, NULL, 2132, 'method=getAccounts&productCode=1001&userStartDate={now}-1f&contactMethod=email', NULL, '2010-05-01 00:00:00', 'email', 'daily'),
  (16, 'CLS. Subscription ends in 7 days', NULL, NULL, 2129, 'method=getAccounts&expiryDate={now}+7d&licenceType=5', NULL, NULL, 'email', 'daily'),
  (18, 'CLS. Subscription ends today', NULL, NULL, 2130, 'method=getAccounts&expiryDate={now}&licenceType=5', NULL, NULL, 'email', 'daily'),
  (19, 'Its Your Job. Unit 3 email', NULL, NULL, 2133, 'method=getAccounts&productCode=1001&userStartDate={now}-2f&contactMethod=email', NULL, '2010-05-01 00:00:00', 'email', 'daily'),
  (20, 'Its Your Job. Unit 4 email', NULL, NULL, 2134, 'method=getAccounts&productCode=1001&userStartDate={now}-3f&contactMethod=email', NULL, '2010-05-01 00:00:00', 'email', 'daily'),
  (21, 'Its Your Job. Unit 5 email', NULL, NULL, 2135, 'method=getAccounts&productCode=1001&userStartDate={now}-4f&contactMethod=email', NULL, '2010-05-01 00:00:00', 'email', 'daily'),
  (22, 'Its Your Job. Unit 6 email', NULL, NULL, 2136, 'method=getAccounts&productCode=1001&userStartDate={now}-5f&contactMethod=email', NULL, '2010-05-01 00:00:00', 'email', 'daily'),
  (23, 'Its Your Job. Unit 7 email', NULL, NULL, 2137, 'method=getAccounts&productCode=1001&userStartDate={now}-6f&contactMethod=email', NULL, '2010-05-01 00:00:00', 'email', 'daily'),
  (24, 'Its Your Job. Unit 8 email', NULL, NULL, 2138, 'method=getAccounts&productCode=1001&userStartDate={now}-7f&contactMethod=email', NULL, '2010-05-01 00:00:00', 'email', 'daily'),
  (25, 'Its Your Job. Unit 9 email', NULL, NULL, 2139, 'method=getAccounts&productCode=1001&userStartDate={now}-8f&contactMethod=email', NULL, '2010-05-01 00:00:00', 'email', 'daily'),
  (26, 'Its Your Job. Unit 10 email', NULL, NULL, 2140, 'method=getAccounts&productCode=1001&userStartDate={now}-9f&contactMethod=email', NULL, '2010-05-01 00:00:00', 'email', 'daily'),
  (30, 'Early warning system', NULL, NULL, 100, 'method=getAccounts', NULL, NULL, 'email', 'weekly'),
  (31, 'Monthly statistics', NULL, NULL, 20, 'method=getAccounts&notLicenceType=5&accountType=1&active=true&selfHost=false', NULL, NULL, 'usageStats', 'monthly');

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;

-- End of script


/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-05-05  7:35:18

