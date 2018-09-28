<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */
require_once(dirname(__FILE__) . "/ClarityService.php");
require_once(dirname(__FILE__) . "../../core/shared/util/Authenticate.php");

$thisService = new ClarityService();

const MAX_EXECUTION_TIME = 300;
ini_set('max_execution_time', MAX_EXECUTION_TIME);
set_time_limit(MAX_EXECUTION_TIME);

// Initialize variables
$errorCode = 0;
$failReason = '';
$rc = array();

/*
if (!Authenticate::isAuthenticated()) {
    $rc['error'] = 301;
    $rc['message'] = 'You are not authorised to get this user data.';
    print json_encode($rc);
    exit(0);
}
*/

$template = (isset($_REQUEST['template'])) ? json_decode($_REQUEST['template']) : null;
$groupIdArray = (isset($_REQUEST['groupIdArray'])) ? json_decode($_REQUEST['groupIdArray']) : array();
$selectedEmailArray = (isset($_REQUEST['selectedEmailArray'])) ? json_decode($_REQUEST['selectedEmailArray']) : array();
$previewIndex = isset($_REQUEST['previewIndex']) ? $_REQUEST['previewIndex'] : 0;
$emailInsertion = isset($_REQUEST['emailInsertion']) ? json_decode($_REQUEST['emailInsertion']) : '';
$send = isset($_REQUEST['send']) && $_REQUEST['send'] == "true";
$queryMethod = (isset($_REQUEST['method'])) ? $_REQUEST['method'] : null;
/**
 * This for testing and debugging emails
 */
/*
$template = json_decode('{
	"description": null,
	"title": null,
	"name": "invitation",
	"data": {
		"administrator": {
			"email": "twaddle@email",
			"name": "Mrs Twaddle"
		},
		"test": {
			"closeTime": "2018-12-31 00:00:00",
			"startType": "timer",
			"productCode": "63",
			"openTime": "2017-01-17 00:00:00",
			"parent": null,
			"children": null,
			"id": "1011",
			"testId": "1011",
			"showResult": false,
			"startData": null,
			"groupId": "35026",
			"status": 2,
			"caption": "Funny in Chinese",
			"language": "EN",
			"menuFilename": "menu.json.hbs",
			"uid": "1011",
			"reportableLabel": "Funny in Chinese"
		}
	},
	"templateID": null,
	"filename": "user/DPT-welcome"
}');
$groupIdArray = json_decode('["21560"]');
$previewIndex = 0;
$queryMethod = json_decode('"getTemplate"');
*/
if (!isset($template->data)) {
    $rc = array();
    $rc['error']=400;
    $rc['message']='No data was passed to the email template.';
    print json_encode($rc);
    exit();
}
if (!isset($groupIdArray[0])) {
    $rc = array();
    $rc['error']=400;
    $rc['message']='No groups passed for users.';
    print json_encode($rc);
    exit();
}

// Get the users from the group and their email addresses
$userEmailArray = $thisService->dailyJobOps->getEmailsForGroup($groupIdArray, $template);
// m#92 Is this the account admin or the person sending the email?
$administratorEmail = (isset($template->data->administrator->email)) ? $template->data->administrator->email : 'support@clarityenglish.com';
$administratorName = (isset($template->data->administrator->name)) ? $template->data->administrator->name : null;

// Filter the users based on the selected array if it exists
if (count($selectedEmailArray) > 0) {
    // convert selected indexes to keyed array
    $keyedEmails = array();
    foreach ($selectedEmailArray as $selectedEmail) {
        $keyedEmails[$selectedEmail] = true;
    }
    $userEmailArray = array_intersect_key($userEmailArray, $keyedEmails);
}

// Note that the above does not reindex the array, so you might just have $userEmailArray[3] and $userEmailArray[31] set.
$firstValue = reset($userEmailArray);

// ctp#346 Add the test administrator to this list of email recipients for copy
// m#92 The person sending the emails will get a summary of the action
$summaryEmail = array();
$summaryEmail['to'] = $administratorEmail;
$summaryEmail['data'] = $firstValue['data'];
$summaryEmail['data']['user'] = new User();
$summaryEmail['data']['user']->name = $administratorName;
$summaryEmail['data']['user']->email = $administratorEmail;
$summaryEmail['data']['templateData']->numberScheduled = count($userEmailArray);
$emailList = '';
foreach ($userEmailArray as $userEmail) {
    $emailList .= $userEmail['data']['user']->email."<br/>";
};
$summaryEmail['data']['templateData']->emailsScheduled = $emailList;

// Get the email from the template and insert the selected user's details into it
if ($queryMethod == "getTemplate") {
    // If you passed some data that the admin wants added into the email, include it in the template data
    if ($emailInsertion)
        $template->data->emailDetails = $emailInsertion;
    $emailContents = $thisService->emailOps->fetchEmail($template->filename, $firstValue['data']);
    $rc['emailContents'] = $emailContents;
}

// If required, actually send the email to test takers and the summary to the administrator
if ($send) {
    $results = $thisService->emailOps->sendEmails("", $template->filename, $userEmailArray);
    $rc = $thisService->emailOps->sendEmails("", 'summaries/dptScheduleSummary', array($summaryEmail));
}

$rc['error'] = $errorCode;
$rc['message'] = $failReason;
print json_encode($rc);
exit();
