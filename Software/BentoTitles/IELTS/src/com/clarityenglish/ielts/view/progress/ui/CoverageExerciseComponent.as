package com.clarityenglish.ielts.view.progress.ui {
	
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
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
		
		[Bindable]
		public var componentCopyProvider:CopyProvider;
		
	}
}