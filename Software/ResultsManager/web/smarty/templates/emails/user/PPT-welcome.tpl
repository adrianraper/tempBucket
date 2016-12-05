<!--
{* Name: Dynamic Placement Test invitation *}
{* Description: Invitation and instructions on how to take the DPT *}
{* Parameters: $user, $testDetail *}
-->
{assign var='testDetail' value=$templateData->test}
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Take the Dynamic Placement Test</title>
    <!-- <from>support@clarityenglish.com</from> -->
</head>
<body>
<p>Hello {$user->name}</p>
<p>You are scheduled to take the Dynamic Placement Test.</p>
<h2>{$testDetail->caption}</h2>
<p>The test opens at {$testDetail->openTime}.</p>

<h2>How does it work?</h2>
<h3>Phone or tablet</h3>
<ol>
	<li><p><a href="https://itunes.apple.com/us/app/dynamic-placement/id99999?mt=8"><image src="http://www.clarityenglish.com/images/app/badge_appstore.png" /></a></p>
        <p><a href="https://play.google.com/store/apps/details?id=dpt.clarityenglish.com&hl=en"><image src="http://www.clarityenglish.com/images/app/badge_googleplay.png" /></a></p>    </li>
        <p>Do it now!</p>
    <li>Sign in with email={$user->email} and password={$user->password}</li>
    <li>The test will download.</li>
    <li>Do some questions to make sure you can do the test on your device.</li>
    <li>Now, everything is ready for the test to start.</li>
    {if $testDetail->startType == 'code'}
        <li>The app will wait for you to type a code, which the test administrator will give to you at the start of the test.</li>
    {elseif $testDetail->startType == 'timer'}
        <li>You can start the test after {$testDetail->openTime}.
        {if $testDetail->closeTime != null}It closes at {$testDetail->closeTime}.{/if}
        </li>
    {else}
        <li>The test will start by {$testDetail->startType}</li>
    {/if}
    <li>Wait until the your device says you are finished before leaving the test. Then you can close and delete the app.</li>
</ol>
<h3>Laptop or other browser</h3>
<ol>
    <li>
        <p>If you want to take the test using your laptop or other browser, go to</p>
        <p><a href="https://ctp.clarityenglish.com">ctp.clarityenglish.com</a></p>
	</li>
    <li>Sign in with email={$user->email} and password={$user->password}</li>
    <li>The test will download.</li>
    <li>Do some questions to make sure you can do the test on your device.</li>
    <li>Now, everything is ready for the test to start.</li>
	{if $testDetail->startType == 'code'}
		<li>The app will wait for you to type a code, which the test administrator will give to you at the start of the test.</li>
	{elseif $testDetail->startType == 'timer'}
        <li>You can start the test after {$testDetail->openTime}.
            {if $testDetail->closeTime != null}It closes at {$testDetail->closeTime}.{/if}
        </li>
	{else}
		<li>The test will start by {$testDetail->startType}</li>
	{/if}
    <li>You don't need to keep the browser open, but don't clear the cache otherwise you will have to download again.</li>
    <li>When you are ready to start the test, open the same <a href="https://ctp.clarityenglish.com">webpage</a> again </li>
	<li>When you have finished the last questions, the app will try to send the answers for marking.</li>
	<li>The test is not complete until your device shows an acknowledgement. Then you can close the browser.</li>
</ol>
<h3>Other information</h3>
<li>Remember to bring your own headphones.</li>
<li>When you are doing the test, it doesn't matter if your internet connection disappears.</li>
<li>If you don't have a device you can bring, make sure you contact the administrator BEFORE the test.</li>

<p>Good luck<br/>
Clarity and telc support team</p>
</body>
</html>