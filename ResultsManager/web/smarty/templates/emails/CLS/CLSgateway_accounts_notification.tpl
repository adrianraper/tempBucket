{* Name: CLS accounts notification *}
{* Description: Email sent to clarity accounts when CLSgateway is invoked. *}
{* Parameters: $data *}
{* Updated for CLS v2 with packages *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Delivery order for iLearnIELTS ref:{$data->orderRef}</title>
	<!-- <from>support@clarityenglish.com</from> -->
	<!-- <bcc>adrian.raper@clarityenglish.com</bcc> -->
</head>
<body>
Somebody went through CLSgateway with the following information<br/>
reseller: {$data->resellerID}<br/>
<br/>
</body>
</html>