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
	
	import mx.collections.ArrayCollection;
	import mx.core.mx_internal;
	
	import org.davekeen.util.Closure;
	import org.osmf.events.BufferEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaPlayerState;
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
		
		// #318
		private var queuedVideoHref:Href;
		private var currentVideoHref:Href;
		private var currentVideoStartTime:Date;
		
		public function ZoneMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ZoneView {
			return viewComponent as ZoneView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.videoPlayerStateChange.add(onVideoPlayerStateChange);
			
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
					
			//Alice: automatic multiple channel
			view.channelcollection.source=configProxy.getConfig().channelArray;
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.videoPlayerStateChange.remove(onVideoPlayerStateChange);
			
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
			
			// #318 - due to the order things happen we store the new href in 'queuedVideoHref' and the 'playing' state change moves it from queued into current.
			// If we don't use this slightly roundabout system we can end up writing durations for the wrong video when changing between them.
			queuedVideoHref = href;
			
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
			
			// #335
			/*var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var channelName:String = configProxy.getConfig().mediaChannel;*/

			
			//Alice: multiple channel
			var channelName:String;
			var streamName:String;
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			
			if(view.questionZoneChannelButtonBar.selectedItem==null){
				channelName=view.adviceZoneChannelButtonBar.selectedItem.name;
				streamName=view.adviceZoneChannelButtonBar.selectedItem.streamName;
			    //configProxy.getConfig().channelchoice=channelName;
				view.choice=view.adviceZoneChannelButtonBar.selectedIndex;
			}else{
				channelName=view.questionZoneChannelButtonBar.selectedItem.name;
				streamName=view.questionZoneChannelButtonBar.selectedItem.streamName;
				//configProxy.getConfig().channelchoice=channelName;
				view.choice=view.adviceZoneChannelButtonBar.selectedIndex;
			}

			
			// To cope with original format files
			if (dynamicList.channel.hasOwnProperty("@name")) {
				var channel:XML = dynamicList.channel.(@name==channelName)[0];
				var protocol:String = channel.@protocol.toString();
			} else {
				channel = dynamicList.channel[0];
				protocol = channel.streaming.toString();
			}
			var host:String = channel.host.toString();
			
			// Replace any virtual paths
			/*if (host.indexOf('{streamingMedia}') >= 0) 
				host = host.replace("{streamingMedia}", configProxy.getConfig().streamingMedia);
			if (host.indexOf('{contentPath}') >= 0) 
				host = host.replace("{contentPath}", configProxy.getContentPath());*/
			
			if (host.indexOf('{streamingMedia}') >= 0) 
				host = host.replace("{streamingMedia}", streamName);
			if (host.indexOf('{contentPath}') >= 0) 
				host = host.replace("{contentPath}", configProxy.getContentPath());
			
			if (protocol == "rtmp") {
				var server:String = channel.server.toString();
				var dynamicSource:DynamicStreamingResource = new DynamicStreamingResource(host);
				
				if (server == "fms") dynamicSource.urlIncludesFMSApplicationInstance = true;
				
				dynamicSource.streamType = channel.type.toString();
				var streamItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();
				for each (var stream:XML in channel.item) {
					var streamingItem:DynamicStreamingItem = new DynamicStreamingItem(stream.streamName, stream.bitrate);
					streamItems.push(streamingItem);
				}
				dynamicSource.streamItems = streamItems; 
				
				videoPlayer.source = dynamicSource;
				videoPlayer.callLater(videoPlayer.play);
				
			// Rackspace's pseudo streaming over http
			} else if (protocol == "http") {
				//videoPlayer.source = host + channel.item[0].streamName.toString() + ".f4m";
				videoPlayer.source = host + channel.item[0].streamName.toString() + ".flv";
				videoPlayer.callLater(videoPlayer.play);
				
			// Vimeo's progressive download
			// Network simple connection
			} else if (protocol == "progressive-download") {
				
				videoPlayer.source = host + channel.item[0].streamName.toString();
				videoPlayer.callLater(videoPlayer.play);
				
			} else {
				log.error(protocol + " streaming type not supported");
				videoPlayer.stop();
				videoPlayer.source = null;
			}
			
			// Allow the listener to be garbage collected
			urlLoader = null;
		}
		
		public function onVideoPlayerStateChange(event:MediaPlayerStateChangeEvent):void {
			log.info("video state is " + event.state);
			
			switch (event.state) {
				case MediaPlayerState.PLAYING:
					if (!currentVideoStartTime) {
						currentVideoHref = queuedVideoHref;
						currentVideoStartTime = new Date();
					}
					break;
				case MediaPlayerState.READY:
				case MediaPlayerState.PAUSED:
					if (currentVideoStartTime) { // #318
						var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
						var exerciseMark:ExerciseMark = new ExerciseMark();
						exerciseMark.duration = (new Date().getTime() - currentVideoStartTime.getTime()) / 1000;
						exerciseMark.UID = bentoProxy.getExerciseUID(currentVideoHref);
						
						// Trigger a notification to write the score out
						sendNotification(BBNotifications.SCORE_WRITE, exerciseMark)
						
						currentVideoStartTime = null;
					}
					break;
			}
		}
		
		public function onVideoPlayerComplete(event:TimeEvent):void {
			log.info("video completed " + event.toString());
		}
		
	}
}
