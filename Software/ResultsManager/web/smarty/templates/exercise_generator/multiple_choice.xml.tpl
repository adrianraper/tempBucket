{assign var=exerciseType value=$xml->settings->exerciseType}
{assign var=questions value=$xml->questions->$exerciseType}

<bento xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<style type="text/css">
		<![CDATA[
		{literal}
		* {
			font-size: 12px;
			font-family: Verdana;
		}
		
		/* Links and draggable spans should be blue and not underlined */
		a, span[draggable="true"] {
			color: #3A00FF;
			text-decoration: none;
		}
		
		/* Classes for showing selections and results */
		a.selected {
			text-decoration: underline;
		}

		a.correct, input.correct, g.correct, select.correct {
			color: 	#4bae38 !important;
			text-decoration: underline;
		}

		a.incorrect, input.incorrect, g.incorrect, select.incorrect {
			color: #7A0404 !important;
		}

		a.neutral, input.neutral, g.neutral, select.neutral {
			color: #0000AA !important;
		}
		{/literal}
		]]>
		</style>
		
		<script id="model" type="application/xml">
			<settings>
				<param name="delayedMarking" value="{if $xml->settings->markingType == 'instant'}false{else}true{/if}" />
			</settings>
			
			<questions>
				{foreach from=$questions item=question name=question}
				<{$exerciseType} block="q{$smarty.foreach.question.index}">
					{foreach from=$question->answers->answer item=answer name=answer}
					<answer source="q{$smarty.foreach.question.index}a{$smarty.foreach.answer.index}">
					</answer>
					{/foreach}
				</{$exerciseType}>
				{/foreach}
			</questions>
		</script>
	</head>
	
	<body>
		{foreach from=$questions item=question name=question}
		<p id="q{$smarty.foreach.question.index}">
			<p>{$question->question}</p>
			<ol>
				{foreach from=$question->answers->answer item=answer name=answer}
				<li>
					<a id="q{$smarty.foreach.question.index}a{$smarty.foreach.answer.index}">
						{$answer}
					</a>
				</li>
				{/foreach}
			</ol>
		</p>
		{/foreach}
	</body>
</bento>