<?php
require_once(dirname(__FILE__)."/../../config.php");
$prefix = 'AAMC';
$dir = '../../'.$GLOBALS['ccb_data_dir'].'/'.$prefix.'/';

$zip = new ZipArchive();
if ($zip->open($dir.'export.zip', ZipArchive::CREATE) === true) {
	$rc = $zip->addFile($dir.'courses.xml', 'newcourses.xml');
	//echo "$rc addFile status ".$zip->getStatusString()."<br/>";
	$rc = $zip->addEmptyDir('media');
	//echo "$rc addEmptyDir status ".$zip->getStatusString()."<br/>";
	$rc = $zip->addFile($dir.'media/media.xml', 'media/newmedia.xml');
	//echo "$rc addFile status ".$zip->getStatusString()."<br/>";
	$rc = $zip->setArchiveComment('Made this day in 2014');
	//echo "$rc setArchiveComment status ".$zip->getStatusString()."<br/>";
	$rc = $zip->close();
	//echo "$rc close status ".$zip->getStatusString()."<br/>";
		
} else {
	//echo "$rc open status ".$zip->getStatusString()."<br/>";
}  

header('Content-Type: application/zip');
header('Content-disposition: attachment; filename=export.zip');
header('Content-Length: ' . filesize($dir.'export.zip'));
readfile($dir.'export.zip');


	require_once(dirname(__FILE__)."/MinimalService.php");
	$dummy = new MinimalService();
	$accountFolder = '../../../Clarity';
	Session::set('userID', '12345');
	
	$repositoryDir = $GLOBALS['ccb_repository_dir'];
	$gitPath = '"c:\Program Files (x86)\Git\bin\git"';
	$debugStderr = ' 2>&1';
	$prefix = substr($accountFolder, strrpos($accountFolder, '/')+1);
	$courseID = 
	$commitMsg = 'by userID='.Session::get('userID').' in '.$prefix;
	$addCmd = ' add '.$prefix.'/*/menu.xml';
	$commitCmd = ' commit -m "'.$commitMsg.'" '.$prefix.'/*/menu.xml';
	$statusCmd = ' status '.$prefix.'/*/menu.xml';
	//$configCmd = ' config core.autocrlf false'; 
	//$configCmd = ' config user.email adrian.raper@clarityenglish.com'; 
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
