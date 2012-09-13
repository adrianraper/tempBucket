package com.clarityenglish.rotterdam.builder.view.filemanager {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.collections.XMLListCollection;
	
	import spark.components.List;
	
	public class FileManagerView extends BentoView {
		
		[SkinPart(required="true")]
		public var fileList:List;
		
		protected override function commitProperties():void {
			super.commitProperties();
		}

		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			fileList.dataProvider = new XMLListCollection(xhtml.files.file);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				
			}
		}

	}
}