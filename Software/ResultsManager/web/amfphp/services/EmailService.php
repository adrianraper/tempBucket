<?php
/**
 * Sends out emails for other scripts
 *		It expects a name and email address in an array
 *		It also expects a user object (you)
 *		And a title object (which is the subject of the email)
 */
require_once(dirname(__FILE__)."/../../config.php");
 
require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");
require_once(dirname(__FILE__)."/../../classes/CopyOps.php");
require_once(dirname(__FILE__)."/../../classes/TemplateOps.php");
require_once(dirname(__FILE__)."/../../classes/EmailOps.php");
require_once(dirname(__FILE__)."/AbstractService.php");

class EmailService extends AbstractService {
	
	var $db;

	function EmailService() {
		parent::_AbstractService();
		
		// A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("EMAIL");
		
		// Set the product name and userID for logging
		AbstractService::$log->setProductName("EMAIL");
		
		$this->emailOps = new EmailOps($this->db);
		
		// DMS has no restrictions on user/group access so disable manageable authentication
		AuthenticationOps::$useAuthentication = false;
	}
	function sendEmails($template, $emailArray, $sender, $data=null) {
		// All about the person sending out the emails
		$emailFrom = $sender['email'];
		$emailFromName = $sender['name'];
		if (!$data) {
			$data = array();
		}
		//if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
		$debug=true;
		if ($debug) {
			foreach($emailArray as $emailData) {
				$emailTo = $emailData['email'];
				$emailToName = $emailData['name'];
				// Add this information to whatever else is in $data
				$data["toName"]=$emailToName;
				$data["fromName"] = $emailFromName;
				$data["fromEmail"] = $emailFrom;
				echo "<b>Email: ".$emailTo."</b><br/><br/>".$this->emailOps->fetchEmail($template, $data)."<hr/>";
				//echo "<b>Email: $emailTo</b> to $emailToName from $emailFromName, $emailFrom<br/><br/><hr/>";
			}
		} else {
			foreach($emailArray as $emailData) {
				$emailTo = $emailData['email'];
				$emailToName = $emailData['name'];
				// Add this information to whatever else is in $data
				$data["toName"] = $emailToName;
				$data["fromName"] = $emailFromName;
				$data["fromEmail"] = $emailFrom;
				$dataArray[] = array("to" => $emailTo
									,"data" => $data
									,"cc" => array($emailFrom)
									,"bcc" => array($adminEmail)
									);
			}
			// Note that sendEmails ignores the first parameter which is supposed to be $from. It picks up $from in the template header.
			// I should send back any errors generated - or should I handle them here?
			return $this->emailOps->sendEmails('', $template, $dataArray);
		}
	}
	
}

?>