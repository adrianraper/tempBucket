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

    private function codeToMessage($code)
    {
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

$uploadfile = dirname(__FILE__)."/../../../../Common/uploads/" . basename($_FILES['rawDataFile']['name']);
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

try {
    if ($_FILES['rawDataFile']['error'] === UPLOAD_ERR_OK) {
        // TODO Before you move, do some file checking
        // is file empty
        // is the name valid
        // is the name not too long
        // is it just csv/txt
        if (!move_uploaded_file($_FILES['rawDataFile']['tmp_name'], $uploadfile))
            throw new Exception("Possible file upload attack on " . $uploadfile);
    } else {
        throw new UploadException($_FILES['file']['error']);
    }
} catch (Exception $e)  {
    echo '<pre>';
    echo 'The problem is '.$e->getMessage().'<br/>';
    echo 'Here is some debugging info:';
    print_r($_FILES);
    print "</pre>";
    exit();
}

    if(($handle = fopen($uploadfile, 'r')) !== FALSE) {
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
                    $emailCol = $field;
                    break;
                case "password":
                    $passwordCol = $field;
                    break;
            }
        }

        // If there is no group information, pack the users in a default group
        $groups = array();
        while(($data = fgetcsv($handle, 1000, $delimiter)) !== FALSE) {

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
            if (isset($nameCol))
                $user['name'] = $data[$nameCol];
            if (isset($idCol))
                $user['id'] = $data[$idCol];
            if (isset($emailCol))
                $user['email'] = $data[$emailCol];
            if (isset($passwordCol))
                $user['password'] = $data[$passwordCol];

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
        }
        fclose($handle);
    }

    // Quick summary for debugging
    /*
    foreach ($groups as $groupName => $users) {
        echo "group $groupName has ".count($users)." users<br/>";
    }
    */

    // Get the top level group for the user (with it's child groups)
    // Use the authentication from the earlier login
    //$userID = $_POST['userID'];

    $userID = Session::get('userID');
    //echo "you are $userID and these are the groups you can work on " . implode(',',Session::get('groupIDs')) . "<br/>";
    $manageables = $thisService->manageableOps->getAllManageables();

    // Work on each group in turn
    foreach ($groups as $groupName => $users) {
        $stubGroup = new Group();
        $stubGroup->name = $groupName;
        foreach ($users as $user) {
            $stubUser = new User();
            if (isset($user['name']))
                $stubUser->name = $user['name'];
            if (isset($user['id']))
                $stubUser->studentID = $user['id'];
            if (isset($user['password']))
                $stubUser->password = $user['password'];
            if (isset($user['email']))
                $stubUser->email = $user['email'];
            $stubGroup->manageables[] = $stubUser;
        }
        try {
            //set_time_limit(300);
            // Save a report of success/failure
            $thisService->manageableOps->initImportResults();
            echo "try to  import " . count($stubGroup->manageables) . " students to group " . $stubGroup->name . "<br/>";
            $rc = $thisService->manageableOps->_importManageable($stubGroup, $manageables[0], true, $duplicateOption);
            $results = $thisService->manageableOps->getImportResults(false);
            foreach ($results as $result) {
                if ($result['success'] != true) {
                    echo $result['name'] . ' failed: ' . $result['message'] . "<br/>";
                    AbstractService::$controlLog->info("failed to import " . $manageable->studentID . " into group " . $stubGroup->groupName);
                } else {
                    //echo $result['name'] . ' success: ' . $result['message'] . "<br/>";
                    AbstractService::$controlLog->info("imported " . $result['name']);
                }
            }
        } catch (Exception $e) {
            echo "importing to " . $stubGroup->name . " had a problem: " . $e->getMessage() . "<br/>";
        }
        flush();
    }

?>