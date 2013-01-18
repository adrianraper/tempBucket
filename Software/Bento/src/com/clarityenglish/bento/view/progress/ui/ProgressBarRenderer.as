package com.clarityenglish.bento.view.progress.ui {
	import almerblank.flex.spark.components.SkinnableDataRenderer;
	
	import caurina.transitions.Tweener;
	
	import com.adobe.utils.StringUtil;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import mx.graphics.SolidColor;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.StringUtils;
	
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
		
		private var _dataChanged:Boolean;
		
		private var _copyProvider:CopyProvider;
		
		// gh#11 Language Code
		public function set copyProvider(copyProvider:CopyProvider):void {
			_copyProvider = copyProvider;
		}

		public override function set data(value:Object):void {
			super.data = value;
			_dataChanged = true;
			invalidateProperties();
		}
		
		protected override function commitProperties():void {
			super.commitProperties(); 
			
			if (data && _dataChanged) {
				var course:XML = data..course.(@["class"] == courseClass)[0];
				solidColour.color = getStyle(courseClass + "Color");
				backColour.color = getStyle(courseClass + "ColorDark");
				
				// gh#11 language Code - is this for coverage or score?
				if (type == 'coverage') {
					var courseLabel:String = StringUtils.capitalize(courseClass).toString();
					commentLabel.text = _copyProvider.getCopyForId(courseLabel) + _copyProvider.getCopyForId("ProgressBarCoverage") + " " + new Number(course.@coverage) + "%";
					var percentValue:Number = new Number(course.@coverage);
				} else {
					courseLabel = StringUtils.capitalize(courseClass).toString();
					commentLabel.text = _copyProvider.getCopyForId(courseLabel) + _copyProvider.getCopyForId("ProgressBarScore") + " " + new Number(course.@averageScore) + "%";
					percentValue = new Number(course.@averageScore);
				}
				
				// Tween it
				Tweener.removeTweens(overallProgressRect, percentWidth);
				Tweener.addTween(overallProgressRect, { percentWidth: percentValue, time: 2, delay: 0, transition: "easeOutSine" });
				
				_dataChanged = false;
			}
		}
		
	}
	
}