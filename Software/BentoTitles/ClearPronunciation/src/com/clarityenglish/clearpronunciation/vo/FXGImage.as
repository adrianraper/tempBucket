package com.clarityenglish.clearpronunciation.vo
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import mx.core.UIComponent;
	
	public class FXGImage extends UIComponent
	{
		public function FXGImage(source:Class = null)
		{
			if(source){
				this.source = source;
			}
			super();
		}
		
		// this will tell us the class we want to use for the display
		// most likely an fxgClass
		private var _source : Class;
		protected var sourceChanged :Boolean = true;
		
		public function get source():Class
		{
			return _source;
		}
		
		public function set source(value:Class):void
		{
			_source = value;
			sourceChanged = true;
			this.commitProperties();
		}
		
		public var imageInstance : DisplayObject;
		
		// if you want to offset the position of the X and Y values in the 
		public var XOffset :int = 0;
		public var YOffset :int = 0;
		
		// if you want to offset the position of the X and Y values in the 
		public var heightOffset :int = 0;
		public var widthOffset :int = 0;
		
		
		override protected function createChildren():void{
			super.createChildren();
			if(this.sourceChanged){
				if(this.imageInstance){
					this.removeChild(this.imageInstance);
					this.imageInstance = null;
				}
				
				if(this.source){
					this.imageInstance = new source();
					this.imageInstance.x = 0 + XOffset;
					this.imageInstance.y = 0 + YOffset;
					this.addChild(this.imageInstance);
				}
				this.sourceChanged = false;
				
			}
		}
		
		override protected function commitProperties():void{
			super.commitProperties();
			if(this.sourceChanged){
				// if the source changed re-created it; which is done in createChildren();
				this.createChildren();
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if(unscaledHeight != 0){
				this.imageInstance.height = unscaledHeight + this.heightOffset;
			}
			if(unscaledWidth != 0){
				this.imageInstance.width = unscaledWidth + this.widthOffset;
			}
		}
		
	}
}