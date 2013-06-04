<?php

class Session {
	
	private static $name;
	
	public static function setSessionName($name) {
		self::$name = $name;
	}

	// gh#341
	public static function getSessionName() {
		return self::$name;
	}

	public static function set($key, $value) {
		$_SESSION[self::$name."_".$key] = $value;
	}
	
	public static function get($key) {
		return $_SESSION[self::$name."_".$key];
	}
	
	public static function is_set($key) {
		return isset($_SESSION[self::$name."_".$key]);
	}
	
	public static function clear() {
		foreach ($_SESSION as $key => $value) {
			if (preg_match("/^".self::$name."_/",$key)) {
				unset($_SESSION[$key]);
			}
		}
	}
	
	// gh#341
	public static function un_set($key) {
		if (isset($_SESSION[self::$name."_".$key]))
			unset($_SESSION[self::$name."_".$key]);
	}
	
}

