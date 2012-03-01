<?PHP
//$filename = "http://www.ielts.org/docs/IELTS%20US%20Recognition%20List%20January2011.xls";
$filename = "D:\development\Software\Widget\IELTS\bin\USAGRSOrgs.xlsx";
$sheet1 = "Sheet1";
$excel_app = new COM("Excel.application") or Die ("Did not connect");
//print "Application name: {$excel_app->Application->value}\n" ;
//print "Loaded version: {$excel_app->Application->version}\n";
$Workbook = $excel_app->Workbooks->Open("$filename") or Die("Did not open $filename $Workbook");
$Worksheet = $Workbook->Worksheets($sheet1);
$Worksheet->activate;
$i = 1;
$institution = "start";
$xmlstring='<?xml version="1.0" encoding="utf-8"?><IELTS>';
while($institution <> null && $institution <> ""){
	$i++;
	// Org ID
	$orgID_cell = $Worksheet->Range("A".$i);
	$orgID_cell->activate;
	$orgID = mb_convert_encoding($orgID_cell->value, "utf-8");
	//print "$institution/";
	// Org name
	$institution_cell = $Worksheet->Range("B".$i);
	$institution_cell->activate;
	$institution = htmlspecialchars(mb_convert_encoding($institution_cell->value, "utf-8"));
	//print "$city/";
	
    // State
	$state_cell = $Worksheet->Range("E".$i);
	$state_cell->activate;
	$state = mb_convert_encoding($state_cell->value, "utf-8");
	//print "$state/";
	
	// setting the float regular expression
	//$regex = "/[0-9]+(\.)*[0-9]*/";
	//$score_cell = $Worksheet->Range("D".$i);
	//$score_cell->activate;
	//$scorestring = $score_cell->value;
	//preg_match($regex, $scorestring, $scores);
	//$score = $scores[0];
	//print "$score/";
	
	//$score_cell = $Worksheet->Range("E".$i);
	//$score_cell->activate;
	//$scorestring = $score_cell->value;
	//preg_match($regex, $scorestring, $scores);
	//$score2 = $scores[0];
	//if(($score2 < $score && $score2 > 0) || $score==0)
	//	$score = $score2;
	//print "$score2/";
	
	//$score_cell = $Worksheet->Range("F".$i);
	//$score_cell->activate;
	//$scorestring = $score_cell->value;
	//preg_match($regex, $scorestring, $scores);
	//$score3 = $scores[0];
	//if(($score3 < $score && $score3 > 0) || $score==0)
	//	$score = $score3;
	//if($score == 0 || $score == "" || $score == null) $score = "undefined";
	//print "$score<br>";
	//print "$score3<br>";
	
	// create xml string
	//$xmlstring .= "<institution><name>$institution</name><city>$city</city><state>$state</state><score>$score</score></institution>";
	$xmlstring .= "<institution><id>$orgID</id><name>$institution</name><state>$state</state></institution>";
};
$xmlstring .= '</IELTS>';
file_put_contents("USInstitutions.xml", $xmlstring);
print "converting done";
//To close all instances of excel:
$Workbook->Close;
unset($Worksheet);
unset($Workbook);
$excel_app->Workbooks->Close();
$excel_app->Quit();
unset($excel_app);
?>