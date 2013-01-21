package com.clarityenglish.bento.view.progress.ui {
	
	import almerblank.flex.spark.components.SkinnableDataRenderer;
	
	import mx.collections.XMLListCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.XmlUtils;
	
	import spark.components.DataGroup;
	import spark.components.Label;
	
	public class CoverageUnitComponent extends SkinnableDataRenderer {

		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		[SkinPart(required="true")]
		public var coverageHeadingLabel:Label;
		
		[SkinPart(required="true")]
		public var groupDataGroup:DataGroup;
		
		/*[Bindable]
		public var productVersion:String;
		
		[Bindable]
		public var componentCopyProvider:CopyProvider;*/
		
		public override function set data(value:Object):void {
			super.data = value;
			
			if (data) {
				coverageHeadingLabel.text = value.@caption;
				
				// Group exercises together by their <group>
				var xml:XML = <coverage />;
				for each (var group:XML in value.parent().groups.group) {
					var groupNode:XML = XmlUtils.copyTopLevelNode(group);
					for each (var exercise:XML in value.exercise.(@["group"] == group.@id)) {
						var exerciseNode:XML = XmlUtils.copyTopLevelNode(exercise);
						groupNode.appendChild(exerciseNode);
					}
					xml.appendChild(groupNode);
				}
				
				groupDataGroup.dataProvider = new XMLListCollection(xml.group);
			} else {
				coverageHeadingLabel.text = "";
				groupDataGroup.dataProvider = null;
			}
		}

	}
}