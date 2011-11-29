package com.clarityenglish.ielts.view.progress.ui {
	import almerblank.flex.spark.components.SkinnableDataRenderer;
	
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
		public var comment:Label;
		
		[SkinPart(required="true")]
		public var overallProgressIndicator:Rect;

		private var _selectedColour:Number;
		
		public var courseClass:String;
		
		public override function set data(value:Object):void {
			super.data = value;
			
			_selectedColour = getStyle(courseClass + "Color");
			
			if (data) {
				comment.text = courseClass + " - average score " + new Number(data.averageScore) + "%";
				overallProgressIndicator.percentWidth = new Number(data.averageScore);
				//overallProgressIndicator.color = _selectedColour;
			}
		}
		
	}
	
}