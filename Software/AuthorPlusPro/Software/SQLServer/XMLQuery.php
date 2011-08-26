<?php
//echo("XMLQuery.php");
class XMLQuery {

    function XMLQuery() {
        $this->ParseRequest();
    }

    function ParseRequest() {
	
	$post = file_get_contents("php://input");
	//if (empty($post)) {
	//	print "nothing from php://input";
	//	$post = urldecode($_POST['queryXML']);
	//} else {
	//	print "got from php://input ".$post;
	//}
	
        //$post = '<query purpose="getDatabaseVersion" dbHost="1" />';
 
        // Parse the request
        $xml = xml_parser_create();
        xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
        xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);

        $this->vars = array(
		'DBPATH'      => "",
		'PURPOSE'     => "",
		'USERNAME'    => "",
		'ROOTID'    => 0,
		'USERID'    => -1,
		'PASSWORD'    => "",
		'LICENCEID'    => "",
		//v6.3.4 Add new field (optional) for passing db details
		'DBHOST'  => 1,
		//v6.5.4.5 which database version
		'DATABASEVERSION' => 0,
		'PREFIX' => "",
		'EKEY'        => ""
		);
		
	// We put dbHost on the command line
	if (isset($_GET['dbHost'])) {
		$this->vars['DBHOST']=$_GET['dbHost'];
	}
	
        if ( !xml_parse_into_struct($xml, $post, $vals, $index) ) {
            return;
	}
        xml_parser_free( $xml );

/*
        // Register variables
        $qid = $index['query'][0];
        foreach($vals[$qid]['attributes'] as $key => $val) {
            $this->vars[ strtoupper($key) ] = $val;
        }
	if ( array_key_exists('value', $vals[$qid]) ) {
		$this->vars['SENTDATA'] = $vals[$qid]['value'];
	}
    }
*/
        // Register variables
	foreach($vals as $key => $val) {
		if ($val['level']>1) {
			$this->vars[strtoupper($val['tag'])] = $val['value'];
		}
	}
  }
}
?>