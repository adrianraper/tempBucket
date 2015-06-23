{assign var=exerciseType value=$xml->settings->exerciseType}
{assign var=questions value=$xml->questions->$exerciseType}

<bento xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<style type="text/css">
		<![CDATA[
		{literal}
		.bold {
			font-weight: bold;
		}
		
		.blue {
			color: #0066FF;
		}
		
		.red {
			color: #ff2052;
		}
		
		* {
		    box-sizing: border-box; /* this doesn't do anything in our application, but brings real CSS more into line with our box model so best to leave it in */
		    margin: 0;
		    padding: 0;
		    font-family: Verdana;
		}
		
		body {
		}
		
		section  * {
    		font-size: 12px;
    		line-height: 150%;
		}
		
		@media ios, android {
			section  * {
				font-size: 12px;
				line-height: 125%;
			}
		}
		
		section p {
		}

		.feedback p {
			line-height: 150%;
			padding-bottom: 0;
			padding-top: 0;
		}
		
		@media ios, android {
			.feedback p {
				line-height: 125%;
			}
		}
		
		.question { 
			display: table-row;
			margin-left: 0px;
			margin-bottom: -5px; /* This is a hack to remove a slight (consistent) vertical gap between questions */
			width: 100%;
		}
		
		.question > div {
			display: table-cell;
			padding: 4px;
			line-height: 150%; /* JL suggests 150% */
		}
		
		@media ios, android {
			.question > div {
				line-height: 125%; /* JL suggests 150% */
			}
		}
		
		.question > .question-number {
			/* Give the column a fixed width */
			width: 25px;
			padding-top: 0px;
			padding-left: 0px;
			padding-right: 0px;
	
			/* Style the question number text */
			font-weight: bold;
	
			text-align: left;
		}
		
		.question > .question-text {
			/* A hacky solution to make the cell fill most of the width without having to change the rendering engine */
			width: 85%;
			padding-top: 0px;
		}
		
		.hanging-indent-popup { 
			display: table-row;
			margin-bottom: -5px; /* This is a hack to remove a slight (consistent) vertical gap between questions */
			width: 100%;
			padding-top: 5px;
			margin-left: 3px;
		}
		
		.hanging-indent-popup > div {
			display: table-cell;
			padding: 4px;
		}
		
		.hanging-indent-popup p {
			padding-bottom: 5px;
			padding-left: 5px;
			line-height: 125%;
		}
		
		.hanging-indent-popup > .bullet {
			width: 20px;
			font-weight: bold;
			text-align: left;
			padding-top: 4px; /* Hack to align number to top of text */
			margin-left: 3px;
		}
		
		@media ios, android {
			.hanging-indent-popup > .bullet {
				width: 30px;
			}
		}
		
		.hanging-indent-popup > .text {
		/* A hacky solution to make the cell fill most of the width without having to change the rendering engine */
			width: 92%;
			line-height: 125%;
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
		
		/* Add space after the correct answer - gh#1006 */
		input {
			gap-after-padding: 2;
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
					{foreach from=$question->answers item=answers name=answers}
						<{$exerciseType} source="{$answers.source}" block="q{$smarty.foreach.question.index}">
						{foreach from=$answers item=answer name=answer}
							<answer value="{$answer}" correct="{$answer.correct}" >
                                {foreach from=$question->feedback item=feedback name=feedback}
                                    {if $feedback|count_characters>0}
                                        <feedback source="fb{$smarty.foreach.question.index}" />
                                    {/if}
                                {/foreach}
                            </answer>
                        {/foreach}
						</{$exerciseType}>
					{/foreach}
				{/foreach}
			</questions>
		</script>
	</head>
	
	<body>
		<section id="body">
			<div>
				{foreach from=$questions item=question name=question}
				<div id="q{$smarty.foreach.question.index}" class="question">
					<div class="question-number">
						{$smarty.foreach.question.iteration}
					</div>
			    	<div class="question-text">
						{$question->question|fixexercisespaces}
					</div>
				</div>
				{/foreach}
			</div>
		</section>
        {foreach from=$questions item=question name=question}
            {foreach from=$question->feedback item=feedback name=feedback}
                {if $feedback|count_characters>0}
                    <section id="fb{$smarty.foreach.question.index}" class="feedback">
                        <p>{$feedback}</p>
                    </section>
                {/if}
            {/foreach}
        {/foreach}
    </body>
</bento>