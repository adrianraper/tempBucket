<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Road to IELTS - password reset</title>
    <style type="text/css">
        @import url(http://fonts.googleapis.com/css?family=Oxygen:400,700);
    </style>

</head>
<body text="#000000" style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-weight:400; font-size: 13px; line-height:18px; margin:0; padding:0;color:#000000;">
{assign var=edge value=$link|strpos:"?token"}
<div style="width:600px;">
    <div style="width:500px; margin:auto; padding:10px 50px 20px 50px;">

        <p style="margin: 0 0 10px 0;">Hello,</p>
        <p style="margin: 0 0 10px 0;">We have received a request to reset your password. Follow this link to set a new password:</p>

        <div style="background-color:#E8E3F0; width:450px; padding:10px 20px 10px 20px; margin:0 0 10px 0;">
            <a href="{$link}" target="_blank">{$link|truncate:$edge+15:"...":true}</a>
        </div>

        <p style="margin: 0 0 10px 0;">This link will expire in 24 hours from when this email was generated. If you need a new link, go back to <a href="https://www.roadtoielts.com/BritishCouncil/login" target="_blank">www.roadtoielts.com</a> and click 'Forgot password' again.</p>

        <p style="margin: 0 0 10px 0;">Regards,<br/>
            Henry Wong</p>
        {include file='file:includes/LMSupport_Email_Signature.tpl'}
    </div>
</div>
</body>
</html>