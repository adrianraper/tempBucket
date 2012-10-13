package com.clarityenglish.components {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	import mx.core.mx_internal;
	
	import spark.components.SpinnerListContainer;
	import spark.components.supportClasses.DropDownController;
	
	use namespace mx_internal;
	
	public class SpinnerDropDownController extends DropDownController {
		
		mx_internal override function systemManager_mouseDownHandler(event:Event):void {
			// stop here if mouse was down from being down on the open button (can't do this because mouseIsDown is private... grr)
			/*if (mouseIsDown) {
				mouseIsDown = false;
				return;
			}*/
			
			if (!dropDown || (dropDown && (event.target == dropDown || (dropDown is DisplayObjectContainer && !DisplayObjectContainer(dropDown).contains(DisplayObject(event.target)))))) {
				// don't close if it's on the openButton
				var target:DisplayObject = event.target as DisplayObject;
				if (openButton && target && openButton.contains(target))
					return;
				
				// Iterate up the display list from target - if anything is a SpinnerList then return
				var displayObject:DisplayObject = event.target as DisplayObject;
				while (displayObject) {
					if (displayObject is SpinnerListContainer) return;
					displayObject = displayObject.parent;
				}
				
				if (hitAreaAdditions != null) {
					for (var i:int = 0; i < hitAreaAdditions.length; i++) {
						if (hitAreaAdditions[i] == event.target || ((hitAreaAdditions[i] is DisplayObjectContainer) && DisplayObjectContainer(hitAreaAdditions[i]).contains(event.target as DisplayObject)))
							return;
					}
				}
				
				// Don't commit changes - this is done by the skin
				closeDropDown(false);
			}
		}
	
	
	}
}
