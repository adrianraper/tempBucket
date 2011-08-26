<?php
$node = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";

include_once("debugXMLQuery.php");
$Query	= new XMLQuery();

$vars		= $Query->vars;

include_once("dbPath.php");
$Db 		= new DB($vars);
include_once("dbProgress.php");
$Progress	= new PROGRESS();

include_once("queryProgress.php");

$Db->open("xxxx");

switch ( strtoupper($vars['METHOD']) ) {
	case 'STARTUSER':
		// v6.4.4 MGS Pick up the MGS for this user as well as their user details
		$rC = getUser( $vars, $node );
		$rC = getMGS( $vars, $node );
		break;

	case 'ADDNEWUSER':
		$rC = addUser( $vars, $node );
		$rC = getMGS( $vars, $node );
		break;

	//v6.3.2 Count total users
	case 'COUNTUSERS':
		$rC = countUsers( $vars, $node );
		break;

	//v6.3 New code for teacher login
	case 'GETUSERS':
		$rC = getUsers( $vars, $node );
		break;

	case 'GETSCRATCHPAD':
		$rC = getScratchPad( $vars, $node );
		break;

	case 'SETSCRATCHPAD':
		//print 'pad=' .$vars['SENTDATA'];
		$rC = setScratchPad( $vars, $node );
		break;
    
	case 'STOPSESSION':
	case 'STOPUSER':
		$rC = updateSession( $vars, $node );
		break;
		
	case 'STARTSESSION':
		$rC = insertSession( $vars, $node );
		break;
		
	case 'WRITESCORE':
		if ( insertScore( $vars, $node ) == 0 ) {
		    $rC = updateSession( $vars, $node );
		}
		break;
		
	case 'GETSCORES':
		$rC = getScores( $vars, $node );
		break;
		
	case 'GETRMSETTINGS':
		//print 'getRMSettings';
		$rC = getRMSettings( $vars, $node );
		break;
		
	//	' v6.5 For certificates
	case 'GETGENERALSTATS':
		$rC = getGeneralStats( $vars, $node );
		break;
	
	default:
		$node .= "<err code='101'>No method sent</err>";
		break;
}
$node .= "</db>";
print($node);
$Db->disconnect();

?>
