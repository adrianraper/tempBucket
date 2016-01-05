<?php
require_once('encryptURL.php');

// To get from moodle page
$studentID = 's021201';
$teacherID = null;
$unitName = 'Am is are';
// Fixed for Creative Secondary School
$rootID = 24568;
$prefix = 'CSS';

$crypt = new Crypt();
$parameters = 'rootID='.$rootID.'&prefix='.$prefix.'&studentID='.$studentID.'&teacherID='.$teacherID.'&unitName='.$unitName;
$startProgram = "?data=".$crypt->encodeSafeChars($crypt->encrypt($parameters));

$programBase = 'http://dock.projectbench/Software/ResultsManager/web/amfphp/services/GenerateCoverageReport.php';

$urlLink = $programBase.$startProgram;
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
    <title>A mock moodle page</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="language" content="en" />
    <style type="text/css">
        body {margin-left: 0px; margin-top: 0px; margin-right: 0px; margin-bottom: 0px}
    </style>
</head>
<body>
Please <a href="<?php echo $urlLink;?>">click here</a> to see progress for <?php echo $studentID;?> in <?php echo $unitName;?>
</body>
</html>
