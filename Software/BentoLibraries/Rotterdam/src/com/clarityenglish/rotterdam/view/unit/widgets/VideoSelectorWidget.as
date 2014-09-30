package com.clarityenglish.rotterdam.view.unit.widgets {
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.controls.video.VideoSelector;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	
	public class VideoSelectorWidget extends AbstractWidget{
		
		[SkinPart]
		public var videoSelector:VideoSelector;
		
		private var _href:Href;
		private var _channelCollection:ArrayCollection;
		
		public function set href(value:Href):void {
			_href = value;
		}
		
		public function set channelCollection(value:ArrayCollection):void {
			_channelCollection = value;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case videoSelector:
					videoSelector.href = _href;
					videoSelector.channelCollection = _channelCollection;
					videoSelector.videoCollection = new XMLListCollection(xml.exercise);
					videoSelector.placeholderSource = _href.rootPath + "/" + xml.@placeholder;
					break;
			}
		}
	}
}