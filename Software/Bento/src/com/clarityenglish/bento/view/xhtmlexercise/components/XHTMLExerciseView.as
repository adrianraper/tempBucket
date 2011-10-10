package com.clarityenglish.bento.view.xhtmlexercise.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.textLayout.components.XHTMLRichText;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import spark.components.Group;
	import spark.components.supportClasses.SkinnableComponent;
	
	[Event(name="questionAnswered", type="com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent")]
	public class XHTMLExerciseView extends BentoView {
		
		/**
		 * All the supported sections should be listed here.  They must also be defined below as required or optional skin parts.  The naming
		 * convention must be as follows:
		 * 
		 * For each section the containing group (i.e. the thing that should be hidden if there is no content) should be named {section}Group
		 * and the ExerciseRichText that displays the content should be named {section}RichText.
		 */
		private static const SUPPORTED_SECTIONS:Array = [ "header", "noscroll", "body", "readingText" ];
		
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
		
		[SkinPart(type="spark.components.Group", required="false")]
		public var readingTextGroup:Group;
		
		[SkinPart(type="com.clarityenglish.textLayout.components.XHTMLRichText", required="false")]
		public var readingTextRichText:XHTMLRichText;
		
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
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// If some XHTML makes it this far, its actually an Exercise (at least, it should be)
			var exercise:Exercise = xhtml as Exercise;
			
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
		}
		
	}

}