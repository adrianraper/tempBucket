package com.clarityenglish.clearpronunciation.view.exercise {
	import com.clarityenglish.bento.view.base.BentoView;
	
	import flashx.textLayout.elements.TextFlow;
	
	import spark.components.Label;
	import spark.components.RichText;
	import spark.utils.TextFlowUtil;
	
	public class YouWillView extends BentoView {
		
		[SkinPart]
		public var youWillRichText:RichText;
		
		private var _labelString:String;
		
		[Bindable]
		public function get labelString():String {
			return _labelString;
		}
		
		public function set labelString(value:String):void {
			_labelString = value;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case youWillRichText:
					var youWillString:String = copyProvider.getCopyForId(labelString);
					trace("youWillString: "+youWillString);
					var youWillTextFlow:TextFlow = TextFlowUtil.importFromString(youWillString);
					youWillRichText.textFlow = youWillTextFlow;
					break;
			}
		}
	}
}