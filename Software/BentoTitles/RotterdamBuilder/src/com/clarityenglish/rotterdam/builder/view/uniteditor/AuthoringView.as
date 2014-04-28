package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.content.ExerciseGenerator;
	import com.clarityenglish.textLayout.vo.XHTML;
	import com.googlecode.bindagetools.Bind;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.events.CloseEvent;
	
	import spark.components.Button;
	import spark.components.List;
	
	public class AuthoringView extends BentoView {
		
		[SkinPart]
		public var questionList:List;
		
		[SkinPart(required="true")]
		public var okButton:Button;
		
		[SkinPart(required="true")]
		public var cancelButton:Button;
		
		[Bindable]
		public var questions:ListCollectionView;
		
		public var widgetNode:XML;
		
		protected function get exerciseGenerator():ExerciseGenerator {
			return _xhtml as ExerciseGenerator;
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			questions = new XMLListCollection(exerciseGenerator.questions.*);
			
			// Update the skin state from the loaded xhtml
			callLater(invalidateSkinState);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case questionList:
					break;
				case okButton:
					okButton.addEventListener(MouseEvent.CLICK, onSelectButton);
					okButton.label = copyProvider.getCopyForId("okButton");
					break;
				case cancelButton:
					cancelButton.addEventListener(MouseEvent.CLICK, onCancelButton);
					cancelButton.label = copyProvider.getCopyForId("cancelButton");
					break;
			}
		}
		
		protected function onSelectButton(event:MouseEvent):void {
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		protected function onCancelButton(event:MouseEvent):void {
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		/**
		 * The skin state is made up of <exerciseType>_<layoutType>.  So for example, MultipleChoiceQuestion_questions, or GapFillQuestion_text.
		 */
		protected override function getCurrentSkinState():String {
			if (exerciseGenerator && exerciseGenerator.hasSettingParam("exerciseType") && exerciseGenerator.hasSettingParam("questionNumberingEnabled")) {
				return exerciseGenerator.getSettingParam("exerciseType") + "_" + (exerciseGenerator.hasSettingParam("questionNumberingEnabled") ? "questions" : "text");
			} else {
				return super.getCurrentSkinState();
			}
		}
		
	}
}