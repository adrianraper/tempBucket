<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */
require_once(dirname(__FILE__)."/DMSService.php");
ini_set('max_execution_time', 300); // 5 minutes
$service = new DMSService();

$newLine = "<br/>";

// check there are no errors
if($_FILES['csv']['error'] == 0) {
    $name = $_FILES['csv']['name'];
    $ext = strtolower(end(explode('.', $_FILES['csv']['name'])));
    $type = $_FILES['csv']['type'];
    $tmpName = $_FILES['csv']['tmp_name'];
    $csvArray = array_map('str_getcsv', file($tmpName));
    $userArray = array();
    foreach ($csvArray as $object) {
        $userObject = array();
        $userObject['name'] = $object[0];
        $userObject['studentID'] = $object[1];
        $userObject['password'] = $object[2];
        $userArray[] = $userObject;
    }
}

// Sort the array by group
Session::set('rootID',21974);
Session::set('loginOption',User::LOGIN_BY_ID);
$groupID = '54253';
$parentGroup = $service->manageableOps->getGroup($groupID);
echo('parent group is '.$parentGroup->name.$newLine);
$controlExistingStudents = ManageableOps::EXCEL_MOVE_IMPORT;
$mergeGroups = false;

// Add each user to the group
foreach ($userArray as $user) {
    $manageable = User::createFromArray($user);
    echo($manageable->name.' | '.$manageable->studentID.' | '.$manageable->password.$newLine);
    $rc = $service->manageableOps->_importManageable($manageable, $parentGroup, $mergeGroups, $controlExistingStudents);
    if ($rc) {
        AbstractService::$debugLog->notice($user['name']." imported ok");
    } else {
        AbstractService::$debugLog->notice($user['name']." failed to import");
    }
}