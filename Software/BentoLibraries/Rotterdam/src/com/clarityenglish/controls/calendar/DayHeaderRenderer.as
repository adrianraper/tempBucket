package com.clarityenglish.controls.calendar {
	import almerblank.flex.spark.components.SkinnableDataRenderer;
	
	import spark.components.Label;
	
	public class DayHeaderRenderer extends SkinnableDataRenderer {
		
		[SkinPart(required="true")]
		public var dayLabel:Label;
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (data) {
				dayLabel.text = data.toString();
			}
		}
		
	}
}
