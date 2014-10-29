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
	import spark.components.Label;
	
	public class SettingsView extends BentoView {
		
		[SkinPart]
		public var videoSelector:VideoSelector;
		
		[SkinPart]
		public var settingsLabel:Label;
		
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
			var videoXMLListCollection:XMLListCollection = new XMLListCollection();
			videoXMLListCollection.addItem(course[1].unit[0].exercise[0].exercise[0].exercise[0]);
			videoSelector.videoCollection = videoXMLListCollection;
			videoSelector.placeholderSource = href.rootPath + "/" + course[1].unit[0].exercise[0].exercise[0].@placeholder;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case saveCloseButton:
					saveCloseButton.label = copyProvider.getCopyForId("closeButton");
					saveCloseButton.addEventListener(MouseEvent.CLICK, onSaveCloseClick);
					break;
				case settingsLabel:
					settingsLabel.text = copyProvider.getCopyForId("settingsLabel");
					break;
			}
		}
		
		protected function onSaveCloseClick(event:MouseEvent):void {
			channelSaveClose.dispatch(videoSelector.channelList.selectedIndex);
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
	}
}