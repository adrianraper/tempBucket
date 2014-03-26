package com.clarityenglish.rotterdam.view.title.ui {
	import flash.events.MouseEvent;
	
	import mx.core.mx_internal;
	
	import spark.components.IItemRenderer;
	import spark.components.TabbedViewNavigator;
	import spark.components.ViewNavigator;

	use namespace mx_internal;
	
	public class CancelableTabbedViewNavigator extends TabbedViewNavigator {
		
		/**
		 * The TabbedViewNavigator can be provided with a function changeConfirmFunction with a single 'next' parameter (similar to node.js next()).  If
		 * set before a tab changes the function is called and in order to continue with the change the function must call next().  This allows us to build
		 * (for example) confirm boxes. 
		 */
		public var changeConfirmFunction:Function;
		
		public function CancelableTabbedViewNavigator() {
			super();
		}
		
		/*gh #242
		public override function set selectedIndex(value:int):void {
			trace("set index: "+value);
			var next:Function = function():void {
				_setSelectedIndex(value);
			};
			
			if (changeConfirmFunction !== null) {
				changeConfirmFunction(next);
			} else {
				next();
			}
		}*/
		
		private function _setSelectedIndex(value:int):void {
			super.selectedIndex = value;
		}
		
		mx_internal override function tabBarRenderer_clickHandler(event:MouseEvent):void {
			// gh#242
			if (((event.target).itemIndex == super.selectedIndex) && super.selectedIndex == 0) {
				var next:Function = function():void {
					_tabBarRenderer_clickHandler(event);
				};
				
				if (changeConfirmFunction !== null) {
					changeConfirmFunction(next);
				} else {
					next();
				}
			}		
		}
		
		private function _tabBarRenderer_clickHandler(event:MouseEvent):void {
			//super.tabBarRenderer_clickHandler(event);
			
			// #745
			if ((event.target is IItemRenderer) && 
				(IItemRenderer(event.target).itemIndex == super.selectedIndex))
			{
				if (selectedNavigator is ViewNavigator) {
					// gh#847
					if (ViewNavigator(selectedNavigator).length > 1)
						ViewNavigator(selectedNavigator).popView();
				}
					
			}
		}
		
	}
	
}
