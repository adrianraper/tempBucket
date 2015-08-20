<?php
    session_start();
    include_once "variables.php";
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr">
<head>
<title>Clarity's Results Manager bulk import</title>
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
<link rel="stylesheet" href="css/common.css" type="text/css" />

<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/js/date.js"></script>
<!-- <script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/js/jquery-1.3.2.min.js"></script> -->
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/js/jquery-ui-1.7.custom.min.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/ui/ui.core.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/js/jquery-ui-datePicker-2.1.2.js"></script>
<script type="text/javascript" src="<?php echo $commonDomain ?>Software/Common/jQuery/js/blockUI-2.js"></script>
<script type="text/javascript" src="importControl.js"></script>
</head>

<body>

<script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script src="Software/Common/jQuery/js/vendor/jquery.ui.widget.js"></script>
<script src="Software/Common/jQuery/js/jquery.iframe-transport.js"></script>
<script src="Software/Common/jQuery/fileUpload/jquery.fileupload.js"></script>
<script>
    $(function () {
        'use strict';
        // Change this to the location of your server-side upload handler:
        var url = '<?php echo $commonDomain ?>Software/Common/jQuery/fileUpload/server/php';
        $('#fileupload').fileupload({
            url: url,
            dataType: 'json',
            done: function (e, data) {
                $.each(data.result.files, function (index, file) {
                    $('<p/>').text(file.name).appendTo(document.body);
                });
            }
            progressall: function (e, data) {
                var progress = parseInt(data.loaded / data.total * 100, 10);
                $('#progress .progress-bar').css(
                    'width',
                    progress + '%'
                );
            }
        }).prop('disabled', !$.support.fileInput)
            .parent().addClass($.support.fileInput ? undefined : 'disabled');
        });
    });

</script>
<h1>This is the Results Manager bulk importer.</h1>
<form id="fileupload" action="//jquery-file-upload.appspot.com/" method="POST" enctype="multipart/form-data">
<form id="importForm" name="importForm" onSubmit="return false;">
    <input type="radio" name="duplicateOption" value="move">move<br>
    <input type="radio" name="duplicateOption" value="copy">copy<br>
    <input type="radio" name="duplicateOption" value="block">copy<br>
    <input id="fileupload" type="file" name="files[]" data-url="server/php/" multiple>
    <div class="button_area">
        <input name="LoginSubmit" type="button" id="LoginSubmit" value="Import" class="button_short"/>
        <div id="responseMessage" class="note"></div>
    </div>
</form>

<!-- These blocks are used for error messages in jQuery blockUI -->
<div id="unexpected" style="display:none; cursor:default">
	<h1>Error</h1>
	<p>Something unexpected happened and you can't go on. Sorry.</p>
	<p>Please contact support@clarityenglish.com.</p>
	<input type="button" id="mOK" value="OK" />
</div>
<div id="notAdministrator" style="display:none; cursor:default">
	<h1>Error</h1>
	<p>Sorry, you are not an administrator of your account.</p>
	<input type="button" id="mOK" value="OK" />
</div>
<div id="invalidIDorPassword" style="display:none; cursor:default">
    <h1>Error</h1>
    <p>Sorry, the name or password are wrong.</p>
    <input type="button" id="mOK" value="OK" />
</div>

</body>
</html>
