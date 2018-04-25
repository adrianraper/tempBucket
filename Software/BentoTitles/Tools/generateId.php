<?php
/**
 * Created by IntelliJ IDEA.
 * User: Adrian
 * Date: 25-Apr-18
 * Time: 3:08 PM
 */
require_once(dirname(__FILE__)."/vo/com/clarityenglish/Utils/UUID.php");
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>New Couloir item id</title>
    <style>
        body {
            font-family: monospace;
            font-size: 16px;
        }
    </style>
</head>
 <body>
<?php echo UUID::v4(); ?>
 </body>
</html>
