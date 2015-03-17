<?php

	require_once('../db_login.php');
	
	$inquire = $search = $_REQUEST['search'];
	error_log(date("Y-m-d H:i:s") . " search word(s):" . $inquire . "\n", 3, "./skyQA.log");

	if ($inquire == "all"){
		$sql = "SELECT * FROM T_QuestionAnswer";
		$resultset = $db->Execute($sql);
		if (!$resultset) {
			$errorMsg = $db->ErrorMsg();
		} else {
			if ($resultset->RecordCount()>0) {
				$size = $resultset->RecordCount();
				for ($i=0; $i<$size; $i++){
					$qid[$i] = $resultset->fields['F_QID'];
					$question[$i] = $resultset->fields['F_Question'];
					$answer[$i] = $resultset->fields['F_Answer'];
					$url[$i] = $resultset->fields['F_URL'];
					$priority[$i] = $resultset->fields['F_Priority'];
					$category[$i] = $resultset->fields['F_Categories'];
					$resultset->MoveNext();
				}
			}
		}
		$resultset->Close();
		
		for ($i=0; $i<$size; $i++){
		
			$sql = "SELECT * FROM T_QuestionAnswerTag WHERE F_QID = ?";
			$resultset = $db->Execute($sql,array($qid[$i]));
			if (!$resultset) {
				$errorMsg = $db->ErrorMsg();
			} else {
				$tag[$i] = "";
				while (!$resultset->EOF) {
					$tag[$i] = $tag[$i] . $resultset->fields['F_Tag'] . "," . $resultset->fields['F_Weight'] . "<br />";
					$resultset->MoveNext();
				}
				$tag[$i] = substr($tag[$i], 0, -2);
			}
			$resultset->Close();
		}
	}else if ($inquire != ""){
		$inquire = preg_replace("/[^a-zA-Z0-9\s]/", " ", $inquire);
		$needles=array(" about ", " above ", " after ", " again ", " against ", " all ", " am ", " an ", " and ", " any ", " are ", " aren t ", " as ", " at ", " be ", " because ", " been ", " before ", " being ", " below ", " between ", " both ", " but ", " by ", " can ", " can t ", " cannot ", " could ", " couldn t ", " did ", " didn t ", " do ", " does ", " doesn t ", " doing ", " don t ", " down ", " during ", " each ", " few ", " for ", " from ", " further ", " had ", " hadn t ", " has ", " hasn t ", " have ", " haven t ", " having ", " he ", " he d ", " he ll ", " he s ", " her ", " here ", " here s ", " hers ", " herself ", " him ", " himself ", " his ", " how ", " how s ", " i d ", " i ll ", " i m ", " i ve ", " if ", " in ", " into ", " is ", " isn t ", " it ", " it s ", " its ", " itself ", " let s ", " me ", " more ", " most ", " mustn t ", " my ", " myself ", " no ", " nor ", " not ", " of ", " off ", " on ", " once ", " only ", " or ", " other ", " ought ", " our ", " ours  ", " ourselves ", " out ", " over ", " own ", " same ", " shan t ", " she ", " she d ", " she ll ", " she s ", " should ", " shouldn t ", " so ", " some ", " such ", " than ", " that ", " that s ", " the ", " their ", " theirs ", " them ", " themselves ", " then ", " there ", " there s ", " these ", " they ", " they d ", " they ll ", " they re ", " they ve ", " this ", " those ", " through ", " to ", " too ", " under ", " until ", " up ", " very ", " was ", " wasn t ", " we ", " we d ", " we ll ", " we re ", " we ve ", " were ", " weren t ", " what ", " what s ", " when ", " when s ", " where ", " where s ", " which ", " while ", " who ", " who s ", " whom ", " why ", " why s ", " with ", " won t ", " would ", " wouldn t ", " you ", " you d ", " you ll ", " you re ", " you ve ", " your ", " yours ", " yourself ", " yourselves" );
		$inquire =str_ireplace($needles, " ", " ".$inquire." ");
		//echo $inquire;
		$inquire = str_replace("  ", " " ,$inquire);
		$inquires = split(" ", $inquire);
		$searchWord = "";
		$ids= array();
		foreach ($inquires as $value) {
			if (strlen($value)<2) continue;
			$searchWord = $searchWord . $value . " ";
			$sql = "SELECT * FROM T_QuestionAnswerTag WHERE F_Tag like ?";
			$resultset = $db->Execute($sql,array("%".$value."%"));
			if (!$resultset) {
				$errorMsg = $db->ErrorMsg();
			} else {
				if ($resultset->RecordCount()>0) {
					$size = $resultset->RecordCount();
					for ($i=0; $i<$size; $i++){
						if (isset($ids[$resultset->fields['F_QID']])){
							$ids[$resultset->fields['F_QID']] = $ids[$resultset->fields['F_QID']] + $resultset->fields['F_Weight'] * (strlen($value)/strlen($resultset->fields['F_Tag']));
						}else{
							$ids[$resultset->fields['F_QID']] = $resultset->fields['F_Weight'] * (strlen($value)/strlen($resultset->fields['F_Tag']));
						}
						$resultset->MoveNext();
					}
				}
			}
			
		}
		error_log(date("Y-m-d H:i:s") . " real search word(s): " . $searchWord . "\n", 3, "./skyQA.log");
		//$result = array_count_values($ids);
		$result = $ids;
		//var_dump($result);
		arsort($result);
		//var_dump($result);
		//$resultset->Close();
		error_log(date("Y-m-d H:i:s") . " search result: " . json_encode($result) . "\n", 3, "./skyQA.log");
		
		$count=0;
		foreach ($result as $key=>$value) {
			$sql = "SELECT * FROM T_QuestionAnswer WHERE F_QID = ?";
			$resultset = $db->Execute($sql,array($key));
			if (!$resultset) {
				$errorMsg = $db->ErrorMsg();
			} else {
				if ($resultset->RecordCount()>0) {
					$qid[$count] = $resultset->fields['F_QID'];
					$score[$count] = $value;
					$question[$count] = $resultset->fields['F_Question'];
					$answer[$count] = $resultset->fields['F_Answer'];
					$url[$count] = $resultset->fields['F_URL'];
					$priority[$count] = $resultset->fields['F_Priority'];
					$category[$count] = $resultset->fields['F_Categories'];
				}
			}
			$resultset->Close();
			
			for ($i=0; $i<$size; $i++){
			
				$sql = "SELECT * FROM T_QuestionAnswerTag WHERE F_QID = ?";
				$resultset = $db->Execute($sql,array($key));
				if (!$resultset) {
					$errorMsg = $db->ErrorMsg();
				} else {
					$tag[$count] = "";
					while (!$resultset->EOF) {
						$tag[$count] = $tag[$count] . $resultset->fields['F_Tag'] . "," . $resultset->fields['F_Weight'] . "<br />";
						$resultset->MoveNext();
					}
					$tag[$count] = substr($tag[$count], 0, -2);
				}
				$resultset->Close();
			}
			$count++;
		}

	}


?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon" />
<title>Clarity Support Question and Answer Searcher</title>
<link rel="stylesheet" type="text/css" href="../css/global.css"/>
<link rel="stylesheet" type="text/css" href="../css/support.css"/>               

<!--Jquery library-->
<script type="text/javascript" src="/script/jquery.js"></script>




</head>

<body id="support">
<?php $supportSelection="search"; ?>



<div id="container_outter">
<?php include  ($_SERVER['DOCUMENT_ROOT'].'/include/header.php') ; ?>

<div id="menu_program"><?php include ( 'menu.php' ); ?></div>
     <div id="container_inner">
    
    <h2>Question and Answer Searcher</h2>
    <form id="form1" method="post">
        <div id="search_bar">
        <input type='text' value="<?php if(isset($search)) echo($search);?>"  name="search" id="search_field" autofocus/>
        </div>
        
 
<script type="text/javascript">
    var input = document.getElementById("search_field");
    if ( !("autofocus" in input) ) {
        input.focus();
    }
</script>
        
        
        <input type="submit" value="Search" />
    </form>
    

    
    
    
    <?php for ($i=0; $i<count($qid); $i++){?>
    
    <div class="question">
        <a href="./QAAnswer.php?qid=<?php echo $qid[$i]; ?>" target="_blank"><?php echo($i+1 . ". " . $question[$i]); ?></a>
    </div>
    <br />
    <div class="answer">
        <?php 
            if (strpos($answer[$i], " ", 300) != false){
                echo substr($answer[$i], 0, strpos($answer[$i], " ", 300));
                echo "...";
            }else{
                echo $answer[$i];
            }
        ?>
    </div>
    
    <?php } ?>
    </div>
     
    
</div>

</body>
</html>