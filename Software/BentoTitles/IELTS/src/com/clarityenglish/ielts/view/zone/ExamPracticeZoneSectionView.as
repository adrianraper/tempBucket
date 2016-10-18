package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.events.ExerciseEvent;
import com.clarityenglish.bento.view.timer.TimerButton;
import com.clarityenglish.bento.view.timer.TimerComponent;
import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
import com.clarityenglish.components.PageNumberDisplay;
import com.clarityenglish.ielts.view.zone.speakingtest.SpeakingTestView;
import com.clarityenglish.textLayout.components.AudioPlayer;
	
	import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.setTimeout;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.XMLListCollection;
	import mx.controls.SWFLoader;
	import mx.events.ScrollEvent;
import mx.events.StateChangeEvent;

import org.osflash.signals.Signal;

import spark.components.Button;

import spark.components.Label;
	import spark.components.List;
	import spark.events.IndexChangeEvent;

	public class ExamPracticeZoneSectionView extends AbstractZoneSectionView {
		
		[SkinPart(required="true")]
		public var list:List;
		
		[SkinPart]
		public var examZoneLabel:Label;
		
		[SkinPart]
		public var examZoneInstructionLabel:Label;
		
		[SkinPart]
		public var examZoneNoTestLabel:Label;

		[SkinPart]
		public var speakingStartButton:Button;

		[SkinPart]
		public var speakingTestView:SpeakingTestView;

		[SkinPart]
		public var pageNumberDisplay:PageNumberDisplay;

		[SkinPart]
		public var rightArrowButton:Button;

		[SkinPart]
		public var leftArrowButton:Button;

		/*[SkinPart]
		public var timerComponent:TimerComponent;*/

		[SkinPart]
		public var readingTimer:TimerComponent;

		[SkinPart]
		public var writingTimer:TimerComponent;

		[Bindable]
		public var speakingTestXMLListCollection:XMLListCollection;

		public var exerciseSelect:Signal = new Signal(XML, String);
		
		private var viewportPropertyWatcher:ChangeWatcher;
		private var _exerciseID:Number;
		private var _isDirectLinkStart:Boolean;
		private var _pageToScroll:Number = 0;
		
		// gh#11
		public function get assetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getDefaultLanguageCode().toLowerCase() + '/';
		}
		public function get languageAssetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getLanguageCode().toLowerCase() + '/';
		}
		// gh#184
		public function getCopyProvider():CopyProvider {
			return copyProvider;
		}
		
		// gh#761
		[Bindable]
		public function get isDirectLinkStart():Boolean {
			return _isDirectLinkStart;
		}
		
		public function set isDirectLinkStart(value:Boolean):void {
			_isDirectLinkStart = value;
		}
		
		[Bindable]
		public function get exerciseID():Number {
			return _exerciseID;
		}
		
		public function set exerciseID(value:Number):void {
			_exerciseID = value;
		}
		
		[Bindable]
		public function get pageToScroll():Number {
			return _pageToScroll;
		}
		
		public function set pageToScroll(value:Number) {
			_pageToScroll = value;
		}

		[Bindable(event="dataChange")]
		public function get examZoneInstructionText():String {
			if (this.courseClass == 'listening') {
				return copyProvider.getCopyForId("examZoneInstructionLabel1");
			} else {
				return copyProvider.getCopyForId("examZoneInstructionLabel2");
			}
		}
		
		public function ExamPracticeZoneSectionView() {
			super();
			actionBarVisible = false;
		}

		public override function set data(value:Object):void {
			super.data = value;

			if (readingTimer) {
				readingTimer.stopTimer();
			}

			if (writingTimer) {
				writingTimer.stopTimer();
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();

			if (_course.@['class'] != 'speaking') {
				list.dataProvider = new XMLListCollection(_course.unit.(attribute("class") == "exam-practice").exercise);
			} else {
				speakingTestXMLListCollection = new XMLListCollection(_course.unit.(attribute("class") == "exam-practice").exercise);
			}

			// get the exercise index in order to scroll to certain page when open the direct link
			if (isDirectLinkStart) {
				if (exerciseID) {
					pageToScroll = _course.unit.(attribute("class") == "exam-practice").exercise.(attribute("id") == exerciseID).childIndex();
				}
			}

			/*if (examZoneInstructionLabel) {
				if (this.courseClass == "listening") {
					examZoneInstructionLabel.text = copyProvider.getCopyForId("examZoneInstructionLabel1");
				} else {
					if (this.courseClass != "speaking") {
						examZoneInstructionLabel.text = copyProvider.getCopyForId("examZoneInstructionLabel2");
					}
				}
			}*/
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case list:
					viewportPropertyWatcher = ChangeWatcher.watch(list.scroller.viewport, "horizontalScrollPosition", onViewportPropertyChange);
					list.addEventListener(ExerciseEvent.EXERCISE_SELECTED, onExerciseSelected);
					break;
				// gh#11
				case examZoneLabel:
					instance.text = copyProvider.getCopyForId("examZoneLabel");
					break;
				case examZoneNoTestLabel:
					if (copyProvider.getLanguageCode() == "JP") {
						instance.setStyle("fontSize", 12);
					} else {
						instance.setStyle("fontSize", 14);
					}
					var replaceObj:Object = new Object();
					replaceObj.courseClass = this.courseClass;
					instance.text = copyProvider.getCopyForId("examZoneNoTestLabel", replaceObj);
					break;
				case examZoneInstructionLabel:
					if (copyProvider.getLanguageCode() == "JP") {
						instance.setStyle("fontSize", 12);
					} else {
						instance.setStyle("fontSize", 14);
					}
					break;
				case leftArrowButton:
				case rightArrowButton:
					if (isDirectLinkStart && exerciseID) {
						instance.enabled = false;
					}
					break;

			}
		}

		protected function onViewportPropertyChange(event:Event):void {
			// TODO: This calls stopAllAudio for every point of the scroll which is a little inefficient.  If we get performance issue this needs to be looked at
			// (but unfortunately there is no easy way to detect a scroll in Flex 4 which is why we are going for a ChangeWatcher).
			AudioPlayer.stopAllAudio(); // gh#12

			// Stop the timer when scroll to another paper.
			if (courseClass == 'reading') {
				if (readingTimer) {
					readingTimer.stopTimer();
				}
			} else if (courseClass == 'writing') {
				if (writingTimer) {
					writingTimer.stopTimer();
				}
			}

			if (list.scroller.horizontalScrollBar) {
				pageNumberDisplay.selectedIndex = Math.floor(list.scroller.horizontalScrollBar.value / list.scroller.viewport.width);

				if (!(isDirectLinkStart && exerciseID)) {
					if (pageNumberDisplay.selectedIndex == list.dataProvider.length - 1) {
						rightArrowButton.enabled = false;
					} else if (pageNumberDisplay.selectedIndex == 0) {
						leftArrowButton.enabled = false;
						rightArrowButton.enabled = true;
					} else {
						leftArrowButton.enabled = true;
						rightArrowButton.enabled = true;
					}
				}
			}
		}
		
		protected function onExerciseSelected(event:ExerciseEvent):void {
			exerciseSelect.dispatch(event.node, event.attribute);
		}
		
		public function stopAllAudio():void {
			AudioPlayer.stopAllAudio();
		}

		protected override function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);

			if (viewportPropertyWatcher) viewportPropertyWatcher.unwatch();
			stopAllAudio();

			if (readingTimer) {
				readingTimer.stopTimer();
			}

			if (writingTimer) {
				writingTimer.stopTimer();
			}
		}
		
	}
}
