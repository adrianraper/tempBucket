<!-- Dynamic Placement Test schedule summary -->
{assign var='testDetail' value=$templateData->test}
{assign var='emailDetails' value=$templateData->emailDetails}
<p>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>DPT schedule summary</title>
        <!-- <from>%22ClarityEnglish%22 %3Cadmin@clarityenglish.com%3E</from> -->
    </head>
    <body style="font-family: Sans-Serif; font-size: 15px">
<p>
    <!-- <div style="text-align: center"><img src="http://www.clarityenglish.com/images/program/DPTpage/dpt_icon_email.png" width="116" height="76"></div> -->
<p>Dear {$user->name}</p>
<p>You have just scheduled a test and sent a notification email for {$templateData->numberScheduled} test-takers .</p>
<p><strong>Test name:</strong><br/>
    {$testDetail->caption}</p>
<p><strong>Test time:</strong><br/>
    From: {format_ansi_date ansiDate=$testDetail->openTime format="%Y-%m-%d %H:%M"} ({$testDetail->timezone})<br/>
    To: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{format_ansi_date ansiDate=$testDetail->closeTime format="%Y-%m-%d %H:%M"} ({$testDetail->timezone})<br/>

<p style="margin-bottom: 0"><strong>Who are the test takers?</strong><br/>
    {$templateData->emailsScheduled}
</p>

{if $emailDetails && $emailDetails->notes}
    <p class="replaceInPreview"><strong>Your notes</strong><br/>
        {unescape_string data=$emailDetails->notes}<br/></p>
{/if}

<p>Best wishes<br/>
    The Dynamic Placement Test support team</p>
</body>
</html>