	// Call the action script
	sendMethodToAction = function() {
	
		// block the button to avoid double clicking
		$("#submitResults").hide();
		$("#validationMessage").text("Please wait while your level is checked...").show();
		
		// get the answers
		var answers = '';
		// only take multiple choice items if selected
		$('.question-text input[type=radio]').filter(":checked").each(function(index){
				answers += '<input class="MultipleChoiceQuestion" id="' + $(this).attr("name") + '" value="' + $(this).attr("value") + '" />';
			});
		// only take gapfill if something is typed
		$('.question-text input[type=text]').filter(function() {return this.value.length > 0;}).each(function(index){
				answers += '<input class="GapFillQuestion" id="' + $(this).attr("id") + '" value="' + $(this).val() + '" />';
			});
		//var answers = $('#testInputs').serialize();
		console.log("answers=" + answers);
		$.ajax({
			type: "POST",
			url: "http://dock.projectbench/Software/ResultsManager/web/amfphp/services/TB6weeksService.php",
			data: {operation: 'checkAnswers', answers: answers, code: $("#codeHolder").text(), user: $("#registration").serialize()},
			dataType: "json",
			error: function(jqXHR, textStatus, errorThrown) {
				console.log('Error: ' + errorThrown);
			},
			success: function (data) {
				//var resultsData = jQuery.parseJSON(data);
				console.log('Marked and returned, debug ' + data.debug + '; from ' + data.of + ' questions (' + data.correct + ',' + data.wrong + ',' + data.skipped + ')');
				//console.log('Marked and returned, you got ' + data);
			}
		});
	};

	setupTestData = function () {

		// Inject the questions
		$.ajax({
			type: "GET",
			url: "http://dock.projectbench/Software/ResultsManager/web/amfphp/services/TB6weeksService.php",
			data: {operation: 'getQuestions', exercise: '1193901049540.xml'},
			dataType: "xml",
			error: function(jqXHR, textStatus, errorThrown) {
				console.log('Error: ' + errorThrown);
			},
			success: function (xml) {
				console.log('Read file successfully');

				// Parse the xml file and get data
				$(xml).find(".question").each(function () {
					// What is the id of this question?
					var questionID = $(this).attr("id");
					
					// If any input doesn't have a type set, make it explicitly text
					$(this).find("input:not([type])").attr("type", "text");
					
					// Gapfill needs to change the input id to be the question id
					$(this).find("input[id]").attr("id", questionID);
					
					// multiple choice needs to have the list <a> nodes turned into radio buttons
					/*
					 *<div class="question" id="q1">
					 * Sorry to ... like this, but there's a problem.
					 * <list class="answerList">
					 *	<li><a id="a1">barge in</a></li>
					 *	<li><a id="a2">barge on</a></li>
					 * </list>
					*/
					/*
					 * Sorry to ... like this, but there's a problem.
					 * <list class="answerList">
					 *	<li><input type="radio" id="a1" name="q1" value="a1">barge in</input></li>
					 *	<li><input type="radio" id="a2" name="q1" value="a2">barge on</input></li>
					 * </list>
					*/
					$(this).find("li a").each(function() {
						$(this).replaceWith("<input type='radio' value='" + $(this).attr('id') + "' name='" + questionID + "'>" + $(this).html() + "</input>");
					});

					$("#testPlaceholder").append($(this).html());
				});
				
				// save the checksum code
				$("#codeHolder").text($(xml).find("config").text());
			}
		});
	}


  jQuery(document).ready(function ($) {
      // $('.loader').css('opacity', 0);
      //  $('.cd-header, #container').css('opacity', 1);
      $('.banner--clone').addClass('banner--unstick');

      if (jQuery.browser.mobile) {

      } else {

			setupTestData();
			setupAboutImages();
			setupTestImages();
			setupRegisterImages();

          $('#container').fullpage({
              'verticalCentered': false,
              'css3': true,
              'navigation': true,
              'navigationPosition': 'right',
              'navigationTooltips': ['TB6weeks', 'Take the test', 'Register'],
              'onLeave': function (index, nextIndex, direction) {

                  if (nextIndex == 1) {
                      $('.banner--clone').removeClass('banner--stick');
                      $('.banner--clone').addClass('banner--unstick');
                  }
                  if (nextIndex > 1) {
                      $('.banner--clone').removeClass('banner--unstick');
                      $('.banner--clone').addClass('banner--stick');
                  }
                  if (nextIndex == 1) {
                      setupAbout();
                      setupAboutImages();
                  }
                  if (nextIndex == 2) {
                      setupTest();
                      setupTestImages();
                  }
                  if (nextIndex == 3) {
                      setupRegister();
                      setupRegisterImages();
                  }
              },
          });


          $(window).resize(function () {
              setupAboutImages();
              setupTestImages();
              setupRegisterImages();
          });

      }

		// Form validation 
		$("#submitResults").click(function() {
			console.log('Checking form data before submission');
			seemsOK = true;
			
			// Warn how many answers have been missed
			var answers = $('.question-text input:text').filter(function() { return this.value == ""; }).length;
			if (answers > 24) {
				$("#validationMessage").text("You have missed " + answers + " questions.");
				seemsOK = false;
			}
			
			var studentEmail = $("#userEmail").val();
			if (studentEmail == "") {
				seemsOK = false;
				$("#userEmail").focus();
				$("#validationMessage").text("Not such a great email...");
			}
			
			if (seemsOK) {
				return sendMethodToAction();
			} else {
				$( "#validationMessage" ).show().fadeOut( 4000 );
				return false;
			}
		});
	
      function setupAboutImages() {

          $('.about-content').css({
              bottom: '25%',
              opacity: 0
          });

          var w = $(window).width();
          var h = $(window).height();
          var srcWidth = 1920; // Max width for the image
          var srcHeight = 1080; // Max height for the image
          var ratio = w / srcWidth;
          if (1080 * ratio < h)
              ratio = h / srcHeight;

          $('#about .about-bg').css('width', 1920 * ratio);
          $('#about .about-bg').css('height', 1080 * ratio);
          $('#about svg').css('transform', 'scale(' + ratio + ')');
          var svg_diffx = 720 - 720 * ratio;
          var svg_diffy = 500 - 500 * ratio;
          $('#about svg').css('left', (920 * ratio - svg_diffx / 2));
          $('#about svg').css('margin-top', (350 * ratio - svg_diffy / 2));
          $('#about .about-bg').css('left', 0);
          //////////////////////
          setTimeout(function () {
              $('.about-content').
              animate({
                  bottom: '20%',
                  opacity: 1
              }, 800, "easeOutCubic")
          }, 2000);
      }

      function setupAbout() {

          var w = $(window).width();
          var h = $(window).height();
          var srcWidth = 1920; // Max width for the image
          var srcHeight = 1080; // Max height for the image
          var ratio = w / srcWidth;
          if (1080 * ratio < h)
              ratio = h / srcHeight;

          $('#um-outline-bg, .um-outline').fadeIn(0);
          $(".um-outline path").each(function () {
              var path = this;
              var length = path.getTotalLength();
              // Clear any previous transition
              path.style.transition = path.style.WebkitTransition =
                  'none';
              // Set up the starting positions
              path.style.strokeDasharray = length + ' ' + length;
              path.style.strokeDashoffset = length;
              // Trigger a layout so styles are calculated & the browser
              // picks up the starting position before animating
              path.getBoundingClientRect();
              // Define our transition
              path.style.transition = path.style.WebkitTransition =
                  'stroke-dashoffset 1.5s ease-in-out';
              // Go!
              path.style.strokeDashoffset = '0';
          });
          var fx = parseInt($('about-content h2').css('font-size'));
          var fxp = parseInt($('.about-content p').css('font-size'));
          var size = parseInt($(".about-content h2").css('font-size'));

          setTimeout(function () {
              $('#um-outline-bg, .um-outline').fadeOut(500)
          }, 1500);
      }

      function setupTestImages() {

          $('.test-content').css({
              top: '0%',
              opacity: 0
          });

          var w = $(window).width();
          var h = $(window).height();
          var srcWidth = 1920; // Max width for the image
          var srcHeight = 1080; // Max height for the image
          var ratio = w / srcWidth;
          if (1080 * ratio < h)
              ratio = h / srcHeight;

		  // Set the height of the scrollable section
          $('#testPlaceholder').css('width', 0.9 * (w));
          $('#testPlaceholder').css('height', 0.8 * (1080 * ratio));
		  
		  // Background colour
		  $('#test').css('background-color', 'blue');

		  // $('.test-content').prepend("<p>" + $(".about-content h2").text() + "</p>");
		  
          //////////////////////
          setTimeout(function () {
              $('.test-content').
              animate({
                  top: '5%',
                  opacity: 1
              }, 800, "easeOutCubic")
          }, 1000);
      }

      function setupTest() {

          var w = $(window).width();
          var h = $(window).height();
          var srcWidth = 1920; // Max width for the image
          var srcHeight = 1080; // Max height for the image
          var ratio = w / srcWidth;
          if (1080 * ratio < h)
              ratio = h / srcHeight;

          $('#um-outline-bg, .um-outline').fadeIn(0);
          $(".um-outline path").each(function () {
              var path = this;
              var length = path.getTotalLength();
              // Clear any previous transition
              path.style.transition = path.style.WebkitTransition =
                  'none';
              // Set up the starting positions
              path.style.strokeDasharray = length + ' ' + length;
              path.style.strokeDashoffset = length;
              // Trigger a layout so styles are calculated & the browser
              // picks up the starting position before animating
              path.getBoundingClientRect();
              // Define our transition
              path.style.transition = path.style.WebkitTransition =
                  'stroke-dashoffset 1.5s ease-in-out';
              // Go!
              path.style.strokeDashoffset = '0';
          });
          var fx = parseInt($('test-content h2').css('font-size'));
          var fxp = parseInt($('.test-content p').css('font-size'));
          var size = parseInt($(".test-content h2").css('font-size'));

          setTimeout(function () {
              $('#um-outline-bg, .um-outline').fadeOut(500)
          }, 1500);
      }

      function setupRegisterImages() {

          $('.register-content').css({
              top: '50%',
              opacity: 0
          });

          var w = $(window).width();
          var h = $(window).height();
          var srcWidth = 1920; // Max width for the image
          var srcHeight = 1080; // Max height for the image
          var ratio = w / srcWidth;
          if (1080 * ratio < h)
              ratio = h / srcHeight;

          $('#register .register-bg').css('width', 1920 * ratio);
          $('#register .register-bg').css('height', 1080 * ratio);
          $('#register svg').css('transform', 'scale(' + ratio + ')');
          var svg_diffx = 720 - 720 * ratio;
          var svg_diffy = 500 - 500 * ratio;
          $('#register svg').css('left', (920 * ratio - svg_diffx / 2));
          $('#register svg').css('margin-top', (350 * ratio - svg_diffy / 2));
          $('#register .register-bg').css('left', 0);
          //////////////////////
          setTimeout(function () {
              $('.register-content').
              animate({
                  bottom: '20%',
                  opacity: 1
              }, 100, "easeOutCubic")
          }, 100);
      }

      function setupRegister() {

          var w = $(window).width();
          var h = $(window).height();
          var srcWidth = 1920; // Max width for the image
          var srcHeight = 1080; // Max height for the image
          var ratio = w / srcWidth;
          if (1080 * ratio < h)
              ratio = h / srcHeight;

          $('#um-outline-bg, .um-outline').fadeIn(0);
          $(".um-outline path").each(function () {
              var path = this;
              var length = path.getTotalLength();
              // Clear any previous transition
              path.style.transition = path.style.WebkitTransition =
                  'none';
              // Set up the starting positions
              path.style.strokeDasharray = length + ' ' + length;
              path.style.strokeDashoffset = length;
              // Trigger a layout so styles are calculated & the browser
              // picks up the starting position before animating
              path.getBoundingClientRect();
              // Define our transition
              path.style.transition = path.style.WebkitTransition =
                  'stroke-dashoffset 1.5s ease-in-out';
              // Go!
              path.style.strokeDashoffset = '0';
          });
          var fx = parseInt($('register-content h2').css('font-size'));
          var fxp = parseInt($('.register-content p').css('font-size'));
          var size = parseInt($(".register-content h2").css('font-size'));

          setTimeout(function () {
              $('#um-outline-bg, .um-outline').fadeOut(100)
          }, 100);
      }
	  
      //open/close primary navigation
      $('.cd-primary-nav-trigger').on('click', function () {
          $('.cd-menu-icon').toggleClass('is-clicked');
          $('.cd-header').toggleClass('menu-is-open');
          //in firefox transitions break when parent overflow is changed, so we need to wait for the end of the trasition to give the body an overflow hidden
          if ($('.cd-primary-nav').hasClass('is-visible')) {
              $('.cd-primary-nav').removeClass('is-visible').one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', function () {
                  $('body').removeClass('overflow-hidden');

              });
          } else {
              $('.cd-primary-nav').addClass('is-visible').one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', function () {
                  $('body').addClass('overflow-hidden');
              });
          }
      });


      $('.loader').fadeOut(300, function () {
           $('.cd-header, #container').css('opacity', 1);
      });
     
      //$('.loader').fadeOut(300);

  });



  /**
   * jQuery.browser.mobile (http://detectmobilebrowser.com/)
   *
   * jQuery.browser.mobile will be true if the browser is a mobile device
   *
   **/
  (function (a) {
      (jQuery.browser = jQuery.browser || {}).mobile = /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4))
  })(navigator.userAgent || navigator.vendor || window.opera);