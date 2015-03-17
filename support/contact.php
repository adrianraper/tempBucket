<?php 
session_start();
$current_subsite = "support"; 

?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="/images/favicon.ico" type="image/x-icon" />
<title>Clarity English language teaching online | Support </title>
<meta name="classification" content="Education">
<meta name="robots" content="ALL">
<meta name="Description" content="Clarity runs several projects to support learning communities worldwide.">
<meta name="Keywords" content="online english, english teaching, Clarity English, ICT for English, IELTS preparation, authoring, ELT,  EFL, ESL, ESOL, CALL, ELT software, ELT program">

<link rel="stylesheet" type="text/css" href="../css/global.css"/>
<link rel="stylesheet" type="text/css" href="../css/support.css"/>
<link rel="stylesheet" type="text/css" href="../css/multiple-select-support.css"/>
<link rel="stylesheet" type="text/css" href="../css/chosen-support.css"/>      

<!--Jquery Library-->
<script type="text/javascript" src="/script/jquery.js"></script>
<!--Select Menu easinng-->
<script type="text/javascript" src="/script/jquery.easing.min.js"></script>
<!-- Menu easinng: include Google's AJAX API loader -->
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1/jquery-ui.min.js"></script>
<!-- For tab: include the Tools -->
<script src="http://cdn.jquerytools.org/1.2.7/full/jquery.tools.min.js"></script>
<!-- For form use-->
<script src="/script/jquery.multiple.select.js"></script>
<script type="text/javascript" src="script/supportEnquiry.js"></script>

<script>
// This adds 'placeholder' to the items listed in the jQuery .support object. 
jQuery(function() {
   jQuery.support.placeholder = false;
   test = document.createElement('input');
   if('placeholder' in test) jQuery.support.placeholder = true;
});
// This adds placeholder support to browsers that wouldn't otherwise support it. 
$(function() {
   if(!$.support.placeholder) { 
      var active = document.activeElement;
      $(':text').focus(function () {
         if ($(this).attr('placeholder') != '' && $(this).val() == $(this).attr('placeholder')) {
            $(this).val('').removeClass('hasPlaceholder');
         }
      }).blur(function () {
         if ($(this).attr('placeholder') != '' && ($(this).val() == '' || $(this).val() == $(this).attr('placeholder'))) {
            $(this).val($(this).attr('placeholder')).addClass('hasPlaceholder');
         }
      });
      $(':text').blur();
      $(active).focus();
      $('form:eq(0)').submit(function () {
         $(':text.hasPlaceholder').val('');
      });
   }
});
</script>

<script src="/script/chosen.jquery.min.js"></script>


<script type="text/javascript">

	$(function() {         
	$(".my_select_box").chosen ({
			width: "100%",
			disable_search: "true"
		});
	
	});
	
	$(function() {         
	$("input[name=licencetype]").change (function(){
			if($("#online").is(':checked')){
				$("#F_SerialNo").parent().parent().hide();
			}else{
				$("#F_SerialNo").parent().parent().show();
			}
		});
	
	});
	

	
	
	$(function() {
	
	$("#search_clear_mini").click(function(){
		$('#bottom_search').val('');
		$( "#search_box_mini").removeClass( "on" );
   		 
	});
	
			
			$('#bottom_search').on('input',function(e){
			 $( "#search_box_mini").addClass( "on" );
	 
				if ($('#search_box_mini').is(".on") &&  !$("#bottom_search").val() ) {
				 $( "#search_box_mini").removeClass( "on" );
			
			}
			
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

<body id="support">
<?php $currentSelection="support"; ?>
<?php $supportSelection="contact"; ?>

<div id="container_outter">

<?php include  ($_SERVER['DOCUMENT_ROOT'].'/include/header.php') ; ?>
    

     
    <div id="container">
    	<div id="menu_program"><?php include ( 'menu.php' ); ?></div>
            <div id="container_support">
            	<div id="container_support_contact">
                
               	  <div class="contactbox_top">
                        <div class="contactbox topleft">
                          <h1>Browse online support</h1>
                          <div id="search_box_mini_out">
                          	<div id="arrow">
                                	Search our Support site for quick answers, manuals, and in-depth technical articles. We hope you will be pleasantly surprised to find answers to your questions any time, day or night, 24/7.
                             </div>
                             <div id="search_box_mini">
                             	
                             	<div id="search_box_mini_position">
                                     <form id="form1" method="post" class="searchform" action="results.php">
                                          <input type='text' value="<?php if(isset($search)) echo($search);?>"  name="search" id="bottom_search" class="search_field_mini"/>
                                          <input name="" type="button" class="search_clear_small" id="search_clear_mini"/>
                                           <input type="submit" value="Search" style="display:none;" />
                                  </form>
                                        <div class="clear"></div>
                       		   </div>
                       	  </div>
                         	</div> 
                            
                            
                            
                    </div>
                        
                        <div class="contactbox topright">
                          <h1>Contact Clarity Support</h1>
                            
                            <div id="contactdetails">
                            	Please contact us if you have any questions about ClarityEnglish.
                                
                              
                              <div id="phone">
                                	+44 (0) 845 130 5627 (United Kingdom office) / <br />
                                    +852 2791 1787 (Hong Kong office)
                          
                              </div>
                              
                              <div id="mail">
                                	<a href="mailto:support@clarityenglish.com" class="nolink">support@clarityenglish.com</a><br />
                                    We will get back to you within one working day.
                              </div>
                            
                            </div>
                            
                        </div>
                    	<div class="clear"></div>
                  </div>
                    
                  	<div class="contactbox btm">
                   	  <h1>Submit a support ticket</h1>
                        
                        <div class="formbox_container">
                       
                       
   
                        
                        <form>
                        
                        <div class="point_line">
                            <div class="point">1</div>
                          <div class="title">Product Details</div>
                            <div class="clear"></div>
                         </div>
                         
                         <div class="section border">
                         
                         	<div id="checkbox_area">
                            
                              
                            
                            	<div class="selectbox">
                                  <input id="network" value="" class="version-checkbox" type="radio" name="licencetype"  />
                                  <label for="network" class="version-label network">Network CD licence</label>
                                </div>
                                
                                <div class="selectbox">
                                  <input id="online" value="" class="version-checkbox" type="radio" name="licencetype" />
                                  <label for="online" class="version-label online">Online licence</label>
                                </div>
                                
                              <div class="selectbox">
                                <input id="notsure" value="" class="version-checkbox" type="radio" name="licencetype"  />
                                <label for="notsure" class="version-label notsure">Not sure</label>
                              </div>
                                <div class="clear"></div>
                                 <div name="ErrMsgLicenceType" id="ErrMsgLicenceType" class="error" style="display:none;">Please let us know which licence you have.</div> 
                                
                                
                          	</div>
                         
                       	   <div class="fieldbox">
                                           <div class="fieldline_large">
                                             <select name="F_Program" id="F_Program" name="productlist" multiple="multiple" class="productlist">
                                               <option value="auk">Access UK</option>
                                               <option value="ar">Active Reading</option>
                                               <option value="ap">Author Plus</option>
                                               <option value="bw">Business Writing</option>
                                               <option value="ccb">Clarity Course Builder</option>
                                               <option value="cpone">Clear Pronunciation 1 (Sounds)</option>
                                               <option value="cptwo">Clear Pronunciation 2 (Speech)</option>
                                               <option value="cscs">CS Communciation Skills</option>
                                               <option value="efhs">English for Hotel Staff</option>
                                               <option value="iyj">It's Your Job</option>
                                   
                                               <option value="rm">Results Manager</option>
                                               <option value="rti">Road to IELTS</option>
                                               <option value="sss">Study Skills Success</option>
                                               <option value="tb">Tense Buster</option>
                                           
                                               <option value="others">Others</option>
                                               
                                    
                                             </select>
                                             <script>
                                                    $("select.productlist").multipleSelect({
                                                        width: 580,
                                                        multiple: true,
                                                        multipleWidth: 255,
                                                        placeholder: "Please select the related product(s)",
                                                        selectAll: false,
                                                        maxHeight: 380
                                                        
                                                
                                                    });
                                                </script>
                                           </div>
                                            
											 
                                             <div class="clear"></div>
                                             <div name="ErrMsgPrograms" id="ErrMsgPrograms" class="error" style="display:none;">Please select the related product(s).</div> 
                          </div>
                          
                          <div class="fieldbox">
                            <div class="fieldline_col" style="margin:0 8px 0 0;">
                                  	<div class="fieldline_small">
                                   	  <input name="F_SerialNo" id="F_SerialNo" type="text"  class="field" placeholder="Serial number (optional)" />
                                    </div>
                       	    </div>
                                  
                                  
                       		<div class="fieldline_col" style="margin:0 8px 0 0;">
                                                   <div class="fieldline_small">
                                                   
                                                   
                                      	
                                      	  <input name="F_InvoiceNo" id="F_InvoiceNo" type="text"  class="field" placeholder="Clarity invoice number (optional)" />
                                          </div>
                           	</div>
                                  
                                        
                                        
                                        <div class="fieldline_col">
                                                   <div class="fieldline_small">
                                                     <select name="F_OS" id="F_OS" data-placeholder="Please select your OS (optional)"  class="my_select_box">
                                                         <option value=""></option>
                                                        <option value="Windows XP">Windows XP</option>
                                                        <option value="Windows Vista">Windows Vista</option>
                                                        <option value="Windows 7 - 32 bit">Windows 7 (32 bit)</option>
                                                         <option value="Windows 7 - 64 bit">Windows 7 (64 bit)</option>
                                                        <option value="Windows 8">Windows 8 / 8.1</option> 
                                                        <option value="Mac OS">Mac OS</option> 
                                                        <option value="Windows Server 2003">Windows Server 2003</option>
                                                        <option value="Windows Server 2007">Windows Server 2007</option>
                                                        <option value="Windows Server 2012">Windows Server 2012</option>
                                                
                                                        <option value="Others">Others</option>        
                                                   </select>
                                                   </div>
											 
                                             
                            </div>
                                  	
                                  
                                       
                                        
                                        <div class="clear"></div>
                           </div>
                          
                          
                         </div>
                         
                         <div class="point_line">
                            <div class="point">2</div>
                            <div class="title">Contact Details</div>
                            <div class="clear"></div>
                         </div>
                         
                         <div class="section">
                         
                         
                         <div class="fieldbox">
                                     <div class="fieldline_col">
                                     <div class="fieldline_mid" style="margin:0 15px 0 0;">
                                       <input name="F_Name" id="F_Name" type="text"  class="field_mid" placeholder="Name" />
                                       
                                     </div>
                                     <div name="ErrMsgName" id="ErrMsgName" class="error" style="display:none;">Please fill in your name.</div> 
                                     </div>
                                     
                                           
                                   			
                                            <div class="fieldline_col">
                                           	  <div class="fieldline_mid">
                                            	<input name="F_Email" id="F_Email" type="text"  class="field_mid" placeholder="Email" />
                                           	  </div>
                                                    <div name="ErrMsgEmail" id="ErrMsgEmail" class="error" style="display:none;">Invalid email address.</div>                                              </div>
                                              
                                              
                                              
                                            

                                      	
                                       
                                        <div class="clear"></div>
                          </div>
                         
                            
                            
<div class="fieldbox">
                                        	<div class="fieldline_col" >
                                           <div class="fieldline_mid"  style="margin:0 15px 0 0;">
                                                 <select name="F_UserType" id="F_UserType" data-placeholder="I am a(n)..." class="my_select_box">
                                                     <option value=""></option>
                                                    <option value="Teacher">Teacher</option>
                                                    <option value="Student">Student</option>
                                                    <option value="Candidate">IELTS candidate</option>
                                                    <option value="Technician">Technician</option>
                                                    <option value="Librarian">Librarian</option>
                                                    <option value="Others">Others</option>  
                                               </select>
                                           </div>
                                           <div name="ErrMsgUserType" id="ErrMsgUserType" class="error" style="display:none;">Please tell us who you are.</div>                                             </div>
                                             
                                             <div class="fieldline_col">
                                             	 <div class="fieldline_mid">
                                      	  <input name="F_Institution" id="F_Institution" type="text"  class="field_mid" placeholder="Institution" />
                                           </div>
                                           <div name="ErrMsgInstitution" id="ErrMsgInstitution" class="error right" style="display:none;" >Please fill in your institution's name.</div>
                                           </div>
                                        <div class="clear"></div>
  </div>
  
  
                  <div class="fieldmsg">
                                           	<div class="fieldmsg_inner">
                                           	  <textarea name="F_Message" id="F_Message"  class="msg" placeholder="Leave a message..."></textarea>
                                           	</div>
                                            <div class="fieldmsg_button">
                                            	
                                           	
                                             	              
                                             
                                        <input name="btnSend" id="btnSend" type="button" class="btn_submit" onclick="verifySupportEnquiryForm();" value="Submit" />
                                            </div>
                           </div>
                           
                           <div class="bottom_box">
                             <div name="ErrMsgMessage" id="ErrMsgMessage" class="error_message_box" style="display:none;">
                                            <p  class="error">Please leave a message.</p>
                                            
                             </div>
                                            
                                       
                                            <div class="sendbox_msg_box">
                                                <div name="MsgSendbox" id="MsgSendbox">
                                                	<div class="sendbox_msg" name="MsgLoading" id="MsgLoading"  style="display:none;">
                                                        <div class="border" >
                                                            <span class="loading">Loading...</span>                                                         </div>
                                                    </div>
                                                     <div class="sendbox_msg"  name="MsgError" id="MsgError" style="display:none;">
                                                         <div class="border">
                                                            <span class="senderror">We're upgrading our system now, please try again later...</span>                                                         </div>
                                                     </div>
                                              </div>
                                         </div>
                                            
                                            <div class="clear"></div>
                                            
        </div>
  
                         </div>
                                
                          </form>
                        </div>
                    
                  </div>
    
               </div>
         
          </div>        
    </div>
​</div>



 <?php include 'common/searchbottom.php' ?>
  <?php include ($_SERVER['DOCUMENT_ROOT'].'/include/footer_plain.php' ); ?>


</body>
</html>
