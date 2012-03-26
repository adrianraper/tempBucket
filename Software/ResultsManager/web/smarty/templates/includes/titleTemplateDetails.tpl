{* This works out some template details that are not in the regular title object *}
{* No good as variables set within the include are lost when you leave the scope *}
{* Old titles
*}
{if $title->name|stristr:"Tense Buster"}
	{assign var='titleImage' value='tb'}
	{assign var='startPageFolder' value='TenseBuster'}
{elseif $title->name|stristr:"Results Manager"}
	{assign var='titleImage' value='rm'}
	{assign var='startPageFolder' value='ResultsManager'}
{elseif $title->name|stristr:"Active Reading"}
	{assign var='titleImage' value='ar'}
	{assign var='startPageFolder' value='ActiveReading'}
{elseif $title->name|stristr:"Study Skills Success V9"}
	{assign var='titleImage' value='sss'}
	{assign var='startPageFolder' value='StudySkillsSuccessV9'}
{elseif $title->name|stristr:"Study Skills Success"}
	{assign var='titleImage' value='g'}
	{assign var='startPageFolder' value='xx'}
{elseif $title->name|stristr:"Author Plus"}
	{assign var='titleImage' value='ap'}
	{assign var='startPageFolder' value='AuthorPlus'}
{elseif $title->name|stristr:"Road to IELTS Academic"}
	{assign var='titleImage' value='rti'}
	{assign var='startPageFolder' value='RoadToIELTS-Academic'}
{elseif $title->name|stristr:"Road to IELTS General"}
	{assign var='titleImage' value='rti'}
	{assign var='startPageFolder' value='RoadToIELTS-General'}
{elseif $title->name|stristr:"Business Writing"}
	{assign var='titleImage' value='bw'}
	{assign var='startPageFolder' value='BusinessWriting'}
{elseif $title->name|stristr:"My Canada"}
	{assign var='titleImage' value='mc'}
	{assign var='startPageFolder' value='MyCanada'}
{elseif $title->name|stristr:"Call Center Communication Skills"}
	{assign var='titleImage' value='cccs'}
	{assign var='startPageFolder' value='CCCS'}
{elseif $title->name|stristr:"Customer Service"}
	{assign var='titleImage' value='cscs'}
	{assign var='startPageFolder' value='CSCS'}
{elseif $title->name|stristr:"It's Your Job"}
	{assign var='titleImage' value='iyj'}
	{assign var='startPageFolder' value='ItsYourJob'}
{elseif $title->name|stristr:"Clear Pronunciation 2"}
	{assign var='titleImage' value='cp2'}
	{assign var='startPageFolder' value='ClearPronunciation2'}
{elseif $title->name|stristr:"Clear Pronunciation"}
	{assign var='titleImage' value='cp'}
	{assign var='startPageFolder' value='ClearPronunciation'}
{elseif $title->name|stristr:"English for Hotel Staff"}
	{assign var='titleImage' value='efhs'}
	{assign var='startPageFolder' value='EnglishForHotelStaff'}
{elseif $title->name|stristr:"Access UK"}
	{assign var='titleImage' value='auk'}
	{assign var='startPageFolder' value='AccessUK'}
{elseif $title->name|stristr:"Practical Placement Test"}
	{assign var='titleImage' value='ppt'}
	{assign var='startPageFolder' value='PracticalPlacementTest'}
{elseif $title->name|stristr:"Issues in English 2"}
	{assign var='titleImage' value='iie2'}
	{assign var='startPageFolder' value='IssuesInEnglish2'}
{elseif $title->name|stristr:"Connected Speech"}
	{assign var='titleImage' value='cs'}
	{assign var='startPageFolder' value='ConnectedSpeech'}
{elseif $title->name|stristr:"Clarity English Success"}
	{assign var='titleImage' value='ces'}
	{assign var='startPageFolder' value='ClarityEnglishSuccess'}
{elseif $title->name|stristr:"Sun On Japanese"}
	{assign var='titleImage' value='so'}
	{assign var='startPageFolder' value='SunOnJapanese'}
{elseif $title->name|stristr:"Clarity Test"}
	{assign var='titleImage' value='ct'}
	{assign var='startPageFolder' value='ClarityTest'}
{elseif $title->name|stristr:"L'amour des temps"}
	{assign var='titleImage' value='g'}
	{assign var='startPageFolder' value='LamourDesTemps'}
{elseif $title->name|stristr:"Language Key"}
	{assign var='titleImage' value='g'}
	{assign var='startPageFolder' value='LanguageKey/xxx'}
{else}
	{assign var='titleImage' value='g'}
	{assign var='startPageFolder' value='xxx'}
{/if}
{if $method=='image'}
	{if $enabled=='off'}
		<img src="http://www.clarityenglish.com/images/email/{$titleImage}_off.jpg" border="0" />
	{else}
		<img src="http://www.clarityenglish.com/images/email/{$titleImage}_on.jpg" border="0" />
	{/if}
{/if}
{if $method=='startPage'}
	{if $title->name|stristr:"It's Your Job"}
		http://www.ClarityEnglish.com/area1/{$startPageFolder}/index.php?prefix={$account->prefix}</br>
	{* Actually no harm in using prefix for RM - it is just ignored
		{elseif $title->name|stristr:"Results Manager"}
			http://www.ClarityEnglish.com/area1/{$startPageFolder}/Start.php</br>
	*}
	{else}
		http://www.ClarityEnglish.com/area1/{$startPageFolder}/Start.php?prefix={$account->prefix}</br>
	{/if}
{/if}
