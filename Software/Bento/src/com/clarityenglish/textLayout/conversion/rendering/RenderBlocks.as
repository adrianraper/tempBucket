package com.clarityenglish.textLayout.conversion.rendering {
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	public class RenderBlocks extends Proxy {
		
		private var renderBlocks:Vector.<RenderBlock>;
		
		public function RenderBlocks() {
			renderBlocks = new Vector.<RenderBlock>();
		}
		
		public function addBlock(node:XML):void {
			var renderBlock:RenderBlock = new RenderBlock();
			renderBlock.html = node;
			
			renderBlocks.push(renderBlock);
		}
		
		public function getIgnoreNodes():Array {
			var ignoreNodes:Array = [];
			for each (var renderBlock:RenderBlock in renderBlocks)
				ignoreNodes.push(renderBlock.html);
			
			return ignoreNodes;
		}
		
		public function get length():int {
			return renderBlocks.length;
		}
		
		override flash_proxy function nextNameIndex(idx:int):int {
			return (renderBlocks && idx < renderBlocks.length) ? idx + 1 : 0;
		}
		
		override flash_proxy function nextValue(idx:int):* {
			return renderBlocks[idx - 1];
		}
		
	}
	
}