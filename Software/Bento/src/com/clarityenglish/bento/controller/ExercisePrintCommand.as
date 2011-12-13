package com.clarityenglish.bento.controller {
	import com.clarityenglish.alivepdf.pdf.PDF;
	import com.clarityenglish.bento.view.DynamicView;
	import com.clarityenglish.bento.vo.Href;
	
	import flash.display.DisplayObject;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	
	import org.alivepdf.display.Display;
	import org.alivepdf.fonts.CoreFont;
	import org.alivepdf.fonts.FontFamily;
	import org.alivepdf.fonts.IFont;
	import org.alivepdf.layout.Layout;
	import org.alivepdf.layout.Orientation;
	import org.alivepdf.layout.Size;
	import org.alivepdf.layout.Unit;
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
			
			var href:Href = note.getBody() as Href;
			
			var pdf:PDF = new PDF(Orientation.PORTRAIT, Unit.MM, Size.A4);
			pdf.setDisplayMode(Display.FULL_PAGE, Layout.SINGLE_PAGE);
			
			var defaultFont:IFont = new CoreFont(FontFamily.HELVETICA);
			pdf.setFont(defaultFont, 11);
			
			var dynamicView:DynamicView = new DynamicView();
			dynamicView.media = "print";
			dynamicView.href = href;
			dynamicView.width = Size.A4.dimensions[0];
			dynamicView.scaleX = dynamicView.scaleY = 1;
			
			PopUpManager.addPopUp(dynamicView, FlexGlobals.topLevelApplication as DisplayObject, true, PopUpManagerChildList.POPUP, FlexGlobals.topLevelApplication.moduleFactory);
			PopUpManager.centerPopUp(dynamicView);
			
			// TODO: This somehow needs to wait for everything to be drawn
			
			// Create a new page and get going
			//pdf.addPage();
			
			// Put a header graphic on the page
			//var imageHeader:ByteArray = new imageHeaderStream() as ByteArray;
			//pdf.addImageStream(imageHeader, ColorSpace.DEVICE_RGB, new org.alivepdf.layout.Resize(Mode.NONE, Position.LEFT), -10, -10, 210);
			
			// Look at ratios and shrinkage
			var viewWidth:Number = dynamicView.width;
			var viewHeight:Number = dynamicView.height;
			var viewAspectRatio:Number = viewHeight / viewWidth;
			
			// The PDF is measured in mm, the chart in pixels. But this number is not just mm. Why not?
			var pdfChartScaling:Number = 1;
			var maxWidth:Number = 180;
			var maxTableWidth:Number = 160; var maxTableHeight:Number = 25;
			
			var pdfViewWidth:Number = maxTableWidth;
			var pdfViewHeight:Number = maxTableWidth * viewAspectRatio;
			
			// Chop the page into seperate images 
			
			//pdf.addPage();
			//pdf.addImage(dynamicView, null, 10,	50, pdfViewWidth, pdfViewHeight);
			
			pdf.addMultiPageImage(dynamicView, null, 10, 0, pdfViewWidth, pdfViewHeight);
			
			// Then send the byte stream to the server. Go through amfphp simply to keep everything in one place?
			var pdfURL:String = "/Software/ResultsManager/web/amfphp/services/createPDF.php";
			pdf.save(Method.REMOTE, pdfURL, Download.ATTACHMENT);
			
			// Then close
			pdf.end();
		}
		
	}
	
}