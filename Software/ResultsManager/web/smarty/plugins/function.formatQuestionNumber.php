<?php
	/**
	 * Used to add question or options numbers based on a particular style
	 */
	function smarty_function_formatQuestionNumber($params, $smarty) {
		$i = $params['idx'] + intval($params['startFrom']-1);
		switch ($params['format']) {
			// A, B, C
			case 2:
				$questionNumber = convertNumberToLetter($i);
				break;
			// a, b, c
			case 3:
				$questionNumber = strtolower(convertNumberToLetter($i));
				break;
			// i, ii, iii
			case 4:
				$questionNumber = convertNumberToRoman($i);
				break;
			// Chinese
			case 5:
				$questionNumber = convertNumberToChinese($i);
				break;
				// 1, 2, 3
			default:
				$questionNumber = $i;
				break;
		}
		return $questionNumber;
	}
	
	function convertNumberToLetter($idx) {
		return chr($idx + 64);
	}
	function convertNumberToRoman($idx) {
		switch ($idx) {
			case 1:
				return 'i';
			case 2:
				return 'ii';
			case 3:
				return 'iii';
			case 4:
				return 'iv';
			case 5:
				return 'v';
			case 6:
				return 'vi';
			case 7:
				return 'vii';
			case 8:
				return 'viii';
			case 9:
				return 'ix';
			case 10:
				return 'x';
			case 11:
				return 'xi';
			default:
				return $idx;
		}
			}
	
	function convertNumberToChinese($idx) {
		switch ($idx) {
			case 1:
				return '一';
			case 2:
				return '二';
			case 3:
				return '三';
			case 4:
				return '四';
			case 5:
				return '五';
			case 6:
				return '六';
			case 7:
				return '七';
			case 8:
				return '八';
			case 9:
				return '九';
			case 10:
				return '十';
			case 11:
				return '十一';
			default:
				return $idx;
		}
	}
