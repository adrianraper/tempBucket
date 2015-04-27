<?php
require_once($GLOBALS['rmail_libs']."/Rmail.php");

require_once(dirname(__FILE__)."/TemplateOps.php");

class EmailOps {
	
	var $db;
	
	function EmailOps($db = null) {
		$this->db = $db;
		
		$this->templateOps = new TemplateOps($db);
	}
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
		$this->templateOps->changeDB($db);
	}
	
	function fetchEmail($templateName, $dataArray, $useCache = false) {
		return $this->templateOps->fetchTemplate("emails/".$templateName, $dataArray, $useCache);
	}
	
	/**
	 * Since this can send more than one email $emailsArray is an array of objects, with each object having:
	 * 
	 * o from: the email address to send from (currently unused - from is taken directly from config.php)
	 * o templateName: the template to send
	 * o emailArray: an array of 'to' and 'data' objects, one per email to be sent.  This also has an optional 'attachments' array which
	 * will be used for attaching licence files, etc.  An example use might be:
	 *
	 * "attachments" => array(new stringAttachment($licenceFileText, 'licence.ini') 
	 *
	 * One email per element will be sent.
	 * gh#226 set default to be to use pendingEmails to send
	 */
	function sendEmails($from, $templateName, $emailArray, $immediateDispatch = false) {
		$errors = array();
				
		// gh#226 Insert records into the pendingEmails table, unless you are specifically requesting immediate dispatch
		if (!$immediateDispatch){
			$errors = $this->queueEmails($from, $templateName, $emailArray);
						
		} else {
			
			// Loop through $emailArray sending one email per entry
			foreach ($emailArray as $email) {
				// Configure the Rmail object.  As there is no removeAttachments method we need to do this once per mail.
				$mail = new Rmail();	
				$mail->setHTMLCharset('UTF-8');
				$mail->setTextCharset('UTF-8');
				$mail->setTextEncoding(new EightBitEncoding());
				$mail->setHTMLEncoding(new EightBitEncoding());
				$mail->setSMTPParams($GLOBALS['rmail_smtp_host'], $GLOBALS['rmail_smtp_port'], $GLOBALS['rmail_smtp_helo'], $GLOBALS['rmail_smtp_auth'], $GLOBALS['rmail_smtp_username'], $GLOBALS['rmail_smtp_password']);
				// v3.5 You might have sent $from in the parameters, or you might get it from the template.
				// This is just the default.
				//$mail->setFrom($GLOBALS['rmail_from']);
				$useFrom = $GLOBALS['rmail_from'];
				
				$to = $email['to'];
				// #516 Try to stop odd characters corrupting the template.
				// No, you can't use the cache otherwise all emails in this batch get the same data
				$useCache = false;
				
				$emailHTML = $this->templateOps->fetchTemplate("emails/".$templateName, $email['data'], $useCache);
				
				// Get the subject of the email from the <title></title> tag
				$mail->setSubject($this->getSubjectFromHTMLTitle($emailHTML));
				$mail->setHTML($emailHTML);
	
				// Check if there is a from in the template - will only be expecting one
				$templateFrom = urldecode($this->getFromFromTemplate($emailHTML)); 
				if (isset($templateFrom) && $templateFrom!='') {
					$useFrom = $templateFrom;
				}
				//$useFrom = "\"Adrian Raper, Clarity\" <adrian@clarityenglish.com>";
				$mail->setFrom($useFrom);
				
				// Check if any cc or bcc from the template (must be written in the header in comments)
				$ccFromTemplate = $this->getCcFromTemplate($emailHTML);
				$ccArray = ($ccFromTemplate) ? array($ccFromTemplate) : array(); 
				$bccFromTemplate = $this->getBccFromTemplate($emailHTML);
				$bccArray = ($bccFromTemplate) ? array($bccFromTemplate) : array(); 
				
				// Check if there is any cc or bcc set in the $email object
				if (isset($email['cc'])) {
					$ccArray = array_merge($ccArray,$email['cc']);
				}
				if (isset($email['bcc'])) {
					$bccArray = array_merge($bccArray,$email['bcc']);
				}
				// implode and explode to make certain that there are no comma delimitted string as single elements
				$ccArray = explode(",", implode(",", $ccArray));
				$bccArray = explode(",", implode(",", $bccArray));
				// Use a marker to be able to split cc and bcc later
				$bccStartMarker = array('bccStart');
	
				// I would like to remove any duplicates - which can easily happen for resellers
				// Remove to from cc and bcc
				$toArray = array($email['to']);
				$fullArray = array_unique(array_merge($toArray, $ccArray, $bccStartMarker, $bccArray));
				//$fullArray = array_merge($toArray, $ccArray, $bccStartMarker, $bccArray);
				// Dump the 'to'
				array_shift($fullArray);
				// Find the bccStartMarker to split cc and bcc
				$bccKey = array_search('bccStart',$fullArray);
				$ccArray = array_slice($fullArray, 0, $bccKey);
				$bccArray = array_slice($fullArray, $bccKey + 1);
				
				// Put cleaned data into the mail class
				$mail->setCc(implode(",",$ccArray));
				$mail->setBcc(implode(",",$bccArray));
				//echo 'final cc='.implode(",", $ccArray);
				//echo 'final bcc='.implode(",", $bccArray);
	
				// Does the template list any attachment file?
				if ($this->getAttachmentFromTemplate($emailHTML)) {
					//echo "try to add ".$this->getAttachmentFromTemplate($emailHTML);
					$attachments = array(new fileAttachment($this->getAttachmentFromTemplate($emailHTML)));
				} else {
					$attachments = array();
				}
				
				// Add any attachments in the email
				// See subscriptionOps->sendSupplierEmail for example of sending attachments in emailArray
				if (isset($email['attachments'])) {
					//$attachments = $email['attachments'];
					$attachments = array_merge($attachments, $email['attachments']);
				}
				if ($attachments) {
					foreach ($attachments as $attachment) {
						$mail->addAttachment($attachment);
					}
				}
				// Just for testing if I just want the emails to come to me
				//$to = 'adrian.raper@gmail.com';
				//$mail->setCc('');
				//$mail->setBcc('');
				
				// Do the send
				$result = $mail->send(array($to), "smtp");
				$ccList = implode(",",$ccArray);
				$bccList = implode(",",$bccArray);
				if (!$result) {
					$logMsg = "Email error: ".$mail->errors[0]." sending $to with template $templateName";
					// gh#226
					throw new Exception($mail->errors[0]);
					
				} else {
					$logMsg = "Sent email to $to with template $templateName and subject {$this->getSubjectFromHTMLTitle($emailHTML)} from $useFrom cc $ccList bcc $bccList";
				}
				AbstractService::$log->notice($logMsg);
				
				if (!$result) $errors[] = $mail->errors[0];
			}
		}
		
		// Return any errors
		return $errors;
	}
	
	// gh#226 Function to queue emails for later sending
	function queueEmails($from, $templateName, $emailArray, $delayUntil = null) {
		$errors = array();
		foreach ($emailArray as $email) {
			// Make sure that you are storing valid JSON data
			$json_data = json_encode($email);
			// This is only PHP5.3
			//if (json_last_error() === JSON_ERROR_NONE) { 
   			if ($json_data != FALSE) { 
   				
   				// It shouldn't happen, but if F_To is empty, just junk the email
   				if (!isset($email['to'])) {
   					$errors[] = 'No TO field for email to account '.$email['data']['account']->name;	
   					echo 'No TO field for email to account '.$email['data']['account']->name;	
   				} else {
					$sql = 	<<<EOD
							INSERT INTO T_PendingEmails
							(`F_To`,`F_TemplateID`,`F_Data`,`F_RequestTimestamp`, `F_DelayUntil`)
							VALUES (?,?,?,?,?); 
EOD;
					$rs = $this->db->Execute($sql, array($email['to'], $templateName, $json_data, date('Y-m-d G:i:s'), $delayUntil));
					if (!$rs) $errors[] = $rs->lastDBError();
   				}
   			} else {
				// This is only PHP5.3
   				//$errors[] = json_last_error();
   				$errors[] = 'JSON encoding error';
   			}			
		}	
		return $errors;
	}
	
	// gh#982
	function removeQueuedEmails($emailID, $to, $templateNames) {
		$errors = array();
		if (isset($emailID)){
			$sql = 	<<<EOD
				DELETE FROM T_PendingEmails
				WHERE `F_EmailID` = ?  
				AND `F_Attempts` = 0; 
EOD;
			$rs = $this->db->Execute($sql, array($emailID));
			if (!$rs) $errors[] = $rs->lastDBError();
		}else{
			foreach ($templateNames as $templateName) { 
				if ($templateName){
					if(isset($to)){
						$sql = 	<<<EOD
							DELETE FROM T_PendingEmails
							WHERE `F_To` = ? 
							AND `F_TemplateID` = ?  
							AND `F_Attempts` = 0; 
EOD;
						$rs = $this->db->Execute($sql, array($to, $templateName));
						if (!$rs) $errors[] = $rs->lastDBError();
					}
				}
			}
		}
		return $errors;
	}
	
	// A version of the above to cope with the old way of sending emails (directly via php.mail)
	function sendWebsiteEmails($email) {
		$errors = array();
				
		// Configure the Rmail object.  As there is no removeAttachments method we need to do this once per mail.
		$mail = new Rmail();	
		$mail->setHTMLCharset('UTF-8');
		$mail->setTextCharset('UTF-8');
		// BUG. Getting odd spaces added into the sent email (especially in filenames of links)
		//$mail->setTextEncoding(new EightBitEncoding());
		//$mail->setHTMLEncoding(new EightBitEncoding());
		$mail->setTextEncoding(new Base64Encoding());
		$mail->setHTMLEncoding(new Base64Encoding());
		$mail->setSMTPParams($GLOBALS['rmail_smtp_host'], $GLOBALS['rmail_smtp_port'], $GLOBALS['rmail_smtp_helo'], $GLOBALS['rmail_smtp_auth'], $GLOBALS['rmail_smtp_username'], $GLOBALS['rmail_smtp_password']);
		// v3.5 You might have sent $from in the parameters, or you might get it from the template.
		// This is just the default.
		//$mail->setFrom($GLOBALS['rmail_from']);
		$useFrom = $GLOBALS['rmail_from'];
		
		$to = $email['to'];
		$from = $email['from'];
		//$from = "\"Nicole Lung, Clarity\" <news@clarityenglish.com>";
		
		// Get the subject of the email from the <title></title> tag
		if (isset($email['subject'])) {
			$subject = $email['subject'];
		} else {
			$subject = "Email from Clarity";
		}
		$mail->setSubject($subject);
		$mail->setHTML($email['body']);
		$mail->setFrom($from);
		if (isset($email['cc'])) {
			$mail->setCc($email['cc']);
		}
		if (isset($email['bcc'])) {
			$mail->setBcc($email['bcc']);
		}
		
		// Add any attachments
		if (isset($email['attachments'])) {
			$attachments = $email['attachments'];
			if ($attachments) {
				foreach ($attachments as $attachment) {
					$mail->addAttachment($attachment);
				}
			}
		}
		
		// Do the send (or display)
		if (isset($email['cc'])) {
			$ccList = $email['cc'];
		} else {
			$ccList = '';
		}
		if (isset($email['transactionTest']) && $email['transactionTest']) {
			echo "email to: $to from: $from cc: $ccList<br/>subject: $subject<br/>{$email['body']}<br/><br/>";
		} else {
			$result = $mail->send(array($to), "smtp");
			if (!$result) {
				$logMsg = "Email error: ".$mail->errors[0]." sending $to from websiteMail";
			} else {
				$logMsg = "Sent websiteMail to $to from $from subject $subject cc $ccList";
			}
			AbstractService::$log->notice($logMsg);
			if (!$result) $errors = $mail->errors;
		}
		
		// Return any errors
		return $errors;
	}

	// Used by EmailGateway to send a few direct emails, no account information used
	function sendDirectEmails($emailArray) {
		foreach ($emailArray as $emailAPI) {
			$this->sendDirectEmail($emailAPI);
		}
	}

	// Used by EmailGateway to send a direct email, no account information used
	// Remember that in the template you have to use {$body.name} format rather than the php $body['name']
	function sendDirectEmail($emailAPI) {
		$emailArray = array("to" => $emailAPI->to,
							"data" => array("body" => $emailAPI->data)
							);
		if ($emailAPI->cc) {
			array_splice($emailArray, 2 , 0, array("cc" => $emailAPI->cc));
		}
							
		// Check that the template exists
		if (!$this->templateOps->checkTemplate('emails', $emailAPI->templateID)) {
			throw new Exception("This template doesn't exist. /emails/{$emailAPI->templateID}");
			//exit(0);
		}
		
		// You can avoid sending the email if you are testing
		if (isset($emailAPI->transactionTest) && ($emailAPI->transactionTest=='true')) {
			echo "<b>send {$emailAPI->templateID}, to: ".$emailAPI->to."</b><br/><br/>";
		} else {
			if (isset($emailAPI->immediateDispatch) && ($emailAPI->immediateDispatch)) {
				$errors = $this->sendEmails("", $emailAPI->templateID, array($emailArray), true);
			} else {
				$errors = $this->sendEmails("", $emailAPI->templateID, array($emailArray));
			}
		}
		// What about handling errors?
		if (!empty($errors)) {
			throw new Exception("Email error ".$errors[0]);
		}
		return true;
	}
	
	// TODO: Use emailAPI.
	function sendOrEchoEmail($account, $emailData, $templateID) {
	//function sendOrEchoEmail($emailAPI) {
		$emailArray = array();
		$emailArray[] = array("to" => $account->adminUser->email
							,"data" => $emailData
							,"cc" => $account->email != $account->adminUser->email ? array($account->email) : array()
							);
		// Set up line breaks for whether this is outputting to html page or a text file
		if (isset($_SERVER["SERVER_NAME"])) {
			$newLine = '<br/>';
		} else {
			$newLine = "\n";
		}
		if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
			// Log for running as a script
			echo $account->name.', '.$account->adminUser->email.$newLine;
			// Need to handle errors
			$errors = $this->sendEmails("", $templateID, $emailArray);
		} else {
			if ($account->email != $account->adminUser->email && $account->email) {
				echo "<b>Email: ".$account->adminUser->email.", cc: ".$account->email."</b> $account->name, $account->id$newLine";
			} else {
				echo "<b>Email: ".$account->adminUser->email."</b> $account->name, $account->id)$newLine";
			}
			echo $this->fetchEmail($templateID, $emailData)."<hr/>";
		}
	}

	/**
	 * Given a block of HTML text this extracts the text between the <title></title> node for use as the email subject
	 */
	private function getSubjectFromHTMLTitle($emailHTML) {
		if (preg_match("/<title>(.*)<\/title>/i", $emailHTML, $out))
			return $out[1];
	}
	private function getFromFromTemplate($emailHTML) {
		if (preg_match("/<from>(.*)<\/from>/i", $emailHTML, $out))
			//echo '++'.$out[1].'++';
			return $out[1];
	}
	private function getCcFromTemplate($emailHTML) {
		if (preg_match("/<cc>(.*)<\/cc>/i", $emailHTML, $out))
			return $out[1];
	}
	private function getBccFromTemplate($emailHTML) {
		if (preg_match("/<bcc>(.*)<\/bcc>/i", $emailHTML, $out))
			return $out[1];
	}
	private function getAttachmentFromTemplate($emailHTML) {
		if (preg_match("/<attachment>(.*)<\/attachment>/i", $emailHTML, $out))
			return $out[1];
	}
}
?>