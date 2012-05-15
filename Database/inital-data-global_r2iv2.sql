CREATE DATABASE  IF NOT EXISTS `global_r2iv2` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `global_r2iv2`;
-- MySQL dump 10.13  Distrib 5.5.9, for Win32 (x86)
--
-- Host: 127.0.0.1    Database: global_r2iv2
-- ------------------------------------------------------
-- Server version	5.1.50-community-log

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
-- Dumping data for table `T_Accounts`
--

LOCK TABLES `T_Accounts` WRITE;
/*!40000 ALTER TABLE `T_Accounts` DISABLE KEYS */;
INSERT INTO `T_Accounts` VALUES (100,2,999999,0,100,100,'2012-12-31 23:59:59',NULL,'EN',NULL,'','','2009-06-09 00:00:00',1,'2d75b848fd3df777e27ab6390858eefaa53c39eac77984b298042bf822807ac4',NULL,NULL,NULL),(100,12,999999,0,10,0,'2012-12-31 23:59:59',NULL,'EN',NULL,'','','2009-05-14 00:00:00',1,'68bc9d65bab2cf165dad68067ed052ccfdef6e918b9ee7814ea2cb068e0ae210',NULL,NULL,NULL),(100,13,999999,0,10,0,'2012-12-31 23:59:59',NULL,'EN',NULL,'','','2009-05-14 00:00:00',1,'94d3d3dcd379feaa98bb9ab0d7d286bb92b2b8044e02d784f11ccfb52b56b7cd',NULL,NULL,NULL),(101,2,999999,0,10,10,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2009-03-20 00:00:00',1,'7f4d8357b1786fb875ea4e377051b02bfee271607a79633144951d33a6e49e0b',NULL,NULL,NULL),(101,12,10,0,1,0,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2009-03-20 00:00:00',1,'7f70b3889a9aa2609e9f46078acfe6d8f304898f451e1ffd72c487612ef6badc',NULL,NULL,NULL),(101,13,10,0,1,0,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2009-03-20 00:00:00',1,'65c0d45bfc6066fb16f2af17bc84441b797694f2df17bc684e3490ca57d8edef',NULL,NULL,NULL),(167,2,999999,0,999,999,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2009-06-09 00:00:00',1,'e14444722c24ffa707fb64a464068c52e95d6e3e6a81e365dcb10dd10a81f05',NULL,NULL,NULL),(167,12,999999,0,0,0,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2009-06-09 00:00:00',1,'4810c0dcc615fe31fcf23d876765602cc1c9953a43cbf02e472ccc8b1f206073',NULL,NULL,NULL),(167,13,999999,0,0,0,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2009-06-09 00:00:00',1,'9cb73ccbb0fe190dfe180f835eb10cf3513719dfba2034ebf1d6bbdf6ab9ea8d',NULL,NULL,NULL),(168,2,999999,0,999,999,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2009-06-09 00:00:00',1,'7b801fe7769f7ffd28bc837c5b0d049b4fa0349c21c6c4a1799e9bb380e85519',NULL,NULL,NULL),(168,12,999999,0,0,0,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2009-06-09 00:00:00',1,'16b74c9d14ed665f926817dc7c9ab43f9053297674823f1ad30087f49b36f814',NULL,NULL,NULL),(168,13,999999,0,0,0,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2009-06-09 00:00:00',1,'43f9ce36c0aaaae0091c1b6ffe7d289fa8957d2060c3c08c0d49d70e9f9c7ab9',NULL,NULL,NULL),(169,2,999999,0,999,999,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2009-06-09 00:00:00',1,'74d74225ea246580162a4149ce8b14398f84165ab4e2be4e6a8a948d799eef4b',NULL,NULL,NULL),(169,12,999999,0,0,0,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2009-06-09 00:00:00',1,'ac08199dca645117d350e93b9924c037e9fd41ee5c0743c9aee4e6e8c72c7e50',NULL,NULL,NULL),(169,13,999999,0,0,0,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2009-06-09 00:00:00',1,'25edf81cc4d623d2db95dbfdf411c647ffe50d3ed69ef47f13325a2d7021a318',NULL,NULL,NULL),(170,2,999999,0,999,999,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2009-06-09 00:00:00',1,'7f0224a1994839f7cd06b134bc6d08d3f10e282e8b812ecc1a900be2a613dd3a',NULL,NULL,NULL),(170,12,999999,0,0,0,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2009-06-09 00:00:00',1,'894594318470a07425a4890cdb89c866e33e46fc23cb033fb5cb5fee1ddb3cb5',NULL,NULL,NULL),(170,13,999999,0,0,0,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2009-06-09 00:00:00',1,'7c6adabbbed82781e2a724a47f3718b1565f92341f7397b7ef0129b2abe21e0d',NULL,NULL,NULL),(171,2,99999,1,10,1,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2011-03-04 00:00:00',2,'17c0aa0d5cc0457c252299f9f5de994bafd42a847c61610442db2582498b530c',NULL,NULL,NULL),(171,12,99999,1,10,1,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2011-03-04 00:00:00',2,'307992c90e3ec06df053169d6e0f1411a413682bde3f944f9d41cb64d19f0c93',NULL,NULL,NULL),(171,13,99999,1,10,1,'2013-01-01 23:59:59',NULL,'EN',NULL,'','','2011-03-04 00:00:00',2,'8e452fb55f5f0dc0504f80a9d7f0c9d2df6ea5a4844a77fcaf47929ed25d05d3',NULL,NULL,NULL),(14028,2,0,0,100,100,'2012-06-21 23:59:59',NULL,'EN',NULL,'','','2011-06-21 00:00:00',1,'bdec4a30aa4f7c603e5a383d65c8a52e200fe7b7bf671e3311bbf6b86b8b0070',NULL,NULL,NULL),(14028,12,1000,0,3,1,'2012-06-21 23:59:59',NULL,'EN',NULL,'','','2011-06-21 00:00:00',1,'6b72a42f26ba0b8b016bafc26a52d03ecb5c9cb9e57e3402004c13f9f91fecf9',NULL,NULL,NULL),(14028,13,1000,0,3,1,'2012-06-21 23:59:59',NULL,'EN',NULL,'','','2011-06-21 00:00:00',1,'8847c772a999b5118cb040905f7064ce5b
de3adc3182da8295a07c49c645f87b',NULL,NULL,NULL),(14030,2,0,0,50,50,'2012-12-31 23:59:59',NULL,'EN',NULL,'','','2011-06-29 00:00:00',1,'56957a0c86030dbf072b5a490d0a177b883a3cbf8efa023668b3c096da8893d0',NULL,NULL,NULL),(14030,12,999999,0,3,1,'2012-12-31 23:59:59',NULL,'EN',NULL,'','','2011-01-01 00:00:00',1,'172d25df5aa676ed9617c067862256dc4c74efec4c310652d46a6d38c43ce72c',NULL,NULL,NULL),(14030,13,999999,0,3,1,'2012-12-31 23:59:59',NULL,'EN',NULL,'','','2011-01-01 00:00:00',1,'9c0a874ce7c81862af520a31aeef7f544de395d06c1aca4948a7ef80320c84d3',NULL,NULL,NULL);
/*!40000 ALTER TABLE `T_Accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `T_AccountRoot`
--

LOCK TABLES `T_AccountRoot` WRITE;
/*!40000 ALTER TABLE `T_AccountRoot` DISABLE KEYS */;
INSERT INTO `T_AccountRoot` VALUES 
(100,'The British Council India','India','','',2,2,'0',12,100,'67133',1,0,2,1,1,'0',1,NULL),
(101,'The British Council China','China','James.Shipton','',2,2,'0',12,101,'67134',0,1,0,1,0,'0',0,NULL),
(167,'The British Council AMESA','AMESA','martin.lowder@britishcouncil.org','',1,2,'0',12,102,'67129',1,0,2,1,0,'0',0,NULL),
(168,'The British Council SEAsia','SEAsia','greg.selby@britishcouncil.org','',2,2,'0',12,103,'67130',1,0,2,1,0,'0',0,NULL),
(169,'The British Council Europe','Europe','mike.welch@britishcouncil.org','',1,0,'0',12,104,'67131',1,0,2,1,0,'0',0,NULL),
(170,'The British Council Americas','Americas','martin.lowder@britishcouncil.org','',1,2,'0',12,105,'67132',0,1,0,1,0,'0',0,NULL),
(171,'The British Council Anonymous','BCAA','adrian.raper@clarityenglish.com','',2,2,'0',12,106,'190721',0,0,128,1,1,'0',1,NULL),
(1,'Clarity test account','TEST','','',0,0,'1',12,1,'',1,0,1,1,0,NULL,0,NULL),
(14030,'The British Council','GLOBAL','','',2,0,'',13,244571,'Added for AWS switch',1,0,2,1,0,NULL,0,NULL);
/*!40000 ALTER TABLE `T_AccountRoot` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-02-02 14:54:47

INSERT INTO `T_User` (`F_UserID`,`F_UserName`,`F_UserSettings`,`F_ScratchPadFile`,`F_Password`,`F_StudentID`,`F_Email`,`F_Birthday`,`F_Country`,`F_custom1`,`F_custom2`,`F_custom3`,`F_custom4`,`F_ScratchPad`,`F_FullName`,`F_AccountStatus`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_ActivationKey`,`F_RegistrationDate`,`F_ExpiryDate`,`F_Company`,`F_City`,`F_StartDate`,`F_LicenceID`,`F_UserIP`,`F_RegisterMethod`,`F_ContactMethod`) VALUES (100,'India_admin',0,NULL,'clarity88',NULL,'Kevin.McLaven@in.britishcouncil.org',NULL,'','','','','',NULL,NULL,0,2,0,1,NULL,'2011-06-01 08:00:00',NULL,'','',NULL,NULL,NULL,NULL,'');
INSERT INTO `T_User` (`F_UserID`,`F_UserName`,`F_UserSettings`,`F_ScratchPadFile`,`F_Password`,`F_StudentID`,`F_Email`,`F_Birthday`,`F_Country`,`F_custom1`,`F_custom2`,`F_custom3`,`F_custom4`,`F_ScratchPad`,`F_FullName`,`F_AccountStatus`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_ActivationKey`,`F_RegistrationDate`,`F_ExpiryDate`,`F_Company`,`F_City`,`F_StartDate`,`F_LicenceID`,`F_UserIP`,`F_RegisterMethod`,`F_ContactMethod`) VALUES (101,'China_admin',0,NULL,'clarity88',NULL,'James.Shipton',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,2,0,1,NULL,'2011-06-01 08:00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `T_User` (`F_UserID`,`F_UserName`,`F_UserSettings`,`F_ScratchPadFile`,`F_Password`,`F_StudentID`,`F_Email`,`F_Birthday`,`F_Country`,`F_custom1`,`F_custom2`,`F_custom3`,`F_custom4`,`F_ScratchPad`,`F_FullName`,`F_AccountStatus`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_ActivationKey`,`F_RegistrationDate`,`F_ExpiryDate`,`F_Company`,`F_City`,`F_StartDate`,`F_LicenceID`,`F_UserIP`,`F_RegisterMethod`,`F_ContactMethod`) VALUES (102,'AMESA_admin',0,NULL,'clarity88',NULL,'martin.lowder@britishcouncil.org',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,2,0,1,NULL,'2011-06-01 08:00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `T_User` (`F_UserID`,`F_UserName`,`F_UserSettings`,`F_ScratchPadFile`,`F_Password`,`F_StudentID`,`F_Email`,`F_Birthday`,`F_Country`,`F_custom1`,`F_custom2`,`F_custom3`,`F_custom4`,`F_ScratchPad`,`F_FullName`,`F_AccountStatus`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_ActivationKey`,`F_RegistrationDate`,`F_ExpiryDate`,`F_Company`,`F_City`,`F_StartDate`,`F_LicenceID`,`F_UserIP`,`F_RegisterMethod`,`F_ContactMethod`) VALUES (103,'SEAsia_admin',0,NULL,'clarity88',NULL,'Kevin.McLaven@in.britishcouncil.org',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,2,0,1,NULL,'2011-06-01 08:00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `T_User` (`F_UserID`,`F_UserName`,`F_UserSettings`,`F_ScratchPadFile`,`F_Password`,`F_StudentID`,`F_Email`,`F_Birthday`,`F_Country`,`F_custom1`,`F_custom2`,`F_custom3`,`F_custom4`,`F_ScratchPad`,`F_FullName`,`F_AccountStatus`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_ActivationKey`,`F_RegistrationDate`,`F_ExpiryDate`,`F_Company`,`F_City`,`F_StartDate`,`F_LicenceID`,`F_UserIP`,`F_RegisterMethod`,`F_ContactMethod`) VALUES (104,'Europe_admin',0,NULL,'clarity88',NULL,'martin.lowder@britishcouncil.org',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,2,0,1,NULL,'2011-06-01 08:00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `T_User` (`F_UserID`,`F_UserName`,`F_UserSettings`,`F_ScratchPadFile`,`F_Password`,`F_StudentID`,`F_Email`,`F_Birthday`,`F_Country`,`F_custom1`,`F_custom2`,`F_custom3`,`F_custom4`,`F_ScratchPad`,`F_FullName`,`F_AccountStatus`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_ActivationKey`,`F_RegistrationDate`,`F_ExpiryDate`,`F_Company`,`F_City`,`F_StartDate`,`F_LicenceID`,`F_UserIP`,`F_RegisterMethod`,`F_ContactMethod`) VALUES (105,'Americas_admin',0,NULL,'clarity88',NULL,'martin.lowder@britishcouncil.org',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,2,0,1,NULL,'2011-06-01 08:00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `T_User` (`F_UserID`,`F_UserName`,`F_UserSettings`,`F_ScratchPadFile`,`F_Password`,`F_StudentID`,`F_Email`,`F_Birthday`,`F_Country`,`F_custom1`,`F_custom2`,`F_custom3`,`F_custom4`,`F_ScratchPad`,`F_FullName`,`F_AccountStatus`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_ActivationKey`,`F_RegistrationDate`,`F_ExpiryDate`,`F_Company`,`F_City`,`F_StartDate`,`F_LicenceID`,`F_UserIP`,`F_RegisterMethod`,`F_ContactMethod`) VALUES (106,'anon_admin',0,NULL,'clarity88',NULL,'anon@britishcouncil.org',NULL,'','','','','',NULL,NULL,0,2,0,1,NULL,'2011-06-01 08:00:00',NULL,'','',NULL,NULL,NULL,NULL,'');
INSERT INTO `T_User` (`F_UserID`,`F_UserName`,`F_UserSettings`,`F_ScratchPadFile`,`F_Password`,`F_StudentID`,`F_Email`,`F_Birthday`,`F_Country`,`F_custom1`,`F_custom2`,`F_custom3`,`F_custom4`,`F_ScratchPad`,`F_FullName`,`F_AccountStatus`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_ActivationKey`,`F_RegistrationDate`,`F_ExpiryDate`,`F_Company`,`F_City`,`F_StartDate`,`F_LicenceID`,`F_UserIP`,`F_RegisterMethod`,`F_ContactMethod`) VALUES (244571,'portal_admin',0,NULL,'clarity88','','riaz@riazhaff.co.za',NULL,'','','','','',NULL,NULL,NULL,2,13,NULL,NULL,'2011-07-02 18:10:37',NULL,'','',NULL,1321691154041,'175.41.136.103',NULL,'');
INSERT INTO `T_User` (`F_UserID`,`F_UserName`,`F_UserSettings`,`F_ScratchPadFile`,`F_Password`,`F_StudentID`,`F_Email`,`F_Birthday`,`F_Country`,`F_custom1`,`F_custom2`,`F_custom3`,`F_custom4`,`F_ScratchPad`,`F_FullName`,`F_AccountStatus`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_ActivationKey`,`F_RegistrationDate`,`F_ExpiryDate`,`F_Company`,`F_City`,`F_StartDate`,`F_LicenceID`,`F_UserIP`,`F_RegisterMethod`,`F_ContactMethod`) VALUES (244572,'Clarity_admin',0,NULL,'clarity88','','adrian@clarityenglish.com',NULL,'','','','','',NULL,NULL,NULL,2,13,NULL,NULL,'2011-07-02 18:10:37',NULL,'','',NULL,1321691154041,'175.41.136.103',NULL,'');

/*
-- Query: select * from GlobalRoadToIELTS.T_Membership where F_UserID in (1,100,101,102,103,104,105,106,244571)
LIMIT 0, 1000

-- Date: 2012-02-02 15:22
*/
INSERT INTO `T_Membership` (`F_UserID`,`F_GroupID`,`F_RootID`) VALUES (100,100,100);
INSERT INTO `T_Membership` (`F_UserID`,`F_GroupID`,`F_RootID`) VALUES (101,171,101);
INSERT INTO `T_Membership` (`F_UserID`,`F_GroupID`,`F_RootID`) VALUES (102,167,167);
INSERT INTO `T_Membership` (`F_UserID`,`F_GroupID`,`F_RootID`) VALUES (103,168,168);
INSERT INTO `T_Membership` (`F_UserID`,`F_GroupID`,`F_RootID`) VALUES (104,169,169);
INSERT INTO `T_Membership` (`F_UserID`,`F_GroupID`,`F_RootID`) VALUES (105,170,170);
INSERT INTO `T_Membership` (`F_UserID`,`F_GroupID`,`F_RootID`) VALUES (106,312,171);
INSERT INTO `T_Membership` (`F_UserID`,`F_GroupID`,`F_RootID`) VALUES (244571,22148,14030);
INSERT INTO `T_Membership` (`F_UserID`,`F_GroupID`,`F_RootID`) VALUES (244572,22148,1);

/*
-- Query: select * from GlobalRoadToIELTS.T_Groupstructure where F_GroupID in (100,171,167,168,169,170,312,22148)
LIMIT 0, 1000

-- Date: 2012-02-02 15:23
*/
INSERT INTO `T_Groupstructure` (`F_GroupID`,`F_GroupName`,`F_GroupDescription`,`F_GroupParent`,`F_GroupType`,`F_GroupLogoImage`,`F_SelfRegister`,`F_Verified`,`F_LoginOption`,`F_lastVisit`,`F_RootDominant`,`F_custom1name`,`F_custom2name`,`F_custom3name`,`F_custom4name`,`F_EnableMGS`,`F_MGSName`) VALUES (100,'India','BC India',100,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `T_Groupstructure` (`F_GroupID`,`F_GroupName`,`F_GroupDescription`,`F_GroupParent`,`F_GroupType`,`F_GroupLogoImage`,`F_SelfRegister`,`F_Verified`,`F_LoginOption`,`F_lastVisit`,`F_RootDominant`,`F_custom1name`,`F_custom2name`,`F_custom3name`,`F_custom4name`,`F_EnableMGS`,`F_MGSName`) VALUES (167,'The British Council AMESA','',167,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'','','','',0,NULL);
INSERT INTO `T_Groupstructure` (`F_GroupID`,`F_GroupName`,`F_GroupDescription`,`F_GroupParent`,`F_GroupType`,`F_GroupLogoImage`,`F_SelfRegister`,`F_Verified`,`F_LoginOption`,`F_lastVisit`,`F_RootDominant`,`F_custom1name`,`F_custom2name`,`F_custom3name`,`F_custom4name`,`F_EnableMGS`,`F_MGSName`) VALUES (168,'The British Council SEAsia','',168,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'','','','',0,NULL);
INSERT INTO `T_Groupstructure` (`F_GroupID`,`F_GroupName`,`F_GroupDescription`,`F_GroupParent`,`F_GroupType`,`F_GroupLogoImage`,`F_SelfRegister`,`F_Verified`,`F_LoginOption`,`F_lastVisit`,`F_RootDominant`,`F_custom1name`,`F_custom2name`,`F_custom3name`,`F_custom4name`,`F_EnableMGS`,`F_MGSName`) VALUES (169,'The British Council Europe','',169,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'','','','',0,NULL);
INSERT INTO `T_Groupstructure` (`F_GroupID`,`F_GroupName`,`F_GroupDescription`,`F_GroupParent`,`F_GroupType`,`F_GroupLogoImage`,`F_SelfRegister`,`F_Verified`,`F_LoginOption`,`F_lastVisit`,`F_RootDominant`,`F_custom1name`,`F_custom2name`,`F_custom3name`,`F_custom4name`,`F_EnableMGS`,`F_MGSName`) VALUES (170,'The British Council Americas','',170,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'','','','',0,NULL);
INSERT INTO `T_Groupstructure` (`F_GroupID`,`F_GroupName`,`F_GroupDescription`,`F_GroupParent`,`F_GroupType`,`F_GroupLogoImage`,`F_SelfRegister`,`F_Verified`,`F_LoginOption`,`F_lastVisit`,`F_RootDominant`,`F_custom1name`,`F_custom2name`,`F_custom3name`,`F_custom4name`,`F_EnableMGS`,`F_MGSName`) VALUES (171,'China','China',171,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `T_Groupstructure` (`F_GroupID`,`F_GroupName`,`F_GroupDescription`,`F_GroupParent`,`F_GroupType`,`F_GroupLogoImage`,`F_SelfRegister`,`F_Verified`,`F_LoginOption`,`F_lastVisit`,`F_RootDominant`,`F_custom1name`,`F_custom2name`,`F_custom3name`,`F_custom4name`,`F_EnableMGS`,`F_MGSName`) VALUES (312,'The British Council Anonymous','',312,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'','','','',0,NULL);
INSERT INTO `T_Groupstructure` (`F_GroupID`,`F_GroupName`,`F_GroupDescription`,`F_GroupParent`,`F_GroupType`,`F_GroupLogoImage`,`F_SelfRegister`,`F_Verified`,`F_LoginOption`,`F_lastVisit`,`F_RootDominant`,`F_custom1name`,`F_custom2name`,`F_custom3name`,`F_custom4name`,`F_EnableMGS`,`F_MGSName`) VALUES (22148,'The British Council','',22148,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'','','','',0,NULL);
INSERT INTO `T_Groupstructure` (`F_GroupID`,`F_GroupName`,`F_GroupDescription`,`F_GroupParent`,`F_GroupType`,`F_GroupLogoImage`,`F_SelfRegister`,`F_Verified`,`F_LoginOption`,`F_lastVisit`,`F_RootDominant`,`F_custom1name`,`F_custom2name`,`F_custom3name`,`F_custom4name`,`F_EnableMGS`,`F_MGSName`) VALUES (22149,'Clarity test account','',22149,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'','','','',0,NULL);
