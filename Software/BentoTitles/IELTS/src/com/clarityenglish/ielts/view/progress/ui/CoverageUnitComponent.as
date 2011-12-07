package com.clarityenglish.ielts.view.progress.ui {
	
	import mx.collections.XMLListCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class CoverageUnitComponent extends SkinnableComponent {

		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		[Bindable]
		public var caption:String;
		
		[Bindable]
		public var listDataProvider:XMLListCollection;
		
		public function CoverageUnitComponent() {
			super();
		}
		
		/**
		 * This function will take a course node and create a list of exercises in the practice-zone
		 * grouped by group ID, with a caption for each and a set of nodes for each exercise in the group
		 * 
		 */
		public function set dataProvider(value:XML):void {

			if (value) {
				var listDP:XMLList= new XMLList();
				var newNode:XML = new XML();
				var newItem:XML = new XML();
				var builder:XML = new XML();
				builder = <list />;
				for each (var group:XML in value.groups.group) {
					newNode = <group caption={group.@caption} />;
					for each (var exercise:XML in value.unit.(@["class"]=='practice-zone').exercise.(@["group"]==group.@id)) {
						newItem = <exercise caption={exercise.@caption} done={exercise.@done} />;
						newNode.appendChild(newItem);
					}
					builder.appendChild(newNode);
				}
				listDataProvider = new XMLListCollection(builder.group);
			}
			
		}

	}
}