<?php
	/**
	 * Used to put the user's name into a cached template
	 * Actually not using this now as can get similar feature from registering a function instead.
	 * {insert name="getUserName" uname=$user->name|capitalize}
	 */
	function smarty_insert_getUserName($params, & $smarty) {
		// Before any template that uses this insert plugin is called, make sure you set this global variable.
		// Then the template can be cached, but the name will be picked afresh.
		// You do need to be sure that you are not fetching templates simultaneosluy for different people.
		global $thisUserName;
		return $thisUserName;
	}
?>