<?php 

require_once('../db_login.php');
if (isset($_REQUEST['qid']) and $_REQUEST['action']=="load"){
	$qid = intval($_REQUEST['qid']);
	$sql = "SELECT * FROM T_QuestionAnswer WHERE F_QID = ?";
	$resultset = $db->Execute($sql,array($qid));
	if (!$resultset) {
		$errorMsg = $db->ErrorMsg();
	} else {
		if ($resultset->RecordCount()>0) {
			$question = $resultset->fields['F_Question'];
			$answer = $resultset->fields['F_Answer'];
			$priority = $resultset->fields['F_Priority'];
			$category = $resultset->fields['F_Categories'];
		}
	}
	$resultset->Close();
	
	$sql = "SELECT * FROM T_QuestionAnswerTag WHERE F_QID = ?";
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
	$resultset->Close();
}


	
	
if ($_REQUEST['action']=="save"){

	$question = $_REQUEST['question'];
	$answer = $_REQUEST['answer'];
	$tag = $_REQUEST['tag'];
	$priority = $_REQUEST['priority'];
	$qid = intval($_REQUEST['qid']);
	$category = $_REQUEST['category'];
	
	$sql = "UPDATE T_QuestionAnswer SET F_Question=?, F_Answer=?, F_Priority=?, F_Categories=? WHERE F_QID = ?";
	$resultset = $db->Execute($sql,array($question, $answer, $priority, $category, $qid));
	
	$sql = "DELETE FROM T_QuestionAnswerTag WHERE F_QID = ?";
	$resultset = $db->Execute($sql,$qid);
	$tags = explode("<br />",$tag);
	
	$tag="";
	$sql = "INSERT INTO T_QuestionAnswerTag (F_QID, F_Tag, F_Weight) VALUES (?,?,?)";
	foreach ($tags as $value) {
		$tagcontents = explode(",",$value);
		if (strlen(trim($tagcontents[0]))<2) continue;
		if (trim($tagcontents[1])<1)
			$tagcontents[1]=1;
		if (trim($tagcontents[1])>5)
			$tagcontents[1]=5;
		$resultset = $db->Execute($sql,array($qid, trim($tagcontents[0]), trim($tagcontents[1])));
		$tag = $tag . trim($tagcontents[0]) . "," . trim($tagcontents[1]) . "<br />";
	}
	
	$resultset->Close();
}
if ($_REQUEST['action']=="new"){
	
	$question = $_REQUEST['question'];
	$answer = $_REQUEST['answer'];
	$tag = $_REQUEST['tag'];
	$priority = $_REQUEST['priority'];
	$category = $_REQUEST['category'];
	
	
	$sql = "INSERT INTO T_QuestionAnswer (F_Question, F_Answer, F_Priority, F_Categories) VALUES (?,?,?,?)";
	$resultset = $db->Execute($sql,array($question, $answer, $priority, $category));
	$qid = $db->Insert_ID();
	
	$tags = explode("<br />",$tag);
	
	$tag="";
	$sql = "INSERT INTO T_QuestionAnswerTag (F_QID, F_Tag, F_Weight) VALUES (?,?,?)";
	foreach ($tags as $value) {
		$tagcontents = explode(",",$value);
		if (strlen(trim($tagcontents[0]))<2) continue;
		if (trim($tagcontents[1])<1)
			$tagcontents[1]=1;
		if (trim($tagcontents[1])>5)
			$tagcontents[1]=5;
		$resultset = $db->Execute($sql,array($qid, trim($tagcontents[0]), trim($tagcontents[1]))); 
		$tag = $tag . trim($tagcontents[0]) . "," . trim($tagcontents[1]) . "<br />";
	}
	$resultset->Close();
}

	
	
	
	//echo $_REQUEST['tag'] . "<br />";




?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon" />
<title>Clarity Support Question and Answer Editor</title>

<script type="text/javascript">

function loadQestionAndAnswerbyID(){
	if (document.getElementById("qid").value != "" && !isNaN(document.getElementById("qid").value)){
		document.getElementById("action").value = "load";
		document.getElementById("form1").submit();
	}else{
		alert("Please input an integer only!");
	}
}

function resetAll(){
	document.location = "./QuestionAndAnswerEditor.php";
}


function saveQestionAndAnswer(){
		document.getElementById("question").value = document.getElementById("question").value.replace(/\r\n|\r|\n/g,"<br />");
		document.getElementById("answer").value = document.getElementById("answer").value.replace(/\r\n|\r|\n/g,"<br />");
		document.getElementById("tag").value = document.getElementById("tag").value.replace(/\r\n|\r|\n/g,"<br />");
		document.getElementById("qid").disabled = false;
		var temp = "";
		if (document.getElementById("category1").checked) temp = temp + "1,";
		if (document.getElementById("category2").checked) temp = temp + "2,";
		if (document.getElementById("category3").checked) temp = temp + "3,";
		if (document.getElementById("category4").checked) temp = temp + "4,";
		if (document.getElementById("category5").checked) temp = temp + "5,";
		if (document.getElementById("category6").checked) temp = temp + "6,";
		if (document.getElementById("category7").checked) temp = temp + "7,";
		if (document.getElementById("category8").checked) temp = temp + "8,";
		if (document.getElementById("category9").checked) temp = temp + "9,";
		document.getElementById("category").value = temp.substring(0, temp.length-1);
		if (document.getElementById("action").value != "new")
			document.getElementById("action").value = "save";
		document.getElementById("form1").submit();
}


function newQestionAndAnswer(){
	document.getElementById("qid").disabled = true;
	document.getElementById("btn_load").disabled = true;
	document.getElementById("btn_new").disabled = true;
	document.getElementById("question").disabled = false;
	document.getElementById("answer").disabled = false;
	document.getElementById("tag").disabled = false;
	document.getElementById("priority").disabled = false;
	document.getElementById("btn_save").disabled = false;
	document.getElementById("btn_reset").disabled = false;
	document.getElementById("action").value = "new";
}

function startup(){
	document.getElementById("qid").value = "<?php echo(isset($qid)?$qid:''); ?>";
	document.getElementById("priority").value  = "<?php echo(isset($priority)?$priority:''); ?>";
	document.getElementById("question").value = document.getElementById("question").value.replace(/\<br \/\>/g,'\n');
	document.getElementById("answer").value = document.getElementById("answer").value.replace(/\<br \/\>/g,'\n');
	document.getElementById("tag").value = document.getElementById("tag").value.replace(/\<br \/\>/g,'\n');
	document.getElementById("action").value = "";
	document.getElementById("category").value = "<?php echo(isset($category)?$category:''); ?>";
	var temp = document.getElementById("category").value.split(",");
	for (var i = 0; i < temp.length; i++) {
		document.getElementById("category"+temp[i]).checked = true;
	}
}

</script>

<style>

span{
	display: inline-block;
	width : 150px;
}

#qid {
	width :100px;
}

#question {
	width :500px;
	height : 40px;
}

#answer {
	width :500px;
	height : 200px;
}

#tag {
	width :500px;
	height : 140px;
}

#priority {
	width :150px;
}



</style>

</head>

<body onLoad="startup()">
     	
<h3>Question and Answer Editor</h3>
<form id="form1" method="post" action="QuestionAndAnswerEditor.php">
<span>Action:</span>
	<input type="hidden" value="" id="action" name="action" />
	<input type="button" id="btn_save" value="Save" onClick="saveQestionAndAnswer()" <?php echo(isset($qid)?'':'disabled'); ?> />
	<input type="button" id="btn_reset" value="Reset" onClick="resetAll()" <?php echo(isset($qid)?'':'disabled'); ?> />
<br/>
	<span>ID:</span>
	<input type='text' value="<?php if(isset($qid)) echo($qid);?>" id="qid" name="qid" <?php echo(isset($qid)?'disabled':''); ?>/>
	<input type="button" id="btn_load" value="Load" onClick="loadQestionAndAnswerbyID()" <?php echo(isset($qid)?'disabled':''); ?>/>
	<input type="button" id="btn_new" value="New" onClick="newQestionAndAnswer()" <?php echo(isset($qid)?'disabled':''); ?>/>
	<br /><br />
	<span>Question:</span>
	<textarea id="question" name="question" <?php echo(isset($qid)?'':'disabled'); ?>><?php echo(isset($question)?$question:''); ?></textarea>
	<br /><br />
	<span>Answer:</span>
	<textarea id="answer" name="answer" <?php echo(isset($qid)?'':'disabled'); ?>><?php echo(isset($answer)?$answer:''); ?></textarea>
	<br /><br />
	<span >Tag:</span>
	<textarea id="tag" name="tag" <?php echo(isset($qid)?'':'disabled'); ?>><?php echo(isset($tag)?$tag:''); ?></textarea>
	<span ><b>Example:</b><br />SCORM,2<br />My LMS is SCORM-compliant - I would like to test that the Clarity programs can run with it.,5 </span>
	<br /><br />
	<span>Category:</span><input type="hidden" value="" id="category" name="category" />
	<input type="checkbox" name="category1" id="category1" value="1" />Troubleshooting<br />
	<span></span>
	<input type="checkbox" name="category2" id="category2" value="2" />License & Delivery<br />
	<span></span>
	<input type="checkbox" name="category3" id="category3" value="3" />Tutorial & Help<br />
	<span></span>
	<input type="checkbox" name="category4" id="category4" value="4" />Others<br /> 
	<span></span>
	<input type="checkbox" name="category5" id="category5" value="5" />Top Query 1<br /> 
	<span></span>
	<input type="checkbox" name="category6" id="category6" value="6" />Top Query 2<br /> 
	<span></span>
	<input type="checkbox" name="category7" id="category7" value="7" />Top Query 3<br /> 
	<span></span>
	<input type="checkbox" name="category8" id="category8" value="8" />Top Query 4<br /> 
	<span></span>
	<input type="checkbox" name="category9" id="category9" value="9" />Top Query 5<br /> 
	<br />
	<span>Priority Level:</span>
	<select id="priority" name="priority" <?php echo(isset($qid)?'':'disabled'); ?>>
		<option value="1">1 - Top Priority</option>
		<option value="2">2</option>
		<option value="3">3 - Service request</option>
		<option value="4">4 - Bug or known issues</option>
		<option value="5">5 - troubleshooting/problems</option>
	</select>

</form>
</body>
</html>
