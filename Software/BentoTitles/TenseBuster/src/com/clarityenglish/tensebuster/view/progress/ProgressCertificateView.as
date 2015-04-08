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
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
	import flash.printing.PrintJob;
	import flash.utils.ByteArray;
	
	import flashx.textLayout.elements.TextFlow;
	
	import mx.controls.SWFLoader;
	
	import org.alivepdf.display.Display;
	import org.alivepdf.fonts.CoreFont;
	import org.alivepdf.fonts.FontFamily;
	import org.alivepdf.fonts.IFont;
	import org.alivepdf.images.ColorSpace;
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
		public var notCompleteRichEditableText:RichEditableText;
		
		[SkinPart]
		public var oopsVGroup:VGroup;
		
		[SkinPart]
		public var certificateSWFLoader:SWFLoader;
		
		[SkinPart]
		public var nameTextLabel:Label;
		
		[SkinPart]
		public var nameLabel:Label;
		
		[SkinPart]
		public var courseTextLabel:Label;
		
		[SkinPart]
		public var courseLabel:Label;
		
		[SkinPart]
		public var dateTextLabel:Label;
		
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
		
		[SkinPart]
		public var certificateFooter:SWFLoader;
		
		[Embed(source="/skins/tensebuster/assets/progress/certificate/ACert.png")]
		private static var ACert:Class;
		
		[Embed(source="/skins/tensebuster/assets/progress/certificate/ECert.png")]
		private static var ECert:Class;
		
		[Embed(source="/skins/tensebuster/assets/progress/certificate/ICert.png")]
		private static var ICert:Class;
		
		[Embed(source="/skins/tensebuster/assets/progress/certificate/UCert.png")]
		private static var UCert:Class;
		
		[Embed(source="/skins/tensebuster/assets/progress/certificate/LCert.png")]
		private static var LCert:Class;
		
		private var _courseChanged:Boolean;
		private var _courseClass:String;
		//private var pdf:PDF;
		
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
			nameLabel.text = user.fullName;
			printButton.label = copyProvider.getCopyForId("printButton");
			nameTextLabel.text = copyProvider.getCopyForId("nameTextLabel");
			courseTextLabel.text = copyProvider.getCopyForId("courseTextLabel");
			dateTextLabel.text = copyProvider.getCopyForId("dateTextLabel");
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
				var coverage:Number = menu.course.(@["class"] == courseClass).@coverage;
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
				trace("coverage: "+coverage);
				if (coverage < 100) {
					oopsVGroup.visible = true;
					certificateFooter.visible = true;
					var courseCaption:String = menu.course.(@["class"] == courseClass).@caption;
					var notCompleteString:String = copyProvider.getCopyForId("notCompleteString", {courseCaption: courseCaption,  exerciseAmount: exerciseAmount, totalExercise: totalExercise, aveScor: aveScore});
					var textFlow:TextFlow = TextFlowUtil.importFromString(notCompleteString);
					notCompleteRichEditableText.textFlow = textFlow;
				} else {
					certificateGroup.visible = true;
					certificateFooter.visible = false;
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
		
		// gh#1038 Redone
		protected function onPrintClick(event:MouseEvent):void {
			var pdf:PDF = new PDF(Orientation.LANDSCAPE, Unit.MM, Size.A4);
			
			// set the zoom to 100% (applies when it is opened in Reader)
			pdf.setDisplayMode(Display.FULL_WIDTH, org.alivepdf.layout.Layout.SINGLE_PAGE); 
			
			// add a page
			pdf.addPage();

			// Add background graphic
			// This would be fine if it wasn't dependent on scrolling in a shallow window. 
			//pdf.addImage(certificateGroup, null, -25, 0, 290);
			pdf.addImage(certificateSWFLoader, new org.alivepdf.layout.Resize(Mode.FIT_TO_PAGE, Position.LEFT), 25, 5);
			
			// add labels and certificate wording
			var arialNormal:IFont = new CoreFont(FontFamily.HELVETICA);
			var arialBold:IFont = new CoreFont(FontFamily.HELVETICA_BOLD);
			pdf.setFont(arialNormal, 11);
			
			pdf.setXY(10, 55);
			pdf.addCell(50, 10, nameTextLabel.text, 0, 0, 'R');
			pdf.setXY(10, 65);
			pdf.addCell(50, 10, courseTextLabel.text, 0, 0, 'R');
			pdf.setXY(10, 75);
			pdf.addCell(50, 10, dateTextLabel.text, 0, 0, 'R');
			
			pdf.setFont(arialBold, 13);
			var replaceObj:Object = { name:nameLabel.text };
			pdf.setXY(62, 55);
			pdf.addCell(50, 10, copyProvider.getCopyForId("certificateName",replaceObj), 0, 0, 'L');
			replaceObj = { course:courseLabel.text };
			pdf.setXY(62, 65);
			pdf.addCell(50, 10, copyProvider.getCopyForId("certificateCourse",replaceObj), 0, 0, 'L');
			replaceObj = { date:dateLabel.text };
			pdf.setXY(62, 75);
			pdf.addCell(50, 10, copyProvider.getCopyForId("certificateDate",replaceObj), 0, 0, 'L');
			
			pdf.setFont(arialNormal, 13);
			var aveScore:Number = menu.course.(@["class"] == courseClass).@averageScore;
			pdf.setXY(88, 92);
			pdf.addMultiCell(120, 6, copyProvider.getCopyForId("certificateWording", {score: aveScore}), 0, 'C');

			var pdfURL:String = "/Software/ResultsManager/web/amfphp/services/createPDF.php?filename=certificate.pdf";
			var bytesTemp:ByteArray = pdf.save(Method.LOCAL);
			var sendRequest:URLRequest = new URLRequest(pdfURL);
			sendRequest.method = URLRequestMethod.POST;
			sendRequest.data = bytesTemp;
			navigateToURL(sendRequest,'_blank');
			
			// Then close
			pdf.end();
		}
	}
}