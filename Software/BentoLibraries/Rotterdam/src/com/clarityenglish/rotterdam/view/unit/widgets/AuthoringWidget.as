package com.clarityenglish.rotterdam.view.unit.widgets {
	import com.clarityenglish.bento.view.DynamicView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.Exercise;
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
			
			// Add a top priority, capture phase, click listener which switches exercise before anything else has a chance to happen #885
			addEventListener(MouseEvent.CLICK, onMouseClick, true, int.MAX_VALUE);
		}
		
		protected override function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);
			
			removeEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case dynamicView:
					if (!_xml.hasOwnProperty("@tempid")) { // THIS IS TEMPORARY
						dynamicView.href = menuXHTMLHref.createRelativeHref(Href.EXERCISE, _xml.@href, true);
					}
					break;
				case markingButton:
					markingButton.addEventListener(MouseEvent.CLICK, onShowMarking);
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
		
		protected function onMouseClick(e:Event):void {
			// Switch exercise
			if (dynamicView.xhtml is Exercise)
				exerciseSwitch.dispatch(dynamicView.xhtml as Exercise);
		}
		
		protected function onShowMarking(e:Event):void {
			// Mark exercise
			if (dynamicView.xhtml is Exercise)
				showMarking.dispatch(dynamicView.xhtml as Exercise);
		}
		
	}
	
}
