package com.clarityenglish.ielts.view.menu {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.ielts.view.module.ModuleView;
	import com.clarityenglish.ielts.view.progress.ProgressView;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.TabBar;
	
	[SkinState("module")]
	[SkinState("progress")]
	[SkinState("account")]
	[SkinState("exercise")]
	public class MenuView extends BentoView {
		
		[SkinPart]
		public var mainTabBar:TabBar;
		
		[SkinPart]
		public var courseTabBar:TabBar;
		
		[SkinPart]
		public var moduleView:ModuleView;
		
		[SkinPart]
		public var progressView:ProgressView;
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case mainTabBar:
					mainTabBar.dataProvider = new ArrayCollection( [
						{ label: "Academic module", data: "module" },
						{ label: "My Progress", data: "progress" },
						{ label: "My Account", data: "account" },
					] );
					mainTabBar.requireSelection = true;
					mainTabBar.addEventListener(Event.CHANGE, onMainTabBarIndexChange);
					break;
				case moduleView:
					// Pass on the same href to the module view
					instance.href = href;
					break;
			}
		}
		
		/**
		 * The skin state is (for the moment) determined by the tab selection
		 * 
		 * @return 
		 */
		protected override function getCurrentSkinState():String {
			return (mainTabBar && mainTabBar.selectedItem) ? mainTabBar.selectedItem.data : null;
		}
		
		/**
		 * When the tab is changed invalidate the skin state to force getCurrentSkinState() to get called again
		 * 
		 * @param event
		 */
		protected function onMainTabBarIndexChange(event:Event):void {
			invalidateSkinState();
		}
		
	}
	
}