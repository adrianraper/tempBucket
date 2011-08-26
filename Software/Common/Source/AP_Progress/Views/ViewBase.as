import mx.controls.*;
import AP_Progress.GlobalVar;

class AP_Progress.Views.ViewBase
{	
	// const variables
	private var HEADER_HINT_HEIGHT:Number	= 25;
	
	// member variables
	private var m_clipContainer:MovieClip;
	private var m_mcNoRecordBackground:MovieClip; 
	private var m_strNoRecordBackgroundFilePath:String	= "";
	private var m_numOfDepth:Number						= 0;
	private var m_myXmlRecCopy:XML;
	private var m_everyoneXmlRecCopy:XML;
	private var m_titleHint:TextField;
	private var m_txtNoData1:TextField;
	
	private static var m_nNumOfViewCreated:Number 		= 0;
	//private static var PRINT_WIDTH_SCALE_RATIO:Number	= 0.7;
	//private static var PRINT_HEIGHT_SCALE_RATIO:Number= 0.7;
	private static var A4_PAPER_WIDTH:Number			= 570;
	private static var NO_DATA_WARNING_MESSAGE1:String	= "";
	private static var NO_DATA_WARNING_MESSAGE2:String	= "Please come back later";
	private static var GRAPHIC_FOLDER_NAME				= "chartsBackground";
	
	public function ViewBase(parent:MovieClip, strViewName:String, numDepth:Number){
		NO_DATA_WARNING_MESSAGE1	= _global.ORCHID.literalModelObj.getLiteral("progress_global_noScoredEx", "messages");
		m_clipContainer				= parent.createEmptyMovieClip(strViewName, numDepth);
		m_nNumOfViewCreated++;
	}
	
	public function SetNoRecordBackgroundFilePath(strFileName:String):Void{
		//m_strNoRecordBackgroundFilePath	= _global.ORCHID.paths.movie + GRAPHIC_FOLDER_NAME + "/" + strFileName;
		m_strNoRecordBackgroundFilePath	= strFileName;
	}
	
	public function SetVisible(bVisible:Boolean):Void{
		m_clipContainer._visible= bVisible;
	}
	
	public function initView(myXmlRecCopy:XML, everyoneXmlRecCopy:XML, titleHintText:String):Void{
		m_myXmlRecCopy			= myXmlRecCopy;
		m_everyoneXmlRecCopy	= everyoneXmlRecCopy;
		
		// v6.5.6.4 New SSS realigned a bit
		//_global.myTrace("xx branding title for " + _global.ORCHID.root.licenceHolder.licenceNS.branding);
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
			_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
			// Note that ProgressApp hardcodes this too to draw the grey background behind it.
			HEADER_HINT_HEIGHT = 31;
			var headerXOffset = 20;
			var headerYOffset = 4;
		} else {
			var headerXOffset = 8;
			var headerYOffset = 2;
		}
		m_titleHint = m_clipContainer.createTextField("m_titleHint" + m_nNumOfViewCreated, 
													m_clipContainer.getNextHighestDepth(), 
													headerXOffset, 
													GlobalVar.G_DISPLAY_START_Y + headerYOffset, 
													GlobalVar.G_DISPLAY_WIDTH,
													HEADER_HINT_HEIGHT);
		with(m_titleHint){
			text	= titleHintText;
		}
		
		var my_fmt:TextFormat = new TextFormat();
		with(my_fmt){
			font 	= "Verdana"; 
			size 	= 12;
			bold	= true;
		}
		
		m_titleHint.setTextFormat(my_fmt);
	}
	
	// override me!
	public function redraw(tarChart_mc:MovieClip):Void{
		tarChart_mc._visible	= true;
		tarChart_mc.setParam();
	}
	
	// override me!
	public function print(strHeader:String):Void{
	}
	
	public function printing(mc:MovieClip, strHeader:String, nPrintX:Number, nPrintY:Number, nScaleRatioWidth:Number, nScaleRatioHeight:Number):Void{
		var my_pj:PrintJob 			= new PrintJob();
		var nBackUpWidth:Number		= mc._width;
		var nBackUpHeight:Number	= mc._height;
		var nBackUpX:Number			= mc._x;
		var nBackUpY:Number			= mc._y;
		
		if(my_pj.start()){
			// change the width and height when printing, make the image fitting the pager size
			mc._width		= mc._width * nScaleRatioWidth;
			mc._height		= mc._height * nScaleRatioHeight;
			mc._x			= nPrintX;
			mc._y			= nPrintY;
				
			// create a text field for the header, only shown on printed page
			var tempTextField:TextField= mc.createTextField(	"tempTextField", 
																mc.getNextHighestDepth(), 
																10, 10, 
																300, 30);
			tempTextField.text= strHeader;
		
			var my_fmt:TextFormat = new TextFormat();
			with(my_fmt){
				font 	= "Verdana"; 
				size 	= 12;
				bold	= true;
			}
			tempTextField.setTextFormat(my_fmt);
		
			// start printing
			my_pj.addPage(mc);
			my_pj.send();
			
			// delete the text field after printing
			tempTextField.removeTextField();
			delete my_pj;
			
			// restore it size and width
			mc._width		= nBackUpWidth;
			mc._height		= nBackUpHeight;
			mc._x			= nBackUpX;
			mc._y			= nBackUpY;
		}
	}
		
	public function showNoDataMessgeBox():Void{
		_global.myTrace("showNoDataMessgeBox");
		
		if(m_txtNoData1){
			_global.myTrace("m_txtNoData1 already have");
			return ;
		}
		
		// Data 1
		m_txtNoData1.removeTextField();
		m_txtNoData1					= m_clipContainer.createTextField(	"m_txtNoData1",
																			m_clipContainer.getNextHighestDepth(), 
																			100, 90, 
																			0, 0);
																																			
		m_txtNoData1.autoSize	= true;
		m_txtNoData1.html		= true;
		m_txtNoData1.htmlText	= "<b><font size=\"16\" face=\"Verdana\" color=\"#000000\">" + NO_DATA_WARNING_MESSAGE1 + "</font></b>";
		m_txtNoData1._x			= (GlobalVar.G_DISPLAY_WIDTH - m_txtNoData1._width)/2;
				
		// invisible hints
		m_titleHint._visible	= false;
	}
	
	public function hiddenNoDataMessgeBox():Void{
		m_txtNoData1.removeTextField();
		m_txtNoData1 = null;
		
		m_titleHint._visible	= true;
	}
	
	// override me!
	private function createAndShowNoRecordBackground():Void{
		hiddenAndReleaseNoRecordBackground();
		
		m_mcNoRecordBackground=	m_clipContainer.attachMovie(m_strNoRecordBackgroundFilePath, "m_mcNoRecordBackground", 0);
		//m_mcNoRecordBackground= m_clipContainer.createEmptyMovieClip("m_mcNoRecordBackground",0);
		//m_mcNoRecordBackground.loadMovie(m_strNoRecordBackgroundFilePath);
		m_mcNoRecordBackground._x	= GlobalVar.G_DISPLAY_START_X	+ 1;
		m_mcNoRecordBackground._y	= GlobalVar.G_DISPLAY_START_Y + HEADER_HINT_HEIGHT	- 1;
	}
	
	private function hiddenAndReleaseNoRecordBackground():Void{
		m_mcNoRecordBackground.removeMovieClip();
	}
}