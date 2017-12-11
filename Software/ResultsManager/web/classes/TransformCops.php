<?php
require_once(dirname(__FILE__) . '/../../../Workflow/vendor/autoload.php');
//putenv('GOOGLE_APPLICATION_CREDENTIALS=' . __DIR__ . '/../../../../.credentials/Couloir Google Transforms-0cedb27e5b36.json');
define('APPLICATION_NAME', 'Couloir Google Transforms');
define('CREDENTIALS_PATH', __DIR__ . '/../../../../.credentials/script-php.json');
define('CLIENT_SECRET_PATH', __DIR__ . '/../../../../.credentials/client_secret_1077737844043-h8m29pshs1p489uc6po1pph4io8ap243.apps.googleusercontent.com.json');
define('SCOPES', implode(' ', array(
        "https://www.googleapis.com/auth/drive", "https://www.googleapis.com/auth/documents")
));

class TransformCops {

    var $db;

    function TransformCops($db) {
        $this->db = $db;

        $this->copyOps = new CopyOps();
        $this->manageableOps = new ManageableOps($db);
        $this->portfolioCops = new PortfolioCops($db);
    }

    /**
     * If you changed the db, you'll need to refresh it here
     * Not a very neat function...
     */
    function changeDB($db) {
        $this->db = $db;
        $this->contentOps->changeDB($db);
        $this->manageableOps->changeDB($db);
        $this->portfolioCops->changeDB($db);
    }

    public function queueTransform($transform) {
        $errors = array();
            // Make sure that you are storing valid JSON data
            $json_data = json_encode($transform);
            if (json_last_error() === JSON_ERROR_NONE) {
                $sql = <<<EOD
                     INSERT INTO T_PendingTransforms
                         (`F_Data`,`F_RequestTimestamp`)
                         VALUES (?,?); 
EOD;
                $rs = $this->db->Execute($sql, array($json_data, date('Y-m-d G:i:s')));
                if (!$rs) $errors[] = $rs->lastDBError();
            } else {
                $errors[] = json_last_error();
            }
        return $errors;
    }

    // sss#362
    // Exceptions caught by the calling program
    public function callTransform($data) {
        $params = json_decode($data);
        switch ($params->transform) {
            case "CreateGoogleDoc":
                AbstractService::$debugLog->info("CreateGoogleDoc for $data");

                // call Google Apps Script to create a pdf
                $rc = $this->createPdfFromTemplate($params->data->template, $params->data->relatedText, $params->data->text, $params->userId);

                // add it to the user's portfolio
                if (isset($rc['href'])) {
                    $href = $rc['href'];
                    $thumbnail = 'media/thumbnail/SSS_WS_U10E01_01_GBRU.jpg';
                    $caption = (isset($params->data->caption)) ? $params->data->caption : 'Your writing';
                    $this->portfolioCops->addToPortfolio($params->userId, $params->uid, $href, $thumbnail, $caption);
                } else {
                    return $rc;
                }
                break;
            default:
                break;
        }
        // Not the right thing to return, but currently contrasts with exception
        return array();
    }

    /**
     * Returns an authorized API client.
     * @return Google_Client the authorized client object
     */
    function getClient() {
        $client = new Google_Client();
        $client->setApplicationName(APPLICATION_NAME);
        $client->setScopes(SCOPES);
        $client->setAuthConfig(CLIENT_SECRET_PATH);
        $client->setAccessType('offline');

        // Load previously authorized credentials from a file.
        $credentialsPath = $this->expandHomeDirectory(CREDENTIALS_PATH);
        if (file_exists($credentialsPath)) {
            $accessToken = json_decode(file_get_contents($credentialsPath), true);
        } else {
            // No credentials so request authorization from the user.
            $authUrl = $client->createAuthUrl();
            // TODO This should do a CURL to run the url and pick up the code from the response
            // Mind you the response will be to call the redirectUri with the code appended
            AbstractService::$debugLog->info("Open the following link in your browser " . $authUrl);
            //print 'Enter verification code: ';
            //$authCode = trim(fgets(STDIN));
            $authCode = '4/wnJb3nZSdELiZ7LWG6cQZ5xcCxF-eSWADMnHolDhYoQ';

            // Exchange authorization code for an access token.
            $accessToken = $client->fetchAccessTokenWithAuthCode($authCode);

            // Store the credentials to disk.
            if (!file_exists(dirname($credentialsPath))) {
                mkdir(dirname($credentialsPath), 0700, true);
            }
            file_put_contents($credentialsPath, json_encode($accessToken, JSON_UNESCAPED_SLASHES));
            AbstractService::$debugLog->info("Credentials saved to " . $credentialsPath);
        }
        $client->setAccessToken($accessToken);

        // Refresh the token if it's expired.
        if ($client->isAccessTokenExpired()) {
            $refreshToken = $client->getRefreshToken();
            AbstractService::$debugLog->info("token has expired, so get new one using refresh_token ".$refreshToken);
            $client->fetchAccessTokenWithRefreshToken($refreshToken);
            $newToken = $client->getAccessToken();
            AbstractService::$debugLog->info("got new access token ".json_encode($newToken));
            // Can I add back the same refresh token to it? Remove escaping of slash
            $newToken['refresh_token'] = $refreshToken;
            file_put_contents($credentialsPath, json_encode($newToken, JSON_UNESCAPED_SLASHES));
        }
        return $client;
    }

    /**
     * Expands the home directory alias '~' to the full path.
     * @param string $path the path to expand.
     * @return string the expanded path.
     */
    function expandHomeDirectory($path) {
        $homeDirectory = getenv('HOME');
        if (empty($homeDirectory)) {
            $homeDirectory = getenv('HOMEDRIVE') . getenv('HOMEPATH');
        }
        return str_replace('~', realpath($homeDirectory), $path);
    }

    function createPdfFromTemplate($template, $rubric, $text, $userId) {
        // Get the API client and construct the service object.
        $client = $this->getClient();
        $service = new Google_Service_Script($client);
        $scriptId = '1FuT-NnOrcLGBSr4Ta869hWp2I8T8tmv429xivB5jRDEWZk0ch5qwaD0G';
        //$scriptId = 'MJOkw0aTi6sbYTIWHlFkGQpGuM7qjtt60'; // App ID from Publish as API Executable
        $requestName = 'createPdfFromTemplate';

        // Pleasant form of google doc id of any template you want
        switch ($template) {
            case "b27 self marking checklist":
                $docId = '1Wx3qCG6xxxhXNdF63y9ADeibhqdfCaYxkWtRRdNejV4';
                break;
            case "blank":
            default:
                $docId = '0';
        }
        $filename = $userId . ' ' . $template;
        $parameterArray = ["filename" => $filename, "text" => $text, "rubric" => $rubric, "template" => $docId];

        // Create an execution request object.
        $request = new Google_Service_Script_ExecutionRequest();
        $request->setFunction($requestName);
        $request->setParameters(json_encode($parameterArray));

        $rc = array();
        try {
            // Make the API request.
            $response = $service->scripts->run($scriptId, $request);
            AbstractService::$debugLog->info("made a request to API");

            if ($response->getError()) {
                // The API executed, but the script returned an error.

                // Extract the first (and only) set of error details. The values of this
                // object are the script's 'errorMessage' and 'errorType', and an array of
                // stack trace elements.
                $error = $response->getError()['details'][0];
                AbstractService::$debugLog->info("Script error message: " . $error['errorMessage']);
                $rc["error"] = 'scriptStackTraceElements';

                if (array_key_exists('scriptStackTraceElements', $error)) {
                    // There may not be a stacktrace if the script didn't start executing.
                    AbstractService::$debugLog->info("Script error stacktrace:");
                    foreach ($error['scriptStackTraceElements'] as $trace) {
                        AbstractService::$debugLog->info($trace['function'] . ':' . $trace['lineNumber']);
                    }
                }
            } else {
                // The response includes the id of the created document so you can pass forward
                $resp = $response->getResponse();
                $rc = $resp['result'];
                if (!isset($rc["href"])) {
                    AbstractService::$debugLog->info("No pdf created");
                } else {
                    AbstractService::$debugLog->info("created new pdf, url=" .$rc["href"]);
                }
            }
        } catch (Exception $e) {
            // The API encountered a problem before the script started executing.
            AbstractService::$debugLog->info('Caught exception: '.$e->getMessage());
            $rc["error"] = $e->getMessage();
        }
        return $rc;
    }
}