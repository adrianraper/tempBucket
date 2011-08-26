{* Email footer: Check for domain *}
{* if $domain|lower|stristr:'claritylifeskills.com' *}
{* if $smarty.server.SERVER_NAME|lower|stristr:'claritylifeskills.com' *}
{if $licenceType==5}
	{assign var='supportEmail' value='support@claritylifeskills.com'}
{else}
	{assign var='supportEmail' value='support@clarityenglish.com'}
{/if}
<p style="margin: 0 0 10px 0; padding:0;">If you have any questions, please do not hesitate to email our Support Team at <a href="mailto:{$supportEmail}">{$supportEmail}</a>.</p>
<p style="margin: 0 0 10px 0; padding:0;">Best wishes<br />
<span style="margin: 0 0 10px 0; padding:0;  font-weight:bold; font-style:italic" >It's Your Job Support Team</span>
<p style="margin: 0 0 0 0; padding:0; font-size:10px;">
	Choose Clarity for effective, enjoyable, easy-to-use educational software.<br />
	Clarity Language Consultants Ltd (UK and Hong Kong since 1992)<br />
	<a href="http://www.ClarityEnglish.com" target="_blank">http://www.ClarityEnglish.com</a><br />
	PO Box 163, Sai Kung, Hong Kong<br />
	Tel: (+852) 2791 1787, Fax: (+852) 2791 6484 
</p>