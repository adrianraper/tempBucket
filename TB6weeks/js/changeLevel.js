/**
 * Remove all traces of an individual from the TB6 weeks system
 */
	// Server action
	changeLevel = function() {
	
		$("#validationMessage").text("Please wait while we up your Tense Buster.");
		
		var productCode = 59;
		$.ajax({
			type: "POST",
			url: "/Software/ResultsManager/web/amfphp/services/TB6weeksService.php",
			data: {operation: 'changeLevel', productCode: productCode, user: $("#changeLevelForm").serialize(), level: $("#level").val()},
			dataType: "json",
			error: function(jqXHR, textStatus, errorThrown) {
				console.log('Error: ' + errorThrown);
			},
			success: function (data) {
				console.log('Success: ' + data);
				$("#validationMessage").text(data);
			}
		});
	};

	jQuery(document).ready(function ($) {
		$("#userEmail").val(getURLParameter('email'));
		$("#validationMessage").val('ready?');
	
		$("#changeLevelForm").validate({
			rules: {
			  userEmail: {
			    required: true,
			    email: true
			  },
			  password: {
				  required: true
			  },
			  level: {
				  required: true
			  }
			},
			messages: {
			  userEmail: {
			    required: "Please type your email address."
			  },
			  level: {
				  required: "You must choose a new level"
			  }
			},
			submitHandler: function(form) {
				changeLevel();
			}
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
