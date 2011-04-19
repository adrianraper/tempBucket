{* This works out some template details that are not in the regular title object *}
{* No good as variables set within the include are lost when you leave the scope *}
{if $title->name|stristr:"Tense Buster"}
	{assign var='titleImage' value='tblogo.jpg'}
	{assign var='startPageFolder' value='TenseBuster'}
{elseif $title->name|stristr:"Results Manager"}
	{assign var='titleImage' value='rmlogo.jpg'}
	{assign var='startPageFolder' value='ResultsManager'}
{elseif $title->name|stristr:"Active Reading"}
	{assign var='titleImage' value='arlogo.jpg'}
	{assign var='startPageFolder' value='ActiveReading'}
{elseif $title->name|stristr:"Study Skills"}
	{assign var='titleImage' value='ssslogo.jpg'}
	{assign var='startPageFolder' value='StudySkillsSuccess'}
{elseif $title->name|stristr:"Author Plus"}
	{assign var='titleImage' value='apstudent.jpg'}
	{assign var='startPageFolder' value='AuthorPlus'}
{elseif $title->name|stristr:"Road to IELTS Academic"}
	{assign var='titleImage' value='roadlogo.jpg'}
	{assign var='startPageFolder' value='RoadToIELTS-Academic'}
{elseif $title->name|stristr:"Road to IELTS General"}
	{assign var='titleImage' value='roadlogo.jpg'}
	{assign var='startPageFolder' value='RoadToIELTS-General'}
{elseif $title->name|stristr:"Business Writing"}
	{assign var='titleImage' value='bwlogo.jpg'}
	{assign var='startPageFolder' value='BusinessWriting'}
{elseif $title->name|stristr:"My Canada"}
	{assign var='titleImage' value='mclogo.jpg'}
	{assign var='startPageFolder' value='MyCanada'}
{elseif $title->name|stristr:"Call Center Communication Skills"}
	{assign var='titleImage' value='cccslogo.jpg'}
	{assign var='startPageFolder' value='CCCS'}
{elseif $title->name|stristr:"Customer Service"}
	{assign var='titleImage' value='cscslogo.jpg'}
	{assign var='startPageFolder' value='CSCS'}
{elseif $title->name|stristr:"It's Your Job"}
	{assign var='titleImage' value='iyjlogo.jpg'}
	{assign var='startPageFolder' value='ItsYourJob'}
{elseif $title->name|stristr:"Clear Pronunciation"}
	{assign var='titleImage' value='cplogo.jpg'}
	{assign var='startPageFolder' value='ClearPronunciation'}
{elseif $title->name|stristr:"English for Hotel Staff"}
	{assign var='titleImage' value='efhslogo.jpg'}
	{assign var='startPageFolder' value='EnglishForHotelStaff'}
{elseif $title->name|stristr:"Issues in English 2"}
	{assign var='titleImage' value='iie2logo.jpg'}
	{assign var='startPageFolder' value='IssuesInEnglish2'}
{elseif $title->name|stristr:"Connected Speech"}
	{assign var='titleImage' value='cslogo.jpg'}
	{assign var='startPageFolder' value='ConnectedSpeech'}
{elseif $title->name|stristr:"Clarity English Success"}
	{assign var='titleImage' value='ceslogo.jpg'}
	{assign var='startPageFolder' value='ClarityEnglishSuccess'}
{elseif $title->name|stristr:"Sun On Japanese"}
	{assign var='titleImage' value='sojlogo.jpg'}
	{assign var='startPageFolder' value='SunOnJapanese'}
{elseif $title->name|stristr:"L'amour des temps"}
	{assign var='titleImage' value='GeneralLogo.jpg'}
	{assign var='startPageFolder' value='LamourDesTemps'}
{elseif $title->name|stristr:"Language Key"}
	{assign var='titleImage' value='GeneralLogo.jpg'}
	{assign var='startPageFolder' value='LanguageKey/xxx'}
{else}
	{assign var='titleImage' value='GeneralLogo.jpg'}
	{assign var='startPageFolder' value='xxx'}
{/if}
{if $method=='image'}
	<img src="http://www.clarityenglish.com/images/englishonline/{$titleImage}" border="0" />
{/if}
{if $method=='startPage'}
	{if $title->name|stristr:"It's Your Job"}
		http://www.ClarityEnglish.com/area1/{$startPageFolder}/index.php?prefix={$account->prefix}</br>
	{else}
		http://www.ClarityEnglish.com/area1/{$startPageFolder}/Start.php?prefix={$account->prefix}</br>
	{/if}
{/if}
