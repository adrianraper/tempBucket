$(document).ready(function() {

    // Error if no prefix passed
    var prefix = getURLParameter('prefix');
    var productCode = 59;
    var titleProductCode = 55;
    var userEmail = '';
    var password = '';
    var existingSubscription = false;

    console.log("running login.js");
    if (!prefix) {
        window.location = "http://www.clarityenglish.com/TenseBuster/6weeks/no-prefix.html";
        return false;
    } else {
        // Pass the prefix through to the placement test page
        $(".get-your-level a[href]").attr("href", "start.php?prefix=" + prefix);
        $("#changeLevel").attr("href", "change-my-level.php?prefix=" + prefix);
        $("#unsubscribe").attr("href", "unsubscribe.php?prefix=" + prefix);
        $("a.forgot").attr("href", "http://www.clarityenglish.com/support/forgotPassword.php?productCode=" + productCode + "&loginOption=128");
    }

    $("#loginForm").validate({
        rules: {
            userEmail: {
                remote: {
                    type: "POST",
                    url: "/Software/ResultsManager/web/amfphp/services/TB6weeksService.php",
                    data: {operation: 'isEmailValid', prefix: prefix, productCode: productCode},
                    dataType: "json",
                    dataFilter: function(data, dataType) {
                        $(".button-below-msg-box").hide();

                        var decodedData = jQuery.parseJSON(data);
                        if (decodedData == 'new user') {
                            console.log(decodedData + " is new");
                            //$("#errorMessage").text("This email doesn't have a subscription.");
                            return false;

                        } else if (decodedData.indexOf('user in wrong account') >= 0) {
                            console.log(decodedData + " is in wrong account");
                            //$("#errorMessage").text("This email is linked to a different account. Use another.");
                            return false;

                        } else if (decodedData == 'no subscription') {
                            console.log(decodedData + " existing user but no subscription");
                            existingSubscription = false;
                            return true;

                        } else if (decodedData == 'existing subscription') {
                            console.log(decodedData + " existing");
                            existingSubscription = true;
                            return true;

                        } else {
                            console.log(decodedData + " conflicts");
                            $("#errorMessage").text(data);
                            $(".button-below-msg-box").show();
                            return true;
                        }
                    }
                },
                required: true,
                email: true
            },
            password: {
                required: true
            }
        },
        messages: {
            userEmail: {
                required: "Please enter your email address.",
                email: "Incorrect email address format.",
                remote: "That email is not registered."
            },
            password: {
                required: "Please enter your password."
            }
        },
        submitHandler: function(form) {
 		
			$("#loadingMsg").show();
			$("#signIn").hide();
 getUser();
            return false;
        }
    });

    // Check the user details and then off to Tense Buster with them
    getUser = function() {

        // Use LoginGateway to sign in this user.
        var loginAPI = {method:"signInUser"};
        loginAPI.email = $("#userEmail").val();
        loginAPI.password = $("#password").val();
        loginAPI.productCode = 56;
        loginAPI.prefix = prefix;
        loginAPI.dbHost = 2;
        loginAPI.loginOption = 128;
        loginAPI.encryptData = true;

        $.ajax({
            type: "POST",
            url: "/Software/ResultsManager/web/amfphp/services/LoginGateway.php",
            data: JSON.stringify(loginAPI),
            dataType: "json",
            error: function(jqXHR, textStatus, errorThrown) {
                console.log('Error: ' + errorThrown);
                $("#errorMessage").text('Error: ' + errorThrown);
                $(".button-below-msg-box").show();
            },
            success: function (data) {

                // Any expected errors sent back?
                if (data.error) {
                    switch (data.error) {
                        case 200:
                            var message = 'That email is not registered.';
                            break;
                        case 253:
                            var message = 'Incorrect email or password.';
                            break;
                        default:
                            message = data.message;
                    }
                    console.log('Error: ' + data.error + ' ' + message);
                    $("#errorMessage").text(message);
                    $(".button-below-msg-box").show();
			$("#loadingMsg").hide();
			$("#signIn").show();

                } else if (data.user) {
                    $(".button-below-msg-box").hide();
                    //var password = data.user.password;
                    //var email = data.user.email;
                    var programURL = "/area1/TenseBuster/Start.php";
                    if (data.encryptedData)
                        programURL += "?data=" + data.encryptedData;
                    window.location = programURL;
                }
            }
        });

    }

    //iFrame colorbox
    $(".iframe-small").colorbox({
        iframe: true,
        width: "524px",
        height: "215px",
        scrolling: false,
        closeButton: false
    });


    $(".iframe-inline").colorbox({
        inline: true,
        width: "524px",
        height: "215px",
        scrolling: false,
        closeButton: false
    });


});

function getURLParameter(sParam){
    var sPageURL = window.location.search.substring(1);
    var sURLVariables = sPageURL.split('&');
    for (var i = 0; i < sURLVariables.length; i++){
        var sParameterName = sURLVariables[i].split('=');
        if (sParameterName[0] == sParam)
            return sParameterName[1];
    }
}
