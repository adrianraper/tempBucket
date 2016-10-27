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
<p>You have been scheduled to take the Dynamic Placement Test.</p>
<h2>{$testDetail->caption}</h2>
<p>The test opens at {$testDetail->openTime}.</p>

<h2>How does it work?</h2>
<h3>Phone or tablet</h3>
<ol>
	<li><p>If you want to take the test using your phone or tablet, download the Dynamic Placement Test app now from:</p>
	    <p>Apple AppStore</p>
	    <p>Google Play</p>
    </li>
    <li>Sign in with email={$user->email} and password={$user->password}</li>
    <li>The app will download what it needs to get ready for the test.</li>
    <li>Then there are some questions to make sure your device can run the test.</li>
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
    <li>When you are doing the test, it doesn't matter if your internet connection disappears.</li>
    <li>When you have finished the last questions, the app will try to send the answers for marking.</li>
    <li>The test is not complete until your device shows an acknowledgement. Then you can close and delete the app.</li>
</ol>
<h3>Laptop or other browser</h3>
<ol>
    <li>
        <p>If you want to take the test using your laptop or other browser, go to</p>
        <p><a href="https://ctp.clarityenglish.com">ctp.clarityenglish.com</a></p>
	</li>
	<li>Sign in with email={$user->email} and password={$user->password}</li>
	<li>The page will download what it needs to get ready for the test.</li>
	<li>Then there are some questions to make sure your device can run the test.</li>
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
	<li>When you are doing the test, it doesn't matter if your internet connection disappears.</li>
	<li>When you have finished the last questions, the app will try to send the answers for marking.</li>
	<li>The test is not complete until your device shows an acknowledgement. Then you can close the browser.</li>
</ol>
<p>If you have any questions, make sure you contact the test administrator BEFORE the test.</p>
<p>Best regards<br/>
Clarity support team</p>
</body>
</html>