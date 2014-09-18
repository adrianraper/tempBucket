package com.clarityenglish.clearpronunciation.view.course {

	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import flash.events.Event;
	
	import org.davekeen.util.StringUtils;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class UnitCaptionComponent extends SkinnableComponent {
		
		private var _source:String;
		private var _copyProvider:CopyProvider;
		 
		public static var mediaFolder:String;
		
		public function UnitCaptionComponent()
		{
			super();
		}
		
		public function set copyProvider(value:CopyProvider):void {
			_copyProvider = value;
		}
		
		[Bindable]
		public function get copyProvider():CopyProvider {
			return _copyProvider;
		}
		
		public function set source(value:String):void {
			_source = value;
			dispatchEvent(new Event("sourceChanged"));
		}
		

		[Bindable(event="sourceChanged")]
		public function get iconLabel():String {
			return copyProvider.getCopyForId(_source);
		}
		
		[Bindable(event="sourceChanged")]
		public function get labelText():String {
			return _source;
		}
		
		[Bindable(event="sourceChanged")]
		public function get mp3Source():String {
			if (_source)
				return (StringUtils.beginsWith(_source.toLowerCase(), "http")) ? _source : mediaFolder  + _source + ".mp3";
			
			return null;
		}
		
	}
}