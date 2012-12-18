<?php
$menuXMLFile = 'http://dock.contentbench/Content/RoadToIELTS2-International/menu-GeneralTraining-.xml';
		if (stristr($menuXMLFile, '-.xml')) {
			$menuXMLFile = preg_replace('/(\w+)-\.xml/i', '$1-FullVersion.xml', $menuXMLFile);
		}

		echo $menuXMLFile;
flush();
exit();
