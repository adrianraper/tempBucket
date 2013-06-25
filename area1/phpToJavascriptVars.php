<?php 

/*
 * Output javascript vars for each PHP variable
 */
echo '<script type="text/javascript">';
echo 'var jsLocation="'.$locationFile.'";';
echo 'var jsPrefix="'.$prefix.'";';
echo 'var jsProductCode="'.$productCode.'";';
echo 'var jsAccountName="'.$accountName.'";';
echo 'var jsReferrer="'.$referrer.'";';
echo 'var jsServer="'.$server.'";';
echo 'var jsIP="'.$ip.'";';
echo 'var jsCourseFile="'.$courseFile.'";';

echo 'var jsUserName=';
if ($username) {
	echo '"'.$username.'";';
} else {
	echo 'swfobject.getQueryParamValue("username");';
}
echo 'var jsPassword=';
if ($password) {
	echo '"'.$password.'";';
} else {
	echo 'swfobject.getQueryParamValue("password");';
}
echo 'var jsStudentID=';
if ($studentID) {
	echo '"'.$studentID.'";';
} else {
	echo 'swfobject.getQueryParamValue("studentID");';
}
echo 'var jsUserID=';
if ($userID) {
	echo '"'.$userID.'";';
} else {
	echo 'swfobject.getQueryParamValue("userID");';
}
echo 'var jsEmail=';
if ($email) {
	echo '"'.$email.'";';
} else {
	echo 'swfobject.getQueryParamValue("email");';
}
echo 'var jsInstanceID=';
if ($instanceID) {
	echo '"'.$instanceID.'";';
} else {
	echo 'swfobject.getQueryParamValue("instanceID");';
}
echo 'var queryStringCourseID=';
if ($course) {
	echo '"'.$course.'";';
} else {
	echo 'swfobject.getQueryParamValue("course");';
}
echo 'var queryStringStartingPoint=';
if ($startingPoint) {
	echo '"'.$startingPoint.'";';
} else {
	echo 'swfobject.getQueryParamValue("startingPoint");';
}
echo 'var jsResize=';
if ($resize) {
	echo '"'.$resize.'";';
} else {
	echo 'swfobject.getQueryParamValue("resize");';
}
echo '</script>';