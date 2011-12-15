package com.clarityenglish.ielts.view.zone.ui {
	import almerblank.flex.spark.components.SkinnableDataRenderer;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import skins.ielts.zone.Chilli;
	
	public class DifficultyRenderer extends SkinnableDataRenderer {
		
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		[SkinPart(required="true")]
		public var chilli1:Chilli;
		
		[SkinPart(required="true")]
		public var chilli2:Chilli;
		
		[SkinPart(required="true")]
		public var chilli3:Chilli;
		
		//private var _selectedColour:Number;
		
		public var courseClass:String;
		
		public override function set data(value:Object):void {
			super.data = value;
			
			var _selectedColour:Number = getStyle(courseClass + "Color");
			
			chilli1.fillColour = chilli2.fillColour = chilli3.fillColour = 0x303030;
			
			if (data) {
				var difficulty:int = new Number(data.@difficulty);
				
				if (difficulty >= 1) chilli1.fillColour = _selectedColour;
				if (difficulty >= 2) chilli2.fillColour = _selectedColour;
				if (difficulty >= 3) chilli3.fillColour = _selectedColour;
				
				if (difficulty > 3) log.error("Illegal difficulty value {0}", data.@difficulty);
			}
		}
		
	}
	
}