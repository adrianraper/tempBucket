package com.clarityenglish.tensebuster.view.title {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.exercise.ExerciseView;
	import com.clarityenglish.bento.vo.Href;
	
	import flash.events.Event;
	
	import org.davekeen.util.StateUtil;
	
	public class TitleView extends BentoView {
		
		private var _selectedCourseXML:XML;
		
		private var currentExerciseHref:Href;
		
		[SkinPart]
		public var exerciseView:ExerciseView;
		
		[Bindable(event="courseSelected")]
		public function get selectedCourseXML():XML {
			return _selectedCourseXML;
		}
		
		public function set selectedCourseXML(value:XML):void {
			_selectedCourseXML = value;
			
			if (_selectedCourseXML)
				currentState = "zone";
			
			dispatchEvent(new Event("courseSelected"));
		}
		
		public function TitleView() {
			// The first one listed will be the default
			StateUtil.addStates(this, [ "home", "zone" ], true);
		}
		
		public function showExercise(exerciseHref:Href):void {
			currentExerciseHref = exerciseHref;
			if (exerciseView) exerciseView.href = currentExerciseHref;
			callLater(invalidateSkinState); // callLater is part of #192
			
			// This is for mobile skins; if the ExerciseView is already top of the stack then set the href, otherwise push a new ExerciseView
			/*if (homeViewNavigator) {
				if (ClassUtil.getClass(homeViewNavigator.activeView) == ExerciseView) {
					if (currentExerciseHref) {
						(homeViewNavigator.activeView as ExerciseView).href = currentExerciseHref;
					} else {
						homeViewNavigator.popView();
					}
				} else {
					homeViewNavigator.pushView(ExerciseView, currentExerciseHref);
				}
			}*/
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				
			}
		}
		
		protected override function getCurrentSkinState():String {
			if (currentExerciseHref)
				return "exercise";
			
			return currentState;
		}
		
	}
}