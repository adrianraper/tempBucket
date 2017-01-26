<!--
{* Name: Dynamic Placement Test invitation *}
{* Description: Invitation and instructions on how to take the DPT *}
{* $testDetail should include an administrator email or name, along with any customised instructions *}
{* Parameters: $user, $testDetail *}
-->
{assign var='testDetail' value=$templateData->test}
{assign var='administrator' value=$templateData->administrator}
<p>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Take the Dynamic Placement Test</title>
    <!-- <from>support@clarityenglish.com</from> -->
</head>
<p>
<div style="text-align: center"><img src="http://www.clarityenglish.com/images/program/DPTpage/dpt_icon_email.png" width="116" height="76"></div>
<p style="font-family: Sans-Serif;">Dear {$user->name}</p>
<p style="font-family: Sans-Serif;">You are scheduled to take an English test.</p>
<p style="font-family: Sans-Serif; "><strong>Test name:</strong><br/>
{$testDetail->caption}</p>
<p style="font-family: Sans-Serif; "><strong>Test5 time:</strong><br/>
    From {format_ansi_date ansiDate=$testDetail->openTime format="%Y-%m-%d %H:%M"}<br/>
    To {format_ansi_date ansiDate=$testDetail->closeTime format="%Y-%m-%d %H:%M"}</p>
<p style="font-family: Sans-Serif; "><strong>Sign in details:</strong><br/>
    Email: <strong>{$user->email}</strong><br/>
    Password: <strong>{$user->password}</strong></p>

<p style="font-family: Sans-Serif; margin-bottom: 0"><strong>How to take the test</strong><br/>
<ol style="margin-top: 0">
    <li>Go to <a href="https://dpt.clarityenglish.com">dpt.clarityenglish.com</a> in your browser or download the app from the <a href="https://itunes.apple.com/hk/app/dynamic-placement-test/id1179218583?mt=8&amp;ign-mpt=uo%3D4" target="_blank" style=" font-size:0.9em;">Apple App Store</a> or <a href="https://play.google.com/store/apps/details?id=com.clarityenglish.ctp_wrapper&hl=en" target="_blank" style=" font-size:0.9em;">Google Play</a><br/>
    <li>Sign in and try section 1 of the test to make sure it runs properly.</li>
{if $testDetail->startType == 'code'}
    <li>Your test administrator will give you the access code when the test is ready to start.</li>
{/if}
</ol>
</p>

<p style="font-family: Sans-Serif; "><strong>Important</strong><br/>
    You will need <strong>headphones</strong> or <strong>earphones</strong> for the test.</p>

{if $testDetail->emailInsertion}
    <p style="font-family: Sans-Serif; "><strong>Notes</strong><br/>
    {$testDetail->emailInsertion}<br/>
{/if}

<p>Questions? Ask your administrator, {$administrator->name} {if $administrator->email} at {$administrator->email}{/if}.</p>

<p>Best wishes<br/>
The ClarityEnglish support team</p>
</body>
</html>