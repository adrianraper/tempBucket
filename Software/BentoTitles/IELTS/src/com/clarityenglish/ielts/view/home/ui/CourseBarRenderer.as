package com.clarityenglish.ielts.view.home.ui {
	import almerblank.flex.spark.components.SkinnableDataRenderer;
	
	import caurina.transitions.Tweener;
	
	import mx.graphics.SolidColor;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.Label;
	import spark.primitives.Rect;
	
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	public class CourseBarRenderer extends SkinnableDataRenderer {
		
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		[SkinPart(required = "true")]
		public var commentLabel:Label;
		
		[SkinPart(required = "true")]
		public var overallProgressRect:Rect;
		
		[SkinPart(required = "true")]
		public var solidColour:SolidColor;
		
		[SkinPart(required = "true")]
		public var backColour:SolidColor;
		
		public var courseClass:String;
		
		private var _courseCaption:String;
		private var _courseCaptionChanged:Boolean;
		
		private var _dataChanged:Boolean;
		
		private var _copyProvider:CopyProvider;
		
		public function set copyProvider(copyProvider:CopyProvider):void {
			_copyProvider = copyProvider;
		}
		
		public function set courseCaption(value:String):void {
			_courseCaption = value;
			_courseCaptionChanged = true;
			invalidateProperties();
		}
		
		public override function set data(value:Object):void {
			super.data = value;
			_dataChanged = true;
			invalidateProperties();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if ((_courseCaptionChanged || _dataChanged) && data) {
				var course:XML = data..course.(@["class"] == courseClass)[0];
				
				// #338 Just in case you have hidden some of the courses
				if (course) {
					solidColour.color = getStyle(courseClass + "Color");
					backColour.color = getStyle(courseClass + "ColorDark");
					commentLabel.text = _courseCaption + " " + _copyProvider.getCopyForId("overallCoverage") + " " + new Number(course.@coverage) + "%";
					var percentValue:Number = new Number(course.@coverage);
					
					// Tween it
					Tweener.removeTweens(overallProgressRect, percentWidth);
					Tweener.addTween(overallProgressRect, {percentWidth: percentValue, time: 2, delay: 0, transition: "easeOutSine"});
				} else {
					backColour.color = getStyle("disabledColor");
					commentLabel.text = _courseCaption + " is hidden";
				}
				
				_courseCaptionChanged = _dataChanged = false;
			}
		}
		
		// If I need this anywhere else, put it in a StringUtil class
		private function properCase(word:String):String {
			return word.charAt(0).toUpperCase() + word.substr(1).toLowerCase();
		}
		
	}
}
