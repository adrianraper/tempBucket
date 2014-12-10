<?php

/*
	$xmlString = '<memory><product><bookmark><startingPoint course="123" unit="12" /><level>B1</level></bookmark><book id="1"></book><bank /></product></memory>';
	$xml = simplexml_load_string($xmlString);
	
	$product = $xml->product;
	if (empty($product)) echo 'product is empty';
	$bookmark = $xml->product->bookmark;
	if (empty($bookmark)) echo 'bookmark is empty';
	$book = $xml->product->book;
	if (empty($book)) echo 'book is empty';
	if (!isset($xml->product->book)) echo 'book is not isset';
	$buck = $xml->product->buck;
	if (empty($buck)) echo 'buck is empty';
	if (!isset($xml->product->buck)) echo 'buck is not isset';
	$busk = $xml->priduct->buck;
	if (empty($busk)) echo 'busk is empty';
	if (!isset($xml->priduct->buck)) echo 'busk is not isset';
	$bank = $xml->product->bank;
	if (empty($bank)) echo 'bank is empty';
	if (!isset($xml->product->bank)) echo 'bank is not isset';
*/

	$_REQUEST['prefix'] = 'clarity';
	$_REQUEST['productCode'] = '59';
	$_REQUEST['user'] = 'userEmail=dandy%40email&userName=asfsadf&password=password&confirmPassword=password';
	$_REQUEST['userEmail'] = 'andrew@claritysupport.com';
	$_REQUEST['level'] = 'INT';
	$_REQUEST['exercise'] = '1193901049540.xml';
	$_REQUEST['answers'] = '<input class="MultipleChoiceQuestion" id="b2" value="q3" /><input class="GapFillQuestion" id="b1" value="goes" />';
	$_REQUEST['code'] = 'f9pewPgs1OT88yqENaxTiq0RwtOmPlCy6KmgFl04fxJAEIxLLW3RnPOIHwSYQHCVt_ZmUZn7uylRZfXERX9RVvaQ3A-zdrhMUQrKCgxlX274KyJlmPzT9zpMpW2x9ujVxmsscCANwuvf5HbqV-xVdmB3iv9SzEpQiGxdHchM085esAl7-GNPfsTDyiQBpJsBYZ0So_rdOh2jJZg-bbnDOTNWSYZTp9uFGJb66a8aEOtHNx9_NpYVQSn71LiUWxEkeemQ357S1SmeDMYDTs9Qy0CYEez7KlC7Qmzvq_ZfEKVa8RJW7wZWqGkuXMjSaFMo2oLslj4KDXv4TaIEOUB5SjxlqwbxB5q2VzKfn6WUnezP4bmGW8kRCqBgwpDwvrwW37Gv80vqfI73ye1wzdixmpoG6jpT8rc46xAseNcX8jo8d8Vr8HBa_5OQIPGB4J4kjZl4fu_a7w2yFxVqx6F4udp208Sr-eK5EC13AH7kePllPYI_83gp4WgEazAOWO2ZqMEwrjtdvWaO9MIPGqWKB_EgjY1JNI0POngvAOxRHvZXVTzSAqy1LQ8gaShY7SzSuyBX3Kk74E-FJtC8AsVI1-P4YbuICyeaG6NYHVEqs2TcBAdMPYvfeRPdscr99d3TUh77vOGtrVzGGrolYsqvEzejRyv7sGJ_04QuUtbwpsn3z9L3uM1lyYxXfMVc-IQRbSC-6gvhCY81B4elcsOGGBeam-nAiIbswgQ-K9TDrgBLCYZJ6mDOnOLwvXZ1DB2qI_1OEcniqzkk-j5cgrqSXElvxRTV0O02n6ndfvmssIN1pSHAzwPd-Ev2W25sbj73q9CU24r71DNSB1RBK1PPLuJ4NFuxHWv_sN2xcx4_3BBmX0w4Ne_1cif_NCo6N9mSpX0ZTZtJBJAlBPxBud9x9kKO4hl2ghiAaW1vKrsmMbuXPf-6HNzx_ckcJZQN94NKOnzhatZWkZ8mo6TxUqmJVWy7FollmkMWI57GJEhdRkxkuWzNs1YdclfYD8K4cTYgpRlkGrGwi2wuXILb2o8SPS2tZ2WtUnOAWpWOwN5b7jLRl5ipl9axobPJdf7gh7xTCUvHhSDWUeoWLfNefuG-gOII0A3DqsQ5QpZ4VDhZaAC7OcUS7e_m2nL6u40RyxIVQHlo3wvTYoxzfqj98LPrq6TyU5VS4QXEF_0V4SR3eQsTUociNHo1_htUSD7jJ9BNZVQzlbWvyDySLKUtAavkZFDbEIvW7A7LQ1d1XdVZx0PfatJZG_1DZOqsEHl14SjB9QDPF2zaK0hwDsKRdm1Nnx8Rfyp0BI6Oj8jkta4MYfnJfMK01sWuZpa5Jk0dUb2QjGsAtVM4aVw8CB85WaL2LhcegMQpHluWvUUSAwrSWPDsFkT0hkhphI0PRxbpIrrQmQw509vMcDjHEbHcDQG9zI8Z_VEYIqXPUtp07LWIfXahQ7tPhYISQbpejqMrSN-G9_GHrZbJtEikb9uFDiFd0km8ZD4wdgMWWYwcN0przlXxj1xOCue7M---8GTXnjABcoNu6ffsbMr7y7naQ63BoJZggKQC14qvr0PZ-fJPHPQNAyC4JuniZAzMbpTaqLpRW64jhrvMTJcDhMGUUWj7KDK0bxVQsnfZ012edPGddZ-R2yTsNUj5s2LURXA8max5de1odT9dc8RNnAczaslhuHdI93dZ1fujZ0FGiYU7Z0XkHL-J2ZPufG-uYkQ4wYy9pv2X6r0tSiRMngQ5hkwSsnPsi1IRQZlwY2soLEoCezD2LtdgE2W8dGxmdq8PNkUnK9JmKnVSUWEbAJuU-Oy2wRplKl_-bTtynS4rgYvYk51BDOqXh1LPqAtbBWxQ0Sdv7zWHwCI0QKIq01imADeIHZAQUt-KWajXeCD74uqVIDQc_Iilo0eHq1e7pvmVGg3sZcNfPMcX1qWz-MsMwXDRIjgdRxSOyojs-4yvIHhiDeKuFg35ooZfZnEsodJuuPulBchFDnHKlFqfEl1miOD69rKjCfOlIisnkyQYXDfxbwuRqkFT1O9l93o1ItkxLKzAOsllndNOJ4UbgYm-UtWBvaG7TT7nLi_ZQze93Rc4SxoZ4oF93JX9UzjosuMhVnaYTdlwGA6mEX6XmijXCP69wjPR090PVbJM1D2jslnFr8WuCjL8TXnp8RsrNkUflvtGpGVfg7xJS8STv_LQKgWeZt8SA_Lj0Zwc5wtOnJ8yuxeGwdcbZec5tdSP9yIAt1-36jctsAe_Xt7N3jeucDHSjSnaXM182I4svHjAckaGi6kkc9PjJ1nJJ-_JgRDplCyV-Q8Q-YZ8BYCrikOxoXOmSEyHb9yIfQGzcSfps5GmFODgwlTj4MX_f_aSlfun8X_P1s7R8qkwnftt3-C2pmFnr2Fcrq0fLjHSxejv5XeP-xjnGNuCmRZhPk8g0_ENPlBunHp1_rieNwrCXEgEVFzC0GDz8V91YxIOPMt6SqACpCizegUwCoRQIsOVNzqRlV9sGuKfFbCVVBI-tmtAs3yuvmQvmBule2-EupiEl26_ZBdYao3JI9dW9kTpJKQ3ur_buRpO_NzYnVdOMEowM_BaN2GicDxCPeXaWbePjRWPg-9BTe748ZtpLGSpvZ0R2ZHeisnMnP8u5DUsYUxj_8pYvncZeK0gXnRqJIAPY55ALzTTV24bxl8UyuXzYW2y-PagP9fuPwt3YFMt5rE9H7KwmehsbwD1YtvBbJ1upzaeYnOmhES3Z4KIalVV9CDrnRdVUCn7YDNRULx4GEp1u0v-ZFaj8Ui2l5HB3Reqr0mgXPqR7uHeuyIRSG5Kq74lr5gQcA060onL-7qNnVN7cP-9ig~~';
	
	$_REQUEST['operation'] = 'changeLevel';
	$_REQUEST['operation'] = 'submitAnswers';
	$_REQUEST['operation'] = 'unsubscribe';
	$_REQUEST['operation'] = 'isEmailValid';
	$_REQUEST['operation'] = 'getQuestions';
	
	require_once(dirname(__FILE__)."/TB6weeksService.php");

/*
	require_once(dirname(__FILE__)."/MinimalService.php");
	$dummy = new MinimalService();

	$gapFillQuestions = array('a' => 'apple', 'b' => 'banana', 'c' => 'cauliflower', 'd' => 'dentist', 'e' => 'egg');
	$maxQuestions = count($gapFillQuestions);
	$numQuestionsToUse = 10;
	$numQuestionsToUse = ($maxQuestions < $numQuestionsToUse) ? $maxQuestions : $numQuestionsToUse;
	$randArray = array_rand(range(0, $maxQuestions-1), $numQuestionsToUse);
	shuffle($randArray);
	var_dump($randArray);			
	$accountFolder = '../../../Clarity';
	Session::set('userID', '12345');
	
	$repositoryDir = $GLOBALS['ccb_repository_dir'];
	$gitPath = '"c:\Program Files (x86)\Git\bin\git"';
	$debugStderr = ' 2>&1';
	$prefix = substr($accountFolder, strrpos($accountFolder, '/')+1);
	$courseID = 
	$commitMsg = 'by userID='.Session::get('userID').' in '.$prefix;
*/
//	$addCmd = ' add '.$prefix.'/*/menu.xml';
//	$commitCmd = ' commit -m "'.$commitMsg.'" '.$prefix.'/*/menu.xml';
//	$statusCmd = ' status '.$prefix.'/*/menu.xml';
	//$configCmd = ' config core.autocrlf false'; 
	//$configCmd = ' config user.email adrian.raper@clarityenglish.com'; 
/*
 	$configCmd = ' config --list';
	
	$doConfig = !true;
	$doAdd = !true;
	$doCommit = true;
	$doStatus = true;
	
	$output = array();
	chdir('../../'.$repositoryDir);
	if ($doConfig) {
		exec($gitPath.$configCmd.$debugStderr, $output, $rc);
		if (!$rc)
			AbstractService::$debugLog->notice("git config failed");
		echo (var_dump($output));
		$output = array();
	}
	if ($doAdd) {
		exec($gitPath.$addCmd.$debugStderr, $output, $rc);
		if (!$rc) {
			AbstractService::$debugLog->notice("git add for prefix=$prefix failed");
		} else {
			AbstractService::$debugLog->notice("git add for prefix=$prefix succeeded");
		}
		echo (var_dump($output));
		$output = array();
	}
	if ($doCommit) {
		exec($gitPath.$commitCmd.$debugStderr, $output, $rc);
		if (!$rc) {
			AbstractService::$debugLog->notice("git commit for prefix=$prefix failed");
		} else {
			AbstractService::$debugLog->notice("git commit for prefix=$prefix succeeded");
		}
		echo (var_dump($output));
		$output = array();
	}
	if ($doStatus) {
		exec($gitPath.$statusCmd.$debugStderr, $output, $rc);
		echo (var_dump($output));
	}
*/
/*
	require_once(dirname(__FILE__)."/../../config.php");

	$repositoryDir = $GLOBALS['ccb_repository_dir'];
	$gitPath = '"c:\Program Files (x86)\Git\bin\git"';
	$debugStderr = ' 2>&1';
	$addCmd = ' add Clarity/*\/menu.xml';
	$commitCmd = ' commit -m "adrian 16:49" Clarity/*\/menu.xml';
	$statusCmd = ' status Clarity'; // /748476225422193042';
	// Need to do the following once to setup the user
	// Can't do --global as get (null)/(null)/.git file doesn't exist
	$configCmd = ' config user.email adrian.raper@clarityenglish.com'; 
	$configCmd = ' config --list';
	$initCmd = ' init';
	$output = array();
	chdir('../../'.$repositoryDir);
	exec($gitPath.$addCmd.$debugStderr, $output, $rc);
	echo (var_dump($output));
	echo $rc.'<br/>';
	exec($gitPath.$commitCmd.$debugStderr, $output, $rc);
	echo (var_dump($output));
	echo $rc;
*/
/*
require_once(dirname(__FILE__)."/../../config.php");
require_once($GLOBALS['common_dir'].'/encryptURL.php');
  
	$parameters = "prefix=clarity&userName=Mrs Twaddle&email=twaddle@email.com&password=password&course=1189057932446&startingPoint=unit:1192013076011";
	$crypt = new Crypt();
	$argList = $crypt->encodeSafeChars($crypt->encrypt($parameters));
	echo $argList;
	
	$data = $crypt->decodeSafeChars($argList);
	echo $crypt->decrypt($data);
	
*/
/*
	$args = "prefix=GLOBAL&session=123gadfasdf456798&studentID=P574528(8)&password=Sunshine1787&padding=00000000000000000000000000";
	
	$key = '123457980123457890';
	$key = sha1($key, true); // get 20 digit hash
	$key = base64_encode($key); // nFXx CBo/ xe00 3MNw QbXK UwLf ECU= // This is 28 characters
	
	$iv_size = mcrypt_get_iv_size(MCRYPT_RIJNDAEL_256, MCRYPT_MODE_ECB);
	$iv = mcrypt_create_iv($iv_size, MCRYPT_RAND);
	$encryptedArgs = mcrypt_encrypt(MCRYPT_RIJNDAEL_256, $key, $args, MCRYPT_MODE_ECB, $iv);
	$td = mcrypt_module_open('rijndael-256', '', 'ofb', '');
	$iv = mcrypt_create_iv(mcrypt_enc_get_iv_size($td), MCRYPT_RAND);
    $ks = mcrypt_enc_get_key_size($td);
    $key = substr(md5($key), 0, $ks);
    mcrypt_generic_init($td, $key, $iv);
    $encryptedArgs = mcrypt_generic($td, $args);
	mcrypt_generic_deinit($td);
	mcrypt_module_close($td);
    
	$passedArgs = base64_encode($encryptedArgs);
	$newURL = 'http://dock.projectbench/Software/ResultsManager/web/amfphp/services/justTestPHP2.php?data='.$passedArgs;
	header('Location: ' . $newURL);
*/

/*
	$validUnitIds = array();
	$validUnitIds[] = '377666536745193046';

		$thisUnitID = '377666536745193047';
				if (in_array($thisUnitID, $validUnitIds, true)) {
					$goodGosh = true;
				} else {
					$goodGosh = false;
				}
		$thisUnitID = '377666536';
				if (in_array($thisUnitID, $validUnitIds)) {
					$goodness = true;
				} else {
					$goodGosh = false;
				}
	$validUnitIds = array();
	$validUnitIds[] = '377666536745';

		$thisUnitID = '377666536746';
				if (in_array($thisUnitID, $validUnitIds)) {
					$goodGosh = true;
				} else {
					$goodGosh = false;
				}
		$thisUnitID = '377666536';
				if (in_array('adfsadf', $validUnitIds)) {
					$goodness = true;
				} else {
					$goodGosh = false;
				}
*/
/*
	if (strtotime('2013-05-04 23:59:59') > strtotime(date("Y-m-d"))) {
		echo "it is still valid";
	} else {
		echo "you have expired";
	}
*/
/*
	if (version_compare(PHP_VERSION, '5.3.0') >= 0) {
    	echo 'I am at least PHP version 5.3.0, my version: ' . PHP_VERSION . "\n";
	}
	$contents = file_get_contents(dirname(__FILE__).'/../../../../../../ContentBench/CCB/Clarity/courses.xml');
	if ($contents)
		$xml = simplexml_load_string($contents);
	print_r($xml);	
*/
/*
	function isIPInRange($ip, $ipRangeList) {
	 	$ipRangeArray = explode(',', $ipRangeList);
		foreach ($ipRangeArray as $ipRange) {
			$ipRange = trim($ipRange);
			
			// loop through the ip addresses you are running from
		 	$myIpArray = explode(',', $ip);
			foreach ($myIpArray as $myIp) {
				$myIp = trim($myIp);

				// first, is there an exact match?
				if ($myIp == $ipRange)
					return true;
				
				// or does it fall in the range? 
				// assume nnn.nnn.nnn.x-y or nnn.nnn.x-y
				$targetBlocks = explode('.',$ipRange);
				$thisBlocks = explode(".",$myIp);
				// how far down do they specify?
				for ($i=0; $i<count($targetBlocks); $i++) {
					// echo "match ".$thisBlocks[$i]." against ".$targetBlocks[$i]."<br/>";
					if ($targetBlocks[$i] == $thisBlocks[$i]) {
					} else if (strpos($targetBlocks[$i], '-') !== FALSE) {
						$targetArray = explode('-',$targetBlocks[$i]);
						$targetStart = (int) $targetArray[0];
						$targetEnd = (int) $targetArray[1];
						$thisDetail = (int) $thisBlocks[$i];
						if ($targetStart <= $thisDetail && $thisDetail <= $targetEnd) {
							//myTrace("range match " + thisDetail + " between " + targetStart + " and " + targetEnd);
							return true;
						}
					} else {
						//myTrace("no match between " + targetBlocks[i] + " and " + thisBlocks[i]);
						break;
					}
				}
			}
		}
		return false;
	}
	$ip = '127.0.0.1 ,192.168.8.74';
	$ranges = '192.168.8.56';
	$ranges = '192.168.8.55, 192.168.8.0-73, 192.168.8.74-78';
	//$ranges = '192.168.8-16.0-64'; // will ignore 4th bit range
	//$ranges = '192.168.8-16';
	//$ranges = '192.168.8'; // will not work
	//$ranges = '192.168'; // will not work
	if (isIPInRange($ip, $ranges)) {
		echo "yes, $ip is in range $ranges";
	} else {
		echo "no, $ip is NOT in range $ranges";
	}
*/		
flush();
exit();
