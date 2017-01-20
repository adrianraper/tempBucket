<!--
{* Name: Dynamic Placement Test invitation *}
{* Description: Invitation and instructions on how to take the DPT *}
{* $testDetail should include an administrator email or name, along with any customised instructions *}
{* Parameters: $user, $testDetail *}
-->
{assign var='testDetail' value=$templateData->test}
{assign var='administrator' value=$templateData->administrator}
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Take the Dynamic Placement Test</title>
    <!-- <from>support@clarityenglish.com</from> -->
</head>
<body>
<p>Dear {$user->name}</p>
<p>You are scheduled to take an English test.</p>
<p>Test name: {$testDetail->caption}</p>
<p>Test time: From {format_ansi_date ansiDate=$testDetail->openTime format="%Y-%m-%d %H:%M"} to {format_ansi_date ansiDate=$testDetail->closeTime format="%Y-%m-%d %H:%M"}</p>
<p>Sign in details: <strong>{$user->email}</strong> / <strong>{$user->password}</strong></p>
{if $testDetail->startType == 'code'}
<p>Test code: You will be told the code before the test starts.</p>
{/if}

<p>Instructions for phone or tablet</p>
<ol>
    <li>Download the app from the <a href="https://itunes.apple.com/hk/app/dynamic-placement-test/id1179218583?mt=8&amp;ign-mpt=uo%3D4" target="_blank" style=" font-size:0.9em;">Apple Store</a> or <a href="https://play.google.com/store/apps/details?id=com.clarityenglish.ctp_wrapper&hl=en" target="_blank" style=" font-size:0.9em;">Google Play</a><br/>
        <a href="https://itunes.apple.com/hk/app/dynamic-placement-test/id1179218583?mt=8&amp;ign-mpt=uo%3D4" target="_blank" style=" font-size:0.9em;"><img src="http://www.clarityenglish.com/images/email/rti2/ielts-lm-apple-store.jpg" alt="App store" width="90" height="27" border="0"/></a>
        <a href="https://play.google.com/store/apps/details?id=com.clarityenglish.ctp_wrapper&hl=en" target="_blank" style=" font-size:0.9em;"><img src="http://www.clarityenglish.com/images/email/rti2/ielts-lm-google-play.jpg" alt="Google play" width="79" height="27" border="0"/></a>
    <li>Try section 1 of the test to make sure it runs on your device.</li>
</ol>
<p>Instructions for laptop or other browser</p>
<ol>
    <li>Go to <a href="https://dpt.clarityenglish.com">dpt.clarityenglish.com</a> and sign in.
    <li>Try section 1 of the test to make sure it runs in your browser.</li>
</ol>

{if $testDetail->emailInsertion}
    <p>{$testDetail->emailInsertion}</p>
{/if}

<p>Important: You will need <strong>headphones</strong> or <strong>earphones</strong> when you do the test.</p>

<p>Questions? Ask your administrator {$administrator->name} {if $administrator->email}({$administrator->email}){/if}.</p>

<p>Best wishes<br/>
The ClarityEgnslih support team</p>
</body>
</html>