{* Name: Practical Placement Test result *}
{* Description: Gives the test taker their result *}
{* Parameters: $user, $templateData, $testResult *}
{assign var='testDetail' value=$templateData->testDetail}
<html>
<body>
<p>Hello {$user->name}</p>
<p>You took Clarity's Practical Placement Test</p>
<p>{$testDetail->caption}</p>
<p>CEF levels are explained somewhere.</p>
</body>
</html>