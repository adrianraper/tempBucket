<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */
require_once(dirname(__FILE__)."/ClarityService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

$thisService = new ClarityService();
if (!Authenticate::isAuthenticated()) {
    // TODO: Replace with text from literals
    //echo "<h2>You are not logged in</h2>";
    //exit(0);
}

//$templateDefinition = new TemplateDefinition();
$templateDefinition = (isset($_REQUEST['template'])) ? json_decode(stripslashes($_REQUEST['template'])) : null;
$groupIdArray = (isset($_REQUEST['groupIdArray'])) ? json_decode(stripslashes($_REQUEST['groupIdArray']), true) : array();
$previewIndex = isset($_REQUEST['previewIndex']) ? $_REQUEST['previewIndex'] : 0;
$send = isset($_REQUEST['send']) && $_REQUEST['send'] == "true";

/**
 * This for testing and debugging emails
 */

$templateDefinition = json_decode('{
	"description": null,
	"title": null,
	"name": "invitation",
	"data": {
		"administrator": {
			"email": "twaddle@email",
			"name": "Mrs Twaddle"
		},
		"test": {
			"closeTime": "2017-01-31 00:00:00",
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
			"emailInsertion": "Please go to lecture room 2B at 10am to start the test.",
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

if (!isset($templateDefinition->data)) {
    echo "<h2>No template data was passed</h2>";
    exit(0);
}

$userEmailArray = $thisService->dailyJobOps->getEmailsForGroup($groupIdArray, $templateDefinition);

// ctp#346 Add the administrator to this list of email recipients for copy
$adminEmail = array();
$adminEmail['to'] = $templateDefinition->data->administrator->email;
// Since we don't have a full user for the admin, just replace key bits
$adminEmail['data']['user'] = new User();
$adminEmail['data']['user']->name = $templateDefinition->data->administrator->name.' (copy for reference)';
$adminEmail['data']['user']->email = $templateDefinition->data->administrator->email;
$adminEmail['data']['user']->password = 'xxxxxx';
$adminEmail['data']['templateData'] = $userEmailArray[0]['data']['templateData'];
array_push($userEmailArray, $adminEmail);

if ($send)
    $results = $thisService->emailOps->sendEmails("", $templateDefinition->filename, $userEmailArray);
?>
<!DOCTYPE html>
  <html>
    <head>
        <title>Preview email</title>
        <link rel="shortcut icon" type="image/x-icon" href="http://www.clarityenglish.com/Software/DPT.ico"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta charset="UTF-8">
        <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600" rel="stylesheet">
        <link href="https://netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.min.css" rel="stylesheet">
        <script src="../../js/prototype-1.6.0.3.js"></script>
        <script>
            function previewEmail(previewIndex) {
                $("sendForm").previewIndex.value = previewIndex;
                $("sendForm").send.value = false;
                $("sendForm").submit();
            }

            function sendEmails() {
                $("sendForm").send.value = true;
                $("sendForm").submit();
            }
        </script>
    </head>
    <style>
        html {
            font: 400 1em/1.4 'Open Sans', sans-serif;
            text-rendering: optimizeLegibility;
        }
        .header {
            font-weight: bold;
            text-align: center;
            padding: 10px 0;
        }
        .body {
            position: absolute;
            top: 50px;
            right: 0;
            bottom: 0;
            left: 0;
            display: flex;
            max-height: 900px;
        }
        .preview {
            padding: 2em;
            width: 60%;
        }
        .main {
            flex: 1;
            display: flex;
            flex-direction: column;
            width: 40%;
        }
        .content {
            flex: 1;
            display: flex;
            overflow-y: auto;
            width: 100%;
        }
        .box {
            min-height: 500px;
            display: flex;
            width: 100%;
        }
        .column {
            padding: 20px;
            width: 100%;
        }

        .col-footer {
            font-weight: bold;
            text-align: center;
            background-image: linear-gradient(to right, #2BB673, #00A79D);
            padding: 1em 0;
            color: #ffffff;
            cursor: pointer;
        }
        .listItem {
            padding: 0.3em;
            width: 100%;
        }
        .bordered {
            border: 1px solid #C9DBDF;
        }
    </style>
    <body>
    <form id="sendForm" action="<?php echo $_SERVER['SCRIPT_NAME']; ?>" method="GET">
        <input type="hidden" name="previewIndex" value="<?php echo isset($_REQUEST['previewIndex']) ? $_REQUEST['previewIndex'] : 0; ?>" />
        <input type="hidden" name="template" value='<?php echo $_REQUEST["template"]; ?>' />
        <input type="hidden" name="groupIdArray" value='<?php echo json_encode($groupIdArray); ?>' />
        <input type="hidden" name="send" />
    </form>
    <?php if (!$send) { ?>
        <div class="header">
            Test takers' emails and preview
        </div>
        <div class="body">
            <div class="main bordered">
                <div class="content ">
                    <div class="box">
                        <div class="column ">
                            <?php
                            $n = 0;
                            foreach ($userEmailArray as $userEmail) {
                                echo "<div class='listItem'>";
                                echo "<a href='#' onClick='previewEmail(".$n.")'>".$userEmail['data']['user']->name." (".$userEmail['to'].")</a>";
                                echo "</div>";
                                $n++;
                            }
                            ?>
                        </div>
                    </div>
                </div>
                <div class="col-footer" onclick="sendEmails()">Send all emails</div>
            </div>
            <div class="preview bordered">
                <?php echo $thisService->emailOps->fetchEmail($templateDefinition->filename, $userEmailArray[$previewIndex]['data']); ?>
            </div>
        </div>
    <?php } else { ?>
        <div class="header">
            Emails sent
        </div>
    <?php } ?>
  </body>
</html>
