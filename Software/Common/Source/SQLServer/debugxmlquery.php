<?php
//echo("XMLQuery.php");
class XMLQuery {

    function XMLQuery() {
        $this->ParseRequest();
    }

    function ParseRequest() {
        // NOTE: 'always_populate_raw_post_data = On' 
        // MUST be uncommented in php.ini or overridden with .htaccess file
	// The next line may be unnecessary or may not be sufficent
	//ini_set('always_populate_raw_post_data','1');
	
        //$post = urldecode($GLOBALS[HTTP_RAW_POST_DATA]);
	//v6.4.1.4 Try a better method for getting raw data
	//v6.4.2 This is all well and good, but I have worked to encode courseName (amongst others) and I don't
	// want to simply unencode it here. OK - do a double encoding on any stringy parts in Flash.
	// v6.5.4.7 Take the bold step of removing this and making sure that you safely pass html entities from actionscript.
	// Otherwise I just couldn't get the + sign to work in names. It seems fine.
	//$post = urldecode(file_get_contents("php://input"));
	$post = file_get_contents("php://input");
	//Global $node;
	//$node .= "<note>" .urlencode($post)  ."</note>";
	$post = '<query dbHost="2" method="getInstanceID" userID="11259" />';
//	$post = '<query dbHost="2" method="startUser" rootID="163" userID="" name="adrian raper" studentID="p574528(8)" password="$!null_!$" dateStamp="2012-05-20 13:09:05" loginOption="1" instanceID="1337504945953" productCode="33" databaseVersion="7" />';
//	$post = '<query dbHost="2" method="getLicenceSlot" licences="998" licenceType="1" rootID="163" userID="11259" userType="0" productCode="9" licenceStartDate="2013-01-01 00:00:00" databaseVersion="6" cacheVersion="1336101653367" />';
//	$post = '<query dbHost="2" method="getLicenceSlot" licences="39" licenceType="1" rootID="163" userID="11259" userType="0" productCode="1" licenceStartDate="2011-01-01 00:00:00" databaseVersion="6" cacheVersion="1318838074491" />';
//	$post = '<query dbHost="200" method="writeScoreDetail" sessionID="2227317" userID="251526" unitID="1" exerciseID="1292227313781" rootID="11091" datestamp="2011-10-17 14:15:52" databaseVersion="6"><item itemID="10" /><item itemID="9" /><item itemID="8" /><item itemID="7" /><item itemID="6" detail="Yes" score="1" /></query>';
//	$post = '<query dbHost="2" method="writeScoreDetail" sessionID="2469289" userID="27639" unitID="1" exerciseID="1292227313781" rootID="163" datestamp="2011-11-01 15:56:40" databaseVersion="7"><item itemID="10" /><item itemID="9" /><item itemID="8" /><item itemID="7" /><item itemID="6" /><item itemID="5" /></query>';
//	$post = '<query method="register" instName="Clarity İstanbul Cad Akyazıcı Sai. Kung. Ltd." contactTitle="Dr" contactName="Raper" email="adrian.raper@clarityenglish.com" address1="2/F" 
//	address2="787 Po Tung&apos;s Highway" address3="undefined" address4="undefined" city="Sai Kung" state="" postcode="" tel="undefined" fax="undefined" country="HK" contactJob="undefined" 
//	instType="undefined" distributor="undefined" optIn="false" serialNumber="0712-B8B5-5749-113C-0001" product="Study Skills Success V9" licences="25" installDate="2011-08-25 15:59:52" 
//	expiry="2019-12-31 23:59:59" machineID="805B-52D2" productCode="49" licencing="Network"  />';
//$post = '<query method="startUser" rootID="163" instanceID="1311736177281" name="Jäckel Heß" studentID="" password="$!null_!$" loginOption="1" productCode="46" dateStamp="2011-07-27 11:09:37" dbHost="2" databaseVersion="6"/>';
//$post = '<query method="startUser" rootID="163" instanceID="1311736177281" name="溫家寶" studentID="" password="$!null_!$" loginOption="1" productCode="46" dateStamp="2011-07-27 11:09:37" dbHost="2" databaseVersion="6"/>';
//$post = '<query method="startUser" rootID="13854" instanceID="1311736177281" name="Heß" studentID="" password="$!null_!$" loginOption="1" productCode="46" dateStamp="2011-07-27 11:09:37" dbHost="2" databaseVersion="6"/>';
//$post = '<query method="startUser" rootID="13854" instanceID="1311736177281" name="Jost" studentID="" password="$!null_!$" loginOption="1" productCode="46" dateStamp="2011-07-27 11:09:37" dbHost="2" databaseVersion="6"/>';
//	$post = '<query dbHost="2" method="getGeneralStats" rootID="163" userID="11259" courseID="1250560407550" cacheVersion="1309764184321" databaseVersion="6" />';
//	$post = '<query dbHost="101" method="getScores" userID="231422" userType="0" rootID="169" courseID="1151344082236" databaseVersion="5" cacheVersion="1309748557978" />';
// 	$post = '<query dbHost="2" method="writeScore" userID="11259" datestamp="2011-12-29 23:30:17" sessionID="2227759" itemID="1251190462821" testUnits="" score="20" correct="2" wrong="3" skipped="5" unitID="2" duration="10" courseID="1250560407550" productCode="9" databaseVersion="6" cacheVersion="13095342123" />';
// 	$post = '<query dbHost="200" method="writeScore" userID="11259" itemID="1250823074193" testUnits="" score="-1" correct="-1" wrong="-1" skipped="-1" sessionID="2210672" unitID="2" datestamp="2011-07-01 22:42:07" duration="12" courseID="1250560407550" databaseVersion="5" cacheVersion="1309531327312" />';
// 	$post = '<query method="writeScore" score="-1" correct="10" wrong="0" skipped="0" complete="100" duration="86" productCode="45" dateStamp="2011-06-15 09:10:48" itemID="1268272283671" unitID="1266911374835" courseID="1266909801303" sessionID="1515740" userID="214434" dbHost="200" databaseVersion="6"/>';
//	$post = '<query dbHost="2" method="countLicencesUsed" rootID="13562,13581" licences="999" productCode="36" licenceStartDate="2011-01-01 00:00:00" databaseVersion="5" cacheVersion="1287022850375" />';
// 	$post = '<query dbHost="2" method="getRMSettings" rootID="11189" prefix="" eKey="" dateStamp="2011-11-22 16:55:11" productCode="9" cacheVersion="1308560111125" />';
// 	$post = '<query method="getScores" productCode="45" userID="214434" courseID="1266909801303" dbHost="2" databaseVersion="5"/>';
// 	$post = "<query method='registerUser' dbHost='2' rootID='13902' groupID='20296' name='Longclocks' password='' loginOption='1' productCode='36' registerMethod='ILATest' databaseVersion='5'/>";
// 	$post = '<query dbHost="2" method="failSession" rootID="13770" userID="" productCode="12" errorReasonCode="220" databaseVersion="5" dateStamp="2011-06-08 09:27:03" />';
// 	$post = '<query dbHost="2" method="startUser" rootID="13770" userID="" name="" studentID="100015825" password="015825" dateStamp="2011-06-08 09:27:03" loginOption="2" instanceID="1307496423446" productCode="12" databaseVersion="5" />';
// 	$post = "<query dbHost='2' method='getUser' rootID='13236' groupID='20292' name='Adrian Raper' email='adrian@noodles.hk' password='$!null_!$' loginOption='8' productCode='36' databaseVersion='5'/>";
// 	$post = '<query dbHost="100" method="getRMSettings" rootID="168" prefix="" eKey="" dateStamp="2011-05-31 16:53:22" productCode="13" cacheVersion="1306832002072" />';
// 	$post = '<query method="getRegDate" studentID="745" dbHost="100"/>';
//	$post = "<query dbHost='101' method='getGlobalUser' studentID='5502796' password='xx' groupID='233' loginOption='2' databaseVersion='5' />";
// 	$post = '<query dbHost="2" method="writeLog" userID="6" rootID="6" productCode="9" sessionID="71477" logCode="600" datestamp="2011-04-15 13:43:04" databaseVersion="5">loadProgs=2485&amp;serverTested=156&amp;firstQueryComplete=3031&amp;fullyLoadedUser=969&amp;fullyLoadedScores=1093&amp;queryStartUser=375&amp;queryGetLicenceSlot=407&amp;queryGetScores=344</query>';
//	$post = '<query method="startSession" rootID="163" userID="11259" productCode="46" courseID="1267078592421" dateStamp="2011-02-16 14:21:24" databaseVersion="5" />';
//	$post = '<query dbHost="2" method="getEditedContent" groupID="163" productCode="9" databaseVersion="5" cacheVersion="1297746179515" />';
//	$post = '<query method="updateInformation" productCode="49" name="Clarity İstanbul Cad Akyazıcı Sai Kung" licences="21" checksum="3A9E6A333878177BE898BBB2C61D58C5D10B144AF19A1B22AF427E18192A8B8A" EmuChecksum="" languageCode="EN" licenceType="3" expiryDate="2012-12-17 23:59:59" rootID="1" validCourses="" dateStamp="2011-04-07 10:28:44" email="adrian.raper@clarityenglish.com" />';
//	$post = '<query dbHost="2" method="startUser" rootID="*" userID="" name="one, student" studentID="student1" password="" dateStamp="2010-12-29 10:01:03" loginOption="2" instanceID="1293588063937" productCode="9" databaseVersion="5" />';
//	$post = '<query dbHost="2" method="addNewUser" rootID="11039" name="Clarity, Student" password="" studentID="student" loginOption="2" licenceType="1" productCode="9" uniqueName="1" email="" instanceID="1292392796937" registerMethod="scorm" databaseVersion="5" groupID="11039" />';
//	$post = '<query dbHost="2" method="startUser" rootID="11039" userID="" name="Clarity, Student" studentID="student" password="" dateStamp="2010-12-15 13:55:04" loginOption="2" instanceID="1292392504375" productCode="9" databaseVersion="5" />';
//	$post = '<query dbHost="2" method="getSpecificStats" rootID="163" userID="11259" productCode="44" sessionID="1514840" databaseVersion="5" cacheVersion="1292222624750" />';
//	$post = '<query dbHost="2" method="getLicenceSlot" licences="999" licenceType="1" rootID="163" userID="211845" userType="0" productCode="9" licenceStartDate="2009-01-01 00:00:00" databaseVersion="5" cacheVersion="1303122740503" />';
//	$post = '<query method="getScores" productCode="46" userID="11259" databaseVersion="5"/>';
//	$post = '<query dbHost="11" method="getEditedContent" groupID="" productCode="9" databaseVersion="5" cacheVersion="1291897498647" />';
//	$post = '<query dbHost="2" method="addNewUser" rootID="163" name="5Bentley, Jennifer" password="" studentID="p1234567(f)" loginOption="1" licenceType="1" productCode="33" uniqueName="1" email="" instanceID="1287117670234" registerMethod="scorm" databaseVersion="5" groupID="10378" />';
//	$post = '<query dbHost="2" method="getGlobalUser" studentID="student" password="$!null_!$" loginOption="2" cacheVersion="1287115127406" databaseVersion="5" />';
//	$post = '<query dbHost="2" method="checkDatabaseVersion" userID="11259" />';
//	$post = '<query dbHost="2" method="getInstanceID" userID="11259" productCode="9" />';
//	$post = '<query method="downloadRecorder" email="adrian@clarity.com.hk" referrer="www.TenseBuster.com" productCode="4" />';
//	$post = '<query dbHost="11" method="getRMSettings" rootID="" prefix="171744" eKey="" dateStamp="2011-05-16 22:44:50" productCode="12" cacheVersion="1305557090687" />';
//	$post = '<query method="CLSStartUser" email="kenix20@hotmail.com" password="zaxmfrhs" instanceID="1267096432500" dbHost="2" databaseVersion="5" />';
//	$post = '<query method="startUser" rootID="163" instanceID="1281690446" name="Adrian Raper" studentID="163" password="password" loginOption="1" productCode="45" dateStamp="2010-08-13 17:07:49" databaseVersion="5" />';
//	$post = '<query method="startUser" rootID="163" name="Adrian%20Raper" studentID="" password="password" loginOption="1" productCode="45" dateStamp="2010-02-26 12:05:32" databaseVersion="5" />';
//	$post = '<query dbHost="2" method="getLicenceSlot" licences="1" licenceType="2" rootID="10524" userID="-1" userType="0" productCode="9" licenceStartDate="2007-04-19 00:00:00" databaseVersion="5" cacheVersion="1289297440921" />';
//	$post = '<query dbHost="2" method="getLicenceSlot" licences="999" licenceType="1" rootID="163" userID="11258" userType="0" productCode="9" licenceStartDate="2009-11-02 09:54:48" databaseVersion="5" cacheVersion="1288662889564" />';
//	$post = '<query method="getRMSettings" rootID="0" prefix="clarity" eKey="" dateStamp="2010-02-25 19:13:52" productCode="33" cacheVersion="1267096432500" />';
//	$post = '<query dbHost="1" method="WriteScore" score="33" correct="5" wrong="2" dateStamp="2010-02-03 15:20:14" 
//				skipped="3" itemID="gs21" courseID="1" unitID="educ" duration="245" sessionID="633394" userID="11259" productCode="45" databaseVersion="5" />';
//	$post = '<query dbHost="2" method="startSession" userID="11259" rootID="163" productCode="9" datestamp="2011-12-29 23:30:16" databaseVersion="6" cacheVersion="1251962173463" />';
//	$post = '<query dbHost="101" method="updateInformation" productCode="33" name="Clarity &quot;Bé©b&apos;s&quot; &lt;_&gt;-+=&amp;^gt; Nasılsınız 並提供" licences="10" checksum="6E942F8F2FD309E0AAF38779A91602DFE97BD0D80FCF10359E22238BB2CA55E7" EmuChecksum="undefined" languageCode="EN" licenceType="3" expiryDate="2049-12-31 23:59:59" rootID="1" dateStamp="2010-02-24 11:22:21" email="adrian.raper@clarityenglish.com" />';
//	$post = '<query dbHost="101" method="updateInformation" productCode="33" name="Clarity" licences="10" checksum="6E942F8F2FD309E0AAF38779A91602DFE97BD0D80FCF10359E22238BB2CA55E7" EmuChecksum="undefined" languageCode="EN" licenceType="3" expiryDate="2049-12-31 23:59:59" rootID="1" dateStamp="2010-02-24 11:22:21" email="adrian.raper@clarityenglish.com" />';

//	$post = '<query dbHost="101" method="startUser" rootID="1" userID="" name="adrian" studentID="" password="password" dateStamp="2010-02-17 19:53:40" loginOption="1" instanceID="1266407620218" productCode="38" databaseVersion="5" />';
//	$post = '<query method="getGlobalUser" studentID="5404725" password="2F5C25A4" groupID="13424" loginOption="2" dbHost="2" databaseVersion="2" />';
//	$post = '<query dbHost="101" method="getLicenceSlot" licences="1" licencing="3" rootID="1" userID="3" userType="0" productCode="38" licenceStartDate="2010-02-18 16:02:13" databaseVersion="5" cacheVersion="1266480253718" />';
//	$post = '<query method="UPDATEINFORMATION" dbHost="101" rootID="1" dateStamp="2010-02-12 17:25:20" productCode="38" licences="10" languageCode="NAMEN" 
//			checksum="IDJHSKDFNKSJNIDJHSKDFNKSJNFIDJHSKDFNKSJNFFIDJHSKDFNKSJNF" name="Bayramlaşamadıklarımız" email="adrian@clarity.com.hk"  />';
//	$post = '<query method="GETRMSETTINGS" dbHost="101" rootID="1" eKey="" dateStamp="2010-02-18 18:38:20" productCode="38"  />';
//	$post = '<query method="GETRMSETTINGS" rootID="163" prefix="TPL" eKey="" dateStamp="2009-08-25 11:44:54" productCode="9"  />';
//	$post = '<query method="getScores" userID="11259" userType="0" rootID="163" courseID="1213672591135" databaseVersion="4" cacheVersion="1249885831875" />';
//	$post = '<query method="WRITESCOREDETAIL" dbHost="1" rootID="163" sessionID="232323" dateStamp="2009-04-27 17:25:20" exerciseID="1228729219807" databaseVersion="3" >';
//	$post .= '<item itemID="1" detail="There"/><item itemID="2" detail="can"/>';
//	$post .= '</query>';
//	$post = '<query dbHost="2" method="writeScoreDetail" rootID="163" sessionID="627750" userID="11259" exerciseID="1243996451478" datestamp="2009-06-23 16:37:08" databaseVersion="3"><item itemID="1" detail="There" /><item itemID="2" detail="can" /></query>';
//	$post = '<query dbHost="1" method="getLicenceSlot" licences="3" licencing="learner tracking" rootID="163" userID="11259" userType="0" licenceStartDate="2008-01-01 00:00:00" productCode="1" databaseVersion="3" cacheVersion="1244770617906" />';
//	$post = '<query method="register" instName="1" contactTitle="undefined" contactName="2" email="3" address1="4" address2="5" address3="undefined" address4="undefined" city="6" state="8" 
//			postcode="7" tel="undefined" fax="undefined" country="9" contactJob="undefined" instType="undefined" distributor="undefined" optIn="false" 
//			serialNumber="0702-11B3-227A-0304-0001" product="Study Skills Success" licences="10" installDate="2009-06-03 10:29:49" expiry="2049-12-31 08:00:00" 
//			machineID="undefined" productCode="3" licencing="Concurrent"  />';
//	$post = '<query dbHost="101" method="STARTUSER" name="Adrian Raper" rootID="1" password="password" dateStamp="2009-02-04 21:00:04" 
//			productCode="38" licences="100" instanceID="1234867801244" licenceStartDate="2008-01-01 00:00:00" databaseVersion="5" />';	
//$post = '<query dbHost="2" method="startUser" rootID="163" studentID="" name="Mrs White" password="$!null_!$" dateStamp="2009-04-16 14:13:44" licences="12" 
//loginOption="1" licenceID="1239862424703" productCode="33" licenceStartDate="" databaseVersion="2" />';
//$post = '<query dbHost="2" method="startUser" rootID="163" studentID="" name="Dandeliön&apos;s &quot;bob&quot;+" 
//password="password&apos;s &quot;bob&quot;" dateStamp="2009-04-16 15:54:02" licences="12" loginOption="1" licenceID="1239868442078" productCode="33" licenceStartDate="" databaseVersion="2" />';
//$post = '<query dbHost="2" method="addNewUser" rootID="163" name="porklet" password="pasword" studentID="" licenceType="Tracked" productCode="33" uniqueName="1" email="" 
//licenceID="1239874537703" registerMethod="" databaseVersion="2" groupID="11975" />';
//$post = '<query dbHost="2" method="startUser" password="$!null_!$" rootID="163" loginOption="64" userID="19304" dateStamp="2009-04-16 18:17:51" licences="12" licenceID="1239877071656" 
//productCode="33" licenceStartDate="" databaseVersion="2" />';
//$post = '<query method="startUser" rootID="163" studentID="456" name="" password="password" dateStamp="2009-03-17 19:09:59" licences="20" 
//	loginOption="34" licenceID="1237288199429" productCode="33" licenceStartDate="2008-04-15 20:54:05" databaseVersion="2" />';
//$post = '<query method="startUser" rootID="163" studentID="123456789" name="Berk Yılmazoğlu" password="123" dateStamp="2009-10-12 13:56:27" 
//	loginOption="1" instanceID="1255326987890" productCode="33" databaseVersion="4" />';
//	$post = '<query dbHost="2" method="startSession" userID="11259" rootID="163" courseID="Examples" productCode="1" datestamp="2009-04-23 11:33:56" duration="15" databaseVersion="3" cacheVersion="1240457636046" />';

//	$post = '<query method="GETSCORES" userID="11259" courseID="1213672591135" userType="2" rootID="163" />';
//$post = '<query method="getScores" userID="11259" userType="1" rootID="163" courseID="1213672591135" databaseVersion="2" cacheVersion="1237288526585" />';

//$post = '<query dbHost="2" method="getScores" userID="11259" userType="1" rootID="163" courseID="1213672591135" databaseVersion="2" cacheVersion="1237289367569" />';
//$post = '<query method="getAllScores" userID="33726" userType="0" rootID="163" courseID="1150976390861" databaseVersion="2" cacheVersion="1237288526585" />';
//	$post = '<query method="WRITESCORE" score="33" correct="5" wrong="2" dateStamp="2009-04-16 11:41:22" testUnits="" 
//				skipped="3" itemID="1228729219807" unitID="7" duration="123" sessionID="232323" userID="19304" databaseVersion="2" />';
//<query dbHost="2" method="writeScore" userID="19304" itemID="1217289202522" testUnits="" score="10" correct="1" wrong="0" skipped="9" 
//sessionID="232397" unitID="1" datestamp="2009-04-16 11:41:22" duration="4" databaseVersion="2" cacheVersion="1239853282187" />

//	$post = '<query method="GETSCRATCHPAD" userID="11259" />';
//	$post = '<query method="SETSCRATCHPAD" userID="11259"><![CDATA[This is Adrian&apos;s new Scratch (newline) & sniff "Pad"]]></query>';
//	$post = '<query method="STOPSESSION" sessionID="232323" courseID="1213672591135" datestamp="2009-02-05 15:09:13" databaseVersion="2" />';
//	$post = '<query method="GETUSER" name="Adrian Raper" rootID="163" password="password" userType="1" databaseVersion="2" />';	
//	$post = '<query method="GETGLOBALUSER" loginOption="2" name="Adrian Raper" studentID="163" password="password" databaseVersion="2" />';	
//	$post = '<query method="UPDATEGLOBALUSER" loginOption="2" name="Adrian Raper" studentID="163" password="secret" newPassword="password" databaseVersion="2" />';	
//	$post = '<query method="REGISTERUSER" name="Ho" studentID="P574528(8)" password="" 
//		country="China" email="xiaobo@vanisoft.com" groupID="10379" rootID="163" productCode="12" loginOption="18" expiryDate="2009-06-30" city="Beijing" databaseVersion="2" />';
//	$post = '	<query method="registerUser" name="IELTS-163-05" studentID="IELTS-163-05" password="VBFWCJYX" expiryDate="2009-04-07" email="adrian.raper@clarityenglish.com" 
//		rootID="163" groupID="10379" productCode="12" loginOption="2" databaseVersion="2" />';
//	$post = '<query method="GETGENERALSTATS" userID="11259" courseID="1213672591135"  />';
//	$post = '<query method="GETHIDDENCONTENT" productCode="33" groupID="10379" courseID="1213672591135" databaseVersion="2" />';
//	$post = '<query method="GETCOURSEHIDDENCONTENT" productCode="33" groupID="10379" databaseVersion="2" />';
//	$post = '<query method="GETLICENCESLOT" licences="20" rootID="163" userID="-1" userType="1" productCode="33" databaseVersion="2" />';
//	$post = '<query method="COUNTUSERS" rootID="163" licences="20" cacheVersion="1234879867353" databaseVersion="2" />';
//	$post = '<query dbHost="2" method="ADDNEWUSER" rootID="163" name="789" password="0464a061d5a9fb7f6cd4a599386fbf23" studentID="789" 
//			licenceType="Tracked" productCode="33" uniqueName="1" email="" licenceID="1239848722453" registerMethod="" databaseVersion="2" groupID="163" />';
//	$post = '<query method="STOPUSER" sessionID="232323" licenceID="280" />';
//        $post = '<query method="GETUSERS" />';

//	$post = '<query dbHost="2" method="getLicenceSlot" licences="1" licencing="concurrent" rootID="13181" userID="-1" userType="" productCode="9" licenceStartDate="2009-04-23 00:00:00" databaseVersion="3" cacheVersion="1247029715828" />';	
//	$post = '<query method="GETLICENCEID" userID="11259" databaseVersion="2" />';
//        $post = '<query method="DROPLICENCE" licenceID="23" />';
//        $post = '<query method="HOLDLICENCE" licenceID="320" />';
//        $post = '<query method="FAILLICENCESLOT" />';
//        $post = '<query dbHost="2" method="holdLicence" licenceID="2367" licenceHost="192.168.8.61" databaseVersion="3" cacheVersion="1247033725515" />';
//        $post = '<query method="getScores" userID="9" courseName="Tense Buster Elementary" cacheVersion="1074374988687"/>';
	//$post = '<query method="STARTSESSION" userID="542" courseID="1126256815671" courseName="Adrian%27s%20test%20%E0%A4%8D" dateStamp="2006-01-17 12:09:17"/>';
	//$post = '<query method="STARTSESSION" userID="2" courseID="11" courseName="Adrians course, which 繁體中文 is a really ลองอีกครั้ง long thing" />';
	//$post = '<query method="GETSESSIONS" userID="2" />';
//       $post = '<query dbHost="2" method="writeLog" rootID="163" logCode="600" sessionID="192168861" databaseVersion="3" datestamp="2009-02-05 15:09:13" productCode="9" userID="11259" ><![CDATA[loadedOne=299;loadedTwo=343;loadedThree=3322]]></query>';
//	$post = '<query dbHost="2" method="startSession" userID="11259" rootID="163" courseName="Pronunciation" courseID="1250560407510" productCode="37" datestamp="2009-11-26 11:55:18" duration="15" databaseVersion="5" cacheVersion="1259207718390" />';
        // Parse the request
        $xml = xml_parser_create();
        xml_parser_set_option($xml, XML_OPTION_SKIP_WHITE, 0);
        xml_parser_set_option($xml, XML_OPTION_CASE_FOLDING, 0);

        // Set initial value of all the variables
	// v6.5.5.1 I'm not sure I really want to do this...
        $this->vars = array(
            'METHOD'      => "help",
            'USERID'      => -1,
	    'ROOTID'    => 0,
            'NAME'        => "",
            'PASSWORD'    => "",
            'RMSETTING'   => "",
            'COURSENAME'  => "",
            'ITEMID'      => 0, // this is used for exerciseID
            'UNITID'      => 0,
            'LICENCEID'   => 0,
            'LICENCES'    => 0,
            'SCORE'       => 0,
            'CORRECT'     => 0,
            'WRONG'       => 0,
            'SKIPPED'     => 0,
            'COUNTRY'     => "",
//            'CLASSNAME'   => "",
            'EMAIL'       => "",
            'STUDENTID'   => 0,
            'SESSIONID'   => -1,
            'DURATION'    => 0,
            'SENTDATA'    => "",
//	v6.3.4 Add new field for unit IDs used in dynamic test
            'TESTUNITS'    => "",
//	v6.3.4 Add new field (optional) for passing db details
		'DBHOST'  => 1,
// v6.3.4 New field for key encryption
		'EKEY' => 1,
		// v6.3.4 session table uses courseID not courseName
		// v6.3.6 But RM takes a while to catch up, and Orchid will write out both.
		// So IF the database has coursename, then write out both but focus on coursename.
		// If not, then (naturally) just use courseID.
		//'USECOURSENAME' => "false",
		// v6.3.5 Licence type
		'LICENCETYPE' => "",
		'LICENCING' => "",
		// v6.4.2 Pass local time
		'DATESTAMP' => date("Y/m/d H:i:s"),
		// v6.3.5 Changed field for courseID in session table
		'COURSEID' => 0,
		//v6.4.2 Add field for score detail
		'QUESTIONID' => 0,
		//v6.5.4.5 New fields for db version 2
		//v6.5.4.5 which database version
		'DATABASEVERSION' => 0,
		//v6.5.4.5 which product
		'PRODUCTCODE' => 0,
		'GROUPID' => 0,
		'LICENCESTARTDATE' => date("Y/m/d H:i:s"),
		'EXPIRYDATE' => "",
		'COUNTRY'     => "",
		'REGION'     => "",
		'CITY'     => "",
		'LOGINOPTION'     => "",
		'NEWPASSWORD'     => "",
		'REGISTERMETHOD' => "",
		'USERTYPE' => "",
		'ERRORREASONCODE' => ""
        );

        if (xml_parse_into_struct($xml, $post, $vals, $index)==0) {
		// failure to read the XML
		return;
	}

        xml_parser_free( $xml );
        // Register variables - find the index of the query node
        $qid = $index['query'][0];
        foreach($vals[$qid]['attributes'] as $key => $val) {
            $this->vars[ strtoupper($key) ] = $val;
        }
	// We need different way to pull out the scratch pad data (a simple cdata string as the value of the query node)
	// and something like items for score details which are xml nodes themselves.
	//if ( array_key_exists('value', $vals[$qid]) ) {
	if ( array_key_exists('value', $vals[$qid]) ) {
		$this->vars['SENTDATA'] = $vals[$qid]['value'];
		//echo 'save simple string data';
	} elseif ( $vals[$qid]['type']=='open' ) {
		$this->vars['SENTDATA'] = $post;
		//echo 'save whole xml';
	} else {
		//echo 'no value to save';
	}
	
	// This code does not seem to work to pull out the value data
        //// Additional SENTDATA variable from within the tag content
        //if ($vals[$qid]['type'] == 'open') {
        //    for ($i = $qid + 1; ; $i++) {
        //        if ($vals[$i]['type'] == 'close' && $vals[$i]['level'] == $vals[$qid]['level'])
        //            break;
        //        if ( array_key_exists('value', $vals[$i]) )
        //            $this->vars['SENTDATA']  .= $vals[$i]['value'];
        //    }
        //}
    }
}
?>