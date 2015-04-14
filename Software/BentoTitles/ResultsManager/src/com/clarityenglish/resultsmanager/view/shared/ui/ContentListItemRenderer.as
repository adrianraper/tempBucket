package com.clarityenglish.resultsmanager.view.shared.ui {
	import com.clarityenglish.resultsmanager.Constants;
	import com.clarityenglish.common.vo.content.Title;
	import mx.controls.Image;
	import mx.controls.listClasses.ListItemRenderer;
	import mx.controls.treeClasses.TreeItemRenderer;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class ContentListItemRenderer extends ListItemRenderer {
		
		private var xOffset:Number = 0;
		
		private var image:Image;
		
		override protected function createChildren():void {
			super.createChildren();
			
			image = new Image();
			image.width = 50;
			image.height = 50;
			image.setStyle("verticalAlign", "middle");
			
			addChild(image);
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			// TODO If this image doesn't exist, use the default RM one - this is for generic titles that don't have an image (yet)
			if (data is Title) {
				image.source = Constants.HOST + Constants.LOGO_FOLDER + "/" + (data as Title).productCode + ".swf";
				image.visible = true;
			} else {
				image.visible = false;
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			image.x = xOffset;

			label.x = (data is Title) ? 55 + xOffset : icon.x + 4 + xOffset;
			label.y = (data is Title) ? 16 : 0;
		}
		
		override protected function measure():void {
			super.measure();
			
			if (data is Title) {
				measuredHeight = 50;
			} else {
				measuredHeight = 16;
			}
		}
		
	}
	
}