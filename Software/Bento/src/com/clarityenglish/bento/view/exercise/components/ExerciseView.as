package com.clarityenglish.bento.view.exercise.components {
	import com.clarityenglish.bento.view.exercise.events.SectionEvent;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.components.XHTMLRichText;
	
	import spark.components.Group;
	import spark.components.supportClasses.SkinnableComponent;
	
	public class ExerciseView extends SkinnableComponent {
		
		/**
		 * All the supported sections should be listed here.  They must also be defined below as required or optional skin parts.  The naming
		 * convention must be as follows:
		 * 
		 * For each section the containing group (i.e. the thing that should be hidden if there is no content) should be named {section}Group
		 * and the ExerciseRichText that displays the content should be named {section}RichText.
		 */
		private static const SUPPORTED_SECTIONS:Array = [ "header", "noscroll", "body" ];
		
		/**
		 * These sections are required in all skins
		 */		
		[SkinPart(type="spark.components.Group", required="true")]
		public var headerGroup:Group;
		
		[SkinPart(type="com.clarityenglish.textLayout.components.XHTMLRichText", required="true")]
		public var headerRichText:XHTMLRichText;
		
		[SkinPart(type="spark.components.Group", required="true")]
		public var bodyGroup:Group;
		
		[SkinPart(type="com.clarityenglish.textLayout.components.XHTMLRichText", required="true")]
		public var bodyRichText:XHTMLRichText;
		
		/**
		 * These sections are optional and don't have to be in every skin 
		 */
		[SkinPart(type="spark.components.Group", required="false")]
		public var noscrollGroup:Group;
		
		[SkinPart(type="com.clarityenglish.textLayout.components.XHTMLRichText", required="false")]
		public var noscrollRichText:XHTMLRichText;
		
		private var _exercise:Exercise;
		private var _exerciseChanged:Boolean;
		
		public function get exercise():Exercise {
			return _exercise;
		}

		public function set exercise(value:Exercise):void {
			if (_exercise !== value) {
				_exercise = value;
				_exerciseChanged = true;
				
				invalidateProperties();
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_exerciseChanged) {
				// Go through the sections supported by this exercise setting the visibility and contents of each section in the skin
				for each (var sectionName:String in SUPPORTED_SECTIONS) {
					var group:Group = this[sectionName + "Group"];
					var xhtmlRichText:XHTMLRichText = this[sectionName + "RichText"];
					
					if (group && xhtmlRichText) {
						group.visible = group.includeInLayout = (sectionName == "header") ? exercise.hasHeader() : exercise.hasSection(sectionName);
						xhtmlRichText.xhtml = exercise;
						xhtmlRichText.nodeId = (sectionName == "header") ? "header" : "#" + sectionName;
					}
				}
				
				_exerciseChanged = false;
			}
		}
		
		private function onQuestionAnswered(e:SectionEvent):void {
			// TODO: Nothing calls this at present
			trace("Question: " + e.question + " answered with " + e.answer + " -- score delta=" + + e.answer.score);
		}
		
	}

}