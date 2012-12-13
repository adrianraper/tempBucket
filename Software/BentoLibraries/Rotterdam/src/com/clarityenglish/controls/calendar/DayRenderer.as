package com.clarityenglish.controls.calendar {
	import almerblank.flex.spark.components.SkinnableItemRenderer;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import spark.components.DataGroup;
	import spark.components.Label;
	
	[SkinState("inMonth")]
	[SkinState("notInMonth")]
	public class DayRenderer extends SkinnableItemRenderer {
		
		[SkinPart(required="true")]
		public var dateLabel:Label;
		
		[SkinPart(required="true")]
		public var labelsDataGroup:DataGroup;
		
		public function DayRenderer() {
			super();
			
			addEventListener(FlexEvent.DATA_CHANGE, function(e:Event):void {
				invalidateProperties();
				invalidateSkinState();
			});
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (data) {
				dateLabel.text = data.date.date.toString();
				labelsDataGroup.dataProvider = new ArrayCollection(data.labels);
			}
		}
		
		protected override function getCurrentSkinState():String {
			var cal:Calendar = owner.parent.parent as Calendar;
			var firstInMonth:Date = cal.firstOfMonth;
			var endOfMonth:Date = cal.endOfMonth;
			
			if (firstInMonth && endOfMonth && data) {
				return (data.date.time < firstInMonth.time || data.date.time > endOfMonth.time) ? "notInMonth" : "inMonth";
			} else {
				return super.getCurrentSkinState();
			}
		}
		
	}
}
