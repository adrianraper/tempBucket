// This script uses action.php to send a forgot password email
$('document').ready(function() {

    $("#email-form").submit(function() {
        var email = $("input#registeredEmail").val();
        var formData = "method=forgotPassword&email=" + email;

        // call the database processing script
        $.ajax({ type: 'POST',
            url: "/script/action.php",
            data: formData,
            dataType: "json",
            beforeSend: function() {
                $("#error").fadeOut();
                $("#btn-submit").html('checking...').removeClass('input-bg-p').addClass('disabled');
            },
            success: onAjaxSuccess,
            error: onAjaxError
        });

        return false;
    });

    // If there has been an error and the email is changed, remove the error
    // Using .change is ok, but it only fires when the focus leaves the changed input
    //$("#registeredEmail").change(function() {
    //    $("#error").fadeOut();
    //});
    $('#registeredEmail').on('input', function() {
        $("#error").fadeOut();
    });

	onAjaxSuccess = function(data, textStatus) {

		// We might have an error
		if (data.error != undefined) {
			switch (parseInt(data.error)) {
                case 0:
                    // all well
                    $("#error").fadeIn(100, function(){
                        $("#error").html('<div class="alert alert-success">'+data.message+'</div>');
                    });
                    break;
                case NaN:
                    $("#error").fadeIn(100, function(){
                        $("#error").html('<div class="alert alert-danger">'+data.message+'</div>');
                    });
                    break;
				case 210:
				case 211:
				default:
                    $("#error").fadeIn(100, function(){
                        $("#error").html('<div class="alert alert-warning">'+data.message+'</div>');
                    });
					break;
			}

		// Or a redirect
		} else if (data.redirect) {
			window.location = data.redirect;
			
		// Anything else is unexpected
		} else {
            $("#error").fadeIn(100, function(){
                $("#error").html('<div class="alert alert-danger">'+data.message+'</div>');
            });
		}
        $("#btn-submit").html('Email me').addClass('input-bg-p').removeClass('disabled');
		return false;
	};
	onAjaxError = function(XMLHttpRequest, textStatus, errorThrown) {
        $("#error").fadeIn(100, function(){
            $("#error").html('<div class="alert alert-danger">This page can&apos;t contact the database now, please try again later.</div>');
        });
        $("#btn-submit").html('Email me').addClass('input-bg-p').removeClass('disabled');
		return false;
	};

});
  