package com.clarityenglish.bento.controller {
import com.clarityenglish.bento.model.ExerciseProxy;
import com.clarityenglish.bento.vo.content.Exercise;
import com.clarityenglish.bento.vo.content.model.answer.Answer;
import com.clarityenglish.bento.vo.content.model.answer.Feedback;
import com.clarityenglish.common.model.CopyProxy;
import com.clarityenglish.common.model.interfaces.CopyProvider;
import com.clarityenglish.textLayout.components.XHTMLRichText;
import com.clarityenglish.textLayout.events.XHTMLEvent;
import com.clarityenglish.textLayout.rendering.RenderFlow;
import com.clarityenglish.textLayout.vo.XHTML;
import com.newgonzo.web.css.CSSComputedStyle;

import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.ui.Keyboard;
import flash.utils.setTimeout;

import flashx.textLayout.formats.TextAlign;

import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.events.FlexMouseEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.IFocusManagerComponent;
import mx.managers.PopUpManager;
import mx.managers.PopUpManagerChildList;

import org.davekeen.util.ClassUtil;
import org.osmf.layout.HorizontalAlign;
import org.puremvc.as3.interfaces.INotification;
import org.puremvc.as3.patterns.command.SimpleCommand;

import spark.components.Group;
import spark.components.HGroup;

import spark.components.Scroller;
import spark.components.SkinnableContainer;
import spark.components.TextInput;
import spark.components.TitleWindow;
import spark.events.TitleWindowBoundsEvent;

public class SmallFeedbackShowCommand extends SimpleCommand {

    /**
     * Standard flex logger
     */
    private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));

    private static var feedbackContainer:SkinnableContainer;

    private static var feedbackContainerwAdded:Boolean;

    private static var bounds:Rectangle;

    private static var container:Group;

    private var feedback:Feedback;

    public override function execute(note:INotification):void {
        super.execute(note);

        // gh#1373 use the bounds to detect whether the titleWindow had been closed or not.
        if (bounds) onClosePopUp();
        bounds = note.getBody().bounds;
        feedback = note.getBody().smallFeedback as Feedback;
        var xhtml:XHTML = note.getBody().exercise as XHTML;
        var substitutions:Object = note.getBody().substitutions;
        container = note.getBody().container;
        container.stage.addEventListener(MouseEvent.CLICK, onStageClick);

        var feedbackNode:XML = xhtml.selectOne("#" + feedback.source);
        if (feedbackNode && bounds) {
            if (substitutions) {
                // Since we might change the XHTML during the substitution phase, we need to clone it
                xhtml = xhtml.clone();

                // Do string substitutions
                var xmlString:String = xhtml.xml;

                for (var find:String in substitutions) {
                    var replace:String = substitutions[find];
                    // gh#269 there may be more than one feedback has score parameter
                    while (xmlString.search("{{=" + find + "}}") > 0)
                        xmlString = xmlString.replace("{{=" + find + "}}", replace);
                }
                xhtml.xml = new XML(xmlString);
            }

            if (!feedbackContainer) {
                feedbackContainer = new SkinnableContainer();
                feedbackContainer.styleName = "smallFeedbackContainer";
            }

            // Create an XHTMLRichText component and add it to the title window
            var xhtmlRichText:XHTMLRichText = new XHTMLRichText();

            // Default to 300 width, variable height unless defined otherwise in the XML
            xhtmlRichText.width = (isNaN(feedback.width)) ? 100 : feedback.width;
            if (!isNaN(feedback.height)) xhtmlRichText.height = feedback.height;

            xhtmlRichText.xhtml = xhtml;
            xhtmlRichText.nodeId = "#" + feedback.source;
            xhtmlRichText.addEventListener(XHTMLEvent.CSS_PARSED, onCssParsed);

            // #127
            var scroller:Scroller = new Scroller();
            scroller.left = 10;
            scroller.right = 0;
            scroller.top = 5;
            scroller.bottom = 5;
            // gh#701
            scroller.minWidth = 0;
            scroller.height = 20;
            scroller.viewport = xhtmlRichText;
            feedbackContainer.addElement(scroller);

            // #210, #256
            var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(note.getBody().exercise as Exercise)) as ExerciseProxy;
            exerciseProxy.exerciseFeedbackSeen = true;

            // This is very hacky, but otherwise the feedback popup can hijack uncommitted textfields and break the tab flow.  There is probably
            // a neater way to do this, but this works and doesn't seem to do any harm.
            // gh#1299 If this is a dropdownquestion, delay a little longer to give the popup selector time to go
            // No, that doesn't have any impact
            if (!feedbackContainerwAdded) setTimeout(addPopupWindow, 100, xhtmlRichText.width );
        } else if (!feedbackNode) {
            log.error("Unable to find feedback source {0}", feedback.source);
        } else if (!bounds) {
            log.error("No position information, cannot place small feedback");
        }
    }

    private function addPopupWindow():void {
        feedbackContainer.x = bounds.x - (arguments[0] - bounds.width) / 2 - 3;
        feedbackContainer.y = bounds.y - 45;
        container.addElement(feedbackContainer);
        feedbackContainerwAdded = true;

        // Add a keyboard listener so the user can close the feedback window with the keyboard.  This listener needs a brief delay before being
        // added as otherwise its possible to trigger the feedback window with the same key that closes it, hence closing it instantly.
        setTimeout(function ():void {
            (FlexGlobals.topLevelApplication as DisplayObject).stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown);
        }, 300);
    }

    protected function onCssParsed(event:Event):void {
        var xhtmlRichText:XHTMLRichText = event.target as XHTMLRichText;

        xhtmlRichText.removeEventListener(XHTMLEvent.CSS_PARSED, onCssParsed);
    }

    /**
     * The escape and enter keys also close the popup
     *
     * @param event
     */
    protected function onKeyboardDown(event:KeyboardEvent):void {
        if (event.keyCode == Keyboard.ESCAPE) {
            onClosePopUp();
        } else if (event.keyCode == Keyboard.ENTER && feedbackContainer) {
            var focus:IFocusManagerComponent = feedbackContainer.focusManager.getFocus();
            if (!focus || !(focus is TextInput)) // #265(d) - don't close the popup if focus is in a gapfill
                onClosePopUp();
        }
    }

    /**
     * Close the popup and make all variables eligible for garbage collection
     *
     * @param event
     */
    protected function onClosePopUp(event:CloseEvent = null):void {
        if (feedbackContainerwAdded) {
            container.removeElement(feedbackContainer);
            container.stage.removeEventListener(MouseEvent.CLICK, onStageClick);

            feedbackContainerwAdded = false;
            feedbackContainer = null;
            feedback = null;
            bounds = null;
            container = null;
        }
    }

    protected function onStageClick(event:Event):void {
        onClosePopUp();
    }

}

}