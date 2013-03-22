{* Email footer for CCB related emails *}
<table style="font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 12px; color:#000000;" width="470" border="0" cellspacing="0" cellpadding="0">
  <tr align="left" valign="top">
    <td width="470" height="10" >
		Best regards<br/>
{if $course->author}
	{$course->author}<br/>
{/if}    
	</td>
  </tr>
  <tr>
    <td colspan="2" height="10"><hr align="left" width="380" size="1" /></td>
  </tr>
  <tr>
    <td height="7"></td>
  </tr>
  <tr>
    <td style="font-size: 11px;"><font color="#666666">
{if $course->email|stristr:'@'}
      E: {$course->email}<br />
{else}
      E: support@clarityenglish.com<br />
{/if}    
      </font></td>
  </tr>

</table>
