package com.clarityenglish.tensebuster.view.progress
{
	import com.clarityenglish.alivepdf.pdf.PDF;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.progress.ui.ProgressCourseButtonBar;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.printing.PrintJob;
	
	import flashx.textLayout.elements.TextFlow;
	
	import mx.controls.SWFLoader;
	
	import org.alivepdf.display.Display;
	import org.alivepdf.layout.Mode;
	import org.alivepdf.layout.Orientation;
	import org.alivepdf.layout.Position;
	import org.alivepdf.layout.Resize;
	import org.alivepdf.layout.Size;
	import org.alivepdf.layout.Unit;
	import org.alivepdf.saving.Method;
	import org.davekeen.util.DateUtil;
	import org.davekeen.util.StringUtils;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.RichEditableText;
	import spark.components.VGroup;
	import spark.events.IndexChangeEvent;
	import spark.utils.TextFlowUtil;
	
	public class ProgressCertificateView extends BentoView {
		
		[SkinPart]
		public var progressCourseButtonBar:ProgressCourseButtonBar;
		
		[SkinPart]
		public var oopsLabel:Label;
		
		[SkinPart]
		public var notCompleteRichEditableText:RichEditableText;
		
		[SkinPart]
		public var oopsVGroup:VGroup;
		
		[SkinPart]
		public var certificateSWFLoader:SWFLoader;
		
		[SkinPart]
		public var nameLabel:Label;
		
		[SkinPart]
		public var courseLabel:Label;
		
		[SkinPart]
		public var dateLabel:Label;
		
		[SkinPart]
		public var certificateRichEditableText:RichEditableText;
		
		[SkinPart]
		public var certificateGroup:spark.components.Group;
		
		[SkinPart]
		public var printButton:Button;
		
		[SkinPart]
		public var printGroup:spark.components.Group;
		
		[Embed(source="skins/tensebuster/assets/progress/certificate/ACert.png")]
		private static var ACert:Class;
		
		[Embed(source="skins/tensebuster/assets/progress/certificate/ECert.png")]
		private static var ECert:Class;
		
		[Embed(source="skins/tensebuster/assets/progress/certificate/ICert.png")]
		private static var ICert:Class;
		
		[Embed(source="skins/tensebuster/assets/progress/certificate/UCert.png")]
		private static var UCert:Class;
		
		[Embed(source="skins/tensebuster/assets/progress/certificate/LCert.png")]
		private static var LCert:Class;
		
		private var _courseChanged:Boolean;
		private var _courseClass:String;
		private var myPDF:PDF;
		
		[Bindable]
		public var user:User;
		
		public var courseSelect:Signal = new Signal(String);
		
		/**
		 * This can be called from outside the view to make the view display a different course
		 *
		 * @param XML A course node from the menu
		 *
		 */
		public function set courseClass(value:String):void {
			_courseClass = value;
			_courseChanged = true;
			invalidateProperties();
		}
		
		[Bindable]
		public function get courseClass():String {
			return _courseClass;
		}
		
		protected override function onViewCreationComplete():void {
			super.onViewCreationComplete();
			
			if (progressCourseButtonBar) progressCourseButtonBar.copyProvider = copyProvider;
			oopsLabel.text = copyProvider.getCopyForId("oopsLabel");
			nameLabel.text = user.fullName;
			printButton.label = copyProvider.getCopyForId("printButton");
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			progressCourseButtonBar.courses = menu.course;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_courseChanged) {
				// #176. Make sure the buttons in the progressCourseBar component reflect current state
				if (progressCourseButtonBar) progressCourseButtonBar.courseClass = courseClass;
				
				var totalUnit:Number = menu.course.(@["class"] == courseClass).unit.length();
				var exerciseAmount:Number = 0;
				var totalExercise:Number = 0;
				for (var i:Number = 0; i < totalUnit; i++) {
					var unitXML:XML = menu.course.(@["class"] == courseClass).unit[i]
					var totalExercisePerUnit:Number = unitXML.exercise.length();
					for (var j:Number = 0; j < totalExercisePerUnit; j++) {
						if (unitXML.exercise[j].hasOwnProperty("@done")) {
							exerciseAmount++;
						}
					}
					totalExercise += totalExercisePerUnit;
				}
				var aveScore:Number = menu.course.(@["class"] == courseClass).@averageScore;
				oopsVGroup.visible = false;
				certificateGroup.visible = false;
				printGroup.visible = false;
				if (exerciseAmount != totalExercise) {
					oopsVGroup.visible = true;
					oopsLabel.setStyle("color", getStyle(StringUtils.capitalize(courseClass.charAt(0)) + "Color"));
					var notCompleteString:String = copyProvider.getCopyForId("notCompleteString", {exerciseAmount: exerciseAmount, totalExercise: totalExercise, aveScor: aveScore});
					var textFlow:TextFlow = TextFlowUtil.importFromString(notCompleteString);
					notCompleteRichEditableText.textFlow = textFlow;
				} else {
					certificateGroup.visible = true;
					printGroup.visible = true;
					switch (courseClass.charAt(0)) {
						case "e":
							certificateSWFLoader.source = ECert;
							break;
						case "u":
							certificateSWFLoader.source = UCert;
							break;
						case "i":
							certificateSWFLoader.source = ICert;
							break;
						case "l":
							certificateSWFLoader.source = LCert;
							break;
						case "a":
							certificateSWFLoader.source = ACert;
							break;
						
					}
					courseLabel.text = menu.course.(@["class"] == courseClass).@caption;
					var completeString:String = copyProvider.getCopyForId("completeString", {aveScore: aveScore});
					var completeTextFlow:TextFlow = TextFlowUtil.importFromString(completeString);
					certificateRichEditableText.textFlow = completeTextFlow;
				}
				
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case progressCourseButtonBar:
					progressCourseButtonBar.addEventListener(IndexChangeEvent.CHANGE, onCourseSelect);
					break;
				case dateLabel:
					var date:Date = new Date();
					dateLabel.text = DateUtil.formatDate(date, "dd MMMM yyyy");
					break;
				case printButton:
					printButton.addEventListener(MouseEvent.CLICK, onPrintClick);
					break;
			}
		}
		
		/**
		 * The user has changed the course to be displayed
		 *
		 * @param String course class name
		 */
		public function onCourseSelect(event:Event):void {
			courseSelect.dispatch(event.target.selectedItem.courseClass.toLowerCase());
		}
		
		protected function onPrintClick(event:MouseEvent):void {
			myPDF = new PDF(  Orientation.LANDSCAPE, Unit.MM, Size.LETTER );
			
			// we set the zoom to 100%
			myPDF.setDisplayMode ( Display.FULL_WIDTH ); 
			
			
			// we add a page
			myPDF.addPage();
			//var resizeMode:Resize = new Resize(Mode.FIT_TO_PAGE, Position.CENTERED);
			myPDF.addImage(certificateGroup, null, -25, 0, 290);
			
			// to save the PDF your specificy the path to the create.php script
			// alivepdf takes care of the rest, if you are using AIR and want to save the PDF locally just use Method.LOCAL
			// and save the returned bytes on the disk through the FileStream class
			myPDF.save( Method.REMOTE, "http://dock.projectbench/Software/ResultsManager/web/amfphp/services/createPDF.php", "drawing.pdf" );
		}
	}
}