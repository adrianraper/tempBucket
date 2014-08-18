<?php
/*
 * Smarty plugin
 * -------------------------------------------------------------
 * File:     modifier.fixexercisespaces.php
 * Type:     modifier
 * Name:     fixexercisespaces
 * Purpose:  surround exercise form elements with non breaking spaces in order to work around long-standing bento bug
 * -------------------------------------------------------------
 */
function smarty_modifier_fixexercisespaces($string) {
    return preg_replace("/(<input.*?\/>)/", "&#xA0;$1&#xA0;", $string);
}