<?php
require_once($GLOBALS['common_dir'].'/encryptURL.php');

class DailyJobObs {
	
	var $db;
	var $server;
	
	function DailyJobObs($db = null) {
		// gh#1137 This doesn't work from a cronjob
		$this->server = (isset($_SERVER['HTTP_HOST'])) ? $_SERVER['HTTP_HOST'] : 'www.clarityenglish.com';
		$this->db = $db;
		$this->manageableOps = new ManageableOps($this->db);
		$this->courseOps = new CourseOps($this->db);
		$this->subscriptionOps = new SubscriptionOps($this->db);
		$this->memoryOps = new MemoryOps($this->db);
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
						
						$parameters = 'prefix='.$account->prefix.'&email='.$user->email.'&password='.$user->password.'&username='.$user->name;
						$crypt = new Crypt();
						$argList = "?data=".$crypt->encodeSafeChars($crypt->encrypt($parameters));
						$startProgram = 'http://'.$this->server.'/area1/TenseBuster10/Start.php'.$argList;
						
						$toEmail = $user->email;
						$emailData = array("user" => $user, "level" => $level, "programLink" => $startProgram, "dateDiff" => $f, "weekX" => $unitsAdded+1, "server" => $this->server);
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
	
}
