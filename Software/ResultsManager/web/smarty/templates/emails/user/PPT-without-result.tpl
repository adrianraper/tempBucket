{* Name: Practical Placement Test result *}
{* Description: Tells the test taker how to get their result *}
{* Parameters: $user, $testDetail *}
{assign var='testDetail' value=$templateData->testDetail}
<html>
<body>
<p>Hello {$user->name}</p>
<p>Your teacher would like to see you to tell you the result of Clarity's Practical Placement Test</p>
</body>
</html>