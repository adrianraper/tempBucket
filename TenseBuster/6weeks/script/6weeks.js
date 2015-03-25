$(document).ready(function() {

    // Error if no prefix passed
    var prefix = getURLParameter('prefix');
    var productCode = 59;
    var titleProductCode = 55;
    var userEmail = '';
    var password = '';
    var existingSubscription = false;
    var existingUser = false;

    console.log("load 6weeks.js");

    if (!prefix) {
        $("#level-test").html("You must start from your library page to take the level test.");
    } else {
        // Pass the prefix through to the home page
        $("#results a[href]").attr("href", "index.php?prefix=" + prefix);
        $("a.forgot").attr("href", "http://www.clarityenglish.com/support/forgotPassword.php?productCode=" + titleProductCode + "&loginOption=128");
    }

    //Start page
    $(".page#level-test").addClass("slideRight").show();
    $("#forgotPasswordLink").hide();

    $("#btn-go-to-register").click(function() {

        $("#menu-register").find(".step").removeClass().addClass("step select");
        $("#menu-register").find(".arrow").removeClass().addClass("arrow select");

        $("#menu-level-test").find(".arrow").removeClass().addClass("arrow off");
        $("#menu-level-test").find(".step").removeClass().addClass("step on");

        $("#menu-results").find(".arrow").removeClass().addClass("arrow off");
        $("#menu-results").find(".step").removeClass().addClass("step off");

        $(".page").removeClass().addClass("page");
        $(".page#results").hide();

        $(".page#level-test").addClass("fadeOut").fadeOut();
        $(".page#register").removeClass().addClass("page slideRight").show();

        $("#leveltest-complete-bar").hide();
        $("#holder").removeClass();

    });

    $(".btn-go-to-results").click(function() {
        console.log("you said OK");
        submitTestData();
    });

    showResult = function() {

        $("#sentEmail").text(userEmail);

        $("#menu-results").find(".step").removeClass().addClass("step select");
        $("#menu-results").find(".arrow").removeClass().addClass("arrow select");

        $("#menu-register").find(".arrow").removeClass().addClass("arrow off");
        $("#menu-register").find(".step").removeClass().addClass("step on");

        $("#menu-level-test").find(".arrow").removeClass().addClass("arrow off");
        $("#menu-level-test").find(".step").removeClass().addClass("step on");

        $(".page").removeClass().addClass("page");
        $(".page#level-test").hide();
        $(".page#register").addClass("fadeOut").fadeOut();
        $(".page#results").removeClass().addClass("page slideRight").show();

        $("#leveltest-complete-bar").hide();
        parent.$.colorbox.close();
        return false;

    };

    existingUserSettings = function(exists) {
        console.log("set user name to " + exists);
        $("#userName").prop('disabled', exists);
        $("label[for='password']").prop('disabled', exists);
        $("#confirmPassword").prop('disabled', exists);
        $("label[for='confirmPassword']").prop('disabled', exists);
        if (exists) {
            $("label[for='password']").text('You already have an account, what is your password?');
            $("#forgotPasswordLink").show();
        } else {
            $("label[for='password']").text('What password do you want to use?');
            $("#forgotPasswordLink").hide();
        }
        existingUser = exists;
    };

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
                            existingSubscription = false;
                            existingUserSettings(false);
                            return true;

                        } else if (decodedData.indexOf('user in wrong account') >= 0) {
                            console.log(decodedData + " is in wrong account");
                            return false;

                        } else if (decodedData == 'no subscription') {
                            console.log(decodedData + " existing user but no subscription");
                            existingSubscription = false;
                            existingUserSettings(true);
                            return true;

                        } else if (decodedData == 'existing subscription') {
                            console.log(decodedData + " existing");
                            existingSubscription = true;
                            existingUserSettings(true);
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
            },
            confirmPassword: {
                equalTo: "#password"
            }
        },
        messages: {
            userEmail: {
                required: "Please type your email.",
                email: "That doesn't seem to be an email, please check it.",
                remote: "This email is already linked to a different account."
            },
            password: {
                required: "Please type your password."
            },
            confirmPassword: {
                equalTo: "The two passwords must be the same."
            }
        },
        submitHandler: function(form) {
            userEmail = $("#userEmail").val();
            password = $("#password").val();

            // If it is an existing user, check the password before you submit results
            if (existingUser) {
                checkPassword();
            } else {
                checkSubscription();
            }
            return false;
        }
    });

    checkPassword = function() {

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
                    // If there IS a subscription too, you can pass the details to the warning
                    // You are still about to do ANOTHER check to see if there is a subscription...
                    if (data.subscription) {
                        $("#inline-level-reset #weekMessage").text(data.subscription.week);
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
                        $("#inline-level-reset #ClarityLevelMessage").text(titleName);

                    }
                    checkSubscription();
                    $(".button-below-msg-box").hide();
                }
            }
        });
    }

    checkSubscription = function() {
        if (existingSubscription) {
            console.log("trying to show color box");
            // Show the existing subscription warning
            $.colorbox({
                href: "#inline-level-reset",
                inline: true,
                width: "524px",
                height: "215px",
                scrolling: false,
                closeButton: false
            });
        } else {
            submitTestData();
        }
    }

    // Send the test data to the server
    submitTestData = function() {

        console.log("submitTestData");

        // get the answers
        var answers = '';
        // only take multiple choice items if selected
        $('.question-text input[type=radio]').filter(":checked").each(function(index){
            answers += '<input class="MultipleChoiceQuestion" id="' + $(this).attr("name") + '" value="' + $(this).attr("value") + '" />';
        });
        // only take gapfill if something is typed
        $('.question-text input[type=text]').filter(function() {return this.value.length > 0;}).each(function(index){
            answers += '<input class="GapFillQuestion" id="' + $(this).attr("id") + '" value="' + $(this).val() + '" />';
        });
        //var answers = $('#testInputs').serialize();
        console.log("answers=" + answers);
        $.ajax({
            type: "POST",
            url: "/Software/ResultsManager/web/amfphp/services/TB6weeksService.php",
            data: {operation: 'submitAnswers', answers: answers, code: $("#codeHolder").text(), user: $("#loginForm").serialize(), prefix: prefix, productCode: productCode},
            dataType: "json",
            error: function(jqXHR, textStatus, errorThrown) {
                console.log('Error: ' + errorThrown);
            },
            success: function (data) {
                //var resultsData = jQuery.parseJSON(data);
                console.log('Marked ' + data.score + '%, debug ' + data.debug + '; level ' + data.ClarityLevel + ' questions (' + data.correct + ',' + data.wrong + ',' + data.skipped + ')');

                switch (data.ClarityLevel) {
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
                $("#icon"+data.ClarityLevel).removeClass().addClass("current");
                //$("a#programUrl").attr("href", data.startProgram);
                showResult();
            }
        });
    };

    getQuestions = function () {

        // Inject the questions
        $.ajax({
            type: "GET",
            url: "/Software/ResultsManager/web/amfphp/services/TB6weeksService.php",
            data: {operation: 'getQuestions', exercise: '1193901049540.xml', prefix: prefix, productCode: productCode},
            dataType: "xml",
            error: function(jqXHR, textStatus, errorThrown) {
                console.log('Error: ' + errorThrown);
                $("#testPlaceholder").append(errorThrown);
            },
            success: function (xml) {
                console.log('Read file successfully');

                // Any errors sent back?
                $(xml).find("error").each(function () {
                    var message = $(this).attr("message");
                    console.log('Error: ' + message);
                    $("#testPlaceholder").append(message);
                });

                $("#testPlaceholder").html("");
                // Parse the xml file and get data
                var questionNumber = 1;
                $(xml).find(".question").each(function () {
                    // What is the id of this question?
                    var questionID = $(this).attr("id");

                    // If any input doesn't have a type set, make it explicitly text
                    $(this).find("input:not([type])").attr("type", "text");

                    // Gapfill needs to change the input id to be the question id
                    $(this).find("input[id]").attr("id", questionID);

                    // multiple choice needs to have the list <a> nodes turned into radio buttons
                    /*
                     *<div class="question" id="q1">
                     * Sorry to ... like this, but there's a problem.
                     * <list class="answerList">
                     *	<li><a id="a1">barge in</a></li>
                     *	<li><a id="a2">barge on</a></li>
                     * </list>
                     */
                    /*
                     * Sorry to ... like this, but there's a problem.
                     * <list class="answerList">
                     *	<li><input type="radio" id="a1" name="q1" value="a1">barge in</input></li>
                     *	<li><input type="radio" id="a2" name="q1" value="a2">barge on</input></li>
                     * </list>
                     */
                    $(this).find("li a").each(function() {
                        $(this).replaceWith("<input type='radio' value='" + $(this).attr('id') + "' name='" + questionID + "'>" + $(this).html() + "</input>");
                    });

                    // Add a question number
                    $(this).prepend("<div class='question-number'>" + questionNumber++ + "</div>");

                    // An outer div for styling purposes
                    $("#testPlaceholder").append("<div class='question'>" + $(this).html() + "</div>");
                });

                // To add an event handler to all inputs to control the leveltest-complete-bar
                $("input[type=text]").change(function() {
                    // If the question id was in a parent of the input...
                    // var qid = $(this).closest(".question").attr("id");
                    var qid = $(this).attr("id");
                    if ($(this).val() != '') {
                        $("#lcb-" + qid).addClass("on");
                    } else {
                        $("#lcb-" + qid).removeClass("on");
                    }
                });
                $("input[type=radio]").change(function() {
                    var qid = $(this).attr("name");
                    $("#lcb-" + qid).addClass("on"); // (you can't completely deselect an m/c once selected)
                });

                // save the checksum code
                $("#codeHolder").text($(xml).find("config").text());
            }
        });
    };

    getQuestions();

    //iFrame colorbox
    $(".iframe-small").colorbox({
        iframe: true,
        width: "524px",
        height: "215px",
        scrolling: false,
        closeButton: false
    });


    $(".iframe-inline").colorbox({
        href: "#inline-level-reset",
        inline: true,
        width: "524px",
        height: "215px",
        scrolling: false,
        closeButton: false
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

});