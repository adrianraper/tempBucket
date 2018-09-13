// Definitions
apiGatewayUrl = "http://dock.projectbench/Software/Tools/apiGateway.php"
programsUrl = "http://dock.projectbench/Software/Tools/clarityPrograms.php"

// What to do and where to focus?
// If you type in any of these fields, set Enter to mean
// email, password => signin.click
// serial, activateName, activateEmail, activatePassword, confirmPassword => activate.click

// If you get an error from these functions, put the status in
// signin => signinStatus
// checkSerial, checkEmail => signinStatus

// Only enable Activate button once token, email, password and confirm password all typed

$(function() {

    // You must be sent a token. Read it to check it is valid and get the email.
    var token = getUrlParams('token');
    getTokenContents(token);

    // Same passwords
    $('#confirmPassword').on( "focusout", function(){
        matchPasswords($('#newPassword').val(), $('#confirmPassword').val());
    });

    // Activate the token
    $('#reset').on( "click", function(){
        changePassword($('#email').text(), $('#newPassword').val(), token);
    });

});

var showAndHideEvents = function(event, msg) {
    switch (event) {
        case "reset":
            $("#resetStatus").text("");
            $("#reset").prop('disabled', false);
            break;
        case "passwordsDifferent":
            $("#resetStatus").text("The passwords are not the same.");
            $("#reset").prop('disabled', true);
            break;
        case "changed":
            $("#resetStatus").text("Your password has been changed. Go and sign in.");
            setTimeout(signout, (1 * 1000));
            break;
        case "invalidToken":
            $("#resetStatus").text("Your link has been corrupted. Please request a new email.");
            $("#reset").prop('disabled', true);
            break;
        case "showEmail":
            $("#email").text(msg);
            break;
        case "error":
            $("#resetStatus").text(msg);
            break;
        default:
    }
}
var signout = function() {
    window.location.replace('clarityPortal.php');
}
var changePassword = function(email, password, token) {
    showAndHideEvents('reset');
    var data = {command:"changePassword", email:email, password:password, token:token};
    console.log("call: " + JSON.stringify(data));
    $.ajax({
        method: "POST",
        url: apiGatewayUrl,
        dataType: "json",
        data: JSON.stringify(data)
    }).done(function(data, status, jqXHR) {
        var success = data.success;
        if (success) {
            // Was it successful?
            showAndHideEvents("changed");
            console.log(data.details);
        } else {
            showAndHideEvents("invalidToken", data.error.message);
            console.log(data.error);
        }
    }).fail(function(jqXHR,status,err) {
        showAndHideEvents("error", err.message);
        console.log(err);
    });
}
var matchPasswords = function(one, two){
    if (one != two) {
        showAndHideEvents("passwordsDifferent");
        return false;
    }
}
var getTokenContents = function(token) {
    var data = {command:"getTokenPayload", token:token};
    console.log("call: " + JSON.stringify(data));
    $.ajax({
        method: "POST",
        url: "http://dock.projectbench/Software/Tools/apiGateway.php",
        dataType: "json",
        data: JSON.stringify(data)
    }).done(function(data, status, jqXHR) {
        var success = data.success;
        if (success) {
            // Was it successful?
            if (data.details.payload.email != null) {
                var email = data.details.payload.email;
                showAndHideEvents("showEmail", email);
            } else {
                showAndHideEvents("invalidToken");
            }
            console.log(data.details);
        } else {
            showAndHideEvents("invalidToken");
            console.log(data.error);
        }

    }).fail(function(jqXHR,status,err) {
        $("#resetStatus").text(err);
        console.log(err);
    });
}

/**
 * JavaScript Get URL Parameter
 *
 * @param String prop The specific URL parameter you want to retreive the value for
 * @return String|Object If prop is provided a string value is returned, otherwise an object of all properties is returned
 */
function getUrlParams( prop ) {
    var params = {};
    var search = decodeURIComponent( window.location.href.slice( window.location.href.indexOf( '?' ) + 1 ) );
    var definitions = search.split( '&' );

    definitions.forEach( function( val, key ) {
        var parts = val.split( '=', 2 );
        params[ parts[ 0 ] ] = parts[ 1 ];
    } );

    return ( prop && prop in params ) ? params[ prop ] : params;
}
