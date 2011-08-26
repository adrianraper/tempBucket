package com.clarityenglish.resultsmanager.view.management.ui.treeClasses {
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.common.vo.manageable.Manageable;
	import com.clarityenglish.common.vo.manageable.User;
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.controls.treeClasses.DefaultDataDescriptor;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class AssignTreeDataDescriptor extends DefaultDataDescriptor {
		
		public function AssignTreeDataDescriptor() {
			super();
		}
		
		/**
		 * Only show groups
		 * 
		 * @param	node
		 * @param	model
		 * @return
		 */
		override public function getChildren(node:Object, model:Object = null):ICollectionView {
			var arrayCollection:ArrayCollection = new ArrayCollection();
			
			for each (var child:Manageable in node.children)
				if (child is Group)
					arrayCollection.addItem(child);
					
			return arrayCollection;
		}
		
		override public function isBranch(node:Object, model:Object = null):Boolean {
			//return getChildren(node).length > 0;
			return hasChildren(node);
		}
		
	}
	
}