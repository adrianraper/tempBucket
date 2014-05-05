package com.clarityenglish.rotterdam.view.unit.widgets {
	import com.clarityenglish.bento.view.xhtmlexercise.components.XHTMLExerciseView;
	import com.clarityenglish.bento.vo.Href;
	
	import flash.utils.setTimeout;
	import flash.events.Event;
	
	public class AuthoringWidget extends AbstractWidget {
		
		[SkinPart]
		public var xhtmlExerciseView:XHTMLExerciseView;
		
		public function AuthoringWidget() {
			super();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case xhtmlExerciseView:
					if (!_xml.hasOwnProperty("@tempid")) { // THIS IS TEMPORARY
						xhtmlExerciseView.href = menuXHTMLHref.createRelativeHref(Href.EXERCISE, _xml.@href, true);
					}
					break;
			}
		}
		
		
		protected override function validateUnitListLayout(e:Event=null):void {
			super.validateUnitListLayout(e);
			
			xhtmlExerciseView.forceRelayout();
		}

		
	}
	
}
