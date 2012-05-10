<?php
/**
 * Add session handling using AWS dynamoDB for cross-server scaling
 */
// Include the SDK
// require_once($GLOBALS['common_dir'].'/awsphpsdk/sdk-1.5.4/sdk.class.php');

class Session {
	
	private static $name;
	
    public function __construct() {
    	
		// Instantiate an AWS DynamoDB client
		/*
		$dynamodb = new AmazonDynamoDB();
	
		// Instantiate, configure, and register the session handler
		$session_handler = $dynamodb->register_session_handler(array(
			'table_name'       => 'php_session_table',
			'lifetime'         => 3600,
		));
		session_start();
		*/
    }
    
	public static function setSessionName($name) {
		//NetDebug::trace('session.set.name='.$name);
		self::$name = $name;
	}

	public static function set($key, $value) {
		$_SESSION[self::$name."_".$key] = $value;
		//session_commit();
	}
	
	public static function get($key) {
		return $_SESSION[self::$name."_".$key];
	}
	
	public static function is_set($key) {
		return isset($_SESSION[self::$name."_".$key]);
	}
	
	public static function clear() {
		//NetDebug::trace('session.clear.name='.Session::$name);
		foreach ($_SESSION as $key => $value) {
			if (preg_match("/^".self::$name."_/",$key)) {
				//NetDebug::trace('session.clear.key='.$key);
				unset($_SESSION[$key]);
			}
		}
		//session_destroy();
	}

}

