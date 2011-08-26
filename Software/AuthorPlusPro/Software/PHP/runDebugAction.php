<?php
include_once("actionFunctions.php");

// Query Class
class XMLQuery {

	function XMLQuery() {
		$this->init();
		
		// finish initialising variables, parse request now
		$this->ParseRequest();
	}
	
	function init() {
		// Set initial value of all the variables
		$this->vars = array(
		'PURPOSE'		=> "",
		'USERNAME'		=> "",
		'PASSWORD'		=> "",
		'CONTENTPATH'	=> "",
		'COURSE'		=> "",
		'EXERCISEID'	=> "",
		'SENDER'		=> "",
		'EMAIL'		=> "webmaster@clarity.com.hk",
		'SUBJECT'		=> "",
		'BODY'		=> "",
		
		// v0.16.1, DL: upload image, audio, video
		'UPLOADPATH'	=> "",
		'UPLOADTYPE'	=> "",
		'UPLOADMULTIPLE'	=> "",
		
		// v0.16.1, DL: file locking
		'FILEPATH'		=> "",
		'TIME'		=> "",
		'ACCOUNT'		=> "",
		
		// v6.4.0.1, DL: user's IP address
		'USERIP'		=> "",	//Request.ServerVariables("REMOTE_ADDR")
		
		// v0.16.1, DL: zip files
		'BASEPATH'		=> "",	// path to the expanded unzip directory
		'FILES'		=> array(),
		'SUBFOLDERS'	=> array(),
		'SCORM'		=> False,	// boolean to indicate whether it's a SCORM export
		'SOFTWAREPATH'	=> "",	// this is not a variable got from APP but holds the path of the Software directory, CStr(Server.MapPath("..\"))
		'MENUXMLPATH'	=> "",	// v6.4.0.1, DL: hold the path of menu.xml to be edited (requires MapPath)
		
		// v0.16.1, DL: unzip file
		'ZIPFILE'		=> "",
		
		// v6.4.2, DL: for SCORM
		'PRODUCT'	=> "AP",	// product code (AP, BW, RO, SSS, TB)
		'CID'		=>	"",	// course id
		'CNAME'	=>	"",	// course name
		'UIDS'		=>	array(),	// unit id's
		'UNAMES'	=>	array(),	// unit names
		    
		// v6.4.2.6 AR for getRootDir
		'USERDATAPATH' => "",
		
		// v6.4.3 Path if you are in MGS pointing to original content, saves reading location.ini
		'ORIGINALCONTENTPATH' => "",
		// v6.4.3 Need to know what to do with enabledFlags
		'MGSENABLED' => False
		);
	}
	
	function ParseRequest() {
		// NOTE: 'always_populate_raw_post_data = On' 
		// MUST be uncommented in php.ini
		//$post = urldecode($GLOBALS[HTTP_RAW_POST_DATA]);
		//$post = file_get_contents("php://input");
/*		
		$post = <<< EOD
		<query><userDataPath>/Fixbench/area1/AuthorPlus</userDataPath>
		<purpose>exportFiles</purpose>
		<file>D:\Fixbench\ap\Clarity/Courses/1150969280977/menu.xml</file>
		<folder>1150969280977</folder>
		<basePath>D:\Fixbench\ap\Clarity</basePath>
		<SCORM>false</SCORM>
		<cid>1150969280977</cid><csubfolder>1150969280977</csubfolder><cname>General%20English</cname>
		<originalContentPath>../../ap/clarity/</originalContentPath>
		<file>D:\Fixbench\ap\Clarity/Courses/1150969280977/Exercises/1150969280713.xml</file><file>D:\Fixbench\ap\Clarity/Courses/1150969280977/Exercises/1150969280397.xml</file><file>D:\Fixbench\ap\Clarity/Courses/1150969280977/Exercises/1150969280701.xml</file><file>D:\Fixbench\ap\Clarity/Courses/1150969280977/Exercises/1150969280658.xml</file><file>D:\Fixbench\ap\Clarity/Courses/1150969280977/Exercises/1150969280368.xml</file></query>
EOD;
*/
$post = <<< EOD
<query><userDataPath>/area1/AuthorPlus</userDataPath><purpose>exportFiles</purpose>
<file>D:\\ProjectBench\\ap\\clarity/Courses/EditedContent-10379/menu.xml</file><folder>EditedContent-10379</folder>
<basePath>D:\\ProjectBench\\ap\\clarity</basePath><SCORM>false</SCORM>
<cid>1280388173000</cid><csubfolder>EditedContent-10379</csubfolder><cname>Edited%20content%20for%20Adrian%27s%20groups</cname>
<originalContentPath>../../ap/clarity/</originalContentPath>
<file>D:\\ProjectBench\\ap\\clarity/Courses/EditedContent-10379/Exercises/1127386318657.xml</file>
<file>D:\\ProjectBench\\ap\\clarity/Courses/EditedContent-10379/Exercises/1281430546046.xml</file>
<file>D:\\ProjectBench\\ap\\clarity/Courses/EditedContent-10379/Media/MultipleChoice.mp3</file>
</query>
EOD;

/*
		$post = <<<EOD
		<query><userDataPath>/fixbench/AuthorPlus</userDataPath>
		<purpose>createSCO</purpose>
		<uid>1254476239994</uid><uname>One</uname>
		<basePath>D:\\fixbench\\Content\\AuthorPlus</basePath>
		<cid>1254476234244</cid><cname>testing scorm</cname>
		<prefix>Clarity</prefix>
		<serverpath>/fixbench/Software/AuthorPlusPro/Software</serverpath>
		</query>
EOD;
*/
		//print $post;
		// Parse the request
		$xml = xml_parser_create();
		xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
		xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);
		
		if ( !xml_parse_into_struct($xml, $post, $vals, $index) ) {
		    return;
		}
		
		xml_parser_free( $xml );
		
		// Register variables
		foreach ($vals as $key => $val) {
			if ($val['level']>1) {
				switch (strtoupper($val['tag'])) {
				case "FILE" :
					array_push($this->vars["FILES"], $val['value']);
					break;
				case "FOLDER" :
					array_push($this->vars["SUBFOLDERS"], $val['value']);
					break;
				case "SCORM" :
					if ($val['value']=="true") {
						$this->vars[strtoupper($val['tag'])] = 1;
					} else {
						$this->vars[strtoupper($val['tag'])] = 0;
					}
					break;
				//v6.4.2 AR for SCORM output, send unit IDs and names, convert to array
				case "UID" :
					array_push($this->vars["UIDS"], $val['value']);
					break;
				case "UNAME" :
					array_push($this->vars["UNAMES"], $val['value']);
					break;
				case "MGSENABLED" :
					if ($val['value']=="true") {
						$this->vars[strtoupper($val['tag'])] = True;
					} else {
						$this->vars[strtoupper($val['tag'])] = False;
					}
					break;
				default :
					$this->vars[strtoupper($val['tag'])] = $val['value'];
					break;
				}
				// debug statement:
				//echo "<val>".$this->vars[strtoupper($val['tag'])]."</val>";
			}
		}
	}
}
$node = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><action>";
$Query = new XMLQuery();

switch ( strtoupper($Query->vars['PURPOSE']) ) {
case "SETUPLOADSETTINGS":
	$rC = setUploadForm( $Query->vars, $node );
	$rC = setUploadLocation( $Query->vars, $node );
	break;
case "LOCKFILE":
	$rC = lockFile( $Query->vars, $node );
	break;
case "CHECKLOCKFILE":
	$rC = checkLockFile( $Query->vars, $node );
	break;
case "CHECKLOCKCOURSE":
	$rC = checkLockCourse( $Query->vars, $node );
	break;
case "RELEASEFILE":
	$rC = releaseFile( $Query->vars, $node );
	break;
case "EXPORTFILES":
	$rC = exportFiles( $Query->vars, $node );
	break;
// v6.4.2 AR new function for building SCORM SCO
case "CREATESCO":
	$rC = createSCO( $Query->vars, $node );
	break;
case "CHECKFILEFORDOWNLOAD":
	$rC = checkFileForDownload( $Query->vars, $node );
	break;
case "UNZIPFILE":
	$rC = unzipFile( $Query->vars, $node );
	break;
case "IMPORTFILESTOCURRENTCOURSE":
	$rC = importFilesToCurrentCourse( $Query->vars, $node );
	break;
case "IMPORTFILES":
	$rC = importFiles( $Query->vars, $node );
	break;
case "SENDEMAIL":
	$rC = sendEmail( $Query->vars, $node );
	break;
case "PREVIEWCOURSES" :
case "PREVIEWMENU" :
case "PREVIEWEXERCISE" :
	$rC = setSessionVariables( $Query->vars, $node );
	break;
case "DELETEFILE":
	$rC = deleteFile( $Query->vars, $node );
	break;
default :
	$node .= "<action success='false'>No method sent to PHP.</action>";
	break;
}

$node .= "</action>";
//header('Content-type: text/xml');
print($node);
?>