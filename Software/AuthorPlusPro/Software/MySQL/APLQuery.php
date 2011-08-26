<?php
include_once("dbPath.php");
include_once("dbFunctions.php");

class XMLQuery {

    function XMLQuery() {
        $this->ParseRequest();
    }

    function ParseRequest() {
        // NOTE: 'always_populate_raw_post_data = On' 
        // MUST be uncommented in php.ini
        //$post = urldecode($GLOBALS[HTTP_RAW_POST_DATA]);
	$post = urldecode(file_get_contents("php://input"));

        // Parse the request
        $xml = xml_parser_create();
        xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
        xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);

        // Set initial value of all the variables
	// AR v6.4.2.6 Add userID and rootID
        $this->vars = array(
            'DBPATH'      => "",
            'PURPOSE'     => "",
            'USERNAME'    => "",
            'ROOTID'    => "1",
            'USERID'    => "",
            'PASSWORD'    => "",
		'EKEY'        => ""
        );

        if ( !xml_parse_into_struct($xml, $post, $vals, $index) ) {
            return;
	}

        xml_parser_free( $xml );

        // Register variables
	foreach($vals as $key => $val) {
		if ($val['level']>1) {
			$this->vars[strtoupper($val['tag'])] = $val['value'];
		}
	}
    }
}

$node = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";

$Query	= new XMLQuery();
$vars = $Query->vars;

//$vars["PURPOSE"] = "CheckLogin";
//$vars["USERNAME"] = "Teacher";
//$vars["ROOTID"] = "163";

$Db = new DB($vars);
$Db->open("score");
switch ( strtoupper($vars["PURPOSE"]) ) {
case "GETDECRYPTKEY" :
	$rC = getDecryptKey( $vars, $node );
	break;
case "CHECKLOGIN" :
	$rC = checkLogin( $vars, $node );
	break;
case "CHECKMGS" :
	$rC = checkMGS( $vars, $node );
	break;
// for debug purpose:
//case "GETMGS" :
//	$rC = getMGS( $vars, $node );
//	break;
// for debug purpose:
//case "GETPARENTGROUP" :
//	$rC = getParentGroup( $vars["GID"]), $node );
//	break;
default:
	$node .= "<db error='true'>No method sent to PHP.</db>";
	break;
}

$node .= "</db>";
print($node);

$Db->disconnect();
?>