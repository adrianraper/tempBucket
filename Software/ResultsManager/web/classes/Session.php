<?php

class Session {
	
	private static $name;
	
	public static function setSessionName($name) {
		//NetDebug::trace('session.set.name='.$name);
		self::$name = $name;
	}

	public static function set($key, $value) {
		//if (stristr($key, 'valid_'))
		//	$value = json_encode($value);
		//$_SESSION[self::$name."_".$key] = json_encode($value);
		$_SESSION[self::$name."_".$key] = $value;
		//NetDebug::trace("session.set.".self::$name."_".$key."=".json_encode($_SESSION[self::$name."_".$key]));
	}
	
	public static function get($key) {
		//if (stristr($key, 'valid_')) {
		//	return json_decode($_SESSION[self::$name."_".$key]);
		//} else {
			return $_SESSION[self::$name."_".$key];
		//}
	}
	
	public static function is_set($key) {
		//NetDebug::trace("session.isset.".self::$name."_".$key."=".isset($_SESSION[self::$name."_".$key]));
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
	}
}

