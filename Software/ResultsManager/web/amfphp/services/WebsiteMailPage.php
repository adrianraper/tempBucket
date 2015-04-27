<?php
/*
 * This script takes over the old website mailpage which used php mail hosted on Rackspace Linux
 * In time it should be replaced by calls to EmailGateway directly from the enquiry scripts.
 */

require_once(dirname(__FILE__)."/EmailService.php");

// Shouldn't all the following be in EmailService?
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/trigger/EmailAPI.php");
require_once($GLOBALS['smarty_libs']."/Smarty.class.php");
$smarty = new Smarty();
$smarty->template_dir = $GLOBALS['smarty_template_dir'];
$smarty->compile_dir = $GLOBALS['smarty_compile_dir'];
$smarty->config_dir = $GLOBALS['smarty_config_dir'];
$smarty->cache_dir = $GLOBALS['smarty_cache_dir'];
$smarty->plugins_dir[] = $GLOBALS['smarty_plugins_dir'];

$emailService = new EmailService();
session_start();
date_default_timezone_set('UTC');

$serverLocation = 'http://www.clarityenglish.com/';
$returnTopPage = false;
$returnPage = $serverLocation."email/oops.php";
$cc="";

	// Information is sent to us as an input from cURL
	$postXML = file_get_contents("php://input");
/*		$postXML = <<<EOD
requestID=2&customerName=Vivying&customerEmail=vivying@clarityenglish.com&enquiry=test&deliveryMethod=email&institution=Clarity&phone=&address=24 Pak Kong Au
&hearFrom=Not choosen&mailingList=yes&country=Hong Kong&price=Active_Reading&afterdemo=&contactMethod=both email and phone&sector=Student&message=Can I Have one Please !
EOD;
*/
	if (isset($postXML) && ($postXML!='')) {
//		$postXML = $_POST['postXML'];
/*		
	if (true) {
		$postXML = <<<EOD
requestID=2&customerName=Dr Adrian Raper's&customerEmail=adrian@noodles.hk&enquiry=Price List, Newsletter, Clarity Guide&deliveryMethod=email&institution=Clarity&phone=&address=24 Pak Kong Au
&hearFrom=Not choosen&mailingList=yes&country=Hong Kong&price=Active_Reading&afterdemo=&contactMethod=both email and phone&sector=Student&message=Can I Have one Please !
EOD;
*/
		// based on the information sent in the POST, create the headers that we want to email, template etc
		// then use the EmailGateway to send
		parse_str($postXML, $data);
		// Validate the key fields
		$errorInfo = false;
		if (!isset($data['requestID'])) {
			$errorInfo = 'error=1&message=missing requestID';
		}
		// Default values
		if (!isset($data['sector'])) {
			$data['sector'] = 'Teacher';
		}
		if ($errorInfo) {
			echo $errorInfo;
			exit(0);
		}

		switch ($data['requestID']) {
			case 1:
				$toClarity = sendEmail(1);
				if ($data['sector'] == "Home user" || $data['sector'] == "Student") {
					$toCustomer = sendEmail(4) && sendEmail(22);
					if ( ($toClarity) AND ($toCustomer) )
						$returnPage = "http://www.ClarityLifeSkills.com";
					$returnTopPage = true;
				} else {
					$toCustomer = sendEmail(4);			
					if ( ($toClarity) AND ($toCustomer) ) {
						$returnPage = "$serverLocation/email/thankyou.php";
					} else {
						$returnPage = "$serverLocation/email/oops.php";
					}
					$returnTopPage = true;
				}
				break;
			case "2": # Price enquiry
				$toClarity = sendEmail(2);
				if ($data['sector'] == "Home user" || $data['sector'] == "Student") {
					$toCustomer = sendEmail(4);// && sendEmail(22);
					if ( ($toClarity) AND ($toCustomer) )
						$returnPage = "http://www.ClarityLifeSkills.com";
					$returnTopPage = true;
				} else if ($data['sector'] == "IELTS candidate") {
					$toCustomer = sendEmail(4);
					if ( ($toClarity) AND ($toCustomer) )
						$returnPage = "http://www.ieltspractice.com";
					$returnTopPage = true;
				} else {
					$toCustomer = sendEmail(4);			
					if ( ($toClarity) AND ($toCustomer) )
						$returnPage = "$serverLocation/email/enquiry_thanks.php";
					else
						$returnPage = "$serverLocation/email/enquiry_oops.php";
					$returnTopPage = false;
				}
				break;
				case "3": # Forget Password
					$toClarity = sendEmail(3);
					$toCustomer = sendEmail(10);
					if ( ($toClarity) AND ($toCustomer) )
						$returnPage = "$serverLocation/email/forgot_thanks.php?email=".$data['fpw_email'];
					else
						$returnPage = "$serverLocation/email/forgot_oops.php?email=".$data['fpw_email'];
						$returnTopPage = false;
					break;

				case "4": # Licence Renewal
					$toClarity = sendEmail(5);
					$toCustomer = sendEmail(6);
					if ( ($toClarity) AND ($toCustomer) )
						$returnPage = "$serverLocation/email/licenceRenewal_Success.php?email=".$data['email'];
					else
						$returnPage = "$serverLocation/email/licenceRenewal_Failure.php?email=".$data['email'];
						$returnTopPage = false;
					break;

				case "5": # request demo
					$toClarity = sendEmail(7);
					$toCustomer = sendEmail(4);
					if ( ($toClarity) AND ($toCustomer) )
						$returnPage = "$serverLocation/email/requestdemo_thanks.php";
					else
						$returnPage = "$serverLocation/email/requestdemo_oops.php";
						$returnTopPage = false;
					break;

				case "6": # clarity competition; NOT IN USE anymore
					$toClarity = sendEmail(8);
					$toCustomer = sendEmail(9);
					if ( ($toClarity) AND ($toCustomer) )
						$returnPage = "$serverLocation/email/comp_thanks.php";
					else
						$returnPage = "$serverLocation/email/comp_oops.php";
						//echo "toClarity=$toClarity, toCustomer=$toCustomer";
						$returnTopPage = true;
					break;

				case "7": # Forget Password - VSB page
					$toClarity = sendEmail(3);
					$toCustomer = sendEmail(10);
					if ( ($toClarity) AND ($toCustomer) )
						$returnPage = "$serverLocation/vsb/forgot_thanks.php?email=".$data['fpw_email'];
					else
						$returnPage = "$serverLocation/vsb/forgot_oops.php?email=".$data['fpw_email'];
						$returnTopPage = false;
					break;

				case "8": # unsubscribe Loud and Clear
					$toClarity = sendEmail(11);
					if ($toClarity){
						$returnPage = "$serverLocation/email/unsubscribeLnC_Success.php";
							echo 'true ';
							echo $returnPage;
							}
					else{
						$returnPage = "$serverLocation/email/unsubscribeLnC_Failure.php";
						$returnTopPage = true;
							echo 'false ';
							echo $returnPage;
							}
					break;

				case "9": # YIF promotion
					$toClarity = sendEmail(12);
					if ($toClarity)
						$returnPage = "$serverLocation/email/YIFpromotion_thanks.php";
					else
						$returnPage = "$serverLocation/email/YIFpromotion_oops.php";
						$returnTopPage = false;
					break;

				case "10": # CLS email subscripton
					$toClarity = sendEmail(13);
					if ($toClarity)
						$returnPage = "yes";
					else
						$returnPage = "no";
					break;
					$returnTopPage = false;
					
				case "11": # CLS promotion
					$toClarity = sendEmail(14);
					$toCustomer = sendEmail(15);
					if ( ($toClarity) AND ($toCustomer) )
						$returnPage = "http://www.ClarityLifeSkills.com/promo/thanks.php";
					else
						$returnPage = "http://www.ClarityLifeSkills.com/promo/oops.php";
						//echo "toClarity=$toClarity, toCustomer=$toCustomer";
						$returnTopPage = true;
					break;
					
				case "12": # cls online survey
					$toCustomer = sendEmail(16);
					if ( $toCustomer ) {
						$returnPage = "thanks.php";
					}
					else {
						$returnPage = "oops.php";
					}
					$returnTopPage = true;
					echo $returnPage;
					break;
					
				case "13": # IYJ online registration
					$toClarity = sendEmail(17);
					$toCustomer = sendEmail(18);
					if ( ($toClarity) AND ($toCustomer) )
						$returnPage = "http://www.iyjonline.com/email/thanks.php";
					else
						$returnPage = "http://www.iyjonline.com/email/oops.php";
						//echo "toClarity=$toClarity, toCustomer=$toCustomer";
						$returnTopPage = true;
					break;
					
				case "14": 
					$toClarity = sendEmail(19);
					$returnTopPage = false;
					break;
					
				case "15": # CLS subscribe Newsletter
					$toClarity = sendEmail(20);
					$toCustomer = sendEmail(21) && sendEmail(22);
					if($toCustomer) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;
					
				case "16":	# CLS unsubscribe Newsletter
					$toClarity = sendEmail(23);
					if($toClarity) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;
					
				case "17":
					$toClarity = sendEmail(24);
					$toCustomer = sendEmail(25);
					$returnTopPage  = false;
					if ( ($toClarity) AND ($toCustomer) )
						$returnPage = "http://www.ilearnielts.com/email/thanks.php";
					else
						$returnPage = "http://www.ilearnielts.com/email/oops.php";
					break;
				
				case "18": # CLS contact us
					$toClarity = sendEmail(26);
					$toCustomer = sendEmail(27);
					if ( ($toClarity) AND ($toCustomer) ) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;
				
				case "19": #ce.com support site enquiry form
				/* Original footer enquiry form
					$toClarity = sendEmail(28);
					$toCustomer = sendEmail(29);
					if ( ($toClarity) AND ($toCustomer) ) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;
				*/
				$toClarity = sendEmail(28);
				if ($data['sector'] == "Home user" || $data['sector'] == "Student") {
					$toCustomer = sendEmail(29) && sendEmail(22);
					//if ( ($toClarity) AND ($toCustomer) )
					//	$returnPage = "http://www.ClarityLifeSkills.com";
					//$returnTopPage = true;
				} else if ($data['sector'] == "IELTS candidate") {
					$toCustomer = sendEmail(29);
					//if ( ($toClarity) AND ($toCustomer) )
					//	$returnPage = "http://www.ieltspractice.com";
					//$returnTopPage = true;
				} else {
					$toCustomer = sendEmail(29);			
					//if ( ($toClarity) AND ($toCustomer) )
					//	$returnPage = "$serverLocation/email/enquiry_thanks.php";
					//else
					//	$returnPage = "$serverLocation/email/enquiry_oops.php";
					//$returnTopPage = false;
				}
				if ( ($toClarity) AND ($toCustomer) ) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;
				case "20": #ieltspractice.com support site enquiry form
					$toClarity = sendEmail(30);
					$toCustomer = sendEmail(31);
					if ( ($toClarity) AND ($toCustomer) ) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;	
				case "21": #ce.com new support site enquiry form
					$toClarity = sendEmail(32);
					$toCustomer = sendEmail(33);
					if ( ($toClarity) AND ($toCustomer) ) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;	
				case "22": #ip.com 6-day IELTS tips email subscription
					$toClarity = sendEmail(34);
					$toCustomer = sendEmail(35);
					if ( ($toClarity) AND ($toCustomer) ) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;
				case "23": #ip.com 6-day IELTS tips email unsubscribe
					$toClarity = sendEmail(36);
					if ($toClarity) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;
				case "24": #201415 Loud and Clear 37
					$toClarity = sendEmail(37);
					$toCustomer = sendEmail(38);
					if ( ($toClarity) AND ($toCustomer) ) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;
				case "25": #China Road to IELTS FV Welcome Email
					$toCustomer = sendEmail(39);
					if ( $toCustomer ) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;
				case "26": #China Road to IELTS LM Welcome Email
					$toCustomer = sendEmail(40);
					if ( $toCustomer ) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;
				case "27": #IELTS tips app promo EDM for IP.com
					$toCustomer = sendEmail(41);
					if ( $toCustomer ) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;
				case "98": #S3 upload status
					$toClarity = sendEmail(98);
					if ($toClarity) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;
				case "996": #China Server monitoring alert
					$toClarity = sendEmail(996);
					if ($toClarity) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;	
				case "997": #China Server monitoring warning
					$toClarity = sendEmail(997);
					if ($toClarity) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;	
				case "998": #Europe Server monitoring alert
					$toClarity = sendEmail(998);
					if ($toClarity) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;	
				case "999": #Europe Server monitoring warning
					$toClarity = sendEmail(999);
					if ($toClarity) {
						echo 'true';
					}
					else {
						echo 'false';
					}
					break;					
				default:
					$errorInfo = 'error=1&message=unexpected requestID';
		}
					
					// This is old processing to return to a different page
					// Skip whilst debugging
					if ($data['requestID']!="10" 
						&& $data['requestID']!='8'
						&& $data['requestID']!='12'
						&& $data['requestID']!='15'
						&& $data['requestID']!='16'
						&& $data['requestID']!='18'
						&& $data['requestID']!='21'
						&& $data['requestID']!='22'
						&& $data['requestID']!='23'
						&& $data['requestID']!='24'
						&& $data['requestID']!='25'
						&& $data['requestID']!='26'
						&& $data['requestID']!='27'
						&& $data['requestID']!='98'
						&& $data['requestID']!='996'
						&& $data['requestID']!='997'
						&& $data['requestID']!='998'
						&& $data['requestID']!='999'
						) {
						// Is there a way to redirect php to a parent frame? seems complicated.
						if ($returnTopPage) {
							echo("<script language=\"javascript\">");
							echo("top.location.href = \"$returnPage\";");
							echo("</script>");
						} else {
							echo("<script language=\"javascript\">");
							echo("this.location.href = \"$returnPage\";");
							echo("</script>");  
						}
					}
	} else {
		echo "No data sent";
	}
	
function sendEmail($templateID) {

	global $data;
	global $emailService;
	global $serverLocation;
	
	// Set common variables
	$clarityTest = "Clarity Testing <unfrankie@gmail.com>";
	$clarityNicole = "Nicole Lung <nicole.lung@clarityenglish.com>";
	$clarityVivi = "Vivying Cheng<vivying.cheng@clarityenglish.com>";
	$claritySales = "ClarityEnglish <sales@clarityenglish.com>";
	$clarityNews = "Clarity English <news@clarityenglish.com>";
	$clarityInfo = "Clarity Info <info@clarityenglish.com>";
	#not used
	//$clarityAdmin = "Clarity Admin <news@clarityenglish.com>";
	$claritySupport = "Clarity Support <support@clarityenglish.com>";
	$clarityAccount = "Clarity Accounts <accounts@clarityenglish.com>";
	$clarityCLSSupport = "ClarityLifeSkills <support@claritylifeskills.com>";
	$clarityIELTSSupport = "IELTS Practice<support@ieltspractice.com>";
	$clarityIELTSSupportNoreply = "IELTS Practice <noreply@ieltspractice.com>";
	$clarityR2ISupport = "Road To IELTS Support Team<support@roadtoielts.com>";
	#not used
	//$clarityCLSAdmin = "ClarityLifeSkills Admin <support@claritylifeskills.com>";
	
	// Why do I need to specify the full URL?
	//$templateFolder = "/email/template";	
	$templateFolder = $serverLocation."email/template";	
	
	// For each template, format it and add the variables you need
	switch ($templateID) {
		case 1: # Loud and Clear from catalogue page - to Clarity
			$body = file_get_contents("$templateFolder/email_loudandclear_toClarity.htm");
			$to = $claritySales;
			$subject = "Subscribe ".$data['enquiry'];
			$from = $clarityNews;
			//$cc = ''; 
			//$bcc = '';
			break;

		case 2: # Price enquiry page - to Clarity
			$body = file_get_contents("$templateFolder/email_priceEnquiry_toClarity.htm");		
			$subject = $data['sector'] . " enquiry: Price enquiry (" . date(DATE_RFC822) .")"; 

			$to = $claritySales;
			
			If ($data['price']<>"") {
				$subject .= " - for ". $data['price'];
				$data['price'] = "?price=". $data['price'];			
			} else If ($data['afterdemo']<>"") {
				$subject = "After demo " . $subject;
				$subject .= " - for ". $data['afterdemo'];
				$data['price'] = "?afterdemo=". $data['afterdemo'];			
			}
			$from = $clarityNews;
			break;
			
		case 3: # Forget Password
			$body = file_get_contents("$templateFolder/email_forgetPassword_toClarity.htm");		
			$to = $claritySupport;
			$subject = "Forget Password";
			$from = $claritySupport;
			break;

		case 4: # enquiry form - to customer
			if($data['sector']=="Home user"||$data['sector']=="Student") { //for student
				// The home user/student email doesn't need a header or footer
				//$body = file_get_contents("$templateFolder/email_enquiry_toHomeUser_header.htm");
				//$body .= file_get_contents("$templateFolder/email_enquiry_toHomeUser_contents.htm");
				$body = file_get_contents("$templateFolder/email_enquiry_toHomeUser_master.htm");
				$from = $clarityCLSSupport;
			} else if($data['sector']=="IELTS candidate") { //for IELTS Candidates
				$body = file_get_contents("$templateFolder/email_enquiry_toIELTScandidates_byEmail.htm");
				$from = $clarityIELTSSupport;
			} else { //not student
				$body = file_get_contents("$templateFolder/email_enquiry_toCustomer_header.htm");
				if ( ($data['deliveryMethod']=="email, post") OR ($data['deliveryMethod']=="post") ) {
					$body .= file_get_contents("$templateFolder/email_enquiry_toCustomer_byPost.htm");
				}
				if ( ($data['deliveryMethod']=="email, post") OR ($data['deliveryMethod']=="email") ) {
					$body .= file_get_contents("$templateFolder/email_enquiry_toCustomer_byEmail.htm");
				}
				$from = $clarityNews;
				$body .= file_get_contents("$templateFolder/email_enquiry_toCustomer_footer.htm");
			}
			// This only leads to complications
			//$to = "'".$data['customerName']."' <".$data['customerEmail'].">";
			$to = $data['customerEmail'];
			if ($data['requestID']=="1") {
				$subject = "Clarity Guide and Loud and Clear";
			} else if ($data['requestID']=="2") {
				$subject = "Clarity English enquiry acknowledgement";
			} else if ($data['requestID']=="5") {
				$subject = "Request demo CD from Clarity";
			}
			break;
			
		case 5: # renew licence - to Clarity
			$body = file_get_contents("$templateFolder/email_licenceRenewal_toClarity.htm");		
			$to = $clarityAccount;
			$subject = "Licence Renewal - ".$data['accountName']."(".$data['accountRoot'].")";
			$from = clarityAccount;
			break;

		case 6: # renew licence - to customer
			$body = file_get_contents("$templateFolder/email_licenceRenew_toCustomer.htm");
			$to = $data['email'];
			$subject = "Licence Renewal Acknowledgement";
			$from = $clarityNews;
			break;

		case 7: # request demo page - to Clarity
			$body = file_get_contents("$templateFolder/email_requestdemo_toClarity.htm");		
			$to = $clarityNews;
			
			$subject = "Request a demo";
			If ($data['demoCD']<>"") {
				$subject .= " - for ". $data['demoCD'];
				$data['demoCD'] = "?demoCD=". $data['demoCD'];			
			}
			$from = $clarityNews;
			break;

		case 8: # clarity competition - to customer; NOT IN USE anymore
			$body = file_get_contents("$templateFolder/email_clarityCompetition_toCustomer.htm");
			$to = $data['customerEmail'];
			$subject = "Clarity Competition Acknowledgement";
			$from = $clarityInfo;
			break;

		case 9: # clarity competition - to Clarity; NOT IN USE anymore
			$body = file_get_contents("$templateFolder/email_clarityCompetition_toClarity.htm");		
			$to = $clarityNews;
			$subject = "Clarity Competition Answer";
			$from = $clarityNews;
			break;

		case 10: # forget password - to customer
			$body = file_get_contents("$templateFolder/email_forgetPassword_toCustomer.htm");
			$to = $data['fpw_email'];
			$subject = "Login details for Clarity programs";
			$from = $claritySupport;
			break;

		case 11: # unsubscribe Loud and Clear - to Clarity
			$body = file_get_contents("$templateFolder/email_unsubscribeLnC_toClarity.htm");		
			$to = $clarityNews;
			$subject = "Unsubscribe to Clarity Newsletter and Guide";
			$from = $clarityInfo;
			break;

		case 12: # YIF promotion - to Clarity
			$body = file_get_contents("$templateFolder/email_YIFpromotion_toClarity.htm");		
			$to = clarityNews;
			$subject = "YIF promotion";
			$from = $clarityNews;
			break;

		case 13: # CLS Price enquiry page - to Clarity
			$body = file_get_contents("$templateFolder/email_CLS_sendScriptionEmail_toClarity.htm");		
			$to = clarityNews;
			$subject = "Clarity Life Skills email subscription";
			$from = clarityNews;
			break;

		case 14: # CLS promotion - to customer
			$body = file_get_contents("$templateFoldere/email_CPGame_toCustomer.htm");
			$to = $data['customerEmail'];
			$subject = "Thank you for playing the ClarityLifeSkills.com game";
			$from = $clarityCLSSupport;
			break;

		case 15: # CLS promotion - to Clarity
			$body = file_get_contents("$templateFolder/email_CPGame_toClarity.htm");		
			$to = clarityNews;
			$subject = "CLS.com - CP Game Answer";
			$from = $clarityCLSSupport;
			break;
			
		case 16: # CLS online survey - to Customer
			$body = file_get_contents("$templateFolder/email_CLS_survey_toCustomer.htm");
			$to = $data['customerEmail'];
			$subject = "Thank you for completing the ClarityLifeSkills.com survey";
			$from = $clarityCLSSupport;
			break;

		case 17: # IYJ Online Registration - to Clarity
			$body = file_get_contents("$templateFolder/email_iyjonline_reg_toClarity.htm");		
			$to = clarityNews;
			$subject = "IYJonline.com - Registration request";
			$from = clarityNews;
			break;

		case 18: # IYJ Online Registration - to customer
			if ( ($data['identity']=='student') OR ($data['identity']=='homeUser') )
				$body = file_get_contents("$templateFolder/email_iyjonline_reg_toStudent.htm");
			else
				$body = file_get_contents("$templateFolder/email_iyjonline_reg_toCustomer.htm");
			$to = $data['email'];
			$subject = "It's Your Job";
			$from = clarityNews;
			break;
			
		case 19: #Credit Card Payment - to Clarity
			$body = file_get_contents("$templateFolder/email_creditCard_payment.htm");
			$to = $clarityAccount;
			$subject = "ClarityEnglish.com Credit Card Payment Notice(invoice number: ".$data['invoice'].")";
			$from = $clarityCLSSupport;
			break;
			
		case 20: #CLS Newsletter Subscription Notification - to Clarity
			$body = file_get_contents("$templateFolder/email_CLS_sendScriptionEmail_toClarity.htm");
			$to = $clarityCLSSupport;
			$subject = "ClarityLifeSkills.com Newsletter subscription";
			$from = $clarityCLSSupport;
			break;
			
		case 21: #CLS Newsletter Subscription Notification - to Customer
			$body = file_get_contents("$templateFolder/email_CLS_sendScriptionEmail_toCustomer.htm");
			$to = $data['customerEmail'];
			$subject = "ClarityLifeSkills, Newsletter subscription";
			$from = $clarityCLSSupport;
			break;

		case 22: #CLS enews - to Customer
			$body = file_get_contents("$templateFolder/email_CLS_enews_toCustomer.htm");
			$to = $data['customerEmail'];
			$subject = "ClarityLifeSkills: Explore new ways to improve your English";
			$from = $clarityCLSSupport;
			break;
			
		case 23: #CLS news letter unsubscribe email - to Clarity
			$body = file_get_contents("$templateFolder/email_CLS_unsubscribe_enews_toClarity.htm");
			$to = $clarityCLSSupport;
			$subject = "Unsubscribe to ClarityLifeSkills.com Newsletter";
			$from = $clarityCLSSupport;
			break;
		
		case 24: #IlearnIELTS prices - to Clarity
			$body = file_get_contents("$templateFolder/email_learnielts_enquiry_toClarity.htm");
			$to = $clarityNews;
			$subject = "iLearnIELTS";
			$from = clarityNews;		
			break;
			
		case 25: #IlearnIETLS prices - to Customer
			if($data['identity']=='student' || $data['identity']=='homeUser') {
				$template_location = "$templateFolder/email_learnielts_enquiry_toStudent.htm";
			}
			else {
				$template_location = "$templateFolder/email_learnielts_enquiry_toCustomer.htm";
			}
			$body = file_get_contents($template_location);
			$to = $data['email'];
			$subject = "iLearnIELTS price enquiry";
			$from = clarityNews;		
			break;

		case 26: # ClarityLifeSkills contact us - to Clarity
			$body = file_get_contents("$templateFolder/email_CLS_contactus_toClarity.htm");
			$to = $clarityCLSSupport;
			$subject = "ClarityLifeSkills.com, Contact us (" . date(DATE_RFC822).")"; 

			$from = $clarityCLSSupport;
			break;
			
		case 27: # ClarityLifeSkills contact us - to Customer
			$body = file_get_contents("$templateFolder/email_CLS_contactus_toCustomer.htm");
			$to = $data['email'];
			$subject = "ClarityLifeSkills enquiry acknowledgement";
			$from = $clarityCLSSupport;
			break;
		/* Original email sent to clarity & customer
		case 28: # CE.com Support site enquiry - to Clarity
			$body = file_get_contents("$templateFolder/email_support_contactus_toClarity.htm");
			$to = $claritySupport;
			$cc = $clarityInfo;
			$subject = "ClarityEnglish.com support site enquiry (" . date(DATE_RFC822) .")"; 

			$from = $data['email'];
			break;
			
		case 29: # CE.com Support site enquiry - to Customer
			$body = file_get_contents("$templateFolder/email_support_contactus_toCustomer.htm");
			$to = $data['email'];
			$subject = "Clarity Support enquiry acknowledgement";
			$from = $claritySupport;
			break;		
		*/	
		case 28: # CE.com Support site enquiry - to Clarity
			$body = file_get_contents("$templateFolder/form_enquiry_toClarity.htm");
			$to = $clarityInfo;
			
			$subject = $data['sector'] . " enquiry: Clarity English information request (" . date(DATE_RFC822) . ")";
			$from = $data['email'];
			break;
			
		case 29: # CE.com  enquiry form - to customer
			if($data['sector']=="Home user"||$data['sector']=="Student") { //for student
				// The home user/student email doesn't need a header or footer
				//$body = file_get_contents("$templateFolder/email_enquiry_toHomeUser_header.htm");
				//$body .= file_get_contents("$templateFolder/email_enquiry_toHomeUser_contents.htm");
				$body = file_get_contents("$templateFolder/form_enquiry_toHomeUser_master.htm");
				$from = $clarityCLSSupport;
			} else if($data['sector']=="IELTS candidate") { //for IELTS Candidates
				$body = file_get_contents("$templateFolder/form_enquiry_toIELTScandidates_byEmail.htm");
				$from = $clarityIELTSSupport;
			} else { //not student
				$body = file_get_contents("$templateFolder/form_enquiry_toCustomer_header.htm");
				$body .= file_get_contents("$templateFolder/email_enquiry_toCustomer_byEmail.htm");				
				$from = $clarityNews;
				$body .= file_get_contents("$templateFolder/email_enquiry_toCustomer_footer.htm");
			}
			// This only leads to complications
			//$to = "'".$data['customerName']."' <".$data['customerEmail'].">";
			$to = $data['email'];
			
			$subject = "Clarity English information request"; 

			break;
		case 30: # ieltspractice.com contact us - to Clarity
			$body = file_get_contents("$templateFolder/email_IPS_contactus_toClarity.htm");
			$to = $clarityIELTSSupport;
			$subject = "IELTSpractice.com, contact us [". $data['category'] . "] (" . date(DATE_RFC822).")"; 

			$from = $clarityIELTSSupport;
			break;
			
		case 31: #  ieltspractice.com contact us - to Customer
			$body = file_get_contents("$templateFolder/email_IPS_contactus_toCustomer.htm");
			$to = $data['email'];
			$subject = "IELTSpractice.com enquiry acknowledgement";
			$from = $clarityIELTSSupport;
			break;	
		case 32: # ce.com new support site contact us - to Clarity
			$body = file_get_contents("$templateFolder/form_enquiry_supportsite_toClarity.htm");
			$subject = $data['userType'] . " enquiry: Support enquiry [". $data['subject'] . "] (" . date(DATE_RFC822).")"; 
			if($data['userType']=="Student") { 
				$to = $clarityCLSSupport;
				$from = $clarityCLSSupport;
			} else if($data['userType']=="Candidate") { //for IELTS Candidates
				$to = $clarityIELTSSupport;
				$from = $clarityIELTSSupport;
			} else { //Teachers, Librarian, Others
				$to = $claritySupport;
				$from = $claritySupport;
			}
			break;
			
		case 33: #  ce.com new support site contact us - to Customer
		
			if($data['userType']=="Student") { 
				$body = file_get_contents("$templateFolder/form_enquiry_toHomeUser_master.htm");
				$from = $clarityCLSSupport;
			} else if($data['userType']=="Candidate") { //for IELTS Candidates
				$body = file_get_contents("$templateFolder/email_enquiry_toIELTScandidates_byEmail.htm");
				$from = $clarityIELTSSupport;
			} else { //Teachers, Librarian, Others
				$body = file_get_contents("$templateFolder/form_enquiry_supportsite_toCustomer.htm");
				$from = $claritySupport;
			}
			$to = $data['email'];
			$subject = "ClarityEnglish support enquiry acknowledgement";
			break;	
			
		case 34: #  ip.com 6-day IELTS tips email subsciption - to Clarity
			$body = file_get_contents("$templateFolder/IP_studyguide_signup_toClarity.htm");
			$to = $clarityIELTSSupport;
			$subject = "IELTSpractice 6-day IELTS tips email subsciption(" . date(DATE_RFC822).")"; 

			$from = $clarityIELTSSupportNoreply;
			break;
			
		case 35: #  ip.com 6-day IELTS tips email subsciption - to Customer
			$to = $data['email'];
			$from = $clarityIELTSSupportNoreply;

			$emailData = array();
			$emailArray = array("to" => $to, "data" => $emailData);
			$templateID = 'IP/studyguide_importantrules';
			$emailService->emailOps->queueEmails($from, $templateID, array($emailArray));
			
			$delayUntil = date("Y-m-d H:i:s", time() + 86400);
			$templateID = 'IP/studyguide_understandtasktypes';
			$emailService->emailOps->queueEmails($from, $templateID, array($emailArray), $delayUntil);
		
			$delayUntil = date("Y-m-d H:i:s", time() + 86400*2);
			$templateID = 'IP/studyguide_speakingtest';
			$emailService->emailOps->queueEmails($from, $templateID, array($emailArray), $delayUntil);

			$delayUntil = date("Y-m-d H:i:s", time() + 86400*3);
			$templateID = 'IP/studyguide_understandspeakers';
			$emailService->emailOps->queueEmails($from, $templateID, array($emailArray), $delayUntil);

			$delayUntil = date("Y-m-d H:i:s", time() + 86400*4);
			$templateID = 'IP/studyguide_timemanagement';
			$emailService->emailOps->queueEmails($from, $templateID, array($emailArray), $delayUntil);

			$delayUntil = date("Y-m-d H:i:s", time() + 86400*5);
			$templateID = 'IP/studyguide_IELTSprepareideas';
			$emailService->emailOps->queueEmails($from, $templateID, array($emailArray), $delayUntil);

			$delayUntil = date("Y-m-d H:i:s", time() + 86400*6);
			$templateID = 'IP/studyguide_subscribetoday';
			$emailService->emailOps->queueEmails($from, $templateID, array($emailArray), $delayUntil);
			
			return true;
			break;
		case 36: #ip.com 6-day IELTS tips email unsubscribe - to Clarity
			$body = file_get_contents("$templateFolder/IP_unsubscribe_toClarity.htm");
			$to = $clarityIELTSSupport;
			//$cc = $clarityR2ISupport;
			$subject = "IELTSpractice 6-day IELTS tips email unsubscribe(" . date(DATE_RFC822).")"; 

			$from = $clarityIELTSSupportNoreply;
			$templateNames = array(	'IP/studyguide_importantrules',
									'IP/studyguide_understandtasktypes',
									'IP/studyguide_speakingtest',
									'IP/studyguide_understandspeakers',
									'IP/studyguide_timemanagement',
									'IP/studyguide_IELTSprepareideas',
									'IP/studyguide_subscribetoday'
								);
			$emailService->emailOps->removeQueuedEmails(null,$data['email'], $templateNames);
			
			
			break;
		case 37: #1415 Loud and Clear 37 - to Clarity
			$body = file_get_contents("$templateFolder/trial_enquiry_toClarity_byEmail.htm");
			$to = $claritySales;
			$subject = $data['sector'] ." enquiry: Trial request from Loud and Clear 37(" . date(DATE_RFC822).")"; 

			$from = $claritySales;
			break;
		case 38: #1415 Loud and Clear 37 - to Customer
			$body = file_get_contents("$templateFolder/trial_enquiry_toCustomer_byEmail.htm");
			$to = $data['email'];
			$subject = "ClarityEnglish trial request acknowledgement"; 

			$from = $claritySales;
			break;
		case 39: #China Road to IELTS FV Welcome Email - to Customer
			$to = $data['customerEmail'];
			$from = $clarityR2ISupport;

			$emailData = array(	'name'=>$data['customerName'],
								'email'=>$data['customerEmail'],
								'password'=>$data['password'],
								'prefix'=>$data['prefix'],
								'productCode'=>(($data['productCode']==52)?"AC":"GT"),
								'expiryDate'=>$data['expiryDate']);
			$emailArray = array("to" => $to, "data" => $emailData);
			$templateID = 'user/Welcome-BCChina-fullversion';
			$emailService->emailOps->queueEmails($from, $templateID, array($emailArray));
			
			return true;
			break;
		case 40: #China Road to IELTS LM Welcome Email - to Customer
			$to = $data['customerEmail'];
			$from = $clarityR2ISupport;

			$emailData = array(	'name'=>$data['customerName'],
								'email'=>$data['customerEmail'],
								'expiryDate'=>$data['expiryDate']);
			$emailArray = array("to" => $to, "data" => $emailData);
			$templateID = 'user/Welcome-BCChina-lastmin';
			$emailService->emailOps->queueEmails($from, $templateID, array($emailArray));
			
			return true;
			break;
		case 41: #IELTS tips app promo EDM for IP.com
			$to = $data['email'];
			$from = $clarityR2ISupport;

			$emailData = array(	'name'=>$data['name']);
			$emailArray = array("to" => $to, "data" => $emailData);
			$templateID = 'IP/IELTS-tips-app-promo-edm';
			$delayUntil = date("Y-m-d H:i:s", time() + 86400*7);
			$emailService->emailOps->queueEmails($from, $templateID, array($emailArray), $delayUntil);
			
			return true;
			break;
		case 98: # server alert
			$body = file_get_contents("$templateFolder/website_monitoring.htm");
			$to = $clarityTest;
			$cc = "Vivying <vivying@clarityenglish.com>";
			$subject = "S3 upload status report(" . date(DATE_RFC822).")"; 
			$from = $claritySupport;
			break;			
		case 996: # China server alert
			$body = file_get_contents("$templateFolder/website_monitoring.htm");
			$to = $clarityTest;
			$cc = "Vivying <vivying@clarityenglish.com>";
			$subject = "CHINA - Website status report(" . date(DATE_RFC822).")"; 

			$from = $claritySupport;
			break;
		case 997: # China server warning
			$body = file_get_contents("$templateFolder/website_monitoring.htm");
			$to = $clarityTest;
			$cc = "Vivying <vivying@clarityenglish.com>";
			$subject = "CHINA - URGENT: Website status warning(" . date(DATE_RFC822).")"; 

			$from = $claritySupport;
			break;			
		case 998: # Europe server alert
			$body = file_get_contents("$templateFolder/website_monitoring.htm");
			$to = $clarityTest;
			$cc = "Vivying <vivying@clarityenglish.com>";
			$subject = "Europe - Website status report(" . date(DATE_RFC822).")"; 

			$from = $claritySupport;
			break;
		case 999: # Europe server warning
			$body = file_get_contents("$templateFolder/website_monitoring.htm");
			$to = $clarityTest;
			$cc = "Vivying <vivying@clarityenglish.com>";
			$subject = "Europe - URGENT: Website status warning(" . date(DATE_RFC822).")"; 

			$from = $claritySupport;
			break;				
		default:
			return false;
	}
	
	# Do some replacement on variables
	foreach ($data as $key => $value) {
		$body = str_replace("{".$key."}", $value, $body);
	}

	$emailAPI = array();
	$emailAPI['from'] = $from;
	$emailAPI['to'] = $to;
	$emailAPI['cc'] = $cc;
	$emailAPI['subject'] = $subject;
	$emailAPI['body'] = $body;
	$emailAPI['transactionTest'] = false;
	//$emailAPI['transactionTest'] = true;
	
	$errors = $emailService->emailOps->sendWebsiteEmails($emailAPI);
	if (empty($errors)) {
		return true;
	} else {
		return false;
	}
	/*
	# Do some replacement on variables
	Foreach ($data as $key => $value) {
		$body = str_replace("{".$key."}", $value, $body);
	}
	
	# Send it out
	return mail( $to, $subject, $body, $headers );
	
	# debug
	//echo $to."<br>".$subject."<br>".$headers."<br>".$body."<br><br>";
	*/
}
flush();
exit(0);
?>
