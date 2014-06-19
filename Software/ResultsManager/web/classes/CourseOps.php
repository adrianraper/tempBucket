<?php
require_once(dirname(__FILE__)."/xml/XmlUtils.php");
require_once(dirname(__FILE__)."/crypto/UniqueIdGenerator.php");
require_once(dirname(__FILE__)."/CopyOps.php");
require_once(dirname(__FILE__)."/EmailOps.php");

class CourseOps {
	
	var $db;

	var $accountFolder;
	
	var $defaultXML = '
<bento xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<script id="model" type="application/xml">
			<menu />
		</script>
	</head>
</bento>
';
	
	// gh#233
	var $stubXML = '
<bento xmlns="http://www.w3.org/1999/xhtml">
	<courses />
</bento>
';
	
	function __construct($db, $accountFolder = null) {
		$this->db = $db;
		if ($accountFolder) 
			$this->setAccountFolder($accountFolder);
			
		$this->copyOps = new CopyOps();
		$this->manageableOps = new ManageableOps($db);
		$this->emailOps = new EmailOps($db);
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
	} 
	
	// gh#122	
	public function setAccountFolder($accountFolder) {
		$this->accountFolder = $accountFolder;
		$this->courseFilename = $this->accountFolder."/courses.xml";
	}
	
	public function courseCreate($courseObj) {
		
		$db = $this->db;
		$accountFolder = $this->accountFolder;
		$defaultXML = $this->defaultXML;
		$id = UniqueIdGenerator::getUniqId();
		
		$return = XmlUtils::rewriteXml($this->courseFilename, function($xml) use($courseObj, $accountFolder, $defaultXML, $id, $db) {
			
			// Create a new course passing in the properties as XML attributes
			$courseNode = $xml->courses->addChild("course");
			$courseNode->addAttribute("id", $id);
			$courseNode->addAttribute("href", $id."/menu.xml");
			foreach ($courseObj as $key => $value) {
				// gh#184 Don't duplicate caption in course and menu
				switch (strtolower($key)) {
					case 'id':
					case 'caption':
						break;
					default:
						$courseNode->addAttribute($key, $value);
				}
			}
			// Make a folder for the course
			mkdir($accountFolder."/".$id);
			
			// Make a default menu.xml file
			$menuXml = simplexml_load_string($defaultXML);

			// The course node in menu.xml is basically the same as $courseNode above minus the href
			$menuCourseNode = $menuXml->head->script->menu->addChild("course");
			$menuCourseNode->addAttribute("id", $id);
			$menuCourseNode->addAttribute("class", ""); // In order for progress to work the course needs an empty class
			foreach ($courseObj as $key => $value)
				if (strtolower($key) != "id") $menuCourseNode->addAttribute($key, $value);
			
			// Add a default unit
			$unitNode = $menuCourseNode->addChild("unit");
			$unitNode->addAttribute("caption", "My unit");
			$unitNode->addAttribute("description", "My unit description");
			
			file_put_contents($accountFolder."/".$id."/menu.xml", $menuXml->saveXML());
			
			$db->StartTrans();
			
			// gh#91 Set permissions and roles
			$sql = <<<SQL
				INSERT INTO T_CoursePermission 
				(F_CourseID, F_Editable)
				VALUES (?, TRUE)
SQL;
			$bindingParams = array($id);
			$rc = $db->Execute($sql, $bindingParams);					
			if (!$rc)
				// It should be impossible for the courseID to already be in this table...
				AbstractService::$debugLog->notice("insert to T_CoursePermission failed");
			
			$sql = <<<SQL
				INSERT INTO T_CourseRoles 
				(F_CourseID, F_UserID, F_GroupID, F_RootID, F_Role, F_DateStamp)
				VALUES (?,?,?,?,?,NOW())
SQL;
			// gh#888 You become the owner and other teachers become publishers
			$bindingParams = array($id, Session::get('userID'), null, null, Course::ROLE_OWNER);
			$rc = $db->Execute($sql, $bindingParams);					
			if (!$rc)
				AbstractService::$debugLog->notice("insert to T_CourseRoles failed");
				
			$bindingParams = array($id, null, null, Session::get('rootID'), Course::ROLE_PUBLISHER);
			$rc = $db->Execute($sql, $bindingParams);					
			if (!$rc)
				AbstractService::$debugLog->notice("insert to T_CourseRoles failed");
				
			$db->CompleteTrans();
			
		});
		
		// gh#598
		$filename = $id."/menu.xml";
		$this->courseAddToRepository($filename);
		
		// Return the id and filename of the new course
		// gh#345 What was the accountFolder set to when this course was created? 
		return array("id" => $id, "filename" => $filename, "accountFolder" => $this->accountFolder);
	}
	
	public function courseSave($filename, $menuXml) {
		// Protect again directory traversal attacks; the filename *must* be in the form <some hex value>/menu.xml otherwise we are being fiddled with
		if (preg_match("/^([0-9a-f]+)\/menu\.xml$/", $filename, $matches) != 1) {
			throw $this->copyOps->getExceptionForId("errorSavingCourse", array("reason" => "corrupt file name"));
		}
		
		// Get the course id
		$courseId = $matches[1];
		
		// Check the file exists
		$menuXMLFilename = "$this->accountFolder/$filename";
		if (!file_exists($menuXMLFilename))
			throw $this->copyOps->getExceptionForId("errorSavingCourse", array("reason" => "menu.xml doesn't exist"));
			
		$db = $this->db;
		$copyOps = $this->copyOps;
		$accountFolder = $this->accountFolder;
		
		// TODO: it would be rather nice to validate $xml against an xsd
		try {
		
			$return = XmlUtils::overwriteXml($menuXMLFilename, $menuXml, function($xml) use($courseId, $accountFolder, $db, $copyOps) {
				$db->StartTrans();
				
				// SimpleXML doesn't like default namespaces in xpath expressions so define the XHTML namespace explicitly
				$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
				
				$courses = $xml->xpath("//xmlns:course");
				
				// Sanity checks
				if (sizeof($courses) != 1)
					throw new Exception("C-Builder menu.xml files must have exactly one course node");
				
				$course = $courses[0];
				
				// If the course is missing an id then add it in
				if (!isset($course['id'])) $course['id'] = $courseId;
				
				// If the units or exercises are missing ids then generate them.  At the same time if any unit has a tempid attribute, remove it.
				foreach ($course->unit as $unit) {
					if (!isset($unit['id'])) $unit['id'] = UniqueIdGenerator::getUniqId();
					foreach ($unit->exercise as $exercise) {
						if (!isset($exercise['id'])) $exercise['id'] = UniqueIdGenerator::getUniqId();
						if (isset($exercise['tempid'])) unset($exercise['tempid']); // gh#90
					}
				}
				
				// This stuff should really go into a transform (fromXML()?), but for now hardcode it here. xref gh#778
				
				// gh#148 If you have just removed publication data for a group, that will NOT exist here
				// but we do need to delete it. So first step is to delete ALL records for groups in the list
				// then you can add them back below.
				$groupIDs = implode(',', Session::get('groupTreeIDs'));
				
				// gh#598 Catch database errors that will still allow you to save the xml
				try {
					$db->Execute("DELETE FROM T_CourseStart WHERE F_GroupID in ($groupIDs) AND F_CourseID = ?", array($courseId));
					$db->Execute("DELETE FROM T_UnitStart WHERE F_GroupID in ($groupIDs) AND F_CourseID = ?", array($courseId));
					
					// 1. Write publication data to the database
		 			foreach ($course->publication->group as $group) {
						// gh#677 a blank end date should be null
		 				// Handle data types
		 				$unitInterval = XmlUtils::xml_attribute($group, 'unitInterval', 'integer');
		 				$seePastUnits = XmlUtils::xml_attribute($group, 'seePastUnits', 'boolean');
		 				$startDate = XmlUtils::xml_attribute($group, 'startDate', 'date');
		 				$endDate = XmlUtils::xml_attribute($group, 'endDate', 'date'); // defaults to null if not present
		 				
						// gh#720 If we are missing any required data then throw an exception
						if (is_null($unitInterval) || !$seePastUnits || !$startDate)
							throw $copyOps->getExceptionForId("errorSavingCourseDates");
						
						// 1.1 First write the T_CourseStart row
						// gh#385 Make sure all simpleXML objects are converted to string
						$fields = array(
							"F_GroupID" => (string)$group['id'],
							"F_RootID" => Session::get('rootID'),
							"F_CourseID" => $courseId,
							"F_StartMethod" => "group",
							"F_UnitInterval" => $unitInterval,
							"F_SeePastUnits" => $seePastUnits,
							"F_StartDate" => $startDate,
							"F_EndDate" => $endDate
						);
						
						// gh#148 PrimaryKey is just groupID and courseID
						//$db->Replace("T_CourseStart", $fields, array("F_GroupID", "F_RootID", "F_CourseID"), true);
						$rc = $db->Replace("T_CourseStart", $fields, array("F_GroupID", "F_CourseID"), true);
						// AbstractService::$debugLog->notice("update T_CourseStart gives $rc");
						
						// 1.2 Next rewrite any rows in T_UnitStart relating to this course
						// Currently we figure this out here, but this may be better calculated on the client since at some point it will be editable anyway
						$startTimestamp = strtotime($startDate);
						foreach ($course->unit as $unit) {
							/*
							 * gh#385 SQLite fails to insert this, but no errors
							 * also we were relying on MySQL to implicitly turn a timestamp into a datetime - which fails for SQLite
							$fields = array(
								"F_GroupID" => (string)$group['id'],
								"F_RootID" => Session::get('rootID'),
								"F_CourseID" => (string)$course['id'],
								"F_UnitID" => (string)$unit['id'],
								"F_StartDate" => (string)$group['startDate']
							);
							$rc = $db->AutoExecute("T_UnitStart", $fields, "INSERT");
							*/
							$sql = <<<SQL
								INSERT INTO T_UnitStart 
								(F_GroupID, F_RootID, F_CourseID, F_UnitID, F_StartDate)
								VALUES (?,?,?,?,?)
SQL;
							$bindingParams = array((string)$group['id'],Session::get('rootID'),$courseId,(string)$unit['id'],
												date('Y-m-d H:i:s', $startTimestamp));
							$rc = $db->Execute($sql, $bindingParams);					
							if (!$rc)
								AbstractService::$debugLog->notice("insert to T_UnitStart failed");
							
							$startTimestamp += $group['unitInterval'] * 86400;
						}
		 			}
		 			
					// 2. Write privacy information to the database
					// 2.1 whole course editable?
					$editable = XmlUtils::xml_attribute($course->permission, 'editable', 'boolean');
					$sql = <<<SQL
							SELECT * FROM T_CoursePermission 
							WHERE F_CourseID = ?
SQL;
					$bindingParams = array($courseId);
					$rs = $db->Execute($sql, $bindingParams);					
					if (!$rs)
						throw new Exception('Failed to read from db');
						
						
					if ($rs->recordCount() > 0) {
						// Do update
						$sql = <<<SQL
							UPDATE T_CoursePermission
							SET F_Editable = ? 
							WHERE F_CourseID = ?
SQL;
						$bindingParams = array($editable, $courseId);
						$rc = $db->Execute($sql, $bindingParams);					
						if (!$rc)
							throw new Exception('update to T_CoursePermission failed');
							
					} else {
						// Do insert
						$sql = <<<SQL
							INSERT INTO T_CoursePermission 
							(F_CourseID, F_Editable)
							VALUES (?,?)
SQL;
						$bindingParams = array($courseId, $editable);
						$rc = $db->Execute($sql, $bindingParams);					
						if (!$rc)
							throw new Exception('insert to T_CoursePermission failed');
					}
			 			
					// 2.2 course roles
					// TODO For now this just works for the author's group and root
					// 2.2.1 Collaborators
					$groupCollaborators = XmlUtils::xml_attribute($course->privacy->collaborators, 'group', 'boolean');
					$groupID = Session::get('groupID');
					$sql = <<<SQL
						DELETE FROM T_CourseRoles 
						WHERE F_CourseID = ?
						AND F_GroupID = ?
						AND F_Role = ?
SQL;
					$bindingParams = array($courseId, $groupID, Course::ROLE_COLLABORATOR);
					$rs = $db->Execute($sql, $bindingParams);					
					if (!$rs)
						throw new Exception('Failed to read from db');
						
					// Do insert - not much point having a timestamp as it will be updated everytime the course is saved
					if ($groupCollaborators) {
						$sql = <<<SQL
							INSERT INTO T_CourseRoles 
							(F_CourseID, F_GroupID, F_Role, F_DateStamp)
							VALUES (?,?,?,?)
SQL;
						$now = new DateTime();
						$bindingParams = array($courseId, $groupID, Course::ROLE_COLLABORATOR, $now->format('Y-m-d H:i:s'));
						$rc = $db->Execute($sql, $bindingParams);					
						if (!$rc)
							throw new Exception('insert to T_CourseRoles failed');
					}
					
					$rootCollaborators = XmlUtils::xml_attribute($course->privacy->collaborators, 'root', 'boolean');
					$rootID = Session::get('rootID');
					$sql = <<<SQL
							DELETE FROM T_CourseRoles 
							WHERE F_CourseID = ?
							AND F_RootID = ?
							AND F_Role = ?
SQL;
					$bindingParams = array($courseId, $rootID, Course::ROLE_COLLABORATOR);
					$rs = $db->Execute($sql, $bindingParams);					
					if (!$rs)
						throw new Exception('Failed to read from db');
						
					// Do insert - not much point having a timestamp as it will be updated everytime the course is saved
					if ($rootCollaborators) {
						$sql = <<<SQL
							INSERT INTO T_CourseRoles 
							(F_CourseID, F_RootID, F_Role, F_DateStamp)
							VALUES (?,?,?,?)
SQL;
						$now = new DateTime();
						$bindingParams = array($courseId, $rootID, Course::ROLE_COLLABORATOR, $now->format('Y-m-d H:i:s'));
						$rc = $db->Execute($sql, $bindingParams);					
						if (!$rc)
							throw new Exception('insert to T_CourseRoles failed');
					}
		
					// 2.2.2 Publishers
					$groupPublishers = XmlUtils::xml_attribute($course->privacy->publishers, 'group', 'boolean');
					$groupID = Session::get('groupID');
					$sql = <<<SQL
						DELETE FROM T_CourseRoles 
						WHERE F_CourseID = ?
						AND F_GroupID = ?
						AND F_Role = ?
SQL;
					$bindingParams = array($courseId, $groupID, Course::ROLE_PUBLISHER);
					$rs = $db->Execute($sql, $bindingParams);					
					if (!$rs)
						throw new Exception('Failed to read from db');
						
					// Do insert - not much point having a timestamp as it will be updated everytime the course is saved
					if ($groupPublishers) {
						$sql = <<<SQL
							INSERT INTO T_CourseRoles 
							(F_CourseID, F_GroupID, F_Role, F_DateStamp)
							VALUES (?,?,?,?)
SQL;
						$now = new DateTime();
						$bindingParams = array($courseId, $groupID, Course::ROLE_PUBLISHER, $now->format('Y-m-d H:i:s'));
						$rc = $db->Execute($sql, $bindingParams);					
						if (!$rc)
							throw new Exception('insert to T_CourseRoles failed');
					}
					
					$rootPublishers = XmlUtils::xml_attribute($course->privacy->publishers, 'root', 'boolean');
					$rootID = Session::get('rootID');
					$sql = <<<SQL
							DELETE FROM T_CourseRoles 
							WHERE F_CourseID = ?
							AND F_RootID = ?
							AND F_Role = ?
SQL;
					$bindingParams = array($courseId, $rootID, Course::ROLE_PUBLISHER);
					$rs = $db->Execute($sql, $bindingParams);					
					if (!$rs)
						throw new Exception('Failed to read from db');
						
					// Do insert - not much point having a timestamp as it will be updated everytime the course is saved
					if ($rootPublishers) {
						$sql = <<<SQL
							INSERT INTO T_CourseRoles 
							(F_CourseID, F_RootID, F_Role, F_DateStamp)
							VALUES (?,?,?,?)
SQL;
						$now = new DateTime();
						$bindingParams = array($courseId, $rootID, Course::ROLE_PUBLISHER, $now->format('Y-m-d H:i:s'));
						$rc = $db->Execute($sql, $bindingParams);					
						if (!$rc)
							throw new Exception('insert to T_CourseRoles failed');
					}
				
				} catch (Exception $e) {
					// gh#924 This exception stops database writing, but doesn't impact the xml file
					// log it for Clarity debugging and give the user a reasonable action
					AbstractService::$debugLog->notice("course save SQL error ".$e->getMessage());
					throw $copyOps->getExceptionForId("errorSavingCourseToDb");
				}
				
				$db->CompleteTrans();
				
				// Finally. Remove data from the XML that you have put into the db so it doesn't get saved in the file
				// gh#191 If you have iterated round the publication loop, you can't now unset it (at least with my PHP)
				// unset($course->publication);
				// I can't remove two children in this way.
				// So whilst it seems fragile, unset the privacy which works as you haven't looped round it then dom remove publication!
				// TODO. need a robust child removal option here
				unset($course->privacy);
				unset($course->permission);
				$dom = dom_import_simplexml($course->publication);
	       		$dom->parentNode->removeChild($dom);
				//$dom = dom_import_simplexml($course->privacy);
	       		//$dom->parentNode->removeChild($dom);
				
			});
			
		} catch (Exception $e) {
			// #598 There may be some exceptions thrown in the above that you still want to press
			// ahead with saving the xml for.
			if ($e->getCode() == '888') {
				// gh#598
				$this->courseCommitToRepository($filename);
			}
			throw $e;
		}
		
		return $return;
	}
	
	public function courseDelete($courseXmlString) {
		// Turn the XML string into SimpleXML
		$course = simplexml_load_string($courseXmlString);
		$accountFolder = $this->accountFolder;
		$db = $this->db;
		
		XmlUtils::rewriteXml($this->courseFilename, function($xml) use($course, $accountFolder, $db) {
			$db->StartTrans();
			
			// SimpleXML doesn't like default namespaces in xpath expressions so define the XHTML namespace explicitly
			$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');

			// gh#91 delete the node only after you have finished using courseID otherwise it becomes null
			$courseID = XmlUtils::xml_attribute($course, 'id', 'string');
			
			// Rename the folder such that it is prefixed with "deleted_"
			if (!rename($accountFolder."/".$courseID,  $accountFolder."/deleted_".$courseID))
				throw new Exception("Unable to rename folder and so could not delete course");
			
			// #155
			$db->Execute("DELETE FROM T_CourseStart WHERE F_RootID = ? AND F_CourseID = ?", array(Session::get('rootID'), $courseID));
			$db->Execute("DELETE FROM T_UnitStart WHERE F_RootID = ? AND F_CourseID = ?", array(Session::get('rootID'), $courseID));
			
			// gh#91 Remove permissions and roles
			$db->Execute("DELETE FROM T_CoursePermission WHERE F_CourseID = ?", array($courseID));
			$db->Execute("DELETE FROM T_CourseRoles WHERE F_CourseID = ?", array($courseID));
			
			// Find the course node in the xml and delete it
			foreach ($xml->xpath("//xmlns:course[@id='$courseID']") as $courseNode) {
				unset($courseNode[0]);
			}
			
			$db->CompleteTrans();
		});
	}
	
	// gh#233
	public function createCourseStub($filename, $id) {
		$stubXML = $this->stubXML;
		XmlUtils::newXml($filename, $stubXML, function($xml) use($id) {
			$courseNode = $xml->courses->addChild("course");
			$courseNode->addAttribute("id", $id);
			$courseNode->addAttribute("href", $id."/menu.xml");
			$date = new DateTime();
			$courseNode->addAttribute("exported", $date->format('Y-m-d H:i:s'));
		});
	}
	
	// gh#598
	protected function courseCommitToRepository($filename) {
		try {		
			/**
			 * commented out until we have git running in production
			 * 
			$repositoryDir = $GLOBALS['ccb_repository_dir'];
			$gitPath = '"c:\Program Files (x86)\Git\bin\git"';
			$debugStderr = ' 2>&1';
			$prefix = $prefix = substr($this->accountFolder, strrpos($this->accountFolder, '/')+1);
			$courseId = substr($filename, 0, strpos($filename, '/'));
			$commitMsg = 'by userID='.Session::get('userID').' in '.$prefix;
			$commitCmd = ' commit -m "'.$commitMsg.'" '.$prefix.'/'.$courseId.'/menu.xml';
			
			$output = array();
			chdir('../../'.$repositoryDir);
			exec($gitPath.$commitCmd.$debugStderr, $output, $rc);
			if (!$rc) {
				AbstractService::$debugLog->notice("git commit for id=$courseId in prefix=$prefix failed, probably nothing changed");
			} else {
				AbstractService::$debugLog->notice("git commit for id=$courseId in prefix=$prefix succeeded");
				AbstractService::$debugLog->notice(implode(' ',$output));
			}
			*/		
		} catch (Exception $e) {
			// Do nothing, just keep going
		}
	}
	
	// gh#598
	protected function courseAddToRepository($filename) {
		try {				
			/**
			 * commented out until we have git running in production
			 * 
			$repositoryDir = $GLOBALS['ccb_repository_dir'];
			$gitPath = '"c:\Program Files (x86)\Git\bin\git"';
			$debugStderr = ' 2>&1';
			$prefix = $prefix = substr($this->accountFolder, strrpos($this->accountFolder, '/')+1);
			$courseId = substr($filename, 0, strpos($filename, '/'));
			$addCmd = ' add '.$prefix.'/'.$courseId.'/menu.xml';
			
			$output = array();
			chdir('../../'.$repositoryDir);
			exec($gitPath.$addCmd.$debugStderr, $output, $rc);
			if (!$rc) {
				AbstractService::$debugLog->notice("git add for id=$courseId in prefix=$prefix succeeded");
			} else {
				AbstractService::$debugLog->notice("git add for id=$courseId in prefix=$prefix failed");
			}
			*/
		} catch (Exception $e) {
			// Do nothing, just keep going
		}
	}
	
	public function getCourseStart($id) {
		$groupID = Session::get('groupID');
		do {
			$sql = "SELECT F_GroupID, F_UnitInterval, F_SeePastUnits, ".$this->db->SQLDate("Y-m-d", "F_StartDate")." F_StartDate, ".$this->db->SQLDate("Y-m-d 23:59:59", "F_EndDate")." F_EndDate ".
			   	   "FROM T_CourseStart ".
			   	   "WHERE F_GroupID = ? ".
			  	   "AND F_RootID = ? ".
			  	   "AND F_CourseID = ?";
			$results = $this->db->GetArray($sql, array($groupID, Session::get('rootID'), $id));
			$result = (sizeof($results) == 0) ? null : $results[0];
			$groupID = $this->manageableOps->getGroupParent($groupID);
			
			// It is possible to have a result which doesn't contain all the bits we need (e.g. a start date, end date and unit interval) so only count if we have all
			// gh#118 But unitInterval might be 0 - which is fine
			//$gotResult = !(is_null($result)) && ($result['F_UnitInterval'] >=0 ) && $result['F_StartDate'] && $result['F_EndDate'];
			//gh #237
			$gotResult = !(is_null($result)) && ($result['F_UnitInterval'] >=0 ) && $result['F_StartDate'];
		} while (!$gotResult && !is_null($groupID));
		
		return $result;
	}

	// gh#122
	public function getCourse($id) {
		if (file_exists($this->accountFolder."/".$id."/menu.xml")) {
			$xml = simplexml_load_file($this->accountFolder."/".$id."/menu.xml");
			return $xml->head->script->menu->course;
		} else {
			return false;
		} 
	}

	/**
	 * This function finds if the course is editable
	 * gh#91
	 */
	public function getCoursePermission($courseID){

		$sql = <<<SQL
			SELECT cp.F_Editable as editable FROM T_CoursePermission cp 
			WHERE cp.F_CourseID = ?
SQL;
		$bindingParams = array($courseID);
		
		$rs = $this->db->Execute($sql, $bindingParams);
		if ($rs->recordCount() > 0)
			return (boolean)$rs->FetchNextObj()->editable;
			
		return false;
	}
	
	/**
	 * This function finds the highest role a user has in a course
	 * gh#91
	 */
	public function getUserRole($courseID){
		$userRole = $groupRole = $rootRole = 99;
		$userID = Session::get('userID');
		$userType = Session::get('userType');
		$groupIDs = implode(',', array_unique(array_merge(Session::get('groupIDs'), Session::get('parentGroupIDs')), SORT_DESC));
		$rootID = Session::get('rootID');
		
		// gh#913
		if ($userType == User::USER_TYPE_ADMINISTRATOR) {
			$userRole = Course::ROLE_OWNER;
		
		} else if ($userType > User::USER_TYPE_STUDENT) {
			// First look for the user directly
			$sql = <<<SQL
				SELECT c.F_Role as role FROM T_CourseRoles c 
				WHERE c.F_CourseID = ?
				AND c.F_UserID = ?
SQL;
			$bindingParams = array($courseID, $userID);
			$rs = $this->db->Execute($sql, $bindingParams);
			if ($rs->recordCount() > 0)
				while ($rec = $rs->FetchNextObj()) {
					if ($rec->role < $userRole)
						$userRole = $rec->role;	
				}
				
			// Then look to see for all the groups the user is part of
			$sql = <<<SQL
				SELECT c.F_Role as role FROM T_CourseRoles c 
				WHERE c.F_CourseID = ?
				AND c.F_GroupID IN (?)
				AND c.F_UserID is null
SQL;
			$bindingParams = array($courseID, $groupIDs);
			$rs = $this->db->Execute($sql, $bindingParams);
			if ($rs->recordCount() > 0)
				while ($rec = $rs->FetchNextObj()) {
					if ($rec->role < $groupRole)
						$groupRole = $rec->role;	
				}
				
			// Finally for the root
			$sql = <<<SQL
				SELECT c.F_Role as role FROM T_CourseRoles c 
				WHERE c.F_CourseID = ?
				AND c.F_RootID = ?
SQL;
			$bindingParams = array($courseID, $rootID);
			$rs = $this->db->Execute($sql, $bindingParams);
			if ($rs->recordCount() > 0)
				while ($rec = $rs->FetchNextObj()) {
					if ($rec->role < $rootRole)
						$rootRole = $rec->role;	
				}
		// gh#882
		/*	
		} else {
			$sql = <<<SQL
			SELECT c.F_Role as role FROM T_CourseRoles c 
			WHERE c.F_CourseID = ?
			AND c.F_GroupID IN (?)
SQL;
			$bindingParams = array ($courseID, $groupIDs );
			$rs = $this->db->Execute ( $sql, $bindingParams );
			if ($rs->recordCount () > 0)
				while ($rec = $rs->FetchNextObj ()) {
					if ($rec->role < $groupRole)
						$groupRole = $rec->role;
				}
		*/
		}
		
		// gh#91 remember that owner=1, collaborator=2 etc so look for the lowest number
		return min($userRole, $groupRole, $rootRole);
	}
	
	// gh#122
	public function getCourseUsersFromGroup($courseID, $groupID, $today){

		$groupArray = $this->getGroupSubgroups($groupID, $courseID);
		$groupList = implode(',', $groupArray);
		
		// Using the list of all groups, get the users in them
		$sql = <<<SQL
			SELECT u.* FROM T_User u, T_Membership m 
			WHERE u.F_UserID = m.F_UserID
			AND m.F_GroupID in ($groupList)
			AND (u.F_ExpiryDate >= ? OR u.F_ExpiryDate IS NULL)
SQL;
		$bindingParams = array($today);
		
		return $this->db->Execute($sql, $bindingParams);
	}
	
	// gh#122 Recursive function to get all subgroups of this group
	// that do NOT have their own course publication date
	private function getGroupSubgroups($startGroupID, $courseID) {
		$subGroupIDs = array($startGroupID);
		$sql = <<<EOD
				SELECT F_GroupID
				FROM T_Groupstructure
				WHERE F_GroupParent = ?
				AND F_GroupParent <> F_GroupID
EOD;
		$groupRS = $this->db->Execute($sql, array($startGroupID));
		
		if ($groupRS->recordCount()>0) {		
			foreach ($groupRS->GetArray() as $group) {
				// Only include this group if it doesn't have its own publication for this course
				$sql = <<<EOD
						SELECT *
						FROM T_CourseStart
						WHERE F_GroupID = ?
						AND F_CourseID = ?
EOD;
				$courseRS = $this->db->Execute($sql, array($group['F_GroupID'], $courseID));
				
				if ($courseRS->recordCount() == 0) {		
					$subGroupIDs = array_merge($subGroupIDs, $this->getGroupSubgroups($group['F_GroupID'], $courseID));
					
				}
			}
		} 
		
		return $subGroupIDs;
	}

	// TODO. Not sure if this is the right place for this function. 
	// I had to add emailOps to courseOps, ok?
	public function sendWelcomeEmail($courseXML, $groupID) {

		// Initialise
		$emailArray = array();
		$today = date('Y-m-d');
		
		// We are sent course information as XML
		$xml = simplexml_load_string($courseXML);
		$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		$course = new Course();
		foreach ($xml->attributes() as $key => $value)
			$course->{$key} = (string) $value;
		
		$publication = $xml->publication;
		if ($publication) {
			foreach ($publication->group as $group) {
				if ($group['id'] == $groupID) {
					$course->startDate = (string) $group['startDate'];
					break;
				}
			}
		}
		// Need to get some account information from the db for this group
		// TODO. This might be better as a method in AccountOps
		$sql = 	<<<EOD
				SELECT r.*, a.*
				FROM T_AccountRoot r, T_Accounts a, T_Membership m
				WHERE r.F_RootID = m.F_RootID
				AND a.F_RootID = r.F_RootID
				AND m.F_GroupID = ?
				LIMIT 1
EOD;
		$rs = $this->db->Execute($sql, array($groupID));
		
		switch ($rs->RecordCount()) {
			case 0:
				// There is no-one in this group yet, so don't know which account it is, raise an error
				return false;
				break;
			case 1:
				// One record, good.
				$dbObj = $rs->FetchNextObj();
				break;
			default:
				return false;
		}
		$course->prefix = $dbObj->F_Prefix;
		$course->contentLocation = $dbObj->F_ContentLocation;
		$course->loginOption = $dbObj->F_LoginOption;
		
		// Now we need get all the active users in this group
		$userRS = $this->getCourseUsersFromGroup($course->id, $groupID, $today);
				
		// Loop round the users and build an email array
		if ($userRS->RecordCount() > 0) {
			while ($userObj = $userRS->FetchNextObj()) {
				$user = new User();
				$user->fromDatabaseObj($userObj);
				
				// Send email IF we have one
				if (isset($user->email) && $user->email) {
					// Just during inital testing - only send emails to me
					//$toEmail = 'adrian.raper@clarityenglish.com';
					$toEmail = $user->email;
					$emailData = array("user" => $user, "course" => $course);
					$thisEmail = array("to" => $toEmail, "data" => $emailData);
					$emailArray[] = $thisEmail;
				}
			}
		}
		
		// gh#226
		$rc = $this->emailOps->sendEmails('', 'CCB/EmailMeWelcome', $emailArray);

		return count($emailArray);
	}
	
	/**
	 * gh#233 Build an xml list of the media files used in a particular course
	 * 
	 */
	public function buildMediaXml($courseId, $prefix) {

		$menuFile = $this->accountFolder.'/'.$courseId.'/menu.xml';
		$menuXml = simplexml_load_file($menuFile);
		$menuXml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		$exercises = $menuXml->xpath('//xmlns:exercise');
		if (count($exercises) > 0) {
			$filesXml = new SimpleXMLElement('<bento xmlns="http://www.w3.org/1999/xhtml"><files originalAccount="'.$prefix.'" /></bento>');			
			foreach ($exercises as $exercise) {
				// Don't write some types of media
				if ($exercise['type'] == 'video')
					continue;
				// Don't try anything that doesn't list a src
				if (!isset($exercise['src']))
					continue;
				// Don't need to copy URLs
				if ((stripos($exercise['src'], 'http') !== false) && (stripos($exercise['src'], 'http') == 0))
					continue;
					
				$fileNode = $filesXml->addChild('file');
				$fileNode['filename'] = $exercise['src'];
				$fileNode['type'] = $exercise['type'];
				
				// Some types have a thumbnail as well as a main src
				if (isset($exercise['thumbnail'])) {
					$fileNode = $filesXml->addChild('file');
					$fileNode['filename'] = $exercise['thumbnail'];
					$fileNode['type'] = 'thumbnail';
				}
					
			}
			return $filesXml->asXML();
		}
	}
}
