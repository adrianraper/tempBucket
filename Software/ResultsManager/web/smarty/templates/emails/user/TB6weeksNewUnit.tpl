{* Name: TB6weeks welcome *}
{* Description: Email sent to subscriber to TB6weeks *}
{* Parameters: $user, $ClarityLevel, $programBase, $startProgram, $startProgress, $dateDiff, $server *}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

{if $server == ''}{assign var='server' value='dock.projectbench'}{/if}

{* sadly this can't go in an include as var assignment is lost in the main EVEN if you do scope=parent*}
{if $level == 'ELE'}
    {assign var='levelDescription' value='Elementary'}
    {assign var='unitNames' value=';'|explode:"Am, is, are (to be);Simple present;Negatives (I don't go);Countable;I, my, me;Questions (does he?)"}
{/if}
{if $level == 'LI'}
    {assign var='levelDescription' value='Lower Intermediate'}
    {assign var='unitNames' value=';'|explode:"Simple present;Simple past;Present perfect;Comparisons;Present continuous;Prepositions"}
{/if}
{if $level == 'INT'}
    {assign var='levelDescription' value='Intermediate'}
    {assign var='unitNames' value=';'|explode:'The passive;"Will" and "going to";Question tags;Equality;Relative clauses;Conditionals'}
{/if}
{if $level == 'UI'}
    {assign var='levelDescription' value='Upper Intermediate'}
    {assign var='unitNames' value=';'|explode:'Past continuous;Conditionals;Adjectives and adverbs;Present perfect;Modals verbs;The future'}
{/if}
{if $level == 'ADV'}
    {assign var='levelDescription' value='Advanced'}
    {assign var='unitNames' value=';'|explode:'Reported speech;Phrasal verbs;Nouns;Past perfect;The passive;Articles'}
{/if}

{* expect date diff to be like '7 days' *}
{if $dateDiff == ''}
    {assign var='dateDiff' value='7 days'}
{/if}
{* split the date interval into value and unit *}
{assign var='dateIntValue' value=$dateDiff|string_format:"%d"}
{assign var='dateIntTemp' value=" "|explode:$dateDiff}
{assign var='dateIntUnit' value=$dateIntTemp[1]}
{assign var='weekIndex' value=$weekX-1}

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>{if $weekX>6}Tense Buster grammar - Complete!{else}Tense Buster grammar unit {$weekX}: {$unitNames[$weekIndex]}{/if}</title>
    <!-- <from>support@clarityenglish.com</from> -->
    <!-- <bcc>adrian@clarityenglish.com</bcc> -->
</head>

<body style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 1em; background-color:#F1F1F1;">
<table width="600" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#F1F1F1" style="font-size:12px; min-width:600px; font-family:Arial, Helvetica, sans-serif;" background="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/bg.jpg">
  <tr>
    <td colspan="3"><img src="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/banner.jpg" alt="Tense Buster 6 week" width="600" height="193" border="0" style="margin:0; font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 1.2em;"/></td>
  </tr>
  <tr>
    <td colspan="3" background="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/bg.jpg">
	  <div style="padding:0 48px;">
           <div style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 1.2em; padding:15px 0; color:#000000; line-height:18px;">Dear {$user->name}</div>
            <div style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 1.2em; padding:15px 0; line-height:18px; color:#E22634; font-weight:bold;">Your English Level is...</div>
      </div>
    </td>
  </tr>
  <tr>
    <td colspan="3" background="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/bar-grey.jpg">
        <table width="600" border="0" cellspacing="0" cellpadding="0" height="73" style="font-size:12px; min-width:600px;">
          <tr>
            <td width="48" style="font-family: Arial, Verdana,  Helvetica, sans-serif;color:#000000; line-height:73px;"></td>
            <td width="128" style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size: 1.6em;  color:#E22634;" valign="middle">{$levelDescription}</td>
            <td width="411"><img src="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/{$level}.jpg" /></td>
            <td width="13" style="font-family: Arial, Verdana,  Helvetica, sans-serif; color:#000000; line-height:73px;"></td>
          </tr>
        </table>
    </td>
  </tr>

  <tr>
    <td colspan="3" background="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/bg.jpg">
        <table width="600" border="0" cellspacing="0" cellpadding="0" style="font-size:12px; min-width:600px;">
            <tr>
                <td width="13" rowspan="10"></td>
                <td width="346" height="60" bgcolor="#FFFFFF" valign="middle">
                    <div style="padding:0 0 0 34px; color:#E5404E; font-size:1.2em; font-weight:700;">
                        {if $weekX>6}These are the six grammar units you have finished:
                        {else}Here are your six grammar units:
                        {/if}
                    </div>
                </td>
                <td width="241" rowspan="10"><img src="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/girl.jpg" width="241" height="284" /></td>
            </tr>
            <tr>
                <td height="15" bgcolor="#FCE8E9"></td>
            </tr>
        {foreach from=$unitNames name=unit item=unitName}
            {math equation='(x - y) * z' x=$smarty.foreach.unit.iteration y=$weekX z=$dateIntValue assign='weekMultiplier'}
            {assign var='dateInterval' value="`$weekMultiplier` `$dateIntUnit`"}
            <tr>
              <td height="26" bgcolor="#FCE8E9" >
                 <table width="317" height="26" border="0" align="right" cellpadding="0" cellspacing="0"
                        {if $smarty.foreach.unit.iteration==$weekX}background="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/bg-week.jpg" {/if}
                        style="font-family: Arial, Verdana,  Helvetica, sans-serif; font-size:12px;">
                    <tr>
                        <td width="28"></td>
                        <td width="115" style="font-size:1.2em; {if $smarty.foreach.unit.iteration==$weekX}color:#E5404E{else}color:#999999{/if}; font-weight:700;">{$smarty.foreach.unit.iteration} ({if $smarty.foreach.unit.iteration<$weekX}done{elseif $smarty.foreach.unit.iteration==$weekX}starts today{else}start {$dateInterval|strtotime|date_format:'%d/%m'}{/if})</td>
                        <td width="174" style="font-size:1.2em; {if $smarty.foreach.unit.iteration==$weekX}color:#000000{else}color:#999999{/if}; font-weight:700;">{$unitName}</td>
                    </tr>
                </table>
              </td>
            </tr>
        {/foreach}
            <tr>
                <td height="26" bgcolor="#FCE8E9"></td>
            </tr>
            <tr>
                <td height="29" bgcolor="#FFFFFF" valign="middle">
    	            <div style="padding:0 0 0 34px; color:#333333; font-size:1.2em;">Click to check your scores! <a href="{$programBase}{$startProgress}" style="color:#333333; font-weight:bold;">My Progress</a></div>
                </td>
            </tr>
        </table>
    </td>
  </tr>
  
  <tr>
    <td colspan="3" background="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/bg.jpg">
        <table width="600" border="0" cellspacing="0" cellpadding="0" style="font-size:12px; font-family:Arial, Helvetica, sans-serif;">
            <tr>
                <td height="20" colspan="5"></td>
            </tr>
            <tr>
                <td width="77"></td>
                <td width="215">
                    {if $weekX>6}
                        <a href="http://{$server}/TenseBuster/6weeks/unsubscribe.php?prefix={$prefix}&email={$user->email}" target="_blank"><img src="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/Delete-My-Level.png" border="0"/></a>    </td>
                    {else}
                        <a href="{$programBase}{$startProgram}" target="_blank"><img src="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/Start-Week-{$weekX}.png" border="0" /></a>    </td>
                    {/if}
                <td width="15"></td>
                <td width="215">
                    <a href="http://{$server}/TenseBuster/6weeks/change-my-level.php?prefix={$prefix}&email={$user->email}" target="_blank"><img src="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/Change-My-Level{if $weekX>6}-Red{/if}.png" border="0"/></a>     </td>
                <td width="78"></td>
            </tr>
            <tr>
                <td height="20" colspan="5"></td>
            </tr>
        </table>
    </td>
  </tr>
    
  <tr>
    <td colspan="3" background="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/TB-footer-bg.png" height="130" valign="top">
    	<table width="600" border="0" align="left" cellpadding="0" cellspacing="0" style="font-size:12px; font-family:Arial, Helvetica, sans-serif;">
          <tr>
                <td rowspan="4" width="225"></td>
                <td height="30" colspan="5"></td>
              </tr>
          	  <tr>
            	<td height="30" colspan="5" style="color:#333333; font-size:1.2em;">Download the <strong>Tense Buster Apps </strong>and study on the go!</td>
              </tr>
              <tr>
                <td width="112"><a href="https://itunes.apple.com/ae/app/tense-buster/id696619890?mt=8" target="_blank"><img src="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/apple-app.png" alt="Apple App" border="0"/></a></td>
                <td width="15"></td>
                <td width="98"><a href="https://play.google.com/store/apps/details?id=air.com.clarityenglish.tensebuster.app&amp;hl=en" target="_blank"><img src="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/google-play.png" alt="Google play" border="0" /></a></td>
                <td width="15"></td>
                <td width="135"><a href="http://www.clarityenglish.com/downloads/apk/TenseBuster.php?utm_campaign=APP-APK&amp;utm_source=TB-6wk&amp;utm_medium=TB-6wk-home" target="_blank"><img src="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/android-app.png" alt="Android app" border="0" /></a></td>
          </tr>
              <tr>
                <td colspan="5"></td>
              </tr>
      </table>
    </td>
  </tr>
    <tr>
    <td colspan="3" height="122" valign="top" background="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/bg-foot.png">
    
    	 <div style="padding:0 48px;">
    			<div style="padding:25px 0 20px 0; color:#333333; font-size:1.2em;">Enjoy your practice!</div>
                <div style="padding:0 0 5px 0; color:#333333; font-size:1.2em;">Best Wishes</div>
                <div style="padding:0; color:#333333; font-size:1.2em;"><img src="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/ClarityEnglish.png" /></div>
          </div>
    </td>
    </tr>
  <tr>
    <td colspan="3"  height="28" bgcolor="#333333">
    	<table width="600" border="0" cellspacing="0" cellpadding="0" style="font-size:12px; font-family:Arial, Helvetica, sans-serif;">
              <tr valign="middle">
                <td width="48"></td>
                <td width="452"><div style="padding:0; color:#ffffff; font-size:0.9em;"><a href="http://www.ClarityEnglish.com" target="_blank" style="color:#ffffff; text-decoration:none;">www.ClarityEnglish.com</a></div></td>
                <td width="100" valign="middle">
                	<a href="http://www.ClarityEnglish.com" target="_blank"><img src="http://www.clarityenglish.com/TenseBuster/6weeks/images/email/ClarityEnglish-white.png" width="84" height="16" border="0"/></a>                </td>
          </tr>
        </table>
    </td>
  </tr>
  
  <tr>
    <td colspan="3"  height="28" bgcolor="#F1F1F1" align="center">
    	<a href="http://{$server}/TenseBuster/6weeks/unsubscribe.php?prefix={$prefix}&email={$user->email}" target="_blank">Click here to unsubscribe your subscription.</a>
    	
        
       
    </td>
  </tr>
  
  
</table>

</body>
</html>
