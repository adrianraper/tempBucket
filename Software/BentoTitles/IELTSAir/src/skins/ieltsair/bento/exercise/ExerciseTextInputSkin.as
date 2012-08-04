package skins.ieltsair.bento.exercise {
	import mx.core.mx_internal;
	
	import skins.ieltsair.assets.bento.exercise.TextInput_border;
	
	import spark.components.supportClasses.StyleableTextField;
	import spark.skins.mobile.TextInputSkin;
	
	use namespace mx_internal;
	
	public class ExerciseTextInputSkin extends TextInputSkin {
		
		public function ExerciseTextInputSkin() {
			super();
			
			borderClass = TextInput_border;
		}
		
		/**
		 * Trying to stop 'Wj' being displayed in text fields during marking
		 */
		override protected function measure():void {
			return;
			measuredMinWidth = 0;
			measuredMinHeight = 0;
			measuredWidth = 0;
			measuredHeight = 0;
			
			var paddingLeft:Number = getStyle("paddingLeft");
			var paddingRight:Number = getStyle("paddingRight");
			var paddingTop:Number = getStyle("paddingTop");
			var paddingBottom:Number = getStyle("paddingBottom");
			var textHeight:Number = getStyle("fontSize") as Number;
			
			if (textDisplay) {
				// temporarily change text for measurement
				var oldText:String = textDisplay.text;
				
				// commit styles so we can get a valid textHeight
				textDisplay.text = "Wj";
				textDisplay.commitStyles();
				
				textHeight = textDisplay.measuredTextSize.y;
				textDisplay.text = oldText;
			}
			
			// width is based on maxChars (if set)
			if (hostComponent && hostComponent.maxChars) {
				// Grab the fontSize and subtract 2 as the pixel value for each character.
				// This is just an approximation, but it appears to be a reasonable one
				// for most input and most font.
				var characterWidth:int = Math.max(1, (getStyle("fontSize") - 2));
				measuredWidth = (characterWidth * hostComponent.maxChars) + paddingLeft + paddingRight + StyleableTextField.TEXT_WIDTH_PADDING;
			}
			
			measuredHeight = paddingTop + textHeight + paddingBottom;
		}
	
	
	}
}
