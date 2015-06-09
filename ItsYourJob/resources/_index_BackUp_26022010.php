<?php
session_start();
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Clarity English Online - Worksheets</title>

<!--CSS General-->
<link rel="stylesheet" type="text/css" href="../css/tab.css" />

<!--Tab function-->
<script type="text/javascript" src="../script/yetii.js"></script>

<!-- Clarity recorder -->
	<script type="text/javascript" src="/Software/Common/swfobject2.js"></script>
	
	<script type="text/javascript" src="/Software/Recorder/gong.js"></script>
	<script type="text/javascript" src="/Software/Recorder/gongInterface.js"></script>
	<applet id="nanogong" archive="http://gong.ust.hk/gong510/nanogong.jar" code="gong.NanoGong" width="1" height="1" style="float:left;"
    	alt="If the Recorder is not working, please check your Java Plugin at http://www.java.com/en/download/index.jsp">
        <p>The Clarity Recorder requires the Java Plug-in. Please go to http://www.java.com/en/download/index.jsp to download or test yours.</p>
	</applet>
	<script type="text/javascript">
		var startControl = "/Software/";
		var coordsWidth = 250; var coordsHeight = 90;
		var flashvarsClarityRecorder = {};
		var paramsClarityRecorder = {allowScriptAccess:"sameDomain"};
		var attrClarityRecorder = {};
		attrClarityRecorder.id = "ClarityRecorder";
		attrClarityRecorder.name = "ClarityRecorder";
		var cacheKiller = new Date().getTime();
		var expressInstall = startControl + "Common/expressInstall.swf";
		swfobject.embedSWF(startControl + "Recorder/ClarityRecorder.swf?" + cacheKiller, "altContentClarityRecorder", coordsWidth, coordsHeight, "9.0.0", expressInstall, flashvarsClarityRecorder, paramsClarityRecorder, attrClarityRecorder);

		// For external interface calls
		function thisMovie(movieName) {
			if (window.document[movieName]) {
				return window.document[movieName];
			}
			if (navigator.appName.indexOf("Microsoft Internet") == -1) {
				if (document.embeds && document.embeds[movieName])
					return document.embeds[movieName];
			} else { // if (navigator.appName.indexOf("Microsoft Internet")!=-1)
				return document.getElementById(movieName);
			}
		}
		
	</script>

</head>

<body id="worksheets_body">
<div id="tab-topics-container">
			<div id="tab-topics-container-menu">
                <ul id="tab-topics-container-nav">
                    <li><a href="#quote">Quotes</a></li>
					<li><a href="#weblink">Different angles</a></li>
                    <li><a href="#tips">Tips</a></li>
                    <li><a href="#recorder">Recorder</a></li>
              </ul>
              
             <div class="clear"></div>
              
  </div>
            
  

      <div class="tab" id="quote">
          	<div class="tab_header">
           	  <p class="tab_header_left_one">Quote from the front line</p>
			</div>
            
  <div class="tabs_box_outter">
                <div class="qutoes_box">
    
                    
                    <p id="quote_detail">&quot;For government jobs, the resume has a lower priority. The first stage of screening is done through the application form, and this is done by a clerical officer. Make sure the application form is neat and tidy, that there is no missing information, and that the information you give can be backed up with the appropriate documentation, such as exam certificates.&quot;</p>
                    <p id="quote_title">Senior Executive Officer, Hong Kong Government</p>
                 </div>
        </div>
  </div>
       
        
<div class="tab" id="weblink">
          	<div class="tab_header">
           	  <p class="tab_header_left_one">Books and websites</p>
			</div>
              <div class="tabs_box_outter">
            
            <div id="tab-container-links" class="detail_box_no_list">
            
              <ul id="tab-container-links-nav">
                <li><a href="#links1"></a></li>
                <li><a href="#links2"></a></li>
              </ul>
              
      
              
              <div id="links_container" style="height:145px; position:relative; width: 400px;">
			    <p class="tab-links-des" id="links_des">Try the resources below:</p>
                      <div class="tab-links" id="links1">
                          
                            <p class="detail_box_no_list_img"><img src="../images/reference/u2_1.jpg"/></p>
                            <p class="detail_box_no_list_text">1. Download a very detailed <a href="http://www.lauriercc.ca/career/students/job/resume.htm" target="_blank">guide</a> to resume writing from Wilfred Laurier University, Canada.</p>
                      </div>
                      
               		 <div class="tab-links" id="links2">
                            <p class="detail_box_no_list_img"><img src="../images/reference/u2_2.jpg"/></p>
                            <p class="detail_box_no_list_text">2. Should you create a DVD resume? Check out <a href="http://video.about.com/jobsearch/Create-a-DVD-resume.htm" target="_blank">this page</a>.</p>
                </div>
                
                
                
              </div>
             <div class="tab_links_ref_area">
 
                    		<a href="javascript:tabber3.previous()">Previous</a> | <a href="javascript:tabber3.next()">Next</a>
                  </div>
              
              
            </div>
            
    </div>
  </div>
             <div class="tab" id="tips">
          	<div class="tab_header">
           	  <p class="tab_header_left_one">Tips from fellow job-seekers</p>
			</div>
            
              <div class="tabs_box_outter">
            
                <ul class="detail_table_arrow" id="tab-container-tips">
                    <!--<div class="blue_border">
                    Be brave! The best way to improve your speaking is to practise. Sometimes you feel foolish speaking a foreign language because you know you are making mistakes. Persist! Language learning is all about taking risks.</div>-->
                    
                  <ul id="tab-container-tips-nav">
                    <li><a href="#tips1"></a></li>
                        <li><a href="#tips2"></a></li>
                        <li><a href="#tips3"></a></li>
                        <li><a href="#tips4"></a></li>
                        <li><a href="#tips5"></a></li>
                  </ul>
                    
                    <div id="tips_container">
    
                      <div class="tab-tips" id="tips1">
                        <p class="heading">Tip 1</p>
                            Don’t state your expected salary if the advertisement does not specifically ask you to. You risk stating a salary below what the company is prepared to pay.                      </div>
                        
                        <div class="tab-tips" id="tips2">
                      <p class="heading">Tip 2</p>Don’t lie in your resume. This includes “massaging” dates. If you are caught out, you lose a job opportunity. For employers a dishonest applicant will probably be a dishonest employee.                    </div>
                        
                        <div class="tab-tips" id="tips3">
                      <p class="heading">Tip 3</p>When you’ve sent in your application, don’t take calls about it at work. It embarrassing you disappear into the corridor to talk on your mobile. Everybody knows what is happening. Arrange to call back later.</div>
                        
                        <div class="tab-tips" id="tips4">
                      <p class="heading">Tip 4</p>Modify your resume to fit the job you are applying for, and showcase your most relevant qualifications and experience. This will impress employers because it shows you have taken the trouble to research their company.</div>
                        
                      <div class="tab-tips" id="tips5">
                      <p class="heading">Tip 5</p>If you are sending your resume by email, send it as a pdf. This way you can be sure that the employers will see the document as you laid it out.                </div>
                  </div>
                      <div class="tab_links_area">
                        <a href="javascript:tabber2.previous()">Previous</a> |
                        <a href="javascript:tabber2.next()">Next</a>                  </div>
                </ul>
             </div>
  </div>
       
        <div class="tab" id="recorder">
          	<div class="tab_header">
			<p class="tab_header_left_one">Use the Clarity Recorder to record and play back your voice</p>
		</div>
  <div style="height:140px; padding:30px 0 0 70px;">
                
      <div id="altContentClarityRecorder" /></div>
  </div>
       
          
          
</div>
      
      <!--Tab function Script-->
<script type="text/javascript" src="../script/libResource.js"></script>
<script type="text/javascript">load(<?php echo $_GET["unitID"]; ?>);</script>

</body>
</html>
