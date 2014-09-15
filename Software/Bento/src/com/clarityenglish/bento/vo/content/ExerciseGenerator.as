package com.clarityenglish.bento.vo.content {
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.SubParagraphGroupElement;
	import flashx.textLayout.elements.TextFlow;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.utils.TextFlowUtil;
	
	/**
	 * @author
	 */
	public class ExerciseGenerator extends XHTML {
		
		public static const QUESTIONS:String = "questions";
		public static const TEXT:String = "text";
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public function ExerciseGenerator(value:XML = null, href:Href = null, useCacheBuster:Boolean = false) {
			super(value, href, useCacheBuster);
		}
		
		public function get authoring():XML {
			return selectOne("script#authoring[type='application/xml']");
		}
		
		public function get settings():XML {
			return authoring.hasOwnProperty("settings") ? authoring.settings[0] : null;
		}
		
		public function get questions():XML {
			return authoring.hasOwnProperty("questions") ? authoring.questions[0] : null;
		}
		
		public function get exerciseType():String {
			return hasSettingParam("exerciseType") ? getSettingParam("exerciseType") : null;
		}
		
		public function get layoutType():String {
			return hasSettingParam("questionNumberingEnabled") ? QUESTIONS : TEXT;
		}
		
		public function hasSettingParam(paramName:String):Boolean {
			return (settings && settings[paramName].length() > 0);
		}
		
		public function getSettingParam(paramName:String):* {
			var value:* = hasSettingParam(paramName) ? settings[paramName].text() : null;
			
			if (value == "true") return true;
			if (value == "false") return false;
			
			return value;
		}
		
		public function htmlToTextFlow(xmlString:String):TextFlow {
			switch (exerciseType) {
				case Question.MULTIPLE_CHOICE_QUESTION: return new GapQuestionConverter().htmlToTlfString(xmlString);
				case Question.GAP_FILL_QUESTION: return new GapQuestionConverter().htmlToTlfString(xmlString);
			}
			
			return TextFlowUtil.importFromString(xmlString);
		}
		
		public function textFlowToHtml(textFlow:TextFlow):String {
			switch (exerciseType) {
				case Question.MULTIPLE_CHOICE_QUESTION: return new GapQuestionConverter().textFlowToHtml(textFlow).toXMLString();
				case Question.GAP_FILL_QUESTION: return new GapQuestionConverter().textFlowToHtml(textFlow).toXMLString();
			}
			
			return TextFlowUtil.export(textFlow).toString();
		}
		
	}
}
import flashx.textLayout.elements.FlowElement;
import flashx.textLayout.elements.FlowGroupElement;
import flashx.textLayout.elements.SpanElement;
import flashx.textLayout.elements.SubParagraphGroupElement;
import flashx.textLayout.elements.TextFlow;

import spark.utils.TextFlowUtil;

interface IQuestionConverter {
	function htmlToTextFlow(xmlString:String):TextFlow;
	function textFlowToHtml(flowElement:FlowElement):XML;	
}

// It actually might turn out that we only need a single converter for all question types...
class GapQuestionConverter {
	
	public function htmlToTlfString(xmlString:String):TextFlow {
		var tlfString:String = "";
		tlfString += '<TextFlow xmlns="http://ns.adobe.com/textLayout/2008">';
		tlfString += xmlString.replace(/<input id="(\w+)" placeholder="(.+)" ?\/>/g, '<g id="$1"><span textDecoration="underline">$2</span></g>');
		tlfString += '</TextFlow>';
		return TextFlowUtil.importFromString(tlfString);
	}
	
	public function textFlowToHtml(flowElement:FlowElement):XML {
		if (flowElement.typeName == "TextFlow") return textFlowToHtml((flowElement as TextFlow).getChildAt(0));
		
		var node:XML = new XML("<" + flowElement.typeName + " />");
		if (flowElement.id) node.@id = flowElement.id;
		if (flowElement is SpanElement) node.appendChild((flowElement as SpanElement).text);
		if (flowElement is SubParagraphGroupElement) return <input id={flowElement.id} placeholder={((flowElement as FlowGroupElement).getChildAt(0) as SpanElement).text}></input>;
		if (flowElement is FlowGroupElement)
			for each (var childFlowElement:FlowElement in (flowElement as FlowGroupElement).mxmlChildren)
			node.appendChild(textFlowToHtml(childFlowElement));
		
		return node;
	}
	
}