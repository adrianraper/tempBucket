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
		
		protected override function measure():void {
			super.measure();
		}
		
		protected override function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void {
			super.layoutContents(unscaledWidth, unscaledHeight);
			
			// Very hacky fix for #403 - I'm sure this could be done better somehow
			//setElementSize(textDisplay, textDisplay + 20, textDisplay.height);
		}
		
	}
}