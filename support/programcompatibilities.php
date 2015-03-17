<?php 
session_start();
$current_subsite = "support"; 



?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="/images/favicon.ico" type="image/x-icon" />
<title>Clarity English language teaching online | Support | Program Compatibilities</title>
<meta name="classification" content="Education">
<meta name="robots" content="ALL">
<meta name="Description" content="Clarity runs several projects to support learning communities worldwide.">
<meta name="Keywords" content="online english, english teaching, Clarity English, ICT for English, IELTS preparation, authoring, ELT,  EFL, ESL, ESOL, CALL, ELT software, ELT program">

<link rel="stylesheet" type="text/css" href="../css/global.css"/>
<link rel="stylesheet" type="text/css" href="../css/support.css"/>     
<link rel="stylesheet" type="text/css" href="../css/programcampatibilities.css"/>
<link rel="stylesheet" type="text/css" href="../css/programcampatibilities_print.css" media="print"/>


<link rel="stylesheet" type="text/css" href="/css/isotope.css"/>     


<!--Jquery library-->
<script type="text/javascript" src="/script/jquery.js"></script>
<!--Sorting-->
<script type="text/javascript" src="/script/jquery.isotope.min.js"></script>
<!--Select Menu easinng-->
<script type="text/javascript" src="/script/jquery.easing.min.js"></script>
<!-- Menu easinng: include Google's AJAX API loader -->
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1/jquery-ui.min.js"></script>

<script type="text/javascript">
$(function(){
  
  var $container = $('.program_box'),
      $checkboxes = $('.name_box input');
  
  $container.isotope({
    itemSelector: '.item'
  });
  
  $checkboxes.change(function(){
  	  	$('#ShowSelected').css('display', 'block');
	    var filters = [];
    // get checked checkboxes values
    $checkboxes.filter(':checked').each(function(){
      filters.push( this.value );

    });
    // ['.red', '.blue'] -> '.red, .blue'
    filters = filters.join(', ');

  $('#ShowSelected').click(function(){
  		$('#ShowAll').css('display', 'block');
    $container.isotope({ filter: filters });	

	$('html,body').scrollTop(0);
  });
   
  $('#ShowAll').click(function(){
       $container.isotope({filter: ''});
       //filters = "";
	  });
  });




$("#Print").click(function () {
  	if (navigator.appName == 'Microsoft Internet Explorer') window.print(delay*1000);
        else window.print();
  });
    
});
</script>

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

<body id="support_comp">
<?php $currentSelection="support"; ?>
<?php $supportSelection="troubleshoot"; ?>

	<div id="printbanner"><img src="../images/support/print_header.jpg" alt="ClarityEnglish" align="middle" /></div>



<div id="procomp_container_top">

	<div id="container">

        <div class="printhide"><?php include  ($_SERVER['DOCUMENT_ROOT'].'/include/header.php') ; ?></div>
    
    	<div class="printhide"><div id="menu_program"><?php include ( 'menu.php' ); ?></div></div>
       
  
<div id="procomp_topbox">
            	
           
            	  <table width="978" border="0" cellspacing="0" cellpadding="0" id="procomp">
           
                  <tr>
                    <td width="344" valign="middle"><h1>Program Compatibilities</h1></td>
                  <td width="272">
                        <table width="272" border="0" cellspacing="0" cellpadding="0">
                  <tr>
                    <td height="35" colspan="7" valign="middle" background="../images/support/comp_sys_title_dark.jpg">
                    	<p class="sector_title">Network / Standalone</p>                     </td>
                    </tr>
                  <tr>
                    <td height="1" colspan="7"></td>
                    </tr>
                  <tr valign="middle">
                    <td width="68" height="55" bgcolor="#7C914C"><p class="sector_txt">Win<br />Vista</p></td>
                    <td width="1"></td>
                    <td width="67" bgcolor="#4A442A" ><p class="sector_txt">Win 7</p></td>
                    <td width="1"></td>
                    <td width="67" bgcolor="#366092"><p class="sector_txt">Win 8 <sup>&Dagger;</sup></p></td>
                    <td width="1"></td>
                    <td width="67" bgcolor="#E26C0A"><p class="sector_txt">Mac<br />OS</p></td>
                  </tr>
                  <tr>
                    <td colspan="7"  height="1"></td>
                    </tr>
                </table>                    </td>
                    <td width="3"></td>
                  <td width="204">
                    <table width="204" border="0" cellspacing="0" cellpadding="0">
                  <tr>
                    <td height="35" colspan="5" valign="middle" background="../images/support/comp_sys_title_mid.jpg">
                    	<p class="sector_title">Network / Server</p>                    </td>
                    </tr>
                  <tr>
                    <td height="1" colspan="5"></td>
                    </tr>
                  <tr valign="middle">
                    <td width="68" height="55" bgcolor="#8A2B29"><p class="sector_txt">Win Server 2003</p></td>
                    <td width="1"></td>
                    <td width="67" bgcolor="#263E7A"><p class="sector_txt">Win Server 2008 <sup>&dagger;</sup></p></td>
                    <td width="1"></td>
                    <td width="67" bgcolor="#0E7854"><p class="sector_txt">Win Server 2012 <sup>&dagger;</sup></p></td>
                  </tr>
                  <tr>
                    <td height="1" colspan="5"></td>
                    </tr>
                </table>                    </td>
                    <td width="3"></td>
              <td width="131">
                <table width="136" border="0" cellspacing="0" cellpadding="0">
                  <tr>
                    <td height="35" colspan="3" valign="middle" background="../images/support/comp_sys_title_light.jpg">
               	    <p class="sector_title">Online</p>                   </td>
                  </tr>
                  <tr>
                    <td height="1" colspan="3"></td>
                  </tr>
                  <tr valign="middle">
                    <td width="68" height="55" bgcolor="#78437B">
                    	<p class="sector_txt">Any<br />Browser ^</p>                    </td>
                    <td width="1"></td>
                    <td width="67" bgcolor="#645B3A">
                    	<p class="sector_txt">iPad/<br />Android<br />Tablet</p>                    </td>
                  </tr>
                </table>                    </td>
                    <td width="21"></td>
                  </tr>
                  </table>
                  
                  <div id="procomp_button">
<div  class="printhide">
                  		<div id="Print" class="btn">Print</div>
                        <div id="ShowSelected" class="btn">Show selected</div>
                        <div id="ShowAll" class="btn">Show all</div>
                      </div>
      </div>
                  
                  <div class="clear"></div>
                  
      </div>
                 
                 </div>
</div>
                
   <div id="procomp_container">
   	<div id="procomp_print">
                	<div id="procomp_container_content">
                        	
                          
                          	<div class="section_box">
                                <div class="program_title first">
                                	<h2>General English</h2>
                                    
                              </div>
                                 
                                
<div class="program_box">
                                
                                	<div class="item ar">
                                	<div class="name_box">
                                    <input id="ar" name="ar" value=".ar" class="comp-checkbox" type="checkbox" />
                                    <label for="ar" class="comp-label">Active Reading</label>
                                    </div>
                                    
                                    <div class="stand_box">
                                   		<div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                        <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                        
                                        <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
                                 	</div>
                          <div class="server_box">
                                  			<div class="dot win2003"><img src="../images/support/comp_dot_red.jpg" /></div>
                                            <div class="dot win2008"><img src="../images/support/comp_dot_blue_dark.jpg" /></div>
                                            <div class="dot win2012"><img src="../images/support/comp_dot_green_high.jpg" /></div>
                                  </div>
                                  <div class="online_box">
                                  	<div class="dot online"><img src="../images/support/comp_dot_wine.jpg" /></div>
                                  
                                  </div>
                              </div>
                              
                              <div class="item iss2">
                                	<div class="name_box">
                                    <input id="iss2" name="iss2" value=".iss2" class="comp-checkbox" type="checkbox" />
                                    <label for="iss2" class="comp-label">Issues in English 2 (v5.1)</label>
                                    </div>
                                    
                                    <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                       <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
                                            
                                    </div>
                                <div class="server_box">
                                	 <div class="dot win2012"><img src="../images/support/comp_dot_green_high.jpg" /></div>
                                </div>
                                <div class="online_box">
                               	  <div class="dot online"><img src="../images/support/comp_dot_wine.jpg" /></div>
                                </div>
                              </div>
                              
                              <div class="item lis1">
                                	<div class="name_box">
                                    <input id="lis1" name="lis1" value=".lis1" class="comp-checkbox" type="checkbox" />
                                    <label for="lis1" class="comp-label">Listen! 1</label>
                                    </div>
                                    
                                    <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                                            <div class="dot macos"><img src="../images/support/comp_dot_orange.jpg" /></div>
                                    </div>
                                <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                              
                              <div class="item lis2">
                                	<div class="name_box">
                                    <input id="lis2" name="lis2" value=".lis2" class="comp-checkbox" type="checkbox" />
                                    <label for="lis2" class="comp-label">Listen! 2</label>
                                    </div>
                                    
                                    <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                                            <div class="dot macos"><img src="../images/support/comp_dot_orange.jpg" /></div>
                                    </div>
                                <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                              
                              <div class="item mg">
                                	<div class="name_box">
                                    <input id="mg" name="mg" value=".mg" class="comp-checkbox" type="checkbox" />
                                    <label for="mg" class="comp-label">MindGame (v26)</label>
                                    </div>
                                    
                                <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                                </div>
                                    <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                              
                              <div class="item sf">
                  <div class="name_box">
                    <input id="sf" name="sf" value=".sf" class="comp-checkbox" type="checkbox" />
                    <label for="sf" class="comp-label">Spelling Fusion (v5.1)</label>
                  </div>
            	  <div class="stand_box">
                    <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
            	    <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                     <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
            	    
          	    </div>
            	  <div class="server_box"></div>
            	  <div class="online_box"></div>
          	  </div>
                              
                              <div class="item talkn">
                                	<div class="name_box">
                                    <input id="talkn" name="talkn" value=".talkn" class="comp-checkbox" type="checkbox" />
                                    <label for="talkn" class="comp-label">Talk Now!</label>
                                    </div>
                                    
                                    <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                       <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
                                            
                                            <div class="dot macos"><img src="../images/support/comp_dot_orange.jpg" /></div>
                                    </div>
                                <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                              
                              <div class="item tb9">
                                	<div class="name_box">
                                    <input id="tb9" name="tb9" value=".tb9" class="comp-checkbox" type="checkbox" />
                                    <label for="tb9" class="comp-label">Tense Buster V9</label>
                                    </div>
                                    
                                <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                                            <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
                                </div>
                                    <div class="server_box">
                       			  <div class="dot win2003"><img src="../images/support/comp_dot_red.jpg" /></div>
                                            <div class="dot win2008"><img src="../images/support/comp_dot_blue_dark.jpg" /></div>
                                            <div class="dot win2012"><img src="../images/support/comp_dot_green_high.jpg" /></div>
                                  </div>
                                <div class="online_box">
                               	  <div class="dot online"><img src="../images/support/comp_dot_wine.jpg" /></div>
                                </div>
                              </div>
                              <div class="clear"></div>
                              
                              </div>
                            </div>
                            
                            <div class="section_box">
                                <div class="program_title rest">
                                	<h2>Academic English &amp; Exams</h2>
                                     
                                  
                                 </div>
                                
                                <div class="program_box">
                                
                               	  <div class="item auk">
                                	<div class="name_box">
                                    <input id="auk" name="auk" value=".auk" class="comp-checkbox" type="checkbox" />
                                    <label for="auk" class="comp-label">Access UK</label>
                                    </div>
                                    
                                    <div class="stand_box">                                 	</div>
                          <div class="server_box">                                  </div>
                                  <div class="online_box">
                                  	<div class="dot online"><img src="../images/support/comp_dot_wine.jpg" /></div>
                                  </div>
                              </div>
                              
                              <div class="item rti2">
                                	<div class="name_box">
                                    <input id="rti2" name="rti2" value=".rti2" class="comp-checkbox" type="checkbox" />
                                    <label for="rti2" class="comp-label">Road to IELTS V2</label>
                                    </div>
                                    
                                <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                                            <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
                                </div>
                                    <div class="server_box">
                       			  <div class="dot win2003"><img src="../images/support/comp_dot_red.jpg" /></div>
                                            <div class="dot win2008"><img src="../images/support/comp_dot_blue_dark.jpg" /></div>
                                            <div class="dot win2012"><img src="../images/support/comp_dot_green_high.jpg" /></div>
                                  </div>
                                <div class="online_box">
                               	  <div class="dot online"><img src="../images/support/comp_dot_wine.jpg" /></div>
                                   <div class="dot tablet"><img src="../images/support/comp_dot_green_dark.jpg" /></div>
                                </div>
                              </div>
                              
                              <div class="item sss9">
                                	<div class="name_box">
                                    <input id="sss9" name="sss9" value=".sss9" class="comp-checkbox" type="checkbox" />
                                    <label for="sss9" class="comp-label">Study Skills Success V9</label>
                                    </div>
                                    
                                <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                                            <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
                                </div>
                                    <div class="server_box">
                       			  <div class="dot win2003"><img src="../images/support/comp_dot_red.jpg" /></div>
                                            <div class="dot win2008"><img src="../images/support/comp_dot_blue_dark.jpg" /></div>
                                            <div class="dot win2012"><img src="../images/support/comp_dot_green_high.jpg" /></div>
                                  </div>
                                <div class="online_box">
                               	  <div class="dot online"><img src="../images/support/comp_dot_wine.jpg" /></div>
                                </div>
                              </div>
                              
                                   <div class="clear"></div>
                              </div>
                          </div>
                            
                            <div class="section_box">
                                <div class="program_title rest">
                                	<h2>Pronunciation</h2>
                                    
                               
                                </div>
                                 
                                
                                <div class="program_box">
                                
                               	  <div class="item cp1">
                                	<div class="name_box">
                                    <input id="cp1" name="cp1" value=".cp1" class="comp-checkbox" type="checkbox" />
                                    <label for="cp1" class="comp-label">Clear Pronunciation 1 (Sounds)</label>
                                    </div>
                                    
                                    <div class="stand_box">
                                   		<div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                        <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                        
                                        <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
                                    </div>
                                    <div class="server_box">
                                  			<div class="dot win2003"><img src="../images/support/comp_dot_red.jpg" /></div>
                                            <div class="dot win2008"><img src="../images/support/comp_dot_blue_dark.jpg" /></div>
                                            <div class="dot win2012"><img src="../images/support/comp_dot_green_high.jpg" /></div>
                                  </div>
                                  <div class="online_box">
                                  	<div class="dot online"><img src="../images/support/comp_dot_wine.jpg" /></div>
                                  </div>
                              </div>
                              
                              <div class="item cp2">
                                	<div class="name_box">
                                    <input id="cp2" name="cp2" value=".cp2" class="comp-checkbox" type="checkbox" />
                                    <label for="cp2" class="comp-label">Clear Pronunciation 2 (Speech)</label>
                                    </div>
                                    
                                <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                                            <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
                                </div>
                                    <div class="server_box">
                       			  <div class="dot win2003"><img src="../images/support/comp_dot_red.jpg" /></div>
                                            <div class="dot win2008"><img src="../images/support/comp_dot_blue_dark.jpg" /></div>
                                            <div class="dot win2012"><img src="../images/support/comp_dot_green_high.jpg" /></div>
                                  </div>
                                <div class="online_box">
                               	  <div class="dot online"><img src="../images/support/comp_dot_wine.jpg" /></div>
                                </div>
                              </div>
                              
                              <div class="item cs">
                                	<div class="name_box">
                                    <input id="cs" name="cs" value=".cs" class="comp-checkbox" type="checkbox" />
                                    <label for="cs" class="comp-label">Connected Speech (v5.1)</label>
                                    </div>
                                    
                                <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                       <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
                                            
                                </div>
                                    <div class="server_box">
                                    	 <div class="dot win2012"><img src="../images/support/comp_dot_green_high.jpg" /></div>
                                    </div>
                                <div class="online_box">
                               	  <div class="dot online"><img src="../images/support/comp_dot_wine.jpg" /></div>
                                </div>
                              </div>
                              
                              <div class="item pp1">
                                	<div class="name_box">
                                    <input id="pp1" name="pp1" value=".pp1" class="comp-checkbox" type="checkbox" />
                                    <label for="pp1" class="comp-label">Pronunciation Power 1</label>
                                    </div>
                                    
                                    <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                                            <div class="dot macos"><img src="../images/support/comp_dot_orange.jpg" /></div>
                                </div>
                                <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                              
                              <div class="item pp2">
                                	<div class="name_box">
                                    <input id="pp2" name="pp2" value=".pp2" class="comp-checkbox" type="checkbox" />
                                    <label for="pp2" class="comp-label">Pronunciation Power 2</label>
                                    </div>
                                    
                                    <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                                            <div class="dot macos"><img src="../images/support/comp_dot_orange.jpg" /></div>
                                    </div>
                                <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                                   <div class="clear"></div>
                              </div>
                          </div>
                            
                            <div class="section_box">
                                <div class="program_title rest">
                                	<h2>Teacher's Tools</h2>
                                      
                              
                                 </div>
                               
                                
                                <div class="program_box">
                                
                               	  <div class="item ap">
                                	<div class="name_box">
                                    <input id="ap" name="ap" value=".ap" class="comp-checkbox" type="checkbox" />
                                    <label for="ap" class="comp-label">Author Plus</label>
                                    </div>
                                    
                                    <div class="stand_box">
                                   		<div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                        <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                        
                                        <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
                                    </div>
                                    <div class="server_box">
                                  			<div class="dot win2003"><img src="../images/support/comp_dot_red.jpg" /></div>
                                            <div class="dot win2008"><img src="../images/support/comp_dot_blue_dark.jpg" /></div>
                                            <div class="dot win2012"><img src="../images/support/comp_dot_green_high.jpg" /></div>
                                  </div>
                                  <div class="online_box">
                                  	<div class="dot online"><img src="../images/support/comp_dot_wine.jpg" /></div>
                                  </div>
                              </div>
                              
                              <div class="item rm2">
                                	<div class="name_box">
                                    <input id="rm2" name="rm2" value=".rm2" class="comp-checkbox" type="checkbox" />
                                    <label for="rm2" class="comp-label">Results Manager v2</label>
                                    </div>
                                    
                                <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                                            <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
                                </div>
                                    <div class="server_box">
                       			  		<div class="dot win2003"><img src="../images/support/comp_dot_red.jpg" /></div>
                                            <div class="dot win2008"><img src="../images/support/comp_dot_blue_dark.jpg" /></div>
                                            <div class="dot win2012"><img src="../images/support/comp_dot_green_high.jpg" /></div>
                                  </div>
                                <div class="online_box">
                              
                                </div>
                              </div>
                              
                              
                              
                              <div class="item rm3">
                               	<div class="name_box">
                                  <input id="rm3" name="rm3" value=".rm3" class="comp-checkbox" type="checkbox" />
                                  <label for="rm3" class="comp-label">Results Manager v3</label>
                                </div>
                                    
                                    <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                      
                                            <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
                                    </div>
                                <div class="server_box">
                           	      <div class="dot win2003"><img src="../images/support/comp_dot_red.jpg" /></div>
                                       <div class="dot win2008"><img src="../images/support/comp_dot_blue_dark.jpg" /></div>
                                       <div class="dot win2012"><img src="../images/support/comp_dot_green_high.jpg" /></div>
                                </div>
                                <div class="online_box">
                                	 	  <div class="dot online"><img src="../images/support/comp_dot_wine.jpg" /></div>
                                </div>
                              </div>
                              
                              <div class="item ccb">
                                	<div class="name_box">
                                    <input id="ccb" name="ccb" value=".ccb" class="comp-checkbox" type="checkbox" />
                                    <label for="ccb" class="comp-label">Clartiy Course Builder</label>
                                    </div>
                                    
                                    <div class="stand_box">                                    </div>
                                <div class="server_box"></div>
                                <div class="online_box">  <div class="dot online"><img src="../images/support/comp_dot_wine.jpg" /></div></div>
                              </div>
                                   <div class="clear"></div>
                              </div>
                            </div>
                            
                          <div class="section_box">
                                <div class="program_title rest">
                                	<h2>Business / Career</h2>
                                      
                             
                                 </div>
                            
                                
                                <div class="program_box">
                                
                               	  <div class="item busmeet">
                                	<div class="name_box">
                                    <input id="busmeet" name="busmeet" value=".busmeet" class="comp-checkbox" type="checkbox" />
                                    <label for="busmeet" class="comp-label">Business English: Meetings</label>
                                    </div>
                                    
                                    <div class="stand_box">
                                   		<div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                        <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                         <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
                                              <div class="dot macos"><img src="../images/support/comp_dot_orange.jpg" /></div>
                                      
                                    </div>
                                    <div class="server_box">
                                    	  <div class="dot win2012"><img src="../images/support/comp_dot_green_high.jpg" /></div>
                                    </div>
                                  <div class="online_box">                                  </div>
                              </div>
                              
                              <div class="item btgen">
                                	<div class="name_box">
                                    <input id="btgen" name="btgen" value=".btgen" class="comp-checkbox" type="checkbox" />
                                    <label for="btgen" class="comp-label">Business Territory 1: General</label>
                                    </div>
                                    
                                <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                  
                                </div>
                                    <div class="server_box">                                  </div>
                                <div class="online_box">                                </div>
                              </div>
                              
                              <div class="item bw">
                                	<div class="name_box">
                                    <input id="bw" name="bw" value=".bw" class="comp-checkbox" type="checkbox" />
                                    <label for="bw" class="comp-label">Business Writing</label>
                                    </div>
                                    
                                <div class="stand_box">
                                   
                                       <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                  <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                       
                                       <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
                                </div>
                                    <div class="server_box">
                                    	   <div class="dot win2003"><img src="../images/support/comp_dot_red.jpg" /></div>
                                       <div class="dot win2008"><img src="../images/support/comp_dot_blue_dark.jpg" /></div>
                                       <div class="dot win2012"><img src="../images/support/comp_dot_green_high.jpg" /></div>
                                    </div>
                                <div class="online_box">
                                	<div class="dot online"><img src="../images/support/comp_dot_wine.jpg" /></div>
                           	    </div>
                              </div>
                              
                              <div class="item cscs">
                                	<div class="name_box">
                                    <input id="cscs" name="cscs" value=".cscs" class="comp-checkbox" type="checkbox" />
                                    <label for="cscs" class="comp-label">Customer Service Communciation Skills</label>
                                    </div>
                                    
                                    <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                      
                                             <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
                                    </div>
                                <div class="server_box">
                                	   <div class="dot win2003"><img src="../images/support/comp_dot_red.jpg" /></div>
                                       <div class="dot win2008"><img src="../images/support/comp_dot_blue_dark.jpg" /></div>
                                       <div class="dot win2012"><img src="../images/support/comp_dot_green_high.jpg" /></div>
                                </div>
                                <div class="online_box"><div class="dot online"><img src="../images/support/comp_dot_wine.jpg" /></div></div>
                              </div>
                              
                              <div class="item engpro">
                                	<div class="name_box">
                                    <input id="engpro" name="engpro" value=".engpro" class="comp-checkbox" type="checkbox" />
                                    <label for="engpro" class="comp-label">English Pro</label>
                                    </div>
                                    
                                    <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                      
                                    </div>
                                <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                              
                              <div class="item efhs">
                                	<div class="name_box">
                                    <input id="efhs" name="efhs" value=".efhs" class="comp-checkbox" type="checkbox" />
                                    <label for="efhs" class="comp-label">English for Hotel Staff</label>
                                    </div>
                                    
                                    <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                      
                                             <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
                                    </div>
                                <div class="server_box">
                                	   <div class="dot win2003"><img src="../images/support/comp_dot_red.jpg" /></div>
                                       <div class="dot win2008"><img src="../images/support/comp_dot_blue_dark.jpg" /></div>
                                       <div class="dot win2012"><img src="../images/support/comp_dot_green_high.jpg" /></div>
                                </div>
                                <div class="online_box"><div class="dot online"><img src="../images/support/comp_dot_wine.jpg" /></div></div>
                              </div>
                              
                              <div class="item iyj">
                                	<div class="name_box">
                                    <input id="iyj" name="iyj" value=".iyj" class="comp-checkbox" type="checkbox" />
                                    <label for="iyj" class="comp-label">It's Your Job</label>
                                    </div>
                                    
                                    <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                      
                                             <div class="dot win8"><img src="../images/support/comp_dot_blue_light.jpg" /></div>
                                    </div>
                                <div class="server_box">
                                	   <div class="dot win2003"><img src="../images/support/comp_dot_red.jpg" /></div>
                                       <div class="dot win2008"><img src="../images/support/comp_dot_blue_dark.jpg" /></div>
                                       <div class="dot win2012"><img src="../images/support/comp_dot_green_high.jpg" /></div>
                                </div>
                                <div class="online_box"><div class="dot online"><img src="../images/support/comp_dot_wine.jpg" /></div></div>
                              </div>
                              
                              <div class="item letsbus" style="height:51px">
                                	<div class="name_box">
                                        <input id="letsbus" name="letsbus" value=".letsbus" class="comp-checkbox" type="checkbox" />
                                      <label for="letsbus" class="comp-label">Let's do Business (v5.1) <br />
                                        	<span class="comp-label-sub">(Negotiating, Telephoning, <br />Meetings, Presentations</span>                                      </label>
                                    </div>
                                    
                                    <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                          <span class="bit">(32 bit)</span>  
                                       <div class="dot macos"><img src="../images/support/comp_dot_orange.jpg" /></div>
                                    </div>
                                <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                                   <div class="clear"></div>
                            </div>
                          </div>
                            <div class="section_box">
                                <div class="program_title rest">
                                	<h2>Previously-sold products</h2>
                     
                                 </div>
                        
                                
                                <div class="program_box">
                                
                               	  <div class="item alie">
                                	<div class="name_box">
                                    <input id="alie" name="alie" value=".alie" class="comp-checkbox" type="checkbox" />
                                    <label for="alie" class="comp-label">Active Listening in English</label>
                                    </div>
                                    
                                    <div class="stand_box">
                                   		<div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                        <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                        <span class="bit">(32 bit)</span>  
                                    </div>
                                    <div class="server_box">                                  </div>
                                  <div class="online_box">                                  </div>
                              </div>
                              
                              <div class="item beat">
                                	<div class="name_box">
                                    <input id="beat" name="beat" value=".beat" class="comp-checkbox" type="checkbox" />
                                    <label for="beat" class="comp-label">Beat the Clock</label>
                                    </div>
                                    
                                <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                                </div>
                                <div class="server_box">                                </div>
                                <div class="online_box">                                </div>
                              </div>
                              
                              
                              
                              <div class="item crossc">
                                	<div class="name_box">
                                    <input id="crossc" name="crossc" value=".crossc" class="comp-checkbox" type="checkbox" />
                                    <label for="crossc" class="comp-label">Crossword Challenge</label>
                                    </div>
                                    
                                <div class="stand_box">
                                   
                                            <div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                                </div>
                                    <div class="server_box">                                </div>
                                <div class="online_box"></div>
                              </div>
                              
                              <div class="item errortr">
                                	<div class="name_box">
                                    <input id="errortr" name="errortr" value=".errortr" class="comp-checkbox" type="checkbox" />
                                    <label for="errortr" class="comp-label">Error Terror</label>
                                    </div>
                                    
                                <div class="stand_box">
                                    
                                    	<div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                                </div>
                                    <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                              
                           <div class="item hex">
                                	<div class="name_box">
                                    <input id="hex" name="hex" value=".hex" class="comp-checkbox" type="checkbox" />
                                    <label for="hex" class="comp-label">HEX LEX</label>
                                    </div>
                                    
                             <div class="stand_box">
                                    
                                    	<div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                             </div>
                                    <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                              
                              <div class="item laei">
                                	<div class="name_box">
                                    <input id="laei" name="laei" value=".laei" class="comp-checkbox" type="checkbox" />
                                    <label for="laei" class="comp-label">Live Action English Interactive (v1.5)</label>
                                    </div>
                                    
                                <div class="stand_box">
                                    
                                    	<div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                  
                                               <div class="dot macos"><img src="../images/support/comp_dot_orange.jpg" /></div>
                                </div>
                                    <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                              
                              <div class="item readup">
                                	<div class="name_box">
                                    <input id="readup" name="readup" value=".readup" class="comp-checkbox" type="checkbox" />
                                    <label for="readup" class="comp-label">Read up - Speed up</label>
                                    </div>
                                    
                                <div class="stand_box">
                                    
                                    	<div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                  <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                      <span class="bit">(32 bit)</span>                                </div>
                                    <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                              
                              <div class="item wordinv">
                                	<div class="name_box">
                                    <input id="wordinv" name="wordinv" value=".wordinv" class="comp-checkbox" type="checkbox" />
                                    <label for="wordinv" class="comp-label">Word Invaders</label>
                                    </div>
                                    
                                <div class="stand_box">
                                    
                                    	<div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                                </div>
                                    <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                              
                              <div class="item trixpv">
                                	<div class="name_box">
                                    <input id="trixpv" name="trixpv" value=".trixpv" class="comp-checkbox" type="checkbox" />
                                    <label for="trixpv" class="comp-label">Trix for Phrasal Verbs</label>
                                    </div>
                                    
                                <div class="stand_box">
                                    
                                    	<div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                                </div>
                                    <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                              
                              <div class="item voice">
                                	<div class="name_box">
                                    <input id="voice" name="voice" value=".voice" class="comp-checkbox" type="checkbox" />
                                    <label for="voice" class="comp-label">VOICEbooks</label>
                                    </div>
                                    
                                <div class="stand_box">
                                    
                                    	<div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                  <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                      <span class="bit">(32 bit)</span>                                </div>
                                    <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                              
                              <div class="item skyp">
                                	<div class="name_box">
                                    <input id="skyp" name="skyp" value=".skyp" class="comp-checkbox" type="checkbox" />
                                    <label for="skyp" class="comp-label">Sky Pronunciation</label>
                                    </div>
                                    
                                <div class="stand_box">
                                    
                                    	<div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                                </div>
                                    <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                              
                              <div class="item exegen">
                                	<div class="name_box">
                                    <input id="exegen" name="exegen" value=".exegen" class="comp-checkbox" type="checkbox" />
                                    <label for="exegen" class="comp-label">Exercise Generator (v26)</label>
                                    </div>
                                    
                                <div class="stand_box">
                                    
                                    	<div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                </div>
                                    <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                              
                              <div class="item trixeng">
                                	<div class="name_box">
                                    <input id="trixeng" name="trixeng" value=".trixeng" class="comp-checkbox" type="checkbox" />
                                    <label for="trixeng" class="comp-label">Trix for Business English</label>
                                    </div>
                                    
                                <div class="stand_box">
                                    
                                    	<div class="dot vista"><img src="../images/support/comp_dot_green_light.jpg" /></div>
                                      <div class="dot win7"><img src="../images/support/comp_dot_green_mid.jpg" /></div>
                                            
                                </div>
                                    <div class="server_box"></div>
                                <div class="online_box"></div>
                              </div>
                                   <div class="clear"></div>
                              </div>
                                <div class="clear"></div>
                      </div>
                          
                          <div id="procomp_bottom"></div>
                          
                          
                          
                          
                        
                          
                          </div>
                         
                          <div id="procomp_more">
                          	* A title without the circle label MAY work in that environment.<br />
                            <sup>&dagger;</sup> Win Server 2008 &amp; Win Server 2012: You will need to get a SONY SecuROM patch from Clarity.<br />
                            <sup>&Dagger;</sup> Win8: You will need to get an update from Clarity in order to use the program with Win 8 &amp; IE10. <br />
                             ^ Adobe Flash Player has to be installed in your browser. For Road to IELTS it must be v10.2 or higher.<br /><br />
                            
                            
                            If you have any questions, please send an email to <a href="mailto:support@clarityenglish.com?subject=Program Compatibilities enquiry" class="nolink">support@clarityenglish.com</a>.
                            
                          </div>
                          
                          
                        
                           
                        </div>
                          
                            <div class="printhide"><?php include 'common/searchbottom.php' ?></div>
<?php include ($_SERVER['DOCUMENT_ROOT'].'/include/footer_plain.php' ); ?>

                          
                  </div>
                  


</body>
</html>
