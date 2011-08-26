<?php
// Here I add accounts to a root
// Add iRead as a new title with a mix of default settings and some taken from the first content title
$RMtitle = new Title();
$RMtitle->productCode = 47;
$RMtitle->maxStudents = 9999;
$RMtitle->maxAuthors = 0;
$RMtitle->maxReporters = 0;
$RMtitle->maxTeachers = 0;
$RMtitle->contentLocation = null;
$RMtitle->expiryDate = $account->titles[0]->expiryDate;
$RMtitle->licenceStartDate = $account->titles[0]->licenceStartDate;
$RMtitle->licenceType = $account->titles[0]->licenceType;
$RMtitle->languageCode = 'EN';
$account->titles[] = $RMtitle;
// and add IYJ
$RMtitle1 = new Title();
$RMtitle1->productCode = 38;
$RMtitle1->maxStudents = 9999;
$RMtitle1->maxAuthors = 0;
$RMtitle1->maxReporters = 0;
$RMtitle1->maxTeachers = 0;
$RMtitle1->contentLocation = null;
$RMtitle1->expiryDate = $account->titles[0]->expiryDate;
$RMtitle1->licenceStartDate = $account->titles[0]->licenceStartDate;
$RMtitle1->licenceType = $account->titles[0]->licenceType;
$RMtitle1->languageCode = 'EN';
$account->titles[] = $RMtitle1;
// and add IYJ
$RMtitle2 = new Title();
$RMtitle2->productCode = 1001;
$RMtitle2->maxStudents = 9999;
$RMtitle2->maxAuthors = 0;
$RMtitle2->maxReporters = 0;
$RMtitle2->maxTeachers = 0;
$RMtitle2->contentLocation = null;
$RMtitle2->expiryDate = $account->titles[0]->expiryDate;
$RMtitle2->licenceStartDate = $account->titles[0]->licenceStartDate;
$RMtitle2->licenceType = $account->titles[0]->licenceType;
$RMtitle2->languageCode = 'EN';
$account->titles[] = $RMtitle2;

// I don't understand why, but if I don't set this session variable I get a warning
Session::set('rootID', $account->id);

// This does far more than we really need - but is easy to call.
$accounts = $dmsService-> updateAccounts(array($account));

/*
// Here I want to add Results Manager to any active, institutional account that doesn't have it
$hasRM = false;
foreach ($account->titles as $title) {
	if ($title-> productCode == 2) {
		$hasRM = true;
		break;
	}
}
if (!$hasRM) {
	echo "add RM for $account->name, $account->prefix<br/>";
	// Add RM as a new title with a mix of default settings and some taken from the first content title
	$RMtitle = new Title();
	$RMtitle->productCode = 2;
	$RMtitle->maxStudents = 0;
	$RMtitle->maxAuthors = 0;
	$RMtitle->maxReporters = 0;
	$RMtitle->maxTeachers = 1;
	$RMtitle->contentLocation = null;
	$RMtitle->expiryDate = $account->titles[0]->expiryDate;
	$RMtitle->licenceStartDate = $account->titles[0]->licenceStartDate;
	$RMtitle->licenceType = $account->titles[0]->licenceType;
	$RMtitle->languageCode = 'EN';
	$account->titles[] = $RMtitle;
	
	// I don't understand why, but if I don't set this session variable I get a warning
	Session::set('rootID', $account->id);
	
	// This does far more than we really need - but is easy to call.
	$accounts = $dmsService->updateAccounts(array($account));
}
*/
?>