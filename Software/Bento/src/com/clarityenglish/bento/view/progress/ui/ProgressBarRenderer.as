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
		
		[Bindable]
		public var trackColour:Number;
		
		[Bindable]
		public var fillColour:Number;
		
		private var _label:String;
		
		public function set label(value:String):void {
			_label = value;
			invalidateProperties();
		}
		
		public override function set data(value:Object):void {
			super.data = value;
			invalidateProperties();
		}
		
		protected override function commitProperties():void {
			super.commitProperties(); 
			
			if (_label) {
				commentLabel.text = _label +  " " + new Number(data) + "%";
			}
			
			// Tween it
			Tweener.removeTweens(overallProgressRect, percentWidth);
			Tweener.addTween(overallProgressRect, { percentWidth: data, time: 2, delay: 0, transition: "easeOutSine" });
		}
		
	}
	
}