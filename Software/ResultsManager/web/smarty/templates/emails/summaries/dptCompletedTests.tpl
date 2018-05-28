<!-- Dynamic Placement Test completed recently summary -->
<p>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>DPT completed tests</title>
        <!-- <from>%22ClarityEnglish%22 %3Csupport@clarityenglish.com%3E</from> -->
    </head>
    <body style="font-family: Sans-Serif; font-size: 15px">
<p>
    <!-- <div style="text-align: center"><img src="http://www.clarityenglish.com/images/program/DPTpage/dpt_icon_email.png" width="116" height="76"></div> -->
<p>Dear {$user->name}</p>
<p>The following test-takers have completed their Dynamic Placement Test since {$fromDate} (UTC)</p>
<ul>
    {foreach from=$completedTests key=k item=test}
        {assign var=result value=$test.result|json_decode:1}
        <li>{$test.name} got CEFR {$result.level} (RN: {$result.numeric})</li>
    {/foreach}
</ul>

<p>Best wishes<br/>
    The Dynamic Placement Test support team</p>
<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 0;">If you have queries, requests or suggestions, we are here to help:</p>
<p style="font-family:  Arial, Helvetica, sans-serif; font-size: 1em; line-height:18px;margin:0 0 10px 20px; padding:0; color:#000000;">
    Email: support@clarityenglish.com<br/>
    Hong Kong : +852 2791 1787<br/>
    United Kingdom : +44 (0)845 130 5627</p>
</body>
</html>