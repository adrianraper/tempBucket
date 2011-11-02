package com.clarityenglish.ielts.view.title {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.ielts.view.account.AccountView;
	import com.clarityenglish.ielts.view.exercise.ExerciseView;
	import com.clarityenglish.ielts.view.home.HomeView;
	import com.clarityenglish.ielts.view.progress.ProgressView;
	import com.clarityenglish.ielts.view.zone.ZoneView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.Button;
	import spark.components.TabBar;
	
	[SkinState("home")]
	[SkinState("zone")]
	[SkinState("progress")]
	[SkinState("account")]
	[SkinState("exercise")]
	public class TitleView extends BentoView {
		
		[SkinPart]
		public var mainTabBar:TabBar;
		
		[SkinPart]
		public var courseTabBar:TabBar;
		
		[SkinPart]
		public var backButton:Button;
		
		[SkinPart]
		public var homeView:HomeView;
		
		[SkinPart]
		public var zoneView:ZoneView;
		
		[SkinPart]
		public var progressView:ProgressView;
		
		[SkinPart]
		public var accountView:AccountView;
		
		[SkinPart]
		public var exerciseView:ExerciseView;
		
		private var currentExerciseHref:Href;
		// Set the default state for the title
		//private var _skinState:String = 'home';
		
		// Constructor to let us initialise first view
		public function TitleView() {
			super();
			currentState = "home";
		}
		
		public function showExercise(exerciseHref:Href):void {
			currentExerciseHref = exerciseHref;
			if (exerciseView) exerciseView.href = currentExerciseHref;
			invalidateSkinState();
		}
		
		/**
		 * Tell the zone view to handle the course
		 * 
		 * @param XML The course XML
		 * 
		 */
		public function showCourse(course:XMLList):void {
			
			// Tell the zone which course to work with
			// Do I need to do course[0] to ensure that there is only one XML object in the list?
			// PROBLEM. I can't refer to zoneView as it has not been added to the view yet.
			zoneView.course = (course as XML);
			
			// Need to set the state to zone
			currentState = "zone";
			invalidateSkinState();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case mainTabBar:
					mainTabBar.dataProvider = new ArrayCollection( [
						{ label: "Home", data: "home" },
						{ label: "My Progress", data: "progress" },
						{ label: "My Account", data: "account" },
					] );
					mainTabBar.requireSelection = true;
					mainTabBar.addEventListener(Event.CHANGE, onMainTabBarIndexChange);
					break;
				case backButton:
					backButton.addEventListener(MouseEvent.CLICK, onBackButtonClick);
					break;
				case zoneView:
				case homeView:
					// The zone and home views run off the same href as the title view, so directly inject it 
					instance.href = href;
					break;
				case exerciseView:
					exerciseView.href = currentExerciseHref;
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
			switch (instance) {
				case mainTabBar:
					mainTabBar.removeEventListener(Event.CHANGE, onMainTabBarIndexChange);
					break;
				case backButton:
					backButton.removeEventListener(MouseEvent.CLICK, onBackButtonClick);
					break;
			}
		}
		
		/**
		 * 
		 * This shows what state the skin is currently in
		 * 
		 * @return string State name 
		 */
		protected override function getCurrentSkinState():String {
			if (currentExerciseHref)
				return "exercise";
			
			// The skin state is (for the moment) determined by the tab selection.
			// This has to stop because the tabs don't include zone view
			//return (mainTabBar && mainTabBar.selectedItem) ? mainTabBar.selectedItem.data : null;
			return currentState;
		}
		
		/**
		 * When the tab is changed invalidate the skin state to force getCurrentSkinState() to get called again
		 * 
		 * @param event
		 */
		protected function onMainTabBarIndexChange(event:Event):void {
			// We can set the skin state from the tab bar click
			currentState = (event.target as TabBar).selectedItem.data;
			
			// Then cause a refresh
			invalidateSkinState();
		}
		
		/**
		 * The user has clicked the back button to get out of an exercise, so clear the current exercise
		 * 
		 * @param event
		 */
		protected function onBackButtonClick(event:MouseEvent):void {
			showExercise(null);
		}
		
	}
	
}