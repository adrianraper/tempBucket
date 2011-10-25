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
(33,'Subscription reminder usage stats',null,null,20,'method=getAccounts&startDay={day}&accountType=1&notLicenceType=5&selfHost=false&active=true',null,null,'usageStats','daily',2),
(34,'Subscription reminder start+1.5m',null,null,34,'method=getAccounts&startDate={now}-1.5m&accountType=1&notLicenceType=5',null,null,'email','daily',3),
(35,'Subscription reminder start+6.5m',null,null,35,'method=getAccounts&startDate={now}-6.5m&accountType=1&notLicenceType=5','2011-12-31',null,'email','daily',3),
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
(2,'Bookery',NULL,'info@bookery.com.au',6),
(3,'Edutech Middle East L.L.C. (Dubai, UAE)',NULL,'subramoni@edutech.com',5),
(4,'Falcon Press Sdn Bhd',NULL,NULL,101),
(5,'Hans Richter Laromedel',NULL,'post@richbook.se',13),
(6,'Mr Kevin Coffey',NULL,'insight@paradise.net.nz',10),
(7,'NAS Software Inc',NULL,'sam@nas.ca',4),
(8,'Study Plan S.L.',NULL,'stephenbe@studyplan.es',102),
(9,'Voice Works International Pte Ltd',NULL,NULL,103),
(10,'Win Hoe Company Limited',NULL,'kima@ms14.hinet.net',9),
(11,'Young India Films',NULL,'youngindiafilms@airtelbroadband.in,yif@vsnl.com',3),
(12,'Clarity in Hong Kong',NULL,'kenix.wong@clarityenglish.com',2),
(13,'Clarity direct',NULL,'admin@clarityenglish.com',2),
(14,'P.T. Solusi Nusantara',NULL,'ervida@solusi-nusantara.com',8),
(15,'Rosanna d o o',NULL,'rossana@t-2.net',104),
(16,'Attica S.A.',NULL,'karine.finck@attica.fr',100),
(17,'Encomium',NULL,'maryam@encomium.com',14),
(18,'Source Learning System (Thailand)',NULL,'udomchai@source.co.th',11),
(19,'Lingualearn Ltd',NULL,'mike@lingualearn.com',105),
(20,'Lara Kytapcilik','old name for Turkey','administrator@eltturkey.com',200),
(21,'Clarity online subscription',NULL,'kenix.wong@clarityenglish.com',22),
(22,'Celestron Ltda',NULL,'valdenegro@celestron.cl',16),
(23,'Sinirsiz Egitim Hizmetleri','new name for Turkey','administrator@eltturkey.com',17),
(24,'Edict Electronics Sdn Bhd',NULL,'mary@edict.com.my',18),
(25,'ThirdWave Learning, Inc.',NULL,'geri@thirdwavelearning.com',19),
(27,'iLearnIELTS',NULL,'sales@ilearnIELTS.com',16),
(28,'Protea Textware',NULL,'orders@proteatextware.com.au',21),
(29,'The Learning Institute',NULL,'kiran@the-learninginstitute.com',105),
(30,'SchoolNet',NULL,'joe@school.hk',21),
(31,'BeeCrazy',NULL,'queenie.lam@clarityenglish.com,kenix.wong@clarityenglish.com',21),
(32,'HKA',NULL,'philip.lam@clarityenglish.com,kenix.wong@clarityenglish.com',1),
(33,'HKB',NULL,'queenie.lam@clarityenglish.com,kenix.wong@clarityenglish.com',1),
(34,'Complejo de Consultoria de Idiomas',NULL,'elizabeth.pena@etciberoamerica.com',99),
(35,'Micromail',NULL,'diarmuid@micromail.ie',105);

-- No more monthly usage stats
UPDATE `rack80829`.`T_Triggers` SET `F_ValidToDate`='2011-08-29' WHERE F_TriggerID in (31);

-- Don't enable questionnaire email yet
UPDATE T_Triggers SET F_ValidFromDate='2011-12-31' WHERE F_TriggerID=35;

DROP TABLE IF EXISTS `T_CcbSchedule`;
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
DELETE FROM T_Triggers WHERE F_TriggerID = 33;
INSERT INTO `rack80829`.`T_Triggers`
(`F_TriggerID`,`F_Name`,`F_RootID`,`F_GroupID`,`F_TemplateID`,`F_Condition`,`F_ValidFromDate`,`F_ValidToDate`,`F_Executor`,`F_Frequency`,`F_MessageType`)
VALUES
(33,'Subscription reminder usage stats',null,null,20,'method=getAccounts&startDay={day}&accountType=1&notLicenceType=5&selfHost=false&active=true',null,null,'usageStats','daily',2);

-- For R2IV2
INSERT INTO `T_Product` VALUES
(52,'Road to IELTS 2',NULL,10);
INSERT INTO `T_ProductLanguage` VALUES 
(52,'AC30','RoadToIELTS2-Academic-30hour'),
(52,'AC10','RoadToIELTS2-Academic-10hour'),
(52,'ACFull','RoadToIELTS2-Academic');
INSERT INTO `T_Language` VALUES 
('AC30','Academic 30-hour'),
('AC10','Academic 10-hour'),
('ACFull','Academic full'),
('GT30','General Training 30-hour'),
('GT10','General Training 10-hour'),
('GTFull','General Training full');

INSERT INTO `T_Accounts` (`F_RootID`,`F_ProductCode`,`F_MaxStudents`,`F_MaxAuthors`,`F_MaxTeachers`,`F_MaxReporters`,`F_ExpiryDate`,`F_ContentLocation`,`F_LanguageCode`,`F_MGSRoot`,`F_StartPage`,`F_LicenceFile`,`F_LicenceStartDate`,`F_LicenceType`,`F_Checksum`,`F_DeliveryFrequency`,`F_LicenceClearanceDate`,`F_LicenceClearanceFrequency`) 
VALUES (163,52,999,0,30,30,'2049-12-31 23:59:59',NULL,'AC30',NULL,'','','2011-10-25 00:00:00',1,'32c926512da043c294aafcb08c089e146b279df91c05e9ea0610fba437ec58cc',NULL,NULL,NULL);
