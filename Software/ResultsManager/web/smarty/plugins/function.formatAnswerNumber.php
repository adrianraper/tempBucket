<?php
	/**
	 * Used to add question or options numbers based on a particular style
	 * The style names are from Flash TLF rather than css.
	 */
	function smarty_function_formatAnswerNumber($params, $smarty) {
		switch ($params['format']) {
			// A, B, C
			case 2:
				$answerStyle = 'upperLatin';
				break;
			// 1, 2, 3
			case 1:
				$answerStyle = 'decimal';
				break;
			// i, ii, iii
			case 4:
				$answerStyle = 'lowerRoman';
				break;
			// Chinese
			case 5:
				$answerStyle = 'cjkHeavenlyStem';
				break;
			// bullet
			case 6:
				$answerStyle = 'disc';
				break;
			// none
			case 7:
				$answerStyle = 'none';
				break;
			// a, b, c
			default:
				$answerStyle = 'lowerLatin';
				break;
		}
		return $answerStyle;
	}
	
