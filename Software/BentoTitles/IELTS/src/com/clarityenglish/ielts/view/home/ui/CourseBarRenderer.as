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

		private var _dataChanged:Boolean;
		private var _detailData:XML;

		public function set courseCaption(value:String):void {
			_courseCaption = value;
		}

		public override function set data(value:Object):void {
			super.data = value;
			_detailData = value as XML;
			_dataChanged= true;
			invalidateProperties();
		}
		protected override function commitProperties():void {
			super.commitProperties();
			if (_dataChanged && _detailData) {
				var course:XML = _detailData.course.(@["class"]==courseClass)[0];
				
				// #338 Just in case you have hidden some of the courses
				if (course) {
					//var courseSummaryInfo:XML = value.course.(@["class"]==courseClass).summaryInfo[0];
					solidColour.color = getStyle(courseClass + "Color");
					backColour.color = getStyle(courseClass + "ColorDark");
					commentLabel.text = _courseCaption + " - overall coverage " + new Number(course.@coverage) + "%";
					var percentValue:Number = new Number(course.@coverage);
					//var percentValue:Number = new Number(courseSummaryInfo.@coverage);
								
					// Tween it
					Tweener.removeTweens(overallProgressRect, percentWidth);
					Tweener.addTween(overallProgressRect, {percentWidth:percentValue, time:2, delay:0, transition:"easeOutSine"});
					
				} else {
					backColour.color = getStyle("disabledColor");
					commentLabel.text = _courseCaption + " is hidden";
				}
			}
		}
		
		// If I need this anywhere else, put it in a StringUtil class
		private function properCase(word:String):String {
			return word.charAt(0).toUpperCase()+word.substr(1).toLowerCase();
		}
	}
}