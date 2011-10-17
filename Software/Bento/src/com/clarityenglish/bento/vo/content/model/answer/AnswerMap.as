package com.clarityenglish.bento.vo.content.model.answer {
	import mx.utils.UIDUtil;
	
	import org.davekeen.collections.VectorMap;
	
	/**
	 * The AnswerMap maps keys (which will generally be an XML node in Bento) to an Answer.  This means that the 'answer' for a question can be an AnswerMap,
	 * which allows a question to have more than one answer, indexed by node.
	 * 
	 * Since some questions only have a single answer which doesn't readily map to an index node, AnswerMap can also operate in ONE mode using the putOne and
	 * getOne methods.
	 * 
	 * @author Dave
	 */
	public class AnswerMap {
		
		/**
		 * A unique key to use as the index for ONE mode 
		 */
		private var ONE_KEY:String = "one-" + UIDUtil.createUID();
		
		private var map:VectorMap;
		
		public function AnswerMap() {
			map = new VectorMap();
		}
		
		public function put(key:Object, answer:Answer):void {
			if (map.containsKey(ONE_KEY))
				throw new Error("Cannot use an AnswerMap in MAP mode once it already has a ONE entry"); 
			
			map.put(key, answer);
		}
		
		public function get(key:Object):Answer {
			return map.get(key) as Answer;
		}
		
		public function putOne(answer:Answer):void {
			if (map.keys.length > 0 && !map.containsKey(ONE_KEY))
				throw new Error("Cannot use an AnswerMap in ONE mode once it already has contents");
			
			map.put(ONE_KEY, answer);
		}
		
		public function getOne():Answer {
			return map.get(ONE_KEY) as Answer;
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
		
	}
	
}
