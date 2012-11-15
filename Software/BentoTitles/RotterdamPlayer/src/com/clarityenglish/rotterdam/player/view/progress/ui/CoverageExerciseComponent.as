package com.clarityenglish.rotterdam.player.view.progress.ui {
	
	import mx.collections.XMLListCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class CoverageExerciseComponent extends SkinnableComponent {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		[Bindable]
		public var caption:String;
		
		[Bindable]
		public var dataProvider:XMLListCollection;
		
		[Bindable]
		public var productVersion:String;
		
	}
}