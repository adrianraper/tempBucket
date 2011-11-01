package com.clarityenglish.ielts.view.title {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.ielts.view.exercise.ExerciseView;
	import com.clarityenglish.ielts.view.zone.ZoneView;
	import com.clarityenglish.ielts.view.home.HomeView;
	import com.clarityenglish.ielts.view.progress.ProgressView;
	import com.clarityenglish.ielts.view.account.AccountView;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.Button;
	import spark.components.TabBar;
	import com.clarityenglish.textLayout.vo.XHTML;
	
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
		private var _skinState:String = 'home';
		
		public function showExercise(exerciseHref:Href):void {
			currentExerciseHref = exerciseHref;
			if (exerciseView) exerciseView.href = currentExerciseHref;
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
		 * The skin state is (for the moment) determined by the tab selection.
		 * This has to stop because the tabs don't include zone view
		 * 
		 * @return 
		 */
		protected override function getCurrentSkinState():String {
			if (currentExerciseHref)
				return "exercise";
			
			//return (mainTabBar && mainTabBar.selectedItem) ? mainTabBar.selectedItem.data : null;
			return this._skinState;
		}
		/**
		 * The skin state is set by this function.
		 * TODO. Since this is not a function that needs to be overridden, does that suggest it shouldn't be called like this?
		 * 
		 * @param string 
		 */
		protected function setCurrentSkinState(state:String):void {
			//this._skinState = state;
			this._skinState = state;
		}
		
		/**
		 * When the tab is changed invalidate the skin state to force getCurrentSkinState() to get called again
		 * 
		 * @param event
		 */
		protected function onMainTabBarIndexChange(event:Event):void {
			// We should set the skin state from the tab bar click
			setCurrentSkinState((event.target as TabBar).selectedItem.data);
			
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