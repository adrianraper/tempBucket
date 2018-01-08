<?php
/*
 * This script is run by the cronjob on a daily basis, but triggers occasional events
 */

/*
 * Occasional jobs include
 *   averaging scores per country
 *   adding already used licence slots when you move to Couloir
 */


require_once(dirname(__FILE__) . "/MinimalService.php");
require_once(dirname(__FILE__) . "../../core/shared/util/Authenticate.php");

// Don't get fooled by old session variables
if (isset($_SESSION['dbHost'])) unset($_SESSION['dbHost']);
if (isset($_REQUEST['dbHost'])) $_SESSION['dbHost'] = $_REQUEST['dbHost'];

$thisService = new MinimalService();

const MAX_EXECUTION_TIME = 3600;
ini_set('max_execution_time', MAX_EXECUTION_TIME);
set_time_limit(MAX_EXECUTION_TIME);

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
}

function runOccasionalJobs($period) {
    global $thisService;
    global $newLine;
    $takeAction = (isset($_GET['action'])) ? ($_GET['action'] === 'true') : false;

    switch ($period) {
        case 'yearly':
        case 'weekly':
            break;
        case 'oneoff':
        case 'monthly':
            /*
             * This averages all scores for a title in all countries and populates T_ScoreCache
            $productCodes = array(52,53);
            $from = new DateTime();
            // The default is to take the last year's data
            $fromDate = $from->sub(new DateInterval('P1Y'))->format('Y-m-d');
            $toDate = null;
            $rc = $thisService->dailyJobOps->averageCountryScores($productCodes, $fromDate, $toDate);
            $now = new DateTime();
            $today = $now->format('Y-m-d');
            echo "Added average scores to the cache $today $rc $newLine";
             */
            /*
             * This adds a licence to T_LicenceHolders based on existing records in T_Session
             * gh#1230
             */
            /*
            // Loop round active accounts in them, ignore individuals as they never extend beyond a year
            $conditions['active'] = true;
            $conditions['individuals'] = false;
            $conditions['productCode'] = 61;
            $testingAccounts = array();
            //$testingAccounts = array(10497,13244,13326,13516,13735,13931,14472,14565,14588,18897,20489,24793,26098,27993,32366,35356,36348,37278,39422,42327,42659,42979,43076,43250,44125,44909,45529,46676,47984,48220);
            $testingAccounts = array(22732);
            $blockedRoots = array(100,101,167,168,169,170,171,14030,14024,14031);
            $bigRoots = array(13754,13865,14223,14302,14374,19855,33662,35886,37999,43873);
            //$bigRoots = array();
            $accounts = $thisService->accountOps->getAccounts($testingAccounts, $conditions);
            $rootIdRange = false;
            //$rootIdRange = array(1000,20000);

            if (!$takeAction) {
                // Do a check of existing licence count
                foreach ($accounts as $account) {
                    // Are there some accounts which we might as well block?
                    // LM, TD, all IP.com
                    if ($rootIdRange && isset($rootIdRange[1]) && (($account->id < $rootIdRange[0]) || ($account->id > $rootIdRange[1])))
                        continue;
                    if (in_array($account->id, $blockedRoots))
                        continue;
                    if (in_array($account->id, $bigRoots))
                        continue;

                    foreach ($account->titles as $title) {
                        // Ignore tests (at some point they will have a licence type = test
                        if (in_array($title->productCode, array(36, 63, 64, 65)))
                            continue;

                        $licence = new Licence();
                        $licence->fromDatabaseObj($title);
                        if (($licence->licenceType == Title::LICENCE_TYPE_TT) || ($licence->licenceType == Title::LICENCE_TYPE_LT)) {
                            $oldStyleCount = $thisService->licenceOps->countUsedOldStyleLicences($account->id, $title->productCode, $licence);
                            $newStyleCount = $thisService->licenceOps->countUsedLicences($account->id, $title->productCode, $licence);
                            $newStyleTotal = $thisService->licenceOps->countTotalLicences($account->id, $title->productCode, $licence);
                            if ($oldStyleCount > 0 || $newStyleCount > 0 || $newStyleTotal > 0)
                                echo $account->id . "&nbsp;&nbsp;&nbsp;&nbsp;" . $title->productCode . "&nbsp;&nbsp;&nbsp;&nbsp;" . $oldStyleCount . "&nbsp;&nbsp;&nbsp;&nbsp;" . $newStyleCount . "&nbsp;&nbsp;&nbsp;&nbsp;" . $newStyleTotal . "$newLine";
                        }
                    }
                }
            } else {
                foreach ($accounts as $account) {
                    // Are there some accounts which we might as well block?
                    // LM, TD, all IP.com
                    if ($rootIdRange && isset($rootIdRange[1]) && (($account->id < $rootIdRange[0]) || ($account->id > $rootIdRange[1])))
                        continue;
                    if (in_array($account->id, $blockedRoots))
                        continue;
                    if (in_array($account->id, $bigRoots))
                        continue;

                    // Get all users for this root
                    //$users = $thisService->manageableOps->getUsersFromAccount($account);
                    // What about the big ones like SciencesPo - pull them out of the loop and do separately?
                    //if (count($users) > 1000) {
                    //    echo "BIG root " . $account->id . " has " . count($users) . " users so remove it$newLine";
                    //    continue;
                    //}

                    //echo "Root " . $account->id . " has " . count($users) . " users$newLine";
                    foreach ($account->titles as $title) {
                        // Ignore tests (at some point they will have a licence type = test
                        if (in_array($title->productCode, array(36, 63, 64, 65)))
                            continue;

                        $licence = new Licence();
                        $licence->fromDatabaseObj($title);

                        // You could do a check to see to jump out if none of the users have used this title...
                        //$timesTitleUsed = $thisService->licenceOps->countTimesTitleUsed($account->id, $title->productCode);
                        //if ($timesTitleUsed == 0)
                        //    continue;

                        // Read all the earliest session records for this title (current licence method)
                        $counter = 0;
                        $sessionRecords = $thisService->licenceOps->checkEarliestOldStyleLicences($account->id, $title->productCode);
                        if ($sessionRecords) {
                            foreach ($sessionRecords as $session) {
                                $userId = $session['userId'];
                                $earliestDate = $session['earliestDate'];
                                echo "userId " . $userId . " earliest date $earliestDate $newLine";
                                if ($earliestDate) {
                                    $rc = $thisService->dailyJobOps->createNewStyleLicence($userId, $account->id, $title->productCode, $licence, $earliestDate);
                                    if ($rc)
                                        $counter++;
                                }
                            }
                        }

                        // This loop is for users who are STILL in RM. What about those who have been deleted yet
                        // have used up licences?? I should be reading the T_Session table and ignoring T_User
                        //foreach ($users as $user) {
                        //    $userId = $user['userID'];
                        //    $earliestDate = $thisService->licenceOps->checkEarliestOldStyleLicence($userId, $title->productCode);
                        //    echo "userId ".$userId." earliest date $earliestDate $newLine";
                        //    if ($earliestDate) {
                        //        $rc = $thisService->dailyJobOps->createNewStyleLicence($userId, $account->id, $title->productCode, $licence, $earliestDate);
                        //        echo "new licence is ".$rc."$newLine";
                        //        if ($rc)
                        //            $counter++;
                        //    }
                        //}
                        echo "&nbsp;&nbsp;&nbsp;&nbsp;Added $counter licences for " . $title->name . " in root " . $account->id . " to T_LicenceHolders$newLine";
                    }
                }
            }
            */
            /*
             * This adds a licence to T_CouloirLicenceHolders based on existing sss records in T_Session
             * sss#314
             */
            /*
            // Loop round active accounts in them, ignore individuals as they will not upgrade mid term
            $conditions['active'] = true;
            $conditions['individuals'] = false;
            $conditions['productCode'] = 49;
            $newProductCode = 66;
            $testingAccounts = array();
            //$testingAccounts = array(14030,24691,35886,163);
            $testingAccounts = array(163);
            $blockedRoots = array(100, 101, 167, 168, 169, 170, 171, 14030, 14024, 14031);
            $bigRoots = array(13754, 13865, 14223, 14302, 14374, 19855, 33662, 35886, 37999);
            //$bigRoots = array();
            $accounts = $thisService->accountOps->getAccounts($testingAccounts, $conditions);
            $rootIdRange = false;
            //$rootIdRange = array(1000,20000);

            // Do a check of existing licence count
            foreach ($accounts as $account) {
                // Are there some accounts which we might as well block?
                // LM, TD, all IP.com
                if ($rootIdRange && isset($rootIdRange[1]) && (($account->id < $rootIdRange[0]) || ($account->id > $rootIdRange[1])))
                    continue;
                if (in_array($account->id, $blockedRoots))
                    continue;
                if (in_array($account->id, $bigRoots))
                    continue;

                foreach ($account->titles as $title) {
                    $licence = new Licence();
                    $licence->fromDatabaseObj($title);

                    if (!$takeAction) {
                        if (($licence->licenceType == Title::LICENCE_TYPE_TT) || ($licence->licenceType == Title::LICENCE_TYPE_LT)) {
                            $oldStyleCount = $thisService->licenceOps->countUsedOldStyleLicences($account->id, $title->productCode, $licence);
                            $newStyleCount = $thisService->licenceOps->countUsedLicences($account->id, $newProductCode, $licence);
                            $newStyleTotal = $thisService->licenceOps->countTotalLicences($account->id, $newProductCode, $licence);
                            //if ($oldStyleCount > 0 || $newStyleCount > 0 || $newStyleTotal > 0)
                                echo "root " . $account->id . "&nbsp;&nbsp;&nbsp;&nbsp;pc=" . $title->productCode . "&nbsp;&nbsp;&nbsp;&nbsp;existing=" . $oldStyleCount . "&nbsp;&nbsp;&nbsp;&nbsp;new current=" . $newStyleCount . "&nbsp;&nbsp;&nbsp;&nbsp;new total=" . $newStyleTotal . "$newLine";
                        }
                    } else {
                        // You could do a check to see to jump out if none of the users have used this title...
                        $timesTitleUsed = $thisService->licenceOps->countTimesTitleUsed($account->id, $title->productCode);
                        if ($timesTitleUsed == 0)
                            continue;

                        // Read all the earliest session records for this title (current licence method)
                        $counter = 0;
                        $sessionRecords = $thisService->licenceOps->checkEarliestOldStyleLicences($account->id, $title->productCode);
                        if ($sessionRecords) {
                            foreach ($sessionRecords as $session) {
                                $userId = $session['userId'];
                                $earliestDate = $session['earliestDate'];
                                echo "userId " . $userId . " earliest date $earliestDate $newLine";
                                if ($earliestDate) {
                                    $rc = $thisService->dailyJobOps->createCouloirLicence($userId, $account->id, $newProductCode, $licence, $earliestDate);
                                    if ($rc)
                                        $counter++;
                                }
                            }
                        }

                        echo "&nbsp;&nbsp;&nbsp;&nbsp;Added $counter licences for " . $title->name . " in root " . $account->id . " to T_CouloirLicenceHolders$newLine";
                    }
                }
            }
            */
        // 9. Remove duplicates from T_LicenceHolders (#1577)
        $conditions['active'] = true;
        $conditions['individuals'] = false;
        //$conditions['productCode'] = 61;
        $testingAccounts = array();
        $bigRoots = array();
        $blockedRoots = array();
        $testingAccounts = array(168);
        //$blockedRoots = array(100,101,167,168,169,170,171,14030,14024,14031);
        //$bigRoots = array(13754,13865,14223,14302,14374,19855,33662,35886,37999,43873);
        $accounts = $thisService->accountOps->getAccounts($testingAccounts, $conditions);
        $rootIdRange = false;
        //$rootIdRange = array(1000,20000);

        // Do a check of existing licence count
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
            echo "root " . $account->id . " has " . count($duplicatedUsers) ." users with duplicates $newLine";

            // For each, leave the last one since the licence clearance date, remove the rest
            $loopLimit = 0;
            foreach ($duplicatedUsers as $duplicatedUser) {
                if ($loopLimit>500)
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
                    if ($takeAction) {
                        $rc = $thisService->dailyJobOps->removeDuplicateLicenceHolders($duplicatedUser["userId"], $duplicatedUser["productCode"], $licence);
                        echo "Deleted $rc licences for " . $duplicatedUser["userId"] . " for pc " . $duplicatedUser["productCode"] . " in root " . $account->id . "$newLine";
                    } else {
                        $rc = $thisService->dailyJobOps->countDuplicateLicenceHolders($duplicatedUser["userId"], $duplicatedUser["productCode"], $licence);
                        echo "Duplicate $rc licences for " . $duplicatedUser["userId"] . " for pc " . $duplicatedUser["productCode"] . " in root " . $account->id . "$newLine";
                    }
                } else {
                    echo "productCode ".$duplicatedUser["productCode"]." not found in " . $account->id . "$newLine";
                }
            }

        }

        break;
        default:
    }
}

// Action
$oneoff = true;

// If you are running a one-off job, don't trigger the other regular actions
if ($oneoff) {
    // Extra date check to ensure one-off is intentional
    if (date("j") == 9 && date("n") == 1) {
        runOccasionalJobs("oneoff");
    } else {
        echo "Set the date in RunOccasionalJobs to enable one-off run";
    }
} else {
    // Is today the first of the year?
    if (date("j") == 1 && date("n") == 1) {
        runOccasionalJobs("yearly");
    }
    // Is today the first of the month?
    if (date("j") == 1) {
        runOccasionalJobs("monthly");
    }
    // Is today Monday (considered first day of the week by Clarity for everyone - apologies to UAE)
    if (date("w") == 1) {
        runOccasionalJobs("weekly");
    }
}

flush();
exit(0);
