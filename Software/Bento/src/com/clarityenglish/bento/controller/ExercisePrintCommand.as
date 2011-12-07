package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.vo.content.Exercise;
	
	import flash.utils.ByteArray;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.alivepdf.display.Display;
	import org.alivepdf.fonts.CoreFont;
	import org.alivepdf.fonts.FontFamily;
	import org.alivepdf.fonts.IFont;
	import org.alivepdf.images.ColorSpace;
	import org.alivepdf.layout.Layout;
	import org.alivepdf.layout.Mode;
	import org.alivepdf.layout.Orientation;
	import org.alivepdf.layout.Position;
	import org.alivepdf.layout.Size;
	import org.alivepdf.layout.Unit;
	import org.alivepdf.pdf.PDF;
	import org.alivepdf.saving.Download;
	import org.alivepdf.saving.Method;
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class ExercisePrintCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		[Embed( source="/skins/assets/StatsYellowHeader.png", mimeType="application/octet-stream" )]
		private var imageHeaderStream:Class;

		public override function execute(note:INotification):void {
			super.execute(note);
			
			var exercise:Exercise = note.getBody().exercise as Exercise;
			
			var exerciseProxy:ExerciseProxy = new ExerciseProxy(exercise);
			
			// Build a pdf of the exercise
			trace("starting to build the pdf");
			var pdf:PDF = new PDF(Orientation.PORTRAIT, Unit.MM, Size.A4);
			pdf.setDisplayMode(Display.FULL_PAGE, Layout.SINGLE_PAGE);
			
			var defaultFont:IFont = new CoreFont ( FontFamily.HELVETICA );
			pdf.setFont( defaultFont, 11 );				
			
			// Create a new page and get going
			pdf.addPage();

			// Put a header graphic on the page
			var imageHeader:ByteArray = new imageHeaderStream() as ByteArray;
			pdf.addImageStream(imageHeader, ColorSpace.DEVICE_RGB, new org.alivepdf.layout.Resize(Mode.NONE, Position.LEFT), -10, -10, 210 );

			// A heading
			pdf.setXY( 50, 3 );
			pdf.setFont( defaultFont, 11 );				
			pdf.addCell(156, 10, "Printing your exercise", 0, 0, 'R');

			// Take a snapshot of a container and output that. Start with the rubric
			// Make new view, infinite height, XHTMLExerciseView, not on screen
			// Get the mediator here and call a function on that to do this. 
			// facade.retrieveMediator(xxxx).getViewComponent();
			// get the xhtmlexerciseview from the mediator, set height to infinite, this might flash the scroll bars, but might work 
				
			// Then send the byte stream to the server. Go through amfphp simply to keep everything in one place?
			var pdfURL:String = "/Software/ResultsManager/web/amfphp/services/createPDF.php";
			pdf.save(Method.REMOTE, pdfURL, Download.ATTACHMENT);
			
			// Then close
			pdf.end();

			sendNotification(BBNotifications.EXERCISE_PRINTED);
		}
		
	}
	
}