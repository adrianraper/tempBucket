package com.clarityenglish.clearpronunciation.view.course {

	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import flash.events.Event;
	
	import org.davekeen.util.StringUtils;
	
	import spark.components.mediaClasses.VolumeBar;
	import spark.components.supportClasses.SkinnableComponent;
	
	public class UnitCaptionComponent extends SkinnableComponent {
		
		private var _text:String;
		private var _phoneticSymbol:String;
		private var _audioSource:String;
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
		
		[Bindable]
		public function get text():String {
			return _text;
		}
		
		public function set text(value:String):void {
			_text = value;
		}
		
		public function set phoneticSymbol(value:String):void {
			_phoneticSymbol = value;
			dispatchEvent(new Event("phoneticSymbolChanged"));
		}
		
		[Bindable(event="phoneticSymbolChanged")]
		public function get symbol():String {
			return copyProvider.getCopyForId(_phoneticSymbol);
		}
		
		[Bindable]
		public function get audioSource():String {
			if (_audioSource)
				return (StringUtils.beginsWith(_audioSource.toLowerCase(), "http")) ? _audioSource : mediaFolder  + _audioSource.toLowerCase() + ".mp3";
			
			return null;
		}
		
		public function set audioSource(value:String):void {
			_audioSource = value;
		}
		
	}
}