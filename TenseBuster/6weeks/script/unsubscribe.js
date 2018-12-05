$(document).ready(function() {

    // Error if no prefix passed
    var prefix = getURLParameter('prefix');
    var productCode = 59;
    var titleProductCode = 55;
    var userEmail = '';
    var password = '';
    var existingSubscription = false;

    if (!prefix) {
        $("#unsubscribe-one").html("You must start from your library page to unsubscribe.");
    } else {
        // Pass the prefix through to the home page
        $("#unsubscribe-two a[href]").attr("href", "index.php?prefix=" + prefix);
        $("a.forgot").attr("href", "https://www.clarityenglish.com/support/forgotPassword.php?productCode=" + productCode + "&loginOption=128");
    }
    $("#userEmail").val(getURLParameter('email'));

    $(".page#unsubscribe-one").addClass("slideRight").show();
    $(".button-below-msg-box").hide();

    $("#loginForm").validate({
        rules: {
            userEmail: {
                remote: {
                    type: "POST",
                    url: "/Software/ResultsManager/web/amfphp/services/TB6weeksService.php",
                    data: {operation: 'isEmailValid', prefix: prefix, productCode: productCode},
                    dataType: "json",
                    dataFilter: function(data, dataType) {
                        var decodedData = jQuery.parseJSON(data);
                        if (decodedData == 'new user') {
                            //console.log(decodedData + " is new");
                            //$("#errorMessage").text("This email doesn't have a subscription.");
                            return false;

                        } else if (decodedData.indexOf('user in wrong account') >= 0) {
                            //console.log(decodedData + " is in wrong account");
                            //$("#errorMessage").text("This email is linked to a different account. Use another.");
                            return false;

                        } else if (decodedData == 'no subscription') {
                            //console.log(decodedData + " existing user but no subscription");
                            existingSubscription = false;
                            return false;

                        } else if (decodedData == 'existing subscription') {
                            //console.log(decodedData + " existing");
                            existingSubscription = true;
                            return true;

                        } else {
                            //console.log(decodedData + " conflicts");
                            return false;
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
                remote: "That email address has not been registered."
            },
            password: {
                required: "Please enter your password."
            }
        },
        submitHandler: function(form) {
            $("#signIn").hide();
            $("#loadingMsg").show();
            unsubscribe();
            return false;
        }
    });

    gotoConfirmation = function() {
        $("#loadingMsg").hide();
        $(".page").removeClass().addClass("page");

        $(".page#unsubscribe-one").addClass("fadeOut").fadeOut();
        $(".page#unsubscribe-two").removeClass().addClass("page slideRight").show();
    }

    unsubscribe = function() {

        userEmail = $("#userEmail").val();
        password = $("#password").val();

        $.ajax({
            type: "POST",
            url: "/Software/ResultsManager/web/amfphp/services/TB6weeksService.php",
            data: {operation: 'unsubscribe', productCode: productCode, user: "userEmail=" + userEmail + "&password=" + password},
            dataType: "json",
            error: function(jqXHR, textStatus, errorThrown) {
                //console.log('Error: ' + errorThrown);
                $("#signIn").show();
                $("#loadingMsg").hide();
            },
            success: function (data) {
                //console.log('Return of unsubscribe is ' + data);
                switch (data) {
                    case "wrong password":
                    case "no such user":
                        var message = "Incorrect email or password.";
                        break;
                    case "done":
                        message = false;
                        break;
                }

                if (message) {
                    $("#errorMessage").text(message);
                    $(".button-below-msg-box").show();
                    $("#signIn").show();
                    $("#loadingMsg").hide();
                } else {
                    gotoConfirmation();
                }
            }
        });
    }

    //iFrame colorbox
    $(".iframe-small").colorbox({
        iframe:true,
        width:"524px",
        height:"215px",
        scrolling:false,
        closeButton:false
    });

    $(".iframe-inline").colorbox({
        inline:true,
        width:"524px",
        height:"215px",
        scrolling:false,
        closeButton:false
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
