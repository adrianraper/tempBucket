// Definitions
apiGatewayUrl = "http://dock.projectbench/Software/Tools/apiGateway.php"
programsUrl = "http://dock.projectbench/Software/Tools/clarityPrograms.php"
clarityAuthentication = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjbGFyaXR5ZW5nbGlzaC5jb20iLCJpYXQiOjE1MzgxMDg3OTEsInByZWZpeCI6IkNsYXJpdHkifQ.Ep32mRIuZqhtkq1YTyTwGUicuhfbkF2m0R1yJeU7WZY";

// What to do and where to focus?
// If you type in any of these fields, set Enter to mean
// email, password => signin.click
// serial, activateName, activateEmail, activatePassword, confirmPassword => activate.click

// If you get an error from these functions, put the status in
// signin => signinStatus
// checkSerial, checkEmail => signinStatus

// Only enable Activate button once token, email, password and confirm password all typed

$(function() {
	$("#btnStartDPT").click(function() {
		prepareData(63);
	});
    $("#btnStartTB").click(function() {
        prepareData(68);
    });
    $("#btnStartSSS").click(function() {
        prepareData(66);
    });
    $("#btnStartCP1").click(function() {
        prepareData(57);
    });

    // Pick up Enter and see what it means
    $("form#userDetails").keypress(function(e) {
        if(e.which == 13) {
            signin($('#login').val(), $('#password').val());
        }
    });
    $("form#forgotDetails").keypress(function(e) {
        if(e.which == 13) {
            forgot($('#forgotEmail').val());
        }
    });
    $("form#tokenDetails").keypress(function(e) {
        if(e.which == 13) {
            activate($('#serial').val(), $('#activateName').val(), $('#activateEmail').val(), $('#activatePassword').val());
        }
    });
    $("form#dptDetails").keypress(function(e) {
        if(e.which == 13) {
            getUser($('#dptEmail').val(), clarityAuthentication);
        }
    });

    // Once a token has been typed, see if it is valid
    $('#serial').on( "focusout", function(){
        checkSerial($(this).val());
    });

    // Once any email has been typed, see if it is already linked to an account
    $('#forgotEmail, #activateEmail').on( "focusout", function(){
        checkEmail($(this));
    });

    // Sign in
    $('#signin').on( "click", function(){
        signin($('#login').val(), $('#password').val());
    });
    // Sign out
    $('#signout').on( "click", function(){
        signout();
    });
    // Forgot email
    $('#forgot').on( "click", function(){
        forgot($('#forgotEmail').val());
    });
    // DPT result
    $('#dptResult').on( "click", function(){
        getUser($('#dptEmail').val(), clarityAuthentication);
    });

    // Same passwords
    $('#confirmPassword').on( "focusout", function(){
        matchPasswords($('#activatePassword').val(), $('#confirmPassword').val());
    });

    // Activate the token
    $('#activate').on( "click", function(){
        activate($('#serial').val(), $('#activateName').val(), $('#activateEmail').val(), $('#activatePassword').val());
    });

});
var showAndHideEvents = function(event, msg) {
    switch (event) {
        case "reset":
            $("#status").text("");
            break;
        case "wrongPassword":
            $("#status").text("That email or password do not match.");
            break;
        case "signin":
            $("#status").text("Taking you to your program page.");
            break;
        case "activate":
            $("#status").text("Taking you to your program page.");
            break;
        case "generalError":
            console.log(msg);
            $("#status").text(msg);
            break;
        case "usedToken":
        case "invalidToken":
            $("#activateName").prop('disabled', true);
            $("#activateEmail").prop('disabled', true);
            $("#activatePassword").prop('disabled', true);
            $("#confirmPassword").prop('disabled', true);
            if (msg && msg == 'used') {
                $("#status").text("This token has already been used.");
            } else {
                $("#status").text("Check your token, this is not valid.");
            }
            break;
        case "validToken":
            $("#activateName").prop('disabled', false);
            $("#activateEmail").prop('disabled', false);
            $("#activatePassword").prop('disabled', false);
            $("#confirmPassword").prop('disabled', false);
            $("#status").text("OK");
            break;
        case "existingAccount":
            $("#activateName").prop('disabled', true);
            $("#activatePassword").prop('disabled', false);
            $("#confirmPassword").prop('disabled', true);
            $("#activatePassword").focus();
            $("#status").text("That email already has an account. If it is you, please type your password.");
            break;
        case "newAccount":
            $("#activateName").prop('disabled', false);
            $("#confirmPassword").prop('disabled', false);
            $("#status").text("OK");
            break;
        case "invalidAccount":
            $("#activateName").prop('disabled', true);
            $("#activatePassword").prop('disabled', true);
            $("#confirmPassword").prop('disabled', true);
            $("#activate").prop('disabled', true);
            $("#status").text("That email can't be used.");
            break;
        case "invalidRegisteredEmail":
            $("#status").text("That email is not registered in our database.");
            $("#forgot").prop('disabled', true);
            break;
        case "validRegisteredEmail":
            $("#status").text("OK");
            $("#forgot").prop('disabled', false);
            break;
        case "sentForgotEmail":
            $("#status").html("<p>We have sent you an email with a link to reset your password.</p>");
            $("#forgot").prop('disabled', false);
            break;
        case "DPTresults":
            // Format the result(s)
            // [{"date":"2017-03-15 12:46:53","result":{"level":"B2","numeric":46}}]
            var build='';
            for (var i = 0; i < msg.length; i++) {
                if (msg[i].hasOwnProperty('date')) {
                    build += '<p>' + msg[i]['date'].substring(0,16);
                }
                if (msg[i].hasOwnProperty('result')) {
                    build += ' CEFR: ' + msg[i]['result']['level'] + ' (RN: ' + msg[i]['result']['numeric'] + ')';
                }
                build += '</p>'
            }
            $("#status").html("<p>DPT result(s)</p>"+build);
            break;

        default:
    }
}
var getUser = function(email, clarityAuthentication) {
    showAndHideEvents('reset');
    var data = {command:"getAuthenticatedUser", email:email, token:clarityAuthentication};
    console.log("call: " + data);
    $.ajax({
        method: "POST",
        url: apiGatewayUrl,
        dataType: "json",
        data: JSON.stringify(data)
    }).done(function(data, status, jqXHR) {
        var success = data.success;
        if (success) {
            // Was it successful?
            if (data.details.authentication) {
                getDPTresult(email, data.details.authentication);
            } else {
                showAndHideEvents("invalidRegisteredEmail");
            }
            console.log(data.details);
        } else {
            showAndHideEvents("generalError", data.error.message);
        }
    }).fail(function(jqXHR,status,err) {
        showAndHideEvents("generalError", err.message);
    });
}
var getDPTresult = function(email, token) {
    showAndHideEvents('reset');
    var data = {command:"getResult", productCode:63, token:token};
    console.log("call: " + data);
    $.ajax({
        method: "POST",
        url: apiGatewayUrl,
        dataType: "json",
        data: JSON.stringify(data)
    }).done(function(data, status, jqXHR) {
        var success = data.success;
        if (success) {
            // Was it successful?
            if (data.details) {
                showAndHideEvents("DPTresults", data.details);
            }
            console.log(data.details);
        } else {
            showAndHideEvents("generalError", data.error.message);
        }
    }).fail(function(jqXHR,status,err) {
        showAndHideEvents("generalError", err.message);
    });
}

var forgot = function(email) {
    showAndHideEvents('reset');
    var data = {command:"forgotPassword", email:email};
    console.log("call: " + data);
    $.ajax({
        method: "POST",
        url: apiGatewayUrl,
        dataType: "json",
        data: JSON.stringify(data)
    }).done(function(data, status, jqXHR) {
        var success = data.success;
        if (success) {
            // Was it successful?
            if (data.details.status == 'sent') {
                showAndHideEvents("sentForgotEmail");
            } else {
                showAndHideEvents("invalidRegisteredEmail");
            }
            console.log(data.details);
        } else {
            showAndHideEvents("generalError", data.error.message);
        }
    }).fail(function(jqXHR,status,err) {
        showAndHideEvents("generalError", err.message);
    });
}
var matchPasswords = function(one, two){
    if (one != two) {
        $("#status").text("Passwords don't match.");
        console.log(one + '!=' + two);
        return false;
    }
}
var activate = function(serial, name, email, password) {
    showAndHideEvents('reset');
    var hashedPassword = passwordHash(password, email);
    var data = {command:"activateToken", email:email, password:hashedPassword, name:name, token:serial, appVersion:"1"};
    console.log("try to activate with " + data);
    $.ajax({
        method: "POST",
        url: apiGatewayUrl,
        dataType: "json",
        data: JSON.stringify(data)
    }).done(function(data, status, jqXHR) {
        var success = data.success;
        if (success) {
            showAndHideEvents("activate");
            console.log(data.details);
            signin(email, hashedPassword);
        } else {
            showAndHideEvents("generalError", data.error.message);
        }
    }).fail(function(jqXHR,status,err) {
        showAndHideEvents("generalError", err.message);
    });
}

var getTestResult = function(token) {
    showAndHideEvents('reset');
    var data = {command:"getResult", token:token, productCode:63};
    console.log("try to get test result" + JSON.stringify(data));
    $.ajax({
        method: "POST",
        url: apiGatewayUrl,
        dataType: "json",
        data: JSON.stringify(data)
    }).done(function(data, status, jqXHR) {
        var success = data.success;
        if (success) {
            showAndHideEvents("gotResult", data.details.level);
            console.log(data.details);
        } else {
            showAndHideEvents("generalError", data.error.message);
        }
    }).fail(function(jqXHR,status,err) {
        showAndHideEvents("generalError", err.message);
    });
}

var signout = function() {
    window.location.replace('clarityPortal.php');
}

var signin = function(login, password) {
    showAndHideEvents('reset');
    var hashedPassword = passwordHash(password, login);
    var data = {command:"signin", email:login, password:hashedPassword};
    console.log(data);
    $.ajax({
        method: "POST",
        url: apiGatewayUrl,
        dataType: "json",
        data: JSON.stringify(data)
    }).done(function(data, status, jqXHR) {
        var success = data.success;
        if (success) {
            $("#status").text("You can access " +  data.details.links.length + " programs.");
            console.log(data.details);
            // Create a hidden form with the user data and submit it to take you to the next page
            var f = document.getElementById('datatopass');
            f.user.value = JSON.stringify(data.details.user);
            f.links.value = JSON.stringify(data.details.links);
            f.account.value = JSON.stringify(data.details.account);
            f.group.value = JSON.stringify(data.details.group);
            f.authentication.value = JSON.stringify(data.details.authentication);
            f.submit();
        } else {
            showAndHideEvents("generalError", data.error.message);
        }
    }).fail(function(jqXHR,status,err) {
        showAndHideEvents("generalError", err.message);
    });
}
var passwordHash = function(password, email) {
    return md5(email + password);
}
var checkEmail = function(field) {
    var email = field.val();
    showAndHideEvents('reset');
    var data = {command:"getEmailStatus", email:email};
    $.ajax({
        method: "POST",
        url: apiGatewayUrl,
        dataType: "json",
        data: JSON.stringify(data)
    }).done(function( msg ) {
        var success = msg.success;
        if (success) {
            console.log(msg.details);
            if (field.attr('id') == "forgotEmail") {
                if (msg.details.status == 'used') {
                    showAndHideEvents("validRegisteredEmail");
                } else {
                    showAndHideEvents("invalidRegisteredEmail");
                }
            } else {
                if (msg.details.status == 'used') {
                    showAndHideEvents("existingAccount");
                } else if (msg.details.status == 'none') {
                    showAndHideEvents("newAccount");
                } else {
                    showAndHideEvents("invalidAccount");
                }
            }
        } else {
            showAndHideEvents("invalidAccount");
        }
    }).fail(function(jqXHR,status,err) {
        showAndHideEvents("generalError", err.message);
    });
}

var checkSerial = function(serial) {
    showAndHideEvents('reset');
    // First check typos using the check digit
    if (!checkDigit(serial)) {
        showAndHideEvents("invalidToken");
        console.log(serial);
        return false;
    }
    // You could hyphenate the serial for going forward...
    var data = {command:"getTokenStatus", token:serial};
    $.ajax({
        method: "POST",
        url: apiGatewayUrl,
        dataType: "json",
        data: JSON.stringify(data)
    }).done(function( msg ) {
        var success = msg.success;
        if (success) {
            if (msg.details.status == 'used') {
                showAndHideEvents("usedToken", msg.details.status);
                console.log(msg.details);
            } else if (msg.details.status == 'ok') {
                showAndHideEvents("validToken");
            } else {
                showAndHideEvents("invalidToken", msg.details.status);
                console.log(msg.details.status);
            }

        } else {
            $("#activateStatus").text("Token is " + msg.error.message);
            console.log(msg.details);
        }
    }).fail(function(jqXHR,status,err) {
        showAndHideEvents("generalError", err.message);
    });
}
var checkDigit = function(str) {
    var sum,
        weight,
        digit,
        check,
        i;
    // remove all characters that are not spaces
    str = str.replace(/[^0-9X]/gi, '');

    if (str.length != 13) {
        return false;
    }

    sum = 0;
    for (i = 0; i < 12; i++) {
        digit = parseInt(str[i]);
        if (i % 2 == 1) {
            sum += 3*digit;
        } else {
            sum += digit;
        }
    }
    check = (10 - (sum % 10)) % 10;
    return (check == str[str.length-1]);
}
var createJWT = function(productCode) {
    var userIdentifier = $('#name').val();
    var prefix = $('#prefix').val();
    var key = $('#key').val();
    var data = { appVersion: "2", command: "createJWT", payload: { productCode: productCode, prefix: prefix, login: userIdentifier}, key: key };
    $.ajax({
        method: "POST",
        url: apiGatewayUrl,
        dataType: "json",
        data: JSON.stringify(data)
    }).done(function( msg ) {
        $('#JWT').text = msg.details.token;
        var url = "/Software/Tools/autoSignIn.php?apiToken=" + msg.details.token;
        console.log(url);
        window.open(url, '_blank');
    }).fail(function(jqXHR,status,err) {
        showAndHideEvents("generalError", err.message);
    });
}
var prepareData = function(productCode) {
    var name = $("#name").val();
    var seemsOK;

    //hide the message
    $("div#status-box").hide();
    $(".button").prop('disabled', true);
    $("#name").parent().removeClass("has-error");

    // Check that all the key parts have valid data
    if (name==undefined || name=="") {
        seemsOK = false;
        $("div#status-box").show();
        $("#name").parent().addClass("has-error");
        $("#status-text").addClass("error-msg");
        $("#status-text").text("Please fill this in and try again...");
    } else {
        seemsOK = true;
    }

    if (seemsOK){
        createJWT(productCode);
    } else	{
        $(".button").prop('disabled', false);
    }
}

