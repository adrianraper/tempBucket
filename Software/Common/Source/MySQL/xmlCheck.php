<?php
$node = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";
class XMLQuery {

    function XMLQuery() {
        $this->ParseRequest();
    }

    function ParseRequest() {
        // NOTE: 'always_populate_raw_post_data = On' 
        // MUST be uncommented in php.ini or overridden with .htaccess file
	// The next line may be unnecessary or may not be sufficent
	//ini_set('always_populate_raw_post_data','1');
	
        //$post = urldecode($GLOBALS[HTTP_RAW_POST_DATA]);
	//v6.4.1.4 Try a better method for getting raw data
	//v6.4.2 This is all well and good, but I have worked to encode courseName (amongst others) and I don't
	// want to simply unencode it here. OK - do a double encoding on any stringy parts in Flash.
	$post = urldecode(file_get_contents("php://input"));
	//$post = file_get_contents("php://input");
	//Global $node;
	//$node .= "<note>" .urlencode($post)  ."</note>";
	
        $post = '<query method="getRMSettings" rootID="1" dbHost="1" />';
//        $post = '<query method="countUsers" rootID="1" />';
//        $post = '<query method="GETUSERS" />';
//        $post = '<query method="ADDNEWUSER" name="Felix" studentID="12345ICQ" password="Password" ' 
//            .'country="Russia" email="test@mail" rootID="0"/>';
//        $post = '<query method="STOPUSER" sessionID="3" licenceID="280" />';

        //$post = '<query method="GETLICENCESLOT" licences="2" rootID="1" userID="11"/>';
//        $post = '<query method="DROPLICENCE" licenceID="23" />';
//        $post = '<query method="HOLDLICENCE" licenceID="320" />';
//        $post = '<query method="FAILLICENCESLOT" />';

//        $post = '<query method="GETSCORES" userID="2" courseID="11" />';
//        $post = '<query method="WRITESCORE" scored="33" correct="5" wrong="2" '
//            . 'skipped="3" itemID="110" unitID="7" duration="123" sessionID="17" userID="9" />';
//        $post = '<query method="STARTSESSION" userID="2" courseID="11" courseName="Late Elementary (R)" />';
//	$post = '<query method="STOPSESSION" sessionID="8" />';
//        $post = '<query method="GETSCRATCHPAD" userID="27" />';
//        $post = '<query method="SETSCRATCHPAD" userID="27"><![CDATA[This is my new Scratch 
	//(newline) Pad]]></query>';
//        $post = '<query method="getScores" userID="9" courseName="Tense Buster Elementary" cacheVersion="1074374988687"/>';
	//$post = '<query method="GETSESSIONS" userID="2" />';

        // Parse the request
        $xml = xml_parser_create();
        xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
        xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);

        // Set initial value of all the variables
        $this->vars = array(
            'METHOD'      => "help",
            'USERID'      => -1,
	    'ROOTID'    => 0,
            'NAME'        => "",
            'PASSWORD'    => "",
            'RMSETTING'   => "",
            'COURSENAME'  => "",
            'ITEMID'      => 0, // this is used for exerciseID
            'UNITID'      => 0,
            'LICENCEID'   => 0,
            'LICENCES'    => 0,
            'SCORE'       => 0,
            'CORRECT'     => 0,
            'WRONG'       => 0,
            'SKIPPED'     => 0,
            'COUNTRY'     => "",
//            'CLASSNAME'   => "",
            'EMAIL'       => "",
            'STUDENTID'   => 0,
            'SESSIONID'   => -1,
            'DURATION'    => 0,
            'SENTDATA'    => "",
//	v6.3.4 Add new field for unit IDs used in dynamic test
            'TESTUNITS'    => "",
//	v6.3.4 Add new field (optional) for passing db details
		'DBHOST'  => "1",
// v6.3.4 New field for key encryption
		'EKEY' => 1,
		// v6.3.4 session table uses courseID not courseName
		// v6.3.6 But RM takes a while to catch up, and Orchid will write out both.
		// So IF the database has coursename, then write out both but focus on coursename.
		// If not, then (naturally) just use courseID.
		'USECOURSENAME' => "false",
		// v6.3.5 Licence type
		'LICENCETYPE' => "Single",
		// v6.4.2 Pass local time
		'DATESTAMP' => date("Y/m/d H:i:s"),
		// v6.3.5 Changed field for courseID in session table
		'COURSEID' => 0,
		//v6.4.2 Add field for score detail
		'QUESTIONID' => 0
        );

        if ( !xml_parse_into_struct($xml, $post, $vals, $index) ) {
            return;
	}

        xml_parser_free( $xml );

        // Register variables
        $qid = $index['query'][0];
        foreach($vals[$qid]['attributes'] as $key => $val) {
            $this->vars[ strtoupper($key) ] = $val;
        }
	if ( array_key_exists('value', $vals[$qid]) ) {
		$this->vars['SENTDATA'] = $vals[$qid]['value'];
	}
	// This code does not seem to work to pull out the value data
        //// Additional SENTDATA variable from within the tag content
        //if ($vals[$qid]['type'] == 'open') {
        //    for ($i = $qid + 1; ; $i++) {
        //        if ($vals[$i]['type'] == 'close' && $vals[$i]['level'] == $vals[$qid]['level'])
        //            break;
        //        if ( array_key_exists('value', $vals[$i]) )
        //            $this->vars['SENTDATA']  .= $vals[$i]['value'];
        //    }
        //}
    }
}
$Query	= new XMLQuery();
$vars		= $Query->vars;

include_once("dbPath.php");
$Db 		= new DB($vars);
print("DB.host=" .$Db->host ." DB.user=".$Db->user." DB.pass=".$Db->pass." DB.base=".$Db->base);
include_once("dbProgress.php");
$Progress	= new PROGRESS();

include_once("queryProgress.php");

$Db->open("score");

switch ( strtoupper($vars['METHOD']) ) {
	case 'STARTUSER':
		$rC = getUser( $vars, $node );
		break;

	case 'ADDNEWUSER':
		$rC = addUser( $vars, $node );
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
		
	default:
		$node .= "<err code='101'>No method sent</err>";
		break;
}

$node .= "</db>";
print($node);

$Db->disconnect();
?>
