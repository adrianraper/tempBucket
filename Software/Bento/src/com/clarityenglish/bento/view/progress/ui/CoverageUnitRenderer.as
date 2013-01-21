package com.clarityenglish.bento.view.progress.ui {
	
	import almerblank.flex.spark.components.SkinnableDataRenderer;
	
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import mx.collections.XMLListCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.DataGroup;
	import spark.components.Label;
	
	public class CoverageUnitRenderer extends SkinnableDataRenderer {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
				
		[SkinPart(required="true")]
		public var coverageHeadingLabel:Label;
		
		[SkinPart(required="true")]
		public var exerciseDataGroup:DataGroup;
		
		/*[Bindable]
		public var productVersion:String;
		
		[Bindable]
		public var componentCopyProvider:CopyProvider;*/
		
		public override function set data(value:Object):void {
			super.data = value;
			
			if (data) {
				coverageHeadingLabel.text = value.@caption;
				exerciseDataGroup.dataProvider = new XMLListCollection(value.exercise);
			} else {
				coverageHeadingLabel.text = "";
				exerciseDataGroup.dataProvider = null;
			}
		}
		
	}
}