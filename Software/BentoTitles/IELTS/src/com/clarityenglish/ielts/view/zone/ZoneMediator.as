package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.ielts.IELTSNotifications;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.core.mx_internal;
	
	import org.davekeen.util.Closure;
	import org.osmf.events.BufferEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	import spark.components.VideoPlayer;
	
	/**
	 * A Mediator
	 */
	public class ZoneMediator extends BentoMediator implements IMediator {

		private var urlLoader:URLLoader;
		
		public function ZoneMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ZoneView {
			return viewComponent as ZoneView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// Inject required data into the view
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			view.user = loginProxy.user;
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.dateFormatter = configProxy.getDateFormatter();
			// #234
			view.productVersion = configProxy.getProductVersion();
			view.licenceType = configProxy.getLicenceType();
			
			// listen for these signals
			view.courseSelect.add(onCourseSelected);
			view.exerciseSelect.add(onExerciseSelected);
			view.videoSelected.add(onVideoSelected);
			
			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			view.isMediated = true; // #222
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.courseSelect.remove(onCourseSelected);
			view.exerciseSelect.remove(onExerciseSelected);
			view.exerciseSelect.remove(onVideoSelected);
			
			view.isMediated = false; // #222
		}
        
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.SCORE_WRITTEN,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				// #164 For updating of coverage blobs when you do another exercise
				case BBNotifications.SCORE_WRITTEN:
					view.popoutExerciseSelector.exercises = view.refreshedExercises();
					break;
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
		 * 
		 * @param videoSource
		 * @return 
		 */
		private function onVideoSelected(href:Href, zoneName:String):void {
			// #81 If the href is not a simple video file, it might be a dynamic streaming list
			var videoSource:String = href.url;
			
			// Get the target video player
			var videoPlayer:VideoPlayer;
			switch (zoneName) {
				case "question-zone":
					videoPlayer = view.questionZoneVideoPlayer;
					break;
				case "advice-zone":
					videoPlayer = view.adviceZoneVideoPlayer;
					break;
				default:
					log.error("Unknown zone name " + zoneName);
					return;
			}
			
			// #208
			videoPlayer.videoDisplay.mx_internal::videoPlayer.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
			
			if (videoSource.match(/\.(rss|xml)$/)) {
				urlLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE, Closure.create(this, onRssLoadComplete, videoPlayer));
				urlLoader.load(new URLRequest(videoSource));
			} else {
				videoPlayer.source = videoSource;
				// #63
				view.callLater(function():void {
					videoPlayer.play();
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
			
			// #269
			sendNotification(BBNotifications.ACTIVITY_TIMER_RESET);
		}
		
		protected function onBufferingChange(event:Event):void {
			//trace("buffering change, bufferTime is " + event.target.bufferTime);
			event.target.removeEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
			event.target.bufferTime = 4;
		}
		
		private function onRssLoadComplete(e:Event, videoPlayer:VideoPlayer):void {
			var dynamicList:XML = new XML(e.target.data);
			
			var streaming:String = dynamicList.channel.streaming.toString();
			var server:String = dynamicList.channel.server.toString();
			var host:String = dynamicList.channel.host.toString();
			
			if (streaming == "rtmp") {
				var dynamicSource:DynamicStreamingResource = new DynamicStreamingResource(host);
				
				if (server == "fms") dynamicSource.urlIncludesFMSApplicationInstance = true;
				
				dynamicSource.streamType = dynamicList.channel.type.toString();
				var streamItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();
				for each (var stream:XML in dynamicList.channel.item) {
					var streamingItem:DynamicStreamingItem = new DynamicStreamingItem(stream.streamName, stream.bitrate);
					streamItems.push(streamingItem);
				}
				dynamicSource.streamItems = streamItems; 
				
				videoPlayer.source = dynamicSource;
				videoPlayer.callLater(videoPlayer.play);
				
			// Rackspace's pseudo streaming over http
			} else if (streaming == "http") {
				videoPlayer.source = host + dynamicList.channel.item[0].streamName.toString() + ".f4m";
				videoPlayer.callLater(videoPlayer.play);
				
			// Vimeo's progressive download
			} else if (streaming == "progressive-download") {
				videoPlayer.source = host + dynamicList.channel.item[0].streamName.toString();
				videoPlayer.callLater(videoPlayer.play);
				
			} else {
				log.error(streaming + " streaming type not supported");
				videoPlayer.stop();
				videoPlayer.source = null;
			}
			
			// Allow the listener to be garbage collected
			urlLoader = null;
		}
		
		public function videoPlayerStateChangeHandler(event:MediaPlayerStateChangeEvent):void {
			log.info("video state is " + event.state);
		}
		
		public function videoPlayerCompleteHandler(event:TimeEvent):void {
			log.info("video completed " + event.toString());
		}

	}
}
