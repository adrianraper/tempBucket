package com.clarityenglish.ielts.view.title
{
	import flashx.textLayout.elements.TextFlow;
	
	import spark.components.RichEditableText;
	import spark.components.supportClasses.ButtonBarBase;
	import spark.components.supportClasses.ButtonBase;
	
	public class InforButton extends ButtonBase {
		[SkinPart]
		public var richText:RichEditableText;
		
		private var _richTextFlow:TextFlow;
		
		[Bindable]
		public function get richTextFlow():TextFlow {
			return _richTextFlow;
		}
		
		public function set richTextFlow(value:TextFlow):void {
			_richTextFlow = value;
		}
	}
}