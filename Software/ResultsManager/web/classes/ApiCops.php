<?php
/*
 * For methods that are only relevant to API calls and not part of Couloir real objects
 */

class ApiCops {
	
	var $db;
	
	function ApiCops($db) {
		$this->db = $db;
		
		$this->copyOps = new CopyOps();
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
	}

	/**
	 * This will initialise data used in test scripts. It can run in any database.
     * Extra accounts/users can be added when new test conditions require them.
     * This is called before each test script runs.
	 */
	function runTestingDataInitialisation() {
	    // Initialise the fixed data
        $rootId = 201;
        $groupId = 501;
        $userId = 401;
        $prefix = 'TD01';
        $productCode = 68;
        $licenceId = 1;
        $scoreId = 1;
        $sessionId = 1;

        $sqls = array();

        // Delete records for rootId and userId
        $sqls = $this->buildDeleteSQLs($rootId, $prefix, $groupId, $sqls);

        // First user is always the admin
        // Set up account and group
        $sqls[] = "INSERT INTO `T_AccountRoot` (`F_RootID`,`F_Name`,`F_Prefix`,`F_Email`,`F_Logo`,`F_TermsConditions`,`F_AccountStatus`,`F_InvoiceNumber`,`F_ResellerCode`,`F_AdminUserID`,`F_Reference`,`F_Verified`,`F_SelfRegister`,`F_LoginOption`,`F_AccountType`,`F_SelfHost`,`F_SelfHostDomain`,`F_OptOutEmails`,`F_OptOutEmailDate`,`F_CustomerType`,`F_UseOldLicenceCount`) VALUES ($rootId,'Testing Data 01','$prefix',NULL,'',2,2,'201801',46,$userId,'',1,0,128,1,0,NULL,0,NULL,0,0);";
        $sqls[] = "INSERT INTO `T_Accounts` (`F_RootID`,`F_ProductCode`,`F_MaxStudents`,`F_MaxAuthors`,`F_MaxTeachers`,`F_MaxReporters`,`F_ExpiryDate`,`F_ContentLocation`,`F_LanguageCode`,`F_ProductVersion`,`F_MGSRoot`,`F_StartPage`,`F_LicenceFile`,`F_LicenceStartDate`,`F_LicenceType`,`F_Checksum`,`F_DeliveryFrequency`,`F_LicenceClearanceDate`,`F_LicenceClearanceFrequency`,`F_LoginModifier`) VALUES ($rootId,2,0,0,5,10,'2019-12-31 23:59:59',NULL,'EN','FV',NULL,'','','2018-01-01 00:00:00',1,'7d49bd51b339cddfe30fe6b2b6ef68d38da9299c71e9de7140c4f070e92ce814',NULL,'2018-01-01 00:00:00','1 year',NULL);";
        $sqls[] = "INSERT INTO `T_Accounts` (`F_RootID`,`F_ProductCode`,`F_MaxStudents`,`F_MaxAuthors`,`F_MaxTeachers`,`F_MaxReporters`,`F_ExpiryDate`,`F_ContentLocation`,`F_LanguageCode`,`F_ProductVersion`,`F_MGSRoot`,`F_StartPage`,`F_LicenceFile`,`F_LicenceStartDate`,`F_LicenceType`,`F_Checksum`,`F_DeliveryFrequency`,`F_LicenceClearanceDate`,`F_LicenceClearanceFrequency`,`F_LoginModifier`) VALUES ($rootId,56,5,0,5,10,'2019-12-31 23:59:59',NULL,'EN','FV',NULL,'','','2018-09-20 00:00:00',1,'49bfc9017a1dc087fff2ba7d300fc68cdece5860bc05e6d748475edb754e1beb',NULL,'2018-09-20 00:00:00','1 year',NULL);";
        $sqls[] = "INSERT INTO `T_Accounts` (`F_RootID`,`F_ProductCode`,`F_MaxStudents`,`F_MaxAuthors`,`F_MaxTeachers`,`F_MaxReporters`,`F_ExpiryDate`,`F_ContentLocation`,`F_LanguageCode`,`F_ProductVersion`,`F_MGSRoot`,`F_StartPage`,`F_LicenceFile`,`F_LicenceStartDate`,`F_LicenceType`,`F_Checksum`,`F_DeliveryFrequency`,`F_LicenceClearanceDate`,`F_LicenceClearanceFrequency`,`F_LoginModifier`) VALUES ($rootId,63,5,0,5,10,'2019-12-31 23:59:59',NULL,'EN','FV',NULL,'','','2018-09-20 00:00:00',1,'60f0eba5c9ce1f6185508dd222702aa143232d90cca74770db440a0fb3fdb76f',NULL,'2018-09-20 00:00:00','1 year',NULL);";
        $sqls[] = "INSERT INTO `T_Accounts` (`F_RootID`,`F_ProductCode`,`F_MaxStudents`,`F_MaxAuthors`,`F_MaxTeachers`,`F_MaxReporters`,`F_ExpiryDate`,`F_ContentLocation`,`F_LanguageCode`,`F_ProductVersion`,`F_MGSRoot`,`F_StartPage`,`F_LicenceFile`,`F_LicenceStartDate`,`F_LicenceType`,`F_Checksum`,`F_DeliveryFrequency`,`F_LicenceClearanceDate`,`F_LicenceClearanceFrequency`,`F_LoginModifier`) VALUES ($rootId,68,5,0,5,10,'2019-12-31 23:59:59',NULL,'EN','FV',NULL,'','','2018-09-20 00:00:00',1,'8e6f6fceb4640edd69bda08a22366cb0acb83f0e9f06938f6a4538656f27277d',NULL,'2018-09-20 00:00:00','1 year',NULL);";
        $sqls[] = "INSERT INTO `T_Accounts` (`F_RootID`,`F_ProductCode`,`F_MaxStudents`,`F_MaxAuthors`,`F_MaxTeachers`,`F_MaxReporters`,`F_ExpiryDate`,`F_ContentLocation`,`F_LanguageCode`,`F_ProductVersion`,`F_MGSRoot`,`F_StartPage`,`F_LicenceFile`,`F_LicenceStartDate`,`F_LicenceType`,`F_Checksum`,`F_DeliveryFrequency`,`F_LicenceClearanceDate`,`F_LicenceClearanceFrequency`,`F_LoginModifier`) VALUES ($rootId,72,5,0,5,10,'2019-12-31 23:59:59',NULL,'EN','FV',NULL,'','','2018-09-20 00:00:00',1,'a0a99c48d3faabdd6b01829d83f81a71e84c719ed7b1e5c38f0e3d42b0188006',NULL,'2018-09-20 00:00:00','1 year',NULL);";
        $sqls[] = "INSERT INTO `T_AccountEmails` (`F_RootID`,`F_Email`,`F_MessageType`,`F_AdminUser`) VALUES ($rootId,NULL,31,1);";
        $sqls[] = "INSERT INTO T_AccountKeys (`F_Prefix`,`F_Key`) VALUES ('$prefix','TD01-201-12345678');";
        $sqls[] = "INSERT INTO `T_Groupstructure` (`F_GroupID`,`F_GroupName`,`F_GroupDescription`,`F_GroupParent`,`F_GroupType`,`F_GroupLogoImage`,`F_SelfRegister`,`F_Verified`,`F_LoginOption`,`F_lastVisit`,`F_RootDominant`,`F_custom1name`,`F_custom2name`,`F_custom3name`,`F_custom4name`,`F_EnableMGS`,`F_MGSName`) VALUES ($groupId,'Testing Data 01','',$groupId,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'','','','',0,NULL);";

        // User and membership table
        $nextUserId = $userId;
        $sqls[] = "INSERT INTO `T_User` (`F_UserID`,`F_UserName`,`F_UserSettings`,`F_Password`,`F_Salt`,`F_StudentID`,`F_Email`,`F_Birthday`,`F_Country`,`F_custom1`,`F_custom2`,`F_custom3`,`F_custom4`,`F_ScratchPad`,`F_FullName`,`F_AccountStatus`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_ActivationKey`,`F_RegistrationDate`,`F_ExpiryDate`,`F_City`,`F_StartDate`,`F_LicenceID`,`F_UserIP`,`F_RegisterMethod`,`F_ContactMethod`,`F_InstanceID`,`F_Memory`) VALUES ($nextUserId,'TD01_admin',0,'TD01_admin',NULL,'TD01_admin','TD01_admin',NULL,'','','','','',NULL,NULL,NULL,2,NULL,NULL,NULL,NULL,NULL,'',NULL,NULL,NULL,NULL,'',NULL,NULL);";
        $sqls[] = "INSERT INTO `T_Membership` (`F_UserID`,`F_GroupID`,`F_RootID`) VALUES ($nextUserId,$groupId,$rootId);";
        $nextUserId++;
        $sqls[] = "INSERT INTO `T_User` (`F_UserID`,`F_UserName`,`F_UserSettings`,`F_Password`,`F_Salt`,`F_StudentID`,`F_Email`,`F_Birthday`,`F_Country`,`F_custom1`,`F_custom2`,`F_custom3`,`F_custom4`,`F_ScratchPad`,`F_FullName`,`F_AccountStatus`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_ActivationKey`,`F_RegistrationDate`,`F_ExpiryDate`,`F_City`,`F_StartDate`,`F_LicenceID`,`F_UserIP`,`F_RegisterMethod`,`F_ContactMethod`,`F_InstanceID`,`F_Memory`) VALUES ($nextUserId,'TD01_user_01',0,'TD01',NULL,'TD01_user_01','user_01@TD01.com',NULL,'','',NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,'',NULL,NULL,NULL,NULL,'',NULL,NULL);";
        $sqls[] = "INSERT INTO `T_Membership` (`F_UserID`,`F_GroupID`,`F_RootID`) VALUES ($nextUserId,$groupId,$rootId);";
        $nextUserId++;
        $sqls[] = "INSERT INTO `T_User` (`F_UserID`,`F_UserName`,`F_UserSettings`,`F_Password`,`F_Salt`,`F_StudentID`,`F_Email`,`F_Birthday`,`F_Country`,`F_custom1`,`F_custom2`,`F_custom3`,`F_custom4`,`F_ScratchPad`,`F_FullName`,`F_AccountStatus`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_ActivationKey`,`F_RegistrationDate`,`F_ExpiryDate`,`F_City`,`F_StartDate`,`F_LicenceID`,`F_UserIP`,`F_RegisterMethod`,`F_ContactMethod`,`F_InstanceID`,`F_Memory`) VALUES ($nextUserId,'TD01_user_02',0,'TD01',NULL,'TD01_user_02','user_02@TD01.com',NULL,'','','','','',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,'2019-09-01 23:59:59','',NULL,NULL,NULL,NULL,'',NULL,NULL);";
        $sqls[] = "INSERT INTO `T_Membership` (`F_UserID`,`F_GroupID`,`F_RootID`) VALUES ($nextUserId,$groupId,$rootId);";
        $nextUserId++;
        $sqls[] = "INSERT INTO `T_User` (`F_UserID`,`F_UserName`,`F_UserSettings`,`F_Password`,`F_Salt`,`F_StudentID`,`F_Email`,`F_Birthday`,`F_Country`,`F_custom1`,`F_custom2`,`F_custom3`,`F_custom4`,`F_ScratchPad`,`F_FullName`,`F_AccountStatus`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_ActivationKey`,`F_RegistrationDate`,`F_ExpiryDate`,`F_City`,`F_StartDate`,`F_LicenceID`,`F_UserIP`,`F_RegisterMethod`,`F_ContactMethod`,`F_InstanceID`,`F_Memory`) VALUES ($nextUserId,'TD01_user_03',0,'TD01',NULL,'TD01_user_03','user_03@TD01.com',NULL,'','','','','',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,'',NULL,NULL,NULL,NULL,'',NULL,NULL);";
        $sqls[] = "INSERT INTO `T_Membership` (`F_UserID`,`F_GroupID`,`F_RootID`) VALUES ($nextUserId,$groupId,$rootId);";
        $nextUserId++;

        // Scores
        $nextUserId = $userId+1; // Start from first student
        $sqls[] = "INSERT INTO `T_Score` (`F_ScoreID`,`F_UserID`,`F_DateStamp`,`F_ExerciseID`,`F_Score`,`F_UnitID`,`F_Duration`,`F_ScoreCorrect`,`F_ScoreWrong`,`F_ScoreMissed`,`F_SessionID`,`F_TestUnits`,`F_CourseID`,`F_ProductCode`) VALUES ($scoreId,$nextUserId,'2018-09-21 00:47:23',2018068010101,38,2018068010100,35,3,2,3,$sessionId,NULL,2018068010000,$productCode);";
        $scoreId++;
        $sqls[] = "INSERT INTO `T_Score` (`F_ScoreID`,`F_UserID`,`F_DateStamp`,`F_ExerciseID`,`F_Score`,`F_UnitID`,`F_Duration`,`F_ScoreCorrect`,`F_ScoreWrong`,`F_ScoreMissed`,`F_SessionID`,`F_TestUnits`,`F_CourseID`,`F_ProductCode`) VALUES ($scoreId,$nextUserId,'2018-09-21 01:01:38',2018068010102,50,2018068010100,28,5,2,3,$sessionId,NULL,2018068010000,$productCode);";
        $scoreId++;
        $sqls[] = "INSERT INTO `T_Score` (`F_ScoreID`,`F_UserID`,`F_DateStamp`,`F_ExerciseID`,`F_Score`,`F_UnitID`,`F_Duration`,`F_ScoreCorrect`,`F_ScoreWrong`,`F_ScoreMissed`,`F_SessionID`,`F_TestUnits`,`F_CourseID`,`F_ProductCode`) VALUES ($scoreId,$nextUserId,'2018-09-21 01:01:53',2018068010103,40,2018068010100,14,4,2,4,$sessionId,NULL,2018068010000,$productCode);";
        $scoreId++;
        $sqls[] = "INSERT INTO `T_Score` (`F_ScoreID`,`F_UserID`,`F_DateStamp`,`F_ExerciseID`,`F_Score`,`F_UnitID`,`F_Duration`,`F_ScoreCorrect`,`F_ScoreWrong`,`F_ScoreMissed`,`F_SessionID`,`F_TestUnits`,`F_CourseID`,`F_ProductCode`) VALUES ($scoreId,$nextUserId,'2018-09-21 01:03:18',2018068010104,40,2018068010100,37,4,2,4,$sessionId,NULL,2018068010000,$productCode);";
        $scoreId++;
        $sqls[] = "INSERT INTO `T_Score` (`F_ScoreID`,`F_UserID`,`F_DateStamp`,`F_ExerciseID`,`F_Score`,`F_UnitID`,`F_Duration`,`F_ScoreCorrect`,`F_ScoreWrong`,`F_ScoreMissed`,`F_SessionID`,`F_TestUnits`,`F_CourseID`,`F_ProductCode`) VALUES ($scoreId,$nextUserId,'2018-09-21 01:03:46',2018068010105,33,2018068010100,28,4,3,5,$sessionId,NULL,2018068010000,$productCode);";
        $scoreId++;
        $sqls[] = "INSERT INTO `T_Score` (`F_ScoreID`,`F_UserID`,`F_DateStamp`,`F_ExerciseID`,`F_Score`,`F_UnitID`,`F_Duration`,`F_ScoreCorrect`,`F_ScoreWrong`,`F_ScoreMissed`,`F_SessionID`,`F_TestUnits`,`F_CourseID`,`F_ProductCode`) VALUES ($scoreId,$nextUserId,'2018-09-21 01:04:07',2018068010106,38,2018068010100,20,3,2,3,$sessionId,NULL,2018068010000,$productCode);";
        $scoreId++;

        // Sessions
        $nextUserId = $userId+1; // Start from first student
        $sqls[] = "INSERT INTO `T_SessionTrack` (`F_SessionID`,`F_UserID`,`F_ProductCode`,`F_RootID`,`F_StartDateStamp`,`F_LastUpdateDateStamp`,`F_Duration`,`F_ContentID`,`F_Data`,`F_Status`) VALUES ($sessionId,$nextUserId,$productCode,$rootId,'2018-09-21 00:45:25','2018-09-21 00:46:37',120,NULL,NULL,0);";
        $nextUserId++;
        $sessionId++;
        $sqls[] = "INSERT INTO `T_SessionTrack` (`F_SessionID`,`F_UserID`,`F_ProductCode`,`F_RootID`,`F_StartDateStamp`,`F_LastUpdateDateStamp`,`F_Duration`,`F_ContentID`,`F_Data`,`F_Status`) VALUES ($sessionId,$nextUserId,$productCode,$rootId,'2018-01-02 00:00:00','2018-01-02 00:30:00',1800,NULL,NULL,0);";
        $nextUserId++;
        $sessionId++;
        $sqls[] = "INSERT INTO `T_SessionTrack` (`F_SessionID`,`F_UserID`,`F_ProductCode`,`F_RootID`,`F_StartDateStamp`,`F_LastUpdateDateStamp`,`F_Duration`,`F_ContentID`,`F_Data`,`F_Status`) VALUES ($sessionId,$nextUserId,$productCode,$rootId,'2017-09-20 00:00:00','2017-09-20 01:00:00',3600,NULL,NULL,0);";
        $nextUserId++;
        $sessionId++;

        // Licences
        $nextUserId = $userId+1; // Start from first student
        $sqls[] = "INSERT INTO `T_CouloirLicenceHolders` (`F_LicenceID`,`F_KeyID`,`F_RootID`,`F_ProductCode`,`F_StartDateStamp`,`F_EndDateStamp`,`F_LicenceType`) VALUES ($licenceId,$nextUserId,$rootId,$productCode,'2018-09-21 00:45:25','2019-09-20 23:59:59',1);";
        $nextUserId++;
        $licenceId++;
        $sqls[] = "INSERT INTO `T_CouloirLicenceHolders` (`F_LicenceID`,`F_KeyID`,`F_RootID`,`F_ProductCode`,`F_StartDateStamp`,`F_EndDateStamp`,`F_LicenceType`) VALUES ($licenceId,$nextUserId,$rootId,$productCode,'2018-01-02 00:00:00','2019-01-01 23:59:59',1);";
        $nextUserId++;
        $licenceId++;
        $sqls[] = "INSERT INTO `T_CouloirLicenceHolders` (`F_LicenceID`,`F_KeyID`,`F_RootID`,`F_ProductCode`,`F_StartDateStamp`,`F_EndDateStamp`,`F_LicenceType`) VALUES ($licenceId,$nextUserId,$rootId,$productCode,'2017-09-20 00:00:00','2018-09-19 23:59:59',1);";
        $nextUserId++;
        $licenceId++;

        /*
         * Now for an AA account
         */
        $rootId = 202;
        $groupId = 502;
        $userId = 411;
        $prefix = 'TD02';
        $productCode = 68;

        // Delete records for rootId and userId
        $sqls = $this->buildDeleteSQLs($rootId, $prefix, $groupId, $sqls);

        // First user is always the admin
        // Set up account and group
        $sqls[] = "INSERT INTO `T_AccountRoot` (`F_RootID`,`F_Name`,`F_Prefix`,`F_Email`,`F_Logo`,`F_TermsConditions`,`F_AccountStatus`,`F_InvoiceNumber`,`F_ResellerCode`,`F_AdminUserID`,`F_Reference`,`F_Verified`,`F_SelfRegister`,`F_LoginOption`,`F_AccountType`,`F_SelfHost`,`F_SelfHostDomain`,`F_OptOutEmails`,`F_OptOutEmailDate`,`F_CustomerType`,`F_UseOldLicenceCount`) VALUES ($rootId,'Testing Data 02','$prefix',NULL,'',2,2,'201801',46,$userId,'',1,21,128,1,0,NULL,0,NULL,0,0);";
        $sqls[] = "INSERT INTO `T_Accounts` (`F_RootID`,`F_ProductCode`,`F_MaxStudents`,`F_MaxAuthors`,`F_MaxTeachers`,`F_MaxReporters`,`F_ExpiryDate`,`F_ContentLocation`,`F_LanguageCode`,`F_ProductVersion`,`F_MGSRoot`,`F_StartPage`,`F_LicenceFile`,`F_LicenceStartDate`,`F_LicenceType`,`F_Checksum`,`F_DeliveryFrequency`,`F_LicenceClearanceDate`,`F_LicenceClearanceFrequency`,`F_LoginModifier`) VALUES ($rootId,2,0,0,1,1,'2019-12-31 23:59:59',NULL,'EN','FV',NULL,'','','2018-01-01 00:00:00',2,'193c3e170b94cb95ea296fe5c62cfc7385dbdf98c5306806163524abc1ffbd6d',NULL,'2018-01-01 00:00:00','1 year',NULL);";
        $sqls[] = "INSERT INTO `T_Accounts` (`F_RootID`,`F_ProductCode`,`F_MaxStudents`,`F_MaxAuthors`,`F_MaxTeachers`,`F_MaxReporters`,`F_ExpiryDate`,`F_ContentLocation`,`F_LanguageCode`,`F_ProductVersion`,`F_MGSRoot`,`F_StartPage`,`F_LicenceFile`,`F_LicenceStartDate`,`F_LicenceType`,`F_Checksum`,`F_DeliveryFrequency`,`F_LicenceClearanceDate`,`F_LicenceClearanceFrequency`,`F_LoginModifier`) VALUES ($rootId,56,1,0,1,1,'2019-12-31 23:59:59',NULL,'EN','FV',NULL,'','','2018-09-21 00:00:00',2,'9e491014a92b065e54547cc278c20ecb4d7c5d69053fcb44b65388e00bf55b1a',NULL,NULL,'',NULL);";
        $sqls[] = "INSERT INTO `T_Accounts` (`F_RootID`,`F_ProductCode`,`F_MaxStudents`,`F_MaxAuthors`,`F_MaxTeachers`,`F_MaxReporters`,`F_ExpiryDate`,`F_ContentLocation`,`F_LanguageCode`,`F_ProductVersion`,`F_MGSRoot`,`F_StartPage`,`F_LicenceFile`,`F_LicenceStartDate`,`F_LicenceType`,`F_Checksum`,`F_DeliveryFrequency`,`F_LicenceClearanceDate`,`F_LicenceClearanceFrequency`,`F_LoginModifier`) VALUES ($rootId,68,1,0,1,1,'2019-12-31 23:59:59',NULL,'EN','FV',NULL,'','','2018-09-21 00:00:00',2,'9a7e0be18ad299b9e975c6dced296a5a5344bc2bd57bf553f50ef60e7b8cc3ac',NULL,NULL,'',NULL);";
        $sqls[] = "INSERT INTO `T_Accounts` (`F_RootID`,`F_ProductCode`,`F_MaxStudents`,`F_MaxAuthors`,`F_MaxTeachers`,`F_MaxReporters`,`F_ExpiryDate`,`F_ContentLocation`,`F_LanguageCode`,`F_ProductVersion`,`F_MGSRoot`,`F_StartPage`,`F_LicenceFile`,`F_LicenceStartDate`,`F_LicenceType`,`F_Checksum`,`F_DeliveryFrequency`,`F_LicenceClearanceDate`,`F_LicenceClearanceFrequency`,`F_LoginModifier`) VALUES ($rootId,72,1,0,1,1,'2019-12-31 23:59:59',NULL,'EN','FV',NULL,'','','2018-09-21 00:00:00',2,'bc57ebaf17e12a5f7422646af915b833b9ef8b306024b81511b23d24e6df2aaf',NULL,NULL,'',NULL);";
        $sqls[] = "INSERT INTO `T_AccountEmails` (`F_RootID`,`F_Email`,`F_MessageType`,`F_AdminUser`) VALUES ($rootId,NULL,31,1);";
        $sqls[] = "INSERT INTO T_AccountKeys (`F_Prefix`,`F_Key`) VALUES ('$prefix','TD02-202-12345678');";
        $sqls[] = "INSERT INTO `T_Groupstructure` (`F_GroupID`,`F_GroupName`,`F_GroupDescription`,`F_GroupParent`,`F_GroupType`,`F_GroupLogoImage`,`F_SelfRegister`,`F_Verified`,`F_LoginOption`,`F_lastVisit`,`F_RootDominant`,`F_custom1name`,`F_custom2name`,`F_custom3name`,`F_custom4name`,`F_EnableMGS`,`F_MGSName`) VALUES ($groupId,'Testing Data 01','',$groupId,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'','','','',0,NULL);";

        // User and membership table
        $nextUserId = $userId;
        $sqls[] = "INSERT INTO `T_User` (`F_UserID`,`F_UserName`,`F_UserSettings`,`F_Password`,`F_Salt`,`F_StudentID`,`F_Email`,`F_Birthday`,`F_Country`,`F_custom1`,`F_custom2`,`F_custom3`,`F_custom4`,`F_ScratchPad`,`F_FullName`,`F_AccountStatus`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_ActivationKey`,`F_RegistrationDate`,`F_ExpiryDate`,`F_City`,`F_StartDate`,`F_LicenceID`,`F_UserIP`,`F_RegisterMethod`,`F_ContactMethod`,`F_InstanceID`,`F_Memory`) VALUES ($nextUserId,'TD02_admin',0,'TD02',NULL,'TD02_admin','TD02_admin',NULL,'','','','','',NULL,NULL,NULL,2,NULL,NULL,NULL,NULL,NULL,'',NULL,NULL,NULL,NULL,'',NULL,NULL);";
        $sqls[] = "INSERT INTO `T_Membership` (`F_UserID`,`F_GroupID`,`F_RootID`) VALUES ($nextUserId,$groupId,$rootId);";
        $nextUserId++;
        $sqls[] = "INSERT INTO `T_User` (`F_UserID`,`F_UserName`,`F_UserSettings`,`F_Password`,`F_Salt`,`F_StudentID`,`F_Email`,`F_Birthday`,`F_Country`,`F_custom1`,`F_custom2`,`F_custom3`,`F_custom4`,`F_ScratchPad`,`F_FullName`,`F_AccountStatus`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_ActivationKey`,`F_RegistrationDate`,`F_ExpiryDate`,`F_City`,`F_StartDate`,`F_LicenceID`,`F_UserIP`,`F_RegisterMethod`,`F_ContactMethod`,`F_InstanceID`,`F_Memory`) VALUES ($nextUserId,'TD02_user_01',0,'TD02',NULL,'TD02_user_01','user_01@TD02.com',NULL,'','',NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,'',NULL,NULL,NULL,NULL,'',NULL,NULL);";
        $sqls[] = "INSERT INTO `T_Membership` (`F_UserID`,`F_GroupID`,`F_RootID`) VALUES ($nextUserId,$groupId,$rootId);";

        // Scores
        $nextUserId = $userId+1; // Start from first student
        $sqls[] = "INSERT INTO `T_Score` (`F_ScoreID`,`F_UserID`,`F_DateStamp`,`F_ExerciseID`,`F_Score`,`F_UnitID`,`F_Duration`,`F_ScoreCorrect`,`F_ScoreWrong`,`F_ScoreMissed`,`F_SessionID`,`F_TestUnits`,`F_CourseID`,`F_ProductCode`) VALUES ($scoreId,$nextUserId,'2018-09-21 00:47:23',2018068010101,38,2018068010100,35,3,2,3,$sessionId,NULL,2018068010000,$productCode);";
        $scoreId++;
        $sqls[] = "INSERT INTO `T_Score` (`F_ScoreID`,`F_UserID`,`F_DateStamp`,`F_ExerciseID`,`F_Score`,`F_UnitID`,`F_Duration`,`F_ScoreCorrect`,`F_ScoreWrong`,`F_ScoreMissed`,`F_SessionID`,`F_TestUnits`,`F_CourseID`,`F_ProductCode`) VALUES ($scoreId,$nextUserId,'2018-09-21 01:01:38',2018068010102,50,2018068010100,28,5,2,3,$sessionId,NULL,2018068010000,$productCode);";
        $scoreId++;
        $sqls[] = "INSERT INTO `T_Score` (`F_ScoreID`,`F_UserID`,`F_DateStamp`,`F_ExerciseID`,`F_Score`,`F_UnitID`,`F_Duration`,`F_ScoreCorrect`,`F_ScoreWrong`,`F_ScoreMissed`,`F_SessionID`,`F_TestUnits`,`F_CourseID`,`F_ProductCode`) VALUES ($scoreId,$nextUserId,'2018-09-21 01:01:53',2018068010103,40,2018068010100,14,4,2,4,$sessionId,NULL,2018068010000,$productCode);";
        $scoreId++;
        $sqls[] = "INSERT INTO `T_Score` (`F_ScoreID`,`F_UserID`,`F_DateStamp`,`F_ExerciseID`,`F_Score`,`F_UnitID`,`F_Duration`,`F_ScoreCorrect`,`F_ScoreWrong`,`F_ScoreMissed`,`F_SessionID`,`F_TestUnits`,`F_CourseID`,`F_ProductCode`) VALUES ($scoreId,$nextUserId,'2018-09-21 01:03:18',2018068010104,40,2018068010100,37,4,2,4,$sessionId,NULL,2018068010000,$productCode);";
        $scoreId++;
        $sqls[] = "INSERT INTO `T_Score` (`F_ScoreID`,`F_UserID`,`F_DateStamp`,`F_ExerciseID`,`F_Score`,`F_UnitID`,`F_Duration`,`F_ScoreCorrect`,`F_ScoreWrong`,`F_ScoreMissed`,`F_SessionID`,`F_TestUnits`,`F_CourseID`,`F_ProductCode`) VALUES ($scoreId,$nextUserId,'2018-09-21 01:03:46',2018068010105,33,2018068010100,28,4,3,5,$sessionId,NULL,2018068010000,$productCode);";
        $scoreId++;
        $sqls[] = "INSERT INTO `T_Score` (`F_ScoreID`,`F_UserID`,`F_DateStamp`,`F_ExerciseID`,`F_Score`,`F_UnitID`,`F_Duration`,`F_ScoreCorrect`,`F_ScoreWrong`,`F_ScoreMissed`,`F_SessionID`,`F_TestUnits`,`F_CourseID`,`F_ProductCode`) VALUES ($scoreId,$nextUserId,'2018-09-21 01:04:07',2018068010106,38,2018068010100,20,3,2,3,$sessionId,NULL,2018068010000,$productCode);";

        // Sessions
        $nextUserId = $userId+1; // Start from first student
        $sqls[] = "INSERT INTO `T_SessionTrack` (`F_SessionID`,`F_UserID`,`F_ProductCode`,`F_RootID`,`F_StartDateStamp`,`F_LastUpdateDateStamp`,`F_Duration`,`F_ContentID`,`F_Data`,`F_Status`) VALUES ($sessionId,$nextUserId,$productCode,$rootId,'2018-09-21 00:45:25','2018-09-21 00:46:37',120,NULL,NULL,0);";
        $sessionId++;

        // Licences
        $nextUserId = $userId+1; // Start from first student
        $sqls[] = "INSERT INTO `T_CouloirLicenceHolders` (`F_LicenceID`,`F_KeyID`,`F_RootID`,`F_ProductCode`,`F_StartDateStamp`,`F_EndDateStamp`,`F_LicenceType`) VALUES ($licenceId,$nextUserId,$rootId,$productCode,'2018-09-21 00:45:25','2018-09-21 02:00:00',2);";
        $licenceId++;

        // For API token testing
        $rootId = 203;
        $groupId = 503;
        $userId = 421;
        $prefix = 'TD03';
        $productCode = 68;
        $licenceType = 8;

        // Delete records for rootId and userId
        $sqls = $this->buildDeleteSQLs($rootId, $prefix, $groupId, $sqls);

        // First user is always the admin
        // Set up account and group
        $sqls[] = "INSERT INTO `T_AccountRoot` (`F_RootID`,`F_Name`,`F_Prefix`,`F_Email`,`F_Logo`,`F_TermsConditions`,`F_AccountStatus`,`F_InvoiceNumber`,`F_ResellerCode`,`F_AdminUserID`,`F_Reference`,`F_Verified`,`F_SelfRegister`,`F_LoginOption`,`F_AccountType`,`F_SelfHost`,`F_SelfHostDomain`,`F_OptOutEmails`,`F_OptOutEmailDate`,`F_CustomerType`,`F_UseOldLicenceCount`) VALUES ($rootId,'Testing Data 03','$prefix',NULL,'',2,2,'201801',46,$userId,'',1,21,128,1,0,NULL,0,NULL,0,0);";
        $sqls[] = "INSERT INTO `T_Accounts` (`F_RootID`,`F_ProductCode`,`F_MaxStudents`,`F_MaxAuthors`,`F_MaxTeachers`,`F_MaxReporters`,`F_ExpiryDate`,`F_ContentLocation`,`F_LanguageCode`,`F_ProductVersion`,`F_MGSRoot`,`F_StartPage`,`F_LicenceFile`,`F_LicenceStartDate`,`F_LicenceType`,`F_Checksum`,`F_DeliveryFrequency`,`F_LicenceClearanceDate`,`F_LicenceClearanceFrequency`,`F_LoginModifier`) VALUES ($rootId,2,0,0,5,10,'2019-12-31 23:59:59',NULL,'EN','FV',NULL,'','','2018-01-01 00:00:00',1,'753ad1b4a97a51961a495e816237cea7c1eccb555db9cff479969a146e94cf9',NULL,'2018-01-01 00:00:00','1 year',NULL);";
        $sqls[] = "INSERT INTO `T_Accounts` (`F_RootID`,`F_ProductCode`,`F_MaxStudents`,`F_MaxAuthors`,`F_MaxTeachers`,`F_MaxReporters`,`F_ExpiryDate`,`F_ContentLocation`,`F_LanguageCode`,`F_ProductVersion`,`F_MGSRoot`,`F_StartPage`,`F_LicenceFile`,`F_LicenceStartDate`,`F_LicenceType`,`F_Checksum`,`F_DeliveryFrequency`,`F_LicenceClearanceDate`,`F_LicenceClearanceFrequency`,`F_LoginModifier`) VALUES ($rootId,56,5,0,5,10,'2019-12-31 23:59:59',NULL,'EN','FV',NULL,'','','2018-09-20 00:00:00',$licenceType,'750339911cd6230cbc810c250c4e39e15bab5760d1f779012020691fbd70c0e8',NULL,'2018-09-20 00:00:00','1 year',NULL);";
        $sqls[] = "INSERT INTO `T_Accounts` (`F_RootID`,`F_ProductCode`,`F_MaxStudents`,`F_MaxAuthors`,`F_MaxTeachers`,`F_MaxReporters`,`F_ExpiryDate`,`F_ContentLocation`,`F_LanguageCode`,`F_ProductVersion`,`F_MGSRoot`,`F_StartPage`,`F_LicenceFile`,`F_LicenceStartDate`,`F_LicenceType`,`F_Checksum`,`F_DeliveryFrequency`,`F_LicenceClearanceDate`,`F_LicenceClearanceFrequency`,`F_LoginModifier`) VALUES ($rootId,63,5,0,5,10,'2019-12-31 23:59:59',NULL,'EN','FV',NULL,'','','2018-09-20 00:00:00',$licenceType,'6bcd53653e65409b7aaae7628105a71bb06210cf74b4bb997081827b1ffef39a',NULL,'2018-09-20 00:00:00','1 year',NULL);";
        $sqls[] = "INSERT INTO `T_Accounts` (`F_RootID`,`F_ProductCode`,`F_MaxStudents`,`F_MaxAuthors`,`F_MaxTeachers`,`F_MaxReporters`,`F_ExpiryDate`,`F_ContentLocation`,`F_LanguageCode`,`F_ProductVersion`,`F_MGSRoot`,`F_StartPage`,`F_LicenceFile`,`F_LicenceStartDate`,`F_LicenceType`,`F_Checksum`,`F_DeliveryFrequency`,`F_LicenceClearanceDate`,`F_LicenceClearanceFrequency`,`F_LoginModifier`) VALUES ($rootId,68,5,0,5,10,'2019-12-31 23:59:59',NULL,'EN','FV',NULL,'','','2018-09-20 00:00:00',$licenceType,'3054ba04289f4910acfede106cb5308dd22b52553e36c8b1e0b54953fbe38796',NULL,'2018-09-20 00:00:00','1 year',NULL);";
        $sqls[] = "INSERT INTO `T_Accounts` (`F_RootID`,`F_ProductCode`,`F_MaxStudents`,`F_MaxAuthors`,`F_MaxTeachers`,`F_MaxReporters`,`F_ExpiryDate`,`F_ContentLocation`,`F_LanguageCode`,`F_ProductVersion`,`F_MGSRoot`,`F_StartPage`,`F_LicenceFile`,`F_LicenceStartDate`,`F_LicenceType`,`F_Checksum`,`F_DeliveryFrequency`,`F_LicenceClearanceDate`,`F_LicenceClearanceFrequency`,`F_LoginModifier`) VALUES ($rootId,72,5,0,5,10,'2019-12-31 23:59:59',NULL,'EN','FV',NULL,'','','2018-09-20 00:00:00',1,'b11cb77c41529a0f7720bda9961d7964f3dc561347635e3315f6908fa4863184',NULL,'2018-09-20 00:00:00','1 year',NULL);";
        $sqls[] = "INSERT INTO `T_AccountEmails` (`F_RootID`,`F_Email`,`F_MessageType`,`F_AdminUser`) VALUES ($rootId,NULL,31,1);";
        $sqls[] = "INSERT INTO T_AccountKeys (`F_Prefix`,`F_Key`) VALUES ('$prefix','TD03-203-12345678');";
        $sqls[] = "INSERT INTO `T_Groupstructure` (`F_GroupID`,`F_GroupName`,`F_GroupDescription`,`F_GroupParent`,`F_GroupType`,`F_GroupLogoImage`,`F_SelfRegister`,`F_Verified`,`F_LoginOption`,`F_lastVisit`,`F_RootDominant`,`F_custom1name`,`F_custom2name`,`F_custom3name`,`F_custom4name`,`F_EnableMGS`,`F_MGSName`) VALUES ($groupId,'Testing Data 01','',$groupId,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'','','','',0,NULL);";

        // Membership for preset users
        $nextUserId = $userId;
        $sqls[] = "INSERT INTO `T_User` (`F_UserID`,`F_UserName`,`F_UserSettings`,`F_Password`,`F_Salt`,`F_StudentID`,`F_Email`,`F_Birthday`,`F_Country`,`F_custom1`,`F_custom2`,`F_custom3`,`F_custom4`,`F_ScratchPad`,`F_FullName`,`F_AccountStatus`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_ActivationKey`,`F_RegistrationDate`,`F_ExpiryDate`,`F_City`,`F_StartDate`,`F_LicenceID`,`F_UserIP`,`F_RegisterMethod`,`F_ContactMethod`,`F_InstanceID`,`F_Memory`) VALUES ($nextUserId,'TD03_admin',0,'TD03',NULL,'TD03_admin','TD03_admin',NULL,'','','','','',NULL,NULL,NULL,2,NULL,NULL,NULL,NULL,NULL,'',NULL,NULL,NULL,NULL,'',NULL,NULL);";
        $sqls[] = "INSERT INTO `T_Membership` (`F_UserID`,`F_GroupID`,`F_RootID`) VALUES ($nextUserId,$groupId,$rootId);";
        $nextUserId++;
        $sqls[] = "INSERT INTO `T_User` (`F_UserID`,`F_UserName`,`F_UserSettings`,`F_Password`,`F_Salt`,`F_StudentID`,`F_Email`,`F_Birthday`,`F_Country`,`F_custom1`,`F_custom2`,`F_custom3`,`F_custom4`,`F_ScratchPad`,`F_FullName`,`F_AccountStatus`,`F_UserType`,`F_UserProfileOption`,`F_UniqueName`,`F_ActivationKey`,`F_RegistrationDate`,`F_ExpiryDate`,`F_City`,`F_StartDate`,`F_LicenceID`,`F_UserIP`,`F_RegisterMethod`,`F_ContactMethod`,`F_InstanceID`,`F_Memory`) VALUES ($nextUserId,'TD03_user_01',0,'TD03',NULL,'TD03_user_01','user_01@TD03.com',NULL,'','',NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,'',NULL,NULL,NULL,NULL,'',NULL,NULL);";
        $sqls[] = "INSERT INTO `T_Membership` (`F_UserID`,`F_GroupID`,`F_RootID`) VALUES ($nextUserId,$groupId,$rootId);";

        // Sessions
        $nextUserId = $userId+1; // Start from first student
        $sqls[] = "INSERT INTO `T_SessionTrack` (`F_SessionID`,`F_UserID`,`F_ProductCode`,`F_RootID`,`F_StartDateStamp`,`F_LastUpdateDateStamp`,`F_Duration`,`F_ContentID`,`F_Data`,`F_Status`) VALUES ($sessionId,$nextUserId,$productCode,$rootId,'2018-09-21 00:45:25','2018-09-21 00:46:37',120,NULL,NULL,0);";
        $sessionId++;

        // Licences
        $nextUserId = $userId+1; // Start from first student
        $sqls[] = "INSERT INTO `T_CouloirLicenceHolders` (`F_LicenceID`,`F_KeyID`,`F_RootID`,`F_ProductCode`,`F_StartDateStamp`,`F_EndDateStamp`,`F_LicenceType`) VALUES ($licenceId,$nextUserId,$rootId,$productCode,'2018-09-21 00:45:25','2018-12-21 02:00:00',$licenceType);";
        $licenceId++;

        $rc = array_map(function ($sql) {
            AbstractService::$debugLog->info($sql);
                $rs = $this->db->Execute($sql);
                if (!$rs)
                    throw new Exception('Data initialisation failed with '.$this->db->errorMsg());

                return $this->db->Affected_Rows();
            }, $sqls);

		return array_sum($rc);
	}
	private function buildDeleteSQLs($rootId, $prefix, $groupId, $sqls) {
        // Delete records from tables keyed on rootID
        $sqls[] = "delete from T_AccountRoot where F_RootID=$rootId;";
        $sqls[] = "delete from T_Accounts where F_RootID=$rootId;";
        $sqls[] = "delete from T_AccountEmails where F_RootID=$rootId;";
        $sqls[] = "delete from T_AccountKeys where F_Prefix='$prefix';";
        $sqls[] = "delete from T_Groupstructure where F_GroupID=$groupId;";
        $sqls[] = "delete from T_SessionTrack where F_RootID=$rootId;";
        $sqls[] = "delete from T_CouloirLicenceHolders where F_RootID=$rootId;";
        // Delete records from tables keyed on userID
        // First scores, then the membership and user records together
        $sqls[] = "delete T_Score from T_Score inner join T_Membership where T_Score.F_UserID = T_Membership.F_UserID and T_Membership.F_RootID=$rootId;";
        $sqls[] = "delete T_User, T_Membership from T_User inner join T_Membership where T_User.F_UserID = T_Membership.F_UserID and T_Membership.F_RootID=$rootId;";
        return $sqls;
    }

}