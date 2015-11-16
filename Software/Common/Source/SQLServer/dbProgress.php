<?php
class PROGRESS {
	// This duplicates information normally held in T_ProductLanguage, and is used for 
	// registering network titles which won't hold that information.
	private $productInformation = array(
		1	=>	array('name' => "Author Plus", 'place' => ""),
		2	=>	array('name' => "Results Manager", 'place' => ""),
		3	=>	array('name' => "Study Skills Success", 'place' => "StudySkillsSuccess"),
		9	=>	array('name' => "Tense Buster", 'place' => "TenseBuster"),
		10	=>	array('name' => "Business Writing", 'place' => "BusinessWriting"),
		11	=>	array('name' => "Reactions!", 'place' => "Reactions"),
		12	=>	array('name' => "Road to IELTS Academic", 'place' => "RoadToIELTS-Academic"),
		13	=>	array('name' => "Road to IELTS General Training", 'place' => "RoadToIELTS-General"),
		14	=>	array('name' => "BULATS", 'place' => "BULATS"),
		15	=>	array('name' => "GEPT", 'place' => "GEPT"),
		16	=>	array('name' => "Holistic English", 'place' => "HolisticEnglish"),
		17	=>	array('name' => "L'amour des temps", 'place' => "LamourDesTemps"),
		18	=>	array('name' => "EGU", 'place' => "EGU"),
		19	=>	array('name' => "AGU", 'place' => "AGU"),
		20	=>	array('name' => "My Canada", 'place' => "MyCanada"),
		33	=>	array('name' => "Active Reading", 'place' => "ActiveReading"),
		34	=>	array('name' => "Peacekeeper", 'place' => "Peacekeeper"),
		35	=>	array('name' => "Call Center Communication Skills", 'place' => "CCCS"),
		37	=>	array('name' => "Clarity English Success", 'place' => "ClarityEnglishSuccess"),
		38	=>	array('name' => "It's Your Job, Practice Centre", 'place' => "ItsYourJob"),
		39	=>	array('name' => "Clear Pronunciation", 'place' => "ClearPronunciation"),
		40	=>	array('name' => "English for Hotel Staff", 'place' => "EnglishForHotelStaff"),
		41	=>	array('name' => "Sun On Japanese", 'place' => "SunOnJapanese"),
		42	=>	array('name' => "Language Key Hotel Test", 'place' => "LanguageKey"),
		43	=>	array('name' => "Customer Service Communication Skills", 'place' => "CSCS"),
		44	=>	array('name' => "Practical Placement Test", 'place' => "ClarityTest"),
		47	=>	array('name' => "HCT's i-Read", 'place' => "i-Read"),
		48	=>	array('name' => "Access UK", 'place' => "AccessUK"),
		49	=>	array('name' => "Study Skills Success V9", 'place' => "StudySkillsSuccessV9"),
		50	=>	array('name' => "Clear Pronunciation 2", 'place' => "ClearPronunciation2"),
		52	=>	array('name' => "Road to IELTS 2 Academic", 'place' => "RoadToIELTS2"),
		53	=>	array('name' => "Road to IELTS 2 General Training", 'place' => "RoadToIELTS2"),
		55	=>	array('name' => "Tense Buster V10", 'place' => "TenseBuster"),
		56	=>	array('name' => "Active Reading V10", 'place' => "ActiveReading"),
		57	=>	array('name' => "Clear Pronunciation Sounds", 'place' => "ClearPronunciation"),
		58	=>	array('name' => "Clear Pronunciation Speech", 'place' => "ClearPronunciation"),
		60	=>	array('name' => "Study Skills Success V10", 'place' => "StudySkillsSuccess"),
		61	=>	array('name' => "Practical Writing", 'place' => "PracticalWriting"),
		62	=>	array('name' => "Business Writing V10", 'place' => "BusinessWriting"),
		1001=>	array('name' => "It's Your Job", 'place' => "ItsYourJob")
	);
	 
	function PROGRESS() {
	}

	//v6.5.4.5 AR functions to see which database you are working on to allow different SQL calls
	function checkDatabaseVersion( &$vars, &$node ){
		global $db;

		//' v6.5.4.5 The first test is to see if T_DatabaseVersion exists - this is the difference between 1 and 2
		// v6.5.5.5 MySQL migration. This is a SQLServer system table
		// v6.5.5.5 This will actually check all databases, so it is conceivable that you have a databaseVersion table only in another db.
		// But I can't see this ever being the case.
		//$node .= "<note driver='".$vars['DBDRIVER']."' strpos='".strpos($vars['DBDRIVER'],"mssql")."'  />";
		if (strpos($vars['DBDRIVER'],"mysql")!==false) {
			$sql = <<<EOD
					SELECT *
					FROM information_schema.tables
					WHERE table_name = ?;
EOD;
		} else if (strpos($vars['DBDRIVER'],"mssql")!==false) {
			$sql = <<<EOD
					select name, type_name(xtype) as type, length from syscolumns
					where id = object_id(?) order by colid
EOD;
		} else if (strpos($vars['DBDRIVER'],"sqlite")!==false) {
			$sql = <<<EOD
					select name from sqlite_master
					where type = 'table'
					and name=?;
EOD;
		} else {
			// Unexpected database driver - how to handle?
			return false;
		}
		$tableName = "T_DatabaseVersion";
		$bindingParams = array($tableName);
		$rs = $db->Execute($sql, $bindingParams);
		//return;
		// no columns means this table doesn't exist
		if ($rs->RecordCount()==0) {
			$node .= "<database version='1'  />";
			$vars['DATABASEVERSION'] = 1;
			$rs->Close();
			return true;
		}
		$rs->Close();

		// v6.5.4.5 The second call is to read the version number from the table we now know exists
		$sql = <<<EOD
			select max(F_VersionNumber) as versionNumber from T_DatabaseVersion;
EOD;
		//echo $sql;
		$rs = $db->Execute($sql);
		if ($rs->RecordCount()>0) {
			$dbObj = $rs->FetchNextObj();
			$vars['DATABASEVERSION'] = $dbObj->versionNumber;
		} else {
			$vars['DATABASEVERSION'] = 1;
		}
		$node .= "<database version='".$vars['DATABASEVERSION']."'  />";
		$rs->Close();
		return true;
	}

	function getRMSettings( &$vars, &$node ){
		global $db;

		// Check the account root or the groupstructure table
		$dbObj = $this->selectRMSettings($vars, $node);
		if ($dbObj) {
			// v6.5.5.1 make sure we do know the rootID now
			if (!isset($vars['ROOTID']) || $vars['ROOTID']=='' || $vars['ROOTID']==0) {
				$vars['ROOTID'] = $dbObj->F_RootID;
			}
			// save some extra information from this table
			// v6.5.4.7 You get the groupId by looking up the admin userID from T_AccountRoot and link to T_Membership
			$thisGroupID = $dbObj->topGroupID;

			// v6.5.5.3 Block entry if the Terms and Conditions are still set to 'display=1'
			if ($dbObj->F_TermsConditions==0) {
				$node .= "<err code='213'>Terms and conditions not accepted.</err>";
				return false;
			}
			$node .= "<settings loginOption='" .$dbObj->F_LoginOption . "'
				verified='" .$dbObj->F_Verified ."'
				selfRegister='" .$dbObj->F_SelfRegister ."'/>";
		} else {
			// Write this in selectRMSettings where we know if it is 0 or multiple
			//$node .= "<err code='100'>No or multiple accounts for this product in this root.</err>";
			return false;
		}

		// v6.3.5 No need to run the encryption key query
		$node .= "<decrypt key='undefined' />";

		// v6.5.4.5 If it is the new db, get Accounts too
		if ($vars['DATABASEVERSION']>2 ) {
			$dbObj = $this->selectAccounts($vars, $node);
			if ($dbObj) {
			
				// v6.5.6.6 At this point figure out the licence clearance date and set that to be the licence start date
				//$dbObj->licenceClearanceDate;
				//$dbObj->licenceClearanceFrequency;
				$licenceStartDate = $this->getLicenceClearanceDate($dbObj);
				//echo "checking startDate=".$dbObj->licenceStartDate." clearanceDate=".$dbObj->licenceClearanceDate." so, answer=".$licenceStartDate;
			
				// Check the account expiryDate. This is going to be something like 2009-06-30 00:00:000.
				// But we really want to let people use the program all day on the expiry date, so should set the time to the end of the day
				// we know the format of the date coming back from the db, so safe to just chop it to get the date
				// v6.5.5.1 We might be reading the root, so send it back
				$endOfTheDay = substr($dbObj->formattedDate,0,10).' 23:59:59';
				$accountExpiryTimestamp = strtotime($endOfTheDay);
				$startOfTheDay = substr($dbObj->licenceStartDate,0,10).' 00:00:00';
				$accountStartTimestamp = strtotime($startOfTheDay);
				$queryTimeStamp = strtotime($vars['DATESTAMP']);
				$systemDateStamp = time() + 43200;
				$systemDate = date('Y-m-d', $systemDateStamp);
				// Check the expiry date
				//if ($accountExpiryTimestamp==0 || $accountExpiryTimestamp > $queryTimeStamp) {
				// v6.5.6 See below for starting - but ending is more critical as we don't want to just give away an extra day...
				// So set it to 12 hours? Yes. Later I might be able to add a timezone to an account and use that instead.
				// 12 hours (43200 seconds) means that Australians (and all who are ahead of GMT) will get exact matches
				// and everyone behind GMT will get an extra day.
				//if ($accountExpiryTimestamp>0 && $accountExpiryTimestamp < $queryTimeStamp) {
				if ($accountExpiryTimestamp>0 && $accountExpiryTimestamp < $systemDateStamp) {
					$node .= "<err code='207'>Account expired, start=$startOfTheDay, systemDate=$systemDate</err>";
				// v6.5.5.2 And add in licence start date too
				// v6.5.6 AR change to use system time rather than student's computer time. Give 24 hours leeway to allow for timezones.
				// Whilst you could make this less as we know the server timezone (AWS = GMT), keep it general to allow for other servers...
				//} else if ($accountStartTimestamp>0 && $accountStartTimestamp > $queryTimeStamp) {
				} else if ($accountStartTimestamp>0 && $accountStartTimestamp > $systemDateStamp) {
					$node .= "<err code='212'>Account not started, start=$startOfTheDay, systemDate=$systemDate</err>";
				// v6.5.5.6 Block suspended for non-payment accounts
				} else if ($dbObj->accountStatus==11) {
					// Whilst I could get the reseller name earlier, it will be so rare that I should just do it here
					$institutionName = $dbObj->institution;
					$resellerName = $this->getReseller($dbObj->resellerCode);
					$node .= "<err code='215' institution='" .htmlspecialchars($institutionName, ENT_QUOTES, 'UTF-8') ."' reseller='".$resellerName."'>Account suspended for non-payments.</err>";
				} else {
					// account has not expired
					//licenceStartDate='" .$dbObj->F_LicenceStartDate ."'
					//groupID='" .$dbObj->F_TopGroupID ."'
					//$node .= "<account expiryDate='" .$dbObj->formattedDate . "'
					// v6.5.5.5 Add checksum for security- what about confirming it here?
					//$dmsPublicKey = new RSAKey("00c9be86502ec265831d104f4f0ce071490aa0b707ac5ae2ac16306ba758368ee9", "10001");

					$dmsPublicKey = new RSAKey("a6f945c79fa1db830591618a0178f1ec4076436bd22e2c264de61b114eb78fad", "10001");
					$orchidKey = new RSAKey("00c2053455fe3c7c7b22a629d53ab2d98a2f46a2c403457da8d044116df9ab43fb", "10001", "24ba437bfbd28b65ebdb34940eb6888351301010b30b1fef1e75f24dc31bfe21");
					$protectedString = $dbObj->institution.$endOfTheDay.$dbObj->F_MaxStudents.$dbObj->F_LicenceType.$dbObj->F_RootID.$dbObj->F_ProductCode;
					// But rawurlencode doesn't do quite the same as actionscript escape. So you need to manually cope with _ and -. Any others?
					$escapedString = $this->actionscriptEscape($protectedString);
					$hash = md5($escapedString);
					// v6.5.5.5 An empty checksum crashes gmp
					if ($dbObj->F_Checksum=="") {
						$testHash = "";
					} else {
						$c = $orchidKey->decrypt($dbObj->F_Checksum);
						$d = $dmsPublicKey->verify($c);
						$testHash = Base8::decode($d);
					}
					// Orchid will repeat this check.
					// Bypass- why?
					$testHash=$hash;
					if ($testHash!=$hash) {
						//$node .= "<note protected='".htmlspecialchars($protectedString, ENT_QUOTES, 'UTF-8')."' />";
						$node .= "<note escaped='$escapedString' />";
						$node .= "<note myhash='$hash' />";
						//$node .= "<note dbchecksum='$dbObj->F_Checksum' />";
						//$node .= "<note decrypt='$c' />";
						//$node .= "<note verify='$d' />";
						// It is dangerous to send back the decrypted hash as it might contain control characters if it has been corrupted.
						//$node .= "<note dbhash='$testHash' myhash='$hash' />";
						$node .= "<err code='214' institution='" .htmlspecialchars($dbObj->institution, ENT_QUOTES, 'UTF-8') ."'>Licence corrupt</err>";
					} else {
						// v6.5.5.5 Change name
						//licencing='" .$dbObj->F_LicenceType ."'
						// v6.5.5.6 ContentLocation probably comes from the default in T_ProductLangauge now, but if it is set here, use it
						if (isset($dbObj->F_ContentLocation) && ($dbObj->F_ContentLocation!="")) {
							$node .= "<note>use special content location from T_Accounts</note>";
							$useContentLocation = $dbObj->F_ContentLocation;
						} else {
							$useContentLocation = $dbObj->defaultContentLocation;
						}
						// v6.5.6.6 use licence clearance date calculations
						$node .= "<account expiryDate='" .$endOfTheDay . "'
							maxStudents='" .$dbObj->F_MaxStudents ."'
							groupID='" .$thisGroupID ."'
							rootID='" .$dbObj->F_RootID ."'
							licenceType='" .$dbObj->F_LicenceType ."'
							institution='" .htmlspecialchars($dbObj->institution, ENT_QUOTES, 'UTF-8') ."'
							contentLocation='" .$useContentLocation ."'
							MGSRoot='" .$dbObj->F_MGSRoot ."'
							licenceStartDate='" .$licenceStartDate ."'
							checksum='" .$dbObj->F_Checksum ."'
							languageCode='" .$dbObj->F_LanguageCode ."'/>";
					}
				}
				// v6.5.5.1 Also see if there are any special licence attributes
				$node .= $this->selectLicenceAttributes($vars, $node);
			} else {
				// v6.5.5.3 This is done in the selectAccounts so you can get an accurate message
				//$node .= "<err code='100'>No or multiple accounts for this product in this root.</err>";
			}
		}
		return true;
	}
	//
	// Utility function to calculate a licence clearance date from all info
	private function getLicenceClearanceDate($title) {
		// The from date for counting licence use is calculated as follows:
		// If there is no licenceClearanceDate, then use licenceStartDate.
		// If there is no licenceClearanceFrequency, then use +1y
		// Take licenceClearanceDate and add the frequency to it until we get a date in the future.
		// The previous date is our fromDate.
		if (!$title->licenceClearanceDate) 
			$title->licenceClearanceDate = $title->licenceStartDate;
		// Just in case dates have been put in wrongly. 
		// First, if clearance date is in the future, use the start date
		if ($title->licenceClearanceDate > time()) 
			$title->licenceClearanceDate = $title->licenceStartDate;
		// If clearance date is before the start date, it doesn't much matter
		// Turn the string into a timestamp
		$fromDateStamp = strtotime($title->licenceClearanceDate);
		
		// You mustn't have a negative frequency otherwise the loop will be infinite
		if (!$title->licenceClearanceFrequency)
			$title->licenceClearanceFrequency = '1 year';
		if (stristr($title->licenceClearanceFrequency, '-')!==FALSE) 
			$title->licenceClearanceFrequency = str_replace('-', '', $title-> licenceClearanceFrequency);
		// Check that the frequency is valid
		if (!strtotime($title-> licenceClearanceFrequency, $fromDateStamp) > 0)
			$title->licenceClearanceFrequency = '1 year';
		// Just in case we still have invalid data
		$safetyCount=0;
		while ($safetyCount<99 && strtotime($title->licenceClearanceFrequency, $fromDateStamp) < time()) {
			$fromDateStamp = strtotime($title->licenceClearanceFrequency, $fromDateStamp);
			$safetyCount++;
		}
		// We want a formatted date
		return date('Y-m-d 00:00:00', $fromDateStamp);
	}

	function getUser( &$vars, &$node ) {
		global $db;

		// if this is an anonymous login, allow it as the program will have already
		// validated that this was allowed
		// v6.5.4.7 Allow userID to be passed as the sole necessary login information. The default is -1 from XMLQuery.php
		// v6.6.0.4 But don't allow userID to be empty in this condition - that's no good as that is exactly what OrchidObjects sends
		// Although control.swf and objects.swf have been updated, can I fix the problem here as easier to migrate?
		// It happens when SCORMStart.html is simply run. prefix=Clarity and scorm, but scorm succeeds so you end up here
		// Is it safe to say that for root 163 this should never be triggered? We never have anonymous, and real SCORM should always have a username
		//if ($vars['NAME'] == "" && $vars['STUDENTID'] == "") {
		if ($vars['NAME'] == "" && $vars['STUDENTID'] == "" && $vars['USERID'] <= 0) {
			// v6.5.6 Pass back root even for anonymous
			//$node .= "<user name=\"\" userID=\"-1\"/>";
			// v6.6.0.4 see above
			if ($vars['ROOTID']==163) {
				$node .= "<err code=\"220\">multiple users</err>";
				return false;
			} else {
				$node .= "<user name='' userID='-1' rootID='".$vars['ROOTID']."' />";
				return 0;
			}
		}

		// v6.3.4 StudentID can be used as well as/or name
		// v6.5.4.6 You could pick up the searchType based on loginOption instead of the data you actually get
		// For instance, if you login with ID, you will also pass a name but don't care if it is unique or not.
		// This should really be binary and so that you can pass 18 and match on '2'.
		if (($vars['LOGINOPTION'] & 2) == 2) {
			$searchType = "id";
		} else if (($vars['LOGINOPTION'] & 4) == 4) {
			$searchType = "both";
		} else if (($vars['LOGINOPTION'] & 1) == 1) {
			$searchType = "name";
		// v6.5.6.5 Add search by email
		} else if (($vars['LOGINOPTION'] & 8) == 8) {
			$searchType = "email";
		// v6.5.4.7 ClarityEnglish.com special case
		} else if (($vars['LOGINOPTION'] & 64) == 64) {
			$searchType = "userID";
		} else {
				// v6.3.4 Add search type (though not used for adding)
				// v6.4.2 Also allow id or both
				//$rC = $Progress->selectUser( $vars , "name");
				if ($vars['NAME'] <> "") {
					$searchType = "name";
					if ($vars['STUDENTID'] <> "") {
						$searchType = "both";
					}
				} else {
					if ($vars['STUDENTID'] <> "") {
						$searchType = "id";
					}
				}
		}
		// Go get this user - if it exists
		$rs = $this->selectUser($vars, $searchType);
		if ($rs) {
			//echo 'count='.$rs->RecordCount();
			switch ($rs->RecordCount()) {
				case 0:
					// No such user
					if ($searchType == "id") {
						$node .= "<err code=\"206\">no such id</err>";
					} else {
						$node .= "<err code=\"203\">no such user</err>";
					}
					return false;
					break;
				// v6.5.6 There is one case where we simply want the first of many - SCORM and DEMO.
				// So always send back the first you find, and an error if necessary
				case 1:
				default:
					// Found one
					$dbObj = $rs->FetchNextObj();
					//print_r($dbObj);
					// save some record variables for later
					$vars['USERID'] = $dbObj->F_UserID;
					$vars['GROUPID'] = $dbObj->groupID;
					$vars['USERTYPE'] = $dbObj->F_UserType;
					$userExpiryTimestamp = strtotime($dbObj->formattedDate);
					$typedPassword = $vars['PASSWORD'];
					$dbPassword = $dbObj->F_Password;
					// v6.3.4 null password (sent from APO) means don't check it
					if ($typedPassword == "$!null_!$") {
						$typedPassword = $dbPassword;
					}
					// gh#653 One user in many groups would give multiple records with same userID.
					// In this case we want to merge to one, with a list of all the groups.
					$justOneUser = true;
					if ($rs->RecordCount() > 1) {
						$mergedGroupIDs = array();
						$mergedGroupIDs[] = $vars['GROUPID'];
						while ($moredbObj = $rs->FetchNextObj()) {
							if ($vars['USERID'] != $moredbObj->F_UserID) {
								$justOneUser = false;
								continue;
							} else {
								$mergedGroupIDs[] = $moredbObj->groupID;
							}
						}
						if ($justOneUser) {
							$vars['GROUPID'] = implode(',',$mergedGroupIDs);
						} else {
							$node .= "<err code='220'>Multiple students match this name/id within this root.</err>";
						}
					}
					
					// v6.5.4.6 TODO Except that if just one of these users matches the password, assume it is them
					// So loop through the users trying to match the password.
					if ($typedPassword != $dbPassword) {
						$node .= "<err code='204'>Password does not match</err>";
						// v6.5.6 If we are working with the first of many, don't worry about the password
						if ($justOneUser)
							return false;
					}

					//$node .= "<note>Multiple students match this name/id within this root.</note>";
					//return false;
					// build user info 
					//v6.5.5.9 RL: add city as return
					// v6.5.6 HCT SCORM. Also we may have found which root of many the user is in, and we need to pass that back
					// AR We user F_UserProfileOption as a means to hold productCode for global R2I. Not sure it is really necessary...
					// AR And send back registrationDate, for use by global R2I
					// TODO deprecate using userName for name
					$node .= "<user userID='" .$dbObj->F_UserID ."'
						userSettings='" .$dbObj->F_UserSettings ."'
						userName='" .htmlspecialchars($dbObj->F_UserName, ENT_QUOTES, 'UTF-8') ."'
						name='" .htmlspecialchars($dbObj->F_UserName, ENT_QUOTES, 'UTF-8') ."'
						country='" .htmlspecialchars($dbObj->F_Country, ENT_QUOTES, 'UTF-8') ."'
						city='" .htmlspecialchars($dbObj->F_City, ENT_QUOTES, 'UTF-8') ."'
						email='" .htmlspecialchars($dbObj->F_Email, ENT_QUOTES, 'UTF-8') ."'
						userType='" .$dbObj->F_UserType ."'
						groupID='" .$vars['GROUPID'] ."'
						rootID='" .$dbObj->rootID ."'
						expiryDate='" .$dbObj->formattedDate ."'
						registrationDate='" .$dbObj->registrationDate ."'
						userProfileOption='" .$dbObj->F_UserProfileOption ."'
						studentID='" .htmlspecialchars($dbObj->F_StudentID, ENT_QUOTES, 'UTF-8') ."' />";

				break;
			}
			$rs->Close();
		} else {
			throw new Exception("Query failed");
		}

		// now check on user expiry date
		if ($vars['DATABASEVERSION']>1 ) {
			if ($userExpiryTimestamp) {
				//if ($userExpiryDate=="1970-01-01 00:00:00") {
				$queryTimeStamp = strtotime($vars['DATESTAMP']);
				if ($userExpiryTimestamp==0 || $userExpiryTimestamp > $queryTimeStamp) {
					$node .= "<note>User has not expired</note>";
				} else {
					$node .= "<err code='208' expiryDate='" .$dbObj->formattedDate."' userID='".$vars['USERID']."'>User expired</err>";
					return false;
				}
			} else {
				$node .= "<note>User has no expiry date</note>";
			}
		}

		// v6.5.4.6 Move this into a separate function, it might not be relevant for all startUser functions
		// Move to checkLicenceAllocation

		// v6.5.4.6 This should be a separate function as it takes an action
		// Move to saveLicence - which is called from runProgressQuery
		return true;
	}
	// v6.5.4.6 If you don't know the rootID
	function getGlobalUser( &$vars, &$node ) {
		global $db;

		// v6.5.4.6 You could pick up the searchType based on loginOption instead of the data you actually get
		// For instance, if you login with ID, you will also pass a name but don't care if it is unique or not.
		if (($vars['LOGINOPTION'] & 2) == 2) {
			$searchType = "id";
		} else if (($vars['LOGINOPTION'] & 4) == 4) {
			$searchType = "both";
		} else if (($vars['LOGINOPTION'] & 1) == 1) {
			$searchType = "name";
		// v6.5.6.5 Add search by email
		} else if (($vars['LOGINOPTION'] & 8) == 8) {
			$searchType = "email";
		// v6.5.4.7 ClarityEnglish.com special case
		} else if (($vars['LOGINOPTION'] & 64) == 64) {
			$searchType = "userID";
		} else {
			// v6.3.4 Add search type (though not used for adding)
			// v6.4.2 Also allow id or both
			//$rC = $Progress->selectUser( $vars , "name");
			if ($vars['NAME'] <> "") {
				$searchType = "name";
				if ($vars['STUDENTID'] <> "") {
					$searchType = "both";
				}
			} else {
				if ($vars['STUDENTID'] <> "") {
					$searchType = "id";
				}
			}
		}

		// Go get this user - if it exists
		$rs = $this->selectGlobalUser($vars, $searchType);
		if ($rs) {
			$hasRoot = false;
			switch ($rs->RecordCount()) {
				case 0:
					// v6.5.6 If you haven't passed a groupID, then it is sufficent to simply say you haven't found the user.
					if ($vars['GROUPID']>0) {
						$tmpRootID = $this->selectRootIDViaGroupID( $vars );
						// If the group doesn't exist, you have a data problem (or the ID has been typed wrongly)
						if ($tmpRootID) {
							$hasRoot = true;
						} else {
							$node .= "<err code=\"207\">db doesn't have group ".$vars['GROUPID']."</err>";
						}
	
						if ($searchType == "id") {
							if( $hasRoot ){
								$node .= "<err code=\"206\" rootID='" .$tmpRootID ."'>no such id</err>";
							} else{
								$node .= "<err code=\"206\">no such id</err>";
							}
						} else {
							if( $hasRoot ){
								$node .= "<err code=\"203\" rootID='" .$tmpRootID ."'>no such name</err>";
							} else{
								$node .= "<err code=\"203\">no such user</err>";
							}
						}
						return false;
					} else {
						$node .= "<err code=\"206\">no such user</err>";
						return true;
					}
					break;
				case 1:
					// Found one
					$dbObj = $rs->FetchNextObj();
					//print_r($dbObj);
					// save some record variables for later
					$typedPassword = $vars['PASSWORD'];
					$dbPassword = $dbObj->F_Password;
					if ($typedPassword == "$!null_!$") {
						$typedPassword = $dbPassword;
					}
					if ($typedPassword != $dbPassword) {
						$node .= "<err code='204'>Password does not match</err>";
						return false;
					}

					$vars['USERID'] = $dbObj->F_UserID;
					$vars['GROUPID'] = $dbObj->groupID;
					$vars['ROOTID'] = $dbObj->rootID;
					$vars['USERTYPE'] = $dbObj->F_UserType;
					$userExpiryTimestamp = strtotime($dbObj->formattedDate);
					// build user info
					// AR v6.5.6.5 You have to send back expiry date for R2I registration. Well, not really but no harm.
					// TODO This should be a common function for all selectUser type calls.
					$node .= "<user userID='" .$dbObj->F_UserID ."'
						name='" .htmlspecialchars($dbObj->F_UserName, ENT_QUOTES, 'UTF-8') ."'
						userSettings='" .$dbObj->F_UserSettings ."'
						country='" .htmlspecialchars($dbObj->F_Country, ENT_QUOTES, 'UTF-8') ."'
						email='" .htmlspecialchars($dbObj->F_Email, ENT_QUOTES, 'UTF-8') ."'
						userType='" .$dbObj->F_UserType ."'
						groupID='" .$dbObj->groupID ."'
						rootID='" .$dbObj->rootID ."'
						password='" .htmlspecialchars($dbObj->F_Password, ENT_QUOTES, 'UTF-8') ."'
						userProfileOption='" .$dbObj->F_UserProfileOption ."'
						expiryDate='" .$dbObj->F_ExpiryDate ."'
						registrationDate='" .$dbObj->registrationDate ."'
						studentID='" .htmlspecialchars($dbObj->F_StudentID, ENT_QUOTES, 'UTF-8')  ."' />";
						
					break;
				default:
					// Something is wrong with the database
					//throw new Exception("Multiple students match this name/id.");
					// v6.5.4.6 TODO Except that if just one of these users matches the password, assume it is them
					// So loop through the users trying to match the password.

					$node .= "<note>Multiple students match this name/id within this root.</note>";
					return false;
			}
			$rs->Close();
		} else {
			throw new Exception("Query failed");
		}

		// now check on user expiry date
		if ($vars['DATABASEVERSION']>1 ) {
			if ($userExpiryTimestamp) {
				//if ($userExpiryDate=="1970-01-01 00:00:00") {
				$queryTimeStamp = strtotime($vars['DATESTAMP']);
				if ($userExpiryTimestamp==0 || $userExpiryTimestamp > $queryTimeStamp) {
					$node .= "<note>User has not expired</note>";
				} else {
					$node .= "<err code='208' userID='".$vars['USERID']."'>User expired</err>";
					return false;
				}
			} else {
				$node .= "<note>User has no expiry date</note>";
			}
		}

		return true;
	}
	// v6.5.5.5 A bad name
	// TODO This should be merged into selectUser or a generic getUser
	//function getUserDetail( &$vars, &$node ){
	function getUserByStudentID( &$vars, &$node ){
		global $db;
		// Go get this user - if it exists
		// v6.5.5.5 bad name
		//$rs = $this->selectUserDetail($vars);
		$rs = $this->selectUserDetailByStudentID($vars);
		if ($rs->RecordCount() > 0) {
			// v6.5.6.5 Wouldn't it be cleaner to do a while loop with FetchNextObj?
			// And isn't it most likely to be an error if there are multiple?
			foreach($rs as $k=>$row) {
				$userExpiryTimestamp = $row['formattedDate'];
				$node .= "<user userID='{$row['F_UserID']}' "
					."name='{$row['F_UserName']}' "
					."email='{$row['F_Email']}' "
					."expiryDate='{$userExpiryTimestamp}' "
					."userProfileOption='{$row['F_UserProfileOption']}' "
					."password='{$row['F_Password']}' "
					."studentID='{$row['F_StudentID']}'/>";
			}
		} else {
			// Is it really an exception if no records are found?
			//throw new Exception("Query failed");
			$node .= "<err code=\"203\">no such user</err>";
			return false;
		}
		$rs->Close();
		return true;
	}

	// TODO This should be merged into selectUser or a generic getUser
	function getUserByEmail( &$vars, &$node ){
		global $db;
		// Go get this user - if it exists
		$rs = $this->selectUserByEmail($vars);
		if ($rs->RecordCount() > 0) {
			foreach($rs as $k=>$row) {
				$node .= "<user userID='{$row['F_UserID']}' "
					."name='{$row['F_UserName']}' "
					."email='{$row['F_Email']}' "
					."password='{$row['F_Password']}' "
					."studentID='{$row['F_StudentID']}'/>";
			}
		} else {
			throw new Exception("Query failed");
		}
		$rs->Close();
		return true;
	}

	// v6.5.4.7 WZ Added for Road to IELTS auto-registration
	function getRootViaGroup( &$vars, &$node){
		global $db;
		// v6.5.5.0 AR I think it would be better to insist that we only get back one record
		// It surely is a mistake if we have several roots
		//$rs = $this->selectRootIDViaGroupID($vars);
		//if ($rs->RecordCount() > 0) {
		//	foreach($rs as $k=>$row) {
		//		$node .= "<user userID='{$row[F_USERID]}' "
		//			."rootID='{$row[F_ROOTID]}'/>";
		//	}
		$thisRoot = $this->selectRootIDViaGroupID($vars);
		if ($thisRoot) {
			$node .= "<user userID='".$vars[USERID]."' "
					."rootID='$thisRoot'/>";
		} else {
			// Where is this exception caught? It would be better to send back an expected error format
			//throw new Exception("Query failed");
			$node .= "<err code=\"207\">db doesn't have group $</err>";
		}
		$rs->Close();
		return true;
	}

	// v6.5.4.6 Seapare action to see if this user can be or is allocated a licenceID
	// This function is most likely not be used as we are dropping licence allocation
	// v6.5.6.5 Take it out
	/*
	function checkLicenceAllocation( &$vars, &$node) {
		global $db;
		// now check on licence allocation
		//'v6.5.4.3 AR any userType over 0 is automatically allocated to all titles
		if ($vars['DATABASEVERSION']>1 ) {
			//if ($userType==0) {
			if ($vars['USERTYPE']==0) {
				//' This is a student. The allocation rules are:
				//' 1: That if there are less students than licences, everyone is allocated.
				//' 2: Otherwise read the table to see if you are listed
				//' 3: If you are not listed, then if the listed number is smaller than the licence, are you in the top x of the user tree
				//'	where x is the number of unallocated licences. Since tree is ordered by UserID, it is first come first served.
				$currentStudents = $this->countUserRecords( $vars );
				$maxStudents = (int)$vars['LICENCES'];
				$node .= "<note currentStudents='".$currentStudents."' maxStudents='".$maxStudents."' />";

				if ($currentStudents>$maxStudents) {
					// so, we do need to check to see if this student is allocated
					$sql = <<<EOD
						SELECT * from T_TitleLicences
							WHERE F_RootID=?
							AND F_UserID=?
							AND F_ProductCode=?
EOD;
					$bindingParams = array($vars['ROOTID'], $vars['USERID'], $vars['PRODUCTCODE']);
					$rs = $db->Execute($sql, $bindingParams);

					if ($rs->RecordCount()==0) {
						// you are not allocated, is there any space for you as an early bird?
						$sql = <<<EOD
							SELECT Count(F_UserID) as allocatedLicences FROM T_TitleLicences
								WHERE F_RootID=?
								AND F_ProductCode=?
EOD;
						$bindingParams = array($vars['ROOTID'], $vars['PRODUCTCODE']);
						$rs = $db->Execute($sql, $bindingParams);

						if ($rs->RecordCount()==0) {
							// throw an error should be impossible
							return false;
						}
						$dbObj = $rs->FetchNextObj();
						$allocatedLicences = $dbObj->allocatedLicences;
						$unusedAllocations = $maxStudents - $allocatedLicences;
						if  ($unusedAllocations >0) {
							// ok there is some space, are you an early bird?
							//' We only count students who have not expired as of today
							$sql = <<<EOD
								SELECT Count(u.F_UserID) as priorityRank FROM T_User u, T_Membership m
									WHERE m.F_RootID=?
									AND u.F_UserID=m.F_UserID
									AND u.F_UserType=0
									AND ((u.F_ExpiryDate is null) OR (u.F_ExpiryDate>?))
									AND u.F_UserID<=?
EOD;
							$bindingParams = array($vars['ROOTID'], $vars['DATESTAMP'], $vars['USERID']);
							$rs = $db->Execute($sql, $bindingParams);

							if ($rs->RecordCount()==0) {
								// throw an error should be impossible
								return false;
							}
							$dbObj = $rs->FetchNextObj();
							$priorityRank = (int)$dbObj->priorityRank;
							$node .= "<note priorityRank='".$priorityRank."' unusedAllocations='".$unusedAllocations."' />";

							if ($priorityRank > $unusedAllocations) {
								//' sorry, you ranked too low
								$node .= "<err code='209' userID='".$vars['USERID']."'>Not ranked within spare allocations.</err>";
							} else {
								//' you can be allocated, all is well
								$node .= "<allocation>You are allocated based on your priority.</allocation>";
							}
						} else {
							//' no space, so sorry, you don't get in
							$node .= "<err code='209' userID='".$vars['USERID']."'>No licence allocations available.</err>";
							return false;
						}
					} else {
						// ' you are allocated, all is well
						$node .= "<allocation>You are specifically allocated</allocation>";
					}
				} else {
					$node .= "<allocation>There is room for everybody</allocation>";
				}
			} else {
				$node .= "<allocation>You are more than a student</allocation>";
			}
		} else {
			//' just for testing
			$node .= "<err code='209' userID='".$vars['USERID']."'>Not allocated for testing</err>";
		}
		return true;
	}
	*/
	
	// v6.5.4.6 Separate action to record this licence (protect against double login)
	// v6.5.5.0 This is really instance not licence
	//function saveLicenceID( &$vars, &$node ) {
	function saveInstanceID( &$vars, &$node ) {

		// v6.5.4.5Finally update the table with the licenceID
		if ($vars['DATABASEVERSION']>1) {
			//$returnCode = $this->insertLicenceID( $vars );
			$returnCode = $this->insertInstanceID( $vars );
			if (!$returnCode) {
				$node .= "<err>instance ID not recorded ".$db->ErrorMsg()."</err>";
			} else {
				//$node .= "<licence id='$vars[LICENCEID]' />";
				$node .= "<instance>".$vars['INSTANCEID']."</instance>";
			}
		}
		return true;
	}

	// v6.4.4 MGS
	function getMGS( &$vars, &$node ) {

		// 6.5.4.5 I am going to cheat now since MGS isn't currently used - don't do the hierarchy check
		// If I do want to do this, I have save groupID in $vars
		$node .= "<MGS enabled='false' />";
		return true;
	}
	// v6.5.5.5 Find the courseIDs the user has already started
	function getStartedContent( &$vars, &$node ) {
		global $db;

		$uid  = $vars['USERID'];
		$pid  = $vars['PRODUCTCODE'];

		$sql = <<<EOD
		SELECT DISTINCT(s.F_CourseID) FROM T_Session s
		WHERE s.F_UserID=?
		AND s.F_ProductCode=?
EOD;
		$bindingParams = array($uid, $pid);
		$rs = $db->Execute($sql, $bindingParams);
		// Expecting zero or lots of records
		if ($rs->RecordCount() > 0)  {
			foreach($rs as $k=>$row) {
				$node .= "<courseID id='".$row["F_CourseID"]."' />";
			}
		}
		$rs->Close();
		return true;
	}

	// v6.5.4.5 updated
	function insertSession( &$vars, &$node ) {
		global $db;

		//v6.4.2 pass local time from app
		//$date = $Db->now();
		//$thisCourseName = $vars['COURSENAME'];
		//$node .= "<note>coursename='$thisCourseName' </note>";
		// v6.6.4 Always use server time for session records
		//if (isset($this->dateNow)) {
		//	$dateNow = $this->dateNow;
		//} else {
			$dateNow = date('Y-m-d H:i:s', time());
		//}
		//$date = $vars['DATESTAMP'];
		//$returnCode = $this->insertSessionRecord($vars, $dateNow);
		
		// v6.6.0 For teachers we will set rootID to 0 in the session record, so, are you a teacher?
		$userType = $this->getUserType($vars);
		
		$sessionID = $this->insertSessionRecord($vars, $dateNow, $userType);
		//print 'affected_rows=' .$Db->affected_rows;
		if (!$sessionID) {
			$node .= "<err code='205'>Your progress cannot be recorded: " .$db->ErrorMsg() ."</err>";
			return false;
		}
		// v6.6.0 Why do we need to count sessions? Nothing happens to this information in Orchid.
		// $numSessions = $this->countSessions($vars);
		$numSessions = 1;
		
		// this is done by identity column now in adodb
		//$sessionID = $this->selectInsertedSessionID($vars, $dateNow, $node);
		//if ($sessionID) {
			$node .= "<session id='$sessionID' count='$numSessions' starttime='$dateNow' />";
		//} else {
		//	$node .= "<err code='205'>Your progress cannot be recorded: " .$db->ErrorMsg() ."</err>";
		//	return false;
		//}
		return true;
	}

	function getScores( &$vars, &$node ) {
		global $db;

		$uid  = $vars['USERID'];
		$cid  = $vars['COURSEID'];

		//Edward: modify query
		if ($vars['DATABASEVERSION']>4) {
			// v6.5.6.6 Something wrong here as this query was the same as the old one below!
			// Now we have F_CourseID in T_Score. Or at least we ought to have. Seems GlobalRoadToIELTS has null for all fields
			// Do a query to update them from session join
			$sql = <<<EOD
			SELECT c.* FROM T_Score c
			WHERE c.F_UserID=?
			AND c.F_CourseID=?
			ORDER BY c.F_DateStamp
EOD;
		} else {
			$sql = <<<EOD
			SELECT c.* FROM T_Score c, T_Session s
			WHERE c.F_UserID=?
			AND c.F_SessionID=s.F_SessionID
			AND s.F_CourseID=?
			ORDER BY c.F_DateStamp
EOD;
		}
		$bindingParams = array($uid, $cid);
		$rs = $db->Execute($sql, $bindingParams);
		// Expecting zero or lots of records
		if ($rs->RecordCount() > 0)  {
			foreach($rs as $k=>$row) {
				$node .= "<score datestamp='".$row["F_DateStamp"]."' ";
				$node .=  "userID='{$vars['USERID']}' ";
				$node .=  "testUnits='{$row['F_TestUnits']}' ";
				$node .= "itemID='{$row['F_ExerciseID']}' "
					."unit='{$row['F_UnitID']}' "
					."score='{$row['F_Score']}' "
					."duration='{$row['F_Duration']}' "
					."correct='{$row['F_ScoreCorrect']}' "
					."wrong='{$row['F_ScoreWrong']}' "
					."skipped='{$row['F_ScoreMissed']}' />";
			}
		}
		$rs->Close();
		return true;
	}
	// v6.5 Note that this is NOT tested yet
	function getAllScores( &$vars, &$node ) {
		global $db;

		$uid  = $vars['USERID'];
		$rootid  = $vars['ROOTID'];
		$cid  = $vars['COURSEID'];

		// Then we need another that just picks up the scored ones
		//Edward: modify query
		// AR: At least in MySQL it goes very much quicker as a JOIN. How about SQL Server? The query execution plan seems about the same.
		// v6.5.6.6 Big delay in this call in MySQL. Need to avoid a join of score and session. 
		// One answer is to denormalise and add F_RootID to T_Score
		// Another is to pre-fetch all userIDs in this root. Try this for now see how it goes. But there are some accounts with tens of thousands of users in a root.
		// Terrible! Query never even completed direct in MySQL. Mind you there were 13000 users!
		// What about joining on membership instead? Ah, seems promising.
		/*
				SELECT SC.F_ExerciseID, SC.F_UnitID, AVG(SC.F_Score) AS AvgScore, COUNT(SC.F_Score) AS NumberDone
				FROM T_Score SC
				WHERE SC.F_CourseID=1151344082236
				AND SC.F_Score>=0
				AND SC.F_UserID in (
					SELECT u.F_UserID FROM T_User u, T_Membership m
					WHERE u.F_UserID = m.F_UserID
					AND m.F_RootID=169
					AND u.F_UserID<>231422
				)
				GROUP BY SC.F_ExerciseID, SC.F_UnitID
				ORDER BY SC.F_ExerciseID;
		*/
		if ($vars['DATABASEVERSION']>3) {
			/*
			SELECT SC.F_ExerciseID, SC.F_UnitID, AVG(SC.F_Score) AS AvgScore, COUNT(SC.F_Score) AS NumberDone
			FROM T_Score SC
			WHERE SC.F_Score>=0
			AND SC.F_SessionID IN (	SELECT F_SessionID
						FROM T_Session SE
				       		WHERE SE.F_UserID<>?
				       		AND SE.F_CourseID=?
				       		AND SE.F_RootID=?)
			GROUP BY SC.F_ExerciseID, SC.F_UnitID
			ORDER BY SC.F_ExerciseID;
			*/
			/*
			SELECT SC.F_ExerciseID, SC.F_UnitID, AVG(SC.F_Score) AS AvgScore, COUNT(SC.F_Score) AS NumberDone
				FROM T_Score SC, T_Session SE
				WHERE SE.F_SessionID = SC.F_SessionID
				AND SE.F_UserID<>?
				AND SE.F_CourseID=?
				AND SE.F_RootID=?
				AND SC.F_Score>=0
				GROUP BY SC.F_ExerciseID, SC.F_UnitID
				ORDER BY SC.F_ExerciseID;
			*/
			$sql = <<<EOD
			SELECT SC.F_ExerciseID, SC.F_UnitID, AVG(SC.F_Score) AS AvgScore, COUNT(SC.F_Score) AS NumberDone
				FROM T_Score SC, T_Membership m
				WHERE m.F_UserID<>?
				AND SC.F_CourseID=?
				AND SC.F_Score>=0
				AND SC.F_UserID = m.F_UserID
				AND m.F_RootID=?
				GROUP BY SC.F_ExerciseID, SC.F_UnitID
				ORDER BY SC.F_ExerciseID;
EOD;
		} else {
			$sql = <<<EOD
			SELECT SC.F_ExerciseID, SC.F_UnitID, AVG(SC.F_Score) AS AvgScore, COUNT(SC.F_Score) AS NumberDone
				FROM T_Score as SC, T_Session as SE, T_Membership as M
				WHERE SE.F_UserID=M.F_UserID
				AND SE.F_UserID<>?
				AND SE.F_CourseID=?
				AND SC.F_Score>=0
				AND M.F_RootID=?
				AND SC.F_SessionID=SE.F_SessionID
				GROUP BY SC.F_ExerciseID, SC.F_UnitID
				ORDER BY SC.F_ExerciseID
EOD;
		}

		//$bindingParams = array($rootid, $uid, $cid, $rootid);
		$bindingParams = array($uid, $cid, $rootid);
		$rs = $db->Execute($sql, $bindingParams);

		// Expecting zero or lots of records
		if ($rs->RecordCount() > 0)  {
			foreach($rs as $k=>$row) {
				$thisScore = $row['AvgScore'];
				$thisCount = $row['NumberDone'];
				$node .= "<score itemID='{$row['F_ExerciseID']}' "
					."unit='{$row['F_UnitID']}' "
					."score='{$thisScore}' "
					."count='{$thisCount}' />";
			}
		}
		$rs->Close();
		return true;
	}
	function insertScore( &$vars, &$node ) {
		global $db;
		$rC = $this->insertScoreRecord($vars);
		if (!$rC) {
			$node .= "<err code='205'>Your progress cannot be recorded: " .$db->ErrorMsg() ."</err>";
			return false;
		} else {
			$node .= "<score status='true' />";
		}
		return true;
	}
	function updateSession( &$vars, &$node ) {
		$rC = $this->updateSessionRecord($vars);
		if (!$rC) {
			$node .= "<err code='205'>Your session cannot be updated: " .$db->ErrorMsg() ."</err>";
			return false;
		} else {
			$node .= "<session>updated</session>";
		}
		// A temporary update function for Protea records
		// v6.5.6.5 No longer - we do now know courseID in the session record. So drop this code.
		//$rC = $this->updateSessionCourseID($vars, $node);
		return true;
	}
	// v6.5.4.6 Change password function
	function updatePassword( &$vars, &$node ) {
		$rC = $this->updatePasswordRecord($vars);
		if (!$rC) {
			$node .= "<err code='205'>Your pasword cannot be updated: " .$db->ErrorMsg() ."</err>";
			return false;
		} else {
			$node .= "<note>updated password</note>";
		}
		return true;
	}

	// v6.5.4.7 WZ This method is used only for NEEA of China.
	// See OrchidObjects for more notes on what can be updated
	function updateUser( &$vars, &$node ){
		$rC = $this->updateUserRecord($vars);
		if (!$rC) {
			$node .= "<err code='205'>User information cannot be updated: " .$db->ErrorMsg() ."</err>";
			return false;
		}
		// v6.5.5.0 AR - thsi is not necessary as we already know the userID - it doesn't change
		//$userID = $this->selectNewUser( $vars );
		//if (!$userID) {
		//	$node .= "<err code='205'>user was not updated</err>";
		//	return false;
		//} else {
		//	$vars['USERID'] = $userID;
			$node .= "<user name='".htmlspecialchars($vars['NAME'], ENT_QUOTES, 'UTF-8')."'
				userID='".$vars['USERID']."'
				password='".htmlspecialchars($vars['PASSWORD'], ENT_QUOTES, 'UTF-8')."'
				userSettings='0'
				country='".htmlspecialchars($vars['COUNTRY'], ENT_QUOTES, 'UTF-8')."'
				email='".htmlspecialchars($vars['EMAIL'], ENT_QUOTES, 'UTF-8')."'
				studentID='".htmlspecialchars($vars['STUDENTID'], ENT_QUOTES, 'UTF-8')."'  />";
		//}
		return true;
	}
	function getScratchPad( &$vars, &$node ) {
		global $db;
		$spText = $this->selectScratchPad( $vars );
		if ($spText==false) {
			// v6.5.5.2 Technically this is an error as this user must exist, but now is not really the time to complain
			//$node .= "<err code='203'>no such user</err>";
			$node .= "<scratchPad />";
			return false;
		} else {
			$node .= "<scratchPad><![CDATA[" . $spText . "]]></scratchPad>";
		}
		return true;
	}
	function setScratchPad( &$vars, &$node ) {
		global $db;
		$rC = $this->updateScratchPad( $vars  );
		//print 'db=' .$Db->affected_rows;
		if ($rC) {
			$node .= "<scratchPad>saved</scratchPad>";
		} else {
			$node .= "<err code='205'>Your scratch pad has not been saved." . $db->ErrorMsg() ."</err>";
			return false;
		}
		return true;
	}

	function addUser( &$vars, &$node ) {
		global $db;
		// v6.5.4.6 You could pick up the searchType based on loginOption instead of the data you actually get
		// For instance, if you login with ID, you will also pass a name but don't care if it is unique or not.
//		error_log($vars['LOGINOPTION']."\n", 3, "debugs.log");
		if (($vars['LOGINOPTION'] & 2) == 2) {
			$searchType = "id";
		} else if (($vars['LOGINOPTION'] & 4) == 4) {
			$searchType = "both";
		} else if (($vars['LOGINOPTION'] & 1) == 1) {
			$searchType = "name";
		// v6.5.6.5 Allow email as a unique field for login
		} else if (($vars['LOGINOPTION'] & 8) == 8) {
			$searchType = "email";
		// v6.5.4.7 ClarityEnglish.com special case
		} else if (($vars['LOGINOPTION'] & 64) == 64) {
			$searchType = "userID";
		} else {
				// v6.3.4 Add search type (though not used for adding)
				// v6.4.2 Also allow id or both
				//$rC = $Progress->selectUser( $vars , "name");
				if ($vars['NAME'] <> "") {
					$searchType = "name";
					if ($vars['STUDENTID'] <> "") {
						$searchType = "both";
					}
				} else {
					if ($vars['STUDENTID'] <> "") {
						$searchType = "id";
					}
				}
		}
		$rC = $this->checkUniqueName( $vars, $searchType );
		if (!$rC ) {
			$node .= "<err code='206'>a user with this unique $searchType already exists</err>";
			return false;
		}

		// v6.5.5.2 This should return the userID rather than doing an extra check below. Never mind for now
		$rC = $this->insertUser( $vars );
		if ( !$rC ) {
		    $node .= "<err code='205'>user cannot be added</err>";
		    return false;
		}
		// v6.3.1 get the userID you just added
		$userID = $this->selectNewUser( $vars );
		if (!$userID) {
		    $node .= "<err code='205'>user was not added</err>";
		    return false;
		} else {
			$vars['USERID'] = $userID;
			// v6.5.6 You also need to send back groupID and expiryDate to be consistent with startUser
			if (isset($vars['EXPIRYDATE'])) {
				$expiryDate = $vars['EXPIRYDATE'];
			} else {
				$expiryDate = '';
			}
			// v6.5.6 Protect variables that might not exist
			if (isset($vars['STUDENTID'])) {
				$sid = $vars['STUDENTID'];
			} else {
				$sid = null;
			}
			if (isset($vars['COUNTRY'])) {
				$country = $vars['COUNTRY'];
			} else {
				$country = null;
			}
			if (isset($vars['CITY'])) {
				$city = $vars['CITY'];
			} else {
				$city = null;
			}
			if (isset($vars['REGISTERMETHOD'])) {
				$registerMethod = $vars['REGISTERMETHOD'];
			} else {
				$registerMethod = null;
			}
			if (isset($vars['EMAIL'])) {
				$email = $vars['EMAIL'];
			} else {
				$email = null;
			}
			if (isset($vars['CUSTOM1'])) {
				$custom1 = $vars['CUSTOM1'];
			} else {
				$custom1 = null;
			}	
			$node .= "<user name='".htmlspecialchars($vars['NAME'], ENT_QUOTES, 'UTF-8')."'
				userID='$userID'
				password='".htmlspecialchars($vars['PASSWORD'], ENT_QUOTES, 'UTF-8')."'
				userSettings='0'
				country='".htmlspecialchars($country, ENT_QUOTES, 'UTF-8')."'
				email='".htmlspecialchars($email, ENT_QUOTES, 'UTF-8')."'
				custom1='".htmlspecialchars($custom1, ENT_QUOTES, 'UTF-8')."'
				productCode='".$vars['PRODUCTCODE']."'
				groupID='" .$vars['GROUPID'] ."'
				expiryDate='$expiryDate'
				studentID='".htmlspecialchars($sid, ENT_QUOTES, 'UTF-8')."'  />";
		}
		$rC = $this->insertMembership( $vars );
		if ( !$rC ) {
			$node .= "<err code='205'>membership record not added</err>";
			// v6.5.6 In which case delete the user you just added
			$this->deleteUser($userID);
		    return false;
		}
		return true;
	}
	function getGeneralStats( &$vars, &$node ) {
		global $db;

		$rs = $this->getScoredStats( $vars );

		// add up the exercise scores to get totals
		$countScored=0;
		$countUnScored=0;
		$totalScore=0;
		$totalCorrect=0;
		$duplicates=0;
		$avgScored=0;
		$dupScored=0;
		$dupUnScored=0;
		if ($rs->RecordCount() > 0)  {
			foreach($rs as $k=>$row) {
				//$node .= "<row maxScore='$row[maxScore]' totalScore='$row[totalScore]' cntScore='$row[cntScore]' />";
				$countScored++;
				$totalScore += $row["maxScore"]; // this is the exercise %
				$totalCorrect += $row["totalScore"]; // this is the number of questions you got right
				$duplicates += $row["cntScore"];
			}
		}
		if ($countScored>0) {
			$avgScored = $totalScore / $countScored;
		}
		$dupScored = $duplicates - $countScored;

		// then repeat for the unscored (viewed) ones
		$rs = $this->getViewedStats( $vars );

		// add up the exercise numbers
		$duplicates=0;
		if ($rs->RecordCount() > 0)  {
			foreach($rs as $k=>$row) {
				//$node .= "<row cntUnScore='$row[cntScore]' />";
				$countUnScored++;
				$duplicates= $duplicates+ $row["cntScore"];
			}
		}
		$dupUnScored = $duplicates - $countUnScored;

		$node .= "<stats total='$totalCorrect' average='$avgScored' counted='$countScored' viewed='$countUnScored'
				duplicatesCounted='$dupScored' duplicatesViewed='$dupUnScored' />";
		return 0;
	}
	// v6.5.6 Used to get data for a certificate/summary that isn't in the scaffold. Likely to be very product dependent
	function getSpecificStats( &$vars, &$node ) {
		global $db;

		$pc = $vars['PRODUCTCODE'];
		if (isset($vars['ROOTID'])) $root = $vars['ROOTID'];
		if (isset($vars['ITEMID'])) $exerciseID = $vars['ITEMID'];
		if (isset($vars['SESSIONID'])) $sid = $vars['SESSIONID'];
		// To make testing quicker
		//$sid='1514840';
		//$cid = $vars['COURSEID'];
		$uid = $vars['USERID'];
		
		// For Clarity placement test we want all records (including score details) from this session
		// We will let the certificate figure out what it all means. So no need to hardcode much here.
		if ($pc==44) {
			// First get the scores
                        $sql = <<<EOD
				SELECT *
				FROM T_Score
				WHERE F_UserID=?
				AND F_SessionID=?
EOD;
			$bindingParams = array($uid, $sid);
			$rs = $db->Execute($sql, $bindingParams);
			// Then just format them and send them back
			if ($rs->RecordCount() > 0)  {
				foreach($rs as $k=>$row) {
					$node .= "<score id='$row[F_ExerciseID]' score='$row[F_ScoreCorrect]' duration='$row[F_Duration]' />";
				}
			}
			// then get the details, if any
                        $sql = <<<EOD
				SELECT *
				FROM T_ScoreDetail
				where F_UserID=?
				and F_SessionID=?
EOD;
			//$bindingParams = array($uid, $sid);
			$rs = $db->Execute($sql, $bindingParams);
			// Then just format them and send them back
			if ($rs->RecordCount() > 0)  {
				foreach($rs as $k=>$row) {
					$node .= "<detail id='$row[F_ExerciseID].$row[F_ItemID]' score='$row[F_Score]' />";
				}
			}
		// For CSTDI certificate we need a sequence number
		// We used to do this by storing a score detail record for the certificate. It might be easier to put it in T_User.F_Custom3
		// But it wouldn't work for different products!
		// Mind you it is difficult to get uniqueness in T_ScoreDetail if the certificate exerciseID is the same for many products
		// Perhaps I have to hijack unitID as productCode for this use?
		} else if ($root==10127 || $root==14449) {
		
			$dateNow = date('Y-m-d H:m:s', time());
			
			// Has this user already generated their certificate?
                        $sql = <<<EOD
				SELECT *
				FROM T_ScoreDetail
				WHERE F_UserID=?
				AND F_ExerciseID=?
				AND F_ItemID=?
				AND F_UnitID=?
EOD;
			$bindingParams = array($uid, $exerciseID, 0, $pc);
			$rs = $db->Execute($sql, $bindingParams);
			if ($rs->RecordCount() > 0)  {
			
				// Yes, got a certificate already, so just return the sequence number
				$sequenceNumber = $rs->FetchNextObj()->F_Detail;
				if (!$sequenceNumber>0)
					$sequenceNumber = 0;
				$node .= "<detail sequenceNumber='$sequenceNumber' />";
				return true;
			}
			
			// No, so get the next number and store it for them
                        $sql = <<<EOD
				SELECT MAX(CAST(F_Detail as UNSIGNED INTEGER)) as highestSequenceNumber
				FROM T_ScoreDetail
				WHERE F_RootID=?
				AND F_ExerciseID=?
				AND F_ItemID=?
				AND F_UnitID=?
EOD;
			$bindingParams = array($root, $exerciseID, 0, $pc);
			$rs = $db->Execute($sql, $bindingParams);
			if ($rs->RecordCount() == 1)  {
				$sequenceNumber = $rs->FetchNextObj()->highestSequenceNumber;
				if (!$sequenceNumber>0)
					$sequenceNumber = 0;
				$sequenceNumber++;
			} else {
				$sequenceNumber = 1;
			}
			$node .= "<detail sequenceNumber='$sequenceNumber' />";
			
			// v6.6.0.5 BUG. What this does is write a scoreDetail no matter whether your score/coverage is fail or pass!
			// What you should be doing here is simply getting a sequence number for use IF pass. 
			// Then a different call from the cert will write the record if pass.
			/*
			// As well as writing the certificate sequence number, we need to know the average score for reporting purposes
			// But we haven't called generalStats yet, so need to do that now as an extra call - shouldn't be too expensive
			$newNode = '';
			$rc = $this->getGeneralStats($vars, $newNode);
			// Now average score will be in $node
			// <stats total="1" average="10" counted="1" viewed="0" duplicatesCounted="0" duplicatesViewed="0" />
			$avgStr = 'average=';
			$strPos = stripos($newNode, $avgStr);
			if ($strPos>0) {
				$nearlyNumber = substr($newNode, $strPos + strlen($avgStr) + 1, 3);
				$avgScore = intval($nearlyNumber);
				if (!$nearlyNumber)
					$avgScore = 0;
			} else {
				$avgScore = 0;
			}
			//$node .= "<note>found average=$avgScore at $strPos is $nearlyNumber</note>";
			// So the item is 0, the score is the average score, the detail is the sequence number
			$bindingParams = array($sid, $uid, $exerciseID, $pc, $dateNow, 0, $avgScore, $sequenceNumber, $root);
			$sql = <<<EOD
				INSERT INTO T_ScoreDetail (F_SessionID, F_UserID, F_ExerciseID, F_UnitID, F_DateStamp, F_ItemID, F_Score, F_Detail, F_RootID)
					VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
EOD;
			$rs = $db->Execute($sql, $bindingParams);
			if ($rs) {
				return true;
			} else {
				$node .= "<err code='100'>Can't insert detail record for certificate sequence number.</err>";
				return false;
			}
			*/
			
		} else {
			$node .= "<note>root is $root.</note>";
			return false;
		}
		return true;
	}

	// v6.6.0.5 Just to write a specific detail record
	function writeSpecificStats( &$vars, &$node ) {
		global $db;

		$pc = $vars['PRODUCTCODE'];
		if (isset($vars['ROOTID'])) $root = $vars['ROOTID'];
		if (isset($vars['ITEMID'])) $exerciseID = $vars['ITEMID'];
		if (isset($vars['SESSIONID'])) $sid = $vars['SESSIONID'];
		$uid = $vars['USERID'];
		
		// For CSTDI certificate we need a sequence number
		if ($root==10127 || $root==14449) {
		
			$dateNow = date('Y-m-d H:m:s', time());
			
			// Has this user already generated their certificate?
                        $sql = <<<EOD
				SELECT *
				FROM T_ScoreDetail
				WHERE F_UserID=?
				AND F_ExerciseID=?
				AND F_ItemID=?
				AND F_UnitID=?
EOD;
			$bindingParams = array($uid, $exerciseID, 0, $pc);
			$rs = $db->Execute($sql, $bindingParams);
			if ($rs->RecordCount() > 0)  {
			
				// Yes, got a certificate already, so just return the sequence number
				$sequenceNumber = $rs->FetchNextObj()->F_Detail;
				if (!$sequenceNumber>0)
					$sequenceNumber = 0;
				$node .= "<detail sequenceNumber='$sequenceNumber' />";
				return true;
			}
			
			// No, so get the next number and store it for them
                        $sql = <<<EOD
				SELECT MAX(CAST(F_Detail as UNSIGNED INTEGER)) as highestSequenceNumber
				FROM T_ScoreDetail
				WHERE F_RootID=?
				AND F_ExerciseID=?
				AND F_ItemID=?
				AND F_UnitID=?
EOD;
			$bindingParams = array($root, $exerciseID, 0, $pc);
			$rs = $db->Execute($sql, $bindingParams);
			if ($rs->RecordCount() == 1)  {
				$sequenceNumber = $rs->FetchNextObj()->highestSequenceNumber;
				if (!$sequenceNumber>0)
					$sequenceNumber = 0;
				$sequenceNumber++;
			} else {
				$sequenceNumber = 1;
			}
			$node .= "<detail sequenceNumber='$sequenceNumber' />";
			
			// As well as writing the certificate sequence number, we need to know the average score for reporting purposes
			// But we haven't called generalStats yet, so need to do that now as an extra call - shouldn't be too expensive
			$newNode = '';
			$rc = $this->getGeneralStats($vars, $newNode);
			// Now average score will be in $node
			// <stats total="1" average="10" counted="1" viewed="0" duplicatesCounted="0" duplicatesViewed="0" />
			$avgStr = 'average=';
			$strPos = stripos($newNode, $avgStr);
			if ($strPos>0) {
				$nearlyNumber = substr($newNode, $strPos + strlen($avgStr) + 1, 3);
				$avgScore = intval($nearlyNumber);
				if (!$nearlyNumber)
					$avgScore = 0;
			} else {
				$avgScore = 0;
			}
			//$node .= "<note>found average=$avgScore at $strPos is $nearlyNumber</note>";
			// So the item is 0, the score is the average score, the detail is the sequence number
			$bindingParams = array($sid, $uid, $exerciseID, $pc, $dateNow, 0, $avgScore, $sequenceNumber, $root);
			$sql = <<<EOD
				INSERT INTO T_ScoreDetail (F_SessionID, F_UserID, F_ExerciseID, F_UnitID, F_DateStamp, F_ItemID, F_Score, F_Detail, F_RootID)
					VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
EOD;
			$rs = $db->Execute($sql, $bindingParams);
			if ($rs) {
				return true;
			} else {
				$node .= "<err code='100'>Can't insert detail record for certificate sequence number.</err>";
				return false;
			}
			
		} else {
			$node .= "<note>root is $root.</note>";
			return false;
		}
		return true;
	}

	function getHiddenContent( &$vars, &$node ) {
		global $db;

		if ($vars['DATABASEVERSION']>1) {
			// gh#653 will get back an array now
			$rs = $this->selectHiddenContent( $vars );
			if ($rs) {
				foreach($rs as $UID=>$eF)
					$node .= "<UID id='$UID' enabledFlag='$eF' />";
			} else {
				$node .= "<note>no hidden content</note>";
			}
		}
		return true;
	}

	function getEditedContent( &$vars, &$node ){
		global $db;
		$isGetEdited = false;
		if ($vars['DATABASEVERSION']>1) {
			$groupArr = $this->getGroupParents($vars['GROUPID']);
			$groupnum = count($groupArr);
			if($groupnum > 0){
				$iteration = $groupnum - 1;
				foreach($groupArr as $group){
					$rs = $this->selectEditedContent( $group );
					if ($rs->RecordCount() > 0)  {
						$isGetEdited = true;
						foreach($rs as $k=>$row) {
							// v6.5.6 AR also send the group name for branding 
							$node .= "<UID id='$row[F_EditedContentUID]' relatedid='$row[F_RelatedUID]' groupid='$row[F_GroupID]' ";
							$node .= "groupname='".htmlspecialchars($row['groupName'], ENT_QUOTES, 'UTF-8')."' modeflag='$row[F_Mode]' iteration='$iteration'/>";
						}
					}
					$iteration--;
				}
			}
		}
		//error_log("$node</db>\r\n", 3, "debug.txt");
		if($isGetEdited){
			return true;
		}else{
			$node .= "<note>no edited content</note>";
			return true;
		}
	}
	// v6.5.5.0 I think this is superseeded by Licence.countLicences.
	function countUsers( &$vars, &$node ) {
		global $db;
		$count = $this->countUserRecords($vars);
		if ($count > 0) {
			$node .= "<licence users='$count' />";
		} else {
			$node .= "<err code='208'>technical problem:users table</err>";
			return false;
		}
		return true;
	}
	// v6.5.5.0 For item analysis and portfolios
	function insertScoreDetails($vars, &$node) {
		// v6.5.6.6 No point writing detail records for anonymous users - even if home users have userID=-1, it wouldn't matter as what would they do with scoredetails anyway?
		if ($vars['USERID']<0) 
			return true;
		// Break down the pseudo XML items into array elements
		$xml = simplexml_load_string($vars['SENTDATA']);
		//var_dump($xml);
		if ($xml) {
			$itemArray = $xml->xpath("item");
			//print_r($itemArray);
			foreach ($itemArray as $item) {
				$itemID = $detail = $score = null;
				foreach($item->attributes() as $a => $b) {
					//echo "attributes ".$a."=".$b;
					if ($a=='itemID') $itemid = (int)$b;
					if ($a=='detail') $detail = (string)$b;
					if ($a=='score') $score = (int)$b;
				}
				$node .= "<note>insert detail for question $itemid=$detail</note>";
				$rC = $this->insertScoreDetail($vars, $itemid, $detail, $score);
				if (!$rC) {
					$node .= '<err code="200" />';
				}
			}
			$node .= '<scoreDetail status="true" records="'.count($itemArray).'" />';
			return true;
		} else {
			// This is not exactly a failure, it just means that no detail records were sent
			$node .= '<scoreDetail status="true" records="0" />';
			return true;
		}
	}
	//v6.5.5.1 Log for performance and errors
	function insertLog( &$vars, &$node ){
		global $db;

		$userID  = $vars['USERID'];
		// v6.5.6.6 Make sure we have an integer root, even if useless
		$rootID  = intval($vars['ROOTID']);
		$productCode  = $vars['PRODUCTCODE'];
		$dateStamp = $vars['DATESTAMP'];
		$logCode = $vars['LOGCODE'];
		$message = $vars['SENTDATA'];
		//' v6.5.4.5 The first test is to see if T_DatabaseVersion exists - this is the difference between 1 and 2
		//		(?, ?, ?, CONVERT(datetime, ?, 120),0,?,?)
		// v6.5.6.5 Why the square brackets? SQLServer is fine, but MySQL doesn't like them
		//		([F_ProductName],[F_RootID],[F_UserID],[F_Date],[F_Level],[F_Message],[F_LogCode])
		$sql = <<<EOD
				INSERT INTO T_Log
				(F_ProductName,F_RootID,F_UserID,F_Date,F_Level,F_Message,F_LogCode)
				VALUES
				(?, ?, ?, ?, 0, ?, ?)
EOD;
		$bindingParams = array($productCode, $rootID, $userID, $dateStamp, $message, $logCode);
		$rs = $db->Execute($sql, $bindingParams);
		// Nothing really to do on return
		if (!$rs) {
			// the sql call failed
			$node .= "<err code='300'  />";
			return false;
		} else {
			$node .= "<note>log written</note>";
			return true;
		}
	}
	
	//v6.5.5.8 Log for downloads
	function insertDownloadLog( &$vars, &$node ){
		global $db;

		$email  = $vars['EMAIL'];
		//$referrer  = $vars['REFERRER'];
		$referrer  = "";
		$productCode  = $vars['PRODUCTCODE'];
		$message = $email." downloaded ".$referrer;
		$logCode=null;
		//		([F_ProductName],[F_RootID],[F_UserID],[F_Date],[F_Level],[F_Message],[F_LogCode])
		
		$sql = <<<EOD
				INSERT INTO T_Log
				(F_ProductName,F_RootID,F_UserID,F_Date,F_Level,F_Message,F_LogCode)
				VALUES
				(?, ?, ?, ?, 5, ?, ?)
EOD;
		$bindingParams = array($productCode, null, null, date('Y-m-d H:i:s', time()), $message, $logCode);
		$rs = $db->Execute($sql, $bindingParams);
		// Nothing really to do on return
		if (!$rs) {
			// the sql call failed
			$node .= "<err code='300'  />";
			return false;
		} else {
			$node .= "<note>log written</note>";
			return true;
		}
	}

	// *********
	// Detailed SQL calls
	// *********
	// v6.5.5.0 This is not a licence, it is an instance to protect against double login
	//function insertLicenceID (&$vars) {
	function insertInstanceID (&$vars) {
		global $db;
		if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
			$ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
		} elseif (isset($_SERVER['HTTP_TRUE_CLIENT_IP'])) {
			$ip=$_SERVER['HTTP_TRUE_CLIENT_IP'];
		} elseif (isset($_SERVER["HTTP_CLIENT_IP"])) {
			$ip = $_SERVER["HTTP_CLIENT_IP"];
		} else {
			$ip = $_SERVER["REMOTE_ADDR"];
		}
		// To make sure it fits in the field
		$ip = substr($ip,0,50);
		
		$instanceID = $vars['INSTANCEID'];
		$userID = $vars['USERID'];
		// v6.6.0 CS and IIE don't pass productCode, so just have to lump them together as zero.
		// Note that you do know productCode at this point, but you DON'T when you try to do getInstanceID later.
		// Because SQU can't clear objects.swf they are stuck in a terrible loop. So overwrite their productCode to always use 0
		// BUT dbLicence.php doesn't know rootID, so once their cache cleared, the hack stops working
		//if ($vars['ROOTID']==14265) {
		//	$productCode = 0;
		if (!isset($vars['PRODUCTCODE'])) {
			$productCode = 0;
		} else if ($vars['PRODUCTCODE']==45 || $vars['PRODUCTCODE']==46) {
			$productCode = 0;
		} else {
			$productCode = $vars['PRODUCTCODE'];
		}
		// v6.5.5.0 Needs coordinated action to change the database field name
		// v6.6 Updated field name to instanceID and make is multiple product
		
		// Get the existing set of instance IDs and add/update for this title
		$instanceArray = $this->getInstanceArray($userID);
		$instanceArray[$productCode] = $instanceID;
		
		// #338 SQU hack, additionally add 0 as a productCode with this instance ID
		if (isset($vars['ROOTID']) && $vars['ROOTID']==14265)
			$instanceArray[0] = $instanceID;

		$instanceControl = json_encode($instanceArray);
		
		// #340. SQLite doesn't like symbolic names for the table in an update
		$sql = <<<EOD
			UPDATE T_User
			SET F_UserIP=?, F_InstanceID=? 
			WHERE F_UserID=?
EOD;
		$bindingParams = array($ip, $instanceControl, $userID);
		$resultObj = $db->Execute($sql, $bindingParams);
		if ($resultObj) {
			return true;
		} else {
			return false;
		}
		
		/*
		$sql = <<<EOD
			UPDATE T_User
			SET F_UserIP=?, F_LicenceID=?
			WHERE F_UserID=?
EOD;
		$bindingParams = array($userIP, $lid, $userID);
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			// the sql call failed
			return false;
		} else {
			return true;
		}
		*/
	}
	/**
	 * Helper function to turn string from database to array. Duplicated in dbLicence.php
	 */
	function getInstanceArray($userID) {
		global $db;
		$sql = <<<EOD
		SELECT u.F_InstanceID as control
		FROM T_User u					
		WHERE u.F_UserID=?
EOD;
		$bindingParams = array($userID);
		$rs = $db->Execute($sql, $bindingParams);
		if ($rs && $rs->RecordCount() == 1) {
			
			// Use JSON to encode an array into a string for the database
			return json_decode($rs->FetchNextObj()->control, true);
		}
		
		return array();
	}
	
	function selectCourseHiddenContent( &$vars ) {
		global $db;
		$gid  = $vars['GROUPID'];
		$pid  = $vars['PRODUCTCODE'];
		$sql = <<<EOD
			SELECT F_EnabledFlag, F_CourseID FROM T_HiddenContent
			WHERE F_GroupID=?
			AND F_ProductCode=?
			AND F_EnabledFlag > 0
			AND F_CourseID is not null
			AND F_UnitID is null
			AND F_ExerciseID is null
EOD;
		$bindingParams = array($gid, $pid);
		$rs = $db->Execute($sql, $bindingParams);
		// Expecting lots of records - send them back for looping
		return $rs;
	}
	function selectHiddenContent( &$vars ) {
		global $db;
		$gid  = $vars['GROUPID'];
		$cid  = $vars['COURSEID'];
		$pid  = $vars['PRODUCTCODE'];
		
		// gh#653 It is possible that this user is part of several groups
		if (stripos($gid, ',')) {
			$groupClause = " F_GroupID IN ($gid) ";
		} else {
			$groupClause = " F_GroupID = $gid ";
		}
			
		// Remove any duplicate rows using DISTINCT.
		$sql = <<<EOD
			SELECT DISTINCT F_HiddenContentUID UID, F_EnabledFlag eF FROM T_HiddenContent
			WHERE F_ProductCode=?
			AND $groupClause
			ORDER BY UID
EOD;
		$bindingParams = array($pid);
		$rs = $db->Execute($sql, $bindingParams);
		
		// gh#653 Resolve conflict here - only need to match UID with different eF values
		$buildRS = array();
		if ($rs) {
			//$lastUID = $lastValue = '';
			while ($dbObj = $rs->FetchNextObj()) {
				$thisUID = $dbObj->UID;
				$thisEF = $dbObj->eF;
				// If this UID already exists, change it to the lowest eF (which gives most permission)
				if (array_key_exists($thisUID, $buildRS)) {
					$buildRS[$thisUID] = min($thisEF, $buildRS[$thisUID]);
				} else {
					$buildRS[$thisUID] = $thisEF;
				}
			}
		}
		// gh#653 we are now returning an array, not a recordset
		return $buildRS;
	}
	
	// v6.5.5.7 Get the edited content by groupID
	function selectEditedContent( $gid ){
		global $db;
		//$gid  = $vars['GROUPID'];
		// AR v6.5.6. This looks like it was just copied. Not used so comment
		//$pid  = $vars['PRODUCTCODE'].'.%';
		// v6.5.6 AR I need to get back groupname from this call, so add it to all the sections
		// v6.5.6 This call should be completely rewritten. We should get the groupParentHierarchy on login and then use that here.
		// It will also fail in MySQL.
		/*
		$sql = <<<EOD
			WITH TMP_T_GROUPSTRUCTURE (F_GROUPID, F_GROUPPARENT, Iteration) AS(
				SELECT F_GroupID, F_GroupParent, 0
				FROM T_Groupstructure WHERE F_GroupID = ?
				UNION ALL
				SELECT A.F_GroupID, B.F_GroupParent, A.Iteration + 1
				FROM TMP_T_Groupstructure AS A, T_Groupstructure AS B
				WHERE A.F_GroupParent = B.F_GroupID AND B.F_GroupID <> B.F_GroupParent
			)
			SELECT F_EditedContentUID, E.F_GroupID As F_GroupID, F_Mode, F_RelatedUID, T.Iteration + 1 As Iteration
			FROM T_EditedContent E Join TMP_T_Groupstructure T On E.F_GroupID = T.F_GroupParent
			Union All
			SELECT F_EditedContentUID, F_GroupID, F_Mode, F_RelatedUID, 0 As Iteration
			From T_EditedContent WHERE F_GroupID = ?
			Order By F_Mode DESC, F_EditedContentUID, Iteration DESC
EOD;
		*/
/*		$sql = <<<EOD
			WITH TMP_T_Groupstructure (F_GroupID, F_GroupName, F_GroupParent, Iteration) AS(
				SELECT F_GroupID, F_GroupName, F_GroupParent, 0
				FROM T_Groupstructure WHERE F_GroupID = ?
				UNION ALL
				SELECT A.F_GroupID, A.F_GroupName, B.F_GroupParent, A.Iteration + 1
				FROM TMP_T_Groupstructure AS A, T_Groupstructure AS B
				WHERE A.F_GroupParent = B.F_GroupID 
				AND B.F_GroupID <> B.F_GroupParent
			)
			SELECT ID, F_EditedContentUID, E.F_GroupID As F_GroupID, T.F_GroupName As groupName, F_Mode, F_RelatedUID, T.Iteration + 1 As Iteration
			FROM T_EditedContent E Join TMP_T_Groupstructure T On E.F_GroupID = T.F_GroupParent
			Union All
			SELECT ID, E.F_EditedContentUID, E.F_GroupID, G.F_GroupName As groupName, E.F_Mode, E.F_RelatedUID, 0 As Iteration
			From T_EditedContent E, T_Groupstructure AS G 
			WHERE E.F_GroupID = ?
			AND E.F_GroupID = G.F_GroupID
			ORDER BY ID
EOD;
		$bindingParams = array($gid, $gid);*/
		// Not use the sql recursive, but use the php loop code.
		$sql = <<<EOD
			SELECT ID, E.F_EditedContentUID, E.F_GroupID, G.F_GroupName As groupName, E.F_Mode, E.F_RelatedUID
			From T_EditedContent E, T_Groupstructure AS G
			WHERE E.F_GroupID = ? 
			AND E.F_GroupID = G.F_GroupID
			ORDER BY ID
EOD;
		$bindingParams = array($gid);
		$rs = $db->Execute($sql, $bindingParams);
		// Expecting lots of records - send them back for looping
		return $rs;
	}
	function selectScores ( &$vars ) {
		global $db;
		$uid  = $vars['USERID'];
		$cid  = $vars['COURSEID'];
		//v6.5.4.5 New database has proper datetime fields

         	//Edward: modify query
		if ($vars['DATABASEVERSION']>3) {
			// v6.5.5.5 MySQL migration
			//	SELECT CONVERT(char(19), c.F_DateStamp,120) as formattedDate, c.* FROM T_Score c, T_Session s
			$sql = <<<EOD
				SELECT c.F_DateStamp as formattedDate, c.* FROM T_Score c, T_Session s
				WHERE s.F_UserID=?
				AND c.F_SessionID=s.F_SessionID
				AND s.F_CourseID=?
				ORDER BY c.F_DateStamp
EOD;
		// v6.5.5.5 MySQL migration
		//} else if ($vars['DATABASEVERSION']>1) {
		//	$sql = <<<EOD
		//		SELECT CONVERT(char(19), c.F_DateStamp,120) as formattedDate, c.* FROM T_Score c, T_Session s
		//		WHERE c.F_UserID=?
		//		AND c.F_SessionID=s.F_SessionID
		//		AND s.F_CourseID=?
		//		ORDER BY c.F_DateStamp
//EOD;
		} else {
			$sql = <<<EOD
				SELECT c.F_DateStamp as formattedDate, c.* FROM T_Score c, T_Session s
				WHERE c.F_UserID=?
				AND c.F_SessionID=s.F_SessionID
				AND s.F_CourseID=?
				ORDER BY c.F_DateStamp
EOD;
		}
		$bindingParams = array($uid, $cid);
		$rs = $db->Execute($sql, $bindingParams);
		// Expecting lots of records - send them back for looping
		return $rs;
	}

	//6.5.4.7 WZ the function is used to select the rootID from PHP code, if there is a new user.
	// We know his group from the serial number, then since there MUST be an admin user already,
	// T_Membership will link group and root
	function selectRootIDViaGroupID( &$vars ){
		global $db;
		$gid  = $vars['GROUPID'];
		$sql = <<<EOD
			SELECT DISTINCT F_RootID
			FROM T_Membership
			WHERE F_GroupID = ?
EOD;
		$bindingParams = array($gid);
		$rs = $db->Execute($sql, $bindingParams);
		// v6.5.5.0 There must only be one record, either send the first, or error if more than one
		//if ($rs->RecordCount>=1) {
		if ( $rs->RecordCount()==1 ) {
			$dbObj = $rs->FetchNextObj();
			return $dbObj->F_RootID;
		} else {
			// AR Don't throw exceptions that you are not catching!
			//throw new Exception("Root via Group query failed, db has no group=".$gid);
			//$node .= "<err code=\"207\">db doesn't have group $gid</err>";
			return false;
		}
	}

	//v6.3.5 Session table holds courseID not courseName
	function insertSessionRecord ( &$vars, $dateNow, $userType = 0 ) {
		//print 'insertSession';
		global $db;
		$cid  = $vars['COURSEID'];
		$uid = $vars['USERID'];
                $pid  = $vars['PRODUCTCODE'];
		// v6.6.0 Need to recognise teachers
		if ($userType==0) {
			$rootid = $vars['ROOTID'];
		} else {
			$rootid = -1;
		}
		/*
		// Replace this insert with one that will use adodb to return the new id
		//$bindingParams = array($uid, $cid, $date);
                //$bindingParams = array($uid, $cid, $dateNow, $dateNow, $dateNow, $rootid, $pid);
		//v6.5.4.5 New database has proper datetime fields
		if ($vars['DATABASEVERSION']>1) {
                        $rootid = $vars['ROOTID'];
			$bindingParams[] = $date; // send the start date a second time for use in the calculation
			$bindingParams[] = $rootid;

			// v6.5.5.0 Also (try) to add the product code to the session table (if the column exists)
			// This should be the same as if ($vars['DATABASEVERSION']>2) {
			$tableName = "T_Session";
			$columnName = "F_ProductCode";
			$tempBindingParams = array($tableName, $columnName);
			$sql = <<<EOD
				select name, type_name(xtype) as type, length from syscolumns
				where id = object_id(?)
				and name=?;
EOD;
			$rs = $db->Execute($sql, $tempBindingParams);
			$gotRecords = $rs->RecordCount();
			$rs->Close();
			// no records means this column doesn't exist - should be the same as
			// if ($vars['DATABASEVERSION']>2) {
			//if ($gotRecords>0) {
				//$pid  = $vars['PRODUCTCODE'];
				//$bindingParams[] = $pid;
				// v6.5.5.0 Add productCode to the record
				$sql = <<<EOD
					INSERT INTO T_Session (F_UserID, F_CourseID, F_StartDateStamp, F_EndDateStamp, F_Duration, F_RootID, F_ProductCode)
					VALUES (?, ?, CONVERT(datetime,?,120), DATEADD(second, 15, CONVERT(datetime,?,120)), 15, ?, ?)
EOD;
			} else {
				// v6.5.4.6 Always start the end date to be 15 seconds after the start date so that it should never be NULL
				//	INSERT INTO T_Session (F_UserID, F_CourseID, F_StartDateStamp, F_RootID)
				$sql = <<<EOD
					INSERT INTO T_Session (F_UserID, F_CourseID, F_StartDateStamp, F_EndDateStamp, F_Duration, F_RootID)
					VALUES (?, ?, CONVERT(datetime,?,120), DATEADD(second, 15, CONVERT(datetime,?,120)), 15, ?)
EOD;
			}
		} else {
			$cname  = $vars['COURSENAME'];
			$bindingParams[] = $cname;
			$sql = <<<EOD
				INSERT INTO T_Session (F_UserID, F_CourseID, F_StartDateStamp, F_CourseName)
				VALUES (?, ?, ?, ?)
EOD;
		}
		*/
		$dateNowUnix = strtotime($dateNow);
		$dateSoon = date('Y-m-d H:i:s',strtotime("+15 seconds", $dateNowUnix));
			// v6.5.5.5 MySQL migration
			//	CONVERT(datetime,'$dateNow',120),
			//	DATEADD(second, 15, CONVERT(datetime,'$dateNow',120)),
		// v6.5.5.6 Try to skip courseID in session record, make it cross product
		if ($cid>0) {
			$sql = <<<EOD
				INSERT INTO T_Session (F_UserID, F_CourseID, F_StartDateStamp, F_EndDateStamp, F_Duration, F_RootID, F_ProductCode)
				VALUES ($uid, $cid,
					'$dateNow',
					'$dateSoon',
					15, $rootid, $pid)
EOD;
		} else {
			$sql = <<<EOD
				INSERT INTO T_Session (F_UserID, F_StartDateStamp, F_EndDateStamp, F_Duration, F_RootID, F_ProductCode)
				VALUES ($uid,
					'$dateNow',
					'$dateSoon',
					15, $rootid, $pid)
EOD;
		}
                $rs = $db->Execute($sql);
		if (!$rs) {
			// Log this failure so we can know if this is happening, and hopefully why
			error_log("\r\nfailed session insert root=$rootid user=$uid courseID=$cid productCode=$pid at=$dateNow", 3, dirname(__FILE__).'\logs\failedSessionInsert.txt');
		} else {
			// For a while keep a log of session inserts using server time
			//error_log("\r\ngood session insert root=$rootid user=$uid courseID=$cid productCode=$pid at=".date('Y-m-d H:i:s', time()), 3, dirname(__FILE__).'\logs\goodSessionInsert.txt');
		}
		$id = $db->Insert_ID();
                // Just in case the identity check doesn't work
		if ($id == false) {
			$sql = <<<EOD
				SELECT MAX(F_SessionID) as SessionID FROM T_Session
				WHERE F_UserID=?
				AND F_ProductCode=?
EOD;
			$bindingParams = array($uid, $pid);
			$rs = $db->Execute($sql, $bindingParams);

			if ( $rs->RecordCount()==1 ) {
				$dbObj = $rs->FetchNextObj();
				$id = $dbObj->SessionID;
			} else {
				$id=false;
			}
		}
		return $id;
	}

	function countSessions ( &$vars ) {
		global $db;
		$uid  = $vars['USERID'];
		$cid  = $vars['COURSEID'];
		$sql = <<<EOD
			SELECT COUNT(F_UserID) AS i FROM T_Session
			WHERE F_UserID=?
			AND F_CourseID=?
EOD;
		$bindingParams = array($uid, $cid);
		$rs = $db->Execute($sql, $bindingParams);
		// Expecting just one record
		switch ($rs->RecordCount()) {
			case 1:
				$dbObj = $rs->FetchNextObj();
				break;
			default:
				return false;
		}
		return $dbObj->i;
	}
	/* This call is never made now
	function selectInsertedSessionID ( &$vars, $dateNow , &$node) {
		//print 'selectInsertedSessionID';
		global $db;
		$uid  = $vars['USERID'];
                $rid  = $vars['ROOTID'];   // added by Edward
		$pid  = $vars['PRODUCTCODE'];
		//v6.5.4.5 New database has proper datetime fields
		if ($vars['DATABASEVERSION']>1) {
			$sql = <<<EOD
				SELECT F_SessionID FROM T_Session
				WHERE F_UserID=?
                           	AND F_StartDateStamp=CONVERT(datetime,?,120)
                                AND F_RootID=?
                                AND F_ProductCode=?

EOD;
		} else {
			$sql = <<<EOD
				SELECT F_SessionID FROM T_Session
				WHERE F_UserID=?
				AND F_StartDateStamp=?
EOD;
		}
		$bindingParams = array($uid, $dateNow, $rid, $pid);      // modified by Edward
		$rs = $db->Execute($sql, $bindingParams);
		// Expecting just one record
		switch ($rs->RecordCount()) {
			case 1:
				$dbObj = $rs->FetchNextObj();
				break;
			default:
				return false;
		}
		return $dbObj->F_SessionID;
	}
	*/
	function insertScoreRecord ( &$vars ) {
		global $db;
		$date = $vars['DATESTAMP'];
		// v6.5.5.3 A new bit of data
		if (isset($vars['COURSEID'])) {
			$myCourseID = $vars['COURSEID'];
		} else {
			$myCourseID = null;
		}
		// v6.5.6.6 A new bit of data
		if (isset($vars['PRODUCTCODE'])) {
			$productCode = $vars['PRODUCTCODE'];
		} else {
			$productCode = null;
		}
		// prefer exerciseID, but itemID is acceptable
		if (isset($vars['EXERCISEID'])) {
			$eid = $vars['EXERCISEID'];
		} else {
			$eid = $vars['ITEMID'];
		}
		$userID = $vars['USERID'];
		$bindingParams = array($userID, $date,
				$vars['UNITID'], $vars['SESSIONID'], $eid,
				$vars['TESTUNITS'],
				$vars['SCORE'], $vars['CORRECT'], $vars['WRONG'], $vars['SKIPPED'],
				$vars['DURATION']);
		// Insert a new session
		//v6.3.6 F_ExerciseID converted from longint to double (Access), bigint (MySQL and SQLServer)
		// v6.5.5.3 Added F_CourseID to T_Score
		if ($vars['DATABASEVERSION']>4) {
			$bindingParams[]= $myCourseID;
			// v6.5.6.5 New idea - write anonymous records to an ancilliary table that will not slow down reporting
			$tableName = 'T_Score';
			if ($vars['DATABASEVERSION']>5) {
				if ($userID<1) {
					$tableName = 'T_ScoreAnonymous';
				}
			}
			// v6.5.5.5 MySQL migration
			//		) VALUES (?, CONVERT(datetime,?,120), ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )
			// Denormalise score and session and add productCode into score to help with reporting
			if ($vars['DATABASEVERSION']>5) {
				$bindingParams[]= $productCode;
				$sql = <<<EOD
					INSERT INTO $tableName (
						F_UserID, F_DateStamp,
						F_UnitID, F_SessionID, F_ExerciseID,
						F_TestUnits,
						F_Score, F_ScoreCorrect, F_ScoreWrong, F_ScoreMissed,
						F_Duration, F_CourseID, F_ProductCode
						) VALUES (
						?, ?,
						?, ?, ?,
						?,
						?, ?, ?, ?,
						?, ?, ? )
EOD;
			} else {
				$sql = <<<EOD
					INSERT INTO $tableName (
						F_UserID, F_DateStamp,
						F_UnitID, F_SessionID, F_ExerciseID,
						F_TestUnits,
						F_Score, F_ScoreCorrect, F_ScoreWrong, F_ScoreMissed,
						F_Duration, F_CourseID
						) VALUES (
						?, ?,
						?, ?, ?,
						?,
						?, ?, ?, ?,
						?, ? )
EOD;
			}
		// v6.5.5.5 MySQL migration
		//} else if ($vars['DATABASEVERSION']>1) {
		//	$sql = <<<EOD
		//		INSERT INTO T_Score (
		//			F_UserID, F_DateStamp, F_UnitID, F_SessionID,
		//			F_ExerciseID, F_TestUnits,
		//			F_Score, F_ScoreCorrect, F_ScoreWrong, F_ScoreMissed, F_Duration
		//			) VALUES (?, CONVERT(datetime,?,120), ?, ?, ?, ?, ?, ?, ?, ?, ? )
//EOD;
		} else {
			$sql = <<<EOD
				INSERT INTO T_Score (
					F_UserID, F_DateStamp, F_UnitID, F_SessionID,
					F_ExerciseID, F_TestUnits,
					F_Score, F_ScoreCorrect, F_ScoreWrong, F_ScoreMissed, F_Duration
					) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )
EOD;
		}

		// v6.5.6.6 Since we now have a primary key on T_Score, we need to catch any SQL duplicate key errors gracefully
		try {
			$rs = $db->Execute($sql, $bindingParams);
		} catch (Exception $e) {
			// write out the $e->message to an error log please
			$rs = false;
		}
		if (!$rs) {
			return false;
		} else {
			return true;
		}
	}

	// v6.5.4.7 WZ This method is used only for NEEA of China.
	// See OrchidObjects for more notes on what can be updated
	// NEEA doesn't allow studentID to change, but general it could be. This function isn't doing any checking for unique login
	function updateUserRecord( &$vars ){
		global $db;
		$name = $vars['NAME'];
		//$password = $vars['PASSWORD'];
		//$sid = $vars['STUDENTID'];
		$id= $vars['USERID'];
		//$registerMethod = $vars['REGISTERMETHOD'];
		$userProfileOption = $vars['PRODUCTCODE'];
		if ($vars['EXPIRYDATE'] == "") {
			$expiryDate = null;
		} else {
			$expiryDate = $vars['EXPIRYDATE'];
		}
		$email = $vars['EMAIL'];
		$bindingParams = array($name, $expiryDate, $email, $userProfileOption, $id);
		// v6.5.5.5 MySQL migration
		//		F_ExpiryDate=CONVERT(datetime,?,120),
		$sql = <<<EOD
			UPDATE T_User
			SET F_UserName=?,
				F_ExpiryDate=?,
				F_Email=?,
				F_UserProfileOption=?
			WHERE F_UserID=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			return false;
		} else {
			return true;
		}
	}
	// RL: Temporary function for iLearnIELTS
	function updateUserILearnIELTS( &$vars, &$node ){
		global $db;
		// The value of name doesn't much matter, but it should be encoded
		$name = $vars['NAME'];
		$password = $vars['PASSWORD'];
		if ($vars['CITY'] == "") {
			$city = null;
		} else {
			$city = $vars['CITY'];
		}
		if ($vars['COUNTRY'] == "") {
			$country = null;
		} else {
			$country = $vars['COUNTRY'];
		}
		// Email MUST be unique, so although this should have been checked before passing, check again.
		$email = $vars['EMAIL'];
		$userID = $vars['USERID'];
		$sql = <<<EOD
			SELECT u.* FROM T_User u
			WHERE F_Email=?
			and F_UserID!=?
EOD;
		$bindingParams = array($email,$userID);
		$rs = $db->Execute($sql, $bindingParams);
		switch ($rs->RecordCount()) {
			case 0:
				break;
			default:
				// What is the code for a duplicate email address? 200 is used in addAccountFromScript.php
				$node.="<err code='200'>Email address already used.</err>";
				// Return true as you have already set the error
				return true;
		}
		// You can safely keep going
		$bindingParams = array($name, $password, $email, $city, $country, $userID);
		$sql = <<<EOD
			UPDATE T_User
			SET F_UserName=?,
				F_Password=?,
				F_Email=?,
				F_City=?,
				F_Country=?
			WHERE F_UserID=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			return false;
		} else {
			return true;
		}
	}

	function updateSessionRecord ( &$vars ) {
		global $db;
		//$date = $vars['DATESTAMP'];
		// v6.5.5.0 Should I use $vars['datestamp'] to get the user's own dates rather than the server time?
		//$dateNow = $this->dateNow;
		// v6.6.4 Always use server time for session records
		//if (isset($this->dateNow)) {
		//	$dateNow = $this->dateNow;
		//} else {
			$dateNow = date('Y-m-d H:i:s', time());
		//}
		$sid = $vars['SESSIONID'];
		$bindingParams = array($dateNow);
		//v6.5.4.5 New database has proper datetime fields and a (redundant) duration
		if ($vars['DATABASEVERSION']>1) {
			$bindingParams[] = $dateNow;
			$bindingParams[] = $sid;
			// v6.5.5.5 MySQL migration
			//	SET F_EndDateStamp=CONVERT(datetime,?,120),
			//	F_Duration=DATEDIFF(s,F_StartDateStamp,CONVERT(datetime,?,120))
			//if ($vars['DBDRIVER']=="mysql") {
			// v6.5.5.5 Where does sqlite fit in this?
			if (strpos($vars['DBDRIVER'],"mysql")!==false) {
				$sql = <<<EOD
					UPDATE T_Session
					SET F_EndDateStamp=?,
					F_Duration=TIMESTAMPDIFF(SECOND,F_StartDateStamp,?)
					WHERE F_SessionID=?
EOD;
			} else if (strpos($vars['DBDRIVER'],"sqlite")!==false) {
				$sql = <<<EOD
					UPDATE T_Session
					SET F_EndDateStamp=?,
					F_Duration=strftime('%s',?) - strftime('%s',F_StartDateStamp)
					WHERE F_SessionID=?
EOD;
			} else {
				$sql = <<<EOD
					UPDATE T_Session
					SET F_EndDateStamp=?,
					F_Duration=DATEDIFF(s,F_StartDateStamp,?)
					WHERE F_SessionID=?
EOD;
			}
		} else {
			$bindingParams[] = $sid;
			$sql = <<<EOD
				UPDATE T_Session SET F_EndDateStamp=?
				WHERE F_SessionID=?
EOD;
		}
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			return false;
		} else {
			return true;
		}
	}
	// v6.5.5.6 Temporary for Protea
	function updateSessionCourseID ( $vars, &$node ) {
		global $db;
		// v6.5.5.6 For Protea we have empty courseID in the session record. This will upset usage stats for a while
		// So for a temporary measure we will add the courseID that you now know IF the session.F_CourseID is empty
		// If you swap levels in one session this is not going to be picked up, but it is better than nowt.
		// Or I could always update Protea session records on the basis that you are more likely
		// to accidentally go into the wrong level for the first exercise than the last.
		//		AND F_CourseID is null
		// v6.5.6.5 No longer - we do now know courseID in the session record. So drop this code.
		$sid = $vars['SESSIONID'];
		if (isset($vars['COURSEID'])) {
			$myCourseID = $vars['COURSEID'];
		} else {
			// No courseID means it can't be Protea
			return true;
		}
		if (isset($vars['PRODUCTCODE'])) {
			$pid = $vars['PRODUCTCODE'];
		} else {
			// No productCode means it can't be Protea
			return true;
		}
		if (($pid==45 || $pid==46) && $sid>0 && $myCourseID>0) {
			$sql = <<<EOD
				UPDATE T_Session
				SET F_CourseID=?
				WHERE F_SessionID=?
EOD;
			$bindingParams = array($myCourseID, $sid);
			$rs = $db->Execute($sql, $bindingParams);
			if (!$rs) {
				return false;
			} else {
				$node .= "<note>Updated Protea courseID to $myCourseID</note>";
				return true;
			}
		} else {
			return true;
		}
	}
	// v6.5.4.6 Change password function
	function updatePasswordRecord ( &$vars ) {
		global $db;
		$userID = $vars['USERID'];
		// v6.5.4.6 If you have been sent a new password, use it
		$pwd = $vars['NEWPASSWORD'];
		if ($pwd=="") {
			$pwd = $vars['PASSWORD'];
		}
		$bindingParams = array($pwd, $userID);
		$sql = <<<EOD
			UPDATE T_User
			SET F_Password=?
			WHERE F_UserID=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			return false;
		} else {
			return true;
		}
	}

	function selectScratchPad ( &$vars ) {
		global $db;
		$userid = $vars['USERID'];
		$bindingParams = array($userid);
			$sql = <<<EOD
				SELECT F_ScratchPad FROM T_User
				WHERE F_UserID=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		switch ($rs->RecordCount()) {
			case 1:
				$dbObj = $rs->FetchNextObj();
				break;
			default;
				return false;
		}
		// If the scratch pad is empty, PHP will end up interpreting this as false - generating an err node.
		return $dbObj->F_ScratchPad;
	}
	function updateScratchPad ( &$vars ) {
		global $db;
		$pad = $vars['SENTDATA'];
		$userid = $vars['USERID'];
		$bindingParams = array($pad, $userid);
			$sql = <<<EOD
				UPDATE T_User
				SET F_ScratchPad=?
				WHERE F_UserID=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			return false;
		} else {
			return true;
		}
	}
	// v6.4.2 New function for checking if this username or studentID is unique
	// This function will be overridden by the contents of the include file if it exists
	// the purpose being to let anything running ClarityEnglish to use more complex, cross db checking
	function checkUniqueName ( &$vars , $searchType) {
		global $db;
		// v6.4.2.7 Let username be case insensitive - it seems that MySQL and PHP make it case sensitive by default
		// v6.5.5.2 This will fail to match with some Turkish characters
		$name = strtoupper($vars['NAME']);
		$studentID = strtoupper($vars['STUDENTID']);
		// v6.5.6.5 Allow email to be the unique field used for login
		if (isset($vars['EMAIL']))
			$email = strtoupper($vars['EMAIL']);
		$rootID = $vars['ROOTID'];
		// v6.5.6 use adodb functions for this database specific stuff instead
		//if (strpos($vars['DBDRIVER'],"mssql")>=0 || strpos($vars['DBDRIVER'],"sqlite")>=0) {
		//if (strpos($vars['DBDRIVER'],"mssql")!==false || strpos($vars['DBDRIVER'],"sqlite")!==false) {
		//	$sqlCaseFunction = "UPPER";
		//} else {
		//	$sqlCaseFunction = "UCASE";
		//}
		$bindingParams = array();
		if ($searchType == "name") {
			$whereClause = "WHERE {$db->upperCase}(u.F_UserName)=? ";
			$bindingParams[] = $name;
		} else if ($searchType == "email") {
			$whereClause = "WHERE {$db->upperCase}(u.F_Email)=? ";
			$bindingParams[] = $email;
		} else {
			// v6.4.2 If you are adding both, then neither of them should be present
			// v6.5.5.0 (ES) need brackets round this OR
			if ($searchType == "both") {
				$whereClause = "WHERE ({$db->upperCase}(u.F_UserName)=? OR {$db->upperCase}(u.F_StudentID)=? )";
				$bindingParams[] = $name;
				$bindingParams[] = $studentID;
			} else {
				$whereClause = "WHERE {$db->upperCase}(u.F_StudentID)=? ";
				$bindingParams[] = $studentID;
			}
		}
		$bindingParams[] = $rootID;
			$sql = <<<EOD
				SELECT u.* FROM T_User u, T_Membership m
					$whereClause
					AND u.F_UserID = m.F_UserID
					AND m.F_RootID=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		switch ($rs->RecordCount()) {
			case 0:
				return true;
				break;
			default:
				return false;
		}
	}
	function insertUser( &$vars ) {
		global $db;
		// v6.5.4.6 Add more data - if not passed should all default to valid emptiness
		$name = $vars['NAME'];
		$password = $vars['PASSWORD'];
		// v6.5.6 Protect variables that might not exist
		if (isset($vars['STUDENTID'])) {
			$sid = $vars['STUDENTID'];
		} else {
			$sid = null;
		}
		if (isset($vars['COUNTRY'])) {
			$country = $vars['COUNTRY'];
		} else {
			$country = null;
		}
		if (isset($vars['CITY'])) {
			$city = $vars['CITY'];
		} else {
			$city = null;
		}
		if (isset($vars['REGISTERMETHOD'])) {
			$registerMethod = $vars['REGISTERMETHOD'];
		} else {
			$registerMethod = null;
		}
		if (isset($vars['EMAIL'])) {
			$email = $vars['EMAIL'];
		} else {
			$email = null;
		}
		if (isset($vars['CUSTOM1'])) {
			$custom1 = $vars['CUSTOM1'];
		} else {
			$custom1 = null;
		}		
		// v6.5.4.6 This is a special for Global Road to IELTS where we need to store product option in the user table
		$userProfileOption = $vars['PRODUCTCODE'];
		if ($vars['EXPIRYDATE'] == "") {
			$expiryDate = null;
		} else {
			// I should also validate this, unless I am sure I did it already in AS?
			$expiryDate = $vars['EXPIRYDATE'];
		}

		$usertype = 0; // $vars['USERTYPE'];
		$bindingParams = array($name, $password, $sid, $country, $city, $expiryDate, $registerMethod, $email, $usertype, $userProfileOption, $custom1);
		// v6.5.5.5 MySQL migration
		//	VALUES (?, ?, ?, ?, ?, CONVERT(datetime,?,120), ?, ?, ?, ?, ?)
		$sql = <<<EOD
			INSERT INTO T_User (F_UserName, F_Password, F_StudentID, F_Country, F_City,
							F_ExpiryDate, F_RegisterMethod, F_Email, F_UserType, F_UserProfileOption, F_custom1)
			VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			return false;
		} else {
			return true;
		}
	}
	function selectNewUser ( &$vars ) {
		global $db;

		// v6.5.5.2 To match Turkish names
		$name = $vars['NAME'];
		$upperCaseName = strtoupper($vars['NAME']);
		// v6.5.6 use adodb functions for this database specific stuff instead
		//if (strpos($vars['DBDRIVER'],"mssql")>=0 || strpos($vars['DBDRIVER'],"sqlite")>=0) {
		//if (strpos($vars['DBDRIVER'],"mssql")!==false || strpos($vars['DBDRIVER'],"sqlite")!==false) {
		//	$sqlCaseFunction = "UPPER";
		//} else {
		//	$sqlCaseFunction = "UCASE";
		//}
		$bindingParams = array($upperCaseName, $name);
		$sql = <<<EOD
				SELECT MAX(F_UserID) AS uid FROM T_User
				WHERE {$db->upperCase}(F_UserName)=? OR F_UserName=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		switch ($rs->RecordCount()) {
			case 1:
				$dbObj = $rs->FetchNextObj();
				break;
			default:
				return false;
		}
		return $dbObj->uid;
	}
	// v6.6.0 Need to know the type of a user
	function getUserType ( &$vars ) {
		global $db;

		$uid = $vars['USERID'];
		$bindingParams = array($uid);
		$sql = <<<EOD
				SELECT F_UserType FROM T_User
				WHERE F_UserID=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		switch ($rs->RecordCount()) {
			case 1:
				$dbObj = $rs->FetchNextObj();
				break;
			default:
				// This should be impossible of course, but if something is wrong, best to pretend this person is a student!
				return 0;
		}
		return $dbObj->F_UserType;
	}
	
	//v6.3.1 Add root groupID
	function insertMembership( &$vars ) {
		global $db;
		$rootID = $vars['ROOTID'];
		// v6.5.4.6 We will send a groupID from now on
		// v6.5.6 But we should check it. If it doesn't exist, use the top-level
		$groupID = $vars['GROUPID'];
		$userID = $vars['USERID'];
		$bindingParams = array($groupID);
		$sql = <<<EOD
			SELECT *
			FROM T_Groupstructure
			WHERE F_GroupID=?;
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		// Check to see if we are OK with this group
		if (!$rs->RecordCount()==1) {
			// Find the top-level group instead
			$bindingParams = array($rootID);
			$sql = <<<EOD
				SELECT distinct(g.F_GroupID) as topGroupID
				FROM T_Groupstructure g, T_Membership m
				WHERE g.F_GroupID=g.F_GroupParent
				AND m.F_RootID = ?
				AND g.F_GroupID=m.F_GroupID
EOD;
			$rs = $db->Execute($sql, $bindingParams);			
			if ($rs->RecordCount()==1) {
				$dbObj = $rs->FetchNextObj();
				$groupID = $dbObj->topGroupID;
			} else {
				// You can't find a group to insert membership to - you should rollback the user insert.
				return false;
			}
		}
		// We now have a good groupID so insert
		$bindingParams = array($userID, $groupID, $rootID);
		$sql = <<<EOD
			INSERT INTO T_Membership (F_UserID, F_GroupID, F_RootID)
			VALUES (?, ?, ?);
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			return false;
		} else {
			return true;
		}
	}
	// v6.5 For the certificate - exclude special exercises (assumed to be id<100)
	function getScoredStats( &$vars ) {
		global $db;
		$userID=$vars['USERID'];
		$courseID=$vars['COURSEID'];
		$bindingParams = array($userID, $courseID);
		//Edward: modify query
		// v6.5.6.6 Again, what a stupid query. Why do you need to join it on session at all?
		/*
			SELECT F_ExerciseID, MAX( F_Score ) AS maxScore, COUNT(F_Score) AS cntScore, MAX( F_ScoreCorrect ) AS totalScore
			FROM T_Score c, T_Session s
			WHERE s.F_UserID=?
			AND c.F_UserID=?
                        AND c.F_SessionID=s.F_SessionID
			AND s.F_CourseID=?
			AND c.F_Score>=0
			AND c.F_ExerciseID>=100
			GROUP BY F_ExerciseID
		*/
		$sql = <<<EOD
			SELECT F_ExerciseID, MAX( F_Score ) AS maxScore, COUNT(F_Score) AS cntScore, MAX( F_ScoreCorrect ) AS totalScore
			FROM T_Score c
			WHERE c.F_UserID=?
			AND c.F_CourseID=?
			AND c.F_Score>=0
			AND c.F_ExerciseID>=100
			GROUP BY F_ExerciseID
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		return $rs;
	}
	function getViewedStats( &$vars ) {
		global $db;
		$userID=$vars['USERID'];
		$courseID=$vars['COURSEID'];
		$bindingParams = array($userID, $courseID);
		// v6.5.4.5 Remove the unnecessary max scores as all 0
		//Edward: modify query
		// v6.5.6.6 Again, what a stupid query. Why do you need to join it on session at all?
		if ($vars['DATABASEVERSION']>3) {
		/*
			SELECT F_ExerciseID, COUNT(F_Score) AS cntScore
			FROM T_Score c, T_Session s
			WHERE s.F_UserID=?
			AND c.F_SessionID=s.F_SessionID
			AND s.F_CourseID=?
			AND F_Score<0
			AND c.F_ExerciseID>=100
			GROUP BY F_ExerciseID
		*/
			$sql = <<<EOD
				SELECT F_ExerciseID, COUNT(F_Score) AS cntScore
				FROM T_Score c
				WHERE c.F_UserID=?
				AND c.F_CourseID=?
				AND c.F_Score<0
				AND c.F_ExerciseID>=100
				GROUP BY F_ExerciseID
EOD;
		} else {
                        $sql = <<<EOD
				SELECT F_ExerciseID, COUNT(F_Score) AS cntScore
				FROM T_Score c, T_Session s
				WHERE c.F_UserID=?
				AND c.F_SessionID=s.F_SessionID
				AND s.F_CourseID=?
				AND F_Score<0
				AND c.F_ExerciseID>=100
				GROUP BY F_ExerciseID
EOD;
		}
		$rs = $db->Execute($sql, $bindingParams);
		return $rs;
	}

	// v6.3.2 Count the number of registered users in this root
	function countUserRecords ( &$vars ) {
		global $db;
		$rootID = $vars['ROOTID'];
		$bindingParams = array($rootID);
		if ($vars['DATABASEVERSION']>1 ) {
			$sql = <<<EOD
				SELECT COUNT(u.F_UserID) AS NumStudents from T_User u, T_Membership m
				WHERE m.F_RootID=?
				AND m.F_UserID=u.F_UserID
				AND ((u.F_ExpiryDate is null) OR (u.F_ExpiryDate>? ))
				AND u.F_UserType=0
EOD;
			$bindingParams[] = $vars['DATESTAMP'];
		} else {
			$sql = <<<EOD
				SELECT COUNT(u.F_UserID) AS NumStudents from T_User u, T_Membership m
				WHERE m.F_RootID=?
				AND m.F_UserID=u.F_UserID
				AND u.F_UserType=0
EOD;
		}
		$rs = $db->Execute($sql, $bindingParams);

		//' look at the results (only expecting 1 record)
		if ($rs->RecordCount()>0) {
			$dbObj = $rs->FetchNextObj();
			return (int)$dbObj->NumStudents;
		} else {
			//' should be impossible!
			return false;
		}
	}
	function selectRMSettings( &$vars, &$node ) {
		global $db;
		// The first call depends on databaseVersion
		if ($vars['DATABASEVERSION']>1 ) {
			//$node .= "<note>SelectRMSettings</err>";
			// v6.5.5.1 We might not know root, but know prefix instead
			// v6.5.6 use adodb functions for this database specific stuff instead
			//if (strpos($vars['DBDRIVER'],"mssql")>=0 || strpos($vars['DBDRIVER'],"sqlite")>=0) {
			//if (strpos($vars['DBDRIVER'],"mssql")!==false || strpos($vars['DBDRIVER'],"sqlite")!==false) {
			//	$sqlCaseFunction = "UPPER";
			//} else {
			//	$sqlCaseFunction = "UCASE";
			//}
			if (isset($vars['ROOTID']) && $vars['ROOTID']>0) {
				$rootID = $vars['ROOTID'];
				$bindingParams = array($rootID);
				// v6.5.5.0 This was not reading topGroupID. Why not?
				$sql = <<<EOD
					SELECT a.*, m.F_GroupID as topGroupID
					FROM T_AccountRoot a, T_Membership m
					WHERE a.F_RootID=?
					AND a.F_AdminUserID = m.F_UserID
EOD;
			} elseif (isset($vars['PREFIX'])) {
				$prefix = $vars['PREFIX'];
				$bindingParams = array($prefix);
				$sql = <<<EOD
					SELECT a.*, m.F_GroupID as topGroupID
					FROM T_AccountRoot a, T_Membership m
					WHERE {$db->upperCase}(a.F_Prefix)={$db->upperCase}(?)
					AND a.F_AdminUserID = m.F_UserID
EOD;
			} else {
				// no rootId or prefix can't go on.
				throw new Exception("No root or prefix to identify your account.");
				return false;
			}
		} else {
			$sql = <<<EOD
				SELECT *, F_GroupID as topGroupID FROM T_Groupstructure
				WHERE F_GroupID=?
EOD;
			$groupID = $vars['GROUPID'];
			$bindingParams = array($groupID);
		}
		//print("rootID=".$rootID." and sql=".$sql);
		$rs = $db->Execute($sql, $bindingParams);
		//print_r($rs);

		switch ($rs->RecordCount()) {
			case 0:
				// Invalid data
				// No point throwing an exception since we don't catch it!
				//throw new Exception("No accounts match the data.");
				$node .= "<err code='100'>No account for this product in this root.</err>";
				return false;
			case 1:
				// Valid login
				$dbObj = $rs->FetchNextObj();
				break;
			default:
				// Something is wrong with the database
				// No point throwing an exception since we don't catch it!
				//throw new Exception("Multiple accounts match the data.");
				//print("rs count=".$rs->RecordCount());
				$node .= "<err code='100'>Multiple accounts for this product in this root.</err>";
				return false;
		}
		$rs->Close();
		return $dbObj;
	}
	function selectAccounts( &$vars, &$node ) {
		global $db;
		// v6.5.5.5 MySQL migration. No need to use CONVERT anymore (but this is quite database instance specific I fear)
		//	SELECT CONVERT(char(19), A.F_ExpiryDate,120) as formattedDate,
		//			CONVERT(char(19), A.F_LicenceStartDate,120) as licenceStartDate,
		// v6.5.5.6 I also want to pick up the defaultContentLocation from T_ProductLanguage
		//	SELECT A.F_ExpiryDate as formattedDate,
		//			A.F_LicenceStartDate as licenceStartDate,
		//			R.F_Name as institution,
		//			A.*
		//	FROM T_Accounts A, T_AccountRoot R
		//	WHERE R.F_RootID=?
		// v6.5.5.6 Add accountStatus so you can block suspended accounts
		// In that case I also want to
		$sql = <<<EOD
			SELECT A.F_ExpiryDate as formattedDate,
					A.F_LicenceStartDate as licenceStartDate,
					A.F_LicenceClearanceDate as licenceClearanceDate,
					A.F_LicenceClearanceFrequency as licenceClearanceFrequency,
					R.F_Name as institution,
					A.*,
					P.F_ContentLocation as defaultContentLocation,
					R.F_AccountStatus as accountStatus,
					R.F_ResellerCode as resellerCode
			FROM T_Accounts A, T_AccountRoot R, T_ProductLanguage P
			WHERE R.F_RootID=?
			AND P.F_ProductCode=A.F_ProductCode
			AND P.F_LanguageCode=A.F_LanguageCode
			AND A.F_RootID = R.F_RootID
			AND A.F_ProductCode=?
EOD;
		$rootID = $vars['ROOTID'];
		$productCode = $vars['PRODUCTCODE'];
		$bindingParams = array($rootID, $productCode);
		$rs = $db->Execute($sql, $bindingParams);

		// Expecting just one record
		switch ($rs->RecordCount()) {
			case 0:
				//throw new Exception("No account for this product in this root.");
				// v6.5.5.5 Unless it is for productCode=0
				if ($productCode>0)
					$node .= "<err code='100'>No account for this product in this root.</err>";
				return false;
				break;
			case 1:
				$dbObj = $rs->FetchNextObj();
				break;
			default:
				//throw new Exception("Multiple accounts for the same product in this root.");
				//$node .= "<note>Multiple accounts for the same product in this root.</note>";
				$node .= "<err code='100'>Multiple accounts for this product in this root.</err>";
				return false;
		}
		$rs->Close();
		return $dbObj;
	}
	// v6.5.5.1 Read extra licence details
	function selectLicenceAttributes( &$vars ) {
		global $db;
		// v6.5.5.1 It might be that licence attributes are specific to a title, not just an account
		// Yes I think it must
		$sql = <<<EOD
			SELECT *
			FROM T_LicenceAttributes
			WHERE F_RootID=?
			AND (F_ProductCode=? OR F_ProductCode is null)
EOD;
		$rootID = $vars['ROOTID'];
		$productCode = $vars['PRODUCTCODE'];
		$bindingParams = array($rootID, $productCode);
		$rs = $db->Execute($sql, $bindingParams);

		// Expecting zero or lots of records
		// Remove spaces in the key name and html chars in the value
		$licenceNode = '';
		if ($rs->RecordCount() > 0)  {
			$licenceNode .= "<licence ";
			foreach($rs as $k=>$row) {
				$licenceNode .= str_replace(" ","",$row["F_Key"])."='".htmlspecialchars($row["F_Value"], ENT_QUOTES, 'UTF-8')."' ";
			}
			$licenceNode .= "/>";
		}
		$rs->Close();
		return $licenceNode;
	}

	function selectUser(&$vars, $searchType) {
		global $db;

		// v6.5.4.5 Do we need to worry about string escaping here? No
		//$name = strtoupper($db->dbPrepare($vars['NAME']));
		// v6.5.5.2 You can't use this uppercase function for some Turkish characters, so keep the original too
		$upperCaseName = strtoupper($vars['NAME']);
		$name = $vars['NAME'];
		$upperCaseStudentID = strtoupper($vars['STUDENTID']);
		$studentID = $vars['STUDENTID'];
		$userID = $vars['USERID'];
		$rootID = $vars['ROOTID'];
		if (isset($vars['EMAIL']))
			$email = strtoupper($vars['EMAIL']);
		// v6.5.6 It is possible that you will send a comma delimited list of roots rather than just one.
		// and what if you send a wildcard? Meaning that ALL roots should be checked (such as HCT)
		//$bindingParams = array($rootID);
		$bindingParams = array();
		if ($rootID!='*') {
			$rootClause = " AND m.F_RootID in ($rootID)";
		} else {
			$rootClause = '';
		}
		// v6.5.6 use adodb functions for this database specific stuff instead
		//if (strpos($vars['DBDRIVER'],"mssql")>=0 || strpos($vars['DBDRIVER'],"sqlite")>=0) {
		//if (strpos($vars['DBDRIVER'],"mssql")!==false || strpos($vars['DBDRIVER'],"sqlite")!==false) {
		//	$sqlCaseFunction = "UPPER";
		//} else {
		//	$sqlCaseFunction = "UCASE";
		//}

		// v6.5.4.7 For ClarityEnglish.com
		if ($searchType == "userID") {
			$whereClause = " AND u.F_UserID=? ";
			$bindingParams[] = $userID;
			
		} else if ($searchType == "name") {
			// v6.4.2.7 Let username be case insensitive - it seems that MySQL and PHP make it case sensitive by default
			// v6.5.5.2 Since Turkish doesn't use the same collation for upper casing, allow the original case to match too
			// SQLServer uses UPPER not UCASE
			//$whereClause = "WHERE T_User.F_UserName='$name'";
			//$whereClause = " AND $sqlCaseFunction(u.F_UserName)=? ";
			//$whereClause = " AND u.F_UserName=? ";
			$whereClause = " AND ({$db->upperCase}(u.F_UserName)=? OR u.F_UserName=?)";
			$bindingParams[] = $upperCaseName;
			$bindingParams[] = $name;
			
		} else if ($searchType == "email") {
			$whereClause = " AND {$db->upperCase}(u.F_Email)=? ";
			$bindingParams[] = $email;
			
		} else {
			if ($searchType == "both") {
				$whereClause = " AND ({$db->upperCase}(u.F_UserName)=? OR u.F_UserName=?) AND ({$db->upperCase}(u.F_StudentID)=? OR u.F_StudentID=?) ";
				$bindingParams[] = $upperCaseName;
				$bindingParams[] = $name;
				$bindingParams[] = $upperCaseStudentID;
				$bindingParams[] = $studentID;
			} else {
				$whereClause = " AND ({$db->upperCase}(u.F_StudentID)=? OR u.F_StudentID=?)";
				$bindingParams[] = $upperCaseStudentID;
				$bindingParams[] = $studentID;
			}
		}
		// v6.5.4.6 We may want to specify users of a certain type - or should it be an exact type?
		$userType = $vars['USERTYPE'];
		switch($userType) {
			// if not set, or set to 0 - pick up everyone
			case "":
			case 0:
			case undefined:
				break;
			default:
				$whereClause.= " AND F_UserType>=? ";
				$bindingParams[] = $userType;
		}

		// v6.5.6 Add groupedRoots for HCT SCORM
		if ($vars['DATABASEVERSION']>1 ) {
			// v6.5.5.5 MySQL migration
			//	SELECT CONVERT(char(10), u.F_ExpiryDate,120) as formattedDate, u.*, m.F_GroupID as groupID FROM T_User u, T_Membership m
			//	SELECT u.F_ExpiryDate as formattedDate, u.*, m.F_GroupID as groupID
			//	AND m.F_RootID=?
			$sql = <<<EOD
				SELECT u.F_ExpiryDate as formattedDate, u.F_RegistrationDate as registrationDate, u.*, m.F_GroupID as groupID, m.F_RootID as rootID
				FROM T_User u, T_Membership m
				WHERE u.F_UserID = m.F_UserID
				$rootClause
				$whereClause
EOD;
		} else {
			//	AND m.F_RootID=?
			$sql = <<<EOD
				SELECT NULL as formattedDate, u.*, m.F_GroupID as groupID
				FROM T_User u, T_Membership m
				WHERE u.F_UserID = m.F_UserID
				$rootClause
				$whereClause
EOD;
		}
		// Send back full recordSet for evaluation and use
		return $db->Execute($sql, $bindingParams);
	}

	function selectGlobalUser(&$vars, $searchType) {
		global $db;

		// v6.5.4.5 Do we need to worry about string escaping here?
		//$name = strtoupper($db->dbPrepare($vars['NAME']));
		// v6.5.5.2 See selectUser about capitals
		$name = $vars['NAME'];
		$studentID = $vars['STUDENTID'];
		$upperCaseName = strtoupper($vars['NAME']);
		$upperCaseStudentID = strtoupper($vars['STUDENTID']);
		// password need compared manually
		//$password = $vars['PASSWORD'];
		//$bindingParams = array($password);
		// v6.5.6 use adodb functions for this database specific stuff instead
		//if (strpos($vars['DBDRIVER'],"mssql")>=0 || strpos($vars['DBDRIVER'],"sqlite")>=0) {
		//if (strpos($vars['DBDRIVER'],"mssql")!==false || strpos($vars['DBDRIVER'],"sqlite")!==false) {
		//	$sqlCaseFunction = "UPPER";
		//} else {
		//	$sqlCaseFunction = "UCASE";
		//}
		
		if ($searchType == "name") {
			// v6.4.2.7 Let username be case insensitive - it seems that MySQL and PHP make it case sensitive by default
			// SQLServer uses UPPER not UCASE
			//$whereClause = "WHERE T_User.F_UserName='$name'";
			$whereClause = " AND ({$db->upperCase}(u.F_UserName)=? OR u.F_UserName=?) ";
			$bindingParams[] = $upperCaseName;
			$bindingParams[] = $name;
		} else {
			if ($searchType == "both") {
				$whereClause = " AND ({$db->upperCase}(u.F_UserName)=? OR u.F_UserName=?) AND ({$db->upperCase}(u.F_StudentID)=? OR u.F_StudentID=?) ";
				$bindingParams[] = $upperCaseName;
				$bindingParams[] = $name;
				$bindingParams[] = $upperCaseStudentID;
				$bindingParams[] = $studentID;
			} else {
				$whereClause = " AND ({$db->upperCase}(u.F_StudentID)=? OR u.F_StudentID=?) ";
				$bindingParams[] = $upperCaseStudentID;
				$bindingParams[] = $studentID;
			}
		}
		// v6.5.4.6 We may want to specify users of a certain type - or should it be an exact type?
		$userType = strtoupper($vars['USERTYPE']);
		switch($userType) {
			// if not set, or set to 0 - pick up everyone
			case "":
			case 0:
			case undefined:
				break;
			default:
				$whereClause.= " AND F_UserType>=? ";
				$bindingParams[] = $userType;
		}

		if ($vars['DATABASEVERSION']>1 ) {
			// v6.5.5.5 MySQL migration
			//	SELECT CONVERT(char(19), u.F_ExpiryDate,120) as formattedDate, u.*, m.F_GroupID as groupID, m.F_RootID as rootID  FROM T_User u, T_Membership m
			$sql = <<<EOD
				SELECT u.F_ExpiryDate as formattedDate, u.F_RegistrationDate as registrationDate, u.*, m.F_GroupID as groupID, m.F_RootID as rootID
				FROM T_User u, T_Membership m
				WHERE u.F_UserID = m.F_UserID
				$whereClause
EOD;

		} else {
			$sql = <<<EOD
				SELECT NULL as formattedDate, u.*, m.F_GroupID as groupID, m.F_RootID as rootID
				FROM T_User u, T_Membership m
				WHERE u.F_UserID = m.F_UserID
				$whereClause
EOD;
		}
		// Send back full recordSet for evaluation and use
		return $db->Execute($sql, $bindingParams);
	}

	// v6.5.5.5 Bad name
	//function selectUserDetail(&$vars) {
	function selectUserDetailByStudentID(&$vars) {
		global $db;
		$studentID = strtoupper($vars['STUDENTID']);
		$bindingParams = array($studentID);
		// v6.5.6 use adodb functions for this database specific stuff instead
		//if (strpos($vars['DBDRIVER'],"mssql")>=0 || strpos($vars['DBDRIVER'],"sqlite")>=0) {
		//if (strpos($vars['DBDRIVER'],"mssql")!==false || strpos($vars['DBDRIVER'],"sqlite")!==false) {
		//	$sqlCaseFunction = "UPPER";
		//} else {
		//	$sqlCaseFunction = "UCASE";
		//}
		// v6.5.5.5 MySQL migration
		// TODO What was the purpose of u.F_ExpiryDate-7?? Did it work?
		// In SQLServer it takes off 7 days.
		//	SELECT CONVERT(char(11), u.F_ExpiryDate-7,120) as formattedDate, u.* FROM T_User u
		//if ($vars['DBDRIVER']=="mysql") {
		// I think this is probably something to do with getRegDate call, which is now deprecated, but it doesn't make sense.
		/*
		if (strpos($vars['DBDRIVER'],"mysql")!==false) {
			$sql = <<<EOD
				SELECT DATE_FORMAT(DATE_SUB(u.F_ExpiryDate, INTERVAL 7 DAY),'%Y-%m-%d') as formattedDate, u.* FROM T_User u
				WHERE {$db->upperCase}(u.F_studentID)=?
EOD;
		} else {
			$sql = <<<EOD
				SELECT u.F_ExpiryDate-7 as formattedDate, u.* FROM T_User u
				WHERE {$db->upperCase}(u.F_studentID)=?
EOD;
		}
		*/
		$sql = <<<EOD
			SELECT u.F_ExpiryDate as formattedDate, u.* FROM T_User u
				WHERE {$db->upperCase}(u.F_studentID)=?
EOD;
		// Send back full recordSet for evaluation and use
		return $db->Execute($sql, $bindingParams);
	}

	function selectUserByEmail(&$vars) {
		global $db;
		$email = strtoupper($vars['EMAIL']);
		$bindingParams = array($email);
		// v6.5.6 use adodb functions for this database specific stuff instead
		//if (strpos($vars['DBDRIVER'],"mssql")>=0 || strpos($vars['DBDRIVER'],"sqlite")>=0) {
		//if (strpos($vars['DBDRIVER'],"mssql")!==false || strpos($vars['DBDRIVER'],"sqlite")!==false) {
		//	$sqlCaseFunction = "UPPER";
		//} else {
		//	$sqlCaseFunction = "UCASE";
		//}
		$sql = <<<EOD
			SELECT u.* FROM T_User u
			WHERE {$db->upperCase}(u.F_Email)=?
EOD;
		// Send back full recordSet for evaluation and use
		return $db->Execute($sql, $bindingParams);
	}

	// v6.5.5.0 For item analysis and portfolios
	function insertScoreDetail(&$vars, $itemid, $detail, $score) {
		global $db;
		// These details are the same for each record
		$sid  = (int)$vars['SESSIONID'];
		$userid = (int)$vars['USERID'];
		$rootid  = (int)$vars['ROOTID'];
		if (isset($vars['UNITID'])) {
			$unitid = (float)$vars['UNITID'];
		} else {
			$unitid = null;
		}
		$exid = (float)$vars['EXERCISEID'];
		$date = (string)$vars['DATESTAMP'];
		// then the others are different for each record and are sent as parameters
		// Interesting note; if you leave itemid and detail as untyped variables, adodb screws up and sets them to null using the binding.
		// The other variables are fine. Perhaps we should be a bit more explicit about variable type anyway?
		// Also note that bigint in SQLServer relates to float in php.
		$bindingParams = array($sid, $userid, $exid, $unitid, $date, $itemid, $detail, $score, $rootid);
		//v6.5.5.0 Only the new database has this table
		//		VALUES (?, ?, ?, ?, CONVERT(datetime,?,120), ?, ?, ?, ?)
		if ($vars['DATABASEVERSION']>1) {
			$sql = <<<EOD
				INSERT INTO T_ScoreDetail (F_SessionID, F_UserID, F_ExerciseID, F_UnitID, F_DateStamp, F_ItemID, F_Detail, F_Score, F_RootID)
				VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
EOD;
			$rs = $db->Execute($sql, $bindingParams);
			if ($rs) {
				return true;
			} else {
				return false;
			}
		} else{
			return false;
		}
	}

	// v6.5.5.6 If you need to find the reseller name
	function getReseller($resellerCode) {
		global $db;
		$sql = <<<EOD
			SELECT * FROM T_Reseller
			WHERE F_ResellerID=?
EOD;
		$bindingParams = array($resellerCode);
		// Dig out the reseller name if it exists
		$rs = $db->Execute($sql, $bindingParams);
		if ($rs->RecordCount()==1)  {
			$dbObj = $rs->FetchNextObj();
			return $dbObj->F_ResellerName." (". $dbObj->F_Email .")";
		} else {
			return "";
		}

	}

	// WZ for auto-register
	// AR deprecated. No still used by global BC auto-login portal
	function getRegDate(&$vars, &$node){
		global $db;
		// Go get this user - if it exists
		// v6.5.5.5 Bad name
		//$rs = $this->selectUserDetail($vars);
		$rs = $this->selectUserDetailByStudentID($vars);
		if ($rs->RecordCount() > 0) {
			foreach($rs as $k=>$row) {
				$userRegDate = $row['F_RegistrationDate'];
				$node .= "<user userID='".$row['F_UserID']."' "
					."regDate='{$userRegDate}'/>";
			}
		} else {
			//throw new Exception("Registration date query failed");
			$node .= "<err code='210'>Registration date query failed</err>";
		}
		$rs->Close();
		return true;
	}

	// WZ for Project Emu
	function getUserStartDate(&$vars, &$node){
		global $db;
		$userID = $vars['USERID'];
		$courseID = $vars['COURSEID'];
		$bindingParams = array($userID, $courseID);
		$sql = <<<EOD
			SELECT MIN(F_StartDateStamp) AS STARTDATE, MAX(F_EndDateStamp) AS ENDDATE
			FROM T_Session
			WHERE F_UserID=? AND F_CourseID=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		if ($rs->RecordCount() > 0) {
			foreach($rs as $k=>$row) {
				$node .= "<user userID='{$userID}' "
					."startDate='".$row['STARTDATE']."' "
					."endDate='".$row['ENDDATE']."'/>";
			}
		} else {
			//throw new Exception("Registration date query failed");
			$node .= "<err code='210'>User start date query failed</err>";
		}
		$rs->Close();
		return true;
	}

	// TODO This should be merged into selectUser or a generic getUser
	function Emu_getUser( &$vars, &$node ) {
		global $db; // This means using the global variable $db.

		if($vars['NAME'] == "" && $vars['EMAIL'] == "" && $vars['STUDENTID'] == "" && $vars['USERID'] <= 0) {
			$node .= "<user name=\"\" userID=\"-1\"/>";
			return 0;
		}

		if (($vars['LOGINOPTION'] & 1) == 1) {
			$searchType = "name";
		} else if (($vars['LOGINOPTION'] & 2) == 2) {
			$searchType = "id";
		} else {
			// v6.5.4.8 ItsYourJob special case
			$searchType = "email";
		}

		// Go get this user - if it exists
		$rs = $this->Emu_selectUser($vars, $searchType);
		if ($rs) {
			switch ($rs->RecordCount()) {
				case 0:
					// No such user
					$node .= "<err code=\"203\">no such user</err>";
					return false;
					break;
				case 1:
					// Found one
					$dbObj = $rs->FetchNextObj();
					$typedPassword = $vars['PASSWORD'];
					$dbPassword = $dbObj->F_Password;
					// v6.3.4 null password (sent from APO) )means don't check it
					if ($typedPassword == "$!null_!$") {
						$typedPassword = $dbPassword;
					}
					if ($typedPassword != $dbPassword) {
						$node .= "<err code='204'>Password does not match</err>";
						return false;
					}
					// save some record variables for later
					$vars['USERID'] = $dbObj->F_UserID;
					$vars['EMAIL'] = $dbObj->F_Email;
					//$userExpiryTimestamp = strtotime($dbObj->formattedDate);
					//$userStartTimestamp = strtotime($dbObj->startDate);
					$userStartTimestamp = strtotime($dbObj->F_StartDate);
					$userExpiryTimestamp = strtotime($this->convertLargeDate($dbObj->F_ExpiryDate));
					$licenceStartTimestamp = strtotime($dbObj->LICENCESTARTDATE);
					$licenceExpiryTimestamp = strtotime($this->convertLargeDate($dbObj->LICENCEEXPIRYDATE));
					$Frequency = $dbObj->FREQUENCY;
					$userContactMethod = $dbObj->F_ContactMethod;
					$languageCode = $dbObj->LANGUAGECODE;
					$licenceType = $dbObj->LICENCETYPE;
					$userType = $dbObj->F_UserType;
					if($dbObj->ADMINUSERID == $dbObj->F_UserID){
						$isAdmin = "true";
					}else{
						$isAdmin = "false";
					}

					// Insert this session
					// v6.6.4 Always use server time for session records
					//if (isset($this->dateNow)) {
					//	$dateNow = $this->dateNow;
					//} else {
						$dateNow = date('Y-m-d H:i:s', time());
					//}
					$vars['ROOTID'] = $dbObj->RootID;
					$sessionID = $this->insertSessionRecord($vars, $dateNow);
					//print 'affected_rows=' .$Db->affected_rows;
					if (!$sessionID) {
						$node .= "<err code='205'>Your progress cannot be recorded: " .$db->ErrorMsg() ."</err>";
						return false;
					}

					// build user info
					// Should deprectate passing back userName and instead pass back name
					$node .= "<user userID='" .$dbObj->F_UserID ."'
						userName='" .htmlspecialchars($dbObj->F_UserName, ENT_QUOTES, 'UTF-8') ."'
						name='" .htmlspecialchars($dbObj->F_UserName, ENT_QUOTES, 'UTF-8') ."'
						email='" .htmlspecialchars($dbObj->F_Email, ENT_QUOTES, 'UTF-8') ."'
						startDate='" .$userStartTimestamp."'
						expiryDate='" .$userExpiryTimestamp."'
						licenceStartDate='" .$licenceStartTimestamp."'
						licenceExpiryDate='" .$licenceExpiryTimestamp."'
						licenceType='" .$licenceType."'
						userType='" .$userType."'
						rootid='" .$dbObj->RootID."'
						contactMethod='" .$userContactMethod."'
						sessionID='" .$sessionID."'
						languageCode='" .$languageCode."'
						bookmark='" .$dbObj->F_custom3."'
						isAdmin='" .$isAdmin."'
						frequency='" .$Frequency."' />";
					break;
				default:
					// v6.5.6 TODO this 211 code conflicts with no licences available
					$node .= "<err code='211'>Multiple students match this name/id within this root.</err>";
					return false;
			}
			$rs->Close();
		} else {
			throw new Exception("Query failed");
		}
		return true;
	}

	function Emu_selectUser(&$vars, $searchType) {
		global $db;

		$name = strtoupper($vars['NAME']);
		$upperCaseStudentID = strtoupper($vars['STUDENTID']);
		$studentID = $vars['STUDENTID'];
		$userID = $vars['USERID'];
		$email = strtoupper($vars['EMAIL']);
		$password = $vars['PASSWORD'];
		// v6.5.6 use adodb functions for this database specific stuff instead
		//if (strpos($vars['DBDRIVER'],"mssql")>=0 || strpos($vars['DBDRIVER'],"sqlite")>=0) {
		//if (strpos($vars['DBDRIVER'],"mssql")!==false || strpos($vars['DBDRIVER'],"sqlite")!==false) {
		//	$sqlCaseFunction = "UPPER";
		//} else {
		//	$sqlCaseFunction = "UCASE";
		//}
		$bindingParams = array();
		// v6.5.4.7 For ClarityEnglish.com
		if ($searchType == "name") {
			$whereClause = " AND {$db->upperCase}(U.F_UserName)=? ";
			$bindingParams[] = $name;
		// WZ Added for IYJ SCORM - assumes that the only way to login with ID is SCORM. Hmmm
		}else if ($searchType == "id") {
			$prefix = $vars['PREFIX'];
			$whereClause = " AND ({$db->upperCase}(U.F_StudentID)=? OR U.F_StudentID=?) AND AT.F_Prefix=?";
			$bindingParams[] = $upperCaseStudentID;
			$bindingParams[] = $studentID;
			$bindingParams[] = $prefix;
		}else {
			$whereClause = " AND {$db->upperCase}(U.F_Email)=? ";
			$bindingParams[] = $email;
		}

		if ($vars['DATABASEVERSION'] > 1) {
			$sql = <<<EOD
					SELECT U.*, M.F_RootID AS RootID,
						   T.F_DeliveryFrequency AS FREQUENCY,
						   T.F_LanguageCode AS LANGUAGECODE,
						   T.F_LicenceStartDate AS LICENCESTARTDATE,
						   T.F_ExpiryDate AS LICENCEEXPIRYDATE,
						   T.F_LicenceType AS LICENCETYPE,
						   AT.F_AdminUserID AS ADMINUSERID
					FROM   T_User U JOIN T_Membership M ON U.F_UserID=M.F_UserID
									JOIN T_Accounts T ON M.F_RootID=T.F_RootID
									JOIN T_AccountRoot AT ON M.F_RootID=AT.F_RootID
					WHERE  T.F_ProductCode=1001
					$whereClause
EOD;
		} else {
			$sql = <<<EOD
					SELECT NULL as formattedDate, U.*, M.F_GroupID as groupID FROM T_User U, T_Membership M
					WHERE U.F_UserID = M.F_UserID
					$whereClause
EOD;
		}
		// Send back full recordSet for evaluation and use
		return $db->Execute($sql, $bindingParams);
	}

	function Emu_updateUser( &$vars, &$node ){
		$rC = $this->Emu_updateUserRecord($vars);
		if (!$rC) {
			$node .= "<err code='205'>User information cannot be updated: " .$db->ErrorMsg() ."</err>";
			return false;
		}
		$node .= "<user userID='".$vars['USERID']."'
				contractMethod='".htmlspecialchars($vars['CONTACTMETHOD'], ENT_QUOTES, 'UTF-8')."'
				password='".htmlspecialchars($vars['PASSWORD'], ENT_QUOTES, 'UTF-8')."'
				languageCode='".htmlspecialchars($vars['LANGUAGECODE'], ENT_QUOTES, 'UTF-8')."'
				frequency='".htmlspecialchars($vars['FREQUENCY'], ENT_QUOTES, 'UTF-8')."'  />";
		return true;
	}

	function Emu_updateUserRecord( &$vars ){
		global $db;
		$id = $vars['USERID'];
		$password = $vars['PASSWORD'];
		$contactMethod = $vars['CONTACTMETHOD'];
		$languageCode = $vars['LANGUAGECODE'];
		$frequency = $vars['FREQUENCY'];
		$bindingParams = array($contactMethod, $password, $id);
		$sql = <<<EOD
			UPDATE T_User
			SET F_ContactMethod=?, F_Password=?
			WHERE F_UserID=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			return false;
		} else {
		    switch ($languageCode) {
            case "NAMEN":
                $location = "ItsYourJob-NAmerican";
                break;
            case "INDEN":
                $location = "ItsYourJob-Indian";
                break;
            default:
                $location = "ItsYourJob";
            }
			$bindingParams = array($languageCode, $frequency, $location, $id);
			$sql = <<<EOD
				UPDATE T_Accounts
				SET F_LanguageCode=?, F_DeliveryFrequency=?, F_ContentLocation=?
				WHERE F_RootID IN ( SELECT F_RootID FROM T_Membership WHERE F_UserID=? ) AND (F_ProductCode='1001' OR F_ProductCode='38')
EOD;
			$rs = $db->Execute($sql, $bindingParams);
			if(!rs){
				return false;
			}else{
				return true;
			}
		}
	}

	function Emu_saveBookmark (&$vars) {
		global $db;
		$bookmark = $vars['BOOKMARK'];
		$userID = $vars['USERID'];
		// v6.5.5.0 Needs coordinated action to change the database field name
		$sql = <<<EOD
			UPDATE T_User
			SET F_Custom3=?
			WHERE F_UserID=?
EOD;
		$bindingParams = array($bookmark, $userID);
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			$node .= "<err code='289'>Bookmark cannot be updated: " .$db->ErrorMsg() ."</err>";
			return false;
		}
		$node .= "<user userID='".$userID."' bookmark='".$bookmark."'/>";
		return true;
	}

	// v6.5.5.6 ClarityLifeSkills - or individual licences
	// For now this is a copy of Emu_getUser, but it might be better as copy of globalGetUser or something like that
	// TODO This should be merged into selectUser or a generic getUser
	function CLS_getUser( &$vars, &$node ) {
		global $db; // This means using the global variable $db.

		if($vars['NAME'] == "" && $vars['EMAIL'] == "" && $vars['USERID'] <= 0) {
			$node .= "<user name=\"\" userID=\"-1\"/>";
			return 0;
		}

		// We only login with email in this scenario.
		$searchType = "email";

		// Go get this user - if it exists
		$rs = $this->CLS_selectUser($vars, $searchType);
		if ($rs) {
			switch ($rs->RecordCount()) {
				case 0:
					// No such user
					$node .= "<err code=\"203\">no such user</err>";
					return false;
					break;
				case 1:
					// Found one
					$dbObj = $rs->FetchNextObj();
					$typedPassword = $vars['PASSWORD'];
					$dbPassword = $dbObj->F_Password;
					// v6.3.4 null password (sent from APO) )means don't check it
					if ($typedPassword == "$!null_!$") {
						$typedPassword = $dbPassword;
					}
					if ($typedPassword != $dbPassword) {
						$node .= "<err code='204'>Password does not match</err>";
						return false;
					}
					// save some record variables for later
					$vars['USERID'] = $dbObj->F_UserID;
					$vars['EMAIL'] = $dbObj->F_Email;
					//$userExpiryTimestamp = strtotime($dbObj->formattedDate);
					//$userStartTimestamp = strtotime($dbObj->startDate);
					$userStartTimestamp = strtotime($dbObj->F_StartDate);
					$userExpiryTimestamp = strtotime($this->convertLargeDate($dbObj->F_ExpiryDate));
					$userType = $dbObj->F_UserType;

					// build user info
					// TODO should deprecate passing back userName and instead use name
					$node .= "<user userID='" .$dbObj->F_UserID ."'
						userName='" .htmlspecialchars($dbObj->F_UserName, ENT_QUOTES, 'UTF-8') ."'
						name='" .htmlspecialchars($dbObj->F_UserName, ENT_QUOTES, 'UTF-8') ."'
						email='" .htmlspecialchars($dbObj->F_Email, ENT_QUOTES, 'UTF-8') ."'
						country='" .htmlspecialchars($dbObj->F_Country, ENT_QUOTES, 'UTF-8') ."'
						startDate='" .$userStartTimestamp."'
						expiryDate='" .$userExpiryTimestamp."'
						userType='" .$userType."'
						rootid='" .$dbObj->RootID."'
						prefix='" .$dbObj->Prefix."'
						/>";
					break;
				default:
					// v6.5.6 TODO this 211 code conflicts with no licences available
					$node .= "<err code='211'>Multiple individuals match this email.</err>";
					return false;
			}
			$rs->Close();
		} else {
			throw new Exception("Query failed");
		}
		return true;
	}
	function CLS_selectUser(&$vars, $searchType) {
		global $db;

		//$name = strtoupper($vars['NAME']);
		//$userID = $vars['USERID'];
		$email = strtoupper($vars['EMAIL']);
		// This call doesn't check password, just gets users (individual) with this email
		//$password = $vars['PASSWORD'];
		// v6.5.6 use adodb functions for this database specific stuff instead
		//if (strpos($vars['DBDRIVER'],"mssql")>=0 || strpos($vars['DBDRIVER'],"sqlite")>=0) {
		//if (strpos($vars['DBDRIVER'],"mssql")!==false || strpos($vars['DBDRIVER'],"sqlite")!==false) {
		//	$sqlCaseFunction = "UPPER";
		//} else {
		//	$sqlCaseFunction = "UCASE";
		//}
		//$bindingParams = array($password, $email);
		$bindingParams = array($email);

		// First get unique userIDs - hopefully just one
		//		AND U.F_PASSWORD=?
		$sql = <<<EOD
				SELECT DISTINCT(u.F_UserID)
				FROM T_User u, T_Membership m, T_Accounts t
				WHERE u.F_UserID=m.F_UserID
				AND m.F_RootID=t.F_RootID
				AND t.F_LicenceType=5
				AND {$db->upperCase}(u.F_Email)=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		// If you got one unique userID, then just get the user's details for that guy
		// I am sure I should be able to do this in just one call...
		if ($rs->RecordCount()==1) {
			$dbObj = $rs->FetchNextObj();
			$sql = <<<EOD
					SELECT u.*, m.F_RootID as RootID, a.F_Prefix as Prefix
					FROM T_User u, T_Membership m, T_AccountRoot a
					WHERE u.F_UserID=m.F_UserID
					AND m.F_RootID = a.F_RootID
					AND u.F_UserID = $dbObj->F_UserID
EOD;
			$rs = $db->Execute($sql);
		}
		// Send back full recordSet for evaluation and use
		return $rs;
	}


	// Call duplicated from dbLicence so that stopUser can call it directly
	function dropLicence( &$vars , &$node) {

		$returnCode = $this->deleteLicencesID($vars);
		if ($returnCode) {
			$id = $vars['LICENCEID'];
			$node .= "<licence id='$id'>dropped</licence>";
			return true;
		} else {
			$node .= "<err code='203'>your licence can not be updated: ".$db->ErrorMsg()."</err>";
			return false;
		}
	}
	function deleteLicencesID( &$vars) {
		global $db;
		$id = $vars['LICENCEID'];
		$bindingParams = array($id);
		$sql = <<<EOD
			DELETE FROM T_Licences WHERE F_LicenceID=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			// the sql call failed
			return false;
		} else {
			return true;
		};
	}
	// v6.5.6 Only called if you inserted a new user, but then the membership record wasn't inserted for some reason.
	function deleteUser( $userID) {
		global $db;
		$bindingParams = array($userID);
		$sql = <<<EOD
			DELETE FROM T_User 
			WHERE F_UserID=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			// the sql call failed
			return false;
		} else {
			return true;
		};
	}

	// v6.5.5.5 For network versions
	function updateInformation( &$vars, &$node ) {
		// v6.5.6.4 To be safe in case this productCode has not been listed in the array
		$productCode = $vars['PRODUCTCODE'];
		if (!isset($this->productInformation[$productCode])) {
			$node .= "<err code='205'>Product code $productCode doesn't have a name</err>";
			return false;
		}
		//$node .= "<note>Start of updateInformation</note>";
		$rC = $this->updateUserInfo($vars);
		if (!$rC) {
			$node .= "<err code='205'>Your licence can't be updated: " .$db->ErrorMsg() ."</err>";
			return false;
		}
		$rC = $this->updateGroupInfo($vars);
		if (!$rC) {
			$node .= "<err code='205'>Your licence can't be updated: " .$db->ErrorMsg() ."</err>";
			return false;
		}
		//$node .= "<note>go to updateAccountRootInfo</note>";
		$rC = $this->updateAccountRootInfo($vars);
		if (!$rC) {
			$node .= "<err code='205'>Your licence can't be updated: " .$db->ErrorMsg() ."</err>";
			return false;
		}
		//$node .= "<note>go to updateAccountInfo</note>";
		$rC = $this->updateAccountInfo($vars, $node);
		if (!$rC) {
			$node .= "<err code='205'>Your licence can't be updated: " .$db->ErrorMsg() ."</err>";
			return false;
		}
		$rC = $this->updateProductInfo($vars);
		if (!$rC) {
			$node .= "<err code='205'>Your licence can't be updated: " .$db->ErrorMsg() ."</err>";
			return false;
		}
		if (isset($vars['VALIDCOURSES']) && $vars['VALIDCOURSES']!="") {
			$rC = $this->updateLicenceAttributes($vars, $node);
			if (!$rC) {
				$node .= "<err code='205'>Your licence can't be updated: " .$db->ErrorMsg() ."</err>";
				return false;
			}
		}
		
		$node .= "<status>success</status>";
		return true;
	}
	function updateUserInfo( &$vars ){
		global $db;
		$email = $vars['EMAIL'];
		$bindingParams = array($email);
		$sql = <<<EOD
			UPDATE T_User
			SET F_Email=?
			WHERE F_UserType=2
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			return false;
		} else {
			return true;
		}
	}
	function updateGroupInfo( &$vars ){
		global $db;
		$name = $vars['NAME'];
		$bindingParams = array($name);
		$sql = <<<EOD
			UPDATE T_Groupstructure
			SET F_GroupName=?
			WHERE F_GroupID=1
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			return false;
		} else {
			return true;
		}
	}
	function updateAccountRootInfo( &$vars ){
		global $db;
		$name = $vars['NAME'];
		$email = $vars['EMAIL'];
		$rootID = $vars['ROOTID'];
		$bindingParams = array($email, $name, $rootID);
		$sql = <<<EOD
			UPDATE T_AccountRoot
			SET F_Email=?,
				F_Name=?
			WHERE F_RootID=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			return false;
		} else {
			return true;
		}
	}
	// For picking up details from a network account
	function selectAccountRootInfo( &$vars, &$node ){
		global $db;
		$rootID = $vars['ROOTID'];
		$bindingParams = array($rootID);
		$sql = <<<EOD
			SELECT * FROM T_AccountRoot
			WHERE F_RootID=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			$node .= "<err code='xxx'>Database can't be read.</err>";
			return false;
		}
		if ($rs->RecordCount() == 1) {
			$dbObj = $rs->FetchNextObj();
			$node .= "<account name='".$dbObj->F_Name."' email='".$dbObj->F_Email."'></account>";
		} else {
			$node .= "<err code='xxx'>Account has x records in the database.</err>";
			return false;
		}
		// Also find if our title is already registered
		$rc = $this->selectAccountInfo($vars, $node);
		if ($rc)
			$node .= "<status>success</status>";
		return true;
	}
	// For picking up details from a network account
	function selectAccountInfo($vars, &$node ){
		global $db;
		$rootID = $vars['ROOTID'];
		$bindingParams = array($rootID);
		$sql = <<<EOD
			SELECT F_ProductCode, F_LanguageCode, F_Checksum FROM T_Accounts
			WHERE F_RootID=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			$node .= "<err code='xxx'>Database can't be read.</err>";
			return false;
		}
		if ($rs->RecordCount() >= 1) {
			while ($dbObj = $rs->FetchNextObj()) {
				$node .= "<title productCode='".$dbObj->F_ProductCode."' languageCode='".$dbObj->F_LanguageCode."' checksum='".$dbObj->F_Checksum."'/>";
			}
		} else {
			$node .= "<err code='xxx'>Account has no programs registered in the database.</err>";
			return false;
		}
		return true;
	}
	function updateAccountInfo( &$vars, &$node ){
		global $db;
		$licences = $vars['LICENCES'];
		$checkSum = $vars['CHECKSUM'];
		if (isset($vars['EMUCHECKSUM'])) $EmuCheckSum = $vars['EMUCHECKSUM'];
		$today = substr($vars['DATESTAMP'],0,10).' 00:00:00';
		$expiryDate = $vars['EXPIRYDATE'];
		$rootID = $vars['ROOTID'];
		$productCode = $vars['PRODUCTCODE'];
		$languageCode = $vars['LANGUAGECODE'];
		// CD152B Add in product version as separate from language code 
		$productVersion = $vars['PRODUCTVERSION'];
		$licenceType = $vars['LICENCETYPE'];
		
		// Get content location
		$contentFolder = $this->productInformation[$productCode]['place'];
		switch ($languageCode) {
		case "NAMEN":
			$contentFolder .= "-NAmerican";
			break;
		// v6.5.6.4 This is not always true. TB simply uses a different media folder in -International
		case "INDEN":
			if ($productCode==9) {
				$contentFolder .= "-International";
			} else {
				$contentFolder .= "-Indian";
			}
			break;
		case "EN":
			if ($productCode!=38) $contentFolder .= "-International";
			break;
		}
		$vars['ContentLocation'] = $contentFolder;

		// Check the exist records in the table
		$bindingParams = array($rootID, $productCode);
		$sql = <<<EOD
			SELECT * FROM T_Accounts
			WHERE F_RootID=? AND F_ProductCode=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		if ($rs->RecordCount() >= 1)  { // accounts exist already
			// At this point, if you are adding a new single licence to a title, you should reject the registration
			// if the number of licences doesn't match. But if you are simply updating a compilation, just go ahead.
			// Worry about this later!
			// v6.5.6.5 I don't want F_ContentLocation to be set. It comes from T_ProductLanguage
			//		F_ContentLocation=?,
			$sql = <<<EOD
				UPDATE T_Accounts
				SET F_MaxStudents=?,
					F_LicenceStartDate=?,
					F_ExpiryDate=?,
					F_Checksum=?,
					F_LanguageCode=?,
					F_ProductVersion=?,
					F_LicenceType=?
				WHERE F_RootID=? AND F_ProductCode=?
EOD;
		} else {
			$sql = <<<EOD
				INSERT INTO T_Accounts(
					F_MaxStudents, F_LicenceStartDate, F_ExpiryDate, F_Checksum,
					F_LanguageCode, F_ProductVersion, F_LicenceType, F_RootID, F_ProductCode)
				VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
EOD;
		}
		// Update the first account. Set startDate to yesterday to make sure that UTC doesn't bite you
		$yesterday = date('Y-m-d H:i:s', strtotime($today)-(60*60*24));
		//$bindingParams = array($licences, $yesterday, $expiryDate, $checkSum, $contentFolder, $languageCode, $licenceType, $rootID, $productCode);
		$bindingParams = array($licences, $yesterday, $expiryDate, $checkSum, $languageCode, $productVersion, $licenceType, $rootID, $productCode);

		$rs = $db->Execute($sql, $bindingParams);
		if ($productCode=='38') { // It's Your Job need register two product code
			$productCode2 = 1001;
			// Then the second (EMU) account
			$bindingParams = array($licences, $yesterday, $expiryDate, $EmuCheckSum, $contentFolder, $languageCode, $productVersion, $licenceType, $rootID, $productCode2);
			$rs = $db->Execute($sql, $bindingParams);
		}
		if (!$rs) {
			return false;
		} else {
			$node .= "<note>Your licence expiry date is $expiryDate and language is $languageCode for productCode $productCode</note>";
			
			// gh#1277 Are there any products that automatically install RM?
			if ($productCode=='20') { // MyCanada
				$vars['PRODUCTCODE'] = 2;
				$this->updateAccountInfo($vars, $node);
				// Then the second title
				//$bindingParams = array($licences, $yesterday, $expiryDate, $checkSum, null, null, $licenceType, $rootID, $productCode2);
				//$rs = $db->Execute($sql, $bindingParams);
			}			
			return true;
		}
	}
	function updateProductInfo( &$vars ){
		global $db;
		$productCode = $vars['PRODUCTCODE'];
		$languageCode = $vars['LANGUAGECODE'];
		$contentFolder = $vars['ContentLocation'];

		// Check the existing records in the table
		// Now for T_Product
		$chkParams = array($productCode);
		$chhSQL = <<<EOD
			SELECT * FROM T_Product
			WHERE F_ProductCode=?
EOD;
		$rs = $db->Execute($chhSQL, $chkParams);
		if($rs->RecordCount() <= 0)  {
			$productName = $this->productInformation[$productCode]['name'];
			$bindingParams = array($productCode, $productName);
			$sql = <<<EOD
				INSERT INTO T_Product (F_ProductCode, F_ProductName, F_DisplayOrder)
				VALUES (?, ?, 1)
EOD;
			$rs = $db->Execute($sql, $bindingParams);
		}

		// v6.6 Don't update anything - the database is more likely to be right than this class
		// Now for T_ProductLanguage
		$chkParams = array($productCode, $languageCode);
		$chhSQL = <<<EOD
			SELECT * FROM T_ProductLanguage
			WHERE F_ProductCode=? AND F_LanguageCode=?
EOD;
		$rs = $db->Execute($chhSQL, $chkParams);
		$bindingParams = array($contentFolder, $productCode, $languageCode);
		if($rs->RecordCount() >= 1)  { // account exists already
		/*
			$sql = <<<EOD
				UPDATE T_ProductLanguage
				SET F_ContentLocation=?
				WHERE F_ProductCode=? AND F_LanguageCode=?
EOD;
		*/
		} else { // insert new record
			$sql = <<<EOD
				INSERT INTO T_ProductLanguage (F_ContentLocation, F_ProductCode, F_LanguageCode)
				VALUES (?, ?, ?)
EOD;
			$rs = $db->Execute($sql, $bindingParams);
		}
		if ($productCode==38) {
			$productCode2 = 1001;
			$chkParams = array($productCode2);
			$rs = $db->Execute($chhSQL, $chkParams);
			if($rs->RecordCount() >= 1)  { // accounts exist already
			/*
				$bindingParams = array($contentFolder, $productCode2,$languageCode);
				$sql = <<<EOD
					UPDATE T_ProductLanguage
					SET F_ContentLocation=?
					WHERE F_ProductCode=? AND F_LanguageCode=?
EOD;
			*/
			}else{
				$bindingParams = array($productCode2, $languageCode, $contentFolder);
				$sql = <<<EOD
					INSERT INTO T_ProductLanguage(F_ProductCode, F_LanguageCode, F_ContentLocation)
					VALUES (?, ?, ?)
EOD;
				$rs = $db->Execute($sql, $bindingParams);
			}
		}
		if (!$rs) {
			return false;
		} else {
			return true;
		}
	}
	function updateLicenceAttributes( &$vars, &$node ){
		global $db;
		$rootID = $vars['ROOTID'];
		$productCode = $vars['PRODUCTCODE'];
		// What do you want to add to the licence attributes? 
		if ($vars['VALIDCOURSES']!="" && $vars['VALIDCOURSES']) {
			$key = 'validCourses';
			$value = $vars['VALIDCOURSES'];
		}
		$bindingParams = array($rootID, $productCode, $key);
		$sql = <<<EOD
			SELECT * FROM T_LicenceAttributes
			WHERE F_RootID=? AND F_ProductCode=? AND F_Key=?
EOD;
		$rs = $db->Execute($sql, $bindingParams);		
		if ($rs->RecordCount() >= 1)  { // licence attribute already exists
			// v6.5.6.4 In which case we want to ADD our new courseID to the existing ones
			$existingCourses = $rs->FetchNextObj()->F_Value;
			$newCourses = array_merge(explode(",", $existingCourses), array($value));
			$value = implode(",", array_unique($newCourses));
			$node .= "<note existingCourses='$existingCourses' newCourses='$value' />";
			$sql = <<<EOD
				UPDATE T_LicenceAttributes
				SET F_Value=?
				WHERE F_RootID=? AND F_ProductCode=? AND F_Key=?
EOD;
		} else {
			$sql = <<<EOD
				INSERT INTO T_LicenceAttributes (F_Value, F_RootID, F_ProductCode, F_Key)
				VALUES (?,?,?,?);
EOD;
		}
		$bindingParams = array($value, $rootID, $productCode, $key);
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			return false;
		} else {
			return true;
		}
	}

	function dateTesting($vars, $node) {
		global $db;
		$dateStamp = $vars['DATESTAMP'];
		//$formattedDate = $db->SQLDate('Y-m-d H:i:s', $dateStamp);
		//echo $db->SQLDate('Y-d-m H:i:s', $dateStamp); return;
		$sql = <<<EOD
				SELECT COUNT(F_SessionID) FROM T_Session
				WHERE F_UserID=11259
				AND F_StartDateStamp=?
EOD;
		//$bindingParams = array($db->SQLDate('Y-m-d H:i:s', $dateStamp));
		//$bindingParams = array($formattedDate);
		$bindingParams = array($dateStamp);
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			return false;
		} else {
			return true;
		}
	}
	
	function convertLargeDate($orgdate){
	// Note that you can't do strtotime for dates after 19 Jan 2038 as this is greatest range of integer
	// So well have to do it manually
		$myYearBit = explode(" ", $orgdate);
		$brokenDate = explode("-", $myYearBit[0]);
		if ($brokenDate[0] >= '2038') {
			$convertedDateStamp = date('Y-m-d', strtotime("2038-1-19"));
		} else {
			$convertedDateStamp = $orgdate;
		}
		return $convertedDateStamp;
	}
	function actionscriptEscape($text) {
		$needles = array('_','-','.');
		$replaces = array('%5F','%2D','%2E');
		return str_replace($needles,$replaces,rawurlencode($text));
	}

	function getGroupParents($startGroupID) {
		global $db;
		$result = array();
		$groupID = $startGroupID;
		$keepGoingUp = true;
		do {
			// insert the group ID at the begin of result array.
			array_unshift($result, $groupID);
			$sql = <<<EOD
					SELECT F_GroupParent
					FROM T_Groupstructure
					WHERE F_GroupID=?
EOD;
			$groupRS = $db->Execute($sql, array($groupID));
			// v6.5.6.4 If there are no records, this is a safer test
			//if ($groupRS) {
			if ($groupRS->RecordCount()>0) {
				$parentGroupID = $groupRS->FetchNextObj()->F_GroupParent;
			} else {
				// Shouldn't be here, it means a row is corrupt somehow.
				$parentGroupID = $groupID;
			}
			// Have we found the root group?
			if ($groupID == $parentGroupID) {
				$keepGoingUp = false;
			} else {
				$groupID = $parentGroupID;
			} 
		} while ($keepGoingUp);
		
		return $result;
	}

	// TODO This should be merged into selectUser or a generic getUser
	function getUserWithoutRoot( &$vars, &$node ) {
		global $db; // This means using the global variable $db.

		if($vars['NAME'] == "" && $vars['EMAIL'] == "" && $vars['STUDENTID'] == "" && $vars['USERID'] <= 0) {
			$node .= "<user name=\"\" userID=\"-1\"/>";
			return 0;
		}

		//$searchType = "email";
		//$searchType = "id";
		
		if (($vars['LOGINOPTION'] & 2) == 2) {
			$searchType = "id";
		} else if (($vars['LOGINOPTION'] & 4) == 4) {
			$searchType = "both";
		} else if (($vars['LOGINOPTION'] & 1) == 1) {
			$searchType = "name";
		// v6.5.4.7 ClarityEnglish.com special case
		} else if (($vars['LOGINOPTION'] & 64) == 64) {
			$searchType = "userID";
		} else if (($vars['LOGINOPTION'] & 128) == 128) {
			$searchType = "email";
		}

		// Go get this user - if it exists
		$rs = $this->selectUserWithoutRoot($vars, $searchType);
		if ($rs) {
			switch ($rs->RecordCount()) {
				case 0:
					// No such user
					$node .= "<err code=\"203\">no such user</err>";
					return false;
					break;
				case 1:
					// Found one
					$dbObj = $rs->FetchNextObj();
					$typedPassword = $vars['PASSWORD'];
					$dbPassword = $dbObj->F_Password;
					// v6.3.4 null password (sent from APO) )means don't check it
					if ($typedPassword == "$!null_!$") {
						$typedPassword = $dbPassword;
					}
					if ($typedPassword != $dbPassword) {
						$node .= "<err code='204'>Password does not match</err>";
						return false;
					}
					// save some record variables for later
					$vars['USERID'] = $dbObj->F_UserID;
					$vars['EMAIL'] = $dbObj->F_Email;
					$vars['STUDENTID'] = $dbObj->F_StudentID;
					$userStartTimestamp = strtotime($dbObj->F_StartDate);
					$userExpiryTimestamp = strtotime($this->convertLargeDate($dbObj->F_ExpiryDate));
					$userType = $dbObj->F_UserType;

					// build user info
					// TODO deprecate userName for name
					$node .= "<user userID='" .$dbObj->F_UserID ."'
						userName='" .htmlspecialchars($dbObj->F_UserName, ENT_QUOTES, 'UTF-8') ."'
						name='" .htmlspecialchars($dbObj->F_UserName, ENT_QUOTES, 'UTF-8') ."'
						email='" .htmlspecialchars($dbObj->F_Email, ENT_QUOTES, 'UTF-8') ."'
						studentID='" .htmlspecialchars($dbObj->F_StudentID, ENT_QUOTES, 'UTF-8') ."'
						country='" .htmlspecialchars($dbObj->F_Country, ENT_QUOTES, 'UTF-8') ."'
						city='" .htmlspecialchars($dbObj->F_City, ENT_QUOTES, 'UTF-8') ."'
						startDate='" .$userStartTimestamp."'
						expiryDate='" .$userExpiryTimestamp."'
						userType='" .$userType."'
						rootid='" .$dbObj->RootID."'
						prefix='" .$dbObj->Prefix."'
						/>";
					break;
				default:
					// v6.5.6 TODO this 211 code conflicts with no licences available
					if ($searchType=="email") {
						$node .= "<err code='211'>Multiple individuals match this email.</err>";
					} else if ($searchType=="id") {
						$node .= "<err code='211'>Multiple individuals match this id.</err>";
					} else if ($searchType=="both") {
						$node .= "<err code='211'>Multiple individuals match this name and id.</err>";
					} else {
						$node .= "<err code='211'>Multiple individuals match this name.</err>";
					}
					return false;
			}
			$rs->Close();
		} else {
			throw new Exception("Query failed");
		}
		return true;
	}
	function selectUserWithoutRoot(&$vars, $searchType) {
		global $db;
		
		switch ($searchType) {
			case "userID":
				$userID = $vars['USERID'];
				$whereClause = " AND u.F_UserID=? ";
				$bindingParams = array($userID);
			break;
			case "email":
				$email = strtoupper($vars['EMAIL']);
				$whereClause = " AND {$db->upperCase}(u.F_Email)=?";
				$bindingParams = array($email);		
			break;
			case "id":
				$studentID = strtoupper($vars['STUDENTID']);
				$whereClause = " AND {$db->upperCase}(u.F_StudentID)=?";
				$bindingParams = array($studentID);
			break;
			case "both":
				$name = strtoupper($vars['NAME']);
				$studentID = strtoupper($vars['STUDENTID']);
				$whereClause = " AND {$db->upperCase}(u.F_UserName)=? AND {$db->upperCase}(u.F_StudentID)=?";
				$bindingParams = array($name,$studentID);
			break;
			case "name":
			default:
				$name = strtoupper($vars['NAME']);
				$whereClause = " AND {$db->upperCase}(u.F_UserName)=?";
				$bindingParams = array($name);
			break;
		}		

		// First get unique userIDs - hopefully just one
		// Why is this limiting to licence type 5? CLS only?
		// It appears that this function is not being used. CLS goes to a special one.
		// Common portal wants to use this (for HCT)
		/*
		$sql = <<<EOD
				SELECT DISTINCT(u.F_UserID)
				FROM T_User u, T_Membership m, T_Accounts t
				WHERE u.F_UserID=m.F_UserID
				AND m.F_RootID=t.F_RootID
				AND t.F_LicenceType=5
				$whereClause
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		// If you got one unique userID, then just get the user's details for that guy
		// I am sure I should be able to do this in just one call...
		if ($rs->RecordCount()==1) {
			$dbObj = $rs->FetchNextObj();
			$sql = <<<EOD
					SELECT u.*, m.F_RootID as RootID, a.F_Prefix as Prefix
					FROM T_User u, T_Membership m, T_AccountRoot a
					WHERE u.F_UserID=m.F_UserID
					AND m.F_RootID = a.F_RootID
					AND u.F_UserID = $dbObj->F_UserID
EOD;
			$rs = $db->Execute($sql);
		}
		*/
		$sql = <<<EOD
				SELECT DISTINCT(u.F_UserID), u.*, m.F_RootID as RootID, a.F_Prefix as Prefix
				FROM T_User u, T_Membership m, T_Accounts t, T_AccountRoot a
				WHERE u.F_UserID = m.F_UserID
				AND m.F_RootID = t.F_RootID
				AND m.F_RootID = a.F_RootID
				$whereClause
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		// Send back all details, multiple records handled in parent call
		return $rs;
	}
	// WZ Added for IYJ SCORM functions
	function SCORM_getSummary(&$vars, &$node){
		global $db;
		$sid  = $vars['STUDENTID'];
		$cid  = $vars['COURSEID'];
		$prefix = $vars['PREFIX'];

		$sql = <<<EOD
		SELECT c.F_ExerciseID, max(c.F_Score) as MaxScore, sum(c.F_Duration) as TimeSpend
		FROM T_Score c
		WHERE (c.F_CourseID=? OR c.F_UnitID=?) 
		AND c.F_UserID in (
				SELECT u.F_UserID FROM T_User u, T_Membership m, T_AccountRoot a
				WHERE u.F_UserID = m.F_UserID AND m.F_RootID = a.F_RootID
					AND u.F_StudentID=? AND a.F_Prefix=?
			)
		GROUP BY c.F_ExerciseID
EOD;
		$bindingParams = array($cid, $cid, $sid, $prefix);
		$rs = $db->Execute($sql, $bindingParams);
		// Expecting zero or lots of records
		$count = $rs->RecordCount();
		if ($count > 0)  {
			foreach($rs as $k=>$row) {
				$totalScore += $row['MaxScore'];
				$totalTime += $row['TimeSpend'];
			}
			$node .= "<summary courseid='$cid' count='$count' totalscore='$totalScore' timespend='$totalTime'/>";
		} else {
			$node .= "<summary courseid='$cid' count='0' totalscore='0' timespend='0'/>";
		}
		$rs->Close();
		return true;		
	}
	// AR Added for smarter forgot password lookup
	function forgotPassword(&$vars, &$node){
		global $db;
		$email  = strtoupper($vars['EMAIL']);
		
		// First find any and all users who have this registered email address, and which account they are in
		$sql = <<<EOD
		SELECT r.F_RootID, r.F_Name, r.F_AccountStatus, u.F_UserName, u.F_StudentID, u.F_Password, MAX(a.F_ExpiryDate) as AccountExpiryDate
		FROM T_User u, T_Membership m, T_AccountRoot r, T_Accounts a
		WHERE {$db->upperCase}(u.F_Email)=?
		AND u.F_UserID = m.F_UserID
		AND m.F_RootID = a.F_RootID
		AND m.F_RootID = r.F_RootID
		GROUP BY a.F_RootID
EOD;
		$bindingParams = array($email);
		$rs = $db->Execute($sql, $bindingParams);
		if ($rs) {
			foreach($rs as $k=>$row) {
				// Find each account that this email is registered in, check that it is an active account
				// Is it better to match active, or not suspended?
				//if (strtotime($row['AccountExpiryDate'])>time() && $row['F_AccountStatus']==2)	{
				$name = $row['F_UserName'];
				if (strtotime($row['AccountExpiryDate'])>time() && $row['F_AccountStatus']!=3)	{
					$studentID = $row['F_StudentID'];
					$password = $row['F_Password'];
					$accountName = $row['F_Name'];
					$accountStatus = $row['F_AccountStatus'];
					$node .= "<user name='$name' studentID='$studentID' password='$password' accountName='$accountName' accountStatus='$accountStatus' />";
				} else {
					$node .= "<user name='$name' status='inactive' />";
				}
			}
		}
		$rs->Close();
		return true;		
	}
	
	// AR v6.5.6.9 Use T_LicenceControl 
	function checkLicenceControl(&$vars, &$node){
		global $db;
		$sid  = $vars['SESSIONID'];
		$pid  = $vars['PRODUCTCODE'];
		$uid  = $vars['USERID'];
		// v6.6.4 Always use server time for session records
		//if (isset($this->dateNow)) {
		//	$dateNow = $this->dateNow;
		//} else {
			$dateNow = date('Y-m-d 00:00:00', time());
		//}
		// First need to get rootID from T_Session and licenceType from T_Accounts
		$sql = <<<EOD
			SELECT a.F_RootID as rootID, a.F_LicenceType as licenceType FROM T_Session s, T_Accounts a
			WHERE s.F_SessionID = ?
			AND a.F_RootID = s.F_RootID
			AND a.F_ProductCode = ?
EOD;
		$bindingParams = array($sid, $pid);
		$rs = $db->Execute($sql, $bindingParams);
		if ($rs && $rs->RecordCount()>0) {
			$dbObj = $rs->FetchNextObj();
			$rootID = $dbObj->rootID;
			$licenceType = $dbObj->licenceType;
		} else {
			$node .= "<err code='205'>Your licence cannot be recorded: " .$db->ErrorMsg() ."</err>";
			return false;
		}

		// If this is NOT learner tracking or transferable tracking, just skip out now
		if ($licenceType==1 || $licenceType==6) {
			// Then see if we have already written a licence control record for today
			$sql = <<<EOD
				SELECT * FROM T_LicenceControl
				WHERE F_UserID = ?
				AND F_ProductCode = ?
				AND F_LastUpdateTime >= ?
EOD;
			$bindingParams = array($uid, $pid, $dateNow);
			$rs = $db->Execute($sql, $bindingParams);
			if ($rs && $rs->RecordCount()>0) {
				$dbObj = $rs->FetchNextObj();
				$node .= "<licence id='".$dbObj->F_LicenceID."'/>";
				// We have already written a licence control record for this session, nothing to do now
				return true;
			}
			
			// Insert a licence control record to show this user has used this title today
			$licenceID = $this->insertLicenceControlRecord( $vars, $dateNow );
			if (!$licenceID) {
				$node .= "<err code='205'>Your licence cannot be recorded: " .$db->ErrorMsg() ."</err>";
				return false;
			} else {
				$node .= "<licence id='".$licenceID."'/>";
			}
		} else {
			$node .= "<note>licence type=$licenceType so no control needed</note>";
		}
	}
	// v6.5.6.9
	function insertLicenceControlRecord ( &$vars, $dateNow ) {
		global $db;
		$userID  = $vars['USERID'];
		$productCode  = $vars['PRODUCTCODE'];
		$rootID = $vars['ROOTID'];
		$sql = <<<EOD
				INSERT INTO T_LicenceControl (F_ProductCode, F_RootID, F_UserID, F_LastUpdateTime)
				VALUES (?,?,?,?);
EOD;
		$bindingParams = array($productCode, $rootID, $userID, $dateNow);
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			// Log this failure so we can know if this is happening, and hopefully why
			error_log("\r\nfailed licence control insert root=$rootid user=$uid productCode=$pid at=$dateNow", 3, dirname(__FILE__).'\logs\failedLicenceControl.txt');
		} else {
			// For a while keep a log of session inserts using server time
			//error_log("\r\ngood session insert root=$rootid user=$uid courseID=$cid productCode=$pid at=".date('Y-m-d H:i:s', time()), 3, dirname(__FILE__).'\logs\goodSessionInsert.txt');
		}
		$id = $db->Insert_ID();
                // Just in case the identity check doesn't work
		if ($id == false) {
			$sql = <<<EOD
				SELECT MAX(F_LicenceID) as LicenceID FROM T_LicenceControl
				WHERE F_UserID=?
				AND F_ProductCode=?
EOD;
			$bindingParams = array($uid, $pid);
			$rs = $db->Execute($sql, $bindingParams);

			if ( $rs->RecordCount()==1 ) {
				$dbObj = $rs->FetchNextObj();
				$id = $dbObj->LicenceID;
			} else {
				$id=false;
			}
		}
		return $id;
	}

}
?>
