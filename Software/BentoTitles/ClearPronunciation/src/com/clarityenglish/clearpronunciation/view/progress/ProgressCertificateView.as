package com.clarityenglish.clearpronunciation.view.progress
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
		
		[Embed(source="skins/clearpronunciation/assets/progress/certificate/certificateConsonants.jpg")]
		private static var certificateConsonants:Class;
		
		[Embed(source="skins/clearpronunciation/assets/progress/certificate/certificateDiphthongs.jpg")]
		private static var certificateDiphthongs:Class;
		
		[Embed(source="skins/clearpronunciation/assets/progress/certificate/certificateVowels.jpg")]
		private static var certificateVowels:Class;
		
		private var _courseChanged:Boolean;
		private var _courseClass:String;
		private var _isPlatformTablet:Boolean;
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
		
		[Bindable]
		public function get isPlatformTablet():Boolean {
			return _isPlatformTablet;
		}
		
		public function set isPlatformTablet(value:Boolean):void {
			_isPlatformTablet = value;
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
			
			var courseXMLList:XMLList = new XMLList();
			for each (var course:XML in menu.course) {
				if (course.@["class"] != "introduction") {
					courseXMLList += course;
				}
			}
			if (progressCourseButtonBar) progressCourseButtonBar.courses = courseXMLList;
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
					var unitXML:XML = menu.course.(@["class"] == courseClass).unit[i];
					// gh#1062
					var totalExercisePerUnit:Number = unitXML.exercise.length();
					for (var j:Number = 0; j < totalExercisePerUnit; j++) {
						if (unitXML.exercise[j].attribute("done")) {
							exerciseAmount++;
						}
					}
					totalExercise += totalExercisePerUnit;
				}
				var aveScore:Number = menu.course.(@["class"] == courseClass).@averageScore;
				oopsVGroup.visible = false;
				certificateGroup.visible = false;
				printGroup.visible = false;
				if (coverage < 90) {
					oopsVGroup.visible = true;
					var courseCaption:String = menu.course.(@["class"] == courseClass).@caption;
					var notCompleteString:String = copyProvider.getCopyForId("notCompleteString", {courseCaption: courseCaption,  exerciseAmount: exerciseAmount, totalExercise: totalExercise, aveScor: aveScore});
					var textFlow:TextFlow = TextFlowUtil.importFromString(notCompleteString);
					notCompleteRichEditableText.textFlow = textFlow;
				} else {
					certificateGroup.visible = true;
					if(!isPlatformTablet)
						printGroup.visible = true;
					switch (courseClass) {
						case "consonants":
							certificateSWFLoader.source = certificateConsonants;
							break;
						case "diphthongs":
							certificateSWFLoader.source = certificateDiphthongs;
							break;
						case "vowels":
							certificateSWFLoader.source = certificateVowels;
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
			//var resizeMode:org.alivepdf.layout.Resize = new Resize(Mode.FIT_TO_PAGE, Position.CENTERED);
			myPDF.addImage(certificateGroup, null, -5, 0, 270);
			
			// to save the PDF your specificy the path to the create.php script
			// alivepdf takes care of the rest, if you are using AIR and want to save the PDF locally just use Method.LOCAL
			// and save the returned bytes on the disk through the FileStream class
			myPDF.save( Method.REMOTE, "http://www.clarityenglish.com/Software/ResultsManager/web/amfphp/services/createPDF.php", "drawing.pdf" );
		}
	}
}