package com.clarityenglish.rotterdam.view.unit.widgets {
	import com.clarityenglish.bento.view.DynamicView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.ResizeEvent;
	
	import spark.components.Button;
	
	/**
	 * Note that the widget embeds the DynamicView directly and so doesn't use ExerciseMediator/ExerciseView at all.
	 */
	public class AuthoringWidget extends AbstractWidget {
		
		[SkinPart]
		public var startAgainButton:Button;
		
		[SkinPart]
		public var markingButton:Button;
		
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
				case startAgainButton:
					startAgainButton.addEventListener(MouseEvent.CLICK, function():void { /*startAgain.dispatch();*/ } );
					startAgainButton.label = copyProvider.getCopyForId("exerciseStartAgainButton");
					break;
				case markingButton:
					markingButton.addEventListener(MouseEvent.CLICK, function():void { /*showMarking.dispatch();*/ } );
					markingButton.label = copyProvider.getCopyForId("exerciseMarkingButton");
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
