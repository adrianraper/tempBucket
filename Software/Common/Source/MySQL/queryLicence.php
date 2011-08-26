<?php

function getLicenceSlot( &$vars, &$node ) {
	global $Db;
	global $Licence;
	
	$liT = $vars['LICENCES'];
        if ($liT < 1) {
		return 1;
        }
	//print 'licences allowed=' .$liT .'    ';
	$sT = $Licence->countLicences($vars, 0, 0);
        if ($sT > 0) return 0;

        $liN = $Licence->countLicences($vars, 1, 0);	
	//print 'licences used=' .$liN .'    ';
        if ($liN < $liT) 
            return insertLicenceRecord(  $vars, $liN, $liT, $node );

        $dateadd = $Db->sqlDateAdd($Db->now(), $Licence->delay);
        $dateconv = $Db->sqlDateConvert($dateadd, 'jn');
	//print 'date='.$dateadd;	
        $ord = $Licence->countLicences($vars, 2, $dateadd);
	//print 'old licences=' .$ord .'    ';	
	if ($ord > 0) {
		$returnCode = $Licence->deleteLicencesOld(  $vars, $dateadd );
		$liN -= $ord;
		$node .= "<warning>$ord licence(s) revoked</warning>";
		if ($liN < $liT)
			return insertLicenceRecord(  $vars, $liN, $liT, $node );
		else {
			$node .= "<err code='201'>no free licences ($liN)</err>";
			return 1;
		}
        } else {
		$node .= "<err code='201'>no free licences ($liN)</err>";
		return 1;
        }
}

function insertLicenceRecord( &$vars, $liN, $liT, &$node) {
	global $Db;
	global $Licence;
	//print 'in iLR with liT=' .$liT;

	$time = $Db->now();
	$returnCode = $Licence->insertLicence(  $vars, $time );
	//print 'rc=' . $returnCode;
        $id = $Licence->selectInsertedLicence(  $vars, $time );
        if ( $id > 0 ) {
		$liN++;
		$host = $Db->dbPrepare($_SERVER['REMOTE_ADDR']);
		$node .= "<licence host='$host' ID='$id' note='$liN of $liT' />";
		return 0;
        } else {
		$node .= "<err code='202'>failed to insert licence record</err>";
		return 1;
        }
}

function updateLicence( &$vars, &$node ) {
	global $Db;
	global $Licence;
	
	$returnCode = $Licence->updateLicence($vars );
	
	if ($Db->affected_rows > 0) {
		$id = $vars['LICENCEID'];
		$node .= "<licence id='" .$id . "'>updated</licence>";
		return 0;
	} else {
		$node .= "<err code='205'>your licence is not being updated</err>";
		return 1;
	}	
}

function dropLicence( &$vars , &$node) {
	global $Db;
	global $Licence;

	$id = $vars['LICENCEID'];
	$returnCode = $Licence->deleteLicencesID($vars);

	//print"affected=" . $Db->affected_rows;
        if ($Db->affected_rows > 0) {
		$node .= "<licence id='$id'>dropped</licence>";
		return 0;
        } else {
		$node .= "<err code='205'>your licence is not being updated</err>";
		return 1;
        }
}

function failLicenceSlot( &$vars, &$node ) {
	global $Db;
	global $Licence;
	$returnCode = $Licence->insertFail( $vars );
	$node .= "<note>licence failure recorded</note>";
	return 0;
}

?>
