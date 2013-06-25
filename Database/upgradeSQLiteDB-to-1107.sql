
CREATE TABLE `T_LicenceType` (
  `F_Status` smallint(5) NOT NULL,
  `F_Description` varchar(32) NOT NULL
);

CREATE TABLE `T_Language` (
  `F_LanguageCode` varchar(16) NOT NULL,
  `F_Description` varchar(50) NOT NULL
);

INSERT INTO `T_LicenceType` (`F_Status`,`F_Description`) VALUES (1,'Learner Tracking');
INSERT INTO `T_LicenceType` (`F_Status`,`F_Description`) VALUES (2,'Anonymous Access');
INSERT INTO `T_LicenceType` (`F_Status`,`F_Description`) VALUES (3,'Network');
INSERT INTO `T_LicenceType` (`F_Status`,`F_Description`) VALUES (4,'Single');
INSERT INTO `T_LicenceType` (`F_Status`,`F_Description`) VALUES (5,'Individual');
INSERT INTO `T_LicenceType` (`F_Status`,`F_Description`) VALUES (6,'Transferable Tracking');
INSERT INTO `T_LicenceType` (`F_Status`,`F_Description`) VALUES (7,'Concurrent Tracking');

ALTER TABLE `T_AccountRoot` ADD COLUMN `F_CustomerType` SMALLINT(5) DEFAULT '0' AFTER `F_OptOutEmailDate` ;
DROP TABLE IF EXISTS `T_CustomerType`;
CREATE TABLE `T_CustomerType` (
  `F_Type` smallint(5) NOT NULL,
  `F_Description` varchar(32) NOT NULL
);
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
ALTER TABLE T_Accounts ADD COLUMN `F_ProductVersion` varchar(8) NULL DEFAULT NULL;
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
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('BREN','British English');
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('AUSEN','Australian English');
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('ORIG','Original recordings');
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('EN','International English');
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('NAMEN','North American English');
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('INDEN','Indian English');
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('ZHO','简体中文 (Putonghua)');
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('TH','ภาษาไทย (Thai)');
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('ES','Español (Spanish)');
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('CHI','繁體中文 (Cantonese)');
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('FR','français (French)');
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('MS','Melayu (Malay)');
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('SV','Svenska (Swedish)');
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('REREC','Clearer recordings');
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('JP','Japanese');
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('TW-ZH','Taiwan Chinese');
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('SL','Slovene');
INSERT INTO `T_Language` (`F_LanguageCode`,`F_Description`) VALUES ('ZH','简体中文 (Putonghua)');

DROP TABLE IF EXISTS `T_Version`;
CREATE TABLE `T_Version` (
  `F_VersionCode` varchar(16) NOT NULL,
  `F_Description` varchar(50) NOT NULL
);

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
);

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

INSERT INTO `T_DatabaseVersion`
(`F_VersionNumber`,`F_ReleaseDate`,`F_Comments`)
VALUES (841, NOW(), 'product version and customer type added');


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

INSERT INTO `T_DatabaseVersion`
(`F_VersionNumber`,`F_ReleaseDate`,`F_Comments`)
VALUES (1107, '2013-06-24 00:00:00', 'course publication dates');

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

CREATE TABLE T_CourseConcurrency (
F_RootID int(11) NOT NULL,
F_UserID int(11) NOT NULL,
F_CourseID bigint(20) NOT NULL,
F_Timestamp datetime NOT NULL,
PRIMARY KEY (F_UserID,F_CourseID)
);

INSERT INTO `T_DatabaseVersion`
(`F_VersionNumber`,`F_ReleaseDate`,`F_Comments`)
VALUES (1142, '2013-06-24 00:00:00', 'course concurrency');

DROP TABLE IF EXISTS `T_PendingEmails`;
CREATE TABLE T_PendingEmails (
F_EmailID bigint(20) NOT NULL,
F_To varchar(64) NOT NULL,
F_TemplateID varchar(64) NOT NULL,
F_Data text,
F_RequestTimestamp datetime DEFAULT NULL,
F_SentTimestamp datetime DEFAULT NULL,
F_DelayUntil datetime DEFAULT NULL,
F_Attempts smallint DEFAULT 0
);

INSERT INTO `T_DatabaseVersion`
(`F_VersionNumber`,`F_ReleaseDate`,`F_Comments`)
VALUES (1143, '2013-06-24 00:00:00', 'pending emails');

ALTER TABLE T_User ADD COLUMN F_TimeZoneOffset FLOAT(3,1) NULL DEFAULT 0;

INSERT INTO `T_DatabaseVersion`
(`F_VersionNumber`,`F_ReleaseDate`,`F_Comments`)
VALUES (1156, '2013-06-24 00:00:00', 'timezone offset');

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


DROP TABLE IF EXISTS `T_SentEmails`;
CREATE TABLE T_SentEmails (
F_EmailID bigint(20) NOT NULL,
F_To varchar(64) NOT NULL,
F_TemplateID varchar(64) NOT NULL,
F_Data text,
F_RequestTimestamp datetime DEFAULT NULL,
F_SentTimestamp datetime DEFAULT NULL,
F_DelayUntil datetime DEFAULT NULL,
F_Attempts SMALLINT DEFAULT 0
);

-- CCB Activity
DROP TABLE IF EXISTS `T_CCB_Activity`;
CREATE TABLE T_CCB_Activity (
F_RootID int(11) NOT NULL,
F_DateStamp datetime NOT NULL,
F_Courses smallint DEFAULT NULL,
F_Units smallint DEFAULT NULL,
F_Exercises smallint DEFAULT NULL,
F_Sessions smallint DEFAULT NULL
);

