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
	echo "<h2>You are not logged in</h2>";
	exit(0);
}

if (!isset($_REQUEST['template']) || trim($_REQUEST['template']) == "") {
	echo "<h2>No template was specified</h2>";
	exit(0);
}
$templateDefinition = new TemplateDefinition();
$templateDefinition = json_decode(stripslashes($_REQUEST['template']));
$groupIdArray = $_REQUEST['groupIdArray'] == "" ? array() : json_decode(stripslashes($_REQUEST['groupIdArray']), true);
$previewIndex = isset($_REQUEST['previewIndex']) ? $_REQUEST['previewIndex'] : 0;
$send = isset($_REQUEST['send']) && $_REQUEST['send'] == "true";
$emails_sent = isset($_REQUEST['emails_sent']) && $_REQUEST['emails_sent'] == "true";

//if ($previewIndex > 0) {
//	var_dump($_REQUEST['template']); exit();
//}
//$pattern = '/..\//';
//$replacement = '';
//$templateDefinition->filename = preg_replace($pattern, $replacement, $templateDefinition->filename);

// You need to pass a user object to the email template, so build an array of all users in all these groups
// TODO It might have been better not to use dailyJobOps as needed lots of new classes for ClarityService from DMS
$userEmailArray = $thisService->dailyJobOps->getEmailsForGroup($groupIdArray, $templateDefinition);

?>
<html>
	<head>
		<script src="../../js/prototype-1.6.0.3.js"></script>
		<script>
			function previewEmail(previewIndex) {
				$("sendForm").previewIndex.value = previewIndex;
				$("sendForm").send.value = false;
				$("sendForm").submit();
			}
			
			function sendEmail() {
				$("sendForm").send.value = true;
				$("sendForm").submit();
			}
		</script>
	</head>
	<style>
		<!--
		#emailPreview {
			margin: 10px 10px 10px 10px;
			padding: 10px 10px 10px 10px;
			border: 1px grey solid;
		}
		#loading {
			width: 200px;
			height: 100px;
			background-color: #c0c0c0;
			position: absolute;
			left: 50%;
			top: 50%;
			margin-top: -50px;
			margin-left: -100px;
			text-align: center;
		}
		-->
	</style>
	<body disabled="true">
		
		<script>
			document.write('<div id="loading"><br>Sending emails...<br><br>Do not refresh this page!</div>');
			window.onload=function() {
				$("loading").style.display = "none";
			}
		</script>
		
		<h1>Results Manager group email merge</h1>
		
<?php if (!$send) { ?>
		<ul>
			<?php 
			$n = 0;
			foreach ($userEmailArray as $userEmail) {
				echo "<li>";
				echo "<a href='#' onClick='previewEmail(".$n.")'>".$userEmail['data']['user']->name." (to:".$userEmail['to'].")</a>";
				echo "</li>";
				$n++;
			}
			 ?>
		</ul>
		<?php //TODO How about only listing 10 emails above and then saying "plus xx more" ?>
		<?php
		if ($emails_sent) {
			echo "<b>Emails sent</b>";
		}
		?>
		<div id="emailPreview">
			<?php echo $thisService->emailOps->fetchEmail($templateDefinition->filename, $userEmailArray[$previewIndex]['data']); ?>
		</div>
		<input type="button" value="Send emails" onClick="sendEmail()" />
<?php } else { ?>
		Sending to: 
		<?php
		// TODO why not output as <ol> list instead of a unreadable string? 
		$emails = array();
		foreach ($userEmailArray as $userEmail)
			$emails[] = $userEmail['to'];
		echo join($emails, ",");
		?>
		<div id="emailResults">
			<h3>Results:</h3>
		</div>
<?php } ?>
		<form id="sendForm" action="<?php echo $_SERVER['SCRIPT_NAME']; ?>" method="GET">
			<input type="hidden" name="previewIndex" value="<?php echo isset($_REQUEST['previewIndex']) ? $_REQUEST['previewIndex'] : 0; ?>" />
			<input type="hidden" name="template" value='<?php echo $_REQUEST["template"]; ?>' />
			<input type="hidden" name="groupIdArray" value='<?php echo json_encode($groupIdArray); ?>' />
			<input type="hidden" name="send" />
			<input type="hidden" name="emails_sent" />
		</form>
	</body>
</html>
<?php 
flush();

if ($send) {
	$results = $thisService->emailOps->sendEmails("", $templateDefinition->filename, $userEmailArray);
	
	if (sizeof($results) > 0) {
		// Write the results into emailResults div
		// TODO But why use a span like this?
		foreach ($results as $result) {
			?>
			<script>				
				resultSpan = new Element("span");
				resultSpan.update("<?php echo $result[0]; ?><br/>");
				$("emailResults").appendChild(resultSpan);
			</script>
			<?php
		}
	} else {
		?>
		<script>
			$("sendForm").emails_sent.value = true;
			previewEmail(0);
		</script>
		<?php
	}
}

exit(0);
