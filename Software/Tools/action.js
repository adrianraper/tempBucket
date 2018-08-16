
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
    $("div#status-box").hide();

    // handle dynamic creation of a JWT based on text in the user identifier field
    //$('#name').on( "input", function(){
    //    createJWT($(this).val());
    //});
});
createJWT = function(productCode) {
    var userIdentifier = $('#name').val();
    var prefix = $('#prefix').val();
    var key = $('#key').val();
    var data = { appVersion: "2", command: "createJWT", payload: { productCode: productCode, prefix: prefix, login: userIdentifier}, key: key };
    $.ajax({
        method: "POST",
        url: "http://dock.projectbench/Software/Tools/ToolsGateway.php",
        dataType: "json",
        data: JSON.stringify(data)
    })
        .done(function( msg ) {
            $('#JWT').text = msg.details.token;
            var url = "http://dock.projectbench/Software/Tools/autoSignIn.php?apiToken=" + msg.details.token;
            console.log(url);
            window.open(url, '_blank');
        });
}
prepareData = function(productCode) {
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

