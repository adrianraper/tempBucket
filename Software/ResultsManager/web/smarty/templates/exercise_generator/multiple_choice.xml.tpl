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
			padding-top: 10px;
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
			padding-left: 15px;
			padding-right: 15px;
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
			
			margin-left: 15px;
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
			width: 30px;
			padding-top: 10px;
			padding-left: 0px;
			padding-right:5px;
	
			/* Style the question number text */
			font-weight: bold;
	
			/* Put a box around the question number area */
			border: 1px solid #F2F2F2;
			border-right-style: none;
			border-left-style: none;
			border-bottom-style: none;
	
			text-align: left;
		}
		
		.question > .question-text {
			/* A hacky solution to make the cell fill most of the width without having to change the rendering engine */
			width: 80%;
			padding-top: 10px;
			
			/* Put a top border above the question */
			border: 1px solid #F2F2F2;
			border-right-style: none;
			border-left-style: none;
			border-bottom-style: none;
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
		.answerList {
		{/literal}
			list-style-type: {formatAnswerNumber format=$xml->settings->answerNumbering};
		{literal}
			padding-left: 16px;
			text-indent: 0px;
			margin-left: 0px;
			line-height: 150%;
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
					<answer source="q{$smarty.foreach.question.index}a{$smarty.foreach.answer.index}" correct="{$answer.correct}">
					</answer>
					{/foreach}
				</{$exerciseType}>
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
						{formatQuestionNumber idx=$smarty.foreach.question.iteration format=$xml->settings->questionNumbering startFrom=$xml->settings->questionStartNumber}
					</div>
			    	<div class="question-text">
						{$question->question}
						<list class="answerList">
							{* for shuffled options make an array you can randomise and then step through *}
							{buildAnswersArray base=$question->answers->answer randomise=$xml->settings->shuffleAnswers}
							{foreach from=$answersArray item=answer}
							<li><a id="q{$smarty.foreach.question.index}a{$answer}">{$question->answers->answer[$answer]}</a></li>
							{/foreach}
						</list>
					</div>
				</div>
				{/foreach}
			</div>
		</section>
	</body>
</bento>