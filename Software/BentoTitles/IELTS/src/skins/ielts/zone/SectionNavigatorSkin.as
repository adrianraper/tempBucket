package skins.ielts.zone {
	import org.davekeen.util.StateUtil;
	
	import spark.components.ButtonBar;
	import spark.components.Group;
	import spark.components.TabbedViewNavigator;
	import spark.components.supportClasses.ButtonBarBase;
	import spark.skins.mobile.supportClasses.MobileSkin;
	
	/**
	 * This is a modification of the TabbedViewNavigator that puts the menu at the top instead of the bottom
	 * 
	 * @author Dave
	 */
	public class SectionNavigatorSkin extends MobileSkin {
		
		public function SectionNavigatorSkin() {
			super();
			
			states = states.concat([ "portrait", "landscape" ]);
		}
		
		/**
		 *  @copy spark.skins.spark.ApplicationSkin#hostComponent
		 */
		public var hostComponent:TabbedViewNavigator;
		
		/**
		 *  @copy spark.components.SkinnableContainer#contentGroup
		 */
		public var contentGroup:Group;
		
		/**
		 *  @copy spark.components.TabbedViewNavigator#tabBar
		 */
		public var tabBar:ButtonBarBase;
		
		private var _isOverlay:Boolean;
		
		/**
		 *  @private
		 */
		override protected function createChildren():void {
			if (!contentGroup) {
				contentGroup = new Group();
				contentGroup.id = "contentGroup";
				addChild(contentGroup);
			}
			
			if (!tabBar) {
				tabBar = new ButtonBar();
				tabBar.id = "tabBar";
				tabBar.requireSelection = true;
				tabBar.buttonMode = true;
				tabBar.useHandCursor = true;
				addChild(tabBar);
			}
		}
		
		/**
		 *  @private
		 */
		override protected function commitCurrentState():void {
			super.commitCurrentState();
			
			_isOverlay = (currentState.indexOf("Overlay") >= 1);
			
			// Force a layout pass on the components
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		/**
		 *  @private
		 */
		override protected function measure():void {
			super.measure();
			
			measuredWidth = Math.max(tabBar.getPreferredBoundsWidth(), contentGroup.getPreferredBoundsWidth());
			
			if (currentState == "portraitAndOverlay" || currentState == "landscapeAndOverlay") {
				measuredHeight = Math.max(tabBar.getPreferredBoundsHeight(), contentGroup.getPreferredBoundsHeight());
			} else {
				measuredHeight = tabBar.getPreferredBoundsHeight() + contentGroup.getPreferredBoundsHeight();
			}
		}
		
		/**
		 *  @private
		 */
		override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void {
			super.layoutContents(unscaledWidth, unscaledHeight);
			
			var tabBarHeight:Number = 0;
			
			if (tabBar.includeInLayout) {
				tabBarHeight = Math.min(tabBar.getPreferredBoundsHeight(), unscaledHeight);
				tabBar.setLayoutBoundsSize(unscaledWidth, tabBarHeight);
				tabBar.setLayoutBoundsPosition(0, 0);
				tabBarHeight = tabBar.getLayoutBoundsHeight();
				
				// backgroundAlpha is not a declared style on ButtonBar
				// TabbedViewNavigatorButtonBarSkin implements for overlay support
				var backgroundAlpha:Number = (_isOverlay) ? 0.75 : 1;
				tabBar.setStyle("backgroundAlpha", backgroundAlpha);
			}
			
			if (contentGroup.includeInLayout) {
				var contentGroupHeight:Number = (_isOverlay) ? unscaledHeight : Math.max(unscaledHeight - tabBarHeight, 0);
				contentGroup.setLayoutBoundsSize(unscaledWidth, contentGroupHeight);
				contentGroup.setLayoutBoundsPosition(0, tabBarHeight);
			}
		}
	}
}
