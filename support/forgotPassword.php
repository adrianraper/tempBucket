<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>ClarityEnglish: Online English since 1992 | Support</title>
    <link rel="shortcut icon" href="https://www.clarityenglish.com/images/favicon.ico" type="image/x-icon" />
    <meta name="robots" content="ALL">
    <meta name="Description" content="Find answers to questions about installation, compatibility, licencing and technical issues relating to ClarityEnglish programs.">
    <meta name="keywords" content="Technical support from ClarityEnglish, installation, compatibility, licencing, technical issues, ask support">

    <!-- Bootstrap -->
    <link href="https://www.clarityenglish.com/bootstrap/css/bootstrap.min.css?v=170824" rel="stylesheet">
    <link href="https://www.clarityenglish.com/bootstrap/css/mobile-max767.css?v=170824" rel="stylesheet">
    <link href="https://www.clarityenglish.com/bootstrap/css/support-mobile.css?v=170824" rel="stylesheet">
    <link href="https://www.clarityenglish.com/bootstrap/css/tablet-768-1199.css?v=170824" rel="stylesheet">

    <!---Font style--->
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,300i,400,400i,600,600i,700,700i,800,800i" rel="stylesheet">
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
    <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->

    <!---Google Analytics Tracking--->
    <script>
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
            (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
            m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

        ga('create', 'UA-873320-20', 'auto');
        ga('send', 'pageview');

    </script>

    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="https://www.clarityenglish.com/bootstrap/js/bootstrap.min.js"></script>

    <link rel="stylesheet" href="../css/forgotpw.css" />
    <script src="../script/forgotPasswordControl.js"></script>
</head>
<body>

<?php include $_SERVER['DOCUMENT_ROOT'].'/inc_nav.php'; ?>

<div class="jumbotron support-jumbotron">
    <div class="banner-txt-box Trans-W-bg text-center">
        <h1 id="general-banner-txt">Support</h1>
    </div>
</div>

<div class="P-E7DAE9-bg">
    <div class="container ">
        <div class="row align-top support-ticket">
            <div class="col-lg-6 col-md-6 col-sm-5 support-left">
                <p id="support-header" class="general-subtag">Find your password</p>
                <p class="general-text">Type your email and we will send your password. If you have forgotten or don&apos;t know the email linked to your account, please email <span class="general-bold-tag">support@clarityenglish.com</span> with your name and institution. </p>
            </div>
            <!-- form -->
            <div class="col-lg-6 col-md-6 col-sm-7 support-right">
                <div class="support-lead-detail general-shadow">
                    <form method="post" id="email-form">
                        <div class="form-group">
                            <input type="email" class="form-control" id="registeredEmail" placeholder="Your email" required autofocus>
                        </div>
                        <div id="error" class="lead-warn-email lead-warn-box">
                            <p class="general-text error-msg">xxx</p>
                        </div>
                        <div class="general-button-box">
                            <button type="submit" id="btn-submit" class="btn btn-default general-input-btn input-bg-p">Email me</button>
                        </div>

                    </form>
                </div>
            </div>
            <!-- end of form-->
        </div>
    </div>
</div>

<?php include $_SERVER['DOCUMENT_ROOT'].'/inc_footer.php'; ?>

</body>
</html>
