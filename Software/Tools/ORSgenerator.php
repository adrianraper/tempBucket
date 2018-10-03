
<?PHP
$name = $_GET['ORSname'];
$pattern = '+';
$replacement = ' ';
$API_Data = "n=".str_replace($replacement, $pattern, $name);

$email = $_GET['ORSemail'];
$pattern = '(AT)';
$replacement = '@';
$API_Data = $API_Data . "&e=".str_replace($replacement, $pattern, $email);

$expiryDate = $_GET['ORSexpiryDate'];
/*
This part includes all the information we needed.
i=5913543115 -> This is the ID number of the candidate
m=Academic -> This is the module of test which the candidate takes. It can be either "Academic" or "General Training" only
t=2015-11-31 -> This is the last date of IELTS test which the candidate will take
n=CLARITY Test -> This is the name of the candidate
e=skytesting@clarityenglish.com -> This is the email address of the candidate
tc=ABC center Hong Kong -> This is the test center
c=Hong Kong -> This is the country
*/

$data = 'i=21539428622&m=Academic&t='.$expiryDate.'&n='.$name.'&e='.$email.'&tc=Mövenpick Hotel Istanbul';
$passwordStr = $name."-&-".$email;
$encrypted = encodeCharacters(encrypt3DES(buildPasswordHash($passwordStr), $data));
$API_Data = $API_Data . "&d=". $encrypted;

$URL = "http://www.roadtoielts.com/BritishCouncil/Global/Start.php?" . $API_Data;

echo $URL;

function buildPasswordHash($str) {
	$pass0sha1 = sha1($str, true); 
	$password = base64_encode($pass0sha1);
	return sha1($password, true);
}

function encrypt3DES($key, $text){
	$iv_size = mcrypt_get_iv_size(MCRYPT_3DES, MCRYPT_MODE_ECB);
	$iv = mcrypt_create_iv($iv_size, MCRYPT_RAND);
	if (strlen($key)%8 != 0 || strlen($key) == 0) $key .= str_repeat("\0", (8-strlen($key)%8)); //pad with "\0" bytes to make sure the key will have valid size by sky on 09012017
	$encrypt = mcrypt_encrypt(MCRYPT_3DES, $key, $text, MCRYPT_MODE_ECB, $iv);
	$encrypt = trim(base64_encode($encrypt));
	return $encrypt;
}

function encodeCharacters ($rawText) {
	$pattern = '/';
	$replacement = '-';
	$temp = str_replace($pattern, $replacement, $rawText);
	$pattern = '=';
	$replacement = '_';
	$temp = str_replace($pattern, $replacement, $temp);
	return $temp;
}

?>