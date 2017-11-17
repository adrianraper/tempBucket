{if $dateDiff == ''}
	{assign var='dateDiff' value='-1month'}
{/if}
{* Count number of expiring titles to help with wording in the email *}
{assign var='countExpiringTitles' value=0}
{date_diff assign='expiringDate' date='' period=$dateDiff}
{foreach name=orderDetails from=$account->titles item=title}
	{* Ignore RM and TB6Weeks*}
	{if $title->expiryDate|truncate:10:"" == $expiringDate && $title->productCode!=2 && $title->productCode!=59}
		{assign var='countExpiringTitles' value=$countExpiringTitles+1}
	{elseif $title->productCode == 2}
		{assign var='totalTitles' value=$totalTitles-1}
	{elseif $title->productCode == 59}
		{assign var='totalTitles' value=$totalTitles-1}
	{/if}
{/foreach}
{assign var='totalTitles' value=$account->titles|@count}
{if $totalTitles == $countExpiringTitles}
	{assign var='useWording' value='all' scope='parent'}
{elseif $countExpiringTitles == 1}
	{assign var='useWording' value='one' scope='parent'}
{elseif $countExpiringTitles == 2}
	{assign var='useWording' value='couple' scope='parent'}
{else}
	{assign var='useWording' value='some' scope='parent'}
{/if}
{$useWording}