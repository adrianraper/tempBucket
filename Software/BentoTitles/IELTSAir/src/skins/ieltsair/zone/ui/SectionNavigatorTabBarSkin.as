package skins.ieltsair.zone.ui {
	import spark.components.ButtonBarButton;
	import spark.components.DataGroup;
	import spark.skins.mobile.TabbedViewNavigatorTabBarSkin;
	import spark.skins.mobile.supportClasses.ButtonBarButtonClassFactory;
	import spark.skins.mobile.supportClasses.TabbedViewNavigatorTabBarHorizontalLayout;
	
	public class SectionNavigatorTabBarSkin extends TabbedViewNavigatorTabBarSkin {
		
		/**
		 *  @private
		 */
		override protected function createChildren():void {
			if (!firstButton) {
				firstButton = new ButtonBarButtonClassFactory(ButtonBarButton);
				firstButton.skinClass = skins.ieltsair.zone.ui.SectionNavigatorTabBarButtonSkin;
			}
			
			if (!lastButton) {
				lastButton = new ButtonBarButtonClassFactory(ButtonBarButton);
				lastButton.skinClass = skins.ieltsair.zone.ui.SectionNavigatorTabBarButtonSkin;
			}
			
			if (!middleButton) {
				middleButton = new ButtonBarButtonClassFactory(ButtonBarButton);
				middleButton.skinClass = skins.ieltsair.zone.ui.SectionNavigatorTabBarButtonSkin;
			}
			
			if (!dataGroup) {
				// TabbedViewNavigatorButtonBarHorizontalLayout for even percent layout
				var tabLayout:TabbedViewNavigatorTabBarHorizontalLayout = new TabbedViewNavigatorTabBarHorizontalLayout();
				tabLayout.useVirtualLayout = false;
				
				dataGroup = new DataGroup();
				dataGroup.layout = tabLayout;
				addChild(dataGroup);
			}
		}
	
	}
}
