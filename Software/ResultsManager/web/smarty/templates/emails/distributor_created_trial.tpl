{* Name: Distributor created a trial notification *}
{* Parameters: $rootID, $group, $parent *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Distributor created a new group</title>
	<!-- <from>support@clarityenglish.com</from> -->
	<!-- <bcc>adrian.raper@clarityenglish.com</bcc> -->
</head>
<body>
{* 
{if $rootID == 20895}
	EPIC
{else}
{/if}
*}
{$parent->name}, root={$rootID}, has created a new group - probably a trial.<br/>
group name: {$group->name}<br/>
parent group name: {$parent->name}<br/>
<br/>
Just for your info - no action required<br/>
ClaritySupport system<br/>
</body>
</html>