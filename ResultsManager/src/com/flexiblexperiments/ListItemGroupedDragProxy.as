/**
 * All computational source code, intellectual property or other works 
 * contained herein are deemed Public Domain as per the Creative 
 * Commons Public Domain license.
 * 
 * http://creativecommons.org/licenses/publicdomain/
 * 
 * Author : Jason Hawyluk
 * Date: 26/02/2007
 * Reference : http://flexibleexperiments.wordpress.com
 * 
 * Jason Hawryluk disclaims all warranties with regard to this software, 
 * including all implied warranties of merchantability and fitness, in 
 * no event shall Jason Hawryluk be liable for any special, indirect or 
 * consequential damages or any damages whatsoever resulting from loss of 
 * use, data or profits, whether in an action of contract, negligence or 
 * other tortuous action, arising out of or in connection with the use or 
 * performance of this software.
 **/

 
/**
* 
* Provides a grouped type dragproxy usefull 
* for multi selection drag operations
**/
package com.flexiblexperiments
{
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	import flash.filters.GlowFilter;
	import mx.controls.listClasses.ListItemRenderer;
	import mx.controls.treeClasses.TreeItemRenderer;
	
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.controls.listClasses.ListBase;
	import mx.controls.listClasses.ListItemDragProxy;
	import mx.core.mx_internal;
	import flash.geom.Point;
	
	use namespace mx_internal;

	
	
	public class ListItemGroupedDragProxy extends ListItemDragProxy
	{
		
		public static var copyProvider:CopyProvider;
		
		public function ListItemGroupedDragProxy(){
			super();
		}
		
		override protected function createChildren():void{
	        	        
			var items:Array = ListBase(owner).selectedItems;
			
			//if we are showing multiple items then group them up
			if (items.length > 1){
				
				//grab a copy of the first item in the list
				var src:IListItemRenderer = ListBase(owner).itemToItemRenderer(items[0]);
				
				var groupProxy:IListItemRenderer = ListBase(owner).itemRenderer.newInstance();
				groupProxy.styleName = ListBase(owner);
				
				if (groupProxy is IDropInListItemRenderer && IDropInListItemRenderer(src) != null)
				{
					var listData:BaseListData = IDropInListItemRenderer(src).listData;
					IDropInListItemRenderer(groupProxy).listData = items[0] ? listData : null;
				}
				
				groupProxy.data = items[0];
				
				//setup the label text
				var labelText:String = ListBase(owner)["groupDragProxyLabel"];
				
				if (labelText == "")
					labelText = copyProvider.getCopyForId("draggingItems");
				
				labelText = labelText.replace("{itemCount}",items.length.toString());
				listData.label = labelText;		
				
				// Create a white background to site behind the label (otherwise it's too hard to read)
				graphics.beginFill(0xFFFFFF, 1);
				graphics.drawRect(src.x, owner.mouseY - src.height / 2, src.width, src.height);
				graphics.endFill();
				
				//add the proxy
				addChild(DisplayObject(groupProxy));
				
				//size and position the proxy
				groupProxy.setActualSize(src.width, src.height);
				groupProxy.x = src.x;
				groupProxy.y = owner.mouseY - src.height / 2;
				
			}
			
			else{
				super.createChildren();
			}
			
		}
	}
}