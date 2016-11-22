package com.clarityenglish.resultsmanager.view.shared.ui {
	import flash.text.TextFormat;
	
	import mx.controls.listClasses.ListItemRenderer;
	
	public class ScheduledTestsItemRenderer extends ListItemRenderer {
		
		override protected function measure():void {
			super.measure();
			
			measuredHeight = 36;
		}
		override protected function commitProperties():void {
			super.commitProperties();
			
			this.label.backgroundColor = 0x00FF00;
		}
	}	
}
