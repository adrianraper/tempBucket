-- For Road to IELTS, need product version in T_Accounts
ALTER TABLE T_Accounts ADD COLUMN `F_ProductVersion` varchar(8) NULL DEFAULT NULL  AFTER `F_LanguageCode`;
update T_Accounts set F_ProductVersion = F_LanguageCode
where F_ProductCode in (52,53);
update T_Accounts set F_LanguageCode = 'EN'
where F_ProductCode in (52,53)
and F_LanguageCode not in ('JP','ZH');

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
('R2ID','Demo'),
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
(52,'R2ID'),
(52,'R2ITD'),
(53,'R2IFV'),
(53,'R2ILM'),
(53,'R2IHU'),
(53,'R2ID'),
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
  `F_LicenceClearanceFrequency` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`F_RootID`,`F_ProductCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `T_DatabaseVersion`
(`F_VersionNumber`,`F_ReleaseDate`,`F_Comments`)
VALUES (841, NOW(), 'product version and customer type added');

-- For R2I in subscriptions
ALTER TABLE T_Subscription ADD COLUMN `F_ProductVersion` varchar(8) NULL DEFAULT NULL AFTER `F_LanguageCode`;

