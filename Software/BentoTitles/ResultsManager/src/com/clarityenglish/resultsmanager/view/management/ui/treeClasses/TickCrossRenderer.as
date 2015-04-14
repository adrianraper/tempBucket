package com.clarityenglish.resultsmanager.view.management.ui.treeClasses {
	import mx.containers.HBox;
	import mx.controls.Image;
	import org.davekeen.controls.SmoothImage;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class TickCrossRenderer extends HBox {
		
		[Embed(source="/../assets/tick.gif")]
		private var tickClass:Class;
		
		[Embed(source="/../assets/cross.gif")]
		private var crossClass:Class;
		
		private var image:SmoothImage;
		
		public function TickCrossRenderer() {
			image = new SmoothImage();
			
			image.width = image.height = 16;
			
			addChild(image);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			image.source = (data.success) ? tickClass : crossClass;
			
			image.x = 3;
			image.y = 1;
			image.width = image.height = 16;
		}
		
	}
	
}