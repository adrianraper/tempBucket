<?PHP
//header("Content-Type: text/xml");
$node = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";

// v6.5.6.4 Needs to be moved before XMLQuery which uses dates
// v6.5.5.4 If you use server time, ensure it is UTC
date_default_timezone_set("UTC");
	
require_once(dirname(__FILE__)."/debugXMLQuery.php");
$adodbPath= "../..";
require_once($adodbPath."/adodb5/adodb-exceptions.inc.php");
require_once($adodbPath."/adodb5/adodb.inc.php");
require_once(dirname(__FILE__)."/dbPath.php");
require_once(dirname(__FILE__)."/dbLicence.php");

	// read the passed XML
	$Query	= new XMLQuery();
	$vars = $Query->vars;
	
	// make the database connection
	global $db;
	$dbDetails = new DBDetails($vars['DBHOST']);
	//print($dbDetails->dsn);
	$db = &ADONewConnection($dbDetails->dsn);
	if (!$db) die("Connection failed");
	// Use this line to see all sql calls
	$db->debug = true;
	$ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
	
	// load the progress functions - all code is in this class now
	$Licence	= new LICENCE();
	
	switch ( strtoupper($vars['METHOD']) ) {
		case 'GETLICENCESLOT':
			// v6.5.5.0 now both concurrent and Learner Tracking licences get licence slot
			// v6.5.5.5 as do network licence. Allow strings and numbers for a while.
			if ($vars['LICENCING']=='concurrent' || $vars['LICENCING']=='network' ||
				$vars['LICENCING']=='2' || $vars['LICENCING']=='3' ||
				$vars['LICENCETYPE']=='2' || $vars['LICENCETYPE']=='3') {
				$rC = $Licence->getConcurrentLicenceSlot( $vars, $node );
			} else {
				$rC = $Licence->getTrackingLicenceSlot( $vars, $node );
			}
			// v6.5.7 I could call failLicenceSlot here if you failed to grant one, rather than going back to Orchid.
			/*
			if (!$rC) {
				// You should have set the error reason code above
				//$vars['ERRORREASONCODE'] = 211
				$rC = $Licence->failLicenceSlot($vars, $node);
			}
			*/
			break;

		    case 'DROPLICENCE':
			$rC = $Licence->dropLicence($vars, $node);
			break;
		
		    case 'HOLDLICENCE':
			$rC = $Licence->updateLicence($vars, $node);
			break;
		
		case 'FAILLICENCESLOT':
		case 'FAILSESSION':
			$rC = $Licence->failLicenceSlot($vars, $node);
			break;
		
		// v6.5.5.0 For counting used licences
		case 'COUNTLICENCESUSED':
			$rC = $Licence->checkAvailableLicences( $vars, $node );
			break;
			
		// v6.5.4.5 For stopping the same username
		//case "GETLICENCEID":
		case "GETINSTANCEID":
			// This will be blocked in Orchid now
			//$rC = checkDatabaseVersion($vars, $node);
			//if ($vars['DATABASEVERSION']>1 ) {
			//	$node .= "<note>getlicenceID</note>";
				//$rC = $Licence->getLicenceID($vars, $node);
				$rC = $Licence->getInstanceID($vars, $node);
			//} else {
			//	$node .= "<note>licence not recorded</note>";
			//}
			break;
			
		// v6.5.4.5 This isn't usually called on its own, part of progress.startUser. But keep here in case
		//case "SETLICENCEID":
		case "SETINSTANCEID":
			// This will be blocked in Orchid now
			//$rC = checkDatabaseVersion($vars, $node);
			//if ($vars['DATABASEVERSION']>1 ) {
				//$rC = $Licence->setLicenceID($vars, $node);
				$rC = $Licence->setInstanceID($vars, $node);
			//}
			break;
			
		default:
			$node .= "<err code='101'>No method sent</err>";
			break;
	}

	$node .= "</db>";
	print($node);
	$db->Close();
	
?>