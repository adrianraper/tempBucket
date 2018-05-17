<!-- Dynamic Placement Test invitation -->
{assign var='testDetail' value=$templateData->test}
{assign var='emailDetails' value=$templateData->emailDetails}
<p>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{if $emailDetails->subject}{unescape_string data=$emailDetails->subject}{else}Dynamic Placement Test{/if}</title>
    <!-- <from>%22ClarityEnglish%22 %3Cno-reply@clarityenglish.com%3E</from> -->
</head>
<body style="font-family: Sans-Serif; font-size: 15px">
<p>
<!-- <div style="text-align: center"><img src="http://www.clarityenglish.com/images/program/DPTpage/dpt_icon_email.png" width="116" height="76"></div> -->
<p>Dear {$user->name}</p>
<p>You are scheduled to take an English test.</p>
<p><strong>Test name:</strong><br/>
{$testDetail->caption}</p>
<p><strong>Test time:</strong><br/>
    From: {format_ansi_date ansiDate=$testDetail->openTime format="%Y-%m-%d %H:%M"} ({$testDetail->timezone})<br/>
    To: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{format_ansi_date ansiDate=$testDetail->closeTime format="%Y-%m-%d %H:%M"} ({$testDetail->timezone})<br/>
The test will take 30 minutes.</p>
<p><strong>Sign in details:</strong><br/>
    Email: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>{$user->email}</strong><br/>
    Password: <strong>{$user->password}</strong></p>

<p style="margin-bottom: 0"><strong>How to take the test</strong><br/>
You can take the test on a desktop/laptop or a tablet/smartphone.<br/>
Go to <a href="https://dpt.clarityenglish.com"><strong>dpt.clarityenglish.com</strong></a> in your browser.<br/>
Sign in and try section 1 of the test to make sure it runs properly on your device.
{if $testDetail->startType == 'code'}
    <br/>Your test administrator will give you the access code when the test is ready to start.
{/if}
</p>

<p><strong>Important</strong><br/>
    You will need <strong>headphones</strong> or <strong>earphones</strong> for the test.<br/>
    The test downloads to your browser after sign-in. When you get to section 1 it is ready. You can close the browser and open it later.
</p>

{if $emailDetails && $emailDetails->notes}
    <p class="replaceInPreview"><strong>Notes</strong><br/>
        {unescape_string data=$emailDetails->notes}<br/></p>
{/if}

<p>Best wishes<br/>
The ClarityEnglish support team</p>
</body>
</html>