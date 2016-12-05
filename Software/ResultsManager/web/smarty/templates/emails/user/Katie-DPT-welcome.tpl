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
<p>Welcome {$user->name}</p>
<p>You have been scheduled to take the Dynamic Placement Test.</p>
<h2>{$testDetail->caption}</h2>
<p>The test opens at {$testDetail->openTime}.</p>

<h2>How does it work?</h2>
<h3>Phone or tablet</h3>
<ol>
	<li><p>If you are taking the test on a phone or tablet, you need to take the following steps.</p></li>
	    
    <li><p> 1) Download the test app from either:</p></li>    
    <li><p>Apple AppStore</p></li>
    <li><p>Google Play</p></li>
    
    
    <li>2) Sign in with email={$user->email} and password={$user->password}</li>
    <li>When the app is downloaded there are some questions for you to practice and make sure your device can run the test.</li>
    <li>Now, everything is ready for the test to start.</li>
    {if $testDetail->startType == 'code'}
        <li>Your administrator will give you a code to start the test. The test will not start without this code.</li>
    {elseif $testDetail->startType == 'timer'}
        <li>Your test will:</li>
        <li>start at {$testDetail->openTime}</li>
        <li>{if $testDetail->closeTime != null}end at {$testDetail->closeTime}.{/if}</li>
    {else}
        <li>The test will start by {$testDetail->startType}</li>
    {/if}
    
    <li>3) Wait until your device says oyou are finished before leaving the test. Then you can close and delete the app.</li>
    
    <li><p>Other information:</p></li>
    <li>It doesn't matter if you lose internet connection during the test. Your answers will be sent when you reconnect.</li>
    
</ol>
<h3>Laptop or other browser</h3>
<ol>
    <li>
        <p>If you are taking the test on a phone or tablet, you need to take the following steps.</p>
        
        <p>1) Go to:<a href="https://ctp.clarityenglish.com">ctp.clarityenglish.com</a></p>
	</li>
	<li>Sign in with email={$user->email} and password={$user->password}</li>
	<li>When the page is ready there are some questions for you to practice and make sure your device can run the test.</li>
    <li>Now, everything is ready for the test to start.</li>
	{if $testDetail->startType == 'code'}
		<li>Your administrator will give you a code to start the test. The test will not start without this code.</li>
	{elseif $testDetail->startType == 'timer'}
    <li>Your test will:</li>
    <li>start at {$testDetail->openTime}.</li>
    <li>{if $testDetail->closeTime != null}end at {$testDetail->closeTime}.{/if}
        </li>
	{else}
		<li>The test will start by {$testDetail->startType}</li>
	{/if}
    
    <li>3) Wait until your device says oyou are finished before leaving the test. Then you can close the browser.</li>
    
    
    <li><p>Other information:</p></li>
    <li>Clear cache before opening the link and starting the test.</li>
    <li>It doesn't matter if you lose internet connection during the test. Your answers will be sent when you reconnect.</li>
    
</ol>
<p>If you have any questions, make sure you contact the test administrator BEFORE the test.</p>
<p>Best regards<br/>
Clarity support team</p>
</body>
</html>