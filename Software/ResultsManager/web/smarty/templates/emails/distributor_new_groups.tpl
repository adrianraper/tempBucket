{* Name: Groups that a distributor has created in the last month *}
{* Variables: $account *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Distributor created new group(s)</title>
	<!-- <from>support@clarityenglish.com</from> -->
	<!-- <bcc>adrian.raper@clarityenglish.com</bcc> -->
</head>
<body>
{$account->name} has created one or more users - maybe for a trial?<br/>
{assign var="delimitter" value=$account->reference|strpos:"|newGroups"}
{if $delimitter>=0}
	{assign var='newGroups' value=$account->reference|substr:$delimitter+11}
	The group(s) are<br/>
	{$newGroups}<br/>
{/if}
<br/>
Just for your info - no action required<br/>
ClaritySupport system<br/>
</body>
</html>