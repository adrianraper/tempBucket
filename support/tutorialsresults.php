<?php
session_start();
$current_subsite = "support"; 
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
		
		/*for ($i=0; $i<$size; $i++){
		
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
		}*/
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
			
			/*for ($i=0; $i<$size; $i++){
			
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
			}*/
			$count++;
			//if ($count == 5) break;
		}

	}


?>





<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="/images/favicon.ico" type="image/x-icon" />

<title>Clarity English language teaching online | Support | Licence and delivery</title>

<link rel="stylesheet" type="text/css" href="../css/global.css"/>
<link rel="stylesheet" type="text/css" href="../css/support.css"/>               

<!--Jquery library-->
<script type="text/javascript" src="/script/jquery.js"></script>
<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.min.js"></script>
<script type="text/javascript" src="/script/jquery.easing.min.js"></script>


<?php if(count($qid) <= 1) { ?>
                  <?php }else{ ?>
       
                 

<!--Jquery Pagination-->
<script type="text/javascript" src="/script/jquery.pages.js"></script>
<script type="text/javascript">
 /* when document is ready */
  $(function() {

    /* initiate plugin */
	var itemsPerPage = 5;
	if (getCookie("itemsPerPage")){
		itemsPerPage = getCookie("itemsPerPage");
		document.getElementById("itemsPerPage").value = itemsPerPage;
	}else{
		setCookie("itemsPerPage", 5, 365);
	}
	
    $("div.pagebox").jPages({
      containerID : "accordion",
      	perPage : <?php if(isset($_COOKIE["itemsPerPage"])){ echo($_COOKIE["itemsPerPage"]);}else{echo(5);} ?>,
		first     : "",
		previous    : "previous",
		next        : "next",
		last        : "",
		midRange  : 15
    });

    /* on select change */
    $("select").change(function(){
      /* get new nº of items per page */
	  
      itemsPerPage = parseInt( $(this).val() );
	  setCookie("itemsPerPage", itemsPerPage, 365);
	  
	  for (i=1; i<= (<?php echo(count($qid)); ?>/5); i++){
		document.getElementById("ans"+(i*5)).className = "box";
	  }
	  
	  for (i=1; i<= (<?php echo(count($qid)); ?>/itemsPerPage); i++){
		document.getElementById("ans"+(i*itemsPerPage)).className = "box_last";
	  }
	  
	  /* destroy jPages and initiate plugin again */
      $("div.pagebox").jPages("destroy").jPages({
        containerID   : "accordion",
        perPage       : itemsPerPage,
		first     : "",
		previous    : "previous",
		next        : "next",
		last        : "",
		minHeight : false,
		midRange  : 15
      });

    });

  });
  
	function getCookie(c_name){
		var c_value = document.cookie;
		var c_start = c_value.indexOf(" " + c_name + "=");
		if (c_start == -1){
			c_start = c_value.indexOf(c_name + "=");
		}
		if (c_start == -1){
			c_value = null;
		}else{
			c_start = c_value.indexOf("=", c_start) + 1;
			var c_end = c_value.indexOf(";", c_start);
			if (c_end == -1){
				c_end = c_value.length;
			}
			c_value = unescape(c_value.substring(c_start,c_end));
		}
		return c_value;
	}
	
	function setCookie(c_name,value,exdays){
		var exdate=new Date();
		exdate.setDate(exdate.getDate() + exdays);
		var c_value=escape(value) + ((exdays==null) ? "" : "; expires="+exdate.toUTCString());
		document.cookie=c_name + "=" + c_value;
	}
</script>
<?php } ?>  

<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-873320-12']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

</head>


<body id="support">
<?php $currentSelection="support"; ?>
<?php $supportSelection="tutorials"; ?>

<div id="container_outter">
<?php include  ($_SERVER['DOCUMENT_ROOT'].'/include/header.php') ; ?>

	<div id="menu_program"><?php include ( 'menu.php' ); ?></div>
     <div id="container_support">
     <div id="searchtop_container">
               	  <div class="search_bar_small">
                        <div class="search_bar_small_type">
                        <form id="form2" method="post" class="searchform">
                          <input type='text' value="<?php if(isset($search)) echo($search);?>"  name="search" id="top_search" class="search_field_small"/>
                          <input type="button" name="" class="search_clear_small"  onclick="document.getElementById('top_search').value = '';"/>
                           <input type="submit" value="Search" style="display:none;" />
                        </form>
                        <div class="clear"></div>
                        </div>
                  </div>
     
       </div>
       <div class="enquirybox">
       	 <div class="top">
               <span class="title">Tutorials</span>
               
                <?php if(count($qid) <= 1) { ?>
                  <?php }else{ ?>
               <div id="qnaclose"></div>
               <div id="qnaopen"></div>
                 <?php } ?>             
       	 </div>
            <div class="subcontent tutorials">
                 <div class="content">
                 
                  <?php if(count($qid) <= 1) { ?>
                  <?php }else{ ?>
                 
                 <form>
        <label>Questions per page: </label>
        <select id="itemsPerPage">
							  <option value="5">5</option>
							  <option value="10">10</option>
							
							  <option value="20">20</option>
							</select>
      </form>
        <?php } ?>
                 
 
        
        
        
                 
		<div id="questionsbox">
           <div id="accordion">
            <input name="CountValue" type="hidden" value="<?php echo(count($qid)); ?>" id="CountValue" />
           
           
           		<?php if(count($qid) < 1) { ?>
                  <div class="noresults_tips">
                        	<p>There are no results to be shown.</p>

                            <p>Please click <a href="licence.php" class="nolink">here</a> to go back to the Licence and delivery page.</p>
             </div>
                  	<?php } ?>	
                  
                    
               
                    
                     <?php for ($i=0; $i<count($qid); $i++){?>
									
					<?php if ($i == (count($qid)-1) or $i%5 == 4){ ?>
					<div id='ans<?php echo($i+1) ?>' class="box_last">
					<?php }else{ ?>
					<div class="box">
					<?php } ?>
                     <h3 class="ui-accordion-header"><?php echo(($i+1) . ". " . $question[$i]); ?></h3>
                        
                        <div class="substring">
						 <?php 
							$temp = str_replace("<br />", "/n", $answer[$i]);
							$temp = strip_tags($temp);
							if (strpos($temp, " ", 100) != false){
								echo str_replace("/n", "<br />", substr($temp, 0, strpos($temp, " ", 100)));
								echo "...";
							}else{
								echo str_replace("/n", "<br />", $temp);
							}
						?>
						</div>
                        
                        <div class="substring">
						 <?php 
							$temp = str_replace("<br />", "/n", $answer[$i]);
							$temp = strip_tags($temp);
							if (strpos($temp, " ", 100) != false){
								echo str_replace("/n", "<br />", substr($temp, 0, strpos($temp, " ", 100)));
								echo "...";
							}else{
								echo str_replace("/n", "<br />", $temp);
							}
						?>
						</div>
                        
                        <div style="display:none;"><?php echo $answer[$i]; ?></div>
                    </div>
                  
                    <?php } ?>
									
									
									
									
									
									
                        </div>
                   
             </div>
             
             </div>

 <?php if(count($qid) <= 1) { ?>
                  <?php }else{ ?>

                
      		<div class="pagebox_pos">
                <div class="pagebox_float">
                <div class="pagebox">
                	
              
                	
                
                </div>
                </div>
                </div>
                  <?php } ?>
                
           </div>
 <div class="btm"></div>
  <script type="text/javascript" src="/script/support_qna_customize.js"></script>
</div>
    </div>
     <?php include 'common/searchbottom.php' ?>
</div>
<?php include ($_SERVER['DOCUMENT_ROOT'].'/include/footer_plain.php' ); ?>

</body>
</html>