package com.clarityenglish.testadmin.view.login.components {
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
			var fillAlphas:Array = getStyle("fillAlphas");
			var cornerRadius:Number = getStyle("cornerRadius");
			var fillType:String = getStyle("fillType");
			
			var _fillType:String = fillType; // GradientType.LINEAR
			var _alphas:Array = fillAlphas; // [1, 1];
			var _ratios:Array = [0, 255];
			var m:Matrix = new Matrix();
			m.createGradientBox(w, h, 0, 0, -h/3);
			var spreadMethod:String = SpreadMethod.PAD;
			
			this.graphics.beginGradientFill(_fillType, fillColors, _alphas, _ratios, m, spreadMethod);
			this.graphics.drawRect(0, 0, w, h);
			//this.graphics.drawRoundRect(0, 0, w, h, cornerRadius, cornerRadius);
			this.graphics.endFill();
		}
	}
} 