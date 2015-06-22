<div id="header_before_login" style="display:none">
<!--SCHOOL: BEFORE LOGIN details-->
<div id="bannar_before_login" class="ban_join">
	<a href="./joinus.php" class="ban_link"></a>
	<a href="./index.php" class="ban_home"></a>
</div>

<div class="bannar_rainbow_line" id="welcome_line">
	<form method="post" action="login.php" name="loginForm" id="loginForm">
        <ul>
            <li><p class="login_title">Login:</p></li>
            <li><input name="id" type="text" value="" class="login_field"/></li>
            <li><p class="login_title">Password:</p></li>
            <li><input name="pwd" type="password" value="" class="login_field"/></li>
			<input name="langcode" type="text" value="" style="display:none"/>
       </ul>

    <!--Error msg area-->
        <div id="formmsg" style="display:none">Login name and/or password is not correct</div>
    <!--End of Error msg area-->

        <input id="submitBtn" name="submit" type="submit" value="" class="login_btn"/>
        <div id="forgotpw"><a href="<?php if(isset($root)) echo $root; ?>forgotpassword.php" class="forgotpw_iframe">Forgot password?</a></div>
	</form>
</div>
<!--End of BEFORE LOGIN details-->
</div>

<div id="header_demo_login" style="display:none">
<!--Public: After DEMO login details-->
    <div id="bannar_demo" class="ban_join">
    	<a href="./joinus.php" class="ban_link"></a>
        <a href="./index.php" class="ban_home"></a>
    </div>

    <div class="bannar_rainbow_line" id="welcome_line">
        <div id="front_logindetails">
               Welcome, <?php echo ($_SESSION['USERNAME']=="" ? $_SESSION['id'] : $_SESSION['USERNAME']) ?>. Today is <?php echo Date("jS F Y", time()); ?>.
        </div>
        <a id="demo_btn_logout" href="javascript:do_logout();" class="logout" style="display:none"></a>
    </div>
<!--End of Public After DEMO login details-->
</div>

<div id="header_after_login" style="display:none">
<!--School: DEMO + AFTER LOGIN details, Public: AFTER LOGIN details-->
    <div id="bannar_after_login" class="ban_choice">

    </div>
	<div class="bannar_rainbow_line" id="welcome_line">
		<div id="front_logindetails">
            Welcome, <?php echo ($_SESSION['USERNAME']=="" ? $_SESSION['id'] : $_SESSION['USERNAME']) ?>. Today is <?php echo Date("jS F Y", time()); ?>.
          </div>
		  <a id="btn_logout" href="javascript:do_logout();" class="logout" style="display:none"></a>
	</div>
<!--End of AFTER LOGIN details-->
</div>


<script type="text/javascript">
var user = "<?php echo ($_SESSION['USERNAME']=="" ? $_SESSION['id'] : $_SESSION['USERNAME']);?>";
var failure = "<?php echo $_SESSION['FAILURE'];?>";
var host = "<?php echo $_SERVER['HTTP_HOST'];?>";
var isDirectLink = "<?php echo $_SESSION['PREFIX'];?>";

if (host == "www.clarityenglish.com"){
	document.getElementById('bannar_before_login').className = "ban_choice";
	document.getElementById('bannar_before_login').innerHTML = "";
	document.getElementById('bannar_demo').className = "ban_choice";
	document.getElementById('bannar_demo').innerHTML = "";
	if(isDirectLink != "" && isSCORM != "true"){
		//document.getElementById('btn_logout').style.display = "block";
	}
} else {
	// gh#1241 No logout in a portal
	if ($allowLogout) {
		document.getElementById('btn_logout').style.display = "block";
		document.getElementById('demo_btn_logout').style.display = "block";
	}
}

if (failure == "true" || user == ""){
	document.getElementById('header_before_login').style.display = "block";
	document.getElementById('header_after_login').style.display = "none";
	document.getElementById('header_demo_login').style.display = "none";
} else {
	if (user == "iyjguest"){
		document.getElementById('header_before_login').style.display = "none";
		document.getElementById('header_after_login').style.display = "none";
		document.getElementById('header_demo_login').style.display = "block";
	}else{
		document.getElementById('header_before_login').style.display = "none";
		document.getElementById('header_after_login').style.display = "block";
		document.getElementById('header_demo_login').style.display = "none";
	}
}
</script>
