package com.clarityenglish.ielts.view.zone.ui {
	
	import almerblank.flex.spark.components.SkinnableItemRenderer;
	
	import com.clarityenglish.bento.vo.Href;
	
	import almerblank.flex.spark.components.SkinnableItemRenderer;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Image;
	
	public class ImageItemRenderer extends SkinnableItemRenderer {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		[SkinPart(required="true")]
		public var image:Image;
		
		public var exerciseClick:Signal;
		public var href:Href;
		
		public var courseClass:String;
		
		[Embed(source="skins/ielts/assets/defaultExerciseThumbnail.png")]
		private static var defaultExerciseThumbnail:Class;
		
		[Embed(source="skins/ielts/assets/ioErrorThumbnail.png")]
		private static var ioErrorThumbnail:Class;
		
		[Embed(source="skins/ielts/assets/Reading_thumbnail.png")] 
		private static var readingThumbnail:Class;
		[Embed(source="skins/ielts/assets/Writing_thumbnail.png")]
		private static var writingThumbnail:Class;
		[Embed(source='skins/ielts/assets/Listening_thumbnail.png')] 
		private static var listeningThumbnail:Class;
		[Embed(source='skins/ielts/assets/Speaking_thumbnail.png')]
		private static var speakingThumbnail:Class;

		public override function set data(value:Object):void {
			super.data = value;
			
			var thumbnailSource:Object;
			switch (courseClass) {
				case "reading":
					thumbnailSource = readingThumbnail;
					break;
				case "writing":
					thumbnailSource = writingThumbnail;
					break;
				case "speaking":
					thumbnailSource = speakingThumbnail;
					break;
				case "listening":
					thumbnailSource = listeningThumbnail;
					break;
				default:
					thumbnailSource = defaultExerciseThumbnail;						
			}
			if (data) {
				image.source = (data.@thumbnail.toString() != "") ? href.createRelativeHref(null, data.@thumbnail.toString()).url : thumbnailSource;
			} else {
				image.source = thumbnailSource;
			}
		}
		
		protected function onComplete(e:Event):void {
			log.info("onComplete for {0}", e.toString());
		}
		
		protected function onError(e:IOErrorEvent):void {
			log.info("onError for {0}", e.toString());
			
			if (image)
				image.source = ioErrorThumbnail;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case image:
					image.addEventListener(MouseEvent.CLICK, onClick);		
					image.addEventListener(Event.COMPLETE, onComplete);
					image.addEventListener(IOErrorEvent.IO_ERROR, onError);
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
			switch (instance) {
				case image:
					image.removeEventListener(MouseEvent.CLICK, onClick);
					image.removeEventListener(Event.COMPLETE, onComplete);
					image.removeEventListener(IOErrorEvent.IO_ERROR, onError);
					break;
			}
		}
		
		protected function onClick(event:MouseEvent):void {
			if (exerciseClick)
				exerciseClick.dispatch(data);
		}
		
	}
	
}
