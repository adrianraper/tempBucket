<?php
class XMLParse {
	private $parser;
	private $casefolding = 1;
	public $parsedData;
	
	public function __construct(){
		$this->parser = null;
		$this->parsedData = array();
	}
	
	public function __destruct() {
		$this->parsedData = null;
	}

	private function parseStart($parser, $name, $attribs){
		$this->parsedData[$name] = $attribs;
	}
	
	private function parseEnd($parser, $name){
		
	}
	
	private function parseData($parser, $data){
		
	}
	
	public function parse($xmlstr){
		$this->parser = xml_parser_create();
		xml_parser_set_option($this->parser, XML_OPTION_CASE_FOLDING, $this->casefolding);
		xml_set_object($this->parser, $this); 
		xml_set_element_handler($this->parser, "parseStart", "parseEnd");
		xml_set_character_data_handler($this->parser, "parseData");
		xml_parse($this->parser, $xmlstr);
		xml_parser_free($this->parser);
	}
	
	public function setOption($optName, $value){
		$this->$optName = $value;
	}
}
?>