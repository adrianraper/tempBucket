<?php
// 2013 Mar 5 Vivying added for catching the undefine variable in header.php
// Updated AR 6 June 2016
 session_start();  //for inc_nav
 if (!isset($miniSelection)) $miniSelection = "";
 if (!isset($currentSelection)) $currentSelection = "";
 if (!isset($current_subsite)) $current_subsite = "";
 if (!isset($userTypeName)) $userTypeName = "";
?> 


 <?php if (!isset($_SESSION['UserName'])) { ?>   
 
	<nav class="navbar-default" id="main-nav">
	  <div class="container-fluid container">
		<!-- Brand and toggle get grouped for better mobile display -->
		<div class="navbar-header">
		  <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#main-navbar-collapse" aria-expanded="false">
			<span class="sr-only">Toggle navigation</span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
		  </button>
		  <a class="navbar-brand" href="/" onClick="ga('send', 'event', 'header', 'logo', 'click-home',0,{nonInteraction: true});"><img src="/images/logo_clarityenglish.png" width="132" height="24"/></a>
		</div>

		<!-- Collect the nav links, forms, and other content for toggling -->
		<div class="collapse navbar-collapse" id="main-navbar-collapse">
		  <ul class="nav navbar-nav navbar-right">
			<li><a href="/program/" class="header-text general-text" onClick="ga('send', 'event', 'header', 'general-directory', 'click-program',0,{nonInteraction: true});">Programs</a></li>
			<li><a href="/resources/" class="header-text general-text" onClick="ga('send', 'event', 'header', 'general-directory', 'click-resources',0,{nonInteraction: true});">Resources</a></li>
			<li><a href="/support/" class="header-text general-text" onClick="ga('send', 'event', 'header', 'general-directory', 'click-support',0,{nonInteraction: true});">Support</a></li>
            <li><a href="http://blog.clarityenglish.com/" target="_blank" class="header-text general-text" onClick="ga('send', 'event', 'header', 'social', 'blog-ce',0,{nonInteraction: true});">Blog</a><li>
			<li id="signin-no-mobile"><a href="/online/login.php" class="header-text general-text" onClick="ga('send', 'event', 'header', 'signin-related', 'signin',0,{nonInteraction: true});">Sign in</a></li>
			<li><a href="/contactus/priceenquiry.php" id="header-cta" class="general-text" onClick="ga('send', 'event', 'header', 'lead-gen', 'price-enquiry',0,{nonInteraction: true});">Price enquiry</a></li>
		  </ul>
		</div><!-- /.navbar-collapse -->
	  </div><!-- /.container-fluid -->
	</nav>

<?php }	else{ ?>

<nav class="navbar-default" id="main-nav">
	  <div class="container-fluid container">
		<!-- Brand and toggle get grouped for better mobile display -->
		<div class="navbar-header">
		  <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#main-navbar-collapse" aria-expanded="false">
			<span class="sr-only">Toggle navigation</span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
		  </button>
		  <a class="navbar-brand" href="/" onClick="ga('send', 'event', 'header', 'logo', 'click-home',0,{nonInteraction: true});"><img src="/images/logo_clarityenglish.png" width="132" height="24"/></a>
		</div>

		<!-- Collect the nav links, forms, and other content for toggling -->
		<div class="collapse navbar-collapse" id="main-navbar-collapse">
		  <ul class="nav navbar-nav navbar-right">
			<li><a href="/program/" class="header-text general-text" onClick="ga('send', 'event', 'header', 'general-directory', 'click-program',0,{nonInteraction: true});">Programs</a></li>
			<li><a href="/resources/" class="header-text general-text" onClick="ga('send', 'event', 'header', 'general-directory', 'click-resources',0,{nonInteraction: true});">Resources</a></li>
			<li><a href="/support/" class="header-text general-text" onClick="ga('send', 'event', 'header', 'general-directory', 'click-support',0,{nonInteraction: true});">Support</a></li>
            <li><a href="http://blog.clarityenglish.com/" target="_blank" class="header-text general-text" onClick="ga('send', 'event', 'header', 'social', 'blog-ce',0,{nonInteraction: true});">Blog</a><li>
			<li id="signin-no-mobile"><a href="/db_logout.php" class="header-text general-text" onClick="ga('send', 'event', 'header', 'signin-related', 'signin',0,{nonInteraction: true});">Sign out</a></li>
			<li><a href="/contactus/priceenquiry.php" id="header-cta" class="general-text" onClick="ga('send', 'event', 'header', 'lead-gen', 'price-enquiry',0,{nonInteraction: true});">Price enquiry</a></li>
		  </ul>
		</div><!-- /.navbar-collapse -->
	  </div><!-- /.container-fluid -->
	</nav>

<?php if($current_subsite == "online") { ?> 
	<nav class="navbar-default" id="main-nav">
	  <div class="container-fluid container">
		<!-- Brand and toggle get grouped for better mobile display -->
		<div class="navbar-header">
		  <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#main-navbar-collapse" aria-expanded="false">
			<span class="sr-only">Toggle navigation</span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
		  </button>
		  <a class="navbar-brand" href="/" onClick="ga('send', 'event', 'header-access', 'logo', 'click-home',0,{nonInteraction: true});"><img src="/images/logo_clarityenglish.png" width="132" height="24"/></a>
		</div>

		<!-- Collect the nav links, forms, and other content for toggling -->
		<div class="collapse navbar-collapse" id="main-navbar-collapse">
		  <ul class="nav navbar-nav navbar-right">
	
			<li><a href="/support/" target="_blank" class="header-text general-text" onClick="ga('send', 'event', 'header-access', 'general-directory', 'click-support',0,{nonInteraction: true});">Support</a></li>
			<li><a href="/db_logout.php" class="header-text general-text" onClick="ga('send', 'event', 'header-access', 'signin-related', 'signout',0,{nonInteraction: true});">Logout</a></li>

		  </ul>
		</div><!-- /.navbar-collapse -->
	  </div><!-- /.container-fluid -->
	</nav>
<?php } ?>
		<?php } ?> 	