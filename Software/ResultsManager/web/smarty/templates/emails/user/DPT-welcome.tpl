<!--
{* Name: Dynamic Placement Test invitation *}
{* Description: Invitation and instructions on how to take the DPT *}
{* $testDetail should include an administrator email or name, along with any customised instructions *}
{* Parameters: $user, $testDetail *}
-->
{assign var='testDetail' value=$templateData->test}
{assign var='emailDetails' value=$templateData->emailDetails}
<p>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{if $emailDetails->subject}{unescape_string data=$emailDetails->subject}{else}Dynamic Placement Test{/if}</title>
    <!-- <from>%22ClarityEnglish%22 %3Cadmin@clarityenglish.com%3E</from> -->
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
You can take the test on a desktop/laptop or a tablet/smartphone.
<ol style="margin-top: 0; margin-bottom: 0">
    <li>For desktop/laptop go to <a href="https://dpt.clarityenglish.com"><strong>dpt.clarityenglish.com</strong></a> in your browser.</li>
    <li>For tablet/phone download the app from the <a href="https://itunes.apple.com/hk/app/dynamic-placement-test/id1179218583?mt=8&amp;ign-mpt=uo%3D4" target="_blank" style=" font-size:0.9em;">Apple App Store</a> or <a href="https://play.google.com/store/apps/details?id=com.clarityenglish.ctp_wrapper&hl=en" target="_blank" style=" font-size:0.9em;">Google Play</a>. Search for <strong>Dynamic Placement Test</strong>.</li>
</ol>
Sign in and try section 1 of the test to make sure it runs properly.<br/>
{if $testDetail->startType == 'code'}
    Your test administrator will give you the access code when the test is ready to start.
{/if}
</p>

<p><strong>Important</strong><br/>
    You will need <strong>headphones</strong> or <strong>earphones</strong> for the test.</p>

{if $emailDetails && $emailDetails->notes}
    <p class="replaceInPreview"><strong>Notes</strong><br/>
        {unescape_string data=$emailDetails->notes}<br/></p>
{/if}

<p>Best wishes<br/>
The ClarityEnglish support team</p>
</body>
</html>