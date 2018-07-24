<?php
/*
 * This script is run by the cronjob on a daily basis.
 */

/*
 * Daily jobs include 
 * archiving expired users from GlobalRoadToIELTS and global_r2iv2 - stopped 18 Dec 2012
 * archiving expired users from rack80829
 * archiving sent emails from T_PendingEmails
 * m#286 REMOVE those jobs whose purpose is to send emails to RunEmailSendingDailyJobs.php
 */

require_once(dirname(__FILE__)."/MinimalService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

// Don't get fooled by old session variables
if (isset($_SESSION['dbHost'])) unset($_SESSION['dbHost']);
if (isset($_REQUEST['dbHost'])) $_SESSION['dbHost']=$_REQUEST['dbHost'];

$thisService = new MinimalService();
set_time_limit(1800); // 30 mins of online processing

date_default_timezone_set('UTC');
if (!Authenticate::isAuthenticated()) {
	// TODO: Replace with text from literals
	// v3.0.6 This script may be run by CRON too, in which case skip authentication. How to tell?
	/*
	if (isset($_SERVER["SERVER_NAME"])) {
		echo "<h2>You are not logged in</h2>";
		exit(0);
	}
	*/
}
// Set up line breaks for whether this is outputting to html page or a text file
if (isset($_SERVER["SERVER_NAME"])) {
	$newLine = '<br/>';
} else {
	$newLine = "\n";
    set_time_limit(3600); // 1 hour of batch processing
}

// NOTE: Sometime convert all away from timestamps to DateTime objects
function addDaysToTimestamp($timestamp, $days) {
	//return date("Y-m-d", $timestamp + ($days * 86400));
	return $timestamp + ($days * 86400);
}

// Maybe I will want to be able to pass an array of triggers to this as well as getting all of them
function runDailyJobs($triggerDate = null) {
	global $thisService;
	global $newLine;
    $database = 'rack80829';

	// Pick up all triggers that are valid on the given date (usually this is going to be today)
	if (!$triggerDate) $triggerDate = time();

    /* m#339 Stop doing this for now
    // 1. Archive expired users for Road to IELTS Last Minute
    $sectionStartTime = new DateTime();

    // Need date as simple Y-m-d
    $expiryDate = date('Y-m-d', $triggerDate);

    // For the Road to IELTS Last Minute accounts in the merged database
    $roots = array(100,101,167,168,169,170,171,14028,14030,14031);
    $usersMoved = $thisService->dailyJobOps->archiveExpiredUsers($expiryDate, $roots, $database);
    echo "1. Archived $usersMoved users $newLine";
    $now = new DateTime();
    echo "== section took " . ($sectionStartTime->diff($now)->format('%s')) . "s$newLine";
    */
	/* m#339 Stop doing this for now
	// 2. Archive expired titles from accounts
    $sectionStartTime = new DateTime();

	// We want to archive 1 month after expiry, so send in 1 month ago as the date
	$expiryDate = date('Y-m-d', addDaysToTimestamp($triggerDate, -31));
	$accountsMoved = $thisService->dailyJobOps->archiveExpiredAccounts($expiryDate, $database);
	echo "2. Archived $accountsMoved titles on $expiryDate $newLine";
    $now = new DateTime();
    echo "== section took " . ($sectionStartTime->diff($now)->format('%s')) . "s$newLine";
	*/
	/* m#339 Stop doing this for now
	// 3. Archive older users from some roots
    $sectionStartTime = new DateTime();

	// We want to archive users who took their test more than 3 months ago from LearnEnglish accounts
	$regDate = date('Y-m-d', addDaysToTimestamp($triggerDate, -92));
	$roots = array(13982,14084,16180,14987);
	$rc = $thisService->dailyJobOps->archiveOldUsers($roots,$regDate);
	echo "3. Archived $rc LearnEnglish level test users who registered before $regDate. $newLine";
    $now = new DateTime();
    echo "== section took " . ($sectionStartTime->diff($now)->format('%s')) . "s$newLine";
	*/
	
	/* m#339 Stop doing this for now
	// 5. Archive sent emails
    $sectionStartTime = new DateTime();
	// Clean up the T_PendingEmails, remove everything that has been sent
	$rc = $thisService->dailyJobOps->archiveSentEmails($database);
	echo "5. Archived $rc sent emails. $newLine";
    $now = new DateTime();
    echo "== section took " . ($sectionStartTime->diff($now)->format('%s')) . "s$newLine";
    */
	// Then every so often clear out the T_SentEmails table - currently to an archive table
    /*
        INSERT INTO T_SentEmails_Archive
			SELECT * FROM T_SentEmails
			WHERE F_SentTimestamp < '2017-06-01';
        DELETE FROM T_SentEmails
			WHERE F_SentTimestamp < '2017-06-01';
    */

    // 8. Archive expired licences
    $sectionStartTime = new DateTime();
    // Clean up the T_LicenceHolders, remove licences that have expired + T_CouloirLicenceHolders
    $expiryDate = new DateTime('@'.$triggerDate);
    $rc = $thisService->dailyJobOps->archiveExpiredLicences($expiryDate->format('Y-m-d'), $database);
    echo "8. Archived $rc licences. $newLine";
    $now = new DateTime();
    echo "== section took " . ($sectionStartTime->diff($now)->format('%s')) . "s$newLine";

	// 9. Remove duplicates from T_LicenceHolders (#1577)
    $sectionStartTime = new DateTime();
    $conditions['active'] = true;
    $conditions['individuals'] = false;
    $testingAccounts = array();
    $bigRoots = array();
    $blockedRoots = array();
    $rootIdRange = false;
    //$testingAccounts = array(168);
    //$blockedRoots = array(100,101,167,168,169,170,171,14030,14024,14031);
    //$bigRoots = array(13754,13865,14223,14302,14374,19855,33662,35886,37999,43873);
    //$rootIdRange = array(1000,20000);
    $accounts = $thisService->accountOps->getAccounts($testingAccounts, $conditions);

    // Do a check of existing licence count
    $countDuplicates = 0;
    foreach ($accounts as $account) {
        // Are there some accounts which we might as well block?
        // LM, TD, all IP.com
        if ($rootIdRange && isset($rootIdRange[1]) && (($account->id < $rootIdRange[0]) || ($account->id > $rootIdRange[1])))
            continue;
        if (in_array($account->id, $blockedRoots))
            continue;
        if (in_array($account->id, $bigRoots))
            continue;

        // Any users with duplicates?
        $duplicatedUsers = $thisService->dailyJobOps->findDuplicateLicenceHolders($account->id);
        //echo "root " . $account->id . " has " . count($duplicatedUsers) ." users with duplicates $newLine";
        $countDuplicates += count($duplicatedUsers);

        // For each, leave the last one since the licence clearance date, remove the rest
        $loopLimit = 0;
        foreach ($duplicatedUsers as $duplicatedUser) {
            if ($loopLimit>1000)
                break;
            $loopLimit++;
            $licence = null;
            foreach ($account->titles as $title) {
                if ($title->productCode == $duplicatedUser["productCode"]) {
                    $licence = new Licence();
                    $licence->fromDatabaseObj($title);
                    break;
                }
            }
            if ($licence) {
                if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
                    $rc = $thisService->dailyJobOps->removeDuplicateLicenceHolders($duplicatedUser["userId"], $duplicatedUser["productCode"], $licence);
                    //echo "Deleted $rc licences for " . $duplicatedUser["userId"] . " for pc " . $duplicatedUser["productCode"] . " in root " . $account->id . "$newLine";
                } else {
                    $rc = $thisService->dailyJobOps->countDuplicateLicenceHolders($duplicatedUser["userId"], $duplicatedUser["productCode"], $licence);
                    echo "Duplicate $rc licences for " . $duplicatedUser["userId"] . " for pc " . $duplicatedUser["productCode"] . " in root " . $account->id . "$newLine";
                }
            } else {
                echo "productCode ".$duplicatedUser["productCode"]." not found in " . $account->id . "$newLine";
            }
        }
    }
    echo "9. ".$countDuplicates." users had duplicated licences $newLine";
    $now = new DateTime();
    echo "== section took " . ($sectionStartTime->diff($now)->format('%s')) . "s$newLine";
}

// Action
$now = new DateTime();
echo "script started at " . $now->format("Y-m-d H:i:s") . "$newLine";
if (isset($_REQUEST['date'])) {
	runDailyJobs(addDaysToTimestamp(time(), intval($_REQUEST['date']))); // 1=tomorrow, -1=yesterday
} else {
	runDailyJobs();
}
$now = new DateTime();
echo "script ended at ... " . $now->format("H:i:s") . "$newLine";
flush();
exit(0);
