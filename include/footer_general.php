<?php 
//need this? 
	require_once(dirname(__FILE__)."/../domainVariables.php");

// 2016 Feb Vivying tell Nicole that  added for catching the undefine variable in footer.php
 if(!(isset($currentSector))) { $currentSector = "";} 
	
?>

<script>
  $(document).ready(function () {
  //Quick icons
    $(".icon#home").mouseover(function () {
      $('#icons_box #txt').text("Home");
    });
	
	$(".icon#contact").mouseover(function () {
      $('#icons_box #txt').text("Contact");
    });
	
	$(".icon#catalogue").mouseover(function () {
      $('#icons_box #txt').text("Catalogue");
    });
	
	$(".icon#top").mouseover(function () {
      $('#icons_box #txt').text("Top");
    });
	
	$(".icon#home").mouseout(function () {
      $('#icons_box #txt').text("");
    });
	
	$(".icon#contact").mouseout(function () {
      $('#icons_box #txt').text("");
    });
	
	$(".icon#catalogue").mouseout(function () {
      $('#icons_box #txt').text("");
    });
	
	$(".icon#top").mouseout(function () {
      $('#icons_box #txt').text("");
    });
	
	$(document).ready(function() {
    $(".tags_line").hide();
	

    var elements = $(".tags_line");
    var elementCount = elements.size();
    var elementsToShow = 5;
    var alreadyChoosen = ",";
    var i = 0;
    while (i < elementsToShow) {
        var rand = Math.floor(Math.random() * elementCount);
        if (alreadyChoosen.indexOf("," + rand + ",") < 0) {
            alreadyChoosen += rand + ",";
            elements.eq(rand).show();
            ++i;
        }
    }
});


	$(document).ready(function() {
    $(".review_line").hide();
	

    var elements = $(".review_line");
    var elementCount = elements.size();
    var elementsToShow = 1;
    var alreadyChoosen = ",";
    var i = 0;
    while (i < elementsToShow) {
        var rand = Math.floor(Math.random() * elementCount);
        if (alreadyChoosen.indexOf("," + rand + ",") < 0) {
            alreadyChoosen += rand + ",";
            elements.eq(rand).show();
            ++i;
        }
    }
});





	
	// fade in #back-top
	$(function () {
		

		// scroll body to 0px on click
		$('.icon#top').click(function () {

			$('body,html').animate({
				scrollTop: 0
			}, 500);
			return false;
		});
	});
	
	
  });
</script>



<div id="footer_container">
  <div id="content">
    	<div id="news">
        

        
        	<a id="guide" href="<?php if ($currentSector =="Library"){echo '/lib'; } ?>/catalogue.php?news" onClick="_gaq.push(['_trackEvent', 'Footer', 'News: Clarity Guide 2015', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);">
         
       	    	<h1>Clarity Guide is <br />
   	    	    now available.</h1>
<h2>Click here to request <br />
           	    your copy!</h2>
          </a>        
        	
        	
        
    </div>
<div id="tags">
        	<h3>Popular tags</h3>
            
            <div class="tags_line">
                    <a class="tags" href="/program/practicalwriting.php" onClick="_gaq.push(['_trackEvent', 'Footer', 'Tags: Practical Writing', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"><span>Practical Writing</span></a>
                </div>
    
                <div class="tags_line">
                    <a class="tags" href="/program/roadtoielts.php" onClick="_gaq.push(['_trackEvent', 'Footer', 'Tags: IELTS preparation', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"><span>IELTS preparation</span></a>
                </div>
                <div class="tags_line" style="display:none;">
                    <a class="tags" href="/support/programcompatibilities.php" onClick="_gaq.push(['_trackEvent', 'Footer', 'Tags: Program compatibilities', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"><span>Program compatibilities</span></a>
                </div>
                <div class="tags_line">
                    <a class="tags" href="/support/results.php?search=SCORM" onClick="_gaq.push(['_trackEvent', 'Footer', 'Tags: SCORM compliant', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"><span>SCORM compliant</span></a>
                </div>
                <div class="tags_line">
                    <a class="tags" href="/program/tensebuster.php" onClick="_gaq.push(['_trackEvent', 'Footer', 'Tags: Gammar', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"><span>Grammar</span></a>
                </div>
                <div class="tags_line">
                    <a class="tags" href="/program/claritycoursebuilder.php" onClick="_gaq.push(['_trackEvent', 'Footer', 'Tags: Clarity Course Builder', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"><span>Clarity Course Builder</span></a>
                </div>

            	<div class="tags_line">
                    <a class="tags" href="/program/roadtoielts2.php" onClick="_gaq.push(['_trackEvent', 'Footer', 'Tags: Road to IELTS', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"><span>Road to IELTS</span></a>
                </div>
                <div class="tags_line">
                    <a class="tags" href="/program/tensebuster.php" onClick="_gaq.push(['_trackEvent', 'Footer', 'Tags: Tense Buster', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"><span>Tense Buster</span></a>
                </div>
                <div class="tags_line">
                    <a class="tags" href="/support/results.php?search=tablet" onClick="_gaq.push(['_trackEvent', 'Footer', 'Tags: Available on tablet', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"><span>Available on tablet</span></a>
                </div>
                <div class="tags_line">
                    <a class="tags" href="/program/claritycoursebuilder.php" onClick="_gaq.push(['_trackEvent', 'Footer', 'Tags: Make my own online course', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"><span>Make my own online course</span></a>
                </div>
                <div class="tags_line">
                    <a class="tags" href="/support/results.php?search=upgrade" onClick="_gaq.push(['_trackEvent', 'Footer', 'Tags: Upgrade Clarity program', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"><span>Upgrade Clarity program</span></a>
                </div>
                
                <div class="tags_line">
                    <a class="tags" href="/support/results.php?search=moodle" onClick="_gaq.push(['_trackEvent', 'Footer', 'Tags:  Moodle / BlackBoard', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"><span>Moodle / BlackBoard</span></a>
                </div>
                
                <div class="tags_line">
                    <a class="tags" href="/program/clearpronunciation.php" onClick="_gaq.push(['_trackEvent', 'Footer', 'Tags:  Pronunciation', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"><span>Pronunciation</span></a>
                </div>
                
                <div class="tags_line">
                    <a class="tags" href="/program/activereading.php" onClick="_gaq.push(['_trackEvent', 'Footer', 'Tags: Reading', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"><span>Reading</span></a>
                </div>
                
                <div class="tags_line">
                    <a class="tags" href="/program/studyskills.php" onClick="_gaq.push(['_trackEvent', 'Footer', 'Tags: Academic Study Skills', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"><span>Academic Study Skills</span></a>
                </div>
                
           
 		
      
        </div>
    	<div id="about">
        	
        	<h3>What are people <br />saying about Clarity?</h3>
            
            


            
            <div class="review_line">
            <h4>I really appreciate the prompt and thorough way Clarity is supporting us with this."</h4>
            
            
           
            	<h5>Lawrence Smith, British Council<br />
                DPR Korea Teaching & Training Project</h5>
          
            <a class="more" href="/story/index.php" onClick="_gaq.push(['_trackEvent', 'Footer', 'About', 'more_ELGazette', '<?php echo $_SERVER["REQUEST_URI"] ?>', true]);" style="display:none;">Learn more</a>
            </div>
            
            <div class="review_line">
            <h4>Clarity is perhaps the most <br />successful of the ELT specialist <br />digital publishers."</h4>
            
            
           
            	<h5>EL Gazette, issue 409,<br />
                February 2014</h5>
          
            <a class="more" href="/story/index.php" onClick="_gaq.push(['_trackEvent', 'Footer', 'About', 'more_ELGazette', '<?php echo $_SERVER["REQUEST_URI"] ?>', true]);" style="display:none;">Learn more</a>
            </div>
            <div class="review_line">
            	 <h4>I am very pleased with Clarity.<br />It is very simple to set up the classes."</h4>
            
            
        
            	<h5>Claudia Kiburz<br />
                Khalifa University of Science, <br />Technology &amp; Research</h5>
           	
            </div>
            
            <div class="review_line">
            	 <h4>The support from ClarityEnglish has been first rate. You always answer very promptly and are very helpful answering enquiries, so thank you very much for that."</h4>
            
            
        
            	<h5>Caroline Rey<br />
                Lincoln College</h5>
                

           	
            </div>
            
            <div class="review_line">
            	 <h4>I am very pleased with Clarity.<br />It is very simple to set up the classes."</h4>
            
            
        
            	<h5>Claudia Kiburz<br />
                Khalifa University of Science, <br />Technology &amp; Research</h5>
           	
            </div>
            
            <div class="review_line">
            	 <h4>I highly appreciate your prompt response and cooperative attitude."</h4>
            
            	<h5>Eman Elshazly<br />
                International School of Creative Science</h5>
           	
            </div>
            
            <div class="review_line">
            	 <h4>Please thank your team for their excellent support in getting Road to IELTS up and running for us."</h4>
            
            	<h5>Dawn Osborne<br />
                Swindon Libraries</h5>
           	
            </div>
            
            <div class="review_line">
            	 <h4>Thank you very much really for your genuine cooperation."</h4>
            
            
        
            	<h5>Milkesso Wako<br />Arba Minch University, Ethiopia</h5>
           	
            </div>
            
            <div class="review_line">
            	 <h4>The teachers were really appreciative of what you did..."</h4>
            
            
        
            	<h5>Andy Keedwell<br />British Council, Afghanistan</h5>
           	
            </div>
           
         </div>
        <div class="clear"></div>
    	
    
    
  </div>
    
    <div id="links_box">
    	<a href="/sitemap.php" onClick="_gaq.push(['_trackEvent', 'Footer', 'Link: Sitemap', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);">Sitemap</a> <strong>|</strong> <a href="/terms.php" onClick="_gaq.push(['_trackEvent', 'Footer', 'Link: Terms', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);">Terms &amp; conditions</a>
    	
    	<div id="icons_box">
        	<div id="txt"></div>
            <a class="icon <?php if ($currentSelection =="home"){echo 'select'; }?>" id="home" href="/" onClick="_gaq.push(['_trackEvent', 'Footer', 'Menu: Home', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"></a>
            <a class="icon <?php if ($miniSelection =="contact"){echo 'select'; }?>" id="contact" href="/contactus.php" onClick="_gaq.push(['_trackEvent', 'Footer', 'Menu: Contact', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"></a>
            <a class="icon <?php if (($currentSelection =="catalogue") || ($miniSelection =="prices")){echo 'select'; }?>" id="catalogue" href="/catalogue.php" onClick="_gaq.push(['_trackEvent', 'Footer', 'Menu: Catalogue', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"></a>
            

            
            <a class="icon" id="top" onClick="_gaq.push(['_trackEvent', 'Footer', 'Menu: Top', '<?php echo $_SERVER["REQUEST_URI"] ?>',, true]);"></a>
         </div>
    </div>
    <div id="bottom_box">
    	<div id="clarityenglish"></div>
        <div id="copyright">Copyright &copy; 1993 - <?php echo date("Y"); ?> Clarity Language Consultants Ltd. All rights reserved.</div>
    </div>
</div>
