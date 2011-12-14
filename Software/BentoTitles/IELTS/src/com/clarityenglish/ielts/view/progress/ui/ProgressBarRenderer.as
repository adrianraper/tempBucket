package com.clarityenglish.ielts.view.progress.ui {
	import almerblank.flex.spark.components.SkinnableDataRenderer;
	
	import mx.graphics.SolidColor;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.Label;
	import spark.primitives.Rect;
		
	public class ProgressBarRenderer extends SkinnableDataRenderer {
		
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		[SkinPart(required="true")]
		public var commentLabel:Label;
		
		[SkinPart(required="true")]
		public var overallProgressRect:Rect;

		[SkinPart(required="true")]
		public var solidColour:SolidColor;
		
		private var _selectedColour:Number;
		
		public var courseClass:String;
	
		public var type:String;
		
		public override function set data(value:Object):void {
			super.data = value;
			
			_selectedColour = getStyle(courseClass + "Color");
			
			if (data) {
				var course:XML = (data.dataProvider as XML).course.(@["class"]==courseClass)[0];
				
				// Is this for coverge or score?
				if (type == 'coverage') {
					trace("progressBarRenderer courseClass = " + courseClass + " score=" + course.@averageScore + " colour=" + _selectedColour);
					commentLabel.text = courseClass + " - overall coverage " + new Number(course.@coverage) + "%";
					overallProgressRect.percentWidth = new Number(course.@coverage);
				} else {
					trace("progressBarRenderer courseClass = " + courseClass + " score=" + course.@averageScore + " colour=" + _selectedColour);
					commentLabel.text = courseClass + " - average score " + new Number(course.@averageScore) + "%";
					overallProgressRect.percentWidth = new Number(course.@averageScore);
				}
				solidColour.color = _selectedColour;
			}
		}
		
	}
	
}