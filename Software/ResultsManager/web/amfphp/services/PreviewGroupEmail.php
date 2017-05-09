<?php
/*
 * This is not really an AMFPHP service but it's in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */
require_once(dirname(__FILE__) . "/ClarityService.php");
require_once(dirname(__FILE__) . "../../core/shared/util/Authenticate.php");

$thisService = new ClarityService();
if (!Authenticate::isAuthenticated()) {
    // TODO: Replace with text from literals
    //echo "<h2>You are not logged in</h2>";
    //exit(0);
}

$templateString = (isset($_REQUEST['template'])) ? $_REQUEST['template'] : '';
$template = (isset($_REQUEST['template'])) ? json_decode($_REQUEST['template']) : null;
$groupIdString = (isset($_REQUEST['groupIdArray'])) ? $_REQUEST['groupIdArray'] : '';
$groupIdArray = (isset($_REQUEST['groupIdArray'])) ? json_decode(stripslashes($_REQUEST['groupIdArray']), true) : array();
$previewIndex = isset($_REQUEST['previewIndex']) ? json_decode($_REQUEST['previewIndex']) : 0;
//$send = isset($_REQUEST['send']) && $_REQUEST['send'] == "true";

/**
 * This for testing and debugging emails
 */
/*
$templateString = '{"title":null,"templateID":null,"description":null,"filename":"user/DPT-welcome","name":"invitation","data":{"test":{"startType":"timer","language":"EN","followUp":{"caption":"Read dock this","href":null},"parent":null,"closeTime":"2017-05-09 17:00:00","id":"56","children":null,"reportableLabel":"May&apos;s test \"that will\" fail","uid":"56","showResult":false,"caption":"May&apos;s test \"that will\" fail","groupId":"35026","menuFilename":"menu.json.hbs","productCode":"63","testId":"56","status":2,"openTime":"2017-05-09 09:00:00","startData":null},"administrator":{"name":"Mrs Twaddle","email":"twaddle@email.com"}}}';
$template = json_decode($templateString);
$groupIdString = '["21560"]';
$groupIdArray = json_decode($groupIdString);
$previewIndex = 0;
*/
if (!isset($template->data)) {
    echo "<h2>No template data was passed</h2>";
    exit(0);
}
if (!isset($groupIdArray[0])) {
    echo "<h2>No group data was passed</h2>";
    exit(0);
}

$userEmailArray = $thisService->dailyJobOps->getEmailsForGroup($groupIdArray, $template);
if (count($userEmailArray) > 0) {
    $emailContents = $thisService->emailOps->fetchEmail($template->filename, $userEmailArray[$previewIndex]['data']);
} else {
    $emailContents = $thisService->emailOps->fetchEmail($template->filename, array());
}

$administratorEmail = (isset($template->data->administrator->email)) ? $template->data->administrator->email : 'support@clarityenglish.com';
$administratorName = (isset($template->data->administrator->name)) ? $template->data->administrator->name : null;

if (isset($template->data->administrator->name) && isset($template->data->administrator->email)) {
    $emailInsertion = "Got any questions? Ask " . $administratorName . " at " . $administratorEmail;
} else if (isset($administratorName)) {
    $emailInsertion = "Ask " . $administratorName. " any questions.";
} else {
    $emailInsertion = "Type here to tell the test takers how to contact you if they have any questions.";
}
/*
// ctp#346 Add the test administrator to this list of email recipients for copy
$adminEmail = array();
$adminEmail['to'] = $administratorEmail;
// Since we don't have a full user for the admin, just replace key bits
$adminEmail['data']['user'] = new User();
$adminEmail['data']['user']->name = $administratorName . ' (copy for reference)';
$adminEmail['data']['user']->email = $administratorEmail;
$adminEmail['data']['user']->password = '(hidden)';
$adminEmail['data']['templateData'] = $userEmailArray[0]['data']['templateData'];
array_push($userEmailArray, $adminEmail);
*/

//if ($send) {
//    $results = $thisService->emailOps->sendEmails("", $template->filename, $userEmailArray);
//}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Test Admin send welcome email</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta charset="UTF-8">
    <link rel="stylesheet" href="https://www.w3schools.com/lib/w3.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <script src="https://code.jquery.com/jquery-3.1.1.js"></script>
    <style>
        .scrollingBlock {
            overflow-y: auto;
        }
        .promptWithIcon {
            vertical-align: -2px;
        }
        li > a {
            text-decoration: none;
        }
        .replaceInPreview {
            display: none;
        }
        #confirmEmailPanel .replaceInPreview {
            display: block;
        }

    </style>
    <script>

        /**
         * This will send the original data and any edits made on this screen to a function that
         * sends the emails and or returns the template with the edits and selected user's details.
         */
        var currentPreviewIndex = 0;
        function previewEmail(previewIndex) {
            currentPreviewIndex = previewIndex;
            getEmail(currentPreviewIndex, false);
        }
        // Show a modal panel with the final email contents
        function confirmEmail() {
            getEmail(currentPreviewIndex, false);
            $("#confirmEmailPanel").show();
        }
        function sendEmails() {
            $("#confirmEmailPanel").hide();
            $("#emailsSentNotice").show();
            getEmail(currentPreviewIndex, true);
        }
        function dontSendEmail() {
            $("#confirmEmailPanel").hide();
        }
        function getEmail(previewIndex, sendEmails) {
            var groupIdArray = JSON.parse(<?php echo "'$groupIdString'"; ?>);
            var previewIndex = previewIndex;
            var template = JSON.parse(<?php echo "'$templateString'"; ?>);
            // Need to remove line breaks (and other?) characters from typed text
            var strippedNotes = $("#emailInsertion").val();
            strippedNotes = strippedNotes.replace(/(?:\r\n|\r|\n)/g, '<br/>');
            strippedNotes = strippedNotes.replace(/(")/g, '&quot;');
            //console.log(strippedNotes);
            var subject = $("#emailSubject").val()
            subject = subject.replace(/(")/g, '&quot;');
            var emailInsertion =  JSON.parse('{"subject":"' + subject + '", "notes":"' + strippedNotes + '"}');

            $.ajax({
                url: "GroupEmailActions.php",
                data: {
                    method: "getTemplate",
                    template: JSON.stringify(template),
                    groupIdArray: JSON.stringify(groupIdArray),
                    previewIndex: JSON.stringify(previewIndex),
                    emailInsertion: JSON.stringify(emailInsertion),
                    send: sendEmails
                },
                type: "GET",
                dataType: "json"
            })
                .done(function (json) {
                    $("#emailConfirm").replaceWith('<div id="emailConfirm" class="w3-container">' + json.emailContents + '</div>');
                    $("#emailContents").replaceWith('<div id="emailContents">' + json.emailContents + '</div>');
                    if (sendEmails)
                        $("#emailsSentNotice h2").text("Emails sent");
                })
                .fail(function (xhr, status, errorThrown) {
                    alert("Sorry, there was a problem!");
                    console.log("Error: " + errorThrown);
                    console.log("Status: " + status);
                    console.dir(xhr);
                });
        }
        function closeWindow() {
            window.close();
        }
    </script>
</head>
<body>
<div class="w3-cell-row">
    <div class="w3-container w3-cell w3-cell-middle w3-card-2" style="width:40%">
        <img src="http://www.clarityenglish.com/images/program/DPTpage/DPT_TA_logo.png" alt="DPT logo"
             class="w3-cell-middle w3-padding-8">
        &nbsp;&nbsp;<span><strong>Edit and send this email to test takers</strong></span>
    </div>
    <div class="w3-container w3-cell w3-cell-middle w3-card-2">
        <div class="w3-cell-row">
            <div class="w3-cell" style="width:94px">Subject&nbsp;&nbsp;<i class="fa fa-edit promptWithIcon"
                                                                          style="font-size:20px"></i></div>
            <input id="emailSubject" class="w3-input w3-border w3-round w3-hover-teal w3-pale-green" type="text"
                   value="<?php if (isset($administratorName)) {
                       echo $administratorName . " has set you an English test";
                   } else {
                       echo "You have been set an English test";
                   }  ?>">
        </div>
    </div>
</div>
<div class="w3-cell-row">
    <div class="w3-container w3-cell w3-card-2" style="width:40%">
        <ul class="w3-ul w3-hoverable scrollingBlock w3-margin-top w3-margin-bottom" style="height:700px">
            <?php
            if (count($userEmailArray) > 0) {
                $n = 0;
                foreach ($userEmailArray as $userEmail) {
                    echo "<li class='w3-hover-teal'>";
                    echo "<a href='#' onClick='previewEmail(" . $n . ")'>" . $userEmail['data']['user']->name . " (" . $userEmail['to'] . ")</a>";
                    echo "</li>";
                    $n++;
                }
            } else {
                echo "<span><strong>There is nobody to send an email to.</strong></span>";
            }
            ?>
        </ul>
    </div>
    <div class="w3-container w3-cell w3-card-2 w3-padding-0">
        <div class="w3-container w3-margin w3-hover-shadow" style="height:700px">
                <div id="emailContents"><?php echo $emailContents; ?></div>
                <div><strong>Notes</strong>&nbsp;&nbsp;<i class="fa fa-edit promptWithIcon" style="font-size:20px"></i>
                </div>
                <textarea id="emailInsertion" class="w3-input w3-border w3-round w3-hover-teal w3-pale-green"
                          style="height:100px; resize:none"><?php echo $emailInsertion; ?></textarea>
        </div>
        <?php
        if (count($userEmailArray) > 0)
            echo '<button class="w3-btn-block w3-ripple w3-teal" onclick="confirmEmail()">Send all</button>';
        ?>
    </div>
</div>
<div id="emailsSentNotice" class="w3-modal" style="display:none">
    <div class="w3-modal-content w3-card-8 w3-center" style="width:50%">
        <header class="w3-container w3-teal">
                            <span onclick="closeWindow()"
                                  class="w3-closebtn">&times;</span>
            <h2>Sending emails, please wait...</h2>
        </header>
    </div>
</div>
<div id="confirmEmailPanel" class="w3-modal" style="display:none">
    <div class="w3-modal-content w3-card-8" style="width:75%">
        <header class="w3-container w3-border-bottom w3-padding-8 w3-light-grey">
                            <span onclick="dontSendEmail()"
                                  class="w3-closebtn">&times;</span>
            <h3>Click OK to confirm this and all emails</h3>
        </header>
        <div id="emailConfirm" class="w3-container">Email goes here</div>
        <div class="w3-container w3-border-top w3-padding-8 w3-light-grey">
            <button onclick="sendEmails()" type="button" class="w3-btn w3-teal w3-left">OK</button>
            <button onclick="dontSendEmail()" type="button" class="w3-btn w3-teal w3-right">Cancel</button>
        </div>
    </div>
</div>

</body>
</html>