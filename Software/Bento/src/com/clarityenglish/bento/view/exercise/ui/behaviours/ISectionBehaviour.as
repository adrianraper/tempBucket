package com.clarityenglish.bento.view.exercise.ui.behaviours {
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	
	import flash.events.MouseEvent;
	
	import flashx.textLayout.elements.TextFlow;
	
	public interface ISectionBehaviour {
		
		function onCreateChildren():void;
		
		function onTextFlowUpdate(textFlow:TextFlow):void;
		
		function onTextFlowClear(textFlow:TextFlow):void;
		
		function onClick(event:MouseEvent, textFlow:TextFlow):void;
		
		function onImportComplete(html:XML, textFlow:TextFlow, exercise:Exercise, flowElementXmlBiMap:FlowElementXmlBiMap):void;
		
	}
	
}