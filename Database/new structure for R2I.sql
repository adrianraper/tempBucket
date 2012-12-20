use rack80829;

ALTER TABLE T_Accounts ADD COLUMN `F_ProductVersion` varchar(8) NULL DEFAULT NULL  AFTER `F_LanguageCode`;
update T_Accounts set F_ProductVersion = F_LanguageCode
where F_ProductCode in (52,53);

INSERT INTO T_Language VALUES
('ZH','简体中文 (Putonghua)');

INSERT INTO T_ProductLanguage VALUES 
(52,'EN','RoadToIELTS2-International'),
(52,'ZH','RoadToIELTS2-Chinese'),
(52,'JP','RoadToIELTS2-Japanese'),
(53,'EN','RoadToIELTS2-International'),
(53,'ZH','RoadToIELTS2-Chinese'),
(53,'JP','RoadToIELTS2-Japanese');

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

-- !!!!!!!!!!!!
-- Only run the following when you are releasing the new version of Road to IELTS
UPDATE T_Accounts set F_LanguageCode = 'EN'
where F_ProductCode in (52,53);

DELETE FROM T_Language WHERE F_LanguageCode IN ('R2IFV','R2ITD','R2ILM','R2IHU','R2ID');
