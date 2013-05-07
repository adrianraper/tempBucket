package com.clarityenglish.controls.video {
	import flash.events.IEventDispatcher;
	
	public interface IVideoPlayer extends IEventDispatcher {
		
		function get source():Object;
		function set source(value:Object):void;
		
		function play():void;
		function stop():void;
		
		function get width():Number;
		function set width(value:Number):void;
		
		function get height():Number;
		function set height(value:Number):void;
		
		function get x():Number;
		function set x(value:Number):void;
		
		function get y():Number;
		function set y(value:Number):void;
		
	}
	
}