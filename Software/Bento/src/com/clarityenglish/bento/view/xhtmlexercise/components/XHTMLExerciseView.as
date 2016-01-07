package com.clarityenglish.bento.view.xhtmlexercise.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.xhtmlexercise.IExerciseView;
	import com.clarityenglish.bento.view.xhtmlexercise.events.MarkingOverlayEvent;
	import com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	import com.clarityenglish.bento.vo.content.model.answer.AnswerMap;
	import com.clarityenglish.bento.vo.content.model.answer.NodeAnswer;
	import com.clarityenglish.bento.vo.content.model.answer.TextAnswer;
	import com.clarityenglish.textLayout.components.AudioPlayer;
	import com.clarityenglish.textLayout.components.XHTMLRichText;
	import com.clarityenglish.textLayout.elements.AudioElement;
	import com.clarityenglish.textLayout.elements.InputElement;
	import com.clarityenglish.textLayout.elements.SelectElement;
	import com.clarityenglish.textLayout.elements.TextComponentElement;
import com.clarityenglish.textLayout.stylesheets.applicators.CSSApplicator;
import com.clarityenglish.textLayout.util.TLFUtil;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.text.engine.TextLine;
import flash.utils.Timer;

import mx.controls.SWFLoader;
import mx.core.IVisualElement;
import mx.graphics.BitmapFillMode;
	import mx.graphics.BitmapSmoothingQuality;
	import mx.graphics.SolidColor;

import org.osmf.events.TimeEvent;

import spark.components.Group;
	import spark.primitives.BitmapImage;
	
	import caurina.transitions.Tweener;
	
	import flashx.textLayout.elements.FlowElement;
	
	import org.davekeen.util.PointUtil;
	import org.osflash.signals.Signal;
	
	import spark.primitives.BitmapImage;
	[Event(name="questionAnswered", type="com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent")]
	[Event(name="feedbackShow", type="com.clarityenglish.bento.view.xhtmlexercise.events.FeedbackEvent")]
	public class XHTMLExerciseView extends BentoView implements IExerciseView {
		
		/**
		 * All the supported sections should be listed here.  They must also be defined below as required or optional skin parts.  The naming
		 * convention must be as follows:
		 * 
		 * For each section the containing group (i.e. the thing that should be hidden if there is no content) should be named {section}Group
		 * and the ExerciseRichText that displays the content should be named {section}RichText.
		 */
		private static const SUPPORTED_SECTIONS:Array = [ "header", "noscroll", "body", "readingText", "rightNoScroll" ];
		
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
		
		[SkinPart(type="spark.components.Group", required="false")]
		public var rightNoScrollGroup:Group;
		
		[SkinPart(type="com.clarityenglish.textLayout.components.XHTMLRichText", required="false")]
		public var rightNoScrollRichText:XHTMLRichText;
		
		[SkinPart(type="com.clarityenglish.textLayout.components.XHTMLRichText", required="false")]
		public var backColour:SolidColor;
	
		[SkinPart(type="spark.components.Group", required="false")]
		public var backgroundGraphics:Group;

		[SkinPart] // gh#1164
		public var imgLeftBlur:SWFLoader;

		[SkinPart] // gh#1164
		public var imgBottomBlur:SWFLoader;

	
		// TODO: These should be in IELTS, not Bento?
		public var courseClass:String;
		// gh#348
		private var _audioStack:Vector.<AudioElement>;
		
		// TODO: These should be in IELTS, not Bento?
		[Bindable]
		public var courseCaption:String;
		
		[Bindable]
		public var atLeastOneSelectedAnswerHasFeedback:Boolean;

		[Bindable]
		public var isClickFlowElement:Boolean;
		
		// gh#413
		public var gotQuestionFeedback:Signal = new Signal(Boolean);
				
		public function XHTMLExerciseView() {
			super();
			
			opaqueBackground = 0xFFFFFF; // #376
		}
		
		/**
		 * Since this view can only be driven by an Exercise provide a helper to typecast it
		 * 
		 * @return 
		 */
		public function get exercise():Exercise {
			return _xhtml as Exercise;
		}
		
		// gh#388
		// gh#413
		public function getQuestionFeedback():Signal {
			return gotQuestionFeedback;
		}
		
		/**
		 * Search through all the sections for the given node
		 * 
		 * @param node
		 * @return 
		 */
		private function getFlowElement(node:XML):FlowElement {
			for each (var sectionName:String in SUPPORTED_SECTIONS) {
				var xhtmlRichText:XHTMLRichText = this[sectionName + "RichText"];
				
				if (xhtmlRichText && _xhtml.flowElementXmlBiMap) {
					var flowElement:FlowElement = _xhtml.flowElementXmlBiMap.getFlowElement(node);
					if (flowElement)
						return flowElement;
				}
			}
			
			return null;
		}
		
		public function set dataProvider(value:XML):void {
			if (value) {
				// TODO: This should be in IELTS, not Bento?
				var course:XML = value.course.(@["class"] == courseClass)[0];
				backColour.color = getStyle(courseClass + "ColorDark");		
			}
		}

		// gh#1159
		protected override function onViewCreationComplete():void {
			super.onViewCreationComplete();

			var richTextVisibleTimer:Timer = new Timer(1000, 1);
			richTextVisibleTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			richTextVisibleTimer.reset();
			richTextVisibleTimer.start();
		}

		protected function onTimerComplete(event:Event):void {
			readingTextRichText.visible = true;
			bodyRichText.visible = true;
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// Go through the sections supported by this exercise setting the visibility and contents of each section in the skin
			for each (var sectionName:String in SUPPORTED_SECTIONS) {
				var group:Group = this[sectionName + "Group"];
				var xhtmlRichText:XHTMLRichText = this[sectionName + "RichText"];
				
				// gh#665 Pick up any background graphics for the main body
				if (sectionName == "body") {
					for each (var item:XML in exercise.select("img.background")) {
						var newImage:BitmapImage = new BitmapImage;
						newImage.source = xhtml.rootPath + '/' + item.@src.toString();
						newImage.left = parseInt(item.@left);
						newImage.top = parseInt(item.@top);
						// gh#1220
						if (CSSApplicator.fontSizeOffset > 1)
							newImage.scaleX = newImage.scaleY = 1.04;
						// TODO DK worries that hasOwnProperty can cause crashes when packaging for iOS.
						// This codes actually works fine without the checks it just seemed better to test first...
						if (item.attribute("width").length() > 0 || item.attribute("height").length() > 0) {
							newImage.fillMode = mx.graphics.BitmapFillMode.SCALE;
							newImage.scaleMode = mx.graphics.BitmapScaleMode.STRETCH;
							newImage.smooth = true;
							newImage.smoothingQuality = BitmapSmoothingQuality.HIGH;
						}
						if (item.attribute("width").length() > 0) 
							newImage.width = parseInt(item.@width);
						if (item.attribute("height").length() > 0)
							newImage.height = parseInt(item.@height);
						backgroundGraphics.addElement(newImage);
					}
				}
					
				if (group && xhtmlRichText) {
					group.visible = group.includeInLayout = (sectionName == "header") ? exercise.hasHeader() : exercise.hasSection(sectionName);
					
					xhtmlRichText.xhtml = exercise;
					xhtmlRichText.nodeId = (sectionName == "header") ? "body > header" : "#" + sectionName;

					// #258
					group.removeEventListener(MouseEvent.CLICK, onSectionClick);
					if (exercise.model.hasSettingParam("incorrectClickSection") && exercise.model.getSettingParam("incorrectClickSection") == sectionName)
						group.addEventListener(MouseEvent.CLICK, onSectionClick);

					// gh#1164 hide the blur mask here for it covering the video scripture button. But after the image can blur itself we can remove the code.
					if (sectionName == "rightNoScroll" && exercise.getSection("rightNoScroll")) {
						if(exercise.getSection("rightNoScroll").video.length() > 0) {
							if (imgLeftBlur)
								imgLeftBlur.visible = false;
							if (imgBottomBlur)
								imgBottomBlur.visible = false;
						} else {
							if (imgLeftBlur)
								imgLeftBlur.visible = true;
							if (imgBottomBlur)
								imgBottomBlur.visible = true;
						}
					}
				}
			}
		}
		
		/**
		 * #258 - display the incorrect icon for a few seconds where the user clicked
		 * 
		 * @param event
		 */
		protected function onSectionClick(event:MouseEvent):void {
			// gh#1436
			if (isClickFlowElement || !(event.target is TextLine)) {
				isClickFlowElement = false;
				return;
			}
			
			dispatchEvent(new SectionEvent(SectionEvent.INCORRECT_QUESTION_ANSWER, null, null, null, true));
			
			var swfLoader:SWFLoader = new SWFLoader();
			swfLoader.source = getStyle("incorrectIcon");
			swfLoader.mouseEnabled = swfLoader.mouseChildren = false;
			
			var point:Point = PointUtil.convertPointCoordinateSpace(new Point(event.localX, event.localY), event.target as DisplayObject, event.currentTarget as DisplayObject);
			swfLoader.x = point.x - getStyle("incorrectIconWidth") / 2;
			swfLoader.y = point.y - getStyle("incorrectIconHeight") / 2;
			
			swfLoader.alpha = 0;
			event.currentTarget.addElement(swfLoader);
			
			Tweener.addTween(swfLoader, { alpha: 1, time: 0.6 } );
			Tweener.addTween(swfLoader, { alpha: 0, time: 0.6, delay: 2, onComplete: function():void { (this.parent as Group).removeElement(this as IVisualElement); } } );
		}

		public function stopAllAudio():void {
			AudioPlayer.stopAllAudio();
		}
		
		public function selectAnswerMap(question:Question, answerMap:AnswerMap):void {
			// This is only applicable for selectable questions
			if (!question.isSelectable())
				return;
			
			var textFlowDamageAccumulator:TextFlowDamageAccumulator = new TextFlowDamageAccumulator();
			
			// Always deselect all nodes so we are selecting from a blank state (ExerciseProxy will take care of mutual exclusiveness, etc)
			for each (var allAnswers:NodeAnswer in question.answers) {
				for each (var otherSource:XML in allAnswers.getSourceNodes(exercise)) {
					XHTML.removeClass(otherSource, Answer.SELECTED);
					TLFUtil.markFlowElementFormatChanged(getFlowElement(otherSource));
					textFlowDamageAccumulator.damageTextFlow(getFlowElement(otherSource).getTextFlow());
				}
			}
			
			for each (var key:Object in answerMap.keys) {
				var answer:Answer = answerMap.get(key);
				var answerNode:XML = key as XML;
				var answerElement:FlowElement = getFlowElement(answerNode);
				
				// Add the selected class
				XHTML.addClass(answerNode, Answer.SELECTED);
				// Refresh the element and update the screen
				// TODO: This is crazy inefficient!  Instead build up the text flows that have changed and do them once each at the end.
				TLFUtil.markFlowElementFormatChanged(answerElement);
				textFlowDamageAccumulator.damageTextFlow(answerElement.getTextFlow());
				break;
			}

			textFlowDamageAccumulator.updateDamagedTextFlows();
		}
		
		public function markAnswerMap(question:Question, answerMap:AnswerMap, isShowAnswers:Boolean = false):void {
			var textFlowDamageAccumulator:TextFlowDamageAccumulator = new TextFlowDamageAccumulator();
			
			for each (var key:Object in answerMap.keys) {
				var answer:Answer = answerMap.get(key);
				var answerNode:XML = key as XML;
				var answerElement:FlowElement = getFlowElement(answerNode);
				
				var sourceNodes:Vector.<XML>;
				
				// If we are in show answers then clear any existing icons for this question (MarkableIconsBehaviour)
				if (isShowAnswers && answerElement) answerElement.getTextFlow().dispatchEvent(new MarkingOverlayEvent(MarkingOverlayEvent.FLOW_ELEMENT_UNMARKED, answerElement));
				
				// For some questions deselect all other nodes
				if (question.isMutuallyExclusive()) {
					for each (var allAnswers:NodeAnswer in question.answers) {
						for each (var otherSource:XML in allAnswers.getSourceNodes(exercise)) {
							var otherSourceElement:FlowElement = getFlowElement(otherSource);
							
							// Remove any icon for this answer (MarkableIconsBehaviour)
							answerElement.getTextFlow().dispatchEvent(new MarkingOverlayEvent(MarkingOverlayEvent.FLOW_ELEMENT_UNMARKED, otherSourceElement));
							
							XHTML.removeClasses(otherSource, [ Answer.CORRECT, Answer.INCORRECT, Answer.NEUTRAL ] );
							TLFUtil.markFlowElementFormatChanged(otherSourceElement);
							textFlowDamageAccumulator.damageTextFlow(otherSourceElement.getTextFlow());
						}
					}
				}
				
				// Fill in the input element with the given answer (if we are using 'show answer' this will fill it in,
				// otherwise this will just fill it in with what is already there and will have no effect)
				if (answerElement is InputElement) {
					var inputElement:InputElement = answerElement as InputElement;
					// gh#650
					if (answer is TextAnswer) {
						answerNode.text = inputElement.value = (answer as TextAnswer).value;
					}
					
					
					if (isShowAnswers) { // gh#351
						/*if (answer is TextAnswer) {
							answerNode.text = inputElement.value = (answer as TextAnswer).value;
						} else {*/
						if (answer is NodeAnswer) {
							sourceNodes = (answer as NodeAnswer).getSourceNodes(exercise);
							
							// gh#473 - updated this to only run when showing answers (this seems to be the only time it is necessary), as well as including a real flowElement instead of null.
							if (sourceNodes) inputElement.dragDrop(sourceNodes[0], exercise.flowElementXmlBiMap.getFlowElement(sourceNodes[0]), sourceNodes[0].toString());
						}							
						//}
					}
				}
				
				if (answerElement is SelectElement) {
					var selectElement:SelectElement = answerElement as SelectElement;
					
					sourceNodes = (answer as NodeAnswer).getSourceNodes(exercise);
					if (sourceNodes) {
						selectElement.selectedItem = sourceNodes[0];
					} else {
						log.error("Unable to find a correct answer for dropdown {0}", selectElement);
					}
				}

				// This is used by MarkableIconsBehaviour
				if (isShowAnswers) {
					// The tick/cross rules when showing answers is slightly different; we tick something you got right, otherwise we do nothing
					if (XHTML.hasClass(answerNode, "selected") && answer.markingClass == Answer.CORRECT) {
						answerElement.getTextFlow().dispatchEvent(new MarkingOverlayEvent(MarkingOverlayEvent.FLOW_ELEMENT_MARKED, answerElement, answer.markingClass));
					}
				} else {
					// Otherwise the tick/cross reflects the marking class
					answerElement.getTextFlow().dispatchEvent(new MarkingOverlayEvent(MarkingOverlayEvent.FLOW_ELEMENT_MARKED, answerElement, answer.markingClass));
				}
				
				// Remove any existing classes and add the result class
				XHTML.removeClasses(answerNode, [ Answer.CORRECT, Answer.INCORRECT, Answer.NEUTRAL ] );
				XHTML.addClass(answerNode, answer.markingClass);
				
				// #102, gh#388
				if (isShowAnswers && answer.feedback) {	
					atLeastOneSelectedAnswerHasFeedback = true;
					// gh#413 I need to get this into exerciseView
					//gotQuestionFeedback.dispatch(atLeastOneSelectedAnswerHasFeedback);
				}
				
				// gh#526 - once a target spotting question has been marked, disable it so it can't be unselected
				if (question.type == Question.TARGET_SPOTTING_QUESTION) {
					XHTML.addClass(answerNode, "disabled");
				}
				TLFUtil.markFlowElementFormatChanged(answerElement);
				textFlowDamageAccumulator.damageTextFlow(answerElement.getTextFlow());
			}
			
			textFlowDamageAccumulator.updateDamagedTextFlows();
        }
		
		/**
		 * When an exercise has been marked, various things (i.e. drags, inputs, etc) become non-interactive.
		 * 
		 * @param value 
		 */
		public function setExerciseMarked(marked:Boolean = true):void {
			// Get all the source node
			var sourceNodes:Vector.<XML> = exercise.model.getAllSourceNodes();
			
			// Combine those with all draggable nodes
			var draggableNodes:Array = exercise.select("*[draggable=true]");
			if (draggableNodes) {
				sourceNodes = sourceNodes.concat(Vector.<XML>(draggableNodes));
			}
			
			var textFlowDamageAccumulator:TextFlowDamageAccumulator = new TextFlowDamageAccumulator();
			
			// Now go through either adding or removing the disabled class as required.  There may be duplication in the sourceNodes vector,
			// but that doesn't matter as addClass and removeClass will do nothing unless it needs to.
			for each (var node:XML in sourceNodes) {
				var flowElement:FlowElement = getFlowElement(node);
				
				if (flowElement) {
					if (marked) {
						XHTML.addClass(node, "disabled");
					} else {
						XHTML.removeClasses(node, [ "disabled", Answer.CORRECT, Answer.INCORRECT, Answer.NEUTRAL ]);
						
						// When clicking try again we want to re-disable dragdrops that were already in use
						if (XHTML.hasClass(node, "used")) {
							XHTML.addClass(node, "disabled");
						}
						
						flowElement.getTextFlow().dispatchEvent(new MarkingOverlayEvent(MarkingOverlayEvent.FLOW_ELEMENT_MARKED, flowElement));
					}
					
					if (flowElement is TextComponentElement)
						(flowElement as TextComponentElement).enabled = !marked;
					
					TLFUtil.markFlowElementFormatChanged(flowElement);
					textFlowDamageAccumulator.damageTextFlow(flowElement.getTextFlow());
				} else {
					log.error("Cannot find flow element for {0}", node);
				}
			}

            // gh#1334 Stop incorrect click behaviour after marking (and enable on try again)
            if (exercise.model.hasSettingParam("incorrectClickSection")) {
                var group:Group = this[exercise.model.getSettingParam("incorrectClickSection") + "Group"];
                if (marked) {
                    log.info("remove incorrect click event for section {0}", exercise.model.getSettingParam("incorrectClickSection"));
                    group.removeEventListener(MouseEvent.CLICK, onSectionClick);
                } else {
                    log.info("add back incorrect click event for section {0}", exercise.model.getSettingParam("incorrectClickSection"));
                    group.addEventListener(MouseEvent.CLICK, onSectionClick);
                }
            }

            textFlowDamageAccumulator.updateDamagedTextFlows();
		}
		
		// gh#627
		public function modifyMarkingClass(question:Question, selectedAnswerMap:AnswerMap, markableAnswerMap:AnswerMap, marked:Boolean = true):void {
			var textFlowDamageAccumulator:TextFlowDamageAccumulator = new TextFlowDamageAccumulator();
			
			if (marked) {
				var targetNodes:Vector.<XML> = question.getSourceNodes(exercise);
				for each (var key:Object in selectedAnswerMap.keys) {
					var sourceNode:XML = key as XML;
					var selectedAnswer:Answer = selectedAnswerMap.get(sourceNode);
					var markableAnswer:Answer = markableAnswerMap.get(sourceNode);
					var selectedAnswerElement:FlowElement = getFlowElement(sourceNode);						
					
					// For multiple choice, the sourceNode(key) is not same in selectedAnswerMap and markableAnswerMap. 
					// Hence if the answer in second try is not same as the first try, you will not get markableAnswer through the key in selectedAnswerMap
					if (markableAnswer && ((selectedAnswer.markingClass != markableAnswer.markingClass) && markableAnswer.markingClass == Answer.INCORRECT)) {
						selectedAnswerElement.getTextFlow().dispatchEvent(new MarkingOverlayEvent(MarkingOverlayEvent.FLOW_ELEMENT_UNMARKED, selectedAnswerElement));
					} else if (!markableAnswer) {
						selectedAnswerElement.getTextFlow().dispatchEvent(new MarkingOverlayEvent(MarkingOverlayEvent.FLOW_ELEMENT_UNMARKED, selectedAnswerElement));
					}
				}			
			} 
		}

		// gh#1373
		public function getTopGroupHeight():Number {
			if (noscrollGroup.height > 0) {
				return headerGroup.height + noscrollGroup.height + 5;
			} else {
				return headerGroup.height;
			}
		}
	}

}
import flash.utils.Dictionary;

import flashx.textLayout.elements.TextFlow;

/**
 * Utility class to allow us to build up a series of changes to text flow, then update then all at the end
 */
class TextFlowDamageAccumulator {
	
	private var damagedTextFlows:Dictionary;
	
	public function TextFlowDamageAccumulator() {
		damagedTextFlows = new Dictionary();
	}
	
	public function damageTextFlow(textFlow:TextFlow):void {
		damagedTextFlows[textFlow] = true;
	}
	
	public function updateDamagedTextFlows():void {
		for (var textFlow:* in damagedTextFlows)
			(textFlow as TextFlow).flowComposer.updateAllControllers();
	}
	
}