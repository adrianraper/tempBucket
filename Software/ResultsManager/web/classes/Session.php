<?php

class Session {
	
	static $name;
	
	public static function setSessionName($name) {
		//NetDebug::trace('session.set.name='.$name);
		Session::$name = $name;
	}

	public static function set($key, $value) {
		$_SESSION[Session::$name."_".$key] = $value;
	}
	
	public static function get($key) {
		return $_SESSION[Session::$name."_".$key];
	}
	
	public static function is_set($key) {
		return isset($_SESSION[Session::$name."_".$key]);
	}
	
	public static function clear() {
		//NetDebug::trace('session.clear.name='.Session::$name);
		foreach ($_SESSION as $key => $value) {
			if (preg_match("/^".Session::$name."_/",$key)) {
				//NetDebug::trace('session.clear.key='.$key);
				unset($_SESSION[$key]);
			}
		}
	}

}
?>
