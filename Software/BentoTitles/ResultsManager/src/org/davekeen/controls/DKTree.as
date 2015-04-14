package org.davekeen.controls {
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.common.vo.manageable.Manageable;
	import flash.events.Event;
	import mx.collections.ArrayCollection;
	import mx.controls.Tree;
	import org.davekeen.events.DKTreeEvent;
	
	/**
	 * An extension to the Tree class that fixes annoying issues as I come across them:
	 * 
	 * o When the data provider changes this ensure that the tree doesn't completely shut, but keeps the openItems in the same state.
	 *   Note that for this to work UIDs must be implemented if the tree contains custom objects.
	 * o Adds an option to keep the scroll position the same when the dataprovider changes
	 * o Adds methods to expand various parts of the tree recursively
	 * 
	 * Note that at present this only supports ArrayCollection based data providers
	 * 
	 * @author Dave Keen
	 */
	public class DKTree extends Tree {
		
		[Bindable]
		public var retainVerticalScrollPosition:Boolean;
		
		private var tempOpenItems:Object;
		private var refreshData:Boolean;
		private var lastVerticalScrollPosition:Number;
		private var isResetting:Boolean;
		
		public function DKTree() {
			addEventListener(Event.RENDER, onRender, false, 0, true);
		}
		
		override public function set dataProvider(value:Object):void {
			if (!isResetting) tempOpenItems = openItems;
			lastVerticalScrollPosition = verticalScrollPosition;
			refreshData = true;
			super.dataProvider = value;
			
			dispatchEvent(new DKTreeEvent(DKTreeEvent.DATA_PROVIDER_SET));
		}
		
		/**
		 * Expand a tree from the given object downwards
		 * 
		 * @param	obj
		 */
		public function expandAllFrom(obj:Object, validate:Boolean = true):void {
			expand(obj);
			if (validate) validateNow();
		}
		
		public function expandAll(expandLastBranch:Boolean = true):void {
			// Use a recursive function to pre-fill openItems instead of using the expandItem method otherwise we can hit a massive performance
			// bottleneck for large trees.
			var newOpenItems:Array = [];
			
			var dataProvider:ArrayCollection = dataProvider as ArrayCollection;
			for each (var node:Object in dataProvider.toArray())
				expandNode(node, newOpenItems);
			
			// Internal recursive function with accumulator
			function expandNode(node:Object, accumulatorArray:Array):void {
				accumulatorArray.push(node);
				
				for each (var child:Object in node.children) {
					if (expandLastBranch) {
						expandNode(child, accumulatorArray);
					} else {
						var hasBranches:Boolean = false;
						for each (var subChild:Object in child.children) {
							if (subChild.children && subChild.children.length > 0) {
								hasBranches = true;
								break;
							}
						}
						
						if (hasBranches) expandNode(child, accumulatorArray);
					}
				}
			}
			
			openItems = newOpenItems;
				
			// This was breaking the open items when doing clear search, but keep an eye on this to make sure that removing it doesn't break something else
			//tempOpenItems = openItems;
			
			validateNow();
		}
		
		public function collapseAll(collapseRoot:Boolean = true):void {
			openItems = (collapseRoot) ? [] : dataProvider;
			
			validateNow();
		}
		
		public function resetTree():void {
			selectedItem = null;
			tempOpenItems = null;
			isResetting = true;
		}
		
		private function expand(obj:Object):void {
			expandItem(obj, true);
			
			for each (var child:Object in obj.children)
				expand(child);
		}
		
		private function onRender(e:Event):void {
			if (refreshData) {
				// Refresh all rows on next update.
				invalidateList();
				
				// A minor hack to fix ticket #63
				if (isResetting) {
					//tempOpenItems = openItems;
					tempOpenItems = [];
					isResetting = false;
				}
				
				refreshData = false;
				if (tempOpenItems.length > 0) openItems = tempOpenItems;
				
				// Validate and update the properties and layout of this object and redraw it, if necessary.
				validateNow();
				
				// Set the vertical scroll position to what it was before the dataprovider was updated
				if (retainVerticalScrollPosition)
					verticalScrollPosition = (lastVerticalScrollPosition <= maxVerticalScrollPosition) ? lastVerticalScrollPosition : maxVerticalScrollPosition;
					
			}
		}
		
		/**
		 * Refreshes all item renderers.  This should be used after changing or updating the dataDescriptor as it ensures that the
		 * scrollbars keep working.
		 */
		public function refreshItemRenderers():void {
			super.invalidateList();
			
			//var tempOpenItems:Object = openItems;
			//openItems = tempOpenItems;
			
			if (retainVerticalScrollPosition) {
				lastVerticalScrollPosition = verticalScrollPosition;
				refreshData = true;
			}
		}
		
	}
	
}