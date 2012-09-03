<?php
	$newURL = "http://p1.clarityenglish.com/area1/AuthorPlus/Author.php?".$_SERVER['QUERY_STRING'];
	//echo $newURL;
	header('Location: ' . $newURL);
	flush();
	exit();
