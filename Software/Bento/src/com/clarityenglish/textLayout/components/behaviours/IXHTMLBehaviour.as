package com.clarityenglish.textLayout.components.behaviours {
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flashx.textLayout.elements.TextFlow;
	
	public interface IXHTMLBehaviour {
		
		function onCreateChildren():void;
		
		function onTextFlowUpdate(textFlow:TextFlow):void;
		
		function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void;
		
	}
	
}