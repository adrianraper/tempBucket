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
		
		[Bindable(event="contentuidAttrChanged")]
		public function get contentuid():String {
			return _xml.@contentuid;
		}
		
		[Bindable(event="contentuidAttrChanged")]
		public function get hasContentuid():Boolean {
			return _xml.hasOwnProperty("@contentuid");
		}

		[Bindable(event="exercisetitleAttrChanged")]
		public function get exercisetitle():String {
			return _xml.@exercisetitle;
		}

		
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
			if (hasContentuid) {
				openContent.dispatch(xml, contentuid);
			} else {
				log.error("We shouldn't be able to get here...");
			}
		}
		
		/**
		 * Get the thumbnail image for this content using the thumbnail script
		 * 
		 * @param uid
		 * @return 
		 */
		public function getThumbnailForUid(uid:String):String {
			return thumbnailScript + "?uid=" + uid;
		}
		
	}
}
