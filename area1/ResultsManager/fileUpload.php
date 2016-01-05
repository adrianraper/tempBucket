<?php
/**
 * Created by IntelliJ IDEA.
 * User: Adrian
 * Date: 05/01/2016
 * Time: 08:46
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

$uploaddir = 'uploads/';
$uploadfile = $uploaddir . basename($_FILES['rawDataFile']['name']);

try {
    if ($_FILES['rawDataFile']['error'] === UPLOAD_ERR_OK) {
        if (!move_uploaded_file($_FILES['rawDataFile']['tmp_name'], $uploadfile))
            throw new Exception("Possible file upload attack!");
    } else {
        throw new UploadException($_FILES['file']['error']);
    }
} catch (Exception $e)  {
    echo '<pre>';
    echo 'The problem is '.$e->getMessage().'<br/>';
    echo 'Here is some debugging info:';
    print_r($_FILES);
    print "</pre>";
}

// Test if the file really is csv
    if(($handle = fopen($uploadfile, 'r')) !== FALSE) {
        // maybe necessary if this a large csv file
        // set_time_limit(60);

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

        // We could look up the account and see what the loginOption is at this point?

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
    foreach ($groups as $groupName => $users) {
        echo "group $groupName has ".count($users)." users<br/>";
    }

    // Send this data to bulkImport in ManageableOps
?>