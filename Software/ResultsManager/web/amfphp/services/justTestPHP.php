<?php
	function inCodes($codeArray, $item) {
		if ($item > 0)
			$codeArray[] = $item;
		return $codeArray;
	}
	function notInCodes($codeList, $item) {
		if ($item < 0)
			$codeArray[] = $item;
		return $codeArray;
	}
	
	$sql = 'select * from T_Accounts where F_RootID=163';
	$productCode = array(9,-33);
		if ($productCode) {
			if (!is_array($productCode))
				$productCode = explode(',',$productCode);
		} else if (!$forDMS) {
			$productCode = array(-2);
		}
		if ($productCode) {
			$sqlInList = array_reduce($productCode, 'inCodes');
			//echo 'in codes string='.implode(',',$sqlInList).'  ';
			$sqlNotInList = array_reduce($productCode, 'notInCodes', null);
			if ($sqlInList) $sql .= ' AND a.F_ProductCode in ('.implode(',',$sqlInList).')';
			if ($sqlNotInList) $sql .= ' AND a.F_ProductCode not in ('.implode(',',$sqlNotInList).')';
		}
	echo $sql;
	
flush();
exit();
