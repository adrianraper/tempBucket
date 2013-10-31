<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */
require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

$dmsService = new DMSService();
if (!Authenticate::isAuthenticated()) {
	// TODO: Replace with text from literals
	echo "<h2>You are not logged in</h2>";
	exit(0);
}

if (!isset($_REQUEST['template']) || trim($_REQUEST['template']) == "") {
	echo "<h2>No template was specified</h2>";
	exit(0);
}
$template = $_REQUEST['template'];
$emailArray = $_REQUEST['emailArray'] == "" ? array() : json_decode(stripslashes($_REQUEST['emailArray']), true);
$previewIndex = isset($_REQUEST['previewIndex']) ? $_REQUEST['previewIndex'] : 0;
$send = isset($_REQUEST['send']) && $_REQUEST['send'] == "true";
$emails_sent = isset($_REQUEST['emails_sent']) && $_REQUEST['emails_sent'] == "true";

// v3.3 Can we see if we can clear the smarty cache?
// No this appears to make no difference.
/*
require_once($GLOBALS['smarty_libs']."/Smarty.class.php");
$smarty = new Smarty();
$smarty->template_dir = $GLOBALS['smarty_template_dir'];
$smarty->compile_dir = $GLOBALS['smarty_compile_dir'];
$smarty->config_dir = $GLOBALS['smarty_config_dir'];
$smarty->cache_dir = $GLOBALS['smarty_cache_dir'];
$smarty->plugins_dir[] = $GLOBALS['smarty_plugins_dir'];
$smarty->clear_compiled_tpl();
$smarty->force_compile = true;
*/

// PHP 5.3
$pattern = '/..\//';
$replacement = '';
$template = preg_replace($pattern, $replacement, $template);

// DMS doesn't serialize the account, but instead just puts an 'account_id' in the data attribute.  Here we go through the array and
// rebuild it getting the real account objects for the account_ids.
// gh#721
class Attribute {
	var $licenceKey;
	var $licenceValue;
	function __construct($key = undefined, $value = undefined) {
		$this->licenceKey = $key;
		$this->licenceValue = $value;
	}
}
$accountEmailArray = array();
foreach ($emailArray as $email) {
	$accountEmail = array();
	// Pick up the full account info from the database
	$accountEmail['data']['account'] = array_shift($dmsService->getAccounts(array($email['data']['account_id'])));
	
	// Has to include licence attributes
	// gh#721
	$attributes = $dmsService->getAccountDetails(array($email['data']['account_id']));
	$attributesAsObject = array();
	foreach ($attributes as $attribute) {
		$attributesAsObject[] = new Attribute($attribute['licenceKey'], $attribute['licenceValue']);
	}
	$accountEmail['data']['account']->licenceAttributes = $attributesAsObject;
	
	// If this is an AA account, you want to talk about the generic student password, but that is NOT in T_AccountRoot
	$accountEmail['data']['user'] = $dmsService->getFirstStudentInAccount($accountEmail['data']['account']->id);
	
	// v3.6 Actually you should be picking up the to and cc from the account, not what you sent
	//$accountEmail['to'] = $email['to'];
	//$accountEmail['to'] = $accountEmail['data']['account']->adminUser->email;
	// Now other emails come from reseller and RM
	// Once the sub emails is done, this will work, for now this is still old style
	$accountEmails = array($accountEmail['data']['account']->adminUser->email);
	// $accountEmails = $dmsService->accountOps->getEmailsForMessageType($email['data']['account_id'], 1);
	// If there is a reseller they are also 'ccd.
	$resellerEmail = array($dmsService->accountOps->getResellerEmail($accountEmail['data']['account']->resellerCode));
	
	// Pick out the first accountEmail for 'to' and merge all the rest as 'cc'
	$adminEmail = array_shift($accountEmails);
	$ccEmails = array_merge($accountEmails, $resellerEmail);
	//echo 'root='.$email['data']['account_id'].' adminEmail='.$adminEmail.' reseller='.implode(',',$resellerEmail).' all cc='.implode(',',$ccEmails);

	// v3.6 Don't duplicate to and cc, which many DMS records do
	//if ($accountEmail['data']['account']->email != $accountEmail['to']) {
	//	$accountEmail['cc'] = explode(",", $accountEmail['data']['account']->email);
	//}
	$accountEmail['to'] = $adminEmail;
	$accountEmail['cc'] = $ccEmails;
	
	//if (isset($email['bcc']) $accountEmail['bcc'] = $email['bcc'];
	// For now cc ALL emails sent out by the system to accounts@clarityenglish.com. 
	// This is now handled by the templates.
	//$accountEmail['cc'] = "accounts@clarityenglish.com";
	$accountEmailArray[] = $accountEmail;
}
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
		#EmailPreview {
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
		
		<h1>DMS Email Merge</h1>
		
<?php if (!$send) { ?>
		<ul>
			<?php 
			$n = 0;
			foreach ($accountEmailArray as $accountEmail) {
				echo "<li>";
				if (isset($accountEmail['cc'])) {
					echo "<a href='#' onClick='previewEmail(".$n.")'>".$accountEmail['data']['account']->name." (to:".$accountEmail['to']." cc:".implode(",", $accountEmail['cc']).")</a>";
				} else {
					echo "<a href='#' onClick='previewEmail(".$n.")'>".$accountEmail['data']['account']->name." (to:".$accountEmail['to'].")</a>";
				}
				echo "</li>";
				$n++;
			} ?>
		</ul>
		<?php
		if ($emails_sent) {
			echo "<b>Emails sent</b>";
		}
		?>
		<div id="EmailPreview">
			<?php echo $dmsService->emailOps->fetchEmail($template, $accountEmailArray[$previewIndex]['data']); ?>
		</div>
		<input type="button" value="Send emails" onClick="sendEmail()" />
<?php } else { ?>
		Sending to: 
		<?php 
		$emails = array();
		foreach ($accountEmailArray as $accountEmail)
			$emails[] = $accountEmail['to'];
		echo join($emails, ",");
		?>
		<div id="EmailResults">
			<h3>Results:</h3>
		</div>
<?php } ?>
		<form id="sendForm" action="<?php echo $_SERVER['SCRIPT_NAME']; ?>" method="GET">
			<input type="hidden" name="previewIndex" value="<?php echo isset($_REQUEST['previewIndex']) ? $_REQUEST['previewIndex'] : 0; ?>" />
			<input type="hidden" name="template" value="<?php echo $_REQUEST['template']; ?>" />
			<input type="hidden" name="emailArray" value='<?php echo json_encode($emailArray); ?>' />
			<input type="hidden" name="send" />
			<input type="hidden" name="emails_sent" />
		</form>
	</body>
</html>
<?php 
flush();

if ($send) {
	$results = $dmsService->emailOps->sendEmails("", $template, $accountEmailArray);
	
	if (sizeof($results) > 0) {
		// Write the results into EmailResults
		foreach ($results as $result) {
			?>
			<script>				
				resultSpan = new Element("span");
				resultSpan.update("<?= $result[0]; ?><br/>");
				
				$("EmailResults").appendChild(resultSpan);
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

exit(0)
?>