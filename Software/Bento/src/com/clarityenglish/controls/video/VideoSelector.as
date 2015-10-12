package com.clarityenglish.controls.video {
import com.clarityenglish.bento.events.ExerciseEvent;
import com.clarityenglish.bento.vo.ExerciseMark;
import com.clarityenglish.bento.vo.Href;
import com.clarityenglish.controls.video.events.VideoEvent;
import com.clarityenglish.controls.video.events.VideoScoreEvent;
import com.clarityenglish.controls.video.loaders.RssVideoLoader;

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.net.NetStream;

import flashx.textLayout.elements.TextFlow;

import mx.collections.IList;
import mx.logging.ILogger;
import mx.logging.Log;

import org.davekeen.util.ClassUtil;
import org.osmf.events.DynamicStreamEvent;
import org.osmf.events.TimeEvent;

import spark.components.Button;
import spark.components.Group;
import spark.components.Image;
import spark.components.List;
import spark.components.RichEditableText;
import spark.components.supportClasses.SkinnableComponent;
import spark.effects.Animate;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.events.IndexChangeEvent;
import spark.utils.TextFlowUtil;

    [Event(name="exerciseSelected", type="com.clarityenglish.bento.events.ExerciseEvent")]
	[Event(name="videoScore", type="com.clarityenglish.controls.video.events.VideoScoreEvent")]
	public class VideoSelector extends SkinnableComponent {

		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));

		[SkinPart]
		public var videoPlayer:IVideoPlayer;

		[SkinPart]
		public var channelList:List;

		[SkinPart]
		public var videoList:List;

		[SkinPart]
		public var placeholderImage:Image;

		[SkinPart]
		public var scriptButton:Button;

		[SkinPart]
		public var rollOutTextGroup:Group;

		[SkinPart]
		public var rollOutRichEditableText:RichEditableText;

		public var href:Href;

		// This is a function that turns an href into a uid (Href -> String)
		public var hrefToUidFunction:Function;

		protected var _channelCollection:IList;
		protected var _channelCollectionChanged:Boolean;

		protected var _videoCollection:IList;
		protected var _videoCollectionChanged:Boolean;

		protected var _placeholderSource:Object;
		protected var _placeholderSourceChanged:Boolean;

		protected var _showSelector:Boolean = true;
		protected var _showSelectorChanged:Boolean;

		protected var _autoPlay:Boolean;
		protected var _autoPlayChanged:Boolean;

		protected var _channelChanged:Boolean;
		protected var _videoChanged:Boolean;

		private var currentVideoStartTime:Date;
		private var isRollOutTextOpen:Boolean;

		public function VideoSelector() {
			super();
		}

		[Bindable]
		public function get channelCollection():IList {
			return _channelCollection;
		}

		public function set channelCollection(value:IList):void {
			if (_channelCollection !== value) {
				_channelCollection = value;
				_channelCollectionChanged = true;
				invalidateProperties();
			}
		}

		[Bindable]
		public function get videoCollection():IList {
			return _videoCollection;
		}

		public function set videoCollection(value:IList):void {
			if (_videoCollection !== value) {
				_videoCollection = value;
				_videoCollectionChanged = true;
				invalidateProperties();
			}
		}


		[Bindable]
		public function get placeholderSource():Object {
			return _placeholderSource;
		}

		public function set placeholderSource(value:Object):void {
			if (_placeholderSource !== value) {
				_placeholderSource = value;
				_placeholderSourceChanged = true;
				invalidateProperties();
			}
		}

		public function get showSelector():Boolean {
			return _showSelector;
		}

		public function set showSelector(value:Boolean):void {
			if (_showSelector !== value) {
				_showSelector = value;
				_showSelectorChanged = true;
				invalidateProperties();
			}
		}

		public function get autoPlay():Boolean {
			return _autoPlay;
		}

		public function set autoPlay(value:Boolean):void {
			if (_autoPlay !== value) {
				_autoPlay = value;
				_autoPlayChanged = true;
				invalidateProperties();
			}
		}

		protected override function commitProperties():void {
			super.commitProperties();

			if (_channelCollectionChanged) {
				_channelCollectionChanged = false;
				if (channelList) {
					channelList.dataProvider = _channelCollection;
					if (channelList.dataProvider.length>1)
						channelList.visible = true;
				}
			}

			if (_videoCollectionChanged) {
				_videoCollectionChanged = false;
				if (videoList) videoList.dataProvider = _videoCollection;
			}

			if (_placeholderSourceChanged) {
				_placeholderSourceChanged = false;
				// TODO: something?
			}

			if (_showSelectorChanged) {
				_showSelectorChanged = false;
				if (videoList) videoList.visible = videoList.includeInLayout = _showSelector;
			}

			if (_autoPlayChanged) {
				_autoPlayChanged = false;
				videoList.requireSelection = _autoPlay;
				if (_autoPlay) callLater(loadSelectedVideo);
			}

			if (_videoChanged || _channelChanged) {
				_videoChanged = _channelChanged = false;
				loadSelectedVideo();
			}
		}

		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);

			switch (instance) {
				case videoPlayer:
					videoPlayer.addEventListener(VideoEvent.VIDEO_PLAYED, onVideoStarted);
					videoPlayer.addEventListener(VideoEvent.VIDEO_READY, onVideoScore);
					videoPlayer.addEventListener(VideoEvent.VIDEO_PAUSED, onVideoScore);
					videoPlayer.addEventListener(TimeEvent.COMPLETE, onVideoScore);
					// gh#1344
					videoPlayer.addEventListener(Event.REMOVED_FROM_STAGE, onVideoScore);
					videoPlayer.addEventListener(TimeEvent.COMPLETE, onVideoPlayerComplete);
					break;
				case channelList:
					channelList.requireSelection = true;
					channelList.addEventListener(IndexChangeEvent.CHANGE, onChannelSelected);

					// For the moment just hide the channel selector.  Its all working if we want to turn it back on in the future though.
					channelList.visible = false;

					//gt#57
					channelList.labelField = "caption";
					break;
				case videoList:
					videoList.addEventListener(IndexChangeEvent.CHANGE, onVideoSelected);
					videoList.visible = videoList.includeInLayout = _showSelector;
					break;
				case scriptButton:
					scriptButton.addEventListener(MouseEvent.CLICK, onScriptButtonClicked);
					scriptButton.visible = false;
					break;
			}
		}

		protected function onChannelSelected(event:IndexChangeEvent):void {
			_channelChanged = true;
			invalidateProperties();
		}

		protected function onVideoSelected(event:Event):void {
			_videoChanged = true;

			// Show the script button if there is a @scriptHref attribute
			scriptButton.visible = (videoList.selectedItem && (videoList.selectedItem.attribute("scriptHref").length() > 0 || videoList.selectedItem.script.length() > 0));
			if (videoList.selectedItem && videoList.selectedItem.child("script").length() > 0) {
				stage.addEventListener(MouseEvent.CLICK, onStageClick);
			}

			invalidateProperties();
		}

		/**
		 * Load the video using the appropriate loader.  For now there is only RssVideoLoader.
		 */
		private function loadSelectedVideo():void {
			if (!videoList.selectedItem || !channelList.selectedItem)
				return;
			videoPlayer.stop();
			var url:String = href.createRelativeHref(null, videoList.selectedItem.@href).url;
			if (url.match(/\.(rss|xml)$/)) {
				new RssVideoLoader(videoPlayer).load(url, channelList.selectedItem);
			} else {
				throw new Error("VideoSelector only supports rss files");
			}
		}

		/**
		 * Record the start time of the video (GH #50)
		 *
		 * @param event
		 */
		protected function onVideoStarted(event:VideoEvent):void {
			currentVideoStartTime = new Date()
		}

		/**
		 * Dispatch an ExerciseMark event with the uid and duration of the video (GH #50)
		 *
		 * @param event
		 */
		protected function onVideoScore(event:Event = null):void {
			var exerciseMark:ExerciseMark = getVideoScore();

			if (exerciseMark) {
				dispatchEvent(new VideoScoreEvent(VideoScoreEvent.VIDEO_SCORE, exerciseMark));
				currentVideoStartTime = null;
			}
		}

		public function getVideoScore():ExerciseMark {
			if (videoList.selectedItem && currentVideoStartTime && hrefToUidFunction != null) { // #138 // for some video (candidates video), no hrefToUidFunction can apply
				var videoHref:Href = href.createRelativeHref(null, videoList.selectedItem.@href);

				var exerciseMark:ExerciseMark = new ExerciseMark();
				exerciseMark.duration = ((new Date()).time - currentVideoStartTime.getTime()) / 1000;
				exerciseMark.UID = hrefToUidFunction(videoHref);

				return exerciseMark;
			}

			return null;
		}

		/**
		 * The video has completed.  This event only gets thrown by the OSMFVideoPlayer.
		 *
		 * @param event
		 */
		protected function onVideoPlayerComplete(event:TimeEvent):void {
			// When a video reaches the end deselect the video in the list so we don't end up with a floating 'loading...' (this is only relevant for OSMFVideoPlayer
			videoList.selectedItem = null;

			// Add fade in effect to displaying place holder image after video finish playing.
			if (placeholderImage) {
				placeholderImage.alpha = 0;
				var simpleMotionPath:SimpleMotionPath = new SimpleMotionPath();
				simpleMotionPath.valueFrom = 0;
				simpleMotionPath.valueTo = 1;
				simpleMotionPath.property = "alpha";

				var vector:Vector.<MotionPath> = new Vector.<MotionPath>;
				vector.push(simpleMotionPath);

				var animate:Animate = new Animate();
				animate.motionPaths = vector;
				animate.targets = [placeholderImage];

				animate.play();
			}
		}

		protected function onScriptButtonClicked(event:MouseEvent):void {
			if (videoList.selectedItem && videoList.selectedItem.attribute("scriptHref").length() > 0) {
				dispatchEvent(new ExerciseEvent(ExerciseEvent.EXERCISE_SELECTED, videoList.selectedItem.@scriptHref, videoList.selectedItem, "scriptHref"));
			} else if (videoList.selectedItem.script.length() > 0) { //gh#1164
				if (!isRollOutTextOpen) {
					rollOutTextGroup.width = 500;
					rollOutTextGroup.visible = true;
					var rollOutTextString:String = videoList.selectedItem.script;
					var textFlow:TextFlow = TextFlowUtil.importFromString(rollOutTextString);
					rollOutRichEditableText.textFlow = textFlow;
					isRollOutTextOpen = true;
				} else {
					rollOutTextGroup.width = 0;
					rollOutTextGroup.visible = false;
					isRollOutTextOpen = false;
				}
			}
		}

		// gh#1164
		protected function onStageClick(event:MouseEvent):void {
			var component:Object = event.target;

			while(component) {
				if (component is VideoSelector) { // detect if user click on window shade
					break;
				}
				component = component.parent;
			}

			if (!(component is VideoSelector)) {
				rollOutTextGroup.width = 0;
				rollOutTextGroup.visible = false;
				isRollOutTextOpen = false;
			}
		}

	}
}
