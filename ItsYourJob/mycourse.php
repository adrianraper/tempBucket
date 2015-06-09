<!--Don't Upload: CSS General-->
<link rel="stylesheet" type="text/css" href="css/job_general.css" />
<!--Don't Upload: CSS General-->
<?php
?>

<!--My course whole panel - DIV loading -->
<div id="My_Course"><!--Group 3 divs-->
<div id="main_area">
<div id="unit_menu_area">
<ul>
	<li id="course_01">
    	<div class="group_menu">
            <a href="javascript:displayUnitById(g_Content, '01');">
                <span class="menu_num">1</span>
                <span class="menu_title">Find the ideal job... for you</span>
            </a>
         </div>
	</li>

	<li id="course_02">
        <div class="group_menu">
            <a href="javascript:displayUnitById(g_Content, '02');">
                <span class="menu_num">2</span>
                <span class="menu_title">The perfect resume</span>
            </a>

        </div>
	</li>

	<li id="course_03">
    	<div class="group_menu">
            <a href="javascript:displayUnitById(g_Content, '03');">
                <span class="menu_num">3</span>
                <span class="menu_title">Cover letters that work</span>
            </a>        </div>
	</li>

	<li id="course_04">
		<div class="group_menu">
            <a href="javascript:displayUnitById(g_Content, '04');">
                <span class="menu_num">4</span>
                <span class="menu_title">Prepare for the interview</span>
            </a>        </div>
	</li>

	<li id="course_05">
    	<div class="group_menu">
            <a href="javascript:displayUnitById(g_Content, '05');">
            <span class="menu_num">5</span>
            <span class="menu_title">Handling difficult questions</span></a>    	</div>
	</li>

	<li id="course_06">
    	<div class="group_menu">
            <a href="javascript:displayUnitById(g_Content, '06');">
            <span class="menu_num">6</span>
            <span class="menu_title">Effective follow-up</span></a>    	</div>
	</li>

	<li id="course_07">
    	<div class="group_menu">
            <a href="javascript:displayUnitById(g_Content, '07');">
            <span class="menu_num">7</span>
            <span class="menu_title">Surviving psychometric tests</span></a>    	</div>
	</li>

	<li id="course_08">
    	<div class="group_menu">
            <a href="javascript:displayUnitById(g_Content, '08');">
            <span class="menu_num">8</span>
            <span class="menu_title">Body language: why it matters</span></a>        </div>
	</li>

	<li id="course_09">
    	<div class="group_menu">
            <a href="javascript:displayUnitById(g_Content, '09');">
            <span class="menu_num">9</span>
            <span class="menu_title">Perform in group discussions</span></a>        </div>
	</li>

	<li id="course_10">
    	<div class="group_menu">
            <a href="javascript:displayUnitById(g_Content, '10');">
            <span class="menu_num">10</span>
            <span class="menu_title">Technology: friend or foe?</span></a>        </div>
	</li>
</ul>
</div>

<div id="unit_content_area"><!--Subscription time mode and title-->
<p class="unit_content_date" id="course_title">Loading...</p>

<!--eBook-->
<div class="unit_content_box">
<div class="unit_content_box_left">
<p id="content_ebook_title" class="header">Career Library</p>
<p id="content_ebook_describe" class="content"><img src="images/ajax-loading-small.gif" /></p>
</div>

<div class="unit_content_box_right">
<p class="icon_ebook">

	<!--<a href="eBook/u2/index.htm" id="content_ebook_link" class="eBook_iframe">Click here</a>-->
    
    <a href="javascript:EbookpopUp('eBook/u2/index.htm')" id="content_ebook_link" class="eBook_iframe">Click here</a>
    
    
</p>
</div>
</div>
<!--End of eBook-->


<!--Video Exe-->
<div class="unit_content_box">
<div class="unit_content_box_left">
<p id="content_video_title" class="header">Advice Zone</p>
<p id="content_video_describe" class="content"></p>
</div>

<!--Video Exe - Questions--> <!--Question 1-->
<ul class="unit_content_box_left_ques_container">

	<li class="unit_content_box_left_ques">
	<p id="content_video_q1" class="question">Question 1</p>
	<p id="content_video_q1_describe" class="description"><img src="images/ajax-loading-small.gif" style="margin:5px 0 0 0"/></p>
	</li>

	<li class="unit_content_box_right_ques">
	<p class="icon_vq1"><a href="#" id="content_video_q1_link"></a></p>
	</li>
</ul>

<!--Question 2-->
<ul class="unit_content_box_left_ques_container">
	<li class="unit_content_box_left_ques">
	<p id="content_video_q2" class="question">Question 2</p>
	<p id="content_video_q2_describe" class="description"><img src="images/ajax-loading-small.gif" style="margin:5px 0 0 0"/></p>
	</li>

	<li class="unit_content_box_right_ques">
	<p class="icon_vq2"><a href="#" id="content_video_q2_link"></a></p>
	</li>
</ul>

<!--Question 3-->
<ul id="ul_video3" class="unit_content_box_left_ques_container">
	<li class="unit_content_box_left_ques">
	<p id="content_video_q3" class="question">Question 3</p>
	<p id="content_video_q3_describe" class="description"><img src="images/ajax-loading-small.gif" style="margin:5px 0 0 0"/></p>
	</li>

	<li class="unit_content_box_right_ques">
	<p class="icon_vq3"><a href="#" id="content_video_q3_link"></a></p>
	</li>
</ul>

<!--End of Video Exe--></div>

<!--Interactive Exercise-->
<div class="unit_content_box">

    <div class="unit_content_box_left">
        <p id="content_exe" class="header">Practice Centre</p>
        <p id="content_exe_describe" class="content"><img src="images/ajax-loading-small.gif"/></p>
    </div>

    <div class="unit_content_box_right">
          <p class="icon_exe"><a href="javascript:ProgrampopUp('http://www.ClarityEnglish.com/area1/ItsYourJob/Start.php?prefix=IYJ-DEMO&username=iyjguest&course=1249436487189&startingPoint=ex:1252280112489')" id="content_exe_link" class="exe_iframe">Click here</a></p>
    </div>
</div>


<!--End of Interactive Exercise-->


<!--Audio-->
<div class="unit_content_box">
<div class="unit_content_box_left">

	<p id="content_audio_title" class="header">Story Point</p>
	<p id="content_audio_describe" class="content"><img src="images/ajax-loading-small.gif"/></p>
</div>


    <div class="unit_content_box_right">
    
    	<div class="audio_box">
            <p class="icon_audio_u1" id="content_audio_icon"></p>
            <div class="audio_player" id="altFlashContent"></div>
      </div>
    </div>
</div>
<!--End of Audio--> 


</div>

<!--Video Area-->
<div id="unit_video_area">
<div id="unit_video_inner_area">

    <div id="video_top"></div>

    <div id="video_middle">
        <p id="video_middle_title">Through an employer's eyes</p>
        
        <!--Video Resolution 320px * 280px-->
        <div id="content_video">
            <img src="images/blank.gif" id="video_template_int"/>
        </div>
    
    </div>

    <div id="video_btn"></div>

    <div id="video_footer">
        <div id="video_footer_left"></div>
    
        <div id="video_footer_middle">
    
            <p>Resources</p>
            
            <ul>
                <li id="res_mp3" class="mp3"><a id="a_res_mp3" href="resources/index.php?tab-topics-container=1" class="res_iframe">Quotes</a></li>
                <li id="res_links" class="links"><a id="a_res_links" href="resources/index.php?tab-topics-container=2" class="res_iframe">Different angles</a></li>
                <li id="res_tips" class="tips"><a id="a_res_tips" href="resources/index.php?tab-topics-container=3" class="res_iframe">Tips</a></li>
                <li id="res_recorder" class="recorder"><a id="a_ares_recorder" href="resources/index.php?tab-topics-container=4" class="res_iframe">Recorder</a></li>
            </ul>
    
        </div>
    
        <div id="video_footer_right"></div>
        
    </div>
    
    <div class="clear"></div>

    </div>
</div>
<div class="clear"></div>
</div>
</div>
<!--My course whole panel - DIV loading -->
