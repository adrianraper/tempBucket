package com.clarityenglish.ielts.view.home.ui {
	import almerblank.flex.spark.components.SkinnableDataRenderer;
	
	import caurina.transitions.Tweener;
	
	import mx.graphics.SolidColor;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.Label;
	import spark.primitives.Rect;

	public class CourseBarRenderer extends SkinnableDataRenderer {
		
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
		
		private var _courseCaption:String;
		
		public function set courseCaption(value:String):void {
			_courseCaption = value;
		}

		public function set dataProvider(value:XML):void {
			
			if (value) {
				// mySummary information is now buried in myDetails instead of it's own XML
				var course:XML = value.course.(@["class"]==courseClass)[0];
				//var courseSummaryInfo:XML = value.course.(@["class"]==courseClass).summaryInfo[0];
				solidColour.color = getStyle(courseClass + "Color");
				backColour.color = getStyle(courseClass + "ColorDark");
				commentLabel.text = _courseCaption + " - overall coverage " + new Number(course.@coverage) + "%";
				var percentValue:Number = new Number(course.@coverage);
				//var percentValue:Number = new Number(courseSummaryInfo.@coverage);
							
				// Tween it
				Tweener.removeTweens(overallProgressRect, percentWidth);
				Tweener.addTween(overallProgressRect, {percentWidth:percentValue, time:2, delay:0, transition:"easeOutSine"});
				
			}
		}
		
		// If I need this anywhere else, put it in a StringUtil class
		private function properCase(word:String):String {
			return word.charAt(0).toUpperCase()+word.substr(1).toLowerCase();
		}
	}
}