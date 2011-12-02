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
				listDataProvider = new XMLListCollection(value.groups.group);
			}
			
		}

	}
}