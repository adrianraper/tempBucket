<?php 
//2013 Mar 5 Vivying added 
//if it is resizing flag, disable the scollbar enabling in CSS by removing the div id
if (isset($_GET['resize']) || $resize) {
	echo '<div id="">';
} else {
//otherwise this id in CSS will enable the scrollbar
	echo '<div id="load_program_original">';
}
