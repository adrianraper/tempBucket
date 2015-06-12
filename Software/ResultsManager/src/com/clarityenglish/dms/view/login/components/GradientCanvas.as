package com.clarityenglish.dms.view.login.components {
	import mx.containers.Canvas;
	import mx.styles.StyleManager;
	import mx.utils.ColorUtil;
	import flash.geom.*
	import flash.display.*
	
	public class GradientCanvas extends Canvas {
		override protected function updateDisplayList(w:Number, h:Number): void {
			super.updateDisplayList(w, h);
			
			this.graphics.clear();
			
			// retrieves the user-defined styles
			var fillColors:Array = getStyle("fillColors");
			var cornerRadius:Number = getStyle("cornerRadius");
			
			var _fillType:String = GradientType.LINEAR;
			var _alphas:Array = [1, 1];
			var _ratios:Array = [0, 255];
			var m:Matrix = new Matrix();
			m.createGradientBox(w, h, 1.5);
			var spreadMethod:String = SpreadMethod.PAD;
			
			this.graphics.beginGradientFill(_fillType, fillColors, _alphas, _ratios, m, spreadMethod);
			this.graphics.drawRect(0, 0, w, h);
			this.graphics.endFill();
		}
	}
} 