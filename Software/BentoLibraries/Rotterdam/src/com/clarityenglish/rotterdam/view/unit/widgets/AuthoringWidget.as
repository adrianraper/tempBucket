package com.clarityenglish.rotterdam.view.unit.widgets {
	import com.clarityenglish.bento.view.DynamicView;
	import com.clarityenglish.bento.vo.Href;
	
	import flash.events.Event;
	
	import mx.events.ResizeEvent;
	
	public class AuthoringWidget extends AbstractWidget {
		
		[SkinPart]
		public var dynamicView:DynamicView;
		
		public function AuthoringWidget() {
			super();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case dynamicView:
					if (!_xml.hasOwnProperty("@tempid")) { // THIS IS TEMPORARY
						dynamicView.href = menuXHTMLHref.createRelativeHref(Href.EXERCISE, _xml.@href, true);
					}
					break;
			}
		}
		
		protected override function validateUnitListLayout(e:Event=null):void {
			super.validateUnitListLayout(e);
			
			//xhtmlExerciseView.forceRelayout();
			
			/*callLater(function() {
				dynamicView.invalidateDisplayList();
				dynamicView.invalidateSize();
				dynamicView.validateNow();
			});*/
			
			// TODO: Need to figure out how to do this properly - this is causing issues
			
			dynamicView.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE, true));
		}
		
	}
	
}
