<?php
	require_once('../db_login.php');
	
	$qid = intval($_REQUEST['qid']);
	

	if ($qid != null){
		$sql = "SELECT * FROM T_QuestionAnswer WHERE F_QID = ?";
		$resultset = $db->Execute($sql,array($qid));
		if (!$resultset) {
			$errorMsg = $db->ErrorMsg();
			exit;
		} else {
			if ($resultset->RecordCount()>0) {
				$question = $resultset->fields['F_Question'];
				$answer = $resultset->fields['F_Answer'];
				//$priority = $resultset->fields['F_Priority'];
				//$category = $resultset->fields['F_Categories'];
			}
		}
		$resultset->Close();
		
		/*$sql = "SELECT * FROM T_QuestionAnswerTag WHERE F_QID = ?";
		$resultset = $db->Execute($sql,array($qid));
		if (!$resultset) {
			$errorMsg = $db->ErrorMsg();
		} else {
			$tag = "";
			while (!$resultset->EOF) {
				$tag = $tag . $resultset->fields['F_Tag'] . "," . $resultset->fields['F_Weight'] . "<br />";
				$resultset->MoveNext();
			}
			//$tag = substr($tag, 0, -2);
		}
		$resultset->Close();*/
		
		error_log(date("Y-m-d H:i:s") . " QID:" . $qid . " is read\n", 3, "./skyQA.log");
	}else{
		$question = null;
		$answer = null;
	}


?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon" />
<title>Clarity Support Search Answer</title>
</head>

<body onLoad="startup()">
     	
    
<h2>Question and Answer</h2><br />
<div>
<?php echo $question; ?>
</div>
<br />
<div>
<?php echo $answer; ?>
</div>
</body>
</html>