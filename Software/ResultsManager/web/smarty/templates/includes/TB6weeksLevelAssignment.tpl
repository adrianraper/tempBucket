{if $level == 'ELE'}
	{assign var='levelDescription' value='Elementary' scope=parent}
	{assign var='unit1' value='Am, is, are (to be)'}
	{assign var='unit2' value='Simple present'}
	{assign var='unit3' value='Negatives (I don’t go)'}
	{assign var='unit4' value='Countable'}
	{assign var='unit5' value='I, my, me'}
	{assign var='unit6' value='Questions (does he?)'}
{/if}
{if $level == 'LI'}
	{assign var='levelDescription' value='Lower Intermediate' scope=parent}
	{assign var='unit1' value='Simple present'}
	{assign var='unit2' value='Simple past'}
	{assign var='unit3' value='Present perfect'}
	{assign var='unit4' value='Comparisons'}
	{assign var='unit5' value='Present continuous'}
	{assign var='unit6' value='Prepositions'}
{/if}
{if $level == 'INT'}
	{assign var='levelDescription' value='Intermediate'}
	{assign var='unit1' value='The passive'}
	{assign var='unit2' value='"Will" and "going to"'}
	{assign var='unit3' value='Question tags'}
	{assign var='unit4' value='Equality'}
	{assign var='unit5' value='Relative clauses'}
	{assign var='unit6' value='Conditionals'}
{/if}
{if $level == 'UI'}
	{assign var='levelDescription' value='Upper Intermediate'}
	{assign var='unit1' value='Past continuous'}
	{assign var='unit2' value='Conditionals'}
	{assign var='unit3' value='Adjectives and adverbs'}
	{assign var='unit4' value='Present perfect'}
	{assign var='unit5' value='Modals verbs'}
	{assign var='unit6' value='The future'}
{/if}
{if $level == 'ADV'}
	{assign var='levelDescription' value='Advanced'}
	{assign var='unit1' value='Reported speech'}
	{assign var='unit2' value='Phrasal verbs'}
	{assign var='unit3' value='Nouns'}
	{assign var='unit4' value='Past perfect'}
	{assign var='unit5' value='The passive'}
	{assign var='unit6' value='Articles'}
{/if}
