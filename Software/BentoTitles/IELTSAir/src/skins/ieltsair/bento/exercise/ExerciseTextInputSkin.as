package skins.ieltsair.bento.exercise {
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	
	import skins.ieltsair.assets.bento.exercise.TextInput_border;
	
	import spark.components.supportClasses.StyleableTextField;
	import spark.skins.mobile.TextInputSkin;
	
	use namespace mx_internal;
	
	public class ExerciseTextInputSkin extends TextInputSkin {
		
		public function ExerciseTextInputSkin() {
			super();
			
			borderClass = TextInput_border;
		}
		
		protected override function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void {
			super.layoutContents(unscaledWidth, unscaledHeight);
			
			// Very hacky fix for #403, but it seems to work
			setElementSize(textDisplay, unscaledWidth + 4, textDisplay.height);
			setElementPosition(textDisplay, -2, textDisplay.y);
		}
		
	}
}