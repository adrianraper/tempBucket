package com.clarityenglish.clearpronunciation.view.home.ui {
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import spark.components.Button;
	import spark.components.supportClasses.ButtonBase;
	
	public class UnitListButton extends ButtonBase {
		private var _caption:String;
		private var _leftItemButtonLabel:String;
		private var _rightItemButtonLabel:String;
		private var _leftIconString:String;
		private var _rightIconString:String;
		private var _itemIndex:String;
		private var _copyProvider:CopyProvider;
		
		[Bindable]
		public function get leftItemButtonLabel():String {
			return _leftItemButtonLabel;
		}
		
		public function set leftItemButtonLabel(value:String):void {
			_leftItemButtonLabel = value;
		}
		
		[Bindable]
		public function get rightItemButtonLabel():String {
			return _rightItemButtonLabel;
		}
		
		public function set rightItemButtonLabel(value:String):void {
			_rightItemButtonLabel = value;
		}
		
		[Bindable]
		public function get caption():String {
			return _caption;
		}
		
		public function set caption(value:String):void {
			_caption = value;
		}
		
		[Bindable]
		public function get leftIconString():String {
			return _leftIconString;	
		}
		
		public function set leftIconString(value:String):void {
			_leftIconString = value;
		}
		
		[Bindable]
		public function get rightIconString():String {
			return _rightIconString;
		}
		
		public function set rightIconString(value:String):void {
			_rightIconString = value;
		}
		
		[Bindable]
		public function get itemIndex():String {
			return _itemIndex;
		}
		
		public function set itemIndex(value:String):void {
			_itemIndex = value;
		}
		
		[Bindable]
		public function get copyProvider():CopyProvider {
			return _copyProvider;
		}
		
		public function set copyProvider(value:CopyProvider):void {
			_copyProvider = value;
		}
	}
}