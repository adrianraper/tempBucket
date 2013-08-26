--
-- This file should list all changes made to the database after it went live
--

-- 11 July 2011
-- Add ConnectedSpeech Australian English
INSERT INTO `T_ProductLanguage` VALUES (46,'AUSEN','ConnectedSpeech-Australian');

-- 11 July 2011
-- Add ClearPronunciation2 and Access UK products
INSERT INTO `T_Product` VALUES
(50,'Clear Pronunciation 2',NULL,10),
(48,'Access UK',NULL,12);
INSERT INTO `T_ProductLanguage` VALUES 
(50,'BREN','ClearPronunciation2-International'),
(48,'EN','AccessUK');
-- OR
INSERT INTO `T_Product` VALUES
(50,'Clear Pronunciation 2',NULL,10);
INSERT INTO `T_ProductLanguage` VALUES 
(50,'BREN','ClearPronunciation2-International');

UPDATE `T_Product` SET F_ProductName='Access UK' WHERE F_ProductCode=48;
UPDATE `T_Product` SET F_DisplayOrder=12 WHERE F_ProductCode=48;

-- just in case
update T_ProductLanguage
set F_ContentLocation = 'ClearPronunciation2-International'
where F_ProductCode=50 
and F_LanguageCode='EN';
update T_ProductLanguage
set F_ContentLocation = 'AccessUK'
where F_ProductCode=48 
and F_LanguageCode='EN';

-- Implemented on RDS on 28th July 2011
-- 20 July 2011
ALTER TABLE `rack80829`.`T_Triggers` ADD COLUMN `F_MessageType` SMALLINT NOT NULL  DEFAULT '1' AFTER `F_Frequency` ;

-- 17 July 2011
INSERT INTO `rack80829`.`T_Triggers`
(`F_TriggerID`,`F_Name`,`F_RootID`,`F_GroupID`,`F_TemplateID`,`F_Condition`,`F_ValidFromDate`,`F_ValidToDate`,`F_Executor`,`F_Frequency`,`F_MessageType`)
VALUES
(32,'Subscription reminder start+7d',null,null,32,'method=getAccounts&startDate={now}-7d&accountType=1&notLicenceType=5',null,null,'email','daily',1),
(33,'Subscription reminder usage stats',null,null,20,'method=getAccounts&startDay={day}&accountType=1&notLicenceType=5&selfHost=false&active=true&optOutEmails=false',null,null,'usageStats','daily',2),
(34,'Support start+1.5m',null,null,34,'method=getAccounts&startDate={now}-1.5m&accountType=1&notLicenceType=5',null,null,'email','daily',4),
(35,'Support start+6.5m',null,null,35,'method=getAccounts&startDate={now}-6.5m&accountType=1&notLicenceType=5','2011-12-31',null,'email','daily',4),
(36,'Subscription reminder end-2.5m',null,null,36,'method=getAccounts&expiryDate={now}+10w&accountType=1&notLicenceType=5',null,null,'email','daily',1),
(37,'Create a quotation',null,null,37,'method=getAccounts&expiryDate={now}+11w&accountType=1&notLicenceType=5',null,null,'internalEmail','daily',0),
(38,'Subscription reminder end-1.5m',null,null,38,'method=getAccounts&expiryDate={now}+45d&accountType=1&notLicenceType=5',null,null,'email','daily',1),
(39,'Subscription reminder end-2w',null,null,39,'method=getAccounts&expiryDate={now}+14d&accountType=1&notLicenceType=5',null,null,'email','daily',1),
(40,'Subscription reminder end tomorrow',null,null,40,'method=getAccounts&expiryDate={now}+1d&accountType=1&notLicenceType=5',null,null,'email','daily',1),
(41,'Subscription reminder end today',null,null,41,'method=getAccounts&expiryDate={now}&accountType=1&notLicenceType=5',null,null,'email','daily',1),
(42,'Subscription reminder ended',null,null,42,'method=getAccounts&expiryDate={now}-14d&accountType=1&notLicenceType=5',null,null,'email','daily',1);

UPDATE `rack80829`.`T_Triggers` SET `F_ValidToDate`='2011-07-19' WHERE F_TriggerID in (1,6,7,8,30);
UPDATE `rack80829`.`T_Triggers` SET F_Name='xxMonthly statistics' WHERE F_TriggerID=31;

DROP TABLE IF EXISTS `rack80829`.`T_MessageType`;
CREATE  TABLE `rack80829`.`T_MessageType` (
  `F_Type` SMALLINT NOT NULL ,
  `F_Description` VARCHAR(45) NULL ,
  PRIMARY KEY (`F_Type`) );
INSERT INTO `rack80829`.`T_MessageType`
(`F_Type`,`F_Description`)
VALUES
(1,'Subscription reminders'),
(2,'Usage statistics'),
(3,'Service announcements'),
(4,'Support announcements'),
(5,'Upgrade announcements'),
(6,'Product news'),
(0,'Internal Clarity messages');

DROP TABLE IF EXISTS `rack80829`.`T_AccountEmails`;
CREATE  TABLE `rack80829`.`T_AccountEmails` (
  `F_RootID` INT NOT NULL ,
  `F_Email` VARCHAR(256) NULL ,
  `F_MessageType` SMALLINT UNSIGNED NULL DEFAULT 1 ,
  `F_AdminUser` TINYINT(1) UNSIGNED NULL DEFAULT 0 ,
  INDEX `Index_1` (`F_RootID` ASC) );
  
-- Every account will get at least one record in here, tied to the admin user email, with F_MessageType initially set to 31
INSERT INTO T_AccountEmails
SELECT r.F_RootID, null, '31', '1'
FROM T_AccountRoot r, T_User u
WHERE r.F_AdminUserID = u.F_UserID;
-- Probably also see if T_AccountRoot.F_Email is set, and, if different, add that to the above table
INSERT INTO T_AccountEmails
SELECT r.F_RootID, r.F_Email, '31', '0'
FROM T_AccountRoot r, T_User u
WHERE r.F_AdminUserID = u.F_UserID
AND u.F_Email != r.F_Email
AND r.F_Email is not null
and r.F_Email !='';
-- This ends up with too many, so take out the common ones that are resellers (or us)
delete from T_AccountEmails
where F_Email in ('subramoni@edutech.com','sam@nas.ca','info@bookery.com.au','anong@source.co.th','insight@paradise.net.nz','stephenbe@studyplan.es','post@richter.d.se','sharadha@edutech.com',
'info@clarityenglish.com','accounts@clarityenglish.com','kima@ms14.hinet.net','info@source.co.th','ali.uzunyolcu@eltturkey.com','mary@edict.com.my')
and F_AdminUser=0;

-- To allow blocking of subscription reminders to be time limited. In the end it should be T_Accounts rather than T_AccountRoot, though unlikely to actually matter much.
ALTER TABLE `rack80829`.`T_AccountRoot` ADD COLUMN `F_OptOutEmailDate` DATETIME NULL  AFTER `F_OptOutEmails` ;
ALTER TABLE `GlobalRoadToIELTS`.`T_AccountRoot` ADD COLUMN `F_OptOutEmailDate` DATETIME NULL  AFTER `F_OptOutEmails` ;

-- Add new licence type for 'Transfer Tracking'
INSERT INTO `T_LicenceType` VALUES (6,'Transferable Tracking');

-- Remove the T_AccountRoot.F_Email at some point. For now disable it in DMS
--UPDATE T_AccountRoot SET F_Email = NULL;
-- You can't do this as Rickson's login pages use F_Email.
-- ALTER TABLE `rack80829`.`T_AccountRoot` ADD COLUMN `F_Email` VARCHAR(256) NULL AFTER `F_Prefix` ;
-- ALTER TABLE `rack80829`.`T_AccountRoot` DROP COLUMN `F_Email` ;

-- Check that T_AccountType is not doubled up
DROP TABLE IF EXISTS `T_AccountType`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_AccountType` (
  `F_Type` int(10) NOT NULL,
  `F_Description` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
INSERT INTO `T_AccountType` VALUES (0,'unknown'),(1,'Standard invoice'),(2,'Trial'),(3,'Project'),(4,'Testing'),(5,'Distributor trials');

-- Correcting reseller details
DELETE FROM T_Reseller;
INSERT INTO `T_Reseller` (`F_ResellerID`,`F_ResellerName`,`F_Remark`,`F_Email`,`F_DisplayOrder`) VALUES 
(0,'Not set',NULL,NULL,300),
(1,'Abacus Communications Ltd',NULL,'info@abacus-communications.com',12),
(2,'Bookery',NULL,'markus@bookery.com.au,info@bookery.com.au',6),
(3,'Edutech Middle East',NULL,'sales@clarityenglish.com,adrian.raper@clarityenglish.com',106),
(4,'Falcon Press Sdn Bhd',NULL,NULL,101),
(5,'Hans Richter Laromedel',NULL,'post@richbook.se',13),
(6,'Mr Kevin Coffey',NULL,'insight@paradise.net.nz',102),
(7,'NAS Software Inc',NULL,'sam@nas.ca',4),
(8,'Study Plan S.L.',NULL,'stephenbe@studyplan.es',102),
(9,'Voice Works International Pte Ltd',NULL,NULL,103),
(10,'Win Hoe Company Limited',NULL,'kima@ms14.hinet.net,kima.huang@msa.hinet.net',9),
(11,'Young India Films',NULL,'info@youngindiafilms.in',3),
(12,'Clarity in Hong Kong',NULL,'sales@clarityenglish.com',2),
(13,'Clarity direct',NULL,'sales@clarityenglish.com',2),
(14,'P.T. Solusi Nusantara',NULL,'ervida@solusieducationaltechnology.com',8),
(15,'Rosanna d o o',NULL,'rossana@t-2.net',104),
(16,'Attica S.A.',NULL,'karine.finck@attica.fr',100),
(17,'Encomium',NULL,'maryam@encomium.com',14),
(18,'Source Learning System (Thailand)',NULL,'udomchai@source.co.th',11),
(19,'Lingualearn Ltd',NULL,'mike@lingualearn.com',105),
(20,'Lara Kytapcilik','old name for Turkey','administrator@eltturkey.com',200),
(21,'Clarity online subscription',NULL,'cynthia.lau@clarityenglish.com',20),
(22,'Celestron Ltda',NULL,'valdenegro@celestron.cl',16),
(23,'Sinirsiz Egitim Hizmetleri','new name for Turkey','administrator@eltturkey.com',17),
(24,'Edict Electronics Sdn Bhd',NULL,'mary@edict.com.my',18),
(25,'ThirdWave Learning, Inc.',NULL,'geri@thirdwavelearning.com',19),
(27,'iLearnIELTS',NULL,'sales@ilearnIELTS.com',16),
(28,'Protea Textware',NULL,'orders@proteatextware.com.au',21),
(29,'The Learning Institute',NULL,'kiran@the-learninginstitute.com',105),
(30,'SchoolNet',NULL,'joe@school.hk',21),
(31,'BeeCrazy',NULL,'sales@clarityenglish.com',21),
(32,'HKA',NULL,'cynthia.lau@clarityenglish.com',1),
(33,'HKB',NULL,'cynthia.lau@clarityenglish.com',1),
(34,'Complejo de Consultoria de Idiomas',NULL,'elizabeth.pena@etciberoamerica.com',99),
(35,'Micromail',NULL,'diarmuid@micromail.ie',105),
(36,'IELTSPractice.com',NULL,'cynthia.lau@clarityenglish.com',20),
(37,'Vietnam Book Promotion Service',NULL,'thao@vietnambookpromotion.com',19),
(38,'Subramoni Iyer (Qatar)',NULL,'subramoni.iyer@lesolonline.com,subramoni.iyer@windowslive.com',7);

-- No more monthly usage stats
UPDATE `rack80829`.`T_Triggers` SET `F_ValidToDate`='2011-08-29' WHERE F_TriggerID in (31);

-- Don't enable questionnaire email yet
UPDATE T_Triggers SET F_ValidFromDate='2011-12-31' WHERE F_TriggerID=35;

DROP TABLE IF EXISTS `T_CcbSchedule`;
/*
CREATE TABLE `T_CcbSchedule` (
  `F_SID` bigint(20) NOT NULL AUTO_INCREMENT,
  `F_GroupID` int(10) NOT NULL,
  `F_CourseID` bigint(20) NOT NULL,
  `F_UnitID` bigint(20) NOT NULL,
  `F_StartDate` datetime DEFAULT NULL,
  `F_EndDate` datetime DEFAULT NULL,
  `F_Period` tinyint(4) DEFAULT '7',
  `F_ShowPast` tinyint(4) DEFAULT '1',
  `F_Enabled` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`F_SID`)
)
*/
INSERT INTO `rack80829`.`T_Triggers`
(`F_TriggerID`,`F_Name`,`F_RootID`,`F_GroupID`,`F_TemplateID`,`F_Condition`,`F_ValidFromDate`,`F_ValidToDate`,`F_Executor`,`F_Frequency`,`F_MessageType`)
VALUES
(43,'Self-host licence reminder',null,null,43,'method=getAccounts&expiryDate={now}+1m&accountType=1&notLicenceType=5&selfHost=true',null,null,'internalEmail','daily',0);

UPDATE T_Triggers
SET F_Condition = 'method=getAccounts&expiryDate={now}+1m&accountType=1&notLicenceType=5&selfHost=true'
WHERE F_TriggerID=43;

-- Just for LearnEnglishTest - BC Rackspace server
INSERT INTO `T_Language` VALUES ('LET-A','LearnEnglishTest-A'),('LET-B','LearnEnglishTest-B'),('LET-C','LearnEnglishTest-C');
INSERT INTO `T_ProductLanguage` VALUES (36,'LET-A','LearnEnglishTest-A'),(36,'LET-B','LearnEnglishTest-B'),(36,'LET-C','LearnEnglishTest-C');

-- Adding licence clearance date
ALTER TABLE `rack80829`.`T_Accounts` ADD COLUMN `F_LicenceClearanceDate` DATETIME NULL DEFAULT NULL  AFTER `F_DeliveryFrequency`;
ALTER TABLE `rack80829`.`T_Accounts` ADD COLUMN `F_LicenceClearanceFrequency` VARCHAR(16) NULL DEFAULT NULL  AFTER `F_LicenceClearanceDate`;
INSERT INTO `T_DatabaseVersion` VALUES (7,'2011-09-01 00:00:00','licence clearance date');

-- Practical Placement test
UPDATE `T_Product` SET F_ProductName='Practical Placement Test' WHERE F_ProductCode=44;
UPDATE `T_ProductLanguage` SET F_ContentLocation='PracticalPlacementTest' WHERE F_ProductCode=44;
UPDATE `T_Product` SET F_DisplayOrder=13 WHERE F_ProductCode=44;

-- CLS for Edict
DELETE from T_Package WHERE F_PackageID in (6,7);
INSERT INTO T_Package VALUES 
(6, 'Tense Buster'),
(7, 'Active Reading'),
(8, 'Clear Pronunciation Pack'),
(9, 'Study Skills Success'),
(10, 'Road to IELTS Academic'),
(11, 'Tense Buster Pack 1'),
(12, 'Clear Pronunciation 1'),
(13, 'Active Reading Pack 1'),
(14, 'Edict Pack 1'),
(15, 'Tense Buster Pack 2'),
(16, 'Clear Pronunciation 2'),
(17, 'Active Reading Pack 2'),
(18, 'Edict Pack 2');

ALTER TABLE `rack80829`.`T_PackageContents` 
DROP PRIMARY KEY 
, ADD PRIMARY KEY (`F_PackageID`, `F_ProductCode`, `F_CourseID`) ;

DELETE from T_PackageContents;
ALTER TABLE `rack80829`.`T_PackageContents` CHANGE COLUMN `F_CourseID` `F_CourseID` BIGINT(19) NOT NULL DEFAULT 0  
, DROP PRIMARY KEY 
, ADD PRIMARY KEY (`F_PackageID`, `F_ProductCode`, `F_CourseID`) ;
INSERT INTO T_PackageContents VALUES 
(1,9,0),
(1,33,0),
(1,39,0),
(1,49,0),
(2,10,0),
(2,38,0),
(2,40,0),
(2,43,0),
(2,1001,0),
(3,12,0),
(4,13,0),
(5,38,0),
(5,1001,0);
INSERT INTO T_PackageContents VALUES 
(6, 9, 0),
(7, 33, 0),
(8, 39, 0),
(8, 50, 0),
(9, 49, 0),
(10, 12, 0),
(11, 9, 1189057932446),
(11, 9, 1189060123431),
(11, 9, 1195467488046),
(12, 39, 0),
(13, 33, 1213672591135),
(13, 33, 1217807117776),
(13, 33, 1218433706785),
(14, 9, 1189057932446),
(14, 9, 1189060123431),
(14, 9, 1195467488046),
(14, 39, 0),
(14, 33, 1213672591135),
(14, 33, 1217807117776),
(14, 33, 1218433706785),
(15, 9, 1195467488046),
(15, 9, 1190277377521),
(15, 9, 1196935701119),
(16, 50, 0),
(17, 33, 1219043007595),
(17, 33, 1219045749181),
(17, 33, 1219136121424),
(18, 9, 1195467488046),
(18, 9, 1190277377521),
(18, 9, 1196935701119),
(18, 50, 0),
(18, 33, 1219043007595),
(18, 33, 1219045749181),
(18, 33, 1219136121424);

INSERT INTO T_Offer VALUES 
(20, 'Tense Buster Pack 1 3-months', 11, 92, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(21, 'Tense Buster Pack 1 6-months', 11, 183, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(22, 'Tense Buster Pack 1 12-months', 11, 365, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(23, 'Clear Pronunciation 1 3-months', 12, 92, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(24, 'Clear Pronunciation 1 6-months', 12, 183, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(25, 'Clear Pronunciation 1 12-months', 12, 365, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(26, 'Active Reading Pack 1 3-months', 13, 92, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(27, 'Active Reading Pack 1 6-months', 13, 183, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(28, 'Active Reading Pack 1 12-months', 13, 365, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(29, 'Edict Pack 1 3-months', 14, 92, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(30, 'Edict Pack 1 6-months', 14, 183, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(31, 'Edict Pack 1 12-months', 14, 365, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 

(32, 'Tense Buster Pack 2 3-months', 15, 92, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(33, 'Tense Buster Pack 2 6-months', 15, 183, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(34, 'Tense Buster Pack 2 12-months', 15, 365, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(35, 'Clear Pronunciation 2 3-months', 16, 92, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(36, 'Clear Pronunciation 2 6-months', 16, 183, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(37, 'Clear Pronunciation 2 12-months', 16, 365, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(38, 'Active Reading Pack 2 3-months', 17, 92, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(39, 'Active Reading Pack 2 6-months', 17, 183, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(40, 'Active Reading Pack 2 12-months', 17, 365, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(41, 'Edict Pack 2 3-months', 18, 92, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(42, 'Edict Pack 2 6-months', 18, 183, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(43, 'Edict Pack 2 12-months', 18, 365, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 

(44, 'Tense Buster Compilation 3-months', 6, 92, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(45, 'Tense Buster Compilation 6-months', 6, 183, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(46, 'Tense Buster Compilation 12-months', 6, 365, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(47, 'Active Reading Compilation 3-months', 7, 92, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(48, 'Active Reading Compilation 6-months', 7, 183, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(49, 'Active Reading Compilation 12-months', 7, 365, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(50, 'Clear Pronunciation Compilation 3-months', 8, 92, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(51, 'Clear Pronunciation Compilation 6-months', 8, 183, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(52, 'Clear Pronunciation Compilation 12-months', 8, 365, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(53, 'Study Skills Success 3-months', 9, 92, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(54, 'Study Skills Success 6-months', 9, 183, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(55, 'Study Skills Success 12-months', 9, 365, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(56, 'Road to IELTS Academic 3-months', 10, 92, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(57, 'Road to IELTS Academic 6-months', 10, 183, 'MYR', 75, '2011-10-14 00:00:00.000', NULL), 
(58, 'Road to IELTS Academic 12-months', 10, 365, 'MYR', 75, '2011-10-14 00:00:00.000', NULL);

-- BUG: Usage stats had been set to trigger on startDate instead of startDay, and for old accounts too
-- see later

-- For storing everyone summary values
DROP TABLE IF EXISTS `rack80829`.`T_ScoreCache`;
CREATE TABLE `T_ScoreCache` (
  `F_CacheID` int(11) NOT NULL AUTO_INCREMENT,
  `F_ProductCode` SMALLINT NOT NULL,
  `F_CourseID` bigint(20) NOT NULL,
  `F_AverageScore` SMALLINT unsigned NOT NULL DEFAULT '0',
  `F_AverageDuration` INT unsigned NOT NULL DEFAULT '0',
  `F_Count` INT unsigned NOT NULL DEFAULT '0',
  `F_DateStamp` datetime DEFAULT NULL,
  `F_Country` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`F_CacheID`)
) AUTO_INCREMENT=19;

-- For occasionally calculating everyone's summary values
INSERT INTO T_ScoreCache (F_ProductCode, F_CourseID, F_AverageScore, F_AverageDuration, F_Count, F_DateStamp, F_Country)
SELECT F_ProductCode, F_CourseID, ROUND(AVG(IF(F_Score<0, NULL, F_Score))) as score, ROUND(AVG(F_Duration)) as duration, 
	COUNT(*) as count, NOW(), 'Worldwide' 
FROM T_Score
WHERE F_ProductCode in (52,53)
GROUP BY F_ProductCode, F_CourseID
ORDER BY F_CourseID;

-- For score records that are coverage rather than score. Note that this is REALLY expensive on production database. Are you sure? NO
-- ALTER TABLE `rack80829`.`T_Score` ADD COLUMN `F_Coverage` SMALLINT NULL  AFTER `F_ProductCode`;
-- ALTER TABLE `rack80829`.`T_ScoreAnonymous` ADD COLUMN `F_Coverage` SMALLINT NULL  AFTER `F_ProductCode`;
-- THINK. Should F_Score, F_Correct, F_Wrong, F_Skipped be smaller data types? Yes they should. And try to avoid varchar, but only if you can do it for the whole table.
-- Whilst TINYINT should be enough since the values are -1 to 100, might be safer to go for SMALLINT just in case.

-- For running daily SQL stored procedures
-- NOT implemented yet
DELETE FROM `rack80829`.`T_Triggers`
WHERE F_TriggerID = 44;
INSERT INTO `rack80829`.`T_Triggers`
(`F_TriggerID`,`F_Name`,`F_RootID`,`F_GroupID`,`F_TemplateID`,`F_Condition`,`F_ValidFromDate`,`F_ValidToDate`,`F_Executor`,`F_Frequency`,`F_MessageType`)
VALUES
(44,'Daily GlobalRoadToIELTS archive expired users',null,null,0,'method=dbChange&select=SELECT * FROM T_AccountRoot where F_RootID=163&update=CALL archiveExpiredUsers()',null,'2012-01-01','SQL','daily',0);

-- Learn English Test Japanese
INSERT INTO `T_Language` VALUES ('JP','日本人 (Japanese)');
INSERT INTO T_ProductLanguage VAUES (36, 'JP', 'ILATest-Japanese');

-- 3 Jan 2012
-- Tidy up triggers
DELETE FROM `rack80829`.`T_Triggers`
WHERE F_TriggerID in (34,35);
INSERT INTO `rack80829`.`T_Triggers`
(`F_TriggerID`,`F_Name`,`F_RootID`,`F_GroupID`,`F_TemplateID`,`F_Condition`,`F_ValidFromDate`,`F_ValidToDate`,`F_Executor`,`F_Frequency`,`F_MessageType`)
VALUES
(34,'Support start+1.5m',null,null,34,'method=getAccounts&startDate={now}-1.5m&accountType=1&notLicenceType=5&active=true',null,null,'email','daily',4),
(35,'Support start+6.5m',null,null,35,'method=getAccounts&startDate={now}-6.5m&accountType=1&notLicenceType=5&active=true','2011-12-31',null,'email','daily',4);

-- Remove duplicates
DELETE FROM `rack80829`.`T_AccountStatus`;
INSERT INTO `T_AccountStatus` (`F_Status`,`F_Description`) 
VALUES 
(0,'Account created'),
(1,'Reviewed and approved'),
(2,'Active'),
(3,'Suspended'),
(4,'xxCustomized'),
(5,'xxInternal testing'),
(6,'xxTrial'),
(7,'xx'),
(8,'Account details changed'),
(9,'Waiting for T&C to be accepted'),
(10,'Changes approved');

-- 5 Jan 2012
-- Licence control
-- This will NOT be used
DROP TABLE IF EXISTS `T_LicenceControl`;
CREATE TABLE `T_LicenceControl` (
  `F_LicenceID` int(11) NOT NULL AUTO_INCREMENT,
  `F_ProductCode` smallint(5) NOT NULL,
  `F_RootID` int(11) NOT NULL,
  `F_UserID` int(11) NOT NULL,
  `F_LastUpdateTime` datetime DEFAULT NULL,
  PRIMARY KEY (`F_LicenceID`),
  KEY `Index_20` (`F_UserID`,`F_ProductCode`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

-- 1 Feb 2012
-- Extend T_Reseller.F_Email to cope with lots of cc
ALTER TABLE `rack80829`.`T_Reseller` CHANGE COLUMN `F_Email` `F_Email` VARCHAR(128) NULL DEFAULT NULL ;

UPDATE `T_Product` SET F_ProductName='Clear Pronunciation 1' WHERE F_ProductCode=39;

-- For R2IV2
DELETE FROM T_Product WHERE F_ProductCode IN (52,53);
INSERT INTO `T_Product` VALUES
(52,'Road to IELTS Academic',NULL,3),
(53,'Road to IELTS General Training',NULL,4);

DELETE FROM rack80829.T_ProductLanguage WHERE F_ProductCode IN (52,53);
INSERT INTO rack80829.T_ProductLanguage VALUES 
(52,'R2ILM','RoadToIELTS2'),
(52,'R2ITD','RoadToIELTS2'),
(52,'R2IFV','RoadToIELTS2'),
(53,'R2ILM','RoadToIELTS2'),
(53,'R2ITD','RoadToIELTS2'),
(53,'R2IFV','RoadToIELTS2'),
(52,'R2IHU','RoadToIELTS2'),
(53,'R2IHU','RoadToIELTS2'),
(52,'DEMO','RoadToIELTS2'),
(53,'DEMO','RoadToIELTS2');

DELETE FROM rack80829.T_Language WHERE F_LanguageCode IN ('AC10','AC30','ACFull','GT10','GT30','GTFull','R2ILM','R2I10','R2IFull','R2IFV','R2ITD','R2IHU','R2ID');
INSERT INTO rack80829.T_Language VALUES 
('R2ILM','Last minute'),
('R2ITD','Test drive'),
('R2IFV','Full version'),
('R2IHU','Home user'),
('DEMO','Demo');

/*
DELETE FROM global_r2iv2.T_ProductLanguage WHERE F_ProductCode IN (52,53);
INSERT INTO global_r2iv2.T_ProductLanguage VALUES 
(52,'R2ILM','RoadToIELTS2'),
(52,'R2ITD','RoadToIELTS2'),
(52,'R2IFV','RoadToIELTS2'),
(53,'R2ILM','RoadToIELTS2'),
(53,'R2ITD','RoadToIELTS2'),
(53,'R2IFV','RoadToIELTS2'),
(52,'R2IHU','RoadToIELTS2'),
(53,'R2IHU','RoadToIELTS2'),
(52,'DEMO','RoadToIELTS2'),
(53,'DEMO','RoadToIELTS2');

DELETE FROM global_r2iv2.T_Language WHERE F_LanguageCode IN ('AC10','AC30','ACFull','GT10','GT30','GTFull','R2ILM','R2I10','R2IFull','R2IFV','R2ITD','R2IHU','R2ID');
INSERT INTO global_r2iv2.T_Language VALUES 
('R2ILM','Last minute'),
('R2ITD','Test drive'),
('R2IFV','Full version'),
('R2IHU','Home user'),
('DEMO','Demo');
*/

-- For beta records
UPDATE T_Accounts SET F_LanguageCode='R2ILM'
WHERE F_LanguageCode in ('AC30','GT30');
UPDATE T_Accounts SET F_LanguageCode='R2IFV'
WHERE F_LanguageCode in ('ACFull','GTFull','R2IFull');
UPDATE T_Accounts SET F_LanguageCode='R2ITD'
WHERE F_LanguageCode in ('AC10','GT10');

-- Bento anonymous users
DELETE FROM T_User WHERE F_UserID = -1;
INSERT INTO `T_User` 
(`F_UserID`,`F_UserName`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_RegistrationDate`)
VALUES (-1,'you',0,0,1,'2012-04-01 00:00:00');

-- Alter T_User to add in a big field for instance control, take out F_Company and F_ScratchPadFile to avoid wasting space
ALTER TABLE `T_User` 
DROP COLUMN `F_Company` , 
DROP COLUMN `F_ScratchPadFile` , 
ADD COLUMN `F_InstanceID` TEXT NULL DEFAULT NULL  AFTER `F_ContactMethod` , 
CHANGE COLUMN `F_ScratchPad` `F_ScratchPad` TEXT NULL DEFAULT NULL  ;

-- package for R2I home user
INSERT INTO `T_Package`
(`F_PackageID`,`F_PackageName`) VALUES
('19','Road to IELTS 2 Academic Home User'),
('20','Road to IELTS 2 General Training Home User');

INSERT INTO `T_PackageContents`
(`F_PackageID`,`F_ProductCode`,`F_CourseID`) VALUES
('19','52','0'),
('20','53','0');

INSERT INTO `T_Offer`
(`F_OfferID`,`F_OfferName`,`F_PackageID`,`F_Duration`,`F_Currency`,`F_Price`,`F_OfferStartDate`,`F_OfferEndDate`) VALUES
('59','Road to IELTS 2 Academic 1-month','19','31','USD','49.99','2012-04-23',NULL),
('60','Road to IELTS 2 Academic 3-months','19','92','USD','99.99','2012-04-23',NULL),
('61','Road to IELTS 2 General Training 1-month','20','31','USD','49.99','2012-04-23',NULL),
('62','Road to IELTS 2 General Training 3-months','20','92','USD','99.99','2012-04-23',NULL);

-- Tidy up subscription table
ALTER TABLE `T_Subscription` 
DROP COLUMN `F_Checksum` , 
DROP COLUMN `F_ExpiryDate` , 
DROP COLUMN `F_ProductCode` , 
ADD COLUMN `F_ResellerCode` SMALLINT(5) NULL DEFAULT NULL  AFTER `F_OfferID`,
ADD COLUMN `F_OrderRef` VARCHAR(32) NULL DEFAULT NULL  AFTER `F_ResellerCode` ;

-- For later, when there is time to recode SubscriptionOps
-- Add subscription detail table to cope with multiple status changes
-- CREATE TABLE `T_SubscriptionDetail` (
--   `F_SubscriptionID` int(10) NOT NULL,
  -- `F_DateStamp` datetime DEFAULT NULL,
  -- `F_Status` varchar(32) DEFAULT NULL,
  -- PRIMARY KEY (`F_SubscriptionID`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Do this later once you know nothing is writing to it
-- ALTER TABLE `T_Subscription` DROP COLUMN `F_Status`; 

-- In the meantime
ALTER TABLE `T_Subscription` 
ADD COLUMN `F_DateStamp` datetime DEFAULT NULL AFTER `F_Email`;

-- Start introducing the svn of this file into the F_Version of T_DatabaseVersion
-- so that you can accurately cope with network installations
INSERT INTO `T_DatabaseVersion`
(`F_VersionNumber`,`F_ReleaseDate`,`F_Comments`)
VALUES (840, NOW(), 'subscription changes');

-- Practical Placement test, language versions
UPDATE `T_ProductLanguage` SET F_ContentLocation='PracticalPlacementTest-International' WHERE F_ProductCode=44 AND F_LanguageCode='EN';
INSERT INTO `T_ProductLanguage` VALUES (44,'TW-ZH','PracticalPlacementTest-Taiwan');
INSERT INTO `T_ProductLanguage` VALUES (44,'SL','PracticalPlacementTest-Slovene');
INSERT INTO `T_Language` VALUES ('TW-ZH','Taiwan Chinese'),('SL','Slovene');

-- EmailMe. RM trial emails
UPDATE T_Triggers
SET F_ValidToDate=NULL, 
F_Condition = 'method=getUsers&userExpiryDate={now}+2d', F_MessageType=7, 
F_Name='EmailMe trial reminder',
F_RootID=14582,
F_GroupID=NULL
WHERE F_TriggerID=2;
INSERT INTO T_MessageType VALUES (7,'EmailMe Trial reminders');

-- Remove Edutech
UPDATE T_Reseller
SET F_Email = 'sales@clarityenglish.com', F_DisplayOrder = 106
WHERE F_ResellerID = 3;

-- Separate CT and Network licence as they are not the same
UPDATE T_LicenceType
SET F_Description = 'Network'
WHERE F_Status = 3;
INSERT T_LicenceType
VALUES (7, 'Concurrent Tracking');

-- For IELTSpractice.com reminder system
DELETE FROM `T_Triggers`
WHERE F_TriggerID in (16,18,45,46);
INSERT INTO `T_Triggers`
(`F_TriggerID`,`F_Name`,`F_RootID`,`F_GroupID`,`F_TemplateID`,`F_Condition`,`F_ValidFromDate`,`F_ValidToDate`,`F_Executor`,`F_Frequency`,`F_MessageType`)
VALUES
(16,'CLS. Subscription ends in 7 days',null,null,2129,'method=getAccounts&expiryDate={now}+7d&licenceType=5&resellerID=21',null,null,'email','daily',1),
(18,'CLS. Subscription ends today',null,null,2130,'method=getAccounts&expiryDate={now}&licenceType=5&resellerID=21',null,null,'email','daily',1),
(45,'IELTSpractice.com 7d',null,null,2200,'method=getAccounts&expiryDate={now}+7d&licenceType=5&resellerID=36',null,null,'email','daily',1),
(46,'IELTSpractice.com 1d',null,null,2201,'method=getAccounts&expiryDate={now}-1d&licenceType=5&resellerID=36',null,null,'email','daily',1);

-- For CLS.com rewriting
INSERT INTO `T_Offer`
(`F_OfferID`,`F_OfferName`,`F_PackageID`,`F_Duration`,`F_Currency`,`F_Price`,`F_OfferStartDate`,`F_OfferEndDate`) VALUES
('63','Clarity English 1-month','21','31','USD','39.99','2012-07-20',NULL),
('64','Clarity English 3-months','21','92','USD','59.99','2012-07-20',NULL),
('65','Clarity English 1-year','21','365','USD','199.99','2012-07-20',NULL);

INSERT INTO T_Package VALUES 
(21, 'Clarity English');

INSERT INTO `T_PackageContents`
(`F_PackageID`,`F_ProductCode`,`F_CourseID`) VALUES
('21','9','0'),
('21','33','0'),
('21','39','0'),
('21','49','0'),
('21','10','0'),
('21','38','0'),
('21','40','0'),
('21','43','0'),
('21','1001','0');

-- Learn English Test Spanish
INSERT INTO T_ProductLanguage VALUES (36, 'ES', 'LearnEnglishTest-Spanish');

-- BUG: Usage stats should ignore opt out emails switch
DELETE FROM T_Triggers WHERE F_TriggerID = 33;
INSERT INTO `rack80829`.`T_Triggers`
(`F_TriggerID`,`F_Name`,`F_RootID`,`F_GroupID`,`F_TemplateID`,`F_Condition`,`F_ValidFromDate`,`F_ValidToDate`,`F_Executor`,`F_Frequency`,`F_MessageType`)
VALUES
(33,'Subscription reminder usage stats',null,null,20,'method=getAccounts&startDay={day}&accountType=1&notLicenceType=5&selfHost=false&active=true&optOutEmails=false',null,null,'usageStats','daily',2);

-- Just to update the BC LearnEnglish test old database
ALTER TABLE `T_Score` ADD COLUMN `F_ProductCode` SMALLINT(5) DEFAULT NULL AFTER `F_CourseID`;
UPDATE T_Score SET F_ProductCode=36 WHERE F_ProductCode is NULL;

-- Add customerType to T_AccountRoot
ALTER TABLE `T_AccountRoot` ADD COLUMN `F_CustomerType` SMALLINT(5) DEFAULT '0' AFTER `F_OptOutEmailDate` ;
DROP TABLE IF EXISTS `T_CustomerType`;
CREATE TABLE `T_CustomerType` (
  `F_Type` smallint(5) NOT NULL,
  `F_Description` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO T_CustomerType VALUES 
(0, '-'),
(1, 'Library'),
(2, 'Partner');
update T_AccountRoot
set F_CustomerType = 1
where F_Name like ('%Library%');
update T_AccountRoot
set F_CustomerType = 0
where not F_Name like ('%Library%');

-- For Rotterdam, CCB
INSERT INTO `T_Product` VALUES
(54,'Clarity Course Builder',NULL,10);
INSERT INTO `T_ProductLanguage` VALUES (54,'EN','');
-- INSERT INTO `T_Accounts` (`F_RootID`,`F_ProductCode`,`F_MaxStudents`,`F_MaxAuthors`,`F_MaxTeachers`,`F_MaxReporters`,`F_ExpiryDate`,`F_ContentLocation`,`F_LanguageCode`,`F_MGSRoot`,`F_StartPage`,`F_LicenceFile`,`F_LicenceStartDate`,`F_LicenceType`,`F_Checksum`,`F_DeliveryFrequency`,`F_LicenceClearanceDate`,`F_LicenceClearanceFrequency`) VALUES 
-- (163,54,100,0,30,30,'2012-12-31 23:59:59','Clarity','EN',NULL,'','','2012-09-18 00:00:00',1,'2be61e2be4125007da11a73d5595e9cd3d49fd53d1cbfb62dd811a49471995f6',NULL,NULL,NULL);
DROP TABLE IF EXISTS `T_CcbSchedule`;

-- For Road to IELTS, need product version in T_Accounts
ALTER TABLE T_Accounts ADD COLUMN `F_ProductVersion` varchar(8) NULL DEFAULT NULL  AFTER `F_LanguageCode`;
update T_Accounts set F_ProductVersion = F_LanguageCode
where F_ProductCode in (52,53);
update T_Accounts set F_LanguageCode = 'EN'
where F_ProductCode in (52,53);

DELETE FROM T_ProductLanguage WHERE F_ProductCode IN (52,53);
INSERT INTO T_ProductLanguage VALUES 
(52,'EN','RoadToIELTS2-International'),
(52,'ZH','RoadToIELTS2-Chinese'),
(52,'JP','RoadToIELTS2-Japanese'),
(53,'EN','RoadToIELTS2-International'),
(53,'ZH','RoadToIELTS2-Chinese'),
(53,'JP','RoadToIELTS2-Japanese');
DELETE FROM T_Language WHERE F_LanguageCode IN ('R2IFV','R2ITD','R2ILM','R2IHU','R2ID');

UPDATE T_Language
SET F_LanguageCode='ZH'
WHERE F_LanguageCode='ZHO';
UPDATE T_Accounts
SET F_LanguageCode='ZH'
WHERE F_LanguageCode='ZHO';
UPDATE T_ProductLanguage
SET F_LanguageCode='ZH'
WHERE F_LanguageCode='ZHO';

INSERT INTO T_Language VALUES
('ZH','简体中文 (Putonghua)');

DROP TABLE IF EXISTS `T_Version`;
CREATE TABLE `T_Version` (
  `F_VersionCode` varchar(16) NOT NULL,
  `F_Description` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `T_Version` VALUES 
('R2IFV','Full Version'),
('R2ILM','Last Minute'),
('R2IHU','Home User'),
('DEMO','Demo'),
('R2ITD','Test Drive');

DROP TABLE IF EXISTS `T_ProductVersion`;
CREATE TABLE `T_ProductVersion` (
  `F_ProductCode` smallint(5) NOT NULL,
  `F_VersionCode` varchar(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `T_ProductVersion` VALUES 
(52,'R2IFV'),
(52,'R2ILM'),
(52,'R2IHU'),
(52,'DEMO'),
(52,'R2ITD'),
(53,'R2IFV'),
(53,'R2ILM'),
(53,'R2IHU'),
(53,'DEMO'),
(53,'R2ITD');

-- Create accounts expiry table
DROP TABLE IF EXISTS `T_Accounts_Expiry`;
CREATE TABLE `T_Accounts_Expiry` (
  `F_RootID` int(10) NOT NULL,
  `F_ProductCode` smallint(5) NOT NULL,
  `F_MaxStudents` int(10) NOT NULL DEFAULT '1',
  `F_MaxAuthors` int(10) NOT NULL DEFAULT '1',
  `F_MaxTeachers` int(10) NOT NULL DEFAULT '0',
  `F_MaxReporters` int(10) NOT NULL DEFAULT '0',
  `F_ExpiryDate` datetime NOT NULL,
  `F_ContentLocation` varchar(128) DEFAULT NULL,
  `F_LanguageCode` varchar(8) NOT NULL DEFAULT 'EN',
  `F_ProductVersion` varchar(8) DEFAULT NULL,
  `F_MGSRoot` varchar(128) DEFAULT NULL,
  `F_StartPage` varchar(128) DEFAULT NULL,
  `F_LicenceFile` varchar(128) DEFAULT NULL,
  `F_LicenceStartDate` datetime DEFAULT NULL,
  `F_LicenceType` int(10) NOT NULL DEFAULT '1',
  `F_Checksum` varchar(256) DEFAULT NULL,
  `F_DeliveryFrequency` int(10) DEFAULT NULL,
  `F_LicenceClearanceDate` datetime DEFAULT NULL,
  `F_LicenceClearanceFrequency` varchar(16) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- or --
ALTER TABLE T_Accounts_Expiry ADD COLUMN `F_ProductVersion` varchar(8) NULL DEFAULT NULL  AFTER `F_LanguageCode`;

INSERT INTO `T_DatabaseVersion`
(`F_VersionNumber`,`F_ReleaseDate`,`F_Comments`)
VALUES (841, NOW(), 'product version and customer type added');

ALTER TABLE `rack80829`.`T_Accounts_Expiry` 
DROP PRIMARY KEY ;

-- For R2I in subscriptions
ALTER TABLE T_Subscription ADD COLUMN `F_ProductVersion` varchar(8) NULL DEFAULT NULL AFTER `F_LanguageCode`;

-- gh#107
DROP TABLE IF EXISTS `T_CourseStart`;
CREATE  TABLE `T_CourseStart` (
  `F_GroupID` int(10) NOT NULL,
  `F_RootID` int(10) NOT NULL,
  `F_CourseID` bigint(20) NOT NULL,
  `F_StartMethod` varchar(8),
  `F_StartDate` datetime DEFAULT NULL,
  `F_EndDate` datetime DEFAULT NULL,
  `F_UnitInterval` smallint(5) DEFAULT NULL,
  `F_SeePastUnits` tinyint(4) DEFAULT 1,
  PRIMARY KEY (`F_GroupID`, `F_CourseID`) );

DROP TABLE IF EXISTS `T_UnitStart`;
CREATE  TABLE `T_UnitStart` (
  `F_GroupID` int(10) NOT NULL,
  `F_RootID` int(10) NOT NULL,
  `F_CourseID` bigint(20) NOT NULL,
  `F_UnitID` bigint(20) NOT NULL,
  `F_StartDate` datetime NOT NULL,
  PRIMARY KEY (`F_GroupID`, `F_CourseID`, `F_UnitID`) );

-- Testing data
INSERT T_CourseStart VALUES
(21560,163,319104163123193047,'group',7,'2013-01-17',null,1);
INSERT T_UnitStart VALUES
(21560,163,319104163123193047,319104389804193040,'2013-01-17');
INSERT T_CourseStart VALUES
(30255,163,319104163123193047,'group',7,'2013-01-17',null,1);
INSERT T_UnitStart VALUES
(30255,163,319104163123193047,319104389804193040,'2013-02-01');
INSERT T_CourseStart VALUES
(25078,163,319104163123193047,'user',7,'2013-01-17',null,1);
INSERT INTO T_Session
(`F_CourseID`,`F_CourseName`,`F_Duration`,`F_EndDateStamp`,`F_ProductCode`,`F_RootID`,`F_StartDateStamp`,`F_UserID`)
VALUES 
(319104163123193047,null,60,'2013-01-20 10:01:00',54,163,'2013-01-20 10:00:00',195254),
(319104163123193047,null,60,'2013-01-15 10:01:00',54,163,'2013-01-15 10:00:00',195255);

INSERT INTO `T_DatabaseVersion`
(`F_VersionNumber`,`F_ReleaseDate`,`F_Comments`)
VALUES (1107, NOW(), 'course publication dates');

ALTER TABLE `rack80829`.`T_Membership_Expiry` 
ADD INDEX `Index_2` (`F_GroupID` ASC, `F_UserID` ASC) 
, ADD INDEX `Index_1` (`F_RootID` ASC) 
, ADD INDEX `Index_3` (`F_GroupID` ASC, `F_RootID` ASC);

ALTER TABLE `rack80829`.`T_User_Expiry` 
ADD INDEX `Index_2` (`F_UserID` ASC) 
, ADD INDEX `Index_1` (`F_RegistrationDate` ASC);

DELETE FROM T_Product WHERE F_ProductCode = 22;
INSERT INTO `T_Product` VALUES
(22,'Listening Bank',NULL,888);
DELETE FROM T_ProductLanguage WHERE F_ProductCode = 22;
INSERT INTO `T_ProductLanguage` VALUES 
(22,'NAMEN','Listening Bank');

-- Global product version of demo rather R2I specific
DELETE FROM T_Version WHERE F_VersionCode IN ('R2ID');
INSERT INTO `T_Version` VALUES 
('DEMO','Demo');

DELETE FROM T_ProductVersion WHERE F_ProductCode IN (52,53);
INSERT INTO `T_ProductVersion` VALUES 
(52,'R2IFV'),
(52,'R2ILM'),
(52,'R2IHU'),
(52,'DEMO'),
(52,'R2ITD'),
(53,'R2IFV'),
(53,'R2ILM'),
(53,'R2IHU'),
(53,'DEMO'),
(53,'R2ITD');

DELETE FROM T_ProductLanguage WHERE F_ProductCode IN (52,53);
INSERT INTO T_ProductLanguage VALUES 
(52,'EN','RoadToIELTS2-International'),
(53,'EN','RoadToIELTS2-International'),
(52,'JP','RoadToIELTS2-Japanese'),
(53,'JP','RoadToIELTS2-Japanese'),
(52,'ZH','RoadToIELTS2-Chinese'),
(53,'ZH','RoadToIELTS2-Chinese');

DELETE FROM T_Language WHERE F_LanguageCode IN ('R2ILM','R2IFV','R2ITD','R2IHU','R2ID');

-- to update existing accounts (probably only one)
update T_Accounts set F_ProductVersion = 'DEMO' where F_ProductVersion = 'R2ID';

ALTER TABLE `T_Membership_Expiry` 
DROP INDEX `Index_3` 
, DROP INDEX `Index_1` 
, DROP INDEX `Index_2` ;

ALTER TABLE `rack80829`.`T_Membership_Expiry` 
ADD INDEX `Index_1` (`F_RootID` ASC) 
, ADD INDEX `Index_2` (`F_UserID` ASC, `F_GroupID` ASC) 
, ADD INDEX `Index_3` (`F_GroupID` ASC, `F_RootID` ASC) ;

ALTER TABLE `rack80829`.`T_User_Expiry` 
DROP INDEX `Index_1` 
, DROP INDEX `Index_2` ;

ALTER TABLE `rack80829`.`T_User_Expiry` 
ADD INDEX `Index_2` (`F_UserID` ASC) 
, ADD INDEX `Index_1` (`F_RegistrationDate` ASC);

ALTER TABLE `T_EditedContent` CHANGE COLUMN `ID` `ID` BIGINT(19) NULL DEFAULT 0;
-- or 
ALTER TABLE `T_EditedContent` ADD COLUMN `ID` BIGINT(19) NULL DEFAULT 0 AFTER `F_RelatedUID`;

CREATE TABLE T_CourseConcurrency (
F_RootID int(11) NOT NULL,
F_UserID int(11) NOT NULL,
F_CourseID bigint(20) NOT NULL,
F_Timestamp datetime NOT NULL,
PRIMARY KEY (F_UserID,F_CourseID)
) ENGINE=InnoDB;

INSERT INTO `T_DatabaseVersion`
(`F_VersionNumber`,`F_ReleaseDate`,`F_Comments`)
VALUES (1142, NOW(), 'course concurrency');

DROP TABLE IF EXISTS `T_PendingEmails`;
CREATE TABLE T_PendingEmails (
F_EmailID bigint(20) NOT NULL AUTO_INCREMENT,
F_To varchar(64) NOT NULL,
F_TemplateID varchar(64) NOT NULL,
F_Data text,
F_RequestTimestamp datetime DEFAULT NULL,
F_SentTimestamp datetime DEFAULT NULL,
F_DelayUntil datetime DEFAULT NULL,
F_Attempts smallint DEFAULT 0,
PRIMARY KEY (F_EmailID),
  KEY `Index_1` (F_SentTimestamp),
  INDEX `Index_2` (`F_RequestTimestamp` ASC)
) ENGINE=InnoDB;

INSERT INTO `T_DatabaseVersion`
(`F_VersionNumber`,`F_ReleaseDate`,`F_Comments`)
VALUES (1143, NOW(), 'pending emails');

ALTER TABLE T_User ADD COLUMN F_TimeZoneOffset FLOAT(3,1) NULL DEFAULT 0;
ALTER TABLE T_User_Expiry ADD COLUMN F_TimeZoneOffset FLOAT(3,1) NULL DEFAULT 0;

INSERT INTO `T_DatabaseVersion`
(`F_VersionNumber`,`F_ReleaseDate`,`F_Comments`)
VALUES (1156, NOW(), 'timezone offset');

-- Tense Buster v10
INSERT INTO `T_Product` VALUES (55,'Tense Buster V10',NULL,10);
INSERT INTO `T_ProductLanguage` VALUES 
(55,'EN','TenseBuster10-International'),
(55,'NAMEN','TenseBuster10-NAmerican'),
(55,'INDEN','TenseBuster10-Indian');

INSERT INTO `T_Version` VALUES 
('FV','Full Version');
INSERT INTO `T_ProductVersion` VALUES 
(55,'FV');

-- DMS login option and self register
DROP TABLE IF EXISTS `T_LoginOption`;
CREATE  TABLE `T_LoginOption` (
  `F_Type` SMALLINT NOT NULL ,
  `F_Description` VARCHAR(45) NULL ,
  PRIMARY KEY (`F_Type`) );
INSERT INTO `T_LoginOption`
(`F_Type`,`F_Description`)
VALUES
(1,'Name'),
(2,'ID'),
(128,'Email'),
(4,'Name and ID (old)');

DROP TABLE IF EXISTS `T_SelfRegisterOption`;
CREATE  TABLE `T_SelfRegisterOption` (
  `F_Type` SMALLINT NOT NULL ,
  `F_Description` VARCHAR(45) NULL ,
  PRIMARY KEY (`F_Type`) );
INSERT INTO `T_SelfRegisterOption`
(`F_Type`,`F_Description`)
VALUES
(0,'Not allowed'),
(17,'Name only'),
(18,'ID only'),
(19,'Name and ID'),
(20,'Email only'),
(21,'Name and email'),
(23,'Name, ID and email');

-- Library emails
ALTER TABLE `T_Triggers` CHANGE COLUMN `F_TemplateID` `F_TemplateID` VARCHAR(64) NOT NULL  ;
INSERT INTO `T_Triggers` (`F_TriggerID`,`F_Name`,`F_RootID`,`F_GroupID`,`F_TemplateID`,`F_Condition`,`F_ValidFromDate`,`F_ValidToDate`,`F_Executor`,`F_Frequency`,`F_MessageType`) 
VALUES 
(48,'Library reminder start+7d',NULL,NULL,'library/32','method=getAccounts&startDate={now}-7d&customerType=1&accountType=1&notLicenceType=5',NULL,NULL,'email','daily',1),
(49,'Library reminder usage stats',NULL,NULL,'library/20','method=getAccounts&startDay={day}&customerType=1&accountType=1&notLicenceType=5&selfHost=false&active=true&optOutEmails=false',NULL,NULL,'usageStats','daily',2),
(50,'Library support start+1.5m',NULL,NULL,'library/34','method=getAccounts&startDate={now}-1.5m&customerType=1&accountType=1&notLicenceType=5',NULL,NULL,'email','daily',4),
(51,'Library support start+6.5m',NULL,NULL,'library/35','method=getAccounts&startDate={now}-6.5m&customerType=1&accountType=1&notLicenceType=5','2011-12-31 00:00:00',NULL,'email','daily',4),
(52,'Library reminder end-2.5m',NULL,NULL,'library/36','method=getAccounts&expiryDate={now}+10w&customerType=1&accountType=1&notLicenceType=5',NULL,NULL,'email','daily',1),
(53,'Library create a quotation',NULL,NULL,'library/37','method=getAccounts&expiryDate={now}+11w&customerType=1&accountType=1&notLicenceType=5',NULL,NULL,'internalEmail','daily',0),
(54,'Library reminder end-1.5m',NULL,NULL,'library/38','method=getAccounts&expiryDate={now}+45d&customerType=1&accountType=1&notLicenceType=5',NULL,NULL,'email','daily',1),
(55,'Library reminder end-2w',NULL,NULL,'library/39','method=getAccounts&expiryDate={now}+14d&customerType=1&accountType=1&notLicenceType=5',NULL,NULL,'email','daily',1),
(56,'Library reminder end tomorrow',NULL,NULL,'library/40','method=getAccounts&expiryDate={now}+1d&customerType=1&accountType=1&notLicenceType=5',NULL,NULL,'email','daily',1),
(57,'Library reminder end today',NULL,NULL,'library/41','method=getAccounts&expiryDate={now}&customerType=1&accountType=1&notLicenceType=5',NULL,NULL,'email','daily',1),
(58,'Library reminder ended',NULL,NULL,'library/42','method=getAccounts&expiryDate={now}-14d&customerType=1&accountType=1&notLicenceType=5',NULL,NULL,'email','daily',1);

-- gh#226
ALTER TABLE `T_PendingEmails` 
ADD INDEX `Index_2` (`F_RequestTimestamp` ASC) ;

DROP TABLE IF EXISTS `T_SentEmails`;
CREATE TABLE T_SentEmails (
F_EmailID bigint(20) NOT NULL,
F_To varchar(64) NOT NULL,
F_TemplateID varchar(64) NOT NULL,
F_Data text,
F_RequestTimestamp datetime DEFAULT NULL,
F_SentTimestamp datetime DEFAULT NULL,
F_DelayUntil datetime DEFAULT NULL,
F_Attempts smallint DEFAULT 0
) ENGINE=InnoDB;

ALTER TABLE `T_PendingEmails` ADD COLUMN `F_Attempts` SMALLINT NULL DEFAULT 0  AFTER `F_DelayUntil` ;
ALTER TABLE `T_SentEmails` ADD COLUMN `F_Attempts` SMALLINT NULL DEFAULT 0  AFTER `F_DelayUntil` ;

-- CCB Activity
DROP TABLE IF EXISTS `T_CCB_Activity`;
CREATE TABLE T_CCB_Activity (
F_RootID int(11) NOT NULL,
F_DateStamp datetime NOT NULL,
F_Courses smallint DEFAULT NULL,
F_Units smallint DEFAULT NULL,
F_Exercises smallint DEFAULT NULL,
F_Sessions smallint DEFAULT NULL,
  KEY `Index_1` (F_RootID)
) ENGINE=InnoDB;

ALTER TABLE `T_Subscription` ADD COLUMN `F_Birthday` DATETIME NULL DEFAULT NULL AFTER `F_OrderRef`;
