-- MySQL dump 10.13  Distrib 5.1.56, for pc-linux-gnu (i686)
--
-- Host: claritylive.cjxpltmvwbov.ap-southeast-1.rds.amazonaws.com    Database: global_r2iv2
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
-- Current Database: `global_r2iv2`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `global_r2iv2` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `global_r2iv2`;

--
-- Table structure for table `T_AccountEmails`
--

DROP TABLE IF EXISTS `T_AccountEmails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_AccountEmails` (
  `F_RootID` int(11) NOT NULL,
  `F_Email` varchar(256) DEFAULT NULL,
  `F_MessageType` smallint(5) unsigned DEFAULT '1',
  `F_AdminUser` tinyint(1) unsigned DEFAULT '0',
  KEY `Index_1` (`F_RootID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `T_AccountRoot`
--

DROP TABLE IF EXISTS `T_AccountRoot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_AccountRoot` (
  `F_RootID` int(10) NOT NULL AUTO_INCREMENT,
  `F_Name` varchar(128) NOT NULL,
  `F_Prefix` varchar(12) DEFAULT NULL,
  `F_Email` varchar(256) DEFAULT NULL,
  `F_Logo` varchar(128) DEFAULT NULL,
  `F_TermsConditions` smallint(5) DEFAULT '0',
  `F_AccountStatus` smallint(5) DEFAULT '0',
  `F_InvoiceNumber` varchar(32) DEFAULT NULL,
  `F_ResellerCode` smallint(5) DEFAULT '0',
  `F_AdminUserID` int(10) DEFAULT NULL,
  `F_Reference` varchar(1024) DEFAULT NULL,
  `F_Verified` smallint(5) NOT NULL DEFAULT '1',
  `F_SelfRegister` smallint(5) NOT NULL DEFAULT '0',
  `F_LoginOption` smallint(5) NOT NULL DEFAULT '1',
  `F_AccountType` smallint(5) NOT NULL DEFAULT '1',
  `F_SelfHost` tinyint(4) DEFAULT '0',
  `F_SelfHostDomain` varchar(64) DEFAULT NULL,
  `F_OptOutEmails` tinyint(4) NOT NULL DEFAULT '0',
  `F_OptOutEmailDate` datetime DEFAULT NULL,
  PRIMARY KEY (`F_RootID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `T_Accounts`
--

DROP TABLE IF EXISTS `T_Accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_Accounts` (
  `F_RootID` int(10) NOT NULL,
  `F_ProductCode` smallint(5) NOT NULL,
  `F_MaxStudents` int(10) NOT NULL DEFAULT '1',
  `F_MaxAuthors` int(10) NOT NULL DEFAULT '1',
  `F_MaxTeachers` int(10) NOT NULL DEFAULT '0',
  `F_MaxReporters` int(10) NOT NULL DEFAULT '0',
  `F_ExpiryDate` datetime NOT NULL,
  `F_ContentLocation` varchar(128) DEFAULT NULL,
  `F_LanguageCode` varchar(8) NOT NULL DEFAULT 'EN',
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
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `T_CourseInfo`
--

DROP TABLE IF EXISTS `T_CourseInfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_CourseInfo` (
  `F_ProductCode` int(10) NOT NULL,
  `F_CourseID` bigint(19) NOT NULL,
  KEY `index_01` (`F_ProductCode`),
  KEY `index_02` (`F_CourseID`),
  KEY `index_03` (`F_CourseID`,`F_ProductCode`),
  KEY `index_04` (`F_ProductCode`,`F_CourseID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `T_DirectStart`
--

DROP TABLE IF EXISTS `T_DirectStart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_DirectStart` (
  `F_SecureString` char(64) NOT NULL,
  `F_RootID` int(10) DEFAULT NULL,
  `F_Email` varchar(128) DEFAULT NULL,
  `F_ValidUntilDate` datetime NOT NULL,
  `F_UserName` varchar(64) DEFAULT NULL,
  `F_Password` varchar(32) DEFAULT NULL,
  `F_UserID` int(11) NOT NULL,
  PRIMARY KEY (`F_SecureString`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `T_EditedContent`
--

DROP TABLE IF EXISTS `T_EditedContent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_EditedContent` (
  `F_EditedContentUID` varchar(80) NOT NULL,
  `F_GroupID` int(10) NOT NULL,
  `F_EnabledFlag` int(10) DEFAULT NULL,
  `F_Mode` int(10) NOT NULL DEFAULT '0',
  `F_RelatedUID` varchar(80) DEFAULT NULL,
  `ID` bigint(19) NOT NULL,
  PRIMARY KEY (`F_EditedContentUID`,`F_GroupID`,`F_Mode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `T_ExtraTeacherGroups`
--

DROP TABLE IF EXISTS `T_ExtraTeacherGroups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_ExtraTeacherGroups` (
  `F_UserID` int(10) NOT NULL,
  `F_GroupID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `T_Failsession`
--

DROP TABLE IF EXISTS `T_Failsession`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_Failsession` (
  `F_UserIP` varchar(50) DEFAULT NULL,
  `F_UserHost` varchar(50) DEFAULT NULL,
  `F_StartTime` datetime DEFAULT NULL,
  `F_ProductCode` smallint(5) DEFAULT NULL,
  `F_UserID` int(10) DEFAULT NULL,
  `F_RootID` int(10) DEFAULT NULL,
  `F_ReasonCode` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `T_Groupstructure`
--

DROP TABLE IF EXISTS `T_Groupstructure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_Groupstructure` (
  `F_GroupID` int(10) NOT NULL AUTO_INCREMENT,
  `F_GroupName` varchar(128) DEFAULT NULL,
  `F_GroupDescription` varchar(256) DEFAULT NULL,
  `F_GroupParent` int(10) NOT NULL,
  `F_GroupType` int(10) DEFAULT NULL,
  `F_GroupLogoImage` varchar(128) DEFAULT NULL,
  `F_SelfRegister` smallint(5) DEFAULT NULL,
  `F_Verified` smallint(5) DEFAULT NULL,
  `F_LoginOption` smallint(5) DEFAULT NULL,
  `F_lastVisit` varchar(24) DEFAULT NULL,
  `F_RootDominant` smallint(5) DEFAULT NULL,
  `F_custom1name` varchar(50) DEFAULT NULL,
  `F_custom2name` varchar(50) DEFAULT NULL,
  `F_custom3name` varchar(50) DEFAULT NULL,
  `F_custom4name` varchar(50) DEFAULT NULL,
  `F_EnableMGS` smallint(5) DEFAULT NULL,
  `F_MGSName` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`F_GroupID`),
  KEY `index_01` (`F_GroupID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `T_HiddenContent`
--

DROP TABLE IF EXISTS `T_HiddenContent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_HiddenContent` (
  `F_HiddenContentUID` char(80) NOT NULL,
  `F_GroupID` int(10) NOT NULL,
  `F_ProductCode` smallint(5) DEFAULT NULL,
  `F_CourseID` bigint(19) DEFAULT NULL,
  `F_UnitID` bigint(19) DEFAULT NULL,
  `F_ExerciseID` bigint(19) DEFAULT NULL,
  `F_EnabledFlag` int(10) NOT NULL,
  PRIMARY KEY (`F_HiddenContentUID`,`F_GroupID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `T_LicenceAttributes`
--

DROP TABLE IF EXISTS `T_LicenceAttributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_LicenceAttributes` (
  `F_RootID` int(10) NOT NULL,
  `F_Key` varchar(128) NOT NULL,
  `F_Value` varchar(2048) NOT NULL,
  `F_ProductCode` int(10) DEFAULT NULL,
  UNIQUE KEY `IX_T_LicenceAttributes` (`F_RootID`,`F_Key`,`F_ProductCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `T_LicenceControl`
--

DROP TABLE IF EXISTS `T_LicenceControl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_LicenceControl` (
  `F_LicenceID` int(11) NOT NULL AUTO_INCREMENT,
  `F_ProductCode` smallint(5) NOT NULL,
  `F_RootID` int(11) NOT NULL,
  `F_UserID` int(11) NOT NULL,
  `F_LastUpdateTime` datetime DEFAULT NULL,
  PRIMARY KEY (`F_LicenceID`),
  KEY `Index_20` (`F_UserID`,`F_ProductCode`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `T_Licences`
--

DROP TABLE IF EXISTS `T_Licences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_Licences` (
  `F_UserIP` varchar(50) DEFAULT NULL,
  `F_UserHost` varchar(50) DEFAULT NULL,
  `F_StartTime` datetime DEFAULT NULL,
  `F_LastUpdateTime` datetime DEFAULT NULL,
  `F_LicenceID` int(10) NOT NULL AUTO_INCREMENT,
  `F_ProductCode` smallint(5) DEFAULT NULL,
  `F_RootID` int(10) NOT NULL,
  `F_UserID` int(10) DEFAULT NULL,
  PRIMARY KEY (`F_LicenceID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `T_Log`
--

DROP TABLE IF EXISTS `T_Log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_Log` (
  `F_LogID` int(11) NOT NULL AUTO_INCREMENT,
  `F_ProductName` varchar(100) NOT NULL,
  `F_RootID` int(11) DEFAULT NULL,
  `F_UserID` int(11) DEFAULT NULL,
  `F_Date` datetime NOT NULL,
  `F_Level` int(11) DEFAULT NULL,
  `F_Message` text,
  `F_LogCode` int(11) DEFAULT NULL,
  PRIMARY KEY (`F_LogID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `T_Membership`
--

DROP TABLE IF EXISTS `T_Membership`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_Membership` (
  `F_UserID` int(10) NOT NULL,
  `F_GroupID` int(10) NOT NULL,
  `F_RootID` int(10) NOT NULL,
  UNIQUE KEY `Index_2` (`F_GroupID`,`F_UserID`),
  KEY `Index_1` (`F_RootID`),
  KEY `Index_3` (`F_GroupID`,`F_RootID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `T_PackageContents`
--

DROP TABLE IF EXISTS `T_PackageContents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_PackageContents` (
  `F_PackageID` smallint(5) NOT NULL,
  `F_ProductCode` smallint(5) NOT NULL,
  `F_CourseID` bigint(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`F_PackageID`,`F_ProductCode`,`F_CourseID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `T_Registration`
--

DROP TABLE IF EXISTS `T_Registration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_Registration` (
  `F_InstitutionName` varchar(50) DEFAULT NULL,
  `F_Product` varchar(50) NOT NULL,
  `F_ExpiryDate` datetime DEFAULT NULL,
  `F_StudentNo` decimal(18,0) DEFAULT NULL,
  `F_Licencing` varchar(20) DEFAULT NULL,
  `F_CreateDate` datetime DEFAULT NULL,
  `F_UserID` int(10) DEFAULT NULL,
  `F_MaxStu` decimal(18,0) DEFAULT NULL,
  `F_Serial` varchar(50) DEFAULT NULL,
  `F_Addr1` varchar(200) DEFAULT NULL,
  `F_Addr2` varchar(200) DEFAULT NULL,
  `F_Addr3` varchar(200) DEFAULT NULL,
  `F_Addr4` varchar(200) DEFAULT NULL,
  `F_City` varchar(50) DEFAULT NULL,
  `F_State` varchar(50) DEFAULT NULL,
  `F_PostCode` varchar(50) DEFAULT NULL,
  `F_ContactTitle` varchar(50) DEFAULT NULL,
  `F_ContactName` varchar(100) DEFAULT NULL,
  `F_ContactJob` varchar(100) DEFAULT NULL,
  `F_Tel` varchar(50) DEFAULT NULL,
  `F_Fax` varchar(50) DEFAULT NULL,
  `F_Country` varchar(50) DEFAULT NULL,
  `F_InstType` varchar(50) DEFAULT NULL,
  `F_Email` varchar(50) DEFAULT NULL,
  `F_IP` varchar(20) DEFAULT NULL,
  `F_MachineID` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
  `F_Email` varchar(128) DEFAULT NULL,
  `F_DisplayOrder` smallint(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `T_Score`
--

DROP TABLE IF EXISTS `T_Score`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_Score` (
  `F_UserID` int(11) NOT NULL,
  `F_DateStamp` datetime NOT NULL,
  `F_ExerciseID` bigint(20) NOT NULL,
  `F_Score` int(11) NOT NULL,
  `F_UnitID` bigint(20) NOT NULL,
  `F_Duration` int(11) NOT NULL,
  `F_ScoreCorrect` int(11) DEFAULT NULL,
  `F_ScoreWrong` int(11) DEFAULT NULL,
  `F_ScoreMissed` int(11) DEFAULT NULL,
  `F_SessionID` int(11) NOT NULL,
  `F_TestUnits` varchar(64) DEFAULT NULL,
  `F_CourseID` bigint(20) NOT NULL DEFAULT '0',
  `F_ProductCode` smallint(5) DEFAULT NULL,
  PRIMARY KEY (`F_UserID`,`F_ExerciseID`,`F_DateStamp`,`F_CourseID`),
  KEY `Index_12` (`F_ScoreCorrect`,`F_SessionID`,`F_UserID`,`F_ExerciseID`,`F_Score`),
  KEY `Index_4` (`F_SessionID`),
  KEY `index_02` (`F_CourseID`),
  KEY `index_03` (`F_ExerciseID`),
  KEY `index_04` (`F_UserID`),
  KEY `index_05` (`F_ExerciseID`,`F_UserID`),
  KEY `index_01` (`F_ExerciseID`,`F_UserID`,`F_DateStamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
/*!50100 PARTITION BY HASH (F_CourseID)
PARTITIONS 200 */;
/*!40101 SET character_set_client = @saved_cs_client */;
-- add the partition after the data is in
-- and unless you clean the table of duplicates first, you will have to remove the primary key for the initial population
-- ALTER TABLE `global_r2iv2`.`T_Score` ADD COLUMN `F_ProductCode` SMALLINT(5) NULL DEFAULT NULL  AFTER `F_CourseID` ;

--
-- Table structure for table `T_ScoreAnonymous`
--

DROP TABLE IF EXISTS `T_ScoreAnonymous`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_ScoreAnonymous` (
  `F_UserID` int(11) NOT NULL,
  `F_DateStamp` datetime DEFAULT NULL,
  `F_ExerciseID` bigint(20) DEFAULT NULL,
  `F_Score` int(11) NOT NULL,
  `F_UnitID` bigint(20) NOT NULL,
  `F_Duration` int(11) NOT NULL,
  `F_ScoreCorrect` int(11) DEFAULT NULL,
  `F_ScoreWrong` int(11) DEFAULT NULL,
  `F_ScoreMissed` int(11) DEFAULT NULL,
  `F_SessionID` int(11) NOT NULL,
  `F_TestUnits` varchar(64) DEFAULT NULL,
  `F_CourseID` bigint(20) DEFAULT NULL,
  `F_ProductCode` smallint(5) DEFAULT NULL,
  KEY `index_03` (`F_ExerciseID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `T_ScoreCache`
--

DROP TABLE IF EXISTS `T_ScoreCache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_ScoreCache` (
  `F_CacheID` int(11) NOT NULL AUTO_INCREMENT,
  `F_ProductCode` smallint(5) NOT NULL,
  `F_CourseID` bigint(20) NOT NULL,
  `F_AverageScore` tinyint(4) unsigned NOT NULL DEFAULT '0',
  `F_AverageDuration` int(11) unsigned NOT NULL DEFAULT '0',
  `F_Count` mediumint(9) unsigned NOT NULL DEFAULT '0',
  `F_DateStamp` datetime DEFAULT NULL,
  `F_Country` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`F_CacheID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `T_ScoreDetail`
--

DROP TABLE IF EXISTS `T_ScoreDetail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_ScoreDetail` (
  `F_UserID` int(10) NOT NULL,
  `F_ExerciseID` bigint(19) NOT NULL,
  `F_ItemID` bigint(19) NOT NULL,
  `F_Score` int(10) DEFAULT NULL,
  `F_SessionID` bigint(19) DEFAULT NULL,
  `F_Detail` varchar(8192) DEFAULT NULL,
  `F_DateStamp` datetime DEFAULT NULL,
  `F_RootID` int(10) DEFAULT NULL,
  `F_UnitID` bigint(19) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `T_SerialNumberAdmin`
--

DROP TABLE IF EXISTS `T_SerialNumberAdmin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_SerialNumberAdmin` (
  `F_SerialNumber` varchar(50) NOT NULL,
  `F_Status` int(10) NOT NULL,
  `F_CreateDate` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `T_Session`
--

DROP TABLE IF EXISTS `T_Session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_Session` (
  `F_SessionID` int(11) NOT NULL AUTO_INCREMENT,
  `F_UserID` int(11) NOT NULL,
  `F_StartDateStamp` datetime DEFAULT NULL,
  `F_EndDateStamp` datetime DEFAULT NULL,
  `F_CourseName` varchar(64) DEFAULT NULL,
  `F_CourseID` bigint(20) DEFAULT NULL,
  `F_RootID` int(11) DEFAULT '1',
  `F_Duration` int(11) DEFAULT NULL,
  `F_ProductCode` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`F_SessionID`,`F_ProductCode`),
  KEY `Index_11` (`F_RootID`,`F_ProductCode`,`F_StartDateStamp`,`F_UserID`),
  KEY `Index_5` (`F_SessionID`,`F_CourseID`,`F_RootID`,`F_UserID`),
  KEY `Index_4` (`F_UserID`,`F_CourseID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1
/*!50100 PARTITION BY HASH (F_ProductCode)
PARTITIONS 35 */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `T_Subscription`
--

DROP TABLE IF EXISTS `T_Subscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_Subscription` (
  `F_SubscriptionID` int(10) NOT NULL AUTO_INCREMENT,
  `F_FullName` varchar(255) NOT NULL,
  `F_Email` varchar(128) NOT NULL,
  `F_Country` varchar(64) DEFAULT NULL,
  `F_DeliveryFrequency` int(10) DEFAULT NULL,
  `F_ContactMethod` varchar(255) DEFAULT NULL,
  `F_LanguageCode` varchar(16) DEFAULT NULL,
  `F_ProductCode` smallint(5) DEFAULT NULL,
  `F_StartDate` datetime DEFAULT NULL,
  `F_ExpiryDate` datetime DEFAULT NULL,
  `F_Password` varchar(32) DEFAULT NULL,
  `F_Checksum` varchar(256) DEFAULT NULL,
  `F_Status` varchar(32) DEFAULT NULL,
  `F_DiscountCode` varchar(32) DEFAULT NULL,
  `F_RootID` int(11) DEFAULT NULL,
  `F_OfferID` smallint(5) DEFAULT NULL,
  PRIMARY KEY (`F_SubscriptionID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `T_User`
--

DROP TABLE IF EXISTS `T_User`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_User` (
  `F_UserID` int(10) NOT NULL AUTO_INCREMENT,
  `F_UserName` varchar(64) DEFAULT NULL,
  `F_UserSettings` int(10) DEFAULT '0',
  `F_ScratchPadFile` varchar(50) DEFAULT NULL,
  `F_Password` varchar(32) DEFAULT NULL,
  `F_StudentID` varchar(32) DEFAULT NULL,
  `F_Email` varchar(128) DEFAULT NULL,
  `F_Birthday` datetime DEFAULT NULL,
  `F_Country` varchar(64) DEFAULT NULL,
  `F_custom1` varchar(64) DEFAULT NULL,
  `F_custom2` varchar(64) DEFAULT NULL,
  `F_custom3` varchar(64) DEFAULT NULL,
  `F_custom4` varchar(64) DEFAULT NULL,
  `F_ScratchPad` longtext,
  `F_FullName` varchar(255) DEFAULT NULL,
  `F_AccountStatus` int(10) DEFAULT NULL,
  `F_UserType` smallint(5) DEFAULT NULL,
  `F_UserProfileOption` int(10) DEFAULT NULL,
  `F_UniqueName` smallint(5) DEFAULT NULL,
  `F_ActivationKey` varchar(20) DEFAULT NULL,
  `F_RegistrationDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `F_ExpiryDate` datetime DEFAULT NULL,
  `F_Company` varchar(64) DEFAULT NULL,
  `F_City` varchar(64) DEFAULT NULL,
  `F_StartDate` datetime DEFAULT NULL,
  `F_LicenceID` bigint(19) DEFAULT NULL,
  `F_UserIP` varchar(50) DEFAULT NULL,
  `F_RegisterMethod` char(16) DEFAULT NULL,
  `F_ContactMethod` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`F_UserID`),
  UNIQUE KEY `Index_7` (`F_UserType`,`F_UserID`,`F_ExpiryDate`),
  UNIQUE KEY `Index_8` (`F_UserName`,`F_UserID`,`F_StudentID`),
  KEY `index_01` (`F_UserID`,`F_UserName`),
  KEY `index_03` (`F_UserID`,`F_UserType`),
  KEY `index_02` (`F_UserType`),
  KEY `index_04` (`F_UserType`,`F_UserID`,`F_UserName`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-02-02 14:00:14
