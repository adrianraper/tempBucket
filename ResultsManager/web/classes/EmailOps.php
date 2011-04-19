<?php
require_once($GLOBALS['rmail_libs']."/Rmail.php");

class EmailOps {
	
	var $db;
	
	function EmailOps($db = null) {
		$this->db = $db;
		
		$this->templateOps = new TemplateOps($db);
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
	 */
	function sendEmails($from, $templateName, $emailArray, $useCache = false) {
		$errors = array();
				
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
			$data = $email['data'];
			
			$emailHTML = $this->templateOps->fetchTemplate("emails/".$templateName, $data, $useCache);
			
			// Get the subject of the email from the <title></title> tag
			$mail->setSubject($this->getSubjectFromHTMLTitle($emailHTML));
			$mail->setHTML($emailHTML);

			// Check if there is a from in the template - will only be expecting one
			$templateFrom = $this->getFromFromTemplate($emailHTML); 
			if (isset($templateFrom) && $templateFrom!='') {
				$useFrom = $templateFrom;
			}
			$mail->setFrom($useFrom);
			
			// Check if there is any cc or bcc set in the $email object
			$ccArray = array($this->getCcFromTemplate($emailHTML)); 
			$bccArray = array($this->getBccFromTemplate($emailHTML));
			if (isset($email['cc'])) {
				$ccArray = array_merge($ccArray,$email['cc']);
			}
			if (isset($email['bcc'])) {
				$bccArray = array_merge($bccArray,$email['bcc']);
			}

			// Then check if any cc or bcc from the template (must be written in the header in comments)
			//$mail->setCc('adrian.raper@clarityenglish.com');
			//function notEmpty($v) {
			//	if ($v=="" || $v==null) return false;
			//	return true;
			//}
			//$ccArray = array_filter($ccArray,"notEmpty");
			//$bccArray = array_filter($bccArray,"notEmpty");

			$mail->setCc(implode(",",$ccArray));
			$mail->setBcc(implode(",",$bccArray));
			//echo "cc to ".implode(",", $ccArray)." bcc=".implode(",", $bccArray);
			
			// Add any attachments
			if (isset($email['attachments'])) {
				$attachments = $email['attachments'];
				if ($attachments) {
					foreach ($attachments as $attachment) {
						$mail->addAttachment($attachment);
					}
				}
			}
			
			// Do the send
			$result = $mail->send(array($to), "smtp");
			$ccList = implode(",",$ccArray);
			$logMsg = "Sent email to $to with template $templateName and subject {$this->getSubjectFromHTMLTitle($emailHTML)} from $useFrom cc $ccList";
			if (!$result) $logMsg.= " error:".var_dump($mail->errors);
			AbstractService::$log->notice($logMsg);
			
			if (!$result) $errors[] = $mail->errors;
		}
		
		// Return any errors
		return $errors;
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
}
?>