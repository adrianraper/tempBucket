package com.clarityenglish.ielts.view.title {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.view.account.AccountView;
	import com.clarityenglish.ielts.view.exercise.ExerciseView;
	import com.clarityenglish.ielts.view.home.HomeView;
	import com.clarityenglish.ielts.view.progress.ProgressView;
	import com.clarityenglish.ielts.view.zone.ZoneView;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.formatters.DateFormatter;
	
	import org.davekeen.util.StateUtil;
	
	import spark.components.Button;
	import spark.components.ButtonBar;
	
	// This tells us that the skin has these states, but the view needs to know about them too
	[SkinState("home")]
	[SkinState("zone")]
	[SkinState("progress")]
	[SkinState("account")]
	[SkinState("exercise")]
	public class TitleView extends BentoView {
		
		[SkinPart]
		public var navBar:ButtonBar;
		
		[SkinPart]
		public var backToMenuButton:Button;
		
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
		
		[Bindable]
		public var user:User;
		
		[Bindable]
		public var configID:String;
		
		[Bindable]
		public var dateFormatter:DateFormatter;
		
		private var currentExerciseHref:Href;
		
		[Embed(source="skins/ielts/assets/assets.swf", symbol="HomeIcon")]
		private var homeIcon:Class;
		
		[Embed(source="skins/ielts/assets/assets.swf", symbol="ProgressIcon")]
		private var progressIcon:Class;
		
		[Embed(source="skins/ielts/assets/assets.swf", symbol="AccountIcon")]
		private var accountIcon:Class;
		
		[Embed(source="skins/ielts/assets/assets.swf", symbol="NotepadIcon")]
		private var notepadIcon:Class;
		
		// Constructor to let us initialise our states
		public function TitleView() {
			super();
			
			// The first one listed will be the default
			StateUtil.addStates(this, [ "home", "zone", "account", "progress", "account" ], true);
		}
		
		public function showExercise(exerciseHref:Href):void {
			currentExerciseHref = exerciseHref;
			if (exerciseView) exerciseView.href = currentExerciseHref;
			invalidateSkinState();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case navBar:
					navBar.dataProvider = new ArrayCollection( [
						{ icon: homeIcon, label: "Home", data: "home" },
						{ icon: progressIcon, label: "My Progress", data: "progress" },
						{ icon: accountIcon, label: "My Account", data: "account" },
						{ icon: notepadIcon, label: "Notepad", data: "account" },
					] );
					
					navBar.requireSelection = true;
					navBar.addEventListener(Event.CHANGE, onNavBarIndexChange);
					break;
				case backToMenuButton:
					backToMenuButton.addEventListener(MouseEvent.CLICK, onBackToMenuButtonClick);
					break;
				case exerciseView:
					exerciseView.href = currentExerciseHref;
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
			switch (instance) {
				case navBar:
					navBar.removeEventListener(Event.CHANGE, onNavBarIndexChange);
					break;
				case backToMenuButton:
					backToMenuButton.removeEventListener(MouseEvent.CLICK, onBackToMenuButtonClick);
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
		protected function onNavBarIndexChange(event:Event):void {
			// We can set the skin state from the tab bar click
			currentState = event.target.selectedItem.data;
		}
		
		/**
		 * The user has clicked the back button to get out of an exercise, so clear the current exercise
		 * 
		 * @param event
		 */
		protected function onBackToMenuButtonClick(event:MouseEvent):void {
			showExercise(null);
		}
		
	}
	
}