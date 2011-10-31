package com.clarityenglish.bento.vo.content.model.answer {
	import org.davekeen.collections.VectorMap;
	
	/**
	 * The AnswerMap maps keys (which will generally be an XML node in Bento) to an Answer.  This means that the 'answer' for a question can be an AnswerMap,
	 * which allows a question to have more than one answer, indexed by node.
	 * 
	 * @author Dave
	 */
	public class AnswerMap {
		
		private var map:VectorMap;
		
		public function AnswerMap() {
			map = new VectorMap();
		}
		
		public function put(key:Object, answer:Answer):void {
			map.put(key, answer);
		}
		
		public function get(key:Object):Answer {
			return map.get(key) as Answer;
		}
		
		public function containsKey(key:Object):Boolean {
			return map.containsKey(key);
		}
		
		public function get keys():Vector.<Object> {
			return map.keys;
		}
		
		public function get values():Vector.<Object> {
			return map.values;
		}
		
		public function isEmpty():Boolean {
			return keys.length == 0;
		}
		
		public function clear():void {
			map.clear();
		}
	}
	
}
