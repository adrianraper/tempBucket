package com.clarityenglish.tensebuster.view.title {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.exercise.ExerciseView;
	import com.clarityenglish.tensebuster.view.home.HomeView;
	import com.clarityenglish.tensebuster.view.zone.ZoneView;
	
	import flash.events.MouseEvent;
	
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.TabbedViewNavigator;
	
	public class TitleView extends BentoView {
		
		[SkinPart]
		public var sectionNavigator:TabbedViewNavigator;
		
		[SkinPart]
		public var backToMenuButton:Button;
		
		private var _selectedNode:XML;
		
		public var backToMenu:Signal = new Signal();
		
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
				case sectionNavigator:
					setNavStateMap(sectionNavigator, {
						home: { viewClass: HomeView },
						zone: { viewClass: ZoneView, stack: true },
						exercise: { viewClass: ExerciseView, stack: true }
					});
					break;
				case backToMenuButton:
					backToMenuButton.addEventListener(MouseEvent.CLICK, onBackToMenuButtonClick);
					break;
			}
		}
		
		protected function onBackToMenuButtonClick(event:MouseEvent):void {
			backToMenu.dispatch();
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}
		
	}
}