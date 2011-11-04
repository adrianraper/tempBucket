package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.view.zone.ui.ButtonItemRenderer;
	import com.clarityenglish.ielts.view.zone.ui.ImageItemRenderer;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	import mx.core.ClassFactory;
	import mx.core.IDataRenderer;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.DataGroup;
	import spark.components.Label;
	import spark.components.TabBar;
	import spark.components.VideoPlayer;
	
	public class ZoneView extends BentoView {
		
		[SkinPart(required="true")]
		public var courseTitleLabel:Label;
		
		[SkinPart(required="true")]
		public var courseDescriptionLabel:Label;
		
		[SkinPart(required="true")]
		public var questionZoneButton:Button;
		
		[SkinPart(required="true")]
		public var examPractice1Button:Button;
		
		[SkinPart(required="true")]
		public var examPractice1Difficulty:IDataRenderer;
		
		[SkinPart(required="true")]
		public var examPractice2Button:Button;
		
		[SkinPart(required="true")]
		public var examPractice2Difficulty:IDataRenderer;
		
		[SkinPart(required="true")]
		public var practiceZoneDataGroup:DataGroup;
		
		[SkinPart(required="true")]
		public var adviceZoneVideoPlayer:VideoPlayer;
		
		private var _course:XML;
		private var _courseChanged:Boolean;
		
		public var exerciseSelect:Signal = new Signal(Href);
		
		/**
		 * This can be called from outside the view to make the view display a different course
		 * 
		 * @param XML A course node from the menu
		 * 
		 */
		public function set course(value:XML):void {
			_course = value;
			_courseChanged = true;
			invalidateProperties();
		}
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// All data is actually being used from course rather than this main document
		}

		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_courseChanged) {
				courseTitleLabel.text = _course.@caption;
				courseDescriptionLabel.text = _course.@description;
				
				// class is a reserved keyword so have to use @["class"] instead of @class
				examPractice1Button.label = _course.unit.(@["class"] == "exam-practice").exercise[0].@caption;
				examPractice1Difficulty.data = _course.unit.(@["class"] == "exam-practice").exercise[0].@difficulty;
				examPractice2Button.label = _course.unit.(@["class"] == "exam-practice").exercise[1].@caption;
				examPractice2Difficulty.data = _course.unit.(@["class"] == "exam-practice").exercise[1].@difficulty;
				
				// Option to either have a button that chooses a category then provides a subset of the XML to the dataprovider
				// or send the whole lot and use tags to display topics.
				practiceZoneDataGroup.dataProvider = new XMLListCollection(_course.unit.(@["class"] == "practice-zone").exercise);
				// AR. At this point, could I change the dataGroup itemRenderer based on how many exercises there are?
				/*
				if (practiceZoneDataGroup.dataProvider.length<=5) {
					// Change the itemRenderer to one that works well with a small number of items
					practiceZoneDataGroup.itemRenderer = new ClassFactory(ImageItemRenderer);
					(practiceZoneDataGroup.itemRenderer as ClassFactory).properties = { exerciseClick: exerciseClick };					
				} else {
					// Otherwise go back to the item renderer for many items
					practiceZoneDataGroup.itemRenderer = new ClassFactory(ButtonItemRenderer);
					(practiceZoneDataGroup.itemRenderer as ClassFactory).properties = { exerciseClick: exerciseClick };					
				}
				*/
				var adviceZoneVideoUrl:String = _course.unit.(@["class"] == "advice-zone").exercise[0].@href;
				adviceZoneVideoPlayer.source = href.createRelativeHref(null, adviceZoneVideoUrl).url;
								
				_courseChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			//trace("partAdded in ZoneView for " + partName);
			switch (instance) {
				case practiceZoneDataGroup:
					// Create a signal and listener for the button item renderer
					var exerciseClick:Signal = new Signal(XML);
					exerciseClick.add(function(xml:XML):void {
						// Fire the exerciseSelect signal
						exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, xml.@href));
					} );
					
					// Create the item renderer and inject the signal into it
					//practiceZoneDataGroup.itemRenderer = new ClassFactory(ButtonItemRenderer);
					practiceZoneDataGroup.itemRenderer = new ClassFactory(ImageItemRenderer);
					(practiceZoneDataGroup.itemRenderer as ClassFactory).properties = { exerciseClick: exerciseClick, href:href };					
					break;
				case questionZoneButton:
				case examPractice1Button:
				case examPractice2Button:
					instance.addEventListener(MouseEvent.CLICK, onExerciseClick);
					break;
			}
		}
		
		/**
		 * The user has selected an exercise
		 * 
		 * @param event
		 */
		protected function onExerciseClick(event:MouseEvent):void {
			// Get the appropriate href based on which button was pressed
			var hrefFilename:String;
			switch (event.target) {
				case questionZoneButton:
					hrefFilename = _course.unit.(@["class"] == "question-zone").exercise[0].@href;
					break;
				case examPractice1Button:
					hrefFilename = _course.unit.(@["class"] == "exam-practice").exercise[0].@href;
					break;
				case examPractice2Button:
					hrefFilename = _course.unit.(@["class"] == "exam-practice").exercise[1].@href;
					break;
			}
			
			// Fire the exerciseSelect signal
			exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, hrefFilename));
		}
		
	}
	
}