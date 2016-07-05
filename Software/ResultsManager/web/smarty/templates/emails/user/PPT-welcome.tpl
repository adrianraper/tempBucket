{* Name: Practical Placement Test invitation *}
{* Description: Invitation and instructions on how to take the PPT *}
{* Parameters: $user, $testDetail *}
{assign var='testDetail' value=$templateData->testDetail}
<html>
<body>
<p>Hello {$user->name}</p>
<p>You need to take the Clarity's Practical Placement Test</p>
<p>The test, {$testDetail->caption}, starts at {$testDetail->startTime}</p>
<p>If you want to take the test using your phone or tablet, download the Practical Placement Test from:</p>
<p>Apple AppStore</p>
<p>Google Play</p>
<p>If you want to take the test using your laptop or other browser, go to</p>
<p>www.clarityenglish.com/PPT/Start</p>

<h2>How does it work?</h2>
<h3>Phone or tablet</h3>
<ol>
<li>Download the app and start it</li>
<li>Sign in with email={$user->email} and password={$user->password}</li>
<li>The app will now download what it needs to get ready for the test</li>
<li>After this is done, you need to test that your device can run the test</li>
<li>Finally, everything is ready.</li>
{if $testDetail->startType == 'code'}
	<li>The app will wait for you to type a code, which will be given to you at the start of the test.</li>
{elseif $testDetail->startType == 'date'}
	<li>The app will wait until {$testDetail->startTime} and then automatically start the test.</li>
{else}
	<li>The test will start by {$testDetail->startType}</li>
{/if}
<li>When you are doing the test, it doesn't matter if your internet connection disappears.</li>
<li>When you have finished the last questions, the app will try to send the answers for marking.</li>
<li>The test is not complete until your device shows an acknowledgement. Now you can close the app.</li>
</ol>
</body>
</html>