{* Name: CLS accounts notification *}
{* Description: Email sent to clarity accounts when CLSgateway is invoked. *}
{* Parameters: $api *}
{* Updated for CLS v2 with packages *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>CLS ref:{$api->subscription->orderRef} - {$api->subscription->name}</title>
	<!-- <from>support@clarityenglish.com</from> -->
	<!-- <cc>support@ieltspractice.com</cc> -->
	<!-- <bcc>adrian.raper@clarityenglish.com,alfred.ng@clarityenglish.com</bcc> -->
</head>
<body>
Somebody went through CLSgateway with the following information<br/>
our ref: {$api->subscription->id}<br/>
email: {$api->subscription->email}<br/>
name: {$api->subscription->name}<br/>
offerID: {$api->subscription->offerID}<br/>
start date: {$api->subscription->startDate}<br/>
reseller: {$api->subscription->resellerID}<br/>
reseller ref: {$api->subscription->orderRef}<br/>
status: {$api->subscription->status}<br/>
<br/>
</body>
</html>