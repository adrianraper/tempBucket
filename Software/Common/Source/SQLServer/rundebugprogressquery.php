<?php
//header("Content-Type: text/xml");
$node = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";

error_reporting(E_ALL);
ini_set('display_errors','on');
// v6.5.6.4 Needs to be moved before XMLQuery which uses dates
// v6.5.5.4 If you use server time, ensure it is UTC
date_default_timezone_set("UTC");
	
require_once(dirname(__FILE__)."/debugXMLQuery.php");
$adodbPath= "../..";
require_once($adodbPath."/adodb5/adodb-exceptions.inc.php");
require_once($adodbPath."/adodb5/adodb.inc.php");
require_once(dirname(__FILE__)."/dbPath.php");
require_once(dirname(__FILE__)."/dbProgress.php");
require_once(dirname(__FILE__)."/crypto/RSAKey.php");
require_once(dirname(__FILE__)."/crypto/Base8.php");

	// read the passed XML
	$Query = new XMLQuery();
	$vars = $Query->vars;

	// ignore whatever is coming from actionscript
	//$vars['DBHOST']=1;
	// make the database connection
	global $db;
	$dbDetails = new DBDetails($vars['DBHOST']);
	//$dbDetails = new DBDetails(3); // To try out a specific database
	$vars['DBDRIVER']=$dbDetails->driver;
	
	echo $dbDetails->dsn;
	$db = &ADONewConnection($dbDetails->dsn);
	if (!$db) die("Connection failed");
	// Put this line on to see all sql calls before they are made
	$db->debug = true;
	
	// v3.6 UTF8 character mismatch between PHP and MySQL
	if ($dbDetails->driver == 'mysql') {
		$charSetRC = mysql_set_charset('utf8');
		//echo 'charSet='.$charSetRC;
	}
	// Fetch mode to use
	$ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
	
	// load the progress functions - all code is in this class now
	$Progress	= new PROGRESS();
	//$node .= "<note>method=".$vars['METHOD']."</note>";
	switch ( strtoupper($vars['METHOD']) ) {
	
		case 'GETRMSETTINGS':
			$node .= "<note>dbhost=".$dbDetails->host." dbname=".$dbDetails->dbname." driver=".$dbDetails->driver."</note>";
			$rC = $Progress->checkDatabaseVersion( $vars, $node );
			if ($rC) {
				$rC = $Progress->getRMSettings( $vars, $node );
			} else {
				$node .= "<note>error from checkDatabaseVersion</note>";			
			}
			break;
		
		case 'STARTUSER':
		case 'CLSSTARTUSER':
		//v6.5.5.9 RL: USe this for website login. I tried to integrated into normal GETUSER but they are locally contradiction
		// (get user use RootID to find the other information while this needs to find the RootID)
		// In the meanwhile just getUser. should we get the instance ID and StartedContent as well?
		case 'STARTUSERWITHOUTROOT':
			// v6.5.5.6 Temporarily use a different function to cope with CLS login
			// This is by email and only looks at people with licenceType=individual as this allows
			// someone to have their email address used as part of a school licence and yet still login to CLSSTARTUSER
			if (strtoupper($vars['METHOD'])=='CLSSTARTUSER') {
				//$rC = $Progress->getIndividualUser( $vars, $node );
				$rC = $Progress->CLS_getUser( $vars, $node );
			} else if (strtoupper($vars['METHOD'])=='STARTUSERWITHOUTROOT') {
				$rC = $Progress->getUserWithoutRoot( $vars, $node );
			} else {
				// v6.5.4.5 database version dependent - now passed in XML
				// v6.5.6 HCT. If coming in through SCORM, we actually need to check the user across all the same groupedRoots that we do for licence control.
				// Then if we find that the user exists in one of those roots, we need to send it back with an override message. 
				// Worries: will we need to redo getRMSettings for that new root? And override vars['rootID']? No, nothing else uses it.
				$rC = $Progress->getUser( $vars, $node );
			}
			if ($rC) {
				// v6.5.4.6 Switch to non-transferable licences
				//$rC = $Progress->checkLicenceAllocation( $vars, $node );
				// V6.5.5.0 All licence checking now done with getLicenceSlot (dbLicence)
				/*
				// v6.5.5.0 First of all see if this user has already used a licence
				if ($Progress->checkExistingLicence( $vars, $node)) {
					// They have, so nothing else to do for licences
					$node .= "<note>use existing licence</note>";
				} else {
					// This is a new licence, first check to see if we have space
					$rC = $Progress->checkAvailableLicences( $vars, $node );
					if ($rC) {
						// We do, so record it
						//$rC = $Progress->addLicencesUsed( $vars, $node );
						$rC = $Progress->addNewLicence( $vars, $node );
					}
				}
				*/
			}			
			if ($rC) {
				// The licenceID we are saving here is to stop double login - not for counting licences used
				// v6.5.5.0 Should be renamed to instanceID
				//$rC = $Progress->saveLicenceID( $vars, $node );
				$rC = $Progress->saveInstanceID( $vars, $node );
				
				// v6.5.4.6 Switch to non-transferable licences
				// v6.5.5.0 wrong place to do this
				//$rC = $Progress->addLicencesUsed( $vars, $node );
			}
			// v6.5.5.0 We could drop MGS couldn't we?
			if ($rC) {
				$rC = $Progress->getMGS( $vars, $node );
			}
			// v6.5.5.5 Add the list of courseIDs that the user has already started
			if ($rC) {
				$rC = $Progress->getStartedContent( $vars, $node );
			}
			break;
		
		// v6.5.4.7 WZ: Added for NEEA China, but could be generally used
		// v6.5.5.0 This duplicates a later case
		//case 'UPDATEUSER':
		//	$rC = $Progress->updateUser($vars, $node );
		//	break;
		
		// v6.5.4.6 This method checks the users details, but doesn't save licence or do MGS.
		// Currently used by registration systems only
		case 'GETUSER':
			$rC = $Progress->getUser( $vars, $node );
			break;
		case 'GETUSERDETAIL':
		case 'GETUSERBYSTUDENTID':
			// v6.5.5.5 Bad naming
			//$rC = $Progress->getUserDetail( $vars, $node );
			$rC = $Progress->getUserByStudentID( $vars, $node );
			break;
		case 'GETUSERBYEMAIL':
			$rC = $Progress->getUserByEmail( $vars, $node );
			break;
		case 'COUNTUSERS':
			$rC = $Progress->countUsers( $vars, $node );
			break;
	
		case 'STARTSESSION':
			$rC = $Progress->insertSession( $vars, $node );
			break;
			
		case 'GETSCORES':
			// debug logging times
			$time1 = time();
			$rC = $Progress->getScores( $vars, $node );
			// v6.4.2.8 And add in everyone's scores
			$time2 = time() - $time1;
			if ($rC) {
				$rC = $Progress->getAllScores( $vars, $node );
			}
			$time3 = time() - $time2 - $time1;
			$node.="<note getScores='$time2' getAllScores='$time3' />";
			$node .= "<note>dbhost=".$dbDetails->host." dbname=".$dbDetails->dbname." driver=".$dbDetails->driver."</note>";
			// v6.5.6.5 Protea uses full unit ID
			if ($vars['PRODUCTCODE']==45 || $vars['PRODUCTCODE']==46) {
				require_once(dirname(__FILE__)."/dbContent.php");
				$Content	= new CONTENT();
				$rC = $Content->encodeUnitIDs($vars, $node);
			}
			break;
			
		// v6.4.2.8 For comparative progress reporting - probably not called directly
		case 'GETALLSCORES':
			$rC = $Progress->getAllScores( $vars, $node );
			break;
			
		case 'WRITESCORE':
			// v6.5.5.6 Protea integration - need to decode course, unit and exerciseID
			// v6.5.6 No longer, Protea now passes correct IDs
			// v6.5.6.5 yes they do, but Clarity programs don't. Or rather Clarity passes unitID as the sequence number not the full ID
			if ($vars['PRODUCTCODE']==45 || $vars['PRODUCTCODE']==46) {
				require_once(dirname(__FILE__)."/dbContent.php");
				$Content	= new CONTENT();
				$rC = $Content->decodeUnitIDs($vars, $node);
			}
			$rC = $Progress->insertScore( $vars, $node );
			if ($rC) {
				$rC = $Progress->updateSession( $vars, $node );
				// v6.5.6.7 Add in a check to see that we are writing one record per session to licence control
				// As we don't know licenceType or rootID at this point, need to read from T_Session and T_Accounts.
				// Do a simple check to avoid anything unnecessary for anonymous access.
				if ($vars['USERID']>=1) {
					$rC = $Progress->checkLicenceControl( $vars, $node );
				}
			}
			break;
			
		case 'GETSCRATCHPAD':
			$rC = $Progress->getScratchPad( $vars, $node );
			break;
	
		case 'SETSCRATCHPAD':
			//print 'pad=' .$vars['SENTDATA'];
			$rC = $Progress->setScratchPad( $vars, $node );
			break;
	    
		case 'STOPSESSION':
			$rC = $Progress->updateSession( $vars, $node );
			break;
			
		case 'STOPUSER':
			$rC = $Progress->updateSession( $vars, $node );
			if ($rC) {
			    $rC = $Progress->dropLicence( $vars, $node );
			}
			break;
			
		case 'ADDNEWUSER':
			$rC = $Progress->addUser( $vars, $node );
			if ($rC) {
				// v6.5.5.0 Should be renamed to instanceID
				//$rC = $Progress->saveLicenceID( $vars, $node );
				$rC = $Progress->saveInstanceID( $vars, $node );
				// V6.5.5.0 All licence checking now done with getLicenceSlot (dbLicence)
				/*
				// v6.5.4.6 Switch to non-transferable licences
				// v6.5.5.0 This is a new user, so it must be a new licence. Use a better name
				// This is a new licence, first check to see if we have space
				$rC = $Progress->checkAvailableLicences( $vars, $node );
				if ($rC) {
					// We do, so record it
					//$rC = $Progress->addLicencesUsed( $vars, $node );
					$rC = $Progress->addNewLicence( $vars, $node );
				}
				*/
			}
			// v6.5.5.0 We could drop MGS couldn't we?
			if ($rC) {
				$rC = $Progress->getMGS( $vars, $node );
			}
			break;
	
		case 'REGISTERUSER':
			// This is likely to be called by a program that is simply adding someone to the db, not starting them running as well
			$rC = $Progress->addUser( $vars, $node );
			break;

		case 'UPDATEUSER':
		// This is likely to be called by a program that is simply adding someone to the db, not starting them running as well
			$rC = $Progress->updateUser( $vars, $node );
			break;
	
		case 'GETGLOBALUSER':
			// This is likely to be called by a program that is simply adding someone to the db, not starting them running as well
			$rC = $Progress->getGlobalUser( $vars, $node );
			break;
	
		case 'GETUSERCHANGEPASSWORD':
			// This is likely to be called by a program that wants to change your password, but not actually start you
			$rC = $Progress->getGlobalUser( $vars, $node );
			if ($rC) {
				$rC = $Progress->updatePassword( $vars, $node );
			}
			break;
	
		//	' v6.5 For certificates
		case 'GETGENERALSTATS':
			$rC = $Progress->getGeneralStats( $vars, $node );
			break;
			
		// v6.5.6 And more certificates
		case 'GETSPECIFICSTATS':
			$rC = $Progress->getSpecificStats( $vars, $node );
			break;
		
		// v6.6.0.5 For CSTDI
		case 'WRITESPECIFICSTATS':
			$rC = $Progress->writeSpecificStats( $vars, $node );
			break;
		
		case "GETHIDDENCONTENT":
			$rC = $Progress->getHiddenContent( $vars, $node );
			break;
			
		//case "GETCOURSEHIDDENCONTENT":
		//	$rC = $Progress->getCourseHiddenContent( $vars, $node );
		//	break;
			
		case "GETEDITEDCONTENT":
			$rC = $Progress->getEditedContent( $vars, $node );
			break;

		case "CHANGEPASSWORD":
			$rC = $Progress->updatePassword( $vars, $node );
			break;

		case "GETREGDATE":
			$rC = $Progress->getRegDate( $vars, $node );
			break;

		case "GETSTARTDATE":
			$rC = $Progress->getUserStartDate( $vars, $node );
			break;

		// v6.5.5.0 For item analysis and portfolios
		case "WRITESCOREDETAIL":
			$rC = $Progress->insertScoreDetails( $vars, $node );
			break;
			
		// v6.5.5.1 For performance and errors
		case "WRITELOG":
			$rC = $Progress->insertLog( $vars, $node );
			break;

		// v6.5.5.6 These EMU functions should be better merged with the common calls
		case "EMUGETUSER":
			$rC = $Progress->Emu_getUser( $vars, $node );
			if ($rC) {
				$rC = $Progress->saveInstanceID( $vars, $node );
			    }
			break;		
	
		case "EMUUPDATEUSER":
			$rC = $Progress->Emu_updateUser( $vars, $node );
			break;
			
		case "EMUSAVEBOOKMARK":
			$rC = $Progress->Emu_saveBookmark( $vars, $node );
			break;

		// v6.5.6.5 Used for registering network licences
		case "UPDATEINFORMATION":
			$node .= "<note>dbhost=".$dbDetails->host." dbname=".$dbDetails->dbname." driver=".$dbDetails->driver."</note>";
			$rC = $Progress->updateInformation( $vars, $node );
			break;

		// v6.5.5.8 This is used for picking up information about the Clarity Recorder download
		case "DOWNLOADRECORDER":
			$rC = $Progress->insertDownloadLog( $vars, $node );
			break;
			
		case "SCORMGETSUMMARY":
			$rC = $Progress->SCORM_getSummary( $vars, $node );
			break;

		// RL: Temporary function for iLearnIELTS
		case "UPDATEUSERILEARNIELTS":
			$rC = $Progress->updateUserILearnIELTS( $vars, $node );
			break;

		// AR: A smarter forgot password lookup
		case "FORGOTPASSWORD":
			$rC = $Progress->forgotPassword( $vars, $node );
			break;
			
		default:
			$node .= "<err code='101'>No method sent</err>";
			break;
	}
	
	$node .= "</db>";
	print($node);
	$db->Close();
?>
