package com.clarityenglish.clearpronunciation.view.settings {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.controls.video.VideoSelector;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import mx.events.CloseEvent;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	
	public class SettingsView extends BentoView {
		
		[SkinPart]
		public var videoSelector:VideoSelector;
		
		[SkinPart]
		public var saveCloseButton:Button;
		
		public var channelCollection:ArrayCollection;
		public var channelSaveClose:Signal = new Signal(Number);
		
		private var course:XMLList;
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			course = xhtml..menu.(@id == productCode).course;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			videoSelector.href = href;
			videoSelector.channelCollection = channelCollection;
			videoSelector.videoCollection = new XMLListCollection(course[0].unit[0].exercise);
			videoSelector.placeholderSource = href.rootPath + "/" + course[0].unit[0].exercise.@placeholder;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case saveCloseButton:
					saveCloseButton.addEventListener(MouseEvent.CLICK, onSaveCloseClick);
					break;
			}
		}
		
		protected function onSaveCloseClick(event:MouseEvent):void {
			channelSaveClose.dispatch(videoSelector.channelList.selectedIndex);
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
	}
}