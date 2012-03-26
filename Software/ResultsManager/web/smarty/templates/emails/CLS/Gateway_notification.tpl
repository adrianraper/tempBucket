{* Name: CLS Gateway notification *}
{* Description: Email sent when you have subscribed to CLS online. *}
{* Parameters: $data *}
{* Updated for CLS v2 with packages *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>CLS gateway ref:{$data->orderRef}</title>
	<!-- <from>support@ClarityLifeSkills.com</from> -->
	<!-- <cc>sales@clarityenglish.com</cc> -->
	<!-- <bcc>adrian.raper@clarityenglish.com</bcc> -->
</head>
<body>
The CLS Gateway has been used to purchase the following:<br/>
order ref: {$data->orderRef}<br/>
offer ID: {$data->offerID}<br/>
name: {$data->name}<br/>
address: {$data->address1}<br/>
         {$data->address2}<br/>
city: {$data->city}<br/>
suburb: {$data->address3}<br/>
state: {$data->state}<br/>
ZIP: {$data->ZIP}<br/>
country: {$data->country}<br/>
phone: {$data->phone}<br/>
mobile: {$data->mobile}<br/>
<br/>
Many thanks<br/>
The ClarityLifeSkills team<br/>
</body>
</html>