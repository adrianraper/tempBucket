<?php
/*
 * The Log_null class is a concrete implementation of the Log abstract
 * class that doesn't do anything with log requests. For use in production.
 * 
 * @author  Clarity
 */
class Log_null extends Log {
	
	function Log_null($name, $ident = '', $conf = array(), $level = PEAR_LOG_DEBUG) {
	}
	
	function setTarget($name) {
	}
}
