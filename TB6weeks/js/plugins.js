// Avoid `console` errors in browsers that lack a console.
(function () {
    var method;
    var noop = function () {};
    var methods = [
        'assert', 'clear', 'count', 'debug', 'dir', 'dirxml', 'error',
        'exception', 'group', 'groupCollapsed', 'groupEnd', 'info', 'log',
        'markTimeline', 'profile', 'profileEnd', 'table', 'time', 'timeEnd',
        'timeStamp', 'trace', 'warn'
    ];
    var length = methods.length;
    var console = (window.console = window.console || {});

    while (length--) {
        method = methods[length];

        // Only stub undefined methods.
        if (!console[method]) {
            console[method] = noop;
        }
    }
}());

// Place any jQuery/helper plugins in here.

//videoBG
/**
 * @preserve Copyright 2011 Syd Lawrence ( www.sydlawrence.com ).
 * Version: 0.2
 *
 * Licensed under MIT and GPLv2.
 *
 * Usage: $('body').videoBG(options);
 *
 */

(function ($) {

    $.fn.videoBG = function (selector, options) {
        if (options === undefined) {
            options = {};
        }
        if (typeof selector === "object") {
            options = $.extend({}, $.fn.videoBG.defaults, selector);
        } else if (!selector) {
            options = $.fn.videoBG.defaults;
        } else {
            return $(selector).videoBG(options);
        }

        var container = $(this);

        // check if elements available otherwise it will cause issues
        if (!container.length) {
            return;
        }

        // container to be at least relative
        if (container.css('position') == 'static' || !container.css('position')) {
            container.css('position', 'relative');
        }

        // we need a width
        if (options.width === 0) {
            options.width = container.width();
        }

        // we need a height
        if (options.height === 0) {
            options.height = container.height();
        }

        // get the wrapper
        var wrap = $.fn.videoBG.wrapper();
        wrap.height(options.height)
            .width(options.width);

        // if is a text replacement
        if (options.textReplacement) {

            // force sizes
            options.scale = true;

            // set sizes and forcing text out
            container.width(options.width)
                .height(options.height)
                .css('text-indent', '-9999px');
        } else {

            // set the wrapper above the video
            wrap.css('z-index', options.zIndex + 1);
        }

        // move the contents into the wrapper
        wrap.html(container.clone(true));

        // get the video
        var video = $.fn.videoBG.video(options);

        // if we are forcing width / height
        if (options.scale) {

            // overlay wrapper
            wrap.height(options.height)
                .width(options.width);

            // video
            video.height(options.height)
                .width(options.width);
        }

        // add it all to the container
        container.html(wrap);
        container.append(video);

        return video.find("video")[0];
    };

    // set to fullscreen
    $.fn.videoBG.setFullscreen = function ($el) {
        var windowWidth = $(window).width(),
            windowHeight = $(window).height();

        $el.css('min-height', 0).css('min-width', 0);
        $el.parent().width(windowWidth).height(windowHeight);
        // if by width
        var shift = 0;
        if (windowWidth / windowHeight > $el.aspectRatio) {
            $el.width(windowWidth).height('auto');
            // shift the element up
            var height = $el.height();
            shift = (height - windowHeight) / 2;
            if (shift < 0) {
                shift = 0;
            }
            $el.css("top", -shift);
        } else {
            $el.width('auto').height(windowHeight);
            // shift the element left
            var width = $el.width();
            shift = (width - windowWidth) / 2;
            if (shift < 0) {
                shift = 0;
            }
            $el.css("left", -shift);

            // this is a hack mainly due to the iphone
            if (shift === 0) {
                var t = setTimeout(function () {
                    $.fn.videoBG.setFullscreen($el);
                }, 500);
            }
        }

        $('body > .videoBG_wrapper').width(windowWidth).height(windowHeight);

    };

    // get the formatted video element
    $.fn.videoBG.video = function (options) {

        $('html, body').scrollTop(-1);

        // video container
        var $div = $('<div/>');
        $div.addClass('videoBG')
            .css('position', options.position)
            .css('z-index', options.zIndex)
            .css('top', 0)
            .css('left', 0)
            .css('height', options.height)
            .css('width', options.width)
            .css('opacity', options.opacity)
            .css('overflow', 'hidden');

        // video element
        var $video = $('<video/>');
        $video.css('position', 'absolute')
            .css('z-index', options.zIndex)
            .attr('poster', options.poster)
            .css('top', 0)
            .css('left', 0)
            .css('min-width', '100%')
            .css('min-height', '100%');

        if (options.autoplay) {
            $video.attr('autoplay', options.autoplay);
        }

        // if fullscreen
        if (options.fullscreen) {
            $video.bind('canplay', function () {
                // set the aspect ratio
                $video.aspectRatio = $video.width() / $video.height();
                $.fn.videoBG.setFullscreen($video);
            });

            // listen out for screenresize
            var resizeTimeout;
            $(window).resize(function () {
                clearTimeout(resizeTimeout);
                resizeTimeout = setTimeout(function () {
                    $.fn.videoBG.setFullscreen($video);
                }, 100);
            });
            $.fn.videoBG.setFullscreen($video);
        }


        // video standard element
        var v = $video[0];

        // if meant to loop
        if (options.loop) {
            loops_left = options.loop;

            // cant use the loop attribute as firefox doesnt support it
            $video.bind('ended', function () {

                // if we have some loops to throw
                if (loops_left) {
                    // replay that bad boy
                    v.play();
                }

                // if not forever
                if (loops_left !== true) {
                    // one less loop
                    loops_left--;
                }
            });
        }

        // when can play, play
        $video.bind('canplay', function () {

            if (options.autoplay) {
                // replay that bad boy
                v.play();
            }

        });


        // if supports video
        if ($.fn.videoBG.supportsVideo()) {

            // supports webm
            if ($.fn.videoBG.supportType('webm')) {

                // play webm
                $video.attr('src', options.webm);
            }
            // supports mp4
            else if ($.fn.videoBG.supportType('mp4')) {

                // play mp4
                $video.attr('src', options.mp4);
            }
            // throw ogv at it then
            else {

                // play ogv
                $video.attr('src', options.ogv);
            }

        }

        // image for those that dont support the video
        var $img = $('<img/>');
        $img.attr('src', options.poster)
            .css('position', 'absolute')
            .css('z-index', options.zIndex)
            .css('top', 0)
            .css('left', 0)
            .css('min-width', '100%')
            .css('min-height', '100%');

        // add the image to the video
        // if suuports video
        if ($.fn.videoBG.supportsVideo()) {
            // add the video to the wrapper
            $div.html($video);
        }

        // nope - whoa old skool
        else {

            // add the image instead
            $div.html($img);
        }

        // if text replacement
        if (options.textReplacement) {

            // force the heights and widths
            $div.css('min-height', 1).css('min-width', 1);
            $video.css('min-height', 1).css('min-width', 1);
            $img.css('min-height', 1).css('min-width', 1);

            $div.height(options.height).width(options.width);
            $video.height(options.height).width(options.width);
            $img.height(options.height).width(options.width);
        }

        if ($.fn.videoBG.supportsVideo()) {
            v.play();
        }
        return $div;
    };

    // check if suuports video
    $.fn.videoBG.supportsVideo = function () {
        return (document.createElement('video').canPlayType);
    };

    // check which type is supported
    $.fn.videoBG.supportType = function (str) {

        // if not at all supported
        if (!$.fn.videoBG.supportsVideo()) {
            return false;
        }

        // create video
        var v = document.createElement('video');

        // check which?
        switch (str) {
        case 'webm':
            return (v.canPlayType('video/webm; codecs="vp8, vorbis"'));
        case 'mp4':
            return (v.canPlayType('video/mp4; codecs="avc1.42E01E, mp4a.40.2"'));
        case 'ogv':
            return (v.canPlayType('video/ogg; codecs="theora, vorbis"'));
        }
        // nope
        return false;
    };

    // get the overlay wrapper
    $.fn.videoBG.wrapper = function () {
        var $wrap = $('<div/>');
        $wrap.addClass('videoBG_wrapper')
            .css('position', 'absolute')
            .css('top', 0)
            .css('left', 0);
        return $wrap;
    };

    // these are the defaults
    $.fn.videoBG.defaults = {
        mp4: '',
        ogv: '',
        webm: '',
        poster: '',
        autoplay: true,
        loop: true,
        scale: false,
        position: "absolute",
        opacity: 1,
        textReplacement: false,
        zIndex: 0,
        width: 0,
        height: 0,
        fullscreen: false,
        imgFallback: true
    };

})(jQuery);

/**
 * fullPage 2.1.8
 * https://github.com/alvarotrigo/fullPage.js
 * MIT licensed
 *
 * Copyright (C) 2013 alvarotrigo.com - A project by Alvaro Trigo
 */
(function(a){a.fn.fullpage=function(b){function M(){a(".fp-section").each(function(){var c=a(this).find(".fp-slide");c.length?c.each(function(){z(a(this))}):z(a(this))});a.isFunction(b.afterRender)&&b.afterRender.call(this)}function N(){if(!b.autoScrolling){var c=a(window).scrollTop(),d=a(".fp-section").map(function(){if(a(this).offset().top<c+100)return a(this)}),d=d[d.length-1];if(!d.hasClass("active")){var e=a(".fp-section.active").index(".fp-section")+1;F=!0;var f=G(d);d.addClass("active").siblings().removeClass("active");
var g=d.data("anchor");a.isFunction(b.onLeave)&&b.onLeave.call(this,e,d.index(".fp-section")+1,f);a.isFunction(b.afterLoad)&&b.afterLoad.call(this,g,d.index(".fp-section")+1);H(g);I(g,0);b.anchors.length&&!t&&(v=g,location.hash=g);clearTimeout(O);O=setTimeout(function(){F=!1},100)}}}function da(c){var d=c.originalEvent;b.autoScrolling&&c.preventDefault();if(!P(c.target)&&(c=a(".fp-section.active"),!t&&!p))if(d=Q(d),w=d.y,A=d.x,c.find(".fp-slides").length&&Math.abs(B-A)>Math.abs(x-w))Math.abs(B-A)>
a(window).width()/100*b.touchSensitivity&&(B>A?a.fn.fullpage.moveSlideRight():a.fn.fullpage.moveSlideLeft());else if(b.autoScrolling&&(d=c.find(".fp-slides").length?c.find(".fp-slide.active").find(".fp-scrollable"):c.find(".fp-scrollable"),Math.abs(x-w)>a(window).height()/100*b.touchSensitivity))if(x>w)if(0<d.length)if(C("bottom",d))a.fn.fullpage.moveSectionDown();else return!0;else a.fn.fullpage.moveSectionDown();else if(w>x)if(0<d.length)if(C("top",d))a.fn.fullpage.moveSectionUp();else return!0;
else a.fn.fullpage.moveSectionUp()}function P(c,d){d=d||0;var e=a(c).parent();return d<b.normalScrollElementTouchThreshold&&e.is(b.normalScrollElements)?!0:d==b.normalScrollElementTouchThreshold?!1:P(e,++d)}function ea(c){c=Q(c.originalEvent);x=c.y;B=c.x}function n(c){if(b.autoScrolling){c=window.event||c;c=Math.max(-1,Math.min(1,c.wheelDelta||-c.deltaY||-c.detail));var d;d=a(".fp-section.active");if(!t)if(d=d.find(".fp-slides").length?d.find(".fp-slide.active").find(".fp-scrollable"):d.find(".fp-scrollable"),
0>c)if(0<d.length)if(C("bottom",d))a.fn.fullpage.moveSectionDown();else return!0;else a.fn.fullpage.moveSectionDown();else if(0<d.length)if(C("top",d))a.fn.fullpage.moveSectionUp();else return!0;else a.fn.fullpage.moveSectionUp();return!1}}function R(c){var d=a(".fp-section.active").find(".fp-slides");if(d.length&&!p){var e=d.find(".fp-slide.active"),f=null,f="prev"===c?e.prev(".fp-slide"):e.next(".fp-slide");if(!f.length){if(!b.loopHorizontal)return;f="prev"===c?e.siblings(":last"):e.siblings(":first")}p=
!0;q(d,f)}}function k(c,d,e){var f={},g=c.position();if("undefined"!==typeof g){var g=g.top,y=G(c),r=c.data("anchor"),h=c.index(".fp-section"),p=c.find(".fp-slide.active"),s=a(".fp-section.active"),l=s.index(".fp-section")+1,E=D;if(p.length)var n=p.data("anchor"),q=p.index();if(b.autoScrolling&&b.continuousVertical&&"undefined"!==typeof e&&(!e&&"up"==y||e&&"down"==y)){e?a(".fp-section.active").before(s.nextAll(".fp-section")):a(".fp-section.active").after(s.prevAll(".fp-section").get().reverse());
u(a(".fp-section.active").position().top);var k=s,g=c.position(),g=g.top,y=G(c)}c.addClass("active").siblings().removeClass("active");t=!0;"undefined"!==typeof r&&S(q,n,r);b.autoScrolling?(f.top=-g,c="."+T):(f.scrollTop=g,c="html, body");var m=function(){k&&k.length&&(e?a(".fp-section:first").before(k):a(".fp-section:last").after(k),u(a(".fp-section.active").position().top))};b.css3&&b.autoScrolling?(a.isFunction(b.onLeave)&&!E&&b.onLeave.call(this,l,h+1,y),U("translate3d(0px, -"+g+"px, 0px)",!0),
setTimeout(function(){m();a.isFunction(b.afterLoad)&&!E&&b.afterLoad.call(this,r,h+1);setTimeout(function(){t=!1;a.isFunction(d)&&d.call(this)},V)},b.scrollingSpeed)):(a.isFunction(b.onLeave)&&!E&&b.onLeave.call(this,l,h+1,y),a(c).animate(f,b.scrollingSpeed,b.easing,function(){m();a.isFunction(b.afterLoad)&&!E&&b.afterLoad.call(this,r,h+1);setTimeout(function(){t=!1;a.isFunction(d)&&d.call(this)},V)}));v=r;b.autoScrolling&&(H(r),I(r,h))}}function W(){if(!F){var c=window.location.hash.replace("#",
"").split("/"),a=c[0],c=c[1];if(a.length){var b="undefined"===typeof v,f="undefined"===typeof v&&"undefined"===typeof c&&!p;(a&&a!==v&&!b||f||!p&&J!=c)&&K(a,c)}}}function q(c,d){var e=d.position(),f=c.find(".fp-slidesContainer").parent(),g=d.index(),h=c.closest(".fp-section"),r=h.index(".fp-section"),k=h.data("anchor"),l=h.find(".fp-slidesNav"),s=d.data("anchor"),m=D;if(b.onSlideLeave){var n=h.find(".fp-slide.active").index(),q;q=n==g?"none":n>g?"left":"right";m||a.isFunction(b.onSlideLeave)&&b.onSlideLeave.call(this,
k,r+1,n,q)}d.addClass("active").siblings().removeClass("active");"undefined"===typeof s&&(s=g);h.hasClass("active")&&(b.loopHorizontal||(h.find(".fp-controlArrow.fp-prev").toggle(0!=g),h.find(".fp-controlArrow.fp-next").toggle(!d.is(":last-child"))),S(g,s,k));b.css3?(e="translate3d(-"+e.left+"px, 0px, 0px)",c.find(".fp-slidesContainer").toggleClass("fp-easing",0<b.scrollingSpeed).css(X(e)),setTimeout(function(){m||a.isFunction(b.afterSlideLoad)&&b.afterSlideLoad.call(this,k,r+1,s,g);p=!1},b.scrollingSpeed,
b.easing)):f.animate({scrollLeft:e.left},b.scrollingSpeed,b.easing,function(){m||a.isFunction(b.afterSlideLoad)&&b.afterSlideLoad.call(this,k,r+1,s,g);p=!1});l.find(".active").removeClass("active");l.find("li").eq(g).find("a").addClass("active")}function fa(c,d){var b=825,f=c;825>c||900>d?(900>d&&(f=d,b=900),b=(100*f/b).toFixed(2),a("body").css("font-size",b+"%")):a("body").css("font-size","100%")}function I(c,d){b.navigation&&(a("#fp-nav").find(".active").removeClass("active"),c?a("#fp-nav").find('a[href="#'+
c+'"]').addClass("active"):a("#fp-nav").find("li").eq(d).find("a").addClass("active"))}function H(c){b.menu&&(a(b.menu).find(".active").removeClass("active"),a(b.menu).find('[data-menuanchor="'+c+'"]').addClass("active"))}function C(c,a){if("top"===c)return!a.scrollTop();if("bottom"===c)return a.scrollTop()+1+a.innerHeight()>=a[0].scrollHeight}function G(c){var b=a(".fp-section.active").index(".fp-section");c=c.index(".fp-section");return b>c?"up":"down"}function z(a){a.css("overflow","hidden");var d=
a.closest(".fp-section"),e=a.find(".fp-scrollable");if(e.length)var f=e.get(0).scrollHeight;else f=a.get(0).scrollHeight,b.verticalCentered&&(f=a.find(".fp-tableCell").get(0).scrollHeight);d=l-parseInt(d.css("padding-bottom"))-parseInt(d.css("padding-top"));f>d?e.length?e.css("height",d+"px").parent().css("height",d+"px"):(b.verticalCentered?a.find(".fp-tableCell").wrapInner('<div class="fp-scrollable" />'):a.wrapInner('<div class="fp-scrollable" />'),a.find(".fp-scrollable").slimScroll({allowPageScroll:!0,
height:d+"px",size:"10px",alwaysVisible:!0})):Y(a);a.css("overflow","")}function Y(a){a.find(".fp-scrollable").children().first().unwrap().unwrap();a.find(".slimScrollBar").remove();a.find(".slimScrollRail").remove()}function Z(a){a.addClass("fp-table").wrapInner('<div class="fp-tableCell" style="height:'+$(a)+'px;" />')}function $(a){var d=l;if(b.paddingTop||b.paddingBottom)d=a,d.hasClass("fp-section")||(d=a.closest(".fp-section")),a=parseInt(d.css("padding-top"))+parseInt(d.css("padding-bottom")),
d=l-a;return d}function U(a,b){h.toggleClass("fp-easing",b);h.css(X(a))}function K(c,b){"undefined"===typeof b&&(b=0);var e=isNaN(c)?a('[data-anchor="'+c+'"]'):a(".fp-section").eq(c-1);c===v||e.hasClass("active")?aa(e,b):k(e,function(){aa(e,b)})}function aa(a,b){if("undefined"!=typeof b){var e=a.find(".fp-slides"),f=e.find('[data-anchor="'+b+'"]');f.length||(f=e.find(".fp-slide").eq(b));f.length&&q(e,f)}}function ga(a,d){a.append('<div class="fp-slidesNav"><ul></ul></div>');var e=a.find(".fp-slidesNav");
e.addClass(b.slidesNavPosition);for(var f=0;f<d;f++)e.find("ul").append('<li><a href="#"><span></span></a></li>');e.css("margin-left","-"+e.width()/2+"px");e.find("li").first().find("a").addClass("active")}function S(a,d,e){var f="";b.anchors.length&&(a?("undefined"!==typeof e&&(f=e),"undefined"===typeof d&&(d=a),J=d,location.hash=f+"/"+d):("undefined"!==typeof a&&(J=d),location.hash=e))}function ha(){var a=document.createElement("p"),b,e={webkitTransform:"-webkit-transform",OTransform:"-o-transform",
msTransform:"-ms-transform",MozTransform:"-moz-transform",transform:"transform"};document.body.insertBefore(a,null);for(var f in e)void 0!==a.style[f]&&(a.style[f]="translate3d(1px,1px,1px)",b=window.getComputedStyle(a).getPropertyValue(e[f]));document.body.removeChild(a);return void 0!==b&&0<b.length&&"none"!==b}function ba(){return window.PointerEvent?{down:"pointerdown",move:"pointermove"}:{down:"MSPointerDown",move:"MSPointerMove"}}function Q(a){var b=[];window.navigator.msPointerEnabled?(b.y=
a.pageY,b.x=a.pageX):(b.y=a.touches[0].pageY,b.x=a.touches[0].pageX);return b}function u(a){b.css3?U("translate3d(0px, -"+a+"px, 0px)",!1):h.css("top",-a)}function X(a){return{"-webkit-transform":a,"-moz-transform":a,"-ms-transform":a,transform:a}}function ia(){u(0);a("#fp-nav, .fp-slidesNav, .fp-controlArrow").remove();a(".fp-section").css({height:"","background-color":"",padding:""});a(".fp-slide").css({width:""});h.css({height:"",position:"","-ms-touch-action":""});a(".fp-section, .fp-slide").each(function(){Y(a(this));
a(this).removeClass("fp-table active")});h.find(".fp-easing").removeClass("fp-easing");h.find(".fp-tableCell, .fp-slidesContainer, .fp-slides").each(function(){a(this).replaceWith(this.childNodes)});a("html, body").scrollTop(0);h.addClass("fullpage-used")}b=a.extend({verticalCentered:!0,resize:!0,sectionsColor:[],anchors:[],scrollingSpeed:700,easing:"easeInQuart",menu:!1,navigation:!1,navigationPosition:"right",navigationColor:"#000",navigationTooltips:[],slidesNavigation:!1,slidesNavPosition:"bottom",
controlArrowColor:"#fff",loopBottom:!1,loopTop:!1,loopHorizontal:!0,autoScrolling:!0,scrollOverflow:!1,css3:!1,paddingTop:0,paddingBottom:0,fixedElements:null,normalScrollElements:null,keyboardScrolling:!0,touchSensitivity:5,continuousVertical:!1,animateAnchor:!0,normalScrollElementTouchThreshold:5,sectionSelector:".section",slideSelector:".slide",afterLoad:null,onLeave:null,afterRender:null,afterResize:null,afterSlideLoad:null,onSlideLeave:null},b);b.continuousVertical&&(b.loopTop||b.loopBottom)&&
(b.continuousVertical=!1,console&&console.log&&console.log("Option loopTop/loopBottom is mutually exclusive with continuousVertical; continuousVertical disabled"));var V=600;a.fn.fullpage.setAutoScrolling=function(c){b.autoScrolling=c;c=a(".fp-section.active");b.autoScrolling?(a("html, body").css({overflow:"hidden",height:"100%"}),c.length&&u(c.position().top)):(a("html, body").css({overflow:"auto",height:"auto"}),u(0),a("html, body").scrollTop(c.position().top))};a.fn.fullpage.setScrollingSpeed=
function(a){b.scrollingSpeed=a};a.fn.fullpage.setMouseWheelScrolling=function(a){a?document.addEventListener?(document.addEventListener("mousewheel",n,!1),document.addEventListener("wheel",n,!1)):document.attachEvent("onmousewheel",n):document.addEventListener?(document.removeEventListener("mousewheel",n,!1),document.removeEventListener("wheel",n,!1)):document.detachEvent("onmousewheel",n)};a.fn.fullpage.setAllowScrolling=function(b){b?(a.fn.fullpage.setMouseWheelScrolling(!0),L&&(MSPointer=ba(),
a(document).off("touchstart "+MSPointer.down).on("touchstart "+MSPointer.down,ea),a(document).off("touchmove "+MSPointer.move).on("touchmove "+MSPointer.move,da))):(a.fn.fullpage.setMouseWheelScrolling(!1),L&&(MSPointer=ba(),a(document).off("touchstart "+MSPointer.down),a(document).off("touchmove "+MSPointer.move)))};a.fn.fullpage.setKeyboardScrolling=function(a){b.keyboardScrolling=a};var p=!1,L=navigator.userAgent.match(/(iPhone|iPod|iPad|Android|BlackBerry|BB10|Windows Phone|Tizen|Bada)/),h=a(this),
l=a(window).height(),t=!1,D=!1,v,J,T="fullpage-wrapper";a.fn.fullpage.setAllowScrolling(!0);b.css3&&(b.css3=ha());a(this).length?(h.css({height:"100%",position:"relative","-ms-touch-action":"none"}),h.addClass(T)):console.error("Error! Fullpage.js needs to be initialized with a selector. For example: $('#myContainer').fullpage();");a(b.sectionSelector).each(function(){a(this).addClass("fp-section")});a(b.slideSelector).each(function(){a(this).addClass("fp-slide")});if(b.navigation){a("body").append('<div id="fp-nav"><ul></ul></div>');
var m=a("#fp-nav");m.css("color",b.navigationColor);m.addClass(b.navigationPosition)}a(".fp-section").each(function(c){var d=a(this),e=a(this).find(".fp-slide"),f=e.length;c||0!==a(".fp-section.active").length||a(this).addClass("active");a(this).css("height",l+"px");(b.paddingTop||b.paddingBottom)&&a(this).css("padding",b.paddingTop+" 0 "+b.paddingBottom+" 0");"undefined"!==typeof b.sectionsColor[c]&&a(this).css("background-color",b.sectionsColor[c]);"undefined"!==typeof b.anchors[c]&&a(this).attr("data-anchor",
b.anchors[c]);if(b.navigation){var g="";b.anchors.length&&(g=b.anchors[c]);c=b.navigationTooltips[c];"undefined"===typeof c&&(c="");m.find("ul").append('<li data-tooltip="'+c+'"><a href="#'+g+'"><span></span></a></li>')}if(1<f){var g=100*f,h=100/f;e.wrapAll('<div class="fp-slidesContainer" />');e.parent().wrap('<div class="fp-slides" />');a(this).find(".fp-slidesContainer").css("width",g+"%");a(this).find(".fp-slides").after('<div class="fp-controlArrow fp-prev"></div><div class="fp-controlArrow fp-next"></div>');
"#fff"!=b.controlArrowColor&&(a(this).find(".fp-controlArrow.fp-next").css("border-color","transparent transparent transparent "+b.controlArrowColor),a(this).find(".fp-controlArrow.fp-prev").css("border-color","transparent "+b.controlArrowColor+" transparent transparent"));b.loopHorizontal||a(this).find(".fp-controlArrow.fp-prev").hide();b.slidesNavigation&&ga(a(this),f);e.each(function(c){c||0!=d.find(".fp-slide.active").length||a(this).addClass("active");a(this).css("width",h+"%");b.verticalCentered&&
Z(a(this))})}else b.verticalCentered&&Z(a(this))}).promise().done(function(){a.fn.fullpage.setAutoScrolling(b.autoScrolling);var c=a(".fp-section.active").find(".fp-slide.active");if(c.length&&(0!=a(".fp-section.active").index(".fp-section")||0==a(".fp-section.active").index(".fp-section")&&0!=c.index())){var d=b.scrollingSpeed;a.fn.fullpage.setScrollingSpeed(0);q(a(".fp-section.active").find(".fp-slides"),c);a.fn.fullpage.setScrollingSpeed(d)}b.fixedElements&&b.css3&&a(b.fixedElements).appendTo("body");
b.navigation&&(m.css("margin-top","-"+m.height()/2+"px"),m.find("li").eq(a(".fp-section.active").index(".fp-section")).find("a").addClass("active"));b.menu&&b.css3&&a(b.menu).closest(".fullpage-wrapper").length&&a(b.menu).appendTo("body");b.scrollOverflow?(h.hasClass("fullpage-used")&&M(),a(window).on("load",M)):a.isFunction(b.afterRender)&&b.afterRender.call(this);c=window.location.hash.replace("#","").split("/")[0];c.length&&(d=a('[data-anchor="'+c+'"]'),!b.animateAnchor&&d.length&&(b.autoScrolling?
u(d.position().top):(u(0),a("html, body").scrollTop(d.position().top)),H(c),I(c,null),a.isFunction(b.afterLoad)&&b.afterLoad.call(this,c,d.index(".fp-section")+1),d.addClass("active").siblings().removeClass("active")));a(window).on("load",function(){var a=window.location.hash.replace("#","").split("/"),b=a[0],a=a[1];b&&K(b,a)})});var O,F=!1;a(window).on("scroll",N);var x=0,B=0,w=0,A=0;a.fn.fullpage.moveSectionUp=function(){var c=a(".fp-section.active").prev(".fp-section");c.length||!b.loopTop&&!b.continuousVertical||
(c=a(".fp-section").last());c.length&&k(c,null,!0)};a.fn.fullpage.moveSectionDown=function(){var c=a(".fp-section.active").next(".fp-section");c.length||!b.loopBottom&&!b.continuousVertical||(c=a(".fp-section").first());(0<c.length||!c.length&&(b.loopBottom||b.continuousVertical))&&k(c,null,!1)};a.fn.fullpage.moveTo=function(b,d){var e="",e=isNaN(b)?a('[data-anchor="'+b+'"]'):a(".fp-section").eq(b-1);"undefined"!==typeof d?K(b,d):0<e.length&&k(e)};a.fn.fullpage.moveSlideRight=function(){R("next")};
a.fn.fullpage.moveSlideLeft=function(){R("prev")};a(window).on("hashchange",W);a(document).keydown(function(c){if(b.keyboardScrolling&&!t)switch(c.which){case 38:case 33:a.fn.fullpage.moveSectionUp();break;case 40:case 34:a.fn.fullpage.moveSectionDown();break;case 36:a.fn.fullpage.moveTo(1);break;case 35:a.fn.fullpage.moveTo(a(".fp-section").length);break;case 37:a.fn.fullpage.moveSlideLeft();break;case 39:a.fn.fullpage.moveSlideRight()}});a(document).on("click","#fp-nav a",function(b){b.preventDefault();
b=a(this).parent().index();k(a(".fp-section").eq(b))});a(document).on({mouseenter:function(){var c=a(this).data("tooltip");a('<div class="fp-tooltip '+b.navigationPosition+'">'+c+"</div>").hide().appendTo(a(this)).fadeIn(200)},mouseleave:function(){a(this).find(".fp-tooltip").fadeOut().remove()}},"#fp-nav li");b.normalScrollElements&&(a(document).on("mouseover",b.normalScrollElements,function(){a.fn.fullpage.setMouseWheelScrolling(!1)}),a(document).on("mouseout",b.normalScrollElements,function(){a.fn.fullpage.setMouseWheelScrolling(!0)}));
a(".fp-section").on("click",".fp-controlArrow",function(){a(this).hasClass("fp-prev")?a.fn.fullpage.moveSlideLeft():a.fn.fullpage.moveSlideRight()});a(".fp-section").on("click",".toSlide",function(b){b.preventDefault();b=a(this).closest(".fp-section").find(".fp-slides");b.find(".fp-slide.active");var d=null,d=b.find(".fp-slide").eq(a(this).data("index")-1);0<d.length&&q(b,d)});var ca;a(window).resize(function(){L?a.fn.fullpage.reBuild():(clearTimeout(ca),ca=setTimeout(a.fn.fullpage.reBuild,500))});
a.fn.fullpage.reBuild=function(){D=!0;var c=a(window).width();l=a(window).height();b.resize&&fa(l,c);a(".fp-section").each(function(){parseInt(a(this).css("padding-bottom"));parseInt(a(this).css("padding-top"));b.verticalCentered&&a(this).find(".fp-tableCell").css("height",$(a(this))+"px");a(this).css("height",l+"px");if(b.scrollOverflow){var c=a(this).find(".fp-slide");c.length?c.each(function(){z(a(this))}):z(a(this))}c=a(this).find(".fp-slides");c.length&&q(c,c.find(".fp-slide.active"))});a(".fp-section.active").position();
c=a(".fp-section.active");c.index(".fp-section")&&k(c);D=!1;a.isFunction(b.afterResize)&&b.afterResize.call(this)};a(document).on("click",".fp-slidesNav a",function(b){b.preventDefault();b=a(this).closest(".fp-section").find(".fp-slides");var d=b.find(".fp-slide").eq(a(this).closest("li").index());q(b,d)});a.fn.fullpage.destroy=function(c){a.fn.fullpage.setAutoScrolling(!1);a.fn.fullpage.setAllowScrolling(!1);a.fn.fullpage.setKeyboardScrolling(!1);a(window).off("scroll",N).off("hashchange",W);a(document).off("click",
"#fp-nav a").off("mouseenter","#fp-nav li").off("mouseleave","#fp-nav li").off("click",".fp-slidesNav a").off("mouseover",b.normalScrollElements).off("mouseout",b.normalScrollElements);a(".fp-section").off("click",".fp-controlArrow").off("click",".toSlide");c&&ia()}}})(jQuery);
/*! Copyright (c) 2011 Piotr Rochala (http://rocha.la)
 * Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
 * and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 *
 * Version: 1.3.2 (modified for fullpage.js)
 *
 */
(function(f){jQuery.fn.extend({slimScroll:function(g){var a=f.extend({width:"auto",height:"250px",size:"7px",color:"#000",position:"right",distance:"1px",start:"top",opacity:.4,alwaysVisible:!1,disableFadeOut:!1,railVisible:!1,railColor:"#333",railOpacity:.2,railDraggable:!0,railClass:"slimScrollRail",barClass:"slimScrollBar",wrapperClass:"slimScrollDiv",allowPageScroll:!1,wheelStep:20,touchScrollStep:200,borderRadius:"7px",railBorderRadius:"7px"},g);this.each(function(){function s(d){d=d||window.event;
var c=0;d.wheelDelta&&(c=-d.wheelDelta/120);d.detail&&(c=d.detail/3);f(d.target||d.srcTarget||d.srcElement).closest("."+a.wrapperClass).is(b.parent())&&m(c,!0);d.preventDefault&&!k&&d.preventDefault();k||(d.returnValue=!1)}function m(d,f,g){k=!1;var e=d,h=b.outerHeight()-c.outerHeight();f&&(e=parseInt(c.css("top"))+d*parseInt(a.wheelStep)/100*c.outerHeight(),e=Math.min(Math.max(e,0),h),e=0<d?Math.ceil(e):Math.floor(e),c.css({top:e+"px"}));l=parseInt(c.css("top"))/(b.outerHeight()-c.outerHeight());
e=l*(b[0].scrollHeight-b.outerHeight());g&&(e=d,d=e/b[0].scrollHeight*b.outerHeight(),d=Math.min(Math.max(d,0),h),c.css({top:d+"px"}));b.scrollTop(e);b.trigger("slimscrolling",~~e);u();p()}function C(){window.addEventListener?(this.addEventListener("DOMMouseScroll",s,!1),this.addEventListener("mousewheel",s,!1)):document.attachEvent("onmousewheel",s)}function v(){r=Math.max(b.outerHeight()/b[0].scrollHeight*b.outerHeight(),D);c.css({height:r+"px"});var a=r==b.outerHeight()?"none":"block";c.css({display:a})}
function u(){v();clearTimeout(A);l==~~l?(k=a.allowPageScroll,B!=l&&b.trigger("slimscroll",0==~~l?"top":"bottom")):k=!1;B=l;r>=b.outerHeight()?k=!0:(c.stop(!0,!0).fadeIn("fast"),a.railVisible&&h.stop(!0,!0).fadeIn("fast"))}function p(){a.alwaysVisible||(A=setTimeout(function(){a.disableFadeOut&&w||x||y||(c.fadeOut("slow"),h.fadeOut("slow"))},1E3))}var w,x,y,A,z,r,l,B,D=30,k=!1,b=f(this);if(b.parent().hasClass(a.wrapperClass)){var n=b.scrollTop(),c=b.parent().find("."+a.barClass),h=b.parent().find("."+
a.railClass);v();if(f.isPlainObject(g)){if("height"in g&&"auto"==g.height){b.parent().css("height","auto");b.css("height","auto");var q=b.parent().parent().height();b.parent().css("height",q);b.css("height",q)}if("scrollTo"in g)n=parseInt(a.scrollTo);else if("scrollBy"in g)n+=parseInt(a.scrollBy);else if("destroy"in g){c.remove();h.remove();b.unwrap();return}m(n,!1,!0)}}else{a.height="auto"==g.height?b.parent().height():g.height;n=f("<div></div>").addClass(a.wrapperClass).css({position:"relative",
overflow:"hidden",width:a.width,height:a.height});b.css({overflow:"hidden",width:a.width,height:a.height});var h=f("<div></div>").addClass(a.railClass).css({width:a.size,height:"100%",position:"absolute",top:0,display:a.alwaysVisible&&a.railVisible?"block":"none","border-radius":a.railBorderRadius,background:a.railColor,opacity:a.railOpacity,zIndex:90}),c=f("<div></div>").addClass(a.barClass).css({background:a.color,width:a.size,position:"absolute",top:0,opacity:a.opacity,display:a.alwaysVisible?
"block":"none","border-radius":a.borderRadius,BorderRadius:a.borderRadius,MozBorderRadius:a.borderRadius,WebkitBorderRadius:a.borderRadius,zIndex:99}),q="right"==a.position?{right:a.distance}:{left:a.distance};h.css(q);c.css(q);b.wrap(n);b.parent().append(c);b.parent().append(h);a.railDraggable&&c.bind("mousedown",function(a){var b=f(document);y=!0;t=parseFloat(c.css("top"));pageY=a.pageY;b.bind("mousemove.slimscroll",function(a){currTop=t+a.pageY-pageY;c.css("top",currTop);m(0,c.position().top,!1)});
b.bind("mouseup.slimscroll",function(a){y=!1;p();b.unbind(".slimscroll")});return!1}).bind("selectstart.slimscroll",function(a){a.stopPropagation();a.preventDefault();return!1});h.hover(function(){u()},function(){p()});c.hover(function(){x=!0},function(){x=!1});b.hover(function(){w=!0;u();p()},function(){w=!1;p()});b.bind("touchstart",function(a,b){a.originalEvent.touches.length&&(z=a.originalEvent.touches[0].pageY)});b.bind("touchmove",function(b){k||b.originalEvent.preventDefault();b.originalEvent.touches.length&&
(m((z-b.originalEvent.touches[0].pageY)/a.touchScrollStep,!0),z=b.originalEvent.touches[0].pageY)});v();"bottom"===a.start?(c.css({top:b.outerHeight()-c.outerHeight()}),m(0,!0)):"top"!==a.start&&(m(f(a.start).position().top,null,!0),a.alwaysVisible||c.hide());C()}});return this}});jQuery.fn.extend({slimscroll:jQuery.fn.slimScroll})})(jQuery);
/*! jQuery UI - v1.9.2 - 2014-03-21
* http://jqueryui.com
* Includes: jquery.ui.effect.js
* Copyright 2014 jQuery Foundation and other contributors; Licensed MIT */

jQuery.effects||function(e,t){var i=e.uiBackCompat!==!1,a="ui-effects-";e.effects={effect:{}},function(t,i){function a(e,t,i){var a=c[t.type]||{};return null==e?i||!t.def?null:t.def:(e=a.floor?~~e:parseFloat(e),isNaN(e)?t.def:a.mod?(e+a.mod)%a.mod:0>e?0:e>a.max?a.max:e)}function s(e){var a=u(),s=a._rgba=[];return e=e.toLowerCase(),m(l,function(t,n){var r,o=n.re.exec(e),h=o&&n.parse(o),l=n.space||"rgba";return h?(r=a[l](h),a[d[l].cache]=r[d[l].cache],s=a._rgba=r._rgba,!1):i}),s.length?("0,0,0,0"===s.join()&&t.extend(s,r.transparent),a):r[e]}function n(e,t,i){return i=(i+1)%1,1>6*i?e+6*(t-e)*i:1>2*i?t:2>3*i?e+6*(t-e)*(2/3-i):e}var r,o="backgroundColor borderBottomColor borderLeftColor borderRightColor borderTopColor color columnRuleColor outlineColor textDecorationColor textEmphasisColor".split(" "),h=/^([\-+])=\s*(\d+\.?\d*)/,l=[{re:/rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)/,parse:function(e){return[e[1],e[2],e[3],e[4]]}},{re:/rgba?\(\s*(\d+(?:\.\d+)?)\%\s*,\s*(\d+(?:\.\d+)?)\%\s*,\s*(\d+(?:\.\d+)?)\%\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)/,parse:function(e){return[2.55*e[1],2.55*e[2],2.55*e[3],e[4]]}},{re:/#([a-f0-9]{2})([a-f0-9]{2})([a-f0-9]{2})/,parse:function(e){return[parseInt(e[1],16),parseInt(e[2],16),parseInt(e[3],16)]}},{re:/#([a-f0-9])([a-f0-9])([a-f0-9])/,parse:function(e){return[parseInt(e[1]+e[1],16),parseInt(e[2]+e[2],16),parseInt(e[3]+e[3],16)]}},{re:/hsla?\(\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\%\s*,\s*(\d+(?:\.\d+)?)\%\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)/,space:"hsla",parse:function(e){return[e[1],e[2]/100,e[3]/100,e[4]]}}],u=t.Color=function(e,i,a,s){return new t.Color.fn.parse(e,i,a,s)},d={rgba:{props:{red:{idx:0,type:"byte"},green:{idx:1,type:"byte"},blue:{idx:2,type:"byte"}}},hsla:{props:{hue:{idx:0,type:"degrees"},saturation:{idx:1,type:"percent"},lightness:{idx:2,type:"percent"}}}},c={"byte":{floor:!0,max:255},percent:{max:1},degrees:{mod:360,floor:!0}},p=u.support={},f=t("<p>")[0],m=t.each;f.style.cssText="background-color:rgba(1,1,1,.5)",p.rgba=f.style.backgroundColor.indexOf("rgba")>-1,m(d,function(e,t){t.cache="_"+e,t.props.alpha={idx:3,type:"percent",def:1}}),u.fn=t.extend(u.prototype,{parse:function(n,o,h,l){if(n===i)return this._rgba=[null,null,null,null],this;(n.jquery||n.nodeType)&&(n=t(n).css(o),o=i);var c=this,p=t.type(n),f=this._rgba=[];return o!==i&&(n=[n,o,h,l],p="array"),"string"===p?this.parse(s(n)||r._default):"array"===p?(m(d.rgba.props,function(e,t){f[t.idx]=a(n[t.idx],t)}),this):"object"===p?(n instanceof u?m(d,function(e,t){n[t.cache]&&(c[t.cache]=n[t.cache].slice())}):m(d,function(t,i){var s=i.cache;m(i.props,function(e,t){if(!c[s]&&i.to){if("alpha"===e||null==n[e])return;c[s]=i.to(c._rgba)}c[s][t.idx]=a(n[e],t,!0)}),c[s]&&0>e.inArray(null,c[s].slice(0,3))&&(c[s][3]=1,i.from&&(c._rgba=i.from(c[s])))}),this):i},is:function(e){var t=u(e),a=!0,s=this;return m(d,function(e,n){var r,o=t[n.cache];return o&&(r=s[n.cache]||n.to&&n.to(s._rgba)||[],m(n.props,function(e,t){return null!=o[t.idx]?a=o[t.idx]===r[t.idx]:i})),a}),a},_space:function(){var e=[],t=this;return m(d,function(i,a){t[a.cache]&&e.push(i)}),e.pop()},transition:function(e,t){var i=u(e),s=i._space(),n=d[s],r=0===this.alpha()?u("transparent"):this,o=r[n.cache]||n.to(r._rgba),h=o.slice();return i=i[n.cache],m(n.props,function(e,s){var n=s.idx,r=o[n],l=i[n],u=c[s.type]||{};null!==l&&(null===r?h[n]=l:(u.mod&&(l-r>u.mod/2?r+=u.mod:r-l>u.mod/2&&(r-=u.mod)),h[n]=a((l-r)*t+r,s)))}),this[s](h)},blend:function(e){if(1===this._rgba[3])return this;var i=this._rgba.slice(),a=i.pop(),s=u(e)._rgba;return u(t.map(i,function(e,t){return(1-a)*s[t]+a*e}))},toRgbaString:function(){var e="rgba(",i=t.map(this._rgba,function(e,t){return null==e?t>2?1:0:e});return 1===i[3]&&(i.pop(),e="rgb("),e+i.join()+")"},toHslaString:function(){var e="hsla(",i=t.map(this.hsla(),function(e,t){return null==e&&(e=t>2?1:0),t&&3>t&&(e=Math.round(100*e)+"%"),e});return 1===i[3]&&(i.pop(),e="hsl("),e+i.join()+")"},toHexString:function(e){var i=this._rgba.slice(),a=i.pop();return e&&i.push(~~(255*a)),"#"+t.map(i,function(e){return e=(e||0).toString(16),1===e.length?"0"+e:e}).join("")},toString:function(){return 0===this._rgba[3]?"transparent":this.toRgbaString()}}),u.fn.parse.prototype=u.fn,d.hsla.to=function(e){if(null==e[0]||null==e[1]||null==e[2])return[null,null,null,e[3]];var t,i,a=e[0]/255,s=e[1]/255,n=e[2]/255,r=e[3],o=Math.max(a,s,n),h=Math.min(a,s,n),l=o-h,u=o+h,d=.5*u;return t=h===o?0:a===o?60*(s-n)/l+360:s===o?60*(n-a)/l+120:60*(a-s)/l+240,i=0===d||1===d?d:.5>=d?l/u:l/(2-u),[Math.round(t)%360,i,d,null==r?1:r]},d.hsla.from=function(e){if(null==e[0]||null==e[1]||null==e[2])return[null,null,null,e[3]];var t=e[0]/360,i=e[1],a=e[2],s=e[3],r=.5>=a?a*(1+i):a+i-a*i,o=2*a-r;return[Math.round(255*n(o,r,t+1/3)),Math.round(255*n(o,r,t)),Math.round(255*n(o,r,t-1/3)),s]},m(d,function(e,s){var n=s.props,r=s.cache,o=s.to,l=s.from;u.fn[e]=function(e){if(o&&!this[r]&&(this[r]=o(this._rgba)),e===i)return this[r].slice();var s,h=t.type(e),d="array"===h||"object"===h?e:arguments,c=this[r].slice();return m(n,function(e,t){var i=d["object"===h?e:t.idx];null==i&&(i=c[t.idx]),c[t.idx]=a(i,t)}),l?(s=u(l(c)),s[r]=c,s):u(c)},m(n,function(i,a){u.fn[i]||(u.fn[i]=function(s){var n,r=t.type(s),o="alpha"===i?this._hsla?"hsla":"rgba":e,l=this[o](),u=l[a.idx];return"undefined"===r?u:("function"===r&&(s=s.call(this,u),r=t.type(s)),null==s&&a.empty?this:("string"===r&&(n=h.exec(s),n&&(s=u+parseFloat(n[2])*("+"===n[1]?1:-1))),l[a.idx]=s,this[o](l)))})})}),m(o,function(e,i){t.cssHooks[i]={set:function(e,a){var n,r,o="";if("string"!==t.type(a)||(n=s(a))){if(a=u(n||a),!p.rgba&&1!==a._rgba[3]){for(r="backgroundColor"===i?e.parentNode:e;(""===o||"transparent"===o)&&r&&r.style;)try{o=t.css(r,"backgroundColor"),r=r.parentNode}catch(h){}a=a.blend(o&&"transparent"!==o?o:"_default")}a=a.toRgbaString()}try{e.style[i]=a}catch(l){}}},t.fx.step[i]=function(e){e.colorInit||(e.start=u(e.elem,i),e.end=u(e.end),e.colorInit=!0),t.cssHooks[i].set(e.elem,e.start.transition(e.end,e.pos))}}),t.cssHooks.borderColor={expand:function(e){var t={};return m(["Top","Right","Bottom","Left"],function(i,a){t["border"+a+"Color"]=e}),t}},r=t.Color.names={aqua:"#00ffff",black:"#000000",blue:"#0000ff",fuchsia:"#ff00ff",gray:"#808080",green:"#008000",lime:"#00ff00",maroon:"#800000",navy:"#000080",olive:"#808000",purple:"#800080",red:"#ff0000",silver:"#c0c0c0",teal:"#008080",white:"#ffffff",yellow:"#ffff00",transparent:[null,null,null,0],_default:"#ffffff"}}(jQuery),function(){function i(){var t,i,a=this.ownerDocument.defaultView?this.ownerDocument.defaultView.getComputedStyle(this,null):this.currentStyle,s={};if(a&&a.length&&a[0]&&a[a[0]])for(i=a.length;i--;)t=a[i],"string"==typeof a[t]&&(s[e.camelCase(t)]=a[t]);else for(t in a)"string"==typeof a[t]&&(s[t]=a[t]);return s}function a(t,i){var a,s,r={};for(a in i)s=i[a],t[a]!==s&&(n[a]||(e.fx.step[a]||!isNaN(parseFloat(s)))&&(r[a]=s));return r}var s=["add","remove","toggle"],n={border:1,borderBottom:1,borderColor:1,borderLeft:1,borderRight:1,borderTop:1,borderWidth:1,margin:1,padding:1};e.each(["borderLeftStyle","borderRightStyle","borderBottomStyle","borderTopStyle"],function(t,i){e.fx.step[i]=function(e){("none"!==e.end&&!e.setAttr||1===e.pos&&!e.setAttr)&&(jQuery.style(e.elem,i,e.end),e.setAttr=!0)}}),e.effects.animateClass=function(t,n,r,o){var h=e.speed(n,r,o);return this.queue(function(){var n,r=e(this),o=r.attr("class")||"",l=h.children?r.find("*").andSelf():r;l=l.map(function(){var t=e(this);return{el:t,start:i.call(this)}}),n=function(){e.each(s,function(e,i){t[i]&&r[i+"Class"](t[i])})},n(),l=l.map(function(){return this.end=i.call(this.el[0]),this.diff=a(this.start,this.end),this}),r.attr("class",o),l=l.map(function(){var t=this,i=e.Deferred(),a=jQuery.extend({},h,{queue:!1,complete:function(){i.resolve(t)}});return this.el.animate(this.diff,a),i.promise()}),e.when.apply(e,l.get()).done(function(){n(),e.each(arguments,function(){var t=this.el;e.each(this.diff,function(e){t.css(e,"")})}),h.complete.call(r[0])})})},e.fn.extend({_addClass:e.fn.addClass,addClass:function(t,i,a,s){return i?e.effects.animateClass.call(this,{add:t},i,a,s):this._addClass(t)},_removeClass:e.fn.removeClass,removeClass:function(t,i,a,s){return i?e.effects.animateClass.call(this,{remove:t},i,a,s):this._removeClass(t)},_toggleClass:e.fn.toggleClass,toggleClass:function(i,a,s,n,r){return"boolean"==typeof a||a===t?s?e.effects.animateClass.call(this,a?{add:i}:{remove:i},s,n,r):this._toggleClass(i,a):e.effects.animateClass.call(this,{toggle:i},a,s,n)},switchClass:function(t,i,a,s,n){return e.effects.animateClass.call(this,{add:i,remove:t},a,s,n)}})}(),function(){function s(t,i,a,s){return e.isPlainObject(t)&&(i=t,t=t.effect),t={effect:t},null==i&&(i={}),e.isFunction(i)&&(s=i,a=null,i={}),("number"==typeof i||e.fx.speeds[i])&&(s=a,a=i,i={}),e.isFunction(a)&&(s=a,a=null),i&&e.extend(t,i),a=a||i.duration,t.duration=e.fx.off?0:"number"==typeof a?a:a in e.fx.speeds?e.fx.speeds[a]:e.fx.speeds._default,t.complete=s||i.complete,t}function n(t){return!t||"number"==typeof t||e.fx.speeds[t]?!0:"string"!=typeof t||e.effects.effect[t]?!1:i&&e.effects[t]?!1:!0}e.extend(e.effects,{version:"1.9.2",save:function(e,t){for(var i=0;t.length>i;i++)null!==t[i]&&e.data(a+t[i],e[0].style[t[i]])},restore:function(e,i){var s,n;for(n=0;i.length>n;n++)null!==i[n]&&(s=e.data(a+i[n]),s===t&&(s=""),e.css(i[n],s))},setMode:function(e,t){return"toggle"===t&&(t=e.is(":hidden")?"show":"hide"),t},getBaseline:function(e,t){var i,a;switch(e[0]){case"top":i=0;break;case"middle":i=.5;break;case"bottom":i=1;break;default:i=e[0]/t.height}switch(e[1]){case"left":a=0;break;case"center":a=.5;break;case"right":a=1;break;default:a=e[1]/t.width}return{x:a,y:i}},createWrapper:function(t){if(t.parent().is(".ui-effects-wrapper"))return t.parent();var i={width:t.outerWidth(!0),height:t.outerHeight(!0),"float":t.css("float")},a=e("<div></div>").addClass("ui-effects-wrapper").css({fontSize:"100%",background:"transparent",border:"none",margin:0,padding:0}),s={width:t.width(),height:t.height()},n=document.activeElement;try{n.id}catch(r){n=document.body}return t.wrap(a),(t[0]===n||e.contains(t[0],n))&&e(n).focus(),a=t.parent(),"static"===t.css("position")?(a.css({position:"relative"}),t.css({position:"relative"})):(e.extend(i,{position:t.css("position"),zIndex:t.css("z-index")}),e.each(["top","left","bottom","right"],function(e,a){i[a]=t.css(a),isNaN(parseInt(i[a],10))&&(i[a]="auto")}),t.css({position:"relative",top:0,left:0,right:"auto",bottom:"auto"})),t.css(s),a.css(i).show()},removeWrapper:function(t){var i=document.activeElement;return t.parent().is(".ui-effects-wrapper")&&(t.parent().replaceWith(t),(t[0]===i||e.contains(t[0],i))&&e(i).focus()),t},setTransition:function(t,i,a,s){return s=s||{},e.each(i,function(e,i){var n=t.cssUnit(i);n[0]>0&&(s[i]=n[0]*a+n[1])}),s}}),e.fn.extend({effect:function(){function t(t){function i(){e.isFunction(n)&&n.call(s[0]),e.isFunction(t)&&t()}var s=e(this),n=a.complete,r=a.mode;(s.is(":hidden")?"hide"===r:"show"===r)?i():o.call(s[0],a,i)}var a=s.apply(this,arguments),n=a.mode,r=a.queue,o=e.effects.effect[a.effect],h=!o&&i&&e.effects[a.effect];return e.fx.off||!o&&!h?n?this[n](a.duration,a.complete):this.each(function(){a.complete&&a.complete.call(this)}):o?r===!1?this.each(t):this.queue(r||"fx",t):h.call(this,{options:a,duration:a.duration,callback:a.complete,mode:a.mode})},_show:e.fn.show,show:function(e){if(n(e))return this._show.apply(this,arguments);var t=s.apply(this,arguments);return t.mode="show",this.effect.call(this,t)},_hide:e.fn.hide,hide:function(e){if(n(e))return this._hide.apply(this,arguments);var t=s.apply(this,arguments);return t.mode="hide",this.effect.call(this,t)},__toggle:e.fn.toggle,toggle:function(t){if(n(t)||"boolean"==typeof t||e.isFunction(t))return this.__toggle.apply(this,arguments);var i=s.apply(this,arguments);return i.mode="toggle",this.effect.call(this,i)},cssUnit:function(t){var i=this.css(t),a=[];return e.each(["em","px","%","pt"],function(e,t){i.indexOf(t)>0&&(a=[parseFloat(i),t])}),a}})}(),function(){var t={};e.each(["Quad","Cubic","Quart","Quint","Expo"],function(e,i){t[i]=function(t){return Math.pow(t,e+2)}}),e.extend(t,{Sine:function(e){return 1-Math.cos(e*Math.PI/2)},Circ:function(e){return 1-Math.sqrt(1-e*e)},Elastic:function(e){return 0===e||1===e?e:-Math.pow(2,8*(e-1))*Math.sin((80*(e-1)-7.5)*Math.PI/15)},Back:function(e){return e*e*(3*e-2)},Bounce:function(e){for(var t,i=4;((t=Math.pow(2,--i))-1)/11>e;);return 1/Math.pow(4,3-i)-7.5625*Math.pow((3*t-2)/22-e,2)}}),e.each(t,function(t,i){e.easing["easeIn"+t]=i,e.easing["easeOut"+t]=function(e){return 1-i(1-e)},e.easing["easeInOut"+t]=function(e){return.5>e?i(2*e)/2:1-i(-2*e+2)/2}})}()}(jQuery);

  (function(t,e){if(typeof define==="function"&&define.amd){define(["jquery"],e)}else if(typeof exports==="object"){module.exports=e(require("jquery"))}else{e(t.jQuery)}})(this,function(t){t.transit={version:"0.9.12",propertyMap:{marginLeft:"margin",marginRight:"margin",marginBottom:"margin",marginTop:"margin",paddingLeft:"padding",paddingRight:"padding",paddingBottom:"padding",paddingTop:"padding"},enabled:true,useTransitionEnd:false};var e=document.createElement("div");var n={};function i(t){if(t in e.style)return t;var n=["Moz","Webkit","O","ms"];var i=t.charAt(0).toUpperCase()+t.substr(1);for(var r=0;r<n.length;++r){var s=n[r]+i;if(s in e.style){return s}}}function r(){e.style[n.transform]="";e.style[n.transform]="rotateY(90deg)";return e.style[n.transform]!==""}var s=navigator.userAgent.toLowerCase().indexOf("chrome")>-1;n.transition=i("transition");n.transitionDelay=i("transitionDelay");n.transform=i("transform");n.transformOrigin=i("transformOrigin");n.filter=i("Filter");n.transform3d=r();var a={transition:"transitionend",MozTransition:"transitionend",OTransition:"oTransitionEnd",WebkitTransition:"webkitTransitionEnd",msTransition:"MSTransitionEnd"};var o=n.transitionEnd=a[n.transition]||null;for(var u in n){if(n.hasOwnProperty(u)&&typeof t.support[u]==="undefined"){t.support[u]=n[u]}}e=null;t.cssEase={_default:"ease","in":"ease-in",out:"ease-out","in-out":"ease-in-out",snap:"cubic-bezier(0,1,.5,1)",easeInCubic:"cubic-bezier(.550,.055,.675,.190)",easeOutCubic:"cubic-bezier(.215,.61,.355,1)",easeInOutCubic:"cubic-bezier(.645,.045,.355,1)",easeInCirc:"cubic-bezier(.6,.04,.98,.335)",easeOutCirc:"cubic-bezier(.075,.82,.165,1)",easeInOutCirc:"cubic-bezier(.785,.135,.15,.86)",easeInExpo:"cubic-bezier(.95,.05,.795,.035)",easeOutExpo:"cubic-bezier(.19,1,.22,1)",easeInOutExpo:"cubic-bezier(1,0,0,1)",easeInQuad:"cubic-bezier(.55,.085,.68,.53)",easeOutQuad:"cubic-bezier(.25,.46,.45,.94)",easeInOutQuad:"cubic-bezier(.455,.03,.515,.955)",easeInQuart:"cubic-bezier(.895,.03,.685,.22)",easeOutQuart:"cubic-bezier(.165,.84,.44,1)",easeInOutQuart:"cubic-bezier(.77,0,.175,1)",easeInQuint:"cubic-bezier(.755,.05,.855,.06)",easeOutQuint:"cubic-bezier(.23,1,.32,1)",easeInOutQuint:"cubic-bezier(.86,0,.07,1)",easeInSine:"cubic-bezier(.47,0,.745,.715)",easeOutSine:"cubic-bezier(.39,.575,.565,1)",easeInOutSine:"cubic-bezier(.445,.05,.55,.95)",easeInBack:"cubic-bezier(.6,-.28,.735,.045)",easeOutBack:"cubic-bezier(.175, .885,.32,1.275)",easeInOutBack:"cubic-bezier(.68,-.55,.265,1.55)"};t.cssHooks["transit:transform"]={get:function(e){return t(e).data("transform")||new f},set:function(e,i){var r=i;if(!(r instanceof f)){r=new f(r)}if(n.transform==="WebkitTransform"&&!s){e.style[n.transform]=r.toString(true)}else{e.style[n.transform]=r.toString()}t(e).data("transform",r)}};t.cssHooks.transform={set:t.cssHooks["transit:transform"].set};t.cssHooks.filter={get:function(t){return t.style[n.filter]},set:function(t,e){t.style[n.filter]=e}};if(t.fn.jquery<"1.8"){t.cssHooks.transformOrigin={get:function(t){return t.style[n.transformOrigin]},set:function(t,e){t.style[n.transformOrigin]=e}};t.cssHooks.transition={get:function(t){return t.style[n.transition]},set:function(t,e){t.style[n.transition]=e}}}p("scale");p("scaleX");p("scaleY");p("translate");p("rotate");p("rotateX");p("rotateY");p("rotate3d");p("perspective");p("skewX");p("skewY");p("x",true);p("y",true);function f(t){if(typeof t==="string"){this.parse(t)}return this}f.prototype={setFromString:function(t,e){var n=typeof e==="string"?e.split(","):e.constructor===Array?e:[e];n.unshift(t);f.prototype.set.apply(this,n)},set:function(t){var e=Array.prototype.slice.apply(arguments,[1]);if(this.setter[t]){this.setter[t].apply(this,e)}else{this[t]=e.join(",")}},get:function(t){if(this.getter[t]){return this.getter[t].apply(this)}else{return this[t]||0}},setter:{rotate:function(t){this.rotate=b(t,"deg")},rotateX:function(t){this.rotateX=b(t,"deg")},rotateY:function(t){this.rotateY=b(t,"deg")},scale:function(t,e){if(e===undefined){e=t}this.scale=t+","+e},skewX:function(t){this.skewX=b(t,"deg")},skewY:function(t){this.skewY=b(t,"deg")},perspective:function(t){this.perspective=b(t,"px")},x:function(t){this.set("translate",t,null)},y:function(t){this.set("translate",null,t)},translate:function(t,e){if(this._translateX===undefined){this._translateX=0}if(this._translateY===undefined){this._translateY=0}if(t!==null&&t!==undefined){this._translateX=b(t,"px")}if(e!==null&&e!==undefined){this._translateY=b(e,"px")}this.translate=this._translateX+","+this._translateY}},getter:{x:function(){return this._translateX||0},y:function(){return this._translateY||0},scale:function(){var t=(this.scale||"1,1").split(",");if(t[0]){t[0]=parseFloat(t[0])}if(t[1]){t[1]=parseFloat(t[1])}return t[0]===t[1]?t[0]:t},rotate3d:function(){var t=(this.rotate3d||"0,0,0,0deg").split(",");for(var e=0;e<=3;++e){if(t[e]){t[e]=parseFloat(t[e])}}if(t[3]){t[3]=b(t[3],"deg")}return t}},parse:function(t){var e=this;t.replace(/([a-zA-Z0-9]+)\((.*?)\)/g,function(t,n,i){e.setFromString(n,i)})},toString:function(t){var e=[];for(var i in this){if(this.hasOwnProperty(i)){if(!n.transform3d&&(i==="rotateX"||i==="rotateY"||i==="perspective"||i==="transformOrigin")){continue}if(i[0]!=="_"){if(t&&i==="scale"){e.push(i+"3d("+this[i]+",1)")}else if(t&&i==="translate"){e.push(i+"3d("+this[i]+",0)")}else{e.push(i+"("+this[i]+")")}}}}return e.join(" ")}};function c(t,e,n){if(e===true){t.queue(n)}else if(e){t.queue(e,n)}else{t.each(function(){n.call(this)})}}function l(e){var i=[];t.each(e,function(e){e=t.camelCase(e);e=t.transit.propertyMap[e]||t.cssProps[e]||e;e=h(e);if(n[e])e=h(n[e]);if(t.inArray(e,i)===-1){i.push(e)}});return i}function d(e,n,i,r){var s=l(e);if(t.cssEase[i]){i=t.cssEase[i]}var a=""+y(n)+" "+i;if(parseInt(r,10)>0){a+=" "+y(r)}var o=[];t.each(s,function(t,e){o.push(e+" "+a)});return o.join(", ")}t.fn.transition=t.fn.transit=function(e,i,r,s){var a=this;var u=0;var f=true;var l=t.extend(true,{},e);if(typeof i==="function"){s=i;i=undefined}if(typeof i==="object"){r=i.easing;u=i.delay||0;f=typeof i.queue==="undefined"?true:i.queue;s=i.complete;i=i.duration}if(typeof r==="function"){s=r;r=undefined}if(typeof l.easing!=="undefined"){r=l.easing;delete l.easing}if(typeof l.duration!=="undefined"){i=l.duration;delete l.duration}if(typeof l.complete!=="undefined"){s=l.complete;delete l.complete}if(typeof l.queue!=="undefined"){f=l.queue;delete l.queue}if(typeof l.delay!=="undefined"){u=l.delay;delete l.delay}if(typeof i==="undefined"){i=t.fx.speeds._default}if(typeof r==="undefined"){r=t.cssEase._default}i=y(i);var p=d(l,i,r,u);var h=t.transit.enabled&&n.transition;var b=h?parseInt(i,10)+parseInt(u,10):0;if(b===0){var g=function(t){a.css(l);if(s){s.apply(a)}if(t){t()}};c(a,f,g);return a}var m={};var v=function(e){var i=false;var r=function(){if(i){a.unbind(o,r)}if(b>0){a.each(function(){this.style[n.transition]=m[this]||null})}if(typeof s==="function"){s.apply(a)}if(typeof e==="function"){e()}};if(b>0&&o&&t.transit.useTransitionEnd){i=true;a.bind(o,r)}else{window.setTimeout(r,b)}a.each(function(){if(b>0){this.style[n.transition]=p}t(this).css(l)})};var z=function(t){this.offsetWidth;v(t)};c(a,f,z);return this};function p(e,i){if(!i){t.cssNumber[e]=true}t.transit.propertyMap[e]=n.transform;t.cssHooks[e]={get:function(n){var i=t(n).css("transit:transform");return i.get(e)},set:function(n,i){var r=t(n).css("transit:transform");r.setFromString(e,i);t(n).css({"transit:transform":r})}}}function h(t){return t.replace(/([A-Z])/g,function(t){return"-"+t.toLowerCase()})}function b(t,e){if(typeof t==="string"&&!t.match(/^[\-0-9\.]+$/)){return t}else{return""+t+e}}function y(e){var n=e;if(typeof n==="string"&&!n.match(/^[\-0-9\.]+/)){n=t.fx.speeds[n]||t.fx.speeds._default}return b(n,"ms")}t.transit.getTransitionValue=d;return t});
/*!
 * headhesive v1.1.1 - An on-demand sticky header
 * Url: http://markgoodyear.com/labs/headhesive
 * Copyright (c) Mark Goodyear — @markgdyr — http://markgoodyear.com
 * License: MIT
 */
!function(t,s,e){"use strict";function i(t){for(var s=0;t;)s+=t.offsetTop,t=t.offsetParent;return s}var o=function(t,s){for(var e in s)s.hasOwnProperty(e)&&(t[e]="object"==typeof s[e]?o(t[e],s[e]):s[e]);return t},n=function(t,s){var e,i,o,n=Date.now||function(){return(new Date).getTime()},l=null,c=0,h=function(){c=n(),l=null,o=t.apply(e,i),e=i=null};return function(){var r=n(),f=s-(r-c);return e=this,i=arguments,0>=f?(clearTimeout(l),l=null,c=r,o=t.apply(e,i),e=i=null):l||(l=setTimeout(h,f)),o}},l=function(){return t.pageYOffset!==e?t.pageYOffset:(s.documentElement||s.body.parentNode||s.body).scrollTop},c=function(e,i){"querySelector"in s&&"addEventListener"in t&&(this.visible=!1,this.options={offset:300,classes:{clone:"headhesive",stick:"headhesive--stick",unstick:"headhesive--unstick"},throttle:250,onInit:function(){},onStick:function(){},onUnstick:function(){},onDestroy:function(){}},this.elem="string"==typeof e?s.querySelector(e):e,this.options=o(this.options,i),this.init())};c.prototype={constructor:c,init:function(){if(this.clonedElem=this.elem.cloneNode(!0),this.clonedElem.className+=" "+this.options.classes.clone,s.body.insertBefore(this.clonedElem,s.body.firstChild),"number"==typeof this.options.offset)this.scrollOffset=this.options.offset;else{if("string"!=typeof this.options.offset)throw new Error("Invalid offset: "+this.options.offset);this.scrollOffset=i(s.querySelector(this.options.offset))}this._throttleUpdate=n(this.update.bind(this),this.options.throttle),t.addEventListener("scroll",this._throttleUpdate,!1),this.options.onInit.call(this)},destroy:function(){s.body.removeChild(this.clonedElem),t.removeEventListener("scroll",this._throttleUpdate),this.options.onDestroy.call(this)},stick:function(){this.visible||(this.clonedElem.className=this.clonedElem.className.replace(new RegExp("(^|\\s)*"+this.options.classes.unstick+"(\\s|$)*","g"),""),this.clonedElem.className+=" "+this.options.classes.stick,this.visible=!0,this.options.onStick.call(this))},unstick:function(){this.visible&&(this.clonedElem.className=this.clonedElem.className.replace(new RegExp("(^|\\s)*"+this.options.classes.stick+"(\\s|$)*","g"),""),this.clonedElem.className+=" "+this.options.classes.unstick,this.visible=!1,this.options.onUnstick.call(this))},update:function(){l()>this.scrollOffset?this.stick():this.unstick()}},t.Headhesive=c}(window,document);
!function(a,b,c){"use strict";var d=function(d,e){var f=!!b.getComputedStyle;f||(b.getComputedStyle=function(a){return this.el=a,this.getPropertyValue=function(b){var c=/(\-([a-z]){1})/g;return"float"===b&&(b="styleFloat"),c.test(b)&&(b=b.replace(c,function(){return arguments[2].toUpperCase()})),a.currentStyle[b]?a.currentStyle[b]:null},this});var g,h,i,j,k,l,m=function(a,b,c,d){if("addEventListener"in a)try{a.addEventListener(b,c,d)}catch(e){if("object"!=typeof c||!c.handleEvent)throw e;a.addEventListener(b,function(a){c.handleEvent.call(c,a)},d)}else"attachEvent"in a&&("object"==typeof c&&c.handleEvent?a.attachEvent("on"+b,function(){c.handleEvent.call(c)}):a.attachEvent("on"+b,c))},n=function(a,b,c,d){if("removeEventListener"in a)try{a.removeEventListener(b,c,d)}catch(e){if("object"!=typeof c||!c.handleEvent)throw e;a.removeEventListener(b,function(a){c.handleEvent.call(c,a)},d)}else"detachEvent"in a&&("object"==typeof c&&c.handleEvent?a.detachEvent("on"+b,function(){c.handleEvent.call(c)}):a.detachEvent("on"+b,c))},o=function(a){if(a.children.length<1)throw new Error("The Nav container has no containing elements");for(var b=[],c=0;c<a.children.length;c++)1===a.children[c].nodeType&&b.push(a.children[c]);return b},p=function(a,b){for(var c in b)a.setAttribute(c,b[c])},q=function(a,b){0!==a.className.indexOf(b)&&(a.className+=" "+b,a.className=a.className.replace(/(^\s*)|(\s*$)/g,""))},r=function(a,b){var c=new RegExp("(\\s|^)"+b+"(\\s|$)");a.className=a.className.replace(c," ").replace(/(^\s*)|(\s*$)/g,"")},s=function(a,b,c){for(var d=0;d<a.length;d++)b.call(c,d,a[d])},t=a.createElement("style"),u=a.documentElement,v=function(b,c){var d;this.options={animate:!0,transition:284,label:"Menu",insert:"before",customToggle:"",closeOnNavClick:!1,openPos:"relative",navClass:"nav-collapse",navActiveClass:"js-nav-active",jsClass:"js",init:function(){},open:function(){},close:function(){}};for(d in c)this.options[d]=c[d];if(q(u,this.options.jsClass),this.wrapperEl=b.replace("#",""),a.getElementById(this.wrapperEl))this.wrapper=a.getElementById(this.wrapperEl);else{if(!a.querySelector(this.wrapperEl))throw new Error("The nav element you are trying to select doesn't exist");this.wrapper=a.querySelector(this.wrapperEl)}this.wrapper.inner=o(this.wrapper),h=this.options,g=this.wrapper,this._init(this)};return v.prototype={destroy:function(){this._removeStyles(),r(g,"closed"),r(g,"opened"),r(g,h.navClass),r(g,h.navClass+"-"+this.index),r(u,h.navActiveClass),g.removeAttribute("style"),g.removeAttribute("aria-hidden"),n(b,"resize",this,!1),n(a.body,"touchmove",this,!1),n(i,"touchstart",this,!1),n(i,"touchend",this,!1),n(i,"mouseup",this,!1),n(i,"keyup",this,!1),n(i,"click",this,!1),h.customToggle?i.removeAttribute("aria-hidden"):i.parentNode.removeChild(i)},toggle:function(){j===!0&&(l?this.close():this.open())},open:function(){l||(r(g,"closed"),q(g,"opened"),q(u,h.navActiveClass),q(i,"active"),g.style.position=h.openPos,p(g,{"aria-hidden":"false"}),l=!0,h.open())},close:function(){l&&(q(g,"closed"),r(g,"opened"),r(u,h.navActiveClass),r(i,"active"),p(g,{"aria-hidden":"true"}),h.animate?(j=!1,setTimeout(function(){g.style.position="absolute",j=!0},h.transition+10)):g.style.position="absolute",l=!1,h.close())},resize:function(){"none"!==b.getComputedStyle(i,null).getPropertyValue("display")?(k=!0,p(i,{"aria-hidden":"false"}),g.className.match(/(^|\s)closed(\s|$)/)&&(p(g,{"aria-hidden":"true"}),g.style.position="absolute"),this._createStyles(),this._calcHeight()):(k=!1,p(i,{"aria-hidden":"true"}),p(g,{"aria-hidden":"false"}),g.style.position=h.openPos,this._removeStyles())},handleEvent:function(a){var c=a||b.event;switch(c.type){case"touchstart":this._onTouchStart(c);break;case"touchmove":this._onTouchMove(c);break;case"touchend":case"mouseup":this._onTouchEnd(c);break;case"click":this._preventDefault(c);break;case"keyup":this._onKeyUp(c);break;case"resize":this.resize(c)}},_init:function(){this.index=c++,q(g,h.navClass),q(g,h.navClass+"-"+this.index),q(g,"closed"),j=!0,l=!1,this._closeOnNavClick(),this._createToggle(),this._transitions(),this.resize();var d=this;setTimeout(function(){d.resize()},20),m(b,"resize",this,!1),m(a.body,"touchmove",this,!1),m(i,"touchstart",this,!1),m(i,"touchend",this,!1),m(i,"mouseup",this,!1),m(i,"keyup",this,!1),m(i,"click",this,!1),h.init()},_createStyles:function(){t.parentNode||(t.type="text/css",a.getElementsByTagName("head")[0].appendChild(t))},_removeStyles:function(){t.parentNode&&t.parentNode.removeChild(t)},_createToggle:function(){if(h.customToggle){var b=h.customToggle.replace("#","");if(a.getElementById(b))i=a.getElementById(b);else{if(!a.querySelector(b))throw new Error("The custom nav toggle you are trying to select doesn't exist");i=a.querySelector(b)}}else{var c=a.createElement("a");c.innerHTML=h.label,p(c,{href:"#","class":"nav-toggle"}),"after"===h.insert?g.parentNode.insertBefore(c,g.nextSibling):g.parentNode.insertBefore(c,g),i=c}},_closeOnNavClick:function(){if(h.closeOnNavClick&&"querySelectorAll"in a){var b=g.querySelectorAll("a"),c=this;s(b,function(a){m(b[a],"click",function(){k&&c.toggle()},!1)})}},_preventDefault:function(a){a.preventDefault?(a.preventDefault(),a.stopPropagation()):a.returnValue=!1},_onTouchStart:function(b){b.stopPropagation(),"after"===h.insert&&q(a.body,"disable-pointer-events"),this.startX=b.touches[0].clientX,this.startY=b.touches[0].clientY,this.touchHasMoved=!1,n(i,"mouseup",this,!1)},_onTouchMove:function(a){(Math.abs(a.touches[0].clientX-this.startX)>10||Math.abs(a.touches[0].clientY-this.startY)>10)&&(this.touchHasMoved=!0)},_onTouchEnd:function(c){if(this._preventDefault(c),!this.touchHasMoved){if("touchend"===c.type)return this.toggle(),"after"===h.insert&&setTimeout(function(){r(a.body,"disable-pointer-events")},h.transition+300),void 0;var d=c||b.event;3!==d.which&&2!==d.button&&this.toggle()}},_onKeyUp:function(a){var c=a||b.event;13===c.keyCode&&this.toggle()},_transitions:function(){if(h.animate){var a=g.style,b="max-height "+h.transition+"ms";a.WebkitTransition=b,a.MozTransition=b,a.OTransition=b,a.transition=b}},_calcHeight:function(){for(var a=0,b=0;b<g.inner.length;b++)a+=g.inner[b].offsetHeight;var c="."+h.jsClass+" ."+h.navClass+"-"+this.index+".opened{max-height:"+a+"px !important}";t.styleSheet?t.styleSheet.cssText=c:t.innerHTML=c,c=""}},new v(d,e)};b.responsiveNav=d}(document,window,0);      
//fgnass.github.com/spin.js#v2.0.1
!function(a,b){"object"==typeof exports?module.exports=b():"function"==typeof define&&define.amd?define(b):a.Spinner=b()}(this,function(){"use strict";function a(a,b){var c,d=document.createElement(a||"div");for(c in b)d[c]=b[c];return d}function b(a){for(var b=1,c=arguments.length;c>b;b++)a.appendChild(arguments[b]);return a}function c(a,b,c,d){var e=["opacity",b,~~(100*a),c,d].join("-"),f=.01+c/d*100,g=Math.max(1-(1-a)/b*(100-f),a),h=j.substring(0,j.indexOf("Animation")).toLowerCase(),i=h&&"-"+h+"-"||"";return l[e]||(m.insertRule("@"+i+"keyframes "+e+"{0%{opacity:"+g+"}"+f+"%{opacity:"+a+"}"+(f+.01)+"%{opacity:1}"+(f+b)%100+"%{opacity:"+a+"}100%{opacity:"+g+"}}",m.cssRules.length),l[e]=1),e}function d(a,b){var c,d,e=a.style;for(b=b.charAt(0).toUpperCase()+b.slice(1),d=0;d<k.length;d++)if(c=k[d]+b,void 0!==e[c])return c;return void 0!==e[b]?b:void 0}function e(a,b){for(var c in b)a.style[d(a,c)||c]=b[c];return a}function f(a){for(var b=1;b<arguments.length;b++){var c=arguments[b];for(var d in c)void 0===a[d]&&(a[d]=c[d])}return a}function g(a,b){return"string"==typeof a?a:a[b%a.length]}function h(a){this.opts=f(a||{},h.defaults,n)}function i(){function c(b,c){return a("<"+b+' xmlns="urn:schemas-microsoft.com:vml" class="spin-vml">',c)}m.addRule(".spin-vml","behavior:url(#default#VML)"),h.prototype.lines=function(a,d){function f(){return e(c("group",{coordsize:k+" "+k,coordorigin:-j+" "+-j}),{width:k,height:k})}function h(a,h,i){b(m,b(e(f(),{rotation:360/d.lines*a+"deg",left:~~h}),b(e(c("roundrect",{arcsize:d.corners}),{width:j,height:d.width,left:d.radius,top:-d.width>>1,filter:i}),c("fill",{color:g(d.color,a),opacity:d.opacity}),c("stroke",{opacity:0}))))}var i,j=d.length+d.width,k=2*j,l=2*-(d.width+d.length)+"px",m=e(f(),{position:"absolute",top:l,left:l});if(d.shadow)for(i=1;i<=d.lines;i++)h(i,-2,"progid:DXImageTransform.Microsoft.Blur(pixelradius=2,makeshadow=1,shadowopacity=.3)");for(i=1;i<=d.lines;i++)h(i);return b(a,m)},h.prototype.opacity=function(a,b,c,d){var e=a.firstChild;d=d.shadow&&d.lines||0,e&&b+d<e.childNodes.length&&(e=e.childNodes[b+d],e=e&&e.firstChild,e=e&&e.firstChild,e&&(e.opacity=c))}}var j,k=["webkit","Moz","ms","O"],l={},m=function(){var c=a("style",{type:"text/css"});return b(document.getElementsByTagName("head")[0],c),c.sheet||c.styleSheet}(),n={lines:12,length:7,width:5,radius:10,rotate:0,corners:1,color:"#000",direction:1,speed:1,trail:100,opacity:.25,fps:20,zIndex:2e9,className:"spinner",top:"50%",left:"50%",position:"absolute"};h.defaults={},f(h.prototype,{spin:function(b){this.stop();{var c=this,d=c.opts,f=c.el=e(a(0,{className:d.className}),{position:d.position,width:0,zIndex:d.zIndex});d.radius+d.length+d.width}if(e(f,{left:d.left,top:d.top}),b&&b.insertBefore(f,b.firstChild||null),f.setAttribute("role","progressbar"),c.lines(f,c.opts),!j){var g,h=0,i=(d.lines-1)*(1-d.direction)/2,k=d.fps,l=k/d.speed,m=(1-d.opacity)/(l*d.trail/100),n=l/d.lines;!function o(){h++;for(var a=0;a<d.lines;a++)g=Math.max(1-(h+(d.lines-a)*n)%l*m,d.opacity),c.opacity(f,a*d.direction+i,g,d);c.timeout=c.el&&setTimeout(o,~~(1e3/k))}()}return c},stop:function(){var a=this.el;return a&&(clearTimeout(this.timeout),a.parentNode&&a.parentNode.removeChild(a),this.el=void 0),this},lines:function(d,f){function h(b,c){return e(a(),{position:"absolute",width:f.length+f.width+"px",height:f.width+"px",background:b,boxShadow:c,transformOrigin:"left",transform:"rotate("+~~(360/f.lines*k+f.rotate)+"deg) translate("+f.radius+"px,0)",borderRadius:(f.corners*f.width>>1)+"px"})}for(var i,k=0,l=(f.lines-1)*(1-f.direction)/2;k<f.lines;k++)i=e(a(),{position:"absolute",top:1+~(f.width/2)+"px",transform:f.hwaccel?"translate3d(0,0,0)":"",opacity:f.opacity,animation:j&&c(f.opacity,f.trail,l+k*f.direction,f.lines)+" "+1/f.speed+"s linear infinite"}),f.shadow&&b(i,e(h("#000","0 0 4px #000"),{top:"2px"})),b(d,b(i,h(g(f.color,k),"0 0 1px rgba(0,0,0,.1)")));return d},opacity:function(a,b,c){b<a.childNodes.length&&(a.childNodes[b].style.opacity=c)}});var o=e(a("group"),{behavior:"url(#default#VML)"});return!d(o,"transform")&&o.adj?i():j=d(o,"animation"),h});