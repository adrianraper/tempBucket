<?php
if (isset($_GET['widgetdatawidth'])) {
	$width = $_GET['widgetdatawidth'];
} else {
	$width=200;
}
if (isset($_GET['widgetdataheight'])) {
	$height = $_GET['widgetdataheight'];
} else {
	$height=300;
}
if (isset($_GET['widgetdatalanguage'])) {
	$language = $_GET['widgetdatalanguage'];
} else {
	$language = 'EN';
}
if (isset($_GET['widgetdatacountry'])) {
	$country = $_GET['widgetdatacountry'];
} else {
	$country = 'International';
}
if (isset($_GET['widgetdatabclogo'])) {
	$logo = $_GET['widgetdatabclogo'];
} else {
	$logo = 'false';
}
$parameters = "widgetdatawidth=".$width."&widgetdataheight=".$height."&widgetdatalanguage=".$language."&widgetdatacountry=".$country."&widgetdatabclogo=".$logo;
?>
<html>
<head>
<title>British Council IELTS widgets</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />

<style type="text/css">
<!--
#Table_01 tr td table tr td h4 {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 14px;
	color: #FFF;
	font-weight: bold;
}
.bold {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 14px;
	color: #FFF;
	font-weight: bold;
}
.blackbold {
	font-family: Arial, Helvetica, sans-serif; 
	font-size: 14px; 
	font-weight: bold;
}
.white {
	font-family: Arial, Helvetica, sans-serif;
	color: #FFFFFF;
	font-size: 14px;
}
-->
</style>

</head>
<body bgcolor="#E0E0E0" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<table width="1000" height="824" border="0" align="center" cellpadding="0" cellspacing="0" id="maintable">
	<tr>
		<td width="1000" height="120" background="images/BC_topbanner.jpg"></td>
	</tr>
	<tr>
		<td width="1000" height="34" valign="middle" bgcolor="#D4092F">
        <table width="992" border="0" align="left" valign="middle" cellpadding="0" cellspacing="0">
          <tr>
            <td width="60" height="30">&nbsp;</td>
            <td width="45" height="30" align="left" valign="middle">
            		<img src="images/bullet_white.jpg" width="10" height="10">
            		<img src="images/bullet_white.jpg" width="10" height="10">
                    <img src="images/bullet_white.jpg" width="10" height="10">            </td>
				<td width="745" height="30" align="left" valign="middle"><span class="white">Examples of the widgets</span></td>
				<td width="15" height="30" align="left" valign="middle">&nbsp;</td>
				<td width="127" height="30" align="left" valign="middle">&nbsp;</td>
		  </tr>
		</table>
		</td>
	</tr>
	<tr>
		<td width="1000" height="634" align="center" valign="middle" style="background:#ffffff url(images/mainbg.jpg) center bottom repeat-x;">
		<table width="920" border="0" cellspacing="0" cellpadding="0" style="padding: 0 0 10px 0;">
			<tr>
				<td width="300" height="600" valign="top">
                    <table width="290" height="593" border="2" cellpadding="0" cellspacing="0" bordercolor="#820033">
                        <tr>
                            <td height="332" align="center" valign="top">
                            <br/>
<script type='text/javascript' language='JavaScript' src='/Software/Common/swfobject2.js'></script>
<script type='text/javascript' language='JavaScript' src='/Software/Widget/IELTS/bin/BandScoreCalculator.php?<?php echo $parameters; ?>'></script>
                          </td>
                        </tr>
                    </table>
                </td>
				<td width="300" height="600" valign="top">
                    <table width="290" height="593" border="2" cellpadding="0" cellspacing="0" bordercolor="#820033">
                        <tr>
                            <td height="400" align="center" valign="top" >
                           <br/>
<script type='text/javascript' language='JavaScript' src='/Software/Common/swfobject2.js'></script>
<script type='text/javascript' language='JavaScript' src='/Software/Widget/IELTS/bin/predictYourBandScore.php?<?php echo $parameters; ?>'></script>
                          </td>
                        </tr>
                    </table>
                </td>
				<td width="300" height="600" valign="top">
                    <table width="290" height="593" border="2" cellpadding="0" cellspacing="0" bordercolor="#820033">
                        <tr>
                            <td height="332" align="center" valign="top">
                            <br/>
<script type='text/javascript' language='JavaScript' src='/Software/Common/swfobject2.js'></script>
<script type='text/javascript' language='JavaScript' src='/Software/Widget/IELTS/bin/whereToStudy.php?<?php echo $parameters; ?>'></script>
                          </td>
                        </tr>
                    </table>
                </td>
			</tr>
		</table>
		</td>
	</tr>

</table>
</form>
</body>
</html>