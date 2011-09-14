package com.clarityenglish.textLayout.components.behaviours {
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	public interface IXHTMLBehaviour {
		
		function onCreateChildren():void;
		
		function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void;
		
	}
	
}