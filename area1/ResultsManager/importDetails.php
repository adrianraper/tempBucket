<?php
    if (isset($_GET['session']))
        session_id($_GET['session']);
    session_start();
    include_once "variables.php";

    // TODO It would be better to make this a javascript file uploader and then ajax to php 1000 records at a time

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr">
<head>
<title>Clarity's Results Manager bulk import</title>
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
<link rel="stylesheet" href="css/common.css" type="text/css" />

<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
</head>

<body>
    <h1>This is the Results Manager bulk importer.</h1>
    <form enctype="multipart/form-data" action="<?php echo $thisDomain."Software/ResultsManager/web/amfphp/services/BulkImportService.php?session=" . session_id(); ?>" method="POST">
        <input type="radio" name="duplicateOption" value="move" checked>move<br>
        <input type="radio" name="duplicateOption" value="copy">copy<br>
        <input type="radio" name="duplicateOption" value="block">block<br>
        <!-- MAX_FILE_SIZE must precede the file input field -->

        <input type="hidden" name="MAX_FILE_SIZE" value="2000000" />
        Choose data source: <input type="file" name="rawDataFile"  />
        <br/><br/>
        <input type="submit" value="Load data" />
    </form>
    <h1>Rules</h1>
    <p>The file should be comma or tab delimited text file.</p>
    <p>The first record should be header with columns for name, id, email, password, group.</p>
    <p>You only need one of name / id / email.</p>
    <p>If no group, then all will be placed in top level.</p>
    <p>Sort by group, and the group should NOT be in the first column.</p>

</body>
</html>
