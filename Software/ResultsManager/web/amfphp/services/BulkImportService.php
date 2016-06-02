<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */

if (isset($_GET['session']))
    session_id($_GET['session']);

require_once(dirname(__FILE__)."/ClarityService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

$thisService = new ClarityService();
set_time_limit(600);  // 10 minutes

/*
if (!Authenticate::isAuthenticated()) {
	echo "<h2>You are not logged in</h2>";
	exit(0);
}
*/

class UploadException extends Exception {

    public function __construct($code) {
        $message = $this->codeToMessage($code);
        parent::__construct($message, $code);
    }

    private function codeToMessage($code) {
        switch ($code) {
            case UPLOAD_ERR_INI_SIZE:
                $message = "The uploaded file exceeds the upload_max_filesize directive in php.ini";
                break;
            case UPLOAD_ERR_FORM_SIZE:
                $message = "The uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the HTML form";
                break;
            case UPLOAD_ERR_PARTIAL:
                $message = "The uploaded file was only partially uploaded";
                break;
            case UPLOAD_ERR_NO_FILE:
                $message = "No file was uploaded";
                break;
            case UPLOAD_ERR_NO_TMP_DIR:
                $message = "Missing a temporary folder";
                break;
            case UPLOAD_ERR_CANT_WRITE:
                $message = "Failed to write file to disk";
                break;
            case UPLOAD_ERR_EXTENSION:
                $message = "File upload stopped by extension";
                break;

            default:
                $message = "Unknown upload error ".$code;
                break;
        }
        return $message;
    }
}

    // Initialisation
    $debug = false;
    if ($debug) {
        $userID = 12192;
        $loginOption = User::LOGIN_BY_ID;
        $rootID = 10719;
        Session::set('groupIDs', array(10719));
        Session::set('valid_groupIDs', array(10719));
    } else {
        $userID = Session::get('userID');
        $loginOption = Session::get('loginOption');
        $rootID = Session::get('rootID');
    }

    try {

        // Check the file upload
        if ($debug) {
            $uploadfile = dirname(__FILE__) . "/../../../../Common/uploads/Testing1.txt";
            $duplicateOption = ManageableOps::EXCEL_MOVE_IMPORT;
        } else {
            $uploadfile = dirname(__FILE__) . "/../../../../Common/uploads/" . basename($_FILES['rawDataFile']['name']);
            switch ($_POST['duplicateOption']) {
                case 'block':
                    $duplicateOption = ManageableOps::EXCEL_IMPORT;
                    break;
                case 'copy':
                    $duplicateOption = ManageableOps::EXCEL_COPY_IMPORT;
                    break;
                default:
                    $duplicateOption = ManageableOps::EXCEL_MOVE_IMPORT;
                    break;
            }
        }

        if (!$debug) {
            if ($_FILES['rawDataFile']['error'] === UPLOAD_ERR_OK) {
                // TODO Before you move, do some file checking
                // is file empty
                // is the name valid
                // is the name not too long
                // is it just csv/txt
                if (!move_uploaded_file($_FILES['rawDataFile']['tmp_name'], $uploadfile))
                    throw new Exception("Possible file upload attack on " . $uploadfile);
            } else {
                throw new UploadException($_FILES['rawDataFile']['error']);
            }
        }

        // Read the data
        if (($handle = fopen($uploadfile, 'r')) !== FALSE) {
            // Read header record from file
            // First see what the delimiter is - assume it will be tabs or commas
            if (($line = fgets($handle)) !== false)
                $delimiter = (strpos($line, "\t") > 0) ? "\t" : ',';
            rewind($handle);
            $firstRow = fgetcsv($handle, 1000, $delimiter);
            //$col_count = count($firstRow);
            foreach ($firstRow as $field => $value) {
                switch (strtolower($value)) {
                    case "group":
                    case "class":
                        $groupCol = $field;
                        break;
                    case "username":
                    case "name":
                        $nameCol = $field;
                        break;
                    case "id":
                    case "studentid":
                        $idCol = $field;
                        break;
                    case "email":
                    case "e-mail":
                        $emailCol = $field;
                        break;
                    case "password":
                        $passwordCol = $field;
                        break;
                }
            }

            // Check that the loginOption is a field in the table
            if (($loginOption == User::LOGIN_BY_NAME && !isset($nameCol)) ||
                ($loginOption == User::LOGIN_BY_EMAIL && !isset($emailCol)) ||
                ($loginOption == User::LOGIN_BY_ID && !isset($idCol)))
                throw new Exception("The file doesn't contain the login option $loginOption");

            // If there is no group information, pack the users in a default group
            $groups = array();
            $recordCount = 0;
            while (($data = fgetcsv($handle, 1000, $delimiter)) !== FALSE) {

                // check against blank lines
                if ($data === array(null))
                    continue;
                $dataInRow = false;
                foreach ($data as $field) {
                    if ($field !== '') {
                        $dataInRow = true;
                        continue;
                    }
                }
                if (!$dataInRow)
                    continue;

                $user = array();
                // This saves empty string if there is no data in a column
                $user['name'] = (isset($nameCol)) ? $data[$nameCol] : null;
                $user['id'] = (isset($idCol)) ? $data[$idCol] : null;
                $user['email'] = (isset($emailCol)) ? $data[$emailCol] : null;
                $user['password'] = (isset($passwordCol)) ? $data[$passwordCol] : null;

                // If the key id is blank, you can't import this user
                switch ($loginOption) {
                    case User::LOGIN_BY_ID:
                        if (empty($user['id']))
                            continue 2;
                        break;
                    case User::LOGIN_BY_EMAIL:
                        if (empty($user['email']))
                            continue 2;
                        break;
                    case User::LOGIN_BY_NAME:
                        if (empty($user['name']))
                            continue 2;
                        break;
                    default:
                }

                // Which group is this user in?
                if (isset($groupCol) && $data[$groupCol] !== '') {
                    $groupName = $data[$groupCol];
                    // is it a new group?
                    if (!isset($groups[$groupName]))
                        $groups[$groupName] = array();
                } else {

                    echo " - no group for $data<br/>";
                    $groupName = 0;
                }

                // Add this user to the current group users array
                $groups[$groupName][] = $user;

                $recordCount++;
            }
            fclose($handle);
            echo "file had $recordCount records and will use $loginOption as key field<br/>";
        }

        // Quick summary for debugging
        foreach ($groups as $groupName => $users) {
            echo "group $groupName has " . count($users) . " users<br/>";
        }

        $allGroups = $thisService->manageableOps->getAllManageables(true);
        $parentGroup = $allGroups[0];

        // Work on each group in turn
        foreach ($groups as $groupName => $users) {
            $stubGroup = new Group();
            $stubGroup->name = $groupName;

            // Make sure the group exists
            $thisGroup = $thisService->manageableOps->addGroup($stubGroup, $parentGroup, false);

            // Build a list of the key ids for each student
            $idArray = array();
            foreach ($users as $user) {
                switch ($loginOption) {
                    case User::LOGIN_BY_ID:
                        if (isset($user['id']))
                            $idArray[] = "'" . $user['id'] . "'";
                        $checkClause = "u.F_StudentID";
                        break;
                    case User::LOGIN_BY_EMAIL:
                        if (isset($user['email']))
                            $idArray[] = $user['email'];
                        $checkClause = "u.F_Email";
                        break;
                    case User::LOGIN_BY_NAME:
                        if (isset($user['name']))
                            $idArray[] = $user['name'];
                        $checkClause = "u.F_UserName";
                        break;
                    default:
                }
            }
            $idList = implode(',', $idArray);

            // Get existing student details for this list
            $sql = <<<EOD
                SELECT u.*, m.F_GroupID, g.F_GroupName as groupName
                FROM T_User u, T_Membership m, T_Groupstructure g
                WHERE u.F_UserID = m.F_UserID
                AND m.F_GroupID = g.F_GroupID
                AND $checkClause in ($idList)
                AND m.F_RootID = ?
EOD;
            $bindingParams = array($rootID);
            $rs = $thisService->db->Execute($sql, $bindingParams);
            $records = $rs->GetArray();

            echo "try to  import " . count($users) . " students to group " . $groupName . "<br/>";

            // Go through the returned recordset comparing against the import list
            // NOTE: Does it matter that you might get two records for a student in two groups? I think it doesn't
            $newUsers = array();
            foreach ($users as $user) {
                $thisId = $user['id'];
                AbstractService::$controlLog->info('look for user ' . $thisId);

                foreach ($records as $record) {
                    if ($record['F_StudentID'] == $thisId) {
                        // This is an existing student, any changes necessary?
                        if ($record['groupName'] != $groupName) {
                            // move this user (means delete membership records and insert new one)
                            // or copy it (just insert new one)
                            if ($duplicateOption == ManageableOps::EXCEL_MOVE_IMPORT) {
                                echo "&nbsp;&nbsp;" . $user['name'] . " will be moved" . "<br/>";
                                $bindingParams = array($record['F_UserID']);
                                $rc = $thisService->db->Execute("DELETE FROM T_Membership WHERE F_UserID=?", $bindingParams);
                            } else {
                                echo "&nbsp;&nbsp;" . $user['name'] . " will be copied" . "<br/>";
                            }
                            try {
                                $bindingParams = array($record['F_UserID'], $thisGroup->id, $rootID);
                                $rc = $thisService->db->Execute("INSERT INTO T_Membership (F_UserID,F_GroupID,F_RootID) VALUES (?,?,?)", $bindingParams);
                            } catch (Exception $e) {
                                // The insert failed as already in this group?
                            }
                            AbstractService::$controlLog->info('userID ' . Session::get('userID') . ' moved a user with id=' . $record['F_UserID'] . ' to group ' . $parentGroup->id);
                        } else {
                            echo "&nbsp;&nbsp;" . $user['name'] . " is already in that group" . "<br/>";
                        }
                        if ($record['F_UserName'] != $user['name'] ||
                            $record['F_StudentID'] != $user['id'] ||
                            $record['F_Email'] != $user['email'] ||
                            $record['F_Password'] != $user['password']
                        ) {
                            // update the user details
                            // SQL UPDATE T_USER WHERE F_UserID = $record['F_UserID']
                            $sql = <<<EOD
                                UPDATE T_User
                                SET F_UserName=?, F_Password=?, F_Email=?, F_StudentID=?
                                WHERE F_UserID=?
EOD;
                            $bindingParams = array($user['name'], $user['password'], $user['email'], $user['id'], $record['F_UserID']);
                            $rs = $thisService->db->Execute($sql, $bindingParams);
                            AbstractService::$controlLog->info('userID ' . Session::get('userID') . ' update a user with id=' . $record['F_UserID']);
                        }
                        continue 2;
                    }
                }
                // This must be a new user as you didn't find a match
                $newUsers[] = $user;
            }

            // Anyone not in the recordset needs to be added as new
            if (count($newUsers) > 0)
                echo "&nbsp;&nbsp;" . count($newUsers) . " will be added as new" . "<br/>";

            foreach ($newUsers as $user) {
                $stubUser = new User();
                if (isset($user['name']))
                    $stubUser->name = $user['name'];
                if (isset($user['id']))
                    $stubUser->studentID = $user['id'];
                if (isset($user['password']))
                    $stubUser->password = $user['password'];
                if (isset($user['email']))
                    $stubUser->email = $user['email'];
                $thisService->manageableOps->minimalAddUser($stubUser, $thisGroup, $rootID, $loginOption);
            }
            flush();

        }

    } catch (Exception $e) {
                echo '<pre>';
                echo 'The problem is ' . $e->getMessage() . '<br/>';
                echo 'Here is some debugging info:';
                print_r($_FILES);
                print "</pre>";
                exit();
    }
?>