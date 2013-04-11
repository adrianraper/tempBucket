package com.clarityenglish.tensebuster.view.title {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.exercise.ExerciseView;
	import com.clarityenglish.bento.vo.Href;
	
	import flash.events.Event;
	
	import org.davekeen.util.StateUtil;
	
	public class TitleView extends BentoView {
		
		[SkinPart]
		public var exerciseView:ExerciseView;
		
		private var _selectedNode:XML;
		
		public function set selectedNode(value:XML):void {
			_selectedNode = value;
			
			switch (_selectedNode.localName()) {
				case "course":
				case "unit":
					currentState = "zone";
					break;
				case "exercise":
					currentState = "exercise";
					break;
			}
		}
		
		public function TitleView() {
			// The first one listed will be the default
			StateUtil.addStates(this, [ "home", "zone", "exercise" ], true);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				
			}
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}
		
	}
}