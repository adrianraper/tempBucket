package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.ielts.IELTSApplication;
	
	import flash.events.Event;
	
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	public class PracticeZoneSectionView extends AbstractZoneSectionView {
		
		[SkinPart(required="true")]
		public var unitList:List;
		
		public var exercisesShow:Signal = new Signal(XMLList, Object);
		
		public function PracticeZoneSectionView() {
			super();
			actionBarVisible = false;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_course) {
				// Give groups as the dataprovider to the unit list
				unitList.dataProvider = new XMLListCollection(_course.groups.group);
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case unitList:
					unitList.addEventListener(IndexChangeEvent.CHANGE, onUnitListChange);
					break;
			}
		}
		
		protected function onUnitListChange(event:Event):void {
			// popoutExerciseSelector.exercises = refreshedExercises();
			exercisesShow.dispatch(selectedExercises, (unitList.selectedItem) ? unitList.selectedItem.@caption.toString() : null);
		}
		
		/**
		 * To allow the data in the exercise list to be refreshed based on score written 
		 * @return 
		 * 
		 */
		public function get selectedExercises():XMLList {
			if (!unitList.selectedItem)
				return null;
			
			var groupXML:XML = unitList.selectedItem;
			
			var exercises:XMLList = new XMLList();
			for each (var exerciseNode:XML in _course..exercise.(attribute("group") == groupXML.@id))
				if (Exercise.showExerciseInMenu(exerciseNode))
					exercises += exerciseNode;
			
			return exercises;
		}
		
		/**
		 * Return the first exercise in a given group.  This is used in the iPad version of IELTS which displays the difficulty in the group selector.
		 * 
		 * @param groupXML
		 * @return 
		 */
		public function getFirstExerciseInGroup(groupXML:XML):XML {
			var exercises:XMLList =_course..exercise.(attribute("group") == groupXML.@id);
			return (exercises.length()) > 0 ? exercises[0] : null;
		}
		
	}
}
