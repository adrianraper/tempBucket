package skins.air.bento.exercise {
	import mx.core.mx_internal;
	
	import skins.air.assets.bento.exercise.TextInput_border;
	
	import spark.primitives.Graphic;
	import spark.skins.mobile.TextInputSkin;
	
	use namespace mx_internal;
	
	public class ExerciseTextInputSkin extends TextInputSkin {
		
		private var dropTargetBorder:Graphic;
		
		public function ExerciseTextInputSkin() {
			super();
			
			borderClass = TextInput_border;
		}
		
		protected override function createChildren():void {
			
			
			if (!dropTargetBorder) {
				dropTargetBorder = new Graphic();
				dropTargetBorder.x = -2;
				dropTargetBorder.y = -1;
				addChild(dropTargetBorder);
			}
			
			super.createChildren();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (hostComponent.editable) {
				if (border) border.visible = true;
				if (dropTargetBorder) dropTargetBorder.visible = false;
			} else {
				if (border) border.visible = false;
				if (dropTargetBorder) dropTargetBorder.visible = true;
			}
		}
		
		protected override function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void {
			super.layoutContents(unscaledWidth, unscaledHeight);
			
			if (dropTargetBorder && dropTargetBorder.visible) {
				dropTargetBorder.graphics.clear();
				dropTargetBorder.graphics.lineStyle(0, 0, 0);
				dropTargetBorder.graphics.beginFill(0xE6E6E6);
				dropTargetBorder.graphics.drawRoundRect(0, 0, unscaledWidth + 1, unscaledHeight + 1, 2, 2);
				dropTargetBorder.graphics.endFill();
			}
			
			// Very hacky fix for #403, but it seems to work
			setElementSize(textDisplay, unscaledWidth + 4, textDisplay.height);
			setElementPosition(textDisplay, -2, textDisplay.y);
		}
		
	}
}