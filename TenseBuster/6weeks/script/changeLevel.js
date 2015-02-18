$(document).ready(function() {

    // Error if no prefix passed
    var prefix = getURLParameter('prefix');
    var productCode = 59;
    var titleProductCode = 55;
    var userEmail = '';
    var password = '';
    var existingSubscription = false;

    if (!prefix) {
        $("#level-change-one").html("You must start from your library page to change your level.");
    } else {
        // Pass the prefix through to the home page
        $("#level-change-three a[href]").attr("href", "index.php?prefix=" + prefix);
        $("a.forgot").attr("href", "http://www.clarityenglish.com/support/forgotPassword.php?productCode=" + titleProductCode + "&loginOption=128");
    }
    $("#userEmail").val(getURLParameter('email'));

    $(".page#level-change-one").addClass("slideRight").show();
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
                            return false;

                        } else if (decodedData == 'existing subscription') {
                            console.log(decodedData + " existing");
                            existingSubscription = true;
                            return true;

                        } else {
                            console.log(decodedData + " conflicts");
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
                required: "Please type your email.",
                email: "That doesn't seem to be an email, please check it.",
                remote: "This email doesn't have a subscription in this account."
            },
            password: {
                required: "Please type your password."
            }
        },
        submitHandler: function(form) {
            checkSubscription();
            return false;
        }
    });

    $("#confirm").click(function() {

        if (!$("input[type='radio'][name='changelevel']").is(":checked"))
            return $("#errorMessage").text('Please choose a new level.');
        changeLevel();

        $("#sentEmail").text(userEmail);
        $(".page").removeClass().addClass("page");
        $(".page#level-change-one").hide();

        $(".page#level-change-two").addClass("fadeOut").fadeOut();
        $(".page#level-change-three").removeClass().addClass("page slideRight").show();
    });

    gotoConfirmation = function() {
        $(".page").removeClass().addClass("page");
        $(".page#level-change-three").hide();

        $(".page#level-change-one").addClass("fadeOut").fadeOut();
        $(".page#level-change-two").removeClass().addClass("page slideRight").show();
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

    // Check the subscription for this user
    checkSubscription = function() {

        console.log("off to check subscription");

        userEmail = $("#userEmail").val();
        password = $("#password").val();

        // Use LoginGateway to find this user.
        var loginAPI = {method:"getSubscription"};
        loginAPI.email = userEmail;
        loginAPI.password = password;
        loginAPI.productCode = productCode;
        loginAPI.prefix = prefix;
        loginAPI.dbHost = 2;
        loginAPI.loginOption = 128;

        $.ajax({
            type: "POST",
            url: "/Software/ResultsManager/web/amfphp/services/LoginGateway.php",
            data: JSON.stringify(loginAPI),
            dataType: "json",
            error: function(jqXHR, textStatus, errorThrown) {
                console.log('Error: ' + errorThrown);
                $("#errorMessage").text('Error: ' + errorThrown);
            },
            success: function (data) {

                // Any expected errors sent back?
                if (data.error) {
                    switch (data.error) {
                        case 200:
                            var message = 'That email is not registered.';
                            break;
                        case 253:
                            message = 'The email or password you typed is incorrect.';
                            break;
                        default:
                            message = data.message;
                    }
                    console.log('Error: ' + data.error + ' ' + message);
                    $("#errorMessage").text(message);
                    $(".button-below-msg-box").show();

                } else if (data.user) {
                    if (data.subscription) {
                        console.log("got subscription for " + userEmail + " " + data.subscription.ClarityLevel);
                        $("#weekMessage").text("week " + data.subscription.week);
                        switch (data.subscription.ClarityLevel) {
                            case 'ELE':
                                var titleName = 'Elementary';
                                break;
                            case 'LI':
                                titleName = 'Lower Intermediate';
                                break;
                            case 'INT':
                                titleName = 'Intermediate';
                                break;
                            case 'UI':
                                titleName = 'Upper Intermediate';
                                break;
                            case 'ADV':
                                titleName = 'Advanced';
                                break;
                        }
                        $("#ClarityLevelMessage").text(titleName);
                        $("#icon"+data.subscription.ClarityLevel).removeClass().addClass("current");
                        $(".button-below-msg-box").hide();

                        gotoConfirmation();

                    } else {
                        console.log('No existing subscription');
                        $("#errorMessage").text("You don't have a subscription, please register.");
                    }
                }
            }
        });

    }

    changeLevel = function() {

        var newLevel = $("input[name='changelevel']:checked").val();

        console.log("new level is " + newLevel + " and you are " + userEmail);
        $.ajax({
            type: "POST",
            url: "/Software/ResultsManager/web/amfphp/services/TB6weeksService.php",
            data: {operation: 'changeLevel', productCode: productCode, user: "userEmail=" + userEmail + "&password=" + password, level: newLevel},
            dataType: "json",
            error: function(jqXHR, textStatus, errorThrown) {
                console.log('Error: ' + errorThrown);
            },
            success: function (data) {
                console.log('Success: ' + data);
                $("#validationMessage").text(data);
            }
        });
    }

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
