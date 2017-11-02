<?php
require_once($GLOBALS['common_dir'].'/encryptURL.php');

class DailyJobObs {
	
	var $db;
	var $server;
	
	// TODO Spelling!!!
	
	function DailyJobObs($db = null) {
		// gh#1137 This doesn't work from a cronjob
		$this->server = (isset($_SERVER['HTTP_HOST'])) ? $_SERVER['HTTP_HOST'] : 'www.clarityenglish.com';
		$this->db = $db;
		$this->manageableOps = new ManageableOps($this->db);
		$this->courseOps = new CourseOps($this->db);
		$this->subscriptionOps = new SubscriptionOps($this->db);
		$this->memoryOps = new MemoryOps($this->db);
		$this->licenceOps = new LicenceOps($this->db);
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
	}
	
	// For archiving expired users from a number of roots.
	// Expected to be run by a daily CRON job
	function archiveExpiredUsers($expiryDate, $roots, $database) {
		
		if (is_array($roots)) {
			$rootList = implode(',', $roots);
		} else if ($roots) {
			$rootList = $roots;
		} else {
			return -1;
		}
		$bindingParams = array($expiryDate);
			
		// Find all the users who we want to expire
		// Note you can't pass rootList in bindingParams as it appears as a quoted string in that case
		$sql = <<<SQL
			SELECT * FROM $database.T_User u, $database.T_Membership m 
			WHERE u.F_ExpiryDate <= ?
			AND u.F_UserID = m.F_UserID
			AND m.F_RootID in ($rootList)
SQL;
		$rs = $this->db->Execute($sql, $bindingParams);

		// Loop round the recordset, inserting to *_Expiry then deleting the related records for each userID
		if ($rs->RecordCount() > 0) {
			while ($dbObj = $rs->FetchNextObj()) {
				
				$this->db->StartTrans();
				
				$userID = $dbObj->F_UserID;
				$bindingParams = array($userID);
				
				// gh#359
				if ($userID < 1) {
					AbstractService::$debugLog->notice("Request to delete user $userID repulsed! DailyJobOps.archiveExpiredUsers");
					continue 1;
				}
				 
				$sql = <<<SQL
					INSERT INTO $database.T_Membership_Expiry
					SELECT * FROM $database.T_Membership 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_Membership
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$sql = <<<SQL
					INSERT INTO $database.T_Session_Expiry
					SELECT * FROM $database.T_Session 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_Session
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);

				$sql = <<<SQL
					INSERT INTO $database.T_Score_Expiry
					SELECT * FROM $database.T_Score 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_Score
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);

                // gh#1550
                $sql = <<<SQL
					INSERT INTO $database.T_ScoreDetail_Expiry
					SELECT * FROM $database.T_ScoreDetail 
					WHERE F_UserID = ?;
SQL;
                $rc = $this->db->Execute($sql, $bindingParams);
                $sql = <<<SQL
					DELETE FROM $database.T_ScoreDetail
					WHERE F_UserID = ?;
SQL;
                $rc = $this->db->Execute($sql, $bindingParams);

                $sql = <<<SQL
					INSERT INTO $database.T_User_Expiry
					SELECT * FROM $database.T_User 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_User
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$this->db->CompleteTrans();
			}
		}
		
		// send back the number of archived users
		return $rs->RecordCount();
		
	}
	
	// To delete records from T_Accounts when the licence has expired and move them to archive table
	function archiveExpiredAccounts($expiryDate, $database) {
		
		// copy the expired records to the expiry tables
		// first records from T_Accounts
		$sql = <<<SQL
			INSERT INTO $database.T_Accounts_Expiry
			SELECT * FROM $database.T_Accounts 
			WHERE F_ExpiryDate <= ?
SQL;
		$bindingParams = array($expiryDate);
		$rs = $this->db->Execute($sql, $bindingParams);

		// Then delete these records
		$sql = <<<SQL
			DELETE FROM $database.T_Accounts 
			WHERE F_ExpiryDate <= ?
SQL;
		$rs = $this->db->Execute($sql, $bindingParams);

		// send back the number of deleted users
		return $this->db->Affected_Rows();
		
	}

	// For archiving older users from a number of roots.
	function archiveOldUsers($roots, $registrationDate, $database = 'rack80829') {
		
		if (is_array($roots)) {
			$rootList = implode(',', $roots);
		} else if ($roots) {
			$rootList = $roots;
		} else {
			return -1;
		}
		$bindingParams = array($registrationDate);
			
		// Find all the users who we want to expire
		// Note you can't pass rootList in bindingParams as it appears as a quoted string in that case
		// Only archive students
		$sql = <<<SQL
			SELECT * FROM $database.T_User u, $database.T_Membership m 
			WHERE u.F_RegistrationDate <= ?
			AND u.F_UserID = m.F_UserID
			AND m.F_RootID in ($rootList)
			AND u.F_UserType = 0
SQL;
		$rs = $this->db->Execute($sql, $bindingParams);

		// Loop round the recordset, inserting to *_Expiry then deleting the related records for each userID
		if ($rs->RecordCount() > 0) {
			while ($dbObj = $rs->FetchNextObj()) {
				
				$this->db->StartTrans();
				
				$userID = $dbObj->F_UserID;
				$bindingParams = array($userID);
				
				$sql = <<<SQL
					INSERT INTO $database.T_Membership_Expiry
					SELECT * FROM $database.T_Membership 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_Membership
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				/*
				 * gh#428 Leave session records so we don't impact licence controls
				$sql = <<<SQL
					INSERT INTO $database.T_Session_Expiry
					SELECT * FROM $database.T_Session 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_Session
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				 */
				
				$sql = <<<SQL
					INSERT INTO $database.T_Score_Expiry
					SELECT * FROM $database.T_Score 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_Score
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$sql = <<<SQL
					INSERT INTO $database.T_User_Expiry
					SELECT * FROM $database.T_User 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_User
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$this->db->CompleteTrans();
			}
		}
		
		// send back the number of archived users
		return $rs->RecordCount();
		
	}

    // git#1230 For archiving LT licences that have expired
    // Expected to be run by a daily CRON job
    function archiveExpiredLicences($expiredDate, $database) {

        $this->db->StartTrans();
        $sql = <<<SQL
			INSERT INTO $database.T_LicenceHoldersDeleted
			SELECT * FROM $database.T_LicenceHolders 
			WHERE F_EndDateStamp < ?;
SQL;
        $bindingParams = array($expiredDate);
        $rs = $this->db->Execute($sql, $bindingParams);

        $sql = <<<SQL
			DELETE FROM $database.T_LicenceHolders
			WHERE F_EndDateStamp < ?;
SQL;
        $rs = $this->db->Execute($sql, $bindingParams);
        $recordCount = $this->db->Affected_Rows();

        $this->db->CompleteTrans();

        // send back the number of deleted records
        return $recordCount;
    }

    // gh#1230 To create a new licence if the user has an existing one
    public function createNewStyleLicence($userId, $rootId, $productCode, $licence, $earliestDate) {

        // Extra check to make sure that this user doesn't have a new licence already for this title
        if (!$this->licenceOps->checkExistingLicence($userId, $productCode, $licence)) {
            $this->licenceOps->convertLicenceSlot($userId, $productCode, $rootId, $licence, $earliestDate);
            AbstractService::$log->info("add a licence for " . $userId . " to " . $productCode);
            return true;
        }
        return false;
    }

    // For archiving sent emails.
	// Expected to be run by a daily CRON job
	function archiveSentEmails($database) {
		
		$this->db->StartTrans();
		$sql = <<<SQL
			INSERT INTO $database.T_SentEmails
			SELECT * FROM $database.T_PendingEmails 
			WHERE F_SentTimestamp is not null;
SQL;
		$rs = $this->db->Execute($sql);
		
		$sql = <<<SQL
			DELETE FROM $database.T_PendingEmails
			WHERE F_SentTimestamp is not null;
SQL;
		$rs = $this->db->Execute($sql);
		$recordCount = $this->db->Affected_Rows();
		
		$this->db->CompleteTrans();
		
		// send back the number of archived emails
		return $recordCount;
		
	}
	
	/*
	 * gh#122 For courses that are published as groupAssigned (the default) see if
	 * 		any groups have units start today. If they do, then get all active users in the groups
	 * 		and send them an email.
	 * 
	 */
	public function getEmailsForGroupUnitStart($today) {

		// Initialise
		$emailArray = array();
		
		$sql = <<<SQL
			SELECT us.*, 
					ar.F_Prefix as prefix, ar.F_LoginOption as loginOption,	a.F_ContentLocation as contentLocation
			FROM T_UnitStart us, T_CourseStart cs, T_AccountRoot ar, T_Accounts a 
			WHERE us.F_CourseID = cs.F_CourseID
			AND us.F_GroupID = cs.F_GroupID
			AND us.F_StartDate = ? 
			AND cs.F_StartMethod = 'group'
			AND ar.F_RootID = cs.F_RootID
			AND ar.F_RootID = a.F_RootID
			AND a.F_ProductCode = 54
			ORDER by us.F_CourseID
SQL;
		$bindingParams = array($today);
		$rs = $this->db->Execute($sql, $bindingParams);

		// Loop round the recordset of groups/units
		$savedCourseID = 0;
		if ($rs->RecordCount() > 0) {
			while ($dbObj = $rs->FetchNextObj()) {
				$courseID = $dbObj->F_CourseID;
				$groupID = $dbObj->F_GroupID;
				$unitID = $dbObj->F_UnitID;
				// TODO. Would it be better to get the whole account object?
				$contentLocation = $dbObj->contentLocation;
				$prefix = $dbObj->prefix;
				$loginOption = $dbObj->loginOption;
				
				// I want to get course and unit data - but that means reading the xml!
				// I would like to put the course name, teacher details, unit name, direct start URL into the email
				// If I order the SQL by group ID, then I can at least do all at once
				// $this->courseOps->setAccountFolder('../../'.$GLOBALS['ccb_data_dir'].'/'.$contentLocation);
				// gh#122 Trouble working out a folder path that works for php command line AND URL running.
				// echo "DailyJobOps running from ".__DIR__."/n";
				$this->courseOps->setAccountFolder(dirname(__FILE__).'/../'.$GLOBALS['ccb_data_dir'].'/'.$contentLocation);
				
				if ($savedCourseID != $courseID) {
					// Add properties to the course object that we will send to the email
					// TODO. This seems abusive use of the course since we give it properties that are not in the class
					$course = new Course();
					$courseXML = $this->courseOps->getCourse($courseID);
					$courseXML->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
					
					foreach ($courseXML->attributes() as $key => $value)
						$course->{$key} = (string) $value;

					// Grab the unit caption
					$unitXML = $courseXML->xpath("//xmlns:unit[@id='$unitID']");
					foreach ($unitXML[0]->attributes() as $key => $value) {
						if (strtolower($key) == 'caption') {
							$course->unitName = (string) $value;
							break;
						}
					}
					// Add other useful data into the course
					$course->prefix = $prefix;
					$course->loginOption = $loginOption;
					$course->startDate = $today;
			
				}
				
				// Now we need get all the active users in this group
				$userRS = $this->courseOps->getCourseUsersFromGroup($courseID, $groupID, $today);
				
				// Loop round the users and build an email array
				if ($userRS->RecordCount() > 0) {
					while ($userObj = $userRS->FetchNextObj()) {
						$user = new User();
						$user->fromDatabaseObj($userObj);
						
						// Send email IF we have one
						if (isset($user->email) && $user->email) {
							// Just during inital testing - only send emails to me
							//$toEmail = 'adrian@noodles.hk';
							$toEmail = $user->email;
							$emailData = array("user" => $user, "course" => $course);
							$thisEmail = array("to" => $toEmail, "data" => $emailData);
							$emailArray[] = $thisEmail;
							
						}
					}
				}
			}
		}
		return $emailArray;
	}

	/*
	 * gh#122 For courses that are published as userFirstUse 
	 * 		get all active users in the group (and subgroups)
	 * 		check if they have ever used the course, if they have, find the first date
	 * 		see if any subsequent units are a unitInterval multiple of days away from that date
	 * 		send the email
	 * Note: this does NOT send a welcome email, so a course with just one unit never triggers this
	 */
	public function getEmailsForUserUnitStart($today) {

		// Initialise
		$emailArray = array();
		
		$sql = <<<SQL
			SELECT cs.* FROM T_CourseStart cs 
			WHERE cs.F_StartMethod = 'user'
			ORDER by cs.F_CourseID
SQL;
		$bindingParams = array();
		$rs = $this->db->Execute($sql, $bindingParams);

		// Loop round the recordset of courses and groups
		$savedCourseID = 0;
		if ($rs->RecordCount() > 0) {
			while ($dbObj = $rs->FetchNextObj()) {
				$courseID = $dbObj->F_CourseID;
				$groupID = $dbObj->F_GroupID;
				$rootID = $dbObj->F_RootID;
				$unitsInterval = $dbObj->F_UnitInterval;

				// First do some simple SQL to see if anyone in this root has started the course yet
				// TODO. Or you could call getGroupSubgroups and then check all those groups for finer control
				// but the purpose of this call is to quickly weed out courses that no-one is doing.
				// Note however that this is NOT a quick call - is it worth it?
				$sql = <<<SQL
					SELECT count(*) FROM T_Session s, T_Membership m 
					WHERE s.F_UserID = m.F_UserID
					AND m.F_RootID = ?
SQL;
				$bindingParams = array($rootID);
				$rs1 = $this->db->Execute($sql, $bindingParams);
				
				// Nobody has started this course, so nothing to do
				if ($rs1->RecordCount() <= 0)
					break;
				
				// Then need all the users in this group and subgroups
				$userRS = $this->courseOps->getCourseUsersFromGroup($courseID, $groupID, $today);

				// and find out how many units there are
				if ($savedCourseID != $courseID) {
					$this->courseOps->setAccountFolder('../../'.$GLOBALS['ccb_data_dir'].'/'.'Clarity');
					
					$courseXML = $this->courseOps->getCourse($courseID);
					$courseXML->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
					$units = count($courseXML->xpath("//xmlns:unit"));
					
					// a course with one unit never needs emails
					if ($units <= 1)
						break;
					
					// save the course details for adding to the email
					$course = new Course();
					foreach ($courseXML->attributes() as $key => $value)
						$course->{$key} = (string) $value;
											
				}
				
				// Loop round the users and see if any of them started the course a whole number of unitsInterval ago
				if ($userRS->RecordCount() > 0) {
					while ($userObj = $userRS->FetchNextObj()) {
						$user = new User();
						$user->fromDatabaseObj($userObj);

						// what was this user's first start date for this course?
						$sql = <<<SQL
							SELECT MIN(F_StartDateStamp) as startDate FROM T_Session s 
							WHERE s.F_UserID = ?
							AND s.F_CourseID = ?
SQL;
						$bindingParams = array($user->id, $courseID);
						$sessionRS = $this->db->Execute($sql, $bindingParams);
						
						if (!$sessionRS || $sessionRS->RecordCount() == 0)
							break 1; // this user has not started this course, so goto next user in loop
							
						// Note: requires PHP 5.3 for DateTime
						// gh#815
						$userStartDate = new DateTime($sessionRS->FetchNextObj()->startDate, new DateTimeZone(TIMEZONE));
						
						// we will ignore the first unit since that must have been run already
						for ($i=1; $i<$units; $i++) {
							$userStartDate->add(new DateInterval('P'.$unitsInterval.'D'));
							$today = new DateTime('now', new DateTimeZone(TIMEZONE));
							if ($userStartDate->format('Y-m-d') == $today->format('Y-m-d')) {
								
								// You already have the course xml, so just grab the nth unit node
								$unitXML = $courseXML->unit[$i];
								foreach ($unitXML[0]->attributes() as $key => $value) {
									if (strtolower($key) == 'caption') {
										// TODO. Will this correctly save each different $course for every email
										// or do we have pass by reference issues?
										$course->unitName = (string) $value;
										break;
									}
								}
									
								$toEmail = $user->email;
								$emailData = array("user" => $user, "course" => $course);
								$thisEmail = array("to" => $toEmail, "data" => $emailData);
								$emailArray[] = $thisEmail;
								break 1; // found the unit that starts today, so goto next user in loop
							}
						}
						
					}
				}
			}
		}
		return $emailArray;
	}

	// Utility to bring back users from the archive table
	function restoreArchivedTeachers($roots) {
			
		if (is_array($roots)) {
			$rootList = implode(',', $roots);
		} else if ($roots) {
			$rootList = $roots;
		} else {
			return -1;
		}
			
		$sql = <<<SQL
			SELECT * FROM T_User_Expiry u, T_Membership_Expiry m 
			WHERE u.F_UserID = m.F_UserID
			AND m.F_RootID in ($rootList)
			AND u.F_UserType > 0
SQL;
		$rs = $this->db->Execute($sql);
		
		// Loop round the array, inserting to * then deleting the related records for each userID from _Expiry
		if ($rs->RecordCount() > 0) {
			while ($dbObj = $rs->FetchNextObj()) {
						
				$this->db->StartTrans();
				
				$userID = $dbObj->F_UserID;
				$bindingParams = array($userID);
				
				$sql = <<<SQL
					INSERT INTO T_Membership
					SELECT * FROM T_Membership_Expiry 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM T_Membership_Expiry
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$sql = <<<SQL
					INSERT INTO T_User
					SELECT * FROM T_User_Expiry 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM T_User_Expiry
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$this->db->CompleteTrans();
			}
		}
		
		// send back the number of restored users
		return $rs->RecordCount();
		
	}

	/*
	 * For checking each account's CCB activity.
	 * Will count courses, units and exercises from xml directory trawling
	 * Will count student activity from database query
	 * Write summary record to db, which can be queried by a charting tool
	 */
	public function monitorCBBActivity($db) {

		// First get a list of all active CCB accounts
		$sql = <<<SQL
			SELECT ar.*, a.F_ContentLocation FROM T_AccountRoot ar, T_Accounts a 
			WHERE ar.F_RootID = a.F_RootID
			AND a.F_ProductCode = 54
			AND a.F_ExpiryDate >= NOW();
SQL;
		$rs = $this->db->Execute($sql);
		$accounts = 0;
		if ($rs->RecordCount() > 0) {
			while ($dbObj = $rs->FetchNextObj()) {
				
				$rootID = $dbObj->F_RootID;
				$prefix = $dbObj->F_Prefix;
				$accountName = $dbObj->F_Name;
				$contentLocation = $dbObj->F_ContentLocation;
				
				if (!isset($contentLocation)) {
					AbstractService::$debugLog->notice("Account $accountName ($rootID) has no content location");
					echo "Account $accountName ($rootID) has no content location";
					continue 1;
				}
					
				// Then for each account, open course.xml and count the nodes
				$courses = $units = $exercises = $sessions = 0;
				$this->courseOps->setAccountFolder(dirname(__FILE__).'/../'.$GLOBALS['ccb_data_dir'].'/'.$contentLocation);
				if (file_exists($this->courseOps->courseFilename)) {
					$courseXML = simplexml_load_file($this->courseOps->courseFilename);
				} else {
					AbstractService::$debugLog->notice("Account $accountName has no courses.xml");
					echo "Account $accountName has no courses.xml";
					continue 1;
				}
				$courseXML->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
				
				$courseNodes = $courseXML->xpath("//xmlns:course");
				foreach ($courseNodes as $course) {
					$courses++;
					if (isset($course['id'])) $courseID = (string) $course['id'];

					// For each course node, open the menu.xml in the folder and count the units/exercises
					$menuXML = $this->courseOps->getCourse($courseID);
					if (!$menuXML) {
						AbstractService::$debugLog->notice("Course $prefix.$courseID has no menu.xml");
						echo "Course $prefix.$courseID has no menu.xml";
						continue 1;
					}
					$menuXML->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
					
					$units += count($menuXML->xpath("//xmlns:unit"));
					$exercises += count($menuXML->xpath("//xmlns:exercise"));
				}
				
				// For each account, count the session records (just students) from database
				$sql = <<<SQL
					SELECT COUNT(1) as counter
					FROM T_Session s 
					WHERE s.F_RootID = ?
					AND s.F_ProductCode = 54
SQL;
				$bindingParams = array($rootID);
				$rs1 = $this->db->Execute($sql, $bindingParams);
				if ($rs1->RecordCount() > 0) {
					$dbObj1 = $rs1->FetchNextObj();
					$sessions = $dbObj1->counter;
				}
				
				// Create a summary record and write to the database if it is different from yesterday
				$sql = <<<SQL
					SELECT * FROM T_CCB_Activity
					WHERE F_RootID = ?
					ORDER BY F_DateStamp DESC
					LIMIT 0,1
SQL;
				$bindingParams = array($rootID);
				$rs2 = $this->db->Execute($sql, $bindingParams);
				if ($rs2->RecordCount() > 0) {
					$dbObj2 = $rs2->FetchNextObj();
					
				} else {
					// This might be the first record for this root
					$dbObj2 = null;
				}	
				
				if ($dbObj2 == null ||
					$dbObj2->F_Courses != $courses ||
					$dbObj2->F_Units != $units ||
					$dbObj2->F_Exercises != $exercises ||
					$dbObj2->F_Sessions != $sessions) {
			
					$sql = <<<SQL
						INSERT INTO T_CCB_Activity
						(F_RootID,F_DateStamp,F_Courses,F_Units,F_Exercises,F_Sessions)
						VALUES ($rootID, NOW(), $courses, $units, $exercises, $sessions)
SQL;
					$rc = $this->db->Execute($sql);
					$accounts++;
				}
			}
		}
		
		return $accounts;
	}

	/**
	 * For all users in a group (or groups), get the email addresses and include the user details.
	 * Would be more useful if you could include other information in the emailArray
	 * 
	 */
	public function getEmailsForGroup($groupIdArray, $templateDefinition=null, $recurseGroups = true) {

		// Initialise
		$emailArray = array();		
		$groups = array();

        if ($recurseGroups) {
            foreach ($groupIdArray as $groupId) {
                //AbstractService::$debugLog->info("get subgroups for $groupId");
                $groups = array_merge($groups, $this->manageableOps->getGroupSubgroups($groupId));
            }
            $groupList = implode(',', $groups);
        } else {
            $groupList = implode(',', $groupIdArray);
        }
		//AbstractService::$debugLog->info("end up asking for users in " . $groupList);
		
		$sql = <<<SQL
			SELECT u.*
			FROM T_User u, T_Membership m 
			WHERE u.F_UserID = m.F_UserID
			AND m.F_GroupID in ($groupList)
SQL;
		$bindingParams = array();
		$rs = $this->db->Execute($sql, $bindingParams);

		if ($rs->RecordCount() > 0) {
			$noEmailCount = 0;
			while ($dbObj = $rs->FetchNextObj()) {
				$user = new User();
				$user->fromDatabaseObj($dbObj);
				
				// Send email IF we have one
				if (isset($user->email) && $user->email) {
					$toEmail = $user->email;
					$emailData = array("user" => $user);
					
					// Based on the template, you might need to query the database for extra information
                    if (isset($templateDefinition)) {
                        switch ($templateDefinition->filename) {
                            case "user/PPT-with-result":
                                // We need to get the pre-saved test result for this user
                                $emailData['testResult'] = $this->memoryOps->get('CEF', 44, $user->id);
                                break;
                            default:
                        }

                        // gh#1487
                        if (!is_null($templateDefinition->data))
                            $emailData['templateData'] = $templateDefinition->data;
                    }

					$thisEmail = array("to" => $toEmail, "data" => $emailData);
					$emailArray[] = $thisEmail;
				} else {
					$noEmailCount++;
				}
			}
			//AbstractService::$debugLog->info("got $noEmailCount users with no email");
		}
		return $emailArray;
	}
	
	/**
	 * This will take an account and find the users in the account with a subscription
	 * A subscription is defined by startDate, frequency and valid
	 * Then it will work out if we need to update the bookmark for that user to reflect a new 'week'
	 * 
	 * Return an array of 'there is a new unit' emails to be sent
	 */
	public function updateSubscriptionBookmarks($account, $productCode, $timestamp = null) {

		// Initialize
		$emailArray = array();
		
		if (!$timestamp) { 
			$now = new DateTime(null, new DateTimeZone(TIMEZONE));
		} else {
			$now = new DateTime();
			$now->setTimestamp($timestamp);
		}
		$today = new DateTime($now->format('Y-m-d'. '00:00:00'));
			
		// Find all users in this account with a subscription to this product
		$users = $this->subscriptionOps->getSubscribedUsersInAccount($account, $productCode);
		
		foreach ($users as $user) {
			$subscription = $this->memoryOps->get('subscription', $productCode, $user->userID);
				
			if ($subscription['valid'] == 'true') {
				
				$level = $this->memoryOps->get('level', $productCode, $user->userID);
				$sd = $subscription['startDate'];
				$f = $subscription['frequency'];
				
				// Data checking
				if (empty($level) || empty($sd) || empty($f))
					continue;
					
				$startDate = new DateTime($sd.' 00:00:00');
				$frequency = DateInterval::createFromDateString($f);
				$keyDate = $startDate->add($frequency);
				
				// For testing we might pass in a different date to use as 'today'
				//$now = new DateTime(null, new DateTimeZone(TIMEZONE));
				//$today = new DateTime($now->format('Y-m-d'. '00:00:00'));
				$unitsAdded = 1;
				
				// TODO: Do we need a 'sensible' limit on number of units to add (in case start date was 1900 or something)
				while ($keyDate <= $today) {
					if ($keyDate == $today) {
						// Need to update the relevant bookmark
						$newBookmark = $this->subscriptionOps->getDirectStart($level, $unitsAdded, $productCode);
						
						// The subscription might have completed
						if (!$newBookmark) {
							$subscription['valid'] = 'false';
							$this->memoryOps->set('subscription', $subscription, $productCode, $user->userID);
						}
						
						// Need to update the Tense Buster bookmark
						$tbProductCode = $this->subscriptionOps->relatedProducts($productCode);
						$this->memoryOps->set('directStart', $newBookmark, $tbProductCode, $user->userID);
						
						$crypt = new Crypt();
						$programBase = 'http://'.$this->server.'/area1/TenseBuster/Start.php';
						$parameters = 'prefix='.$account->prefix.'&email='.$user->email.'&password='.$user->password.'&username='.$user->name;
                        $startProgram = "?data=".$crypt->encodeSafeChars($crypt->encrypt($parameters));
                        $parameters .= '&startingPoint=state:progress';
                        $startProgress = "?data=".$crypt->encodeSafeChars($crypt->encrypt($parameters));

						$toEmail = $user->email;
						$emailData = array("user" => $user, "level" => $level, "programBase" => $programBase, "startProgram" => $startProgram, "startProgress" => $startProgress, "dateDiff" => $f, "weekX" => $unitsAdded+1, "server" => $this->server, "prefix" => $account->prefix);
						$thisEmail = array("to" => $toEmail, "data" => $emailData);
						$emailArray[] = $thisEmail;
						AbstractService::$debugLog->info("update user ".$user->email." to week $unitsAdded");
						
						continue 2;
					}
					$unitsAdded++;
					$keyDate = $keyDate->add($frequency);
				}
			}
		}
		return $emailArray;
	}
	// gh#1166
	function averageCountryScores($productCodes, $fromDate=null, $toDate=null) {
		// For each product code do worldwide
		foreach ($productCodes as $productCode) {
			$sql = <<<SQL
				INSERT INTO T_ScoreCache (F_ProductCode, F_CourseID, F_UnitId, F_AverageScore, F_AverageDuration, F_Count, F_DateStamp, F_Country)
				SELECT F_ProductCode, F_CourseID, null, AVG(F_Score) as AverageScore, AVG(if(F_Duration>3600,3600,F_Duration)) as AverageDuration, COUNT(F_UserID) as Count, now(), 'Worldwide' 
				FROM T_Score
				WHERE F_ProductCode = ?
				AND F_Score>=0
SQL;
			$bindingParams = array($productCode);
			if ($fromDate) {
				$sql .= ' AND F_DateStamp >= ? ';
				$bindingParams[] = $fromDate;
			}
			if ($toDate) {
				$sql .= ' AND F_DateStamp <= ? ';
				$bindingParams[] = $toDate;
			}
			$sql .= ' GROUP BY F_CourseID ';
			
			//$rc = $this->db->Execute($sql, $bindingParams);
			AbstractService::$debugLog->notice("Added score cache for worldwide.");
		}
						
		// Then loop through each country that we know about (ignoring a list of known bad eggs)
		$sql = <<<SQL
			SELECT distinct(F_Country) 
			FROM T_User u, T_Membership m
			WHERE u.F_UserID = m.F_UserID
			AND m.F_RootID NOT IN (19278,14781,14252,13770,13577,12923)
			AND F_Country NOT IN ('undefined', '', '02', '01', 'global')
			GROUP BY F_Country
			ORDER BY F_Country asc;
SQL;
		$bindingParams = array();
		$rs = $this->db->Execute($sql, $bindingParams);
		if ($rs->RecordCount() > 0) {
			while ($dbObj = $rs->FetchNextObj()) {
					
				$country = $dbObj->F_Country;
				// For each product code do this country
				foreach ($productCodes as $productCode) {
					$sql = <<<SQL
						INSERT INTO T_ScoreCache (F_ProductCode, F_CourseID, F_UnitId, F_AverageScore, F_AverageDuration, F_Count, F_DateStamp, F_Country)
						SELECT F_ProductCode, s.F_CourseID, null, AVG(s.F_Score) as AverageScore, AVG(if(s.F_Duration>3600,3600,s.F_Duration)) as AverageDuration, COUNT(s.F_UserID) as Count, now(), F_Country 
						FROM T_Score s, T_User u
						WHERE s.F_ProductCode = ?
						AND s.F_Score>=0
						AND u.F_UserID = s.F_UserID
						AND u.F_Country = ?
SQL;
					$bindingParams = array($productCode, $country);
					if ($fromDate) {
						$sql .= ' AND F_DateStamp >= ? ';
						$bindingParams[] = $fromDate;
					}
					if ($toDate) {
						$sql .= ' AND F_DateStamp <= ? ';
						$bindingParams[] = $toDate;
					}
					$sql .= ' GROUP BY F_CourseID ';
					
					$rc = $this->db->Execute($sql, $bindingParams);
					AbstractService::$debugLog->notice("Added score cache for $country.");
				}
			}
		}
		if ($rc == false)
			return $this->db->ErrorMsg();
		return true; 		
	}

	// VUS special handling as hidden content not properly inherited

    /**
     * @return CourseOps
     */
    public function imposeHiddenContent($groupId) {
        // Check the group exists
        if (!$subGroups = $this->manageableOps->getGroup($groupId))
            return "no such group $groupId";

        // First get the subgroups of this group
        $subGroups = $this->manageableOps->getGroupSubgroups($groupId);
        foreach ($subGroups as $group) {
            // First delete existing hidden content for this group
            $sql = <<<SQL
                  delete from T_HiddenContent
                  where F_GroupID = ?
                  and F_ProductCode=52;
SQL;
            $bindingParams = array(intval($group));
            $rc = $this->db->Execute($sql, $bindingParams);
            
            // Find the pattern and do inserts
            $this->hiddenContentInsert($group, $groupId);
        }
        return implode(',', $subGroups);
    }
    private function hiddenContentInsert($group, $fixedGroup) {
        switch ($fixedGroup) {
            case 100477:
            case 21560:
                // Then insert fixed records for this fixed parent
                $sql = <<<SQL
                INSERT INTO `T_HiddenContent` (`F_HiddenContentUID`,`F_GroupID`,`F_ProductCode`,`F_CourseID`,`F_UnitID`,`F_ExerciseID`,`F_EnabledFlag`) 
                VALUES ('52',$group,52,NULL,NULL,NULL,0),
                ('52.1287130100000',$group,52,1287130100000,NULL,NULL,0),
                ('52.1287130100000.1287130120000.1287130120002',$group,52,1287130100000,1287130120000,1287130120002,8),
                ('52.1287130100000.1287130120000.1287130120003',$group,52,1287130100000,1287130120000,1287130120003,8),
                ('52.1287130100000.1287130120000.1287130120004',$group,52,1287130100000,1287130120000,1287130120004,8),
                ('52.1287130100000.1287130120000.1287130120005',$group,52,1287130100000,1287130120000,1287130120005,8),
                ('52.1287130100000.1287130120000.1287130120006',$group,52,1287130100000,1287130120000,1287130120006,8),
                ('52.1287130100000.1287130140000.1151344151277',$group,52,1287130100000,1287130140000,1151344151277,8),
                ('52.1287130100000.1287130140000.1151344151646',$group,52,1287130100000,1287130140000,1151344151646,8),
                ('52.1287130100000.1287130140000.1151344151840',$group,52,1287130100000,1287130140000,1151344151840,8),
                ('52.1287130100000.1287130140000.1151344172358',$group,52,1287130100000,1287130140000,1151344172358,8),
                ('52.1287130100000.1287130140000.1151344172524',$group,52,1287130100000,1287130140000,1151344172524,8),
                ('52.1287130100000.1287130140000.1151344172674',$group,52,1287130100000,1287130140000,1151344172674,8),
                ('52.1287130100000.1287130140000.1151344172814',$group,52,1287130100000,1287130140000,1151344172814,8),
                ('52.1287130100000.1287130140000.1151344194563',$group,52,1287130100000,1287130140000,1151344194563,8),
                ('52.1287130100000.1287130140000.1151344194690',$group,52,1287130100000,1287130140000,1151344194690,8),
                ('52.1287130100000.1287130140000.1151344194960',$group,52,1287130100000,1287130140000,1151344194960,8),
                ('52.1287130100000.1287130140000.1151344221051',$group,52,1287130100000,1287130140000,1151344221051,8),
                ('52.1287130100000.1287130140000.1151344221061',$group,52,1287130100000,1287130140000,1151344221061,8),
                ('52.1287130100000.1287130140000.1151344221063',$group,52,1287130100000,1287130140000,1151344221063,8),
                ('52.1287130100000.1287130140000.1151344221292',$group,52,1287130100000,1287130140000,1151344221292,8),
                ('52.1287130100000.1287130140000.1151344221541',$group,52,1287130100000,1287130140000,1151344221541,8),
                ('52.1287130100000.1287130140000.1151344221730',$group,52,1287130100000,1287130140000,1151344221730,8),
                ('52.1287130100000.1287130140000.1151344244509',$group,52,1287130100000,1287130140000,1151344244509,8),
                ('52.1287130100000.1287130140000.1151344244681',$group,52,1287130100000,1287130140000,1151344244681,8),
                ('52.1287130100000.1287130140000.1151344244784',$group,52,1287130100000,1287130140000,1151344244784,8),
                ('52.1287130100000.1287130140000.1151344244836',$group,52,1287130100000,1287130140000,1151344244836,8),
                ('52.1287130100000.1287130140000.1151344244888',$group,52,1287130100000,1287130140000,1151344244888,8),
                ('52.1287130100000.1287130140000.1151344259045',$group,52,1287130100000,1287130140000,1151344259045,8),
                ('52.1287130100000.1287130140000.1151344259264',$group,52,1287130100000,1287130140000,1151344259264,8),
                ('52.1287130100000.1287130140000.1151344259319',$group,52,1287130100000,1287130140000,1151344259319,8),
                ('52.1287130100000.1287130140000.1151344259704',$group,52,1287130100000,1287130140000,1151344259704,8),
                ('52.1287130100000.1287130140000.1151344259757',$group,52,1287130100000,1287130140000,1151344259757,8),
                ('52.1287130100000.1287130140000.1151344259839',$group,52,1287130100000,1287130140000,1151344259839,8),
                ('52.1287130100000.1287130140000.1151344537636',$group,52,1287130100000,1287130140000,1151344537636,8),
                ('52.1287130100000.1287130140000.1151344537791',$group,52,1287130100000,1287130140000,1151344537791,8),
                ('52.1287130100000.1287130140000.1154106132066',$group,52,1287130100000,1287130140000,1154106132066,8),
                ('52.1287130100000.1287130140000.1154541191072',$group,52,1287130100000,1287130140000,1154541191072,8),
                ('52.1287130200000',$group,52,1287130200000,NULL,NULL,0),
                ('52.1287130200000.1287130220000.1287130220002',$group,52,1287130200000,1287130220000,1287130220002,8),
                ('52.1287130200000.1287130220000.1287130220003',$group,52,1287130200000,1287130220000,1287130220003,8),
                ('52.1287130200000.1287130220000.1287130220004',$group,52,1287130200000,1287130220000,1287130220004,8),
                ('52.1287130200000.1287130220000.1287130220005',$group,52,1287130200000,1287130220000,1287130220005,8),
                ('52.1287130200000.1287130220000.1287130220006',$group,52,1287130200000,1287130220000,1287130220006,8),
                ('52.1287130200000.1287130240000.1151344151185',$group,52,1287130200000,1287130240000,1151344151185,8),
                ('52.1287130200000.1287130240000.1151344151990',$group,52,1287130200000,1287130240000,1151344151990,8),
                ('52.1287130200000.1287130240000.1151344172054',$group,52,1287130200000,1287130240000,1151344172054,8),
                ('52.1287130200000.1287130240000.1151344172601',$group,52,1287130200000,1287130240000,1151344172601,8),
                ('52.1287130200000.1287130240000.1151344172855',$group,52,1287130200000,1287130240000,1151344172855,8),
                ('52.1287130200000.1287130240000.1151344172963',$group,52,1287130200000,1287130240000,1151344172963,8),
                ('52.1287130200000.1287130240000.1151344194290',$group,52,1287130200000,1287130240000,1151344194290,8),
                ('52.1287130200000.1287130240000.1151344194562',$group,52,1287130200000,1287130240000,1151344194562,8),
                ('52.1287130200000.1287130240000.1151344194575',$group,52,1287130200000,1287130240000,1151344194575,8),
                ('52.1287130200000.1287130240000.1151344194748',$group,52,1287130200000,1287130240000,1151344194748,8),
                ('52.1287130200000.1287130240000.1151344221308',$group,52,1287130200000,1287130240000,1151344221308,8),
                ('52.1287130200000.1287130240000.1151344221365',$group,52,1287130200000,1287130240000,1151344221365,8),
                ('52.1287130200000.1287130240000.1151344221436',$group,52,1287130200000,1287130240000,1151344221436,8),
                ('52.1287130200000.1287130240000.1151344221548',$group,52,1287130200000,1287130240000,1151344221548,8),
                ('52.1287130200000.1287130240000.1151344221875',$group,52,1287130200000,1287130240000,1151344221875,8),
                ('52.1287130200000.1287130240000.1151344221888',$group,52,1287130200000,1287130240000,1151344221888,8),
                ('52.1287130200000.1287130240000.1151344244009',$group,52,1287130200000,1287130240000,1151344244009,8),
                ('52.1287130200000.1287130240000.1151344244026',$group,52,1287130200000,1287130240000,1151344244026,8),
                ('52.1287130200000.1287130240000.1151344244199',$group,52,1287130200000,1287130240000,1151344244199,8),
                ('52.1287130200000.1287130240000.1151344244398',$group,52,1287130200000,1287130240000,1151344244398,8),
                ('52.1287130200000.1287130240000.1151344244577',$group,52,1287130200000,1287130240000,1151344244577,8),
                ('52.1287130200000.1287130240000.1151344259234',$group,52,1287130200000,1287130240000,1151344259234,8),
                ('52.1287130200000.1287130240000.1151344259298',$group,52,1287130200000,1287130240000,1151344259298,8),
                ('52.1287130200000.1287130240000.1151344259533',$group,52,1287130200000,1287130240000,1151344259533,8),
                ('52.1287130200000.1287130240000.1151344259537',$group,52,1287130200000,1287130240000,1151344259537,8),
                ('52.1287130200000.1287130240000.1151344259715',$group,52,1287130200000,1287130240000,1151344259715,8),
                ('52.1287130200000.1287130240000.1151344259935',$group,52,1287130200000,1287130240000,1151344259935,8),
                ('52.1287130200000.1287130240000.1151344537619',$group,52,1287130200000,1287130240000,1151344537619,8),
                ('52.1287130200000.1287130240000.1151344537628',$group,52,1287130200000,1287130240000,1151344537628,8),
                ('52.1287130200000.1287130240000.1154102099587',$group,52,1287130200000,1287130240000,1154102099587,8),
                ('52.1287130200000.1287130240000.1154102879147',$group,52,1287130200000,1287130240000,1154102879147,8),
                ('52.1287130200000.1287130240000.1155523998171',$group,52,1287130200000,1287130240000,1155523998171,8),
                ('52.1287130200000.1287130240000.1156429192269',$group,52,1287130200000,1287130240000,1156429192269,8),
                ('52.1287130200000.1287130240000.1156957196702',$group,52,1287130200000,1287130240000,1156957196702,8),
                ('52.1287130300000',$group,52,1287130300000,NULL,NULL,0),
                ('52.1287130300000.1287130320000.1287130320002',$group,52,1287130300000,1287130320000,1287130320002,8),
                ('52.1287130300000.1287130320000.1287130320003',$group,52,1287130300000,1287130320000,1287130320003,8),
                ('52.1287130300000.1287130320000.1287130320004',$group,52,1287130300000,1287130320000,1287130320004,8),
                ('52.1287130300000.1287130320000.1287130320005',$group,52,1287130300000,1287130320000,1287130320005,8),
                ('52.1287130300000.1287130320000.1287130320006',$group,52,1287130300000,1287130320000,1287130320006,8),
                ('52.1287130300000.1287130340000.1151344151026',$group,52,1287130300000,1287130340000,1151344151026,8),
                ('52.1287130300000.1287130340000.1151344151182',$group,52,1287130300000,1287130340000,1151344151182,8),
                ('52.1287130300000.1287130340000.1151344151320',$group,52,1287130300000,1287130340000,1151344151320,8),
                ('52.1287130300000.1287130340000.1151344151339',$group,52,1287130300000,1287130340000,1151344151339,8),
                ('52.1287130300000.1287130340000.1151344151471',$group,52,1287130300000,1287130340000,1151344151471,8),
                ('52.1287130300000.1287130340000.1151344151544',$group,52,1287130300000,1287130340000,1151344151544,8),
                ('52.1287130300000.1287130340000.1151344151678',$group,52,1287130300000,1287130340000,1151344151678,8),
                ('52.1287130300000.1287130340000.1151344172352',$group,52,1287130300000,1287130340000,1151344172352,8),
                ('52.1287130300000.1287130340000.1151344172405',$group,52,1287130300000,1287130340000,1151344172405,8),
                ('52.1287130300000.1287130340000.1151344172525',$group,52,1287130300000,1287130340000,1151344172525,8),
                ('52.1287130300000.1287130340000.1151344172701',$group,52,1287130300000,1287130340000,1151344172701,8),
                ('52.1287130300000.1287130340000.1151344172836',$group,52,1287130300000,1287130340000,1151344172836,8),
                ('52.1287130300000.1287130340000.1151344172961',$group,52,1287130300000,1287130340000,1151344172961,8),
                ('52.1287130300000.1287130340000.1151344194030',$group,52,1287130300000,1287130340000,1151344194030,8),
                ('52.1287130300000.1287130340000.1151344194186',$group,52,1287130300000,1287130340000,1151344194186,8),
                ('52.1287130300000.1287130340000.1151344194188',$group,52,1287130300000,1287130340000,1151344194188,8),
                ('52.1287130300000.1287130340000.1151344194612',$group,52,1287130300000,1287130340000,1151344194612,8),
                ('52.1287130300000.1287130340000.1151344194769',$group,52,1287130300000,1287130340000,1151344194769,8),
                ('52.1287130300000.1287130340000.1151344194925',$group,52,1287130300000,1287130340000,1151344194925,8),
                ('52.1287130300000.1287130340000.1151344194991',$group,52,1287130300000,1287130340000,1151344194991,8),
                ('52.1287130300000.1287130340000.1151344221025',$group,52,1287130300000,1287130340000,1151344221025,8),
                ('52.1287130300000.1287130340000.1151344221331',$group,52,1287130300000,1287130340000,1151344221331,8),
                ('52.1287130300000.1287130340000.1151344221379',$group,52,1287130300000,1287130340000,1151344221379,8),
                ('52.1287130300000.1287130340000.1151344221535',$group,52,1287130300000,1287130340000,1151344221535,8),
                ('52.1287130300000.1287130340000.1151344221613',$group,52,1287130300000,1287130340000,1151344221613,8),
                ('52.1287130300000.1287130340000.1151344221617',$group,52,1287130300000,1287130340000,1151344221617,8),
                ('52.1287130300000.1287130340000.1151344221947',$group,52,1287130300000,1287130340000,1151344221947,8),
                ('52.1287130300000.1287130340000.1151344244225',$group,52,1287130300000,1287130340000,1151344244225,8),
                ('52.1287130300000.1287130340000.1151344244656',$group,52,1287130300000,1287130340000,1151344244656,8),
                ('52.1287130300000.1287130340000.1151344244813',$group,52,1287130300000,1287130340000,1151344244813,8),
                ('52.1287130300000.1287130340000.1151344244890',$group,52,1287130300000,1287130340000,1151344244890,8),
                ('52.1287130300000.1287130340000.1151344244971',$group,52,1287130300000,1287130340000,1151344244971,8),
                ('52.1287130300000.1287130340000.1151344259115',$group,52,1287130300000,1287130340000,1151344259115,8),
                ('52.1287130300000.1287130340000.1151344259499',$group,52,1287130300000,1287130340000,1151344259499,8),
                ('52.1287130300000.1287130340000.1151344259505',$group,52,1287130300000,1287130340000,1151344259505,8),
                ('52.1287130300000.1287130340000.1151344259681',$group,52,1287130300000,1287130340000,1151344259681,8),
                ('52.1287130300000.1287130340000.1151344259808',$group,52,1287130300000,1287130340000,1151344259808,8),
                ('52.1287130300000.1287130340000.1151344259849',$group,52,1287130300000,1287130340000,1151344259849,8),
                ('52.1287130300000.1287130340000.1151344259941',$group,52,1287130300000,1287130340000,1151344259941,8),
                ('52.1287130300000.1287130340000.1151344537189',$group,52,1287130300000,1287130340000,1151344537189,8),
                ('52.1287130300000.1287130340000.1151344537344',$group,52,1287130300000,1287130340000,1151344537344,8),
                ('52.1287130300000.1287130340000.1151344537369',$group,52,1287130300000,1287130340000,1151344537369,8),
                ('52.1287130300000.1287130340000.1151344537382',$group,52,1287130300000,1287130340000,1151344537382,8),
                ('52.1287130300000.1287130340000.1151344537448',$group,52,1287130300000,1287130340000,1151344537448,8),
                ('52.1287130300000.1287130340000.1151344537547',$group,52,1287130300000,1287130340000,1151344537547,8),
                ('52.1287130300000.1287130340000.1151344537741',$group,52,1287130300000,1287130340000,1151344537741,8),
                ('52.1287130300000.1287130340000.1151344537796',$group,52,1287130300000,1287130340000,1151344537796,8),
                ('52.1287130300000.1287130340000.1156429192024',$group,52,1287130300000,1287130340000,1156429192024,8),
                ('52.1287130300000.1287130340000.1156429192203',$group,52,1287130300000,1287130340000,1156429192203,8),
                ('52.1287130300000.1287130340000.1156429192246',$group,52,1287130300000,1287130340000,1156429192246,8),
                ('52.1287130300000.1287130340000.1156429192404',$group,52,1287130300000,1287130340000,1156429192404,8),
                ('52.1287130300000.1287130340000.1156429192443',$group,52,1287130300000,1287130340000,1156429192443,8),
                ('52.1287130300000.1287130340000.1156429192483',$group,52,1287130300000,1287130340000,1156429192483,8),
                ('52.1287130300000.1287130340000.1156429192635',$group,52,1287130300000,1287130340000,1156429192635,8),
                ('52.1287130300000.1287130340000.1156429192673',$group,52,1287130300000,1287130340000,1156429192673,8),
                ('52.1287130300000.1287130340000.1156429192754',$group,52,1287130300000,1287130340000,1156429192754,8),
                ('52.1287130300000.1287130340000.1156429192930',$group,52,1287130300000,1287130340000,1156429192930,8),
                ('52.1287130300000.1287130340000.1156429192940',$group,52,1287130300000,1287130340000,1156429192940,8),
                ('52.1287130400000',$group,52,1287130400000,NULL,NULL,0),
                ('52.1287130400000.1287130420000.1287130420002',$group,52,1287130400000,1287130420000,1287130420002,8),
                ('52.1287130400000.1287130420000.1287130420003',$group,52,1287130400000,1287130420000,1287130420003,8),
                ('52.1287130400000.1287130420000.1287130420004',$group,52,1287130400000,1287130420000,1287130420004,8),
                ('52.1287130400000.1287130420000.1287130420005',$group,52,1287130400000,1287130420000,1287130420005,8),
                ('52.1287130400000.1287130420000.1287130420006',$group,52,1287130400000,1287130420000,1287130420006,8),
                ('52.1287130400000.1287130440000.1151344151113',$group,52,1287130400000,1287130440000,1151344151113,8),
                ('52.1287130400000.1287130440000.1151344151225',$group,52,1287130400000,1287130440000,1151344151225,8),
                ('52.1287130400000.1287130440000.1151344151248',$group,52,1287130400000,1287130440000,1151344151248,8),
                ('52.1287130400000.1287130440000.1151344151338',$group,52,1287130400000,1287130440000,1151344151338,8),
                ('52.1287130400000.1287130440000.1151344151459',$group,52,1287130400000,1287130440000,1151344151459,8),
                ('52.1287130400000.1287130440000.1151344151514',$group,52,1287130400000,1287130440000,1151344151514,8),
                ('52.1287130400000.1287130440000.1151344151535',$group,52,1287130400000,1287130440000,1151344151535,8),
                ('52.1287130400000.1287130440000.1151344151542',$group,52,1287130400000,1287130440000,1151344151542,8),
                ('52.1287130400000.1287130440000.1151344151811',$group,52,1287130400000,1287130440000,1151344151811,8),
                ('52.1287130400000.1287130440000.1151344151845',$group,52,1287130400000,1287130440000,1151344151845,8),
                ('52.1287130400000.1287130440000.1151344151879',$group,52,1287130400000,1287130440000,1151344151879,8),
                ('52.1287130400000.1287130440000.1151344151900',$group,52,1287130400000,1287130440000,1151344151900,8),
                ('52.1287130400000.1287130440000.1151344151924',$group,52,1287130400000,1287130440000,1151344151924,8),
                ('52.1287130400000.1287130440000.1151344151941',$group,52,1287130400000,1287130440000,1151344151941,8),
                ('52.1287130400000.1287130440000.1151344151960',$group,52,1287130400000,1287130440000,1151344151960,8),
                ('52.1287130400000.1287130440000.1151344151961',$group,52,1287130400000,1287130440000,1151344151961,8),
                ('52.1287130400000.1287130440000.1151344151962',$group,52,1287130400000,1287130440000,1151344151962,8),
                ('52.1287130400000.1287130440000.1151344151963',$group,52,1287130400000,1287130440000,1151344151963,8),
                ('52.1287130400000.1287130440000.1151344151964',$group,52,1287130400000,1287130440000,1151344151964,8),
                ('52.1287130400000.1287130440000.1151344172016',$group,52,1287130400000,1287130440000,1151344172016,8),
                ('52.1287130400000.1287130440000.1151344172094',$group,52,1287130400000,1287130440000,1151344172094,8),
                ('52.1287130400000.1287130440000.1151344172370',$group,52,1287130400000,1287130440000,1151344172370,8),
                ('52.1287130400000.1287130440000.1151344172381',$group,52,1287130400000,1287130440000,1151344172381,8),
                ('52.1287130400000.1287130440000.1151344172453',$group,52,1287130400000,1287130440000,1151344172453,8),
                ('52.1287130400000.1287130440000.1151344172565',$group,52,1287130400000,1287130440000,1151344172565,8),
                ('52.1287130400000.1287130440000.1151344172623',$group,52,1287130400000,1287130440000,1151344172623,8),
                ('52.1287130400000.1287130440000.1151344172669',$group,52,1287130400000,1287130440000,1151344172669,8),
                ('52.1287130400000.1287130440000.1151344172726',$group,52,1287130400000,1287130440000,1151344172726,8),
                ('52.1287130400000.1287130440000.1151344172813',$group,52,1287130400000,1287130440000,1151344172813,8),
                ('52.1287130400000.1287130440000.1151344172816',$group,52,1287130400000,1287130440000,1151344172816,8),
                ('52.1287130400000.1287130440000.1151344172861',$group,52,1287130400000,1287130440000,1151344172861,8),
                ('52.1287130400000.1287130440000.1151344172864',$group,52,1287130400000,1287130440000,1151344172864,8),
                ('52.1287130400000.1287130440000.1151344172878',$group,52,1287130400000,1287130440000,1151344172878,8),
                ('52.1287130400000.1287130440000.1151344172927',$group,52,1287130400000,1287130440000,1151344172927,8),
                ('52.1287130400000.1287130440000.1151344172979',$group,52,1287130400000,1287130440000,1151344172979,8),
                ('52.1287130400000.1287130440000.1151344194088',$group,52,1287130400000,1287130440000,1151344194088,8),
                ('52.1287130400000.1287130440000.1151344194091',$group,52,1287130400000,1287130440000,1151344194091,8),
                ('52.1287130400000.1287130440000.1151344194254',$group,52,1287130400000,1287130440000,1151344194254,8),
                ('52.1287130400000.1287130440000.1151344194293',$group,52,1287130400000,1287130440000,1151344194293,8),
                ('52.1287130400000.1287130440000.1151344194348',$group,52,1287130400000,1287130440000,1151344194348,8),
                ('52.1287130400000.1287130440000.1151344194371',$group,52,1287130400000,1287130440000,1151344194371,8),
                ('52.1287130400000.1287130440000.1151344194379',$group,52,1287130400000,1287130440000,1151344194379,8),
                ('52.1287130400000.1287130440000.1151344194394',$group,52,1287130400000,1287130440000,1151344194394,8),
                ('52.1287130400000.1287130440000.1151344194477',$group,52,1287130400000,1287130440000,1151344194477,8),
                ('52.1287130400000.1287130440000.1151344194483',$group,52,1287130400000,1287130440000,1151344194483,8),
                ('52.1287130400000.1287130440000.1151344194544',$group,52,1287130400000,1287130440000,1151344194544,8),
                ('52.1287130400000.1287130440000.1151344194607',$group,52,1287130400000,1287130440000,1151344194607,8),
                ('52.1287130400000.1287130440000.1151344194903',$group,52,1287130400000,1287130440000,1151344194903,8),
                ('52.1287130400000.1287130440000.1151344221080',$group,52,1287130400000,1287130440000,1151344221080,8),
                ('52.1287130400000.1287130440000.1151344221257',$group,52,1287130400000,1287130440000,1151344221257,8),
                ('52.1287130400000.1287130440000.1151344221269',$group,52,1287130400000,1287130440000,1151344221269,8),
                ('52.1287130400000.1287130440000.1151344221398',$group,52,1287130400000,1287130440000,1151344221398,8),
                ('52.1287130400000.1287130440000.1151344244171',$group,52,1287130400000,1287130440000,1151344244171,8),
                ('52.1287130400000.1287130440000.1151344244226',$group,52,1287130400000,1287130440000,1151344244226,8),
                ('52.1287130400000.1287130440000.1151344244286',$group,52,1287130400000,1287130440000,1151344244286,8),
                ('52.1287130400000.1287130440000.1151344244519',$group,52,1287130400000,1287130440000,1151344244519,8),
                ('52.1287130400000.1287130440000.1151344244619',$group,52,1287130400000,1287130440000,1151344244619,8),
                ('52.1287130400000.1287130440000.1151344259097',$group,52,1287130400000,1287130440000,1151344259097,8),
                ('52.1287130400000.1287130440000.1151344259304',$group,52,1287130400000,1287130440000,1151344259304,8),
                ('52.1287130400000.1287130440000.1151344259472',$group,52,1287130400000,1287130440000,1151344259472,8),
                ('52.1287130400000.1287130440000.1151344259490',$group,52,1287130400000,1287130440000,1151344259490,8),
                ('52.1287130400000.1287130440000.1151344259606',$group,52,1287130400000,1287130440000,1151344259606,8),
                ('52.1287130400000.1287130440000.1151344537016',$group,52,1287130400000,1287130440000,1151344537016,8),
                ('52.1287130400000.1287130440000.1151344537183',$group,52,1287130400000,1287130440000,1151344537183,8),
                ('52.1287130400000.1287130440000.1151344537286',$group,52,1287130400000,1287130440000,1151344537286,8),
                ('52.1287130400000.1287130440000.1151344537330',$group,52,1287130400000,1287130440000,1151344537330,8),
                ('52.1287130400000.1287130440000.1151344537377',$group,52,1287130400000,1287130440000,1151344537377,8),
                ('52.1287130400000.1287130440000.1151344537422',$group,52,1287130400000,1287130440000,1151344537422,8),
                ('52.1287130400000.1287130440000.1151344537449',$group,52,1287130400000,1287130440000,1151344537449,8),
                ('52.1287130400000.1287130440000.1151344537542',$group,52,1287130400000,1287130440000,1151344537542,8),
                ('52.1287130400000.1287130440000.1151344537567',$group,52,1287130400000,1287130440000,1151344537567,8),
                ('52.1287130400000.1287130440000.1151344537805',$group,52,1287130400000,1287130440000,1151344537805,8),
                ('52.1287130400000.1287130440000.1151344537821',$group,52,1287130400000,1287130440000,1151344537821,8),
                ('52.1287130400000.1287130440000.1151344537840',$group,52,1287130400000,1287130440000,1151344537840,8),
                ('52.1287130400000.1287130440000.1151344537842',$group,52,1287130400000,1287130440000,1151344537842,8),
                ('52.1287130400000.1287130440000.1151344537899',$group,52,1287130400000,1287130440000,1151344537899,8),
                ('52.1287130400000.1287130440000.1153925866014',$group,52,1287130400000,1287130440000,1153925866014,8),
                ('52.1287130400000.1287130440000.1153929967942',$group,52,1287130400000,1287130440000,1153929967942,8),
                ('52.1287130400000.1287130440000.1154106427713',$group,52,1287130400000,1287130440000,1154106427713,8),
                ('52.1287130400000.1287130440000.1154110371956',$group,52,1287130400000,1287130440000,1154110371956,8),
                ('52.1287130400000.1287130440000.1154542110626',$group,52,1287130400000,1287130440000,1154542110626,8),
                ('52.1287130400000.1287130440000.1154682996234',$group,52,1287130400000,1287130440000,1154682996234,8),
                ('52.1287130400000.1287130440000.1154683176375',$group,52,1287130400000,1287130440000,1154683176375,8),
                ('52.1287130400000.1287130440000.1154683256265',$group,52,1287130400000,1287130440000,1154683256265,8),
                ('52.1287130400000.1287130440000.1154684731484',$group,52,1287130400000,1287130440000,1154684731484,8),
                ('52.1287130400000.1287130440000.1154684988203',$group,52,1287130400000,1287130440000,1154684988203,8),
                ('52.1287130400000.1287130440000.1154685020187',$group,52,1287130400000,1287130440000,1154685020187,8),
                ('52.1287130400000.1287130440000.1155192197437',$group,52,1287130400000,1287130440000,1155192197437,8),
                ('52.1287130400000.1287130440000.1156429192104',$group,52,1287130400000,1287130440000,1156429192104,8),
                ('52.1287130400000.1287130440000.1156429192118',$group,52,1287130400000,1287130440000,1156429192118,8),
                ('52.1287130400000.1287130440000.1156429192163',$group,52,1287130400000,1287130440000,1156429192163,8),
                ('52.1287130400000.1287130440000.1156429192176',$group,52,1287130400000,1287130440000,1156429192176,8),
                ('52.1287130400000.1287130440000.1156429192196',$group,52,1287130400000,1287130440000,1156429192196,8),
                ('52.1287130400000.1287130440000.1156429192216',$group,52,1287130400000,1287130440000,1156429192216,8),
                ('52.1287130400000.1287130440000.1156429192335',$group,52,1287130400000,1287130440000,1156429192335,8),
                ('52.1287130400000.1287130440000.1156429192338',$group,52,1287130400000,1287130440000,1156429192338,8),
                ('52.1287130400000.1287130440000.1156429192415',$group,52,1287130400000,1287130440000,1156429192415,8),
                ('52.1287130400000.1287130440000.1156429192459',$group,52,1287130400000,1287130440000,1156429192459,8),
                ('52.1287130400000.1287130440000.1156429192481',$group,52,1287130400000,1287130440000,1156429192481,8),
                ('52.1287130400000.1287130440000.1156429192508',$group,52,1287130400000,1287130440000,1156429192508,8),
                ('52.1287130400000.1287130440000.1156429192509',$group,52,1287130400000,1287130440000,1156429192509,8),
                ('52.1287130400000.1287130440000.1156429192625',$group,52,1287130400000,1287130440000,1156429192625,8),
                ('52.1287130400000.1287130440000.1156429192941',$group,52,1287130400000,1287130440000,1156429192941,8),
                ('52.1287130400000.1287130440000.1156429192961',$group,52,1287130400000,1287130440000,1156429192961,8),
                ('52.1287130400000.1287130440000.1156429192994',$group,52,1287130400000,1287130440000,1156429192994,8),
                ('52.1287130400000.1287130440000.1156434321968',$group,52,1287130400000,1287130440000,1156434321968,8),
                ('52.1287130400000.1287130440000.1157616602346',$group,52,1287130400000,1287130440000,1157616602346,8),
                ('52.1287130400000.1287130440000.1157642353997',$group,52,1287130400000,1287130440000,1157642353997,8),
                ('52.1287130400000.1287130440000.1157642557387',$group,52,1287130400000,1287130440000,1157642557387,8),
                ('52.1287130400000.1287130440000.1157642719760',$group,52,1287130400000,1287130440000,1157642719760,8),
                ('52.1287130400000.1287130440000.1157642854079',$group,52,1287130400000,1287130440000,1157642854079,8),
                ('52.1287130400000.1287130440000.1157643012959',$group,52,1287130400000,1287130440000,1157643012959,8),
                ('52.1287130400000.1287130440000.1157699050609',$group,52,1287130400000,1287130440000,1157699050609,8);
SQL;
                $bindingParams = array();
                $rc = $this->db->Execute($sql, $bindingParams);
                break;
            case 100430:
                // Then insert fixed records for this fixed parent
                $sql = <<<SQL
                    INSERT INTO `T_HiddenContent` (`F_HiddenContentUID`,`F_GroupID`,`F_ProductCode`,`F_CourseID`,`F_UnitID`,`F_ExerciseID`,`F_EnabledFlag`) 
                    VALUES ('52',$group,52,NULL,NULL,NULL,0),
                    ('52.1287130100000.1287130120000.1287130120004',$group,52,1287130100000,1287130120000,1287130120004,8),
                    ('52.1287130100000.1287130120000.1287130120005',$group,52,1287130100000,1287130120000,1287130120005,8),
                    ('52.1287130100000.1287130120000.1287130120006',$group,52,1287130100000,1287130120000,1287130120006,8),
                    ('52.1287130100000.1287130140000.1151344221051',$group,52,1287130100000,1287130140000,1151344221051,8),
                    ('52.1287130100000.1287130140000.1151344221061',$group,52,1287130100000,1287130140000,1151344221061,8),
                    ('52.1287130100000.1287130140000.1151344221063',$group,52,1287130100000,1287130140000,1151344221063,8),
                    ('52.1287130100000.1287130140000.1151344221292',$group,52,1287130100000,1287130140000,1151344221292,8),
                    ('52.1287130100000.1287130140000.1151344221541',$group,52,1287130100000,1287130140000,1151344221541,8),
                    ('52.1287130100000.1287130140000.1151344221730',$group,52,1287130100000,1287130140000,1151344221730,8),
                    ('52.1287130100000.1287130140000.1151344244509',$group,52,1287130100000,1287130140000,1151344244509,8),
                    ('52.1287130100000.1287130140000.1151344244681',$group,52,1287130100000,1287130140000,1151344244681,8),
                    ('52.1287130100000.1287130140000.1151344244784',$group,52,1287130100000,1287130140000,1151344244784,8),
                    ('52.1287130100000.1287130140000.1151344244836',$group,52,1287130100000,1287130140000,1151344244836,8),
                    ('52.1287130100000.1287130140000.1151344244888',$group,52,1287130100000,1287130140000,1151344244888,8),
                    ('52.1287130100000.1287130140000.1151344259045',$group,52,1287130100000,1287130140000,1151344259045,8),
                    ('52.1287130100000.1287130140000.1151344259264',$group,52,1287130100000,1287130140000,1151344259264,8),
                    ('52.1287130100000.1287130140000.1151344259319',$group,52,1287130100000,1287130140000,1151344259319,8),
                    ('52.1287130100000.1287130140000.1151344259704',$group,52,1287130100000,1287130140000,1151344259704,8),
                    ('52.1287130100000.1287130140000.1151344259757',$group,52,1287130100000,1287130140000,1151344259757,8),
                    ('52.1287130100000.1287130140000.1151344259839',$group,52,1287130100000,1287130140000,1151344259839,8),
                    ('52.1287130200000.1287130220000.1287130220004',$group,52,1287130200000,1287130220000,1287130220004,8),
                    ('52.1287130200000.1287130220000.1287130220005',$group,52,1287130200000,1287130220000,1287130220005,8),
                    ('52.1287130200000.1287130220000.1287130220006',$group,52,1287130200000,1287130220000,1287130220006,8),
                    ('52.1287130200000.1287130240000.1151344194290',$group,52,1287130200000,1287130240000,1151344194290,8),
                    ('52.1287130200000.1287130240000.1151344194562',$group,52,1287130200000,1287130240000,1151344194562,8),
                    ('52.1287130200000.1287130240000.1151344194575',$group,52,1287130200000,1287130240000,1151344194575,8),
                    ('52.1287130200000.1287130240000.1151344194748',$group,52,1287130200000,1287130240000,1151344194748,8),
                    ('52.1287130200000.1287130240000.1151344221308',$group,52,1287130200000,1287130240000,1151344221308,8),
                    ('52.1287130200000.1287130240000.1151344221365',$group,52,1287130200000,1287130240000,1151344221365,8),
                    ('52.1287130200000.1287130240000.1151344221436',$group,52,1287130200000,1287130240000,1151344221436,8),
                    ('52.1287130200000.1287130240000.1151344221548',$group,52,1287130200000,1287130240000,1151344221548,8),
                    ('52.1287130200000.1287130240000.1151344221875',$group,52,1287130200000,1287130240000,1151344221875,8),
                    ('52.1287130200000.1287130240000.1151344221888',$group,52,1287130200000,1287130240000,1151344221888,8),
                    ('52.1287130200000.1287130240000.1151344244009',$group,52,1287130200000,1287130240000,1151344244009,8),
                    ('52.1287130200000.1287130240000.1151344244026',$group,52,1287130200000,1287130240000,1151344244026,8),
                    ('52.1287130200000.1287130240000.1151344244199',$group,52,1287130200000,1287130240000,1151344244199,8),
                    ('52.1287130200000.1287130240000.1151344244398',$group,52,1287130200000,1287130240000,1151344244398,8),
                    ('52.1287130200000.1287130240000.1151344244577',$group,52,1287130200000,1287130240000,1151344244577,8),
                    ('52.1287130200000.1287130240000.1151344259234',$group,52,1287130200000,1287130240000,1151344259234,8),
                    ('52.1287130200000.1287130240000.1151344259298',$group,52,1287130200000,1287130240000,1151344259298,8),
                    ('52.1287130200000.1287130240000.1151344259533',$group,52,1287130200000,1287130240000,1151344259533,8),
                    ('52.1287130200000.1287130240000.1151344259537',$group,52,1287130200000,1287130240000,1151344259537,8),
                    ('52.1287130200000.1287130240000.1151344259715',$group,52,1287130200000,1287130240000,1151344259715,8),
                    ('52.1287130200000.1287130240000.1151344259935',$group,52,1287130200000,1287130240000,1151344259935,8),
                    ('52.1287130200000.1287130240000.1155523998171',$group,52,1287130200000,1287130240000,1155523998171,8),
                    ('52.1287130300000.1287130320000.1287130320004',$group,52,1287130300000,1287130320000,1287130320004,8),
                    ('52.1287130300000.1287130320000.1287130320005',$group,52,1287130300000,1287130320000,1287130320005,8),
                    ('52.1287130300000.1287130320000.1287130320006',$group,52,1287130300000,1287130320000,1287130320006,8),
                    ('52.1287130300000.1287130340000.1151344194030',$group,52,1287130300000,1287130340000,1151344194030,8),
                    ('52.1287130300000.1287130340000.1151344194186',$group,52,1287130300000,1287130340000,1151344194186,8),
                    ('52.1287130300000.1287130340000.1151344194188',$group,52,1287130300000,1287130340000,1151344194188,8),
                    ('52.1287130300000.1287130340000.1151344194612',$group,52,1287130300000,1287130340000,1151344194612,8),
                    ('52.1287130300000.1287130340000.1151344194769',$group,52,1287130300000,1287130340000,1151344194769,8),
                    ('52.1287130300000.1287130340000.1151344194925',$group,52,1287130300000,1287130340000,1151344194925,8),
                    ('52.1287130300000.1287130340000.1151344194991',$group,52,1287130300000,1287130340000,1151344194991,8),
                    ('52.1287130300000.1287130340000.1151344221025',$group,52,1287130300000,1287130340000,1151344221025,8),
                    ('52.1287130300000.1287130340000.1151344221331',$group,52,1287130300000,1287130340000,1151344221331,8),
                    ('52.1287130300000.1287130340000.1151344221379',$group,52,1287130300000,1287130340000,1151344221379,8),
                    ('52.1287130300000.1287130340000.1151344221535',$group,52,1287130300000,1287130340000,1151344221535,8),
                    ('52.1287130300000.1287130340000.1151344221613',$group,52,1287130300000,1287130340000,1151344221613,8),
                    ('52.1287130300000.1287130340000.1151344221617',$group,52,1287130300000,1287130340000,1151344221617,8),
                    ('52.1287130300000.1287130340000.1151344221947',$group,52,1287130300000,1287130340000,1151344221947,8),
                    ('52.1287130300000.1287130340000.1151344244225',$group,52,1287130300000,1287130340000,1151344244225,8),
                    ('52.1287130300000.1287130340000.1151344244656',$group,52,1287130300000,1287130340000,1151344244656,8),
                    ('52.1287130300000.1287130340000.1151344244813',$group,52,1287130300000,1287130340000,1151344244813,8),
                    ('52.1287130300000.1287130340000.1151344244890',$group,52,1287130300000,1287130340000,1151344244890,8),
                    ('52.1287130300000.1287130340000.1151344244971',$group,52,1287130300000,1287130340000,1151344244971,8),
                    ('52.1287130300000.1287130340000.1151344259115',$group,52,1287130300000,1287130340000,1151344259115,8),
                    ('52.1287130300000.1287130340000.1151344259499',$group,52,1287130300000,1287130340000,1151344259499,8),
                    ('52.1287130300000.1287130340000.1151344259505',$group,52,1287130300000,1287130340000,1151344259505,8),
                    ('52.1287130300000.1287130340000.1151344259681',$group,52,1287130300000,1287130340000,1151344259681,8),
                    ('52.1287130300000.1287130340000.1151344259808',$group,52,1287130300000,1287130340000,1151344259808,8),
                    ('52.1287130300000.1287130340000.1151344259849',$group,52,1287130300000,1287130340000,1151344259849,8),
                    ('52.1287130300000.1287130340000.1151344259941',$group,52,1287130300000,1287130340000,1151344259941,8),
                    ('52.1287130400000.1287130420000.1287130420004',$group,52,1287130400000,1287130420000,1287130420004,8),
                    ('52.1287130400000.1287130420000.1287130420005',$group,52,1287130400000,1287130420000,1287130420005,8),
                    ('52.1287130400000.1287130420000.1287130420006',$group,52,1287130400000,1287130420000,1287130420006,8),
                    ('52.1287130400000.1287130440000.1151344194088',$group,52,1287130400000,1287130440000,1151344194088,8),
                    ('52.1287130400000.1287130440000.1151344194091',$group,52,1287130400000,1287130440000,1151344194091,8),
                    ('52.1287130400000.1287130440000.1151344194254',$group,52,1287130400000,1287130440000,1151344194254,8),
                    ('52.1287130400000.1287130440000.1151344194293',$group,52,1287130400000,1287130440000,1151344194293,8),
                    ('52.1287130400000.1287130440000.1151344194348',$group,52,1287130400000,1287130440000,1151344194348,8),
                    ('52.1287130400000.1287130440000.1151344194371',$group,52,1287130400000,1287130440000,1151344194371,8),
                    ('52.1287130400000.1287130440000.1151344194379',$group,52,1287130400000,1287130440000,1151344194379,8),
                    ('52.1287130400000.1287130440000.1151344194394',$group,52,1287130400000,1287130440000,1151344194394,8),
                    ('52.1287130400000.1287130440000.1151344194477',$group,52,1287130400000,1287130440000,1151344194477,8),
                    ('52.1287130400000.1287130440000.1151344194483',$group,52,1287130400000,1287130440000,1151344194483,8),
                    ('52.1287130400000.1287130440000.1151344194544',$group,52,1287130400000,1287130440000,1151344194544,8),
                    ('52.1287130400000.1287130440000.1151344194607',$group,52,1287130400000,1287130440000,1151344194607,8),
                    ('52.1287130400000.1287130440000.1151344194903',$group,52,1287130400000,1287130440000,1151344194903,8),
                    ('52.1287130400000.1287130440000.1151344221080',$group,52,1287130400000,1287130440000,1151344221080,8),
                    ('52.1287130400000.1287130440000.1151344221257',$group,52,1287130400000,1287130440000,1151344221257,8),
                    ('52.1287130400000.1287130440000.1151344221269',$group,52,1287130400000,1287130440000,1151344221269,8),
                    ('52.1287130400000.1287130440000.1151344221398',$group,52,1287130400000,1287130440000,1151344221398,8),
                    ('52.1287130400000.1287130440000.1151344244171',$group,52,1287130400000,1287130440000,1151344244171,8),
                    ('52.1287130400000.1287130440000.1151344244226',$group,52,1287130400000,1287130440000,1151344244226,8),
                    ('52.1287130400000.1287130440000.1151344244286',$group,52,1287130400000,1287130440000,1151344244286,8),
                    ('52.1287130400000.1287130440000.1151344244519',$group,52,1287130400000,1287130440000,1151344244519,8),
                    ('52.1287130400000.1287130440000.1151344244619',$group,52,1287130400000,1287130440000,1151344244619,8),
                    ('52.1287130400000.1287130440000.1151344259097',$group,52,1287130400000,1287130440000,1151344259097,8),
                    ('52.1287130400000.1287130440000.1151344259304',$group,52,1287130400000,1287130440000,1151344259304,8),
                    ('52.1287130400000.1287130440000.1151344259472',$group,52,1287130400000,1287130440000,1151344259472,8),
                    ('52.1287130400000.1287130440000.1151344259490',$group,52,1287130400000,1287130440000,1151344259490,8),
                    ('52.1287130400000.1287130440000.1151344259606',$group,52,1287130400000,1287130440000,1151344259606,8),
                    ('52.1287130400000.1287130440000.1154542110626',$group,52,1287130400000,1287130440000,1154542110626,8),
                    ('52.1287130400000.1287130440000.1154684731484',$group,52,1287130400000,1287130440000,1154684731484,8),
                    ('52.1287130400000.1287130440000.1154684988203',$group,52,1287130400000,1287130440000,1154684988203,8),
                    ('52.1287130400000.1287130440000.1154685020187',$group,52,1287130400000,1287130440000,1154685020187,8),
                    ('52.1287130400000.1287130440000.1157616602346',$group,52,1287130400000,1287130440000,1157616602346,8),
                    ('52.1287130400000.1287130440000.1157642353997',$group,52,1287130400000,1287130440000,1157642353997,8),
                    ('52.1287130400000.1287130440000.1157642557387',$group,52,1287130400000,1287130440000,1157642557387,8),
                    ('52.1287130400000.1287130440000.1157642719760',$group,52,1287130400000,1287130440000,1157642719760,8),
                    ('52.1287130400000.1287130440000.1157642854079',$group,52,1287130400000,1287130440000,1157642854079,8),
                    ('52.1287130400000.1287130440000.1157643012959',$group,52,1287130400000,1287130440000,1157643012959,8),
                    ('52.1287130400000.1287130440000.1157699050609',$group,52,1287130400000,1287130440000,1157699050609,8);
SQL;
                $bindingParams = array();
                $rc = $this->db->Execute($sql, $bindingParams);
                break;
            case 100431:
                // Then insert fixed records for this fixed parent
                $sql = <<<SQL
                    INSERT INTO `T_HiddenContent` (`F_HiddenContentUID`,`F_GroupID`,`F_ProductCode`,`F_CourseID`,`F_UnitID`,`F_ExerciseID`,`F_EnabledFlag`) 
                    VALUES ('52',$group,52,NULL,NULL,NULL,0);
SQL;
            $bindingParams = array();
            $rc = $this->db->Execute($sql, $bindingParams);
            break;
            default:
        }
    }
}
