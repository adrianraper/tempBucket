<?php
class XMLQuery {

    function XMLQuery() {
        $this->ParseRequest();
    }

    function ParseRequest() {
		//$post = file_get_contents("php://input");
		$post = '<query><purpose>getLicenceDetails</purpose><prefix>DEV</prefix></query>';
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
		'DBHOST'  => 2,
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

    // Register variables
	foreach($vals as $key => $val) {
		if ($val['level']>1) {
			$this->vars[strtoupper($val['tag'])] = $val['value'];
		}
	}
  }
}
?>