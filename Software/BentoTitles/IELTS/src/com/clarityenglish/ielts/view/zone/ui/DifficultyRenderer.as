package com.clarityenglish.ielts.view.zone.ui {
	import almerblank.flex.spark.components.SkinnableDataRenderer;
	
	public class DifficultyRenderer extends SkinnableDataRenderer {
		
		[Bindable]
		public var difficulty:int;
		
		public override function set data(value:Object):void {
			super.data = value;
			
			if (data) {
				difficulty = data.@difficulty;
			}
		}
		
	}
	
}