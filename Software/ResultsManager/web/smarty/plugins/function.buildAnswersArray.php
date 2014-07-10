<?php
	/**
	 * Used to assign a, possibly, randomised array to a variable in a template
	 * TODO This is very clumsy 
	 */
	function smarty_function_buildAnswersArray($params, $smarty) {
		$baseArray = range(0, count($params['base'])-1);
		if ($params['randomise'])
			shuffle($baseArray);
		$smarty->assign('answersArray', $baseArray);
		return null;
	}
	
