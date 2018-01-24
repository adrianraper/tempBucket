{foreach name=licenceStuff from=$account->licenceAttributes item=licenceAttribute}
	{if isset($licenceAttribute->licenceKey)}	<!-- For Email 	-->
	{if $licenceAttribute->licenceKey == "IPrange"}
		{assign var='hasIP' value='true'}
		{assign var='IPrange' value=$licenceAttribute->licenceValue}
	{/if}
	{if $licenceAttribute->licenceKey == "barcode"}
		{assign var='hasBarcode' value='true'}
		{assign var='barcode' value=$licenceAttribute->licenceValue}
		{/if}
	{if $licenceAttribute->licenceKey == "AccountManagerEmail"}
		{assign var='hasAccountManagerEmail' value='true'}
		{assign var='AccountManagerEmail' value=$licenceAttribute->licenceValue}
		{/if}	
	{if $licenceAttribute->licenceKey == "AccountManagerName"}
		{assign var='hasAccountManagerName' value='true'}
		{assign var='AccountManagerName' value=$licenceAttribute->licenceValue}
		{/if}	
	{else} 		<!-- For preview -->
		{if $licenceAttribute.licenceKey == "IPrange"}
			{assign var='hasIP' value='true'}
			{assign var='IPrange' value=$licenceAttribute.licenceValue}
		{/if}
		{if $licenceAttribute.licenceKey == "barcode"}
			{assign var='hasBarcode' value='true'}
			{assign var='barcode' value=$licenceAttribute.licenceValue}
		{/if}
		{if $licenceAttribute.licenceKey == "AccountManagerEmail"}
			{assign var='hasAccountManagerEmail' value='true'}
			{assign var='AccountManagerEmail' value=$licenceAttribute.licenceValue}
		{/if}
		{if $licenceAttribute.licenceKey == "AccountManagerName"}
			{assign var='hasAccountManagerName' value='true'}
			{assign var='AccountManagerName' value=$licenceAttribute.licenceValue}
		{/if}
	{/if}
{/foreach}
{if $resellerCode=='12'}
	<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold; line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
   <tr>
    <td width="14" height="10" ></td>
    <td width="96"  valign="top"></td>
    <td width="10"></td>
    <td width="240"></td>
  </tr>     
    <tr>
    <td width="14" height="99"></td>
    <td width="96" valign="top"><img src="http://www.clarityenglish.com/images/email/q_clarityenglish.png" width="88" align="right" style="margin:2px 0 0 0;"/></td>
    <td width="10"></td>
    <td width="240" align="left" valign="top">

        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Charlotte Kwok</p>
        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">ClarityEnglish<br />
		Hong Kong<br />
		Tel: +852 2791 1787 <br />
		<a href="mailto:Charlotte.Kwok@clarityenglish.com">Charlotte.Kwok@clarityenglish.com</a>
	  </p> </td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
  </tr>
</table>


{elseif $resellerCode=='44'}
	<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold; line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
       <tr>
    <td width="14" height="10" ></td>
    <td width="96"  valign="top"></td>
    <td width="10"></td>
    <td width="240"></td>
  </tr>   
    <tr>
    <td width="14" height="99"></td>
    <td width="96" valign="top"><img src="http://www.clarityenglish.com/images/email/q_clarityenglish.png" width="88" align="right" style="margin:2px 0 0 0;"/></td>
    <td width="10"></td>
    <td width="240" align="left" valign="top">

        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Andrew Stokes</p>
        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">ClarityEnglish<br />
		Hong Kong office<br />
		Tel: +852 9731 0900 <br />
		<a href="mailto:andrew.stokes@clarityenglish.com">andrew.stokes@clarityenglish.com</a>
	  </p> </td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
  </tr>
</table>

{elseif $resellerCode=='47'}
	<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold; line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
       <tr>
    <td width="14" height="10" ></td>
    <td width="96"  valign="top"></td>
    <td width="10"></td>
    <td width="240"></td>
  </tr>   
    <tr>
    <td width="14" height="99"></td>
    <td width="96" valign="top"><img src="http://www.clarityenglish.com/images/email/q_eltc.png" width="88" align="right" style="margin:2px 0 0 0;"/></td>
    <td width="10"></td>
    <td width="240" align="left" valign="top">

        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Mr Andy Cowle</p>
        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">ELT Connections<br />
		United Kingdom<br />
		Tel: +44 (0)7860 339420 <br />
		<a href="mailto:andy@eltconnections.com">andy@eltconnections.com</a>
	  </p> </td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
  </tr>
</table>
{elseif $resellerCode=='13'}
	<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold; line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
       <tr>
    <td width="14" height="10" ></td>
    <td width="96"  valign="top"></td>
    <td width="10"></td>
    <td width="240"></td>
  </tr>   
    <tr>
    <td width="14" height="99"></td>
    <td width="96" valign="top"><img src="http://www.clarityenglish.com/images/email/q_clarityenglish.png" width="88" align="right" style="margin:2px 0 0 0;"/></td>
    <td width="10"></td>
    <td width="240" align="left" valign="top">

        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Andrew Stokes</p>
        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">ClarityEnglish<br />
		Hong Kong office <br />
		Tel: +852 9731 0900 <br />
		<a href="mailto:andrew.stokes@clarityenglish.com">andrew.stokes@clarityenglish.com</a>
	  </p> </td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
  </tr>
</table>

{elseif $resellerCode=='46'}
	<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold; line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
       <tr>
    <td width="14" height="10" ></td>
    <td width="96"  valign="top"></td>
    <td width="10"></td>
    <td width="240"></td>
  </tr>   
    <tr>
    <td width="14" height="99"></td>
    <td width="96" valign="top"><img src="http://www.clarityenglish.com/images/email/q_clarityenglish.png" width="88" align="right" style="margin:2px 0 0 0;"/></td>
    <td width="10"></td>
    <td width="240" align="left" valign="top">

        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Dr. Adrian Raper</p>
        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">ClarityEnglish<br />
		Hong Kong office <br />
		Tel: +852 2791 1787<br />
		<a href="mailto:adrian.raper@clarityenglish.com">adrian.raper@clarityenglish.com</a>
	  </p> </td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
  </tr>
</table>

    
{elseif $resellerCode=='45'}
	<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold; line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
       <tr>
    <td width="14" height="10" ></td>
    <td width="96"  valign="top"></td>
    <td width="10"></td>
    <td width="240"></td>
  </tr>   
    <tr>
    <td width="14" height="99"></td>
    <td width="96" valign="top"><img src="http://www.clarityenglish.com/images/email/logo_elec_phil.jpg" width="88" align="right" style="margin:2px 0 0 0;"/></td>
    <td width="10"></td>
    <td width="240" align="left" valign="top">

        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Ms Melody JOY R. Berroya</p>
        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">Electronic Information Solutions Inc.<br />
		Philippines<br />
		Tel: +632 843 6571/ +632 845 3507<br />
		<a href="mailto:joy.berroya@eisi.com.ph ">joy.berroya@eisi.com.ph </a>
	  </p> </td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
  </tr>
</table>

{elseif $resellerCode=='15'}
	<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="2" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold; line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
       <tr>
    <td width="70" height="10" ></td>
    <td width="290"  valign="top"></td>
    
  </tr>   
    <tr>
    <td width="70" height="99"></td>
    
    <td width="290" align="left" valign="top">

        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Ms Rosana Tollazzi</p>
        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">Rosanna doo<br />
		Slovenia<br />
		Tel: +386 (0)59 33 44 00<br />
		<a href="mailto:rossana@t-2.net">rossana@t-2.net</a>
	  </p> </td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
  </tr>
</table>

{elseif $resellerCode=='37'}
	<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold; line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
       <tr>
    <td width="14" height="10" ></td>
    <td width="96"  valign="top"></td>
    <td width="10"></td>
    <td width="240"></td>
  </tr>   
    <tr>
    <td width="14" height="99"></td>
    <td width="96" valign="top"><img src="http://www.clarityenglish.com/images/email/logo_vbps.jpg" width="88" align="right" style="margin:2px 0 0 0;"/></td>
    <td width="10"></td>
    <td width="240" align="left" valign="top">

        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Mr Giang Cao Thảo</p>
        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">Vietnam Book Promotion Service<br />
		Vietnam<br />
		Tel: [84] 8 3507 4706<br />
		<a href="mailto:thao@vietnambookpromotion.com">thao@vietnambookpromotion.com</a>
	  </p> </td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
  </tr>
</table>

    

{elseif $resellerCode=='42'}
<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold;line-height:14px; ">Your Account Manager is:</p>        
		</td>
      </tr>
      
      <tr>
    <td width="15" height="10" ></td>
    <td width="99"  valign="top"></td>
    <td width="10"></td>
    <td width="236"></td>
  </tr>
      <tr>
    <td width="15" height="90" ></td>
    <td width="99"  valign="top"><img src="http://www.clarityenglish.com/images/email/logo_cienytec.jpg" width="92" align="right" style="margin:2px 0 0 10px;" /></td>
    <td width="10"></td>
    <td width="236" align="left" valign="top">
  
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Mr Ricardo Ospina B.</p>
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">
		Cienytec Ltda<br />
		Colombia<br />
		Tel: +57 1 467 2719<br />
		<a href="mailto: ricardo.ospina@cienytec.com">ricardo.ospina@cienytec.com</a>
		</p>   </td>
  </tr>
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
    </tr>
</table>


{elseif $resellerCode=='43'}
<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold;line-height:14px; ">Your Account Manager is:</p>        </td>
      </tr>
      
      <tr>
    <td width="15" height="10" ></td>
    <td width="99"  valign="top"></td>
    <td width="10"></td>
    <td width="236"></td>
  </tr>
      <tr>
    <td width="15" height="90" ></td>
    <td width="99"  valign="top"><img src="http://www.clarityenglish.com/images/email/logo_spain.jpg" width="90" align="right" style="margin:2px 0 0 0px;" /></td>
    <td width="10"></td>
    <td width="236" align="left" valign="top">
  
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Ms Maribel Domenech</p>
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">
		eTFL Solutions<br />
		Spain<br />
		Tel: +34 693 614 390<br />
		<a href="mailto: maribel@etfl.es">maribel@etfl.es</a>	</p>   </td>
  </tr>
    <tr>
      <td valign="top"></td>
    </tr>
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
    </tr>
</table>

{elseif $resellerCode=='2'}
<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold;line-height:14px; ">Your Account Manager is:</p>        </td>
      </tr>
      
      <tr>
    <td width="8" height="10" ></td>
    <td width="99"  valign="top"></td>
    <td width="8"></td>
    <td width="247"></td>
  </tr>
      <tr>
    <td width="8" height="90" ></td>
    <td width="99"  valign="top"><img src="http://www.clarityenglish.com/images/email/q_bookery.jpg" width="75" height="65" align="right" style="margin:2px 0 0 10px;" /></td>
    <td width="8"></td>
    <td width="247" align="left" valign="top">
  
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Ms Jennifer Paschal</p>
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">
		Bookery<br />
		Australia<br />
		Tel: +61 3 8417 9500<br />
		<a href="mailto: info@bookery.com.au">info@bookery.com.au</a>	</p>   </td>
  </tr>
    <tr>
      <td valign="top"></td>
    </tr>
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
    </tr>
</table>

    
    
{elseif $resellerCode=='11'}
<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold; line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
  <tr>
    <td width="9" height="10" ></td>
    <td width="99"  valign="top"></td>
    <td width="8"></td>
    <td width="244"></td>
  </tr>
	
    <tr>
    <td width="9" height="99"></td>
    <td width="99"  valign="top"><img src="http://www.clarityenglish.com/images/email/q_yif.jpg" width="83" height="74" align="right" style="margin:2px 0 0 0;" /></td>
    <td width="8"></td>
    <td width="244" align="left" valign="top">

		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Mr Vivek Bhasin</p>
	  <p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">
		Young India Films<br />
		India<br />
		Tel: [91] 44-2829 5693<br />
		<a href="mailto: info@youngindiafilms.in">info@youngindiafilms.in</a>
	  </p>  </td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
    </tr>
</table>

    
{elseif $resellerCode=='22'}
<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold; line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
  <tr>
    <td width="9" height="10" ></td>
    <td width="99"  valign="top"></td>
    <td width="10"></td>
    <td width="242"></td>
  </tr>
  
    <tr>
    <td width="9" height="98"></td>
    <td width="99"  valign="top"><img src="http://www.clarityenglish.com/images/email/q_celestron.jpg" width="79" height="50" align="right" style="margin:2px 0 0 0;" /></td>
    <td width="10"></td>
    <td width="242" align="left" valign="top">
    
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Mr Aldo Valdenegro</p>
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">
		Celestron Ltda<br />
		Chile<br />
		Tel: 2-2640404<br />
		<a href="mailto: valdenegro@celestron.cl">valdenegro@celestron.cl</a>
	  </p> </td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
    </tr>
</table>
    
{elseif $resellerCode=='24'}
<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold;line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
  <tr>
    <td width="11" height="10" ></td>
    <td width="97"  valign="top"></td>
    <td width="7"></td>
    <td width="245"></td>
  </tr>
  
    <tr>
    <td width="11" height="100"></td>
    <td width="97" valign="top"><img src="http://www.clarityenglish.com/images/email/q_edict.jpg" width="86" height="42" align="right" style="margin:2px 0 0 0;"/></td>
    <td width="7"></td>
    <td width="245" align="left" valign="top">
      
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Mr Isaac Ho</p>
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">
		Edict Electronics Sdn Bhd<br />
		Malaysia<br />
		Tel: [60] 3 8319 1101<br />
		<a href="mailto: isaac@edict.com.my">isaac@edict.com.my</a>
	  </p> </td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
    </tr>
</table>
    
{elseif $resellerCode=='28'}
<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold; line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
   <tr>
    <td width="12" height="10" ></td>
    <td width="90"  valign="top"></td>
    <td width="10"></td>
    <td width="248"></td>
  </tr>   
    <tr>
    <td width="12" height="94"></td>
    <td width="90" valign="top"><img src="http://www.clarityenglish.com/images/email/q_protea.jpg" width="75" height="71" align="right" style="margin:2px 0 0 0;"/></td>
    <td width="10"></td>
    <td width="248" align="left" valign="top">
   
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Virginia Westwood </strong></p>
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">
		Protea Textware Pty Ltd<br />
            Australia<br />
		Tel: (08) 9192 8390<br />
		Mobile: 0408 971 446<br />
		<a href="mailto: orders@proteatextware.com.au">orders@proteatextware.com.au</a>
      </p></td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
    </tr>
</table>
    
{elseif $resellerCode=='7'}
<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold;line-height:14px;  ">Your Account Manager is:</p>
        </td>
      </tr>
    <tr>
    <td width="13" height="10" ></td>
    <td width="98"  valign="top"></td>
    <td width="12"></td>
    <td width="237"></td>
  </tr>     
    <tr>
    <td width="13" height="93"></td>
    <td width="98"  valign="top"><img src="http://www.clarityenglish.com/images/email/q_nas.jpg" width="89" height="37" align="right" style="margin:2px 0 0 0;" /></td>
    <td width="12"></td>
    <td width="237" align="left" valign="top">

		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Mr Samuel Sheinberg</strong></p>
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">
		NAS Software Inc.<br />
		Canada<br />
		Tel: [1] 905-764-8079<br />
		<a href="mailto: sam@nas.ca">sam@nas.ca</a>
	  </p> </td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
    </tr>
</table>
    
    
{elseif $resellerCode=='14'}
<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold; line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
 <tr>
    <td width="12" height="10" ></td>
    <td width="88"  valign="top"></td>
    <td width="9"></td>
    <td width="251"></td>
  </tr>     
    <tr>
    <td width="12" height="96"></td>
    <td width="88"  valign="top"><img src="http://www.clarityenglish.com/images/email/q_solusi.jpg" width="83" height="77" align="right" style="margin:2px 0 0 0;" /></td>
    <td width="9"></td>
    <td width="251" align="left" valign="top">
   
	  
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Ms Ervida Lin</strong></p>
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">SOLUSI Educational Technology<br />
		Indonesia<br />
		Tel: [62] 61-733 1286<br />
		<a href="mailto:ervida@solusieducationaltechnology.com">ervida@solusieducationaltechnology.com</a><br />
	  </p> </td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
    </tr>
</table>

    
    

    
{elseif $resellerCode=='34'}
<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold; line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
 <tr>
    <td width="18" height="10" ></td>
    <td width="92"  valign="top"></td>
    <td width="9"></td>
    <td width="241"></td>
  </tr>     
    <tr>
    <td width="18" height="96"></td>
    <td width="92"  valign="top"><img src="http://www.clarityenglish.com/images/email/logo_principalgris.png" width="92" align="right" style="margin:2px 0 0 0;" /></td>
    <td width="9"></td>
    <td width="241" align="left" valign="top">
   
	  
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Ms Elizabeth Peña G.</strong></p>
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">Premium Education<br />
		Mexico<br />
		Tel: +52 55 3028 4158<br />
		<a href="mailto:elizabeth.pena@premium-ed.com">elizabeth.pena@premium-ed.com</a><br />
	  </p> </td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
    </tr>
</table>

    
{elseif $resellerCode=='38'}
<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold; line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
 <tr>
    <td width="18" height="10" ></td>
    <td width="76"  valign="top"></td>
    <td width="9"></td>
    <td width="257"></td>
  </tr>     
    <tr>
    <td width="18" height="96"></td>
    <td width="76"  valign="top"><img src="http://www.clarityenglish.com/images/email/logo_lesol.png" width="70" align="right" style="margin:2px 0 0 0;" /></td>
    <td width="9"></td>
    <td width="257" align="left" valign="top">
   
	  
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Mr Subramoni K Iyer</strong></p>
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">Tech Solutions FZE<br />
		GCC<br />
		Mob: [971] 50 9332421<br />
		<a href="mailto: subramoni.iyer@techsolutionsfze.com">subramoni.iyer@techsolutionsfze.com</a><br />
	  </p> </td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
    </tr>
</table>
    

    
{elseif $resellerCode=='10'}
<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold; line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
     <tr>
    <td width="14" height="10" ></td>
    <td width="96"  valign="top"></td>
    <td width="10"></td>
    <td width="240"></td>
  </tr> 
    <tr>
    <td width="14" height="99"></td>
    <td width="96" valign="top"><img src="http://www.clarityenglish.com/images/email/logo_winhoe.jpg" width="85" align="right" style="margin:2px 0 0 0;"/></td>
    <td width="10"></td>
    <td width="240" align="left" valign="top">

        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Ms Kima Huang</p>
        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">Win Hoe Company Limited<br />
		Taiwan<br />
		Tel: [886] 4-2451-8175<br />
		<a href="mailto:kima@winhoe.com">kima@winhoe.com</a>
	  </p> </td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
  </tr>
</table>

{elseif $resellerCode=='17'}
<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold; line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
         <tr>
    <td width="14" height="10" ></td>
    <td width="104"  valign="top"></td>
    <td width="12"></td>
    <td width="230"></td>
  </tr> 
    <tr>
    <td width="14" height="99"></td>
    <td width="104" valign="top"><img src="http://www.clarityenglish.com/images/email/q_encomium.jpg" width="95" align="right" style="margin:2px 0 0 0;"/></td>
    <td width="12"></td>
    <td width="230" align="left" valign="top">
  
        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:700; font-size: 1em; margin:0 0 5px 0; padding:0; color:#000000;">Ms. Maryam Hallez</p>
        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">Encomium Publications, Inc.<br />
		USA<br />
		Tel: +1 (513) 871-4377<br />
		<a href="mailto:maryam@encomium.com">maryam@encomium.com</a>
	  </p> </td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
  </tr>
</table>
{elseif $resellerCode=='48'}
<table width="360" border="0" cellpadding="0" cellspacing="0" background="http://www.clarityenglish.com/images/email/q_mid.jpg" bgcolor="#EDEDED" style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px;margin: 0 0 12px 0;">
      <tr>
        <td height="45" colspan="4" background="http://www.clarityenglish.com/images/email/q_top.jpg">  <p style="font-family: 'Oxygen', Arial, Helvetica, sans-serif; font-size: 1.1em; margin:0; padding:20px 0 0 70px; color:#000000; font-weight:bold; line-height:14px; ">Your Account Manager is:</p>
        </td>
      </tr>
       <tr>
    <td width="14" height="10" ></td>
    <td width="96"  valign="top"></td>
    <td width="10"></td>
    <td width="240"></td>
  </tr>   
    <tr>
    <td width="14" height="99"></td>
    <td width="96" valign="top"><img src="http://www.clarityenglish.com/images/email/q_BC.png" width="88" align="right" style="margin:2px 0 0 0;"/></td>
    <td width="10"></td>
    <td width="240" align="left" valign="top">

      {if $hasAccountManagerEmail=='true' && $hasAccountManagerName=='true'}
        <p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">{$AccountManagerName}<br>{$AccountManagerEmail}</p>
		{else}	
		<p style="font-family: Arial, Helvetica, sans-serif; font-weight:400; font-size: 1em; margin:0; padding:0; color:#000000;">Please contact your local <br>British Council office.</p>
		{/if}
	</td>
  </tr>
    
  <tr>
    <td height="27" colspan="4" background="http://www.clarityenglish.com/images/email/q_bottom.jpg"></td>
  </tr>
</table>

    
{/if}      
