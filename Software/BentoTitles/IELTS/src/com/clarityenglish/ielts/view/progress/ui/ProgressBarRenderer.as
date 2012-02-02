package com.clarityenglish.ielts.view.progress.ui {
	import almerblank.flex.spark.components.SkinnableDataRenderer;
	
	import caurina.transitions.Tweener;
	
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
		
		[SkinPart(required="true")]
		public var backColour:SolidColor;
		
		public var courseClass:String;
		
	
		public var type:String;
		
		public override function set data(value:Object):void {
			super.data = value;
			
			if (data) {
				var course:XML = (data.dataProvider as XML).course.(@["class"]==courseClass)[0];
				solidColour.color = getStyle(courseClass + "Color");;
				backColour.color = getStyle(courseClass + "ColorDark");;
				
				// Is this for coverge or score?
				if (type == 'coverage') {
					commentLabel.text = courseClass + " - overall coverage " + new Number(course.@coverage) + "%";
					var percentValue:Number = new Number(course.@coverage);
				} else {
					commentLabel.text = courseClass + " - average score " + new Number(course.@averageScore) + "%";
					percentValue = new Number(course.@averageScore);
				}
				
				// Tween it
				Tweener.removeTweens(overallProgressRect, percentWidth);
				Tweener.addTween(overallProgressRect, {percentWidth:percentValue, time:2, delay:0, transition:"easeOutSine"});
				
			}
		}
		
	}
	
}