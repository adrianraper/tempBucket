<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ClarityEnglish reset password</title>
    <link rel="shortcut icon" href="https://www.clarityenglish.com/images/favicon.ico" type="image/x-icon"/>
    <meta name="robots" content="ALL">
    <meta name="Description" content="Integration examples for ClarityEnglish programs">
    <meta name="keywords" content="Dynamic Placement Test, ClarityEnglish">

    <!-- Bootstrap -->
    <link href="https://www.clarityenglish.com/bootstrap/css/bootstrap.min.css?v=170828" rel="stylesheet">
    <link href="https://www.clarityenglish.com/bootstrap/css/mobile-max767.css?v=170828" rel="stylesheet">
    <link href="https://www.clarityenglish.com/bootstrap/css/tablet-768-1199.css?v=170828" rel="stylesheet">
    <script src="js/md5.js"></script>

    <!---Font style--->
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,300i,400,400i,600,600i,700,700i,800,800i"
          rel="stylesheet">
    <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
    <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
    <style>
        .dpt-register-bg {
            padding: 5% 2%;
            background: rgba(68, 170, 153, 0.20);
            height: 100%;
        }

        .price-box .about-box {
            margin-top: 5%;
        !important
        }

        .price-thumbnail-box {
            margin-top: 6px;
        }

        .btn-dpt {
            font-family: Helvetica Neue, Helvetica, Arial, sans-serif;
            width: 100%;
            height: 40px;
            border: 2px solid #44AA66;;
            font-size: 17px;
            outline: none;
            color: #44AA66;;
            background: white;
        }

        .btn-dpt:hover {
            color: white;
            background: rgba(42, 165, 176, 1);
            background: -moz-linear-gradient(left, rgba(42, 165, 176, 1) 0%, rgba(42, 165, 176, 1) 20%, rgba(68, 170, 102, 1) 80%, rgba(68, 170, 102, 1) 100%);
            background: -webkit-gradient(left top, right top, color-stop(0%, rgba(42, 165, 176, 1)), color-stop(20%, rgba(42, 165, 176, 1)), color-stop(80%, rgba(68, 170, 102, 1)), color-stop(100%, rgba(68, 170, 102, 1)));
            background: -webkit-linear-gradient(left, rgba(42, 165, 176, 1) 0%, rgba(42, 165, 176, 1) 20%, rgba(68, 170, 102, 1) 80%, rgba(68, 170, 102, 1) 100%);
            background: -o-linear-gradient(left, rgba(42, 165, 176, 1) 0%, rgba(42, 165, 176, 1) 20%, rgba(68, 170, 102, 1) 80%, rgba(68, 170, 102, 1) 100%);
            background: -ms-linear-gradient(left, rgba(42, 165, 176, 1) 0%, rgba(42, 165, 176, 1) 20%, rgba(68, 170, 102, 1) 80%, rgba(68, 170, 102, 1) 100%);
            background: linear-gradient(to right, rgba(42, 165, 176, 1) 0%, rgba(42, 165, 176, 1) 20%, rgba(68, 170, 102, 1) 80%, rgba(68, 170, 102, 1) 100%);
            filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#2aa5b0', endColorstr='#44aa66', GradientType=1);
        }

        .logo {
            min-width: 90px;
            width: 10vw;
        }

        #dpt-logo {
            width: 27vw;
            max-width: 200px;
        }

        #JWT {
            overflow-wrap: break-word;
            word-wrap: break-word;
        }
    </style>
</head>
<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
<!-- Include all compiled plugins (below), or include individual files as needed -->
<script src="https://www.clarityenglish.com/bootstrap/js/bootstrap.min.js"></script>
<!-- Specifically for this form -->
<script src="actionResetPassword.js"></script>
<body>

<!--- code is from the inc_nav_simple.php--->
<nav class="navbar-default" id="main-nav">
    <div class="container-fluid container">
        <div class="navbar-header">
            <a class="navbar-brand" href="/">
                <img src="https://www.clarityenglish.com/images/logo_clarityenglish.png" width="132" height="24"/>
            </a>
        </div>
    </div>
</nav>

<div class="dpt-register-bg">
    <div class="container">
        <div class="row price-box">

            <div class="col-lg-6 col-md-6 col-sm-6">
                <div class="lead-detail general-shadow">
                    <div class="row">
                        <div class="col-xs-8">
                            <p class="general-text">
                                Access and authentication
                            </p>
                        </div>
                    </div>
                    <form id="userDetails">
                        <p class="general-bold-tag">Choose a new password for your account</p>

                        <div class="form-group">
                            <p id="email" type="text" class="form-control general-text"></p>
                        </div>
                        <div class="form-group">
                            <input id="newPassword" type="password" class="form-control general-text"
                                   placeholder="new password">
                        </div>
                        <div class="form-group">
                            <input id="confirmPassword" type="password" class="form-control general-text"
                                   placeholder="retype new password">
                        </div>
                        <div class="general-button-box">
                            <input type="button" class="btn btn-default general-input-btn input-bg-p" value="Reset" id="reset" name="reset" accesskey="g" tabindex="3">
                        </div>
                        <div id="status-box" class="lead-warn-field lead-warn-box">
                            <p id="status-text" class="general-text">Status message</p>
                        </div>

                    </form>
                </div>
                <div class="lead-detail general-shadow">
                    <div class="row">
                        <div class="col-xs-8">
                            <p id="signinStatus" class="general-text">
                                After resetting your password, go back to the program and sign in.
                            </p>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>
</body>
</html>
