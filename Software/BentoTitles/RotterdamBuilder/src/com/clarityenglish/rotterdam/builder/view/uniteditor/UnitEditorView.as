package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoView;
	
	import mx.collections.XMLListCollection;
	
	import spark.components.List;
	
	public class UnitEditorView extends BentoView {
		
		[SkinPart(required="true")]
		public var unitList:List;
		
		[Bindable]
		public var unitCollection:XMLListCollection;
		
		public override function set data(value:Object):void {
			super.data = value;
			
			if (data) {
				unitCollection = new XMLListCollection(data.*);
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case unitList:
					break;
			}
		}
		
	}
}