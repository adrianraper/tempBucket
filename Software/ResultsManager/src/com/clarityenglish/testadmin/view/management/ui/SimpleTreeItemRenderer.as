package com.clarityenglish.testadmin.view.management.ui {
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.common.vo.manageable.User;
	import mx.controls.treeClasses.TreeItemRenderer;
	
	import org.davekeen.utils.ClassUtils;

	public class SimpleTreeItemRenderer extends TreeItemRenderer {
		public function SimpleTreeItemRenderer() {
			super();
		}
		
		override public function set data(value:Object):void {
			super.data = value;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			label.y += 4;
			label.x += 20;
			disclosureIcon.x+= 20;
		}
		override protected function measure():void {
			super.measure();
			measuredHeight = 28;
		}
	}
}