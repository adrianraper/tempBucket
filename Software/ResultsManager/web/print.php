<?php
include('../../Common/simplehtmldom/simple_html_dom.php');

// Load the file into a string
$html = file_get_html("http://dock.projectbench/Content/RoadToIELTS2/reading/exercises/1156153794672.xml");


foreach($html->find('head') as $e) {
	$e->onload = "window.print()";
}

foreach($html->find('body') as $e) {
	$e->onload = "window.print()";
}

// Add a print command to the window loader