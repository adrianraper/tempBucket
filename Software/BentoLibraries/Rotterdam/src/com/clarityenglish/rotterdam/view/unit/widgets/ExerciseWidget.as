package com.clarityenglish.rotterdam.view.unit.widgets {
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.Image;
	
	public class ExerciseWidget extends AbstractWidget {
		
		[SkinPart(required="true")]
		public var exerciseImage:Image;
		
		public function ExerciseWidget() {
			super();
		}
		
		/*[Bindable(event="srcAttrChanged")]
		public function get src():String {
			return _xml.@src;
		}
		
		[Bindable(event="srcAttrChanged")]
		public function get hasSrc():Boolean {
			return _xml.hasOwnProperty("@src");
		}*/
		
		// TODO: implement with execise uid?
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case exerciseImage:
					exerciseImage.buttonMode = true;
					exerciseImage.addEventListener(MouseEvent.CLICK, onExerciseImageClick);
					break;
			}
		}
		
		protected function onExerciseImageClick(event:MouseEvent):void {
			/*if (hasSrc) {
				openMedia.dispatch(xml, src);
			} else {
				log.error("TODO: implement exercise...");
			}*/
		}
		
	}
}
