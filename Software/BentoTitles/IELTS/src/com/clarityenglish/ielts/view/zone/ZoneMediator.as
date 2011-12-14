package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.ielts.IELTSNotifications;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class ZoneMediator extends BentoMediator implements IMediator {
		
		public function ZoneMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ZoneView {
			return viewComponent as ZoneView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// listen for these signals
			view.courseSelect.add(onCourseSelected);
			view.exerciseSelect.add(onExerciseSelected);
			view.videoSelected.add(onVideoSelected);
			
			// This view runs of the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.courseSelect.remove(onCourseSelected);
			view.exerciseSelect.remove(onExerciseSelected);
			view.exerciseSelect.remove(onVideoSelected);
		}
        
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				//IELTSNotifications.COURSE_SHOW,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				// You can't send a notification like this from another mediator under Title as this mediator will not exist
				/*
				case IELTSNotifications.COURSE_SHOW:
					var course:XMLList = note.getBody() as XMLList;
					view.course = course[0] as XML;
					break;
				*/
			}
		}
		
		/**
		 * An exercise was selected. Based on the extension of the Href we either want to open an exercise or open a pdf.
		 * 
		 * @param href
		 */
		private function onExerciseSelected(href:Href):void {
			sendNotification(IELTSNotifications.HREF_SELECTED, href);
		}
		
		/**
		 * Trigger the display of a course in the zone view
		 *
		 */
		private function onCourseSelected(course:XML):void {
			
			sendNotification(IELTSNotifications.COURSE_SHOW, course);
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			bentoProxy.currentCourseClass = course.@["class"];
		}
		
		/**
		 * Trigger the display of a video in the advice zone view and note that you are doing it in progress
		 * @param videoSource
		 * @return 
		 * 
		 */
		private function onVideoSelected(href:Href):void {
			
			// #81 If the href is not a simple video file, it might be a dynamic streaming list
			//var videoSource:String = href.createRelativeHref(null, adviceZoneVideoList.selectedItem.@href).url;
			var videoSource:String = href.url;
			
			if (videoSource.indexOf("rss")>0 || videoSource.indexOf("xml")>0) {
				
				var urlLoader:URLLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE, onAdviceZoneVideoRSSLoadComplete);
				urlLoader.load(new URLRequest(videoSource));
				
			} else {
				
				view.adviceZoneVideoPlayer.source = videoSource;
				// #63
				view.callLater(function():void {
					view.adviceZoneVideoPlayer.play();
				});
			}
			
			// #111 Write a record that they have started watching the video
			// Unless you can simply record that they started and then write the record when they stop?
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var thisExerciseMark:ExerciseMark = new ExerciseMark();
			thisExerciseMark.duration = 0
			thisExerciseMark.UID = bentoProxy.getExerciseUID(href);
			
			// Trigger a notification to write the score out
			sendNotification(BBNotifications.SCORE_WRITE, thisExerciseMark);

		}
		protected function onAdviceZoneVideoRSSLoadComplete(e:Event):void {
			var dynamicList:XML = new XML(e.target.data);
			
			// Build the mxml component
			var host:String = dynamicList.channel.host.toString();
			var dynamicSource:DynamicStreamingResource = new DynamicStreamingResource(host);
			dynamicSource.urlIncludesFMSApplicationInstance = true;
			dynamicSource.streamType = dynamicList.channel.type.toString();
			var streamItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();
			for each (var stream:XML in dynamicList.channel.item) {
				var streamName:String = stream.streamName;
				var bitrate:Number = stream.bitrate;
				var streamingItem:DynamicStreamingItem = new DynamicStreamingItem(streamName, bitrate);
				streamItems.push(streamingItem);
			}
			dynamicSource.streamItems = streamItems; 
			view.adviceZoneVideoPlayer.source = dynamicSource;
			//view.adviceZoneVideoPlayer.addEventListener(TimeEvent.COMPLETE, videoPlayerCompleteHandler);
			//view.adviceZoneVideoPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, videoPlayerStateChangeHandler);
			view.adviceZoneVideoPlayer.autoPlay = true;
			
			// #63 - overidden by #119
			/*callLater(function():void {
			adviceZoneVideoPlayer.play();
			});*/
			
		}
		public function videoPlayerStateChangeHandler(event:MediaPlayerStateChangeEvent):void {
			log.info("video state is " + event.state);
		}
		public function videoPlayerCompleteHandler(event:TimeEvent):void {
			log.info("video completed " + event.toString());
		}

	}
}
