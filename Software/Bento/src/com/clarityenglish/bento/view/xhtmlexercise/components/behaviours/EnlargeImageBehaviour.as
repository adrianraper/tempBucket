package com.clarityenglish.bento.view.xhtmlexercise.components.behaviours {
import com.clarityenglish.bento.view.xhtmlexercise.events.ImageEvent;
import com.clarityenglish.bento.vo.content.Exercise;
import com.clarityenglish.textLayout.components.behaviours.AbstractXHTMLBehaviour;
import com.clarityenglish.textLayout.components.behaviours.IXHTMLBehaviour;
import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
import com.clarityenglish.textLayout.vo.XHTML;

import flash.events.IEventDispatcher;

import flashx.textLayout.elements.FlowElement;

import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.FlowElementMouseEvent;
import flashx.textLayout.tlf_internal;

import org.davekeen.util.Closure;

import spark.components.Group;

use namespace tlf_internal;

    public class EnlargeImageBehaviour extends AbstractXHTMLBehaviour implements IXHTMLBehaviour {

        private var rootPath:String;

        public function EnlargeImageBehaviour(container:Group) {
            super(container);
        }

        public function onTextFlowUpdate(textFlow:TextFlow):void { }

        public function onCreateChildren():void { }

        public function onTextFlowClear(textFlow:TextFlow):void { }

        public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void {
            var exercise:Exercise = xhtml as Exercise;
            rootPath = xhtml.rootPath;

            for each (var imgNode:XML in exercise.xml..img) {
                if (imgNode.attribute("largeWidth").length() > 0 && imgNode.attribute("largeHeight").length() > 0) {
                    var flowElement:FlowElement = flowElementXmlBiMap.getFlowElement(imgNode);
                    if (flowElement) {
                        var eventMirror:IEventDispatcher = flowElement.tlf_internal::getEventMirror();
                        if (eventMirror) {
                            eventMirror.addEventListener(FlowElementMouseEvent.CLICK, Closure.create(this, onClick, imgNode.@src, imgNode.@largeWidth, imgNode.@largeHeight));
                        } else {
                            log.error("Attempt to bind a click handler to non-leaf element {0}", flowElement);
                        }
                    }
                }
            }
        }

        private function onClick(e:FlowElementMouseEvent, source:String, width:String = null, height:String = null):void {
            var image:Object = {source: updateWithRootPath(source), width: Number(width) * 2, height: Number(height) * 2};
            container.dispatchEvent(new ImageEvent(ImageEvent.IMAGE_ENLARGE, image, true));
        }

        // copy from InlineGraphicElement.as to form the full path for image.
        private function updateWithRootPath(url:String):String {
            // If rootPath is defined and the url isn't a web address then prepend the url with the root path
            if (rootPath && url.search(/^https?:\/\/.*/i) < 0)
                url = ((rootPath) ? rootPath + "/" : "") + url;

            return url;
        }
    }
}
