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
(33,'Subscription reminder usage stats',null,null,20,'method=getAccounts&startDate={day}&accountType=1&notLicenceType=5',null,null,'usageStats','daily',2),
(34,'Subscription reminder start+1.5m',null,null,34,'method=getAccounts&startDate={now}-1.5m&accountType=1&notLicenceType=5',null,null,'email','daily',3),
(35,'Subscription reminder start+6.5m',null,null,35,'method=getAccounts&startDate={now}-6.5m&accountType=1&notLicenceType=5','2011-08-30',null,'email','daily',3),
(36,'Subscription reminder end-2.5m',null,null,36,'method=getAccounts&expiryDate={now}+10w&accountType=1&notLicenceType=5',null,null,'email','daily',1),
(37,'Create a quotation',null,null,37,'method=getAccounts&expiryDate={now}+11w&accountType=1&notLicenceType=5',null,null,'internalEmail','daily',0),
(38,'Subscription reminder end-1.5m',null,null,38,'method=getAccounts&expiryDate={now}+45d&accountType=1&notLicenceType=5',null,null,'email','daily',1),
(39,'Subscription reminder end-2w',null,null,39,'method=getAccounts&expiryDate={now}+14d&accountType=1&notLicenceType=5',null,null,'email','daily',1),
(40,'Subscription reminder end tomorrow',null,null,40,'method=getAccounts&expiryDate={now}+1d&accountType=1&notLicenceType=5',null,null,'email','daily',1),
(41,'Subscription reminder end today',null,null,41,'method=getAccounts&expiryDate={now}&accountType=1&notLicenceType=5',null,null,'email','daily',1),
(42,'Subscription reminder ended',null,null,42,'method=getAccounts&expiryDate={now}-14d&accountType=1&notLicenceType=5',null,null,'email','daily',1);

UPDATE `rack80829`.`T_Triggers`
SET `F_ValidToDate`='2011-07-19'
WHERE F_TriggerID in (1,6,7,8,30);

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

-- For CCB
DROP TABLE IF EXISTS `T_CcbSchedule`;
CREATE TABLE `T_CcbSchedule` (
  `F_SID` bigint(20) NOT NULL AUTO_INCREMENT,
  `F_GroupID` int(10) NOT NULL,
  `F_CourseID` bigint(19) NOT NULL,
  `F_StartDate` datetime DEFAULT NULL,
  `F_EndDate` datetime DEFAULT NULL,
  `F_Period` tinyint(4) DEFAULT '7',
  `F_ShowPast` tinyint(4) DEFAULT '1',
  PRIMARY KEY (`F_SID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

-- Correcting reseller details
UPDATE T_Reseller SET F_Email='valdenegro@celestron.cl' WHERE F_ResellerID=22;
UPDATE T_Reseller SET F_Email='post@richbook.se' WHERE F_ResellerID=5;
UPDATE T_Reseller SET F_Email='philip.lam@clarityenglish.com,queenie.lam@clarityenglish.com' WHERE F_ResellerID=12;
UPDATE T_Reseller SET F_Email='joe@school.hk' WHERE F_ResellerID=30;