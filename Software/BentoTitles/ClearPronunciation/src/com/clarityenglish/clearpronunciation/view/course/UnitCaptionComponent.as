package com.clarityenglish.clearpronunciation.view.course {

	import flash.events.Event;
	
	import org.davekeen.util.StringUtils;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class UnitCaptionComponent extends SkinnableComponent {
		
		private var _source:String;
		public static var mediaFolder:String;
		
		public function UnitCaptionComponent()
		{
			super();
		}
		
		public function set source(value:String):void {
			_source = value;
			dispatchEvent(new Event("sourceChanged"));
		}
		
		[Bindable(event="sourceChanged")]
		public function get swfSource():String {
			return (StringUtils.beginsWith(_source.toLowerCase(), "http")) ? _source : mediaFolder + _source + "_small.swf";
		}
		
		[Bindable(event="sourceChanged")]
		public function get mp3Source():String {
			if (_source)
				return (StringUtils.beginsWith(_source.toLowerCase(), "http")) ? _source : mediaFolder  + _source + ".mp3";
			
			return null;
		}
		
	}
}