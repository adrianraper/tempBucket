import AP_Progress.Views.ViewBase;
import AP_Progress.Views.NormalView;
import AP_Progress.Views.CompareView;
import AP_Progress.Views.AboutUView;
import AP_Progress.GlobalVar;
import mx.controls.*;
import flash.geom.*;
import AP_Progress.CustomizeDevice;
//import fl.events.MouseEvent;

class AP_Progress.ProgressApp
{	
	// constants
	static public var CLIP_NAME:String			= "progressApp";
	private var BUTTON_START_X:Number			= 5;
	private var BUTTON_START_Y:Number			= 5;
	private var BUTTON_OFFSET_X:Number			= 10;
	private var BUTTON_WIDTH:Number				= 110;
	private var BUTTON_HEIGHT:Number			= 28.3;
	private var BUTTON_LABEL_FONT_SIZE:Number	= 12; 
	
	// member variables
	private var m_clipContainer:MovieClip;
	private var m_viewNormal:NormalView;
	private var m_viewCompare:CompareView;
	private var m_viewAboutU:AboutUView;
	private var m_rgRadioButtonGroup:RadioButtonGroup;
	private var m_currentView:ViewBase;
	
	// testing data
	private var m_MyXml:XML;
	private var m_EveryoneXml:XML;
	
	private var m_btnTable:Button;
	private var m_btnAboutU:Button;
	private var m_btnCompare:Button;
	private var m_btnTest:Button;
	private var m_grBtnBg:MovieClip;
	
	public function ProgressApp(){
	}
	
	private function readXML():Void{
		m_MyXml			= new XML();
		m_EveryoneXml	= new XML();
		
		m_MyXml["parentInstance"]		= this;
		m_EveryoneXml["parentInstance"]	= this;
		
		m_MyXml.load("my.xml");
		m_EveryoneXml.load("everyone.xml");
			
		//m_MyXml.onLoad= XmlOnLoad;
		m_EveryoneXml.onLoad= m_MyXml.onLoad= function(success:Boolean):Void{
			if(this.parentInstance.checkIfBothXmlLoaded()){
				this.parentInstance.initViews();
			}
		}
	}
	public function InitApp(parentClip:MovieClip, nAppWidth:Number, nAppHeight:Number, numDepth:Number, myXmlRecord:XML, everyOneXmlRecord:XML){
		m_clipContainer		= parentClip.createEmptyMovieClip(CLIP_NAME, numDepth);
		m_clipContainer._x 	= 0;
		m_clipContainer._y 	= 0;
		
			m_grBtnBg = m_clipContainer.createEmptyMovieClip("m_grBtnBg", m_clipContainer.getNextHighestDepth());
			m_grBtnBg.colors = CustomizeDevice.ChangeStyleColor(CLIP_NAME, "grBtnBg_colors");
			
			with (m_grBtnBg) 
			{	
				fillType = "linear"
				alphas = [100, 100];
				ratios = [0, 0xFF];
				spreadMethod = "reflect";
				interpolationMethod = "linearRGB";
				focalPointRatio = 0.9;
				matrix = new Matrix();
				matrix.createGradientBox(100, 100, Math.PI, 0, 0);
				beginGradientFill(fillType, colors, alphas, ratios, matrix, 
					spreadMethod, interpolationMethod, focalPointRatio);
				
				var nStartX	= 0;
				var nStartY	= 0;
				var nWidth	= GlobalVar.G_DISPLAY_WIDTH+1;
				// v6.5.6.4 New SSS
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
					_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
					var nHeight	= 30;
					nStartX+= 1;
					nWidth+= 1;
				} else {
					var nHeight	= 38;
				}
				moveTo(nStartX, nStartY);
				lineTo(nWidth, nStartY);
				lineTo(nWidth, nHeight);
				lineTo(nStartX, nHeight);
				lineTo(nStartX,nStartY);
				endFill();
			}
			
		// v6.5.6.4 New SSS doesn't want internal buttons
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toString().toLowerCase().indexOf("clarity/sssv9")>=0 ||
			_global.ORCHID.root.licenceHolder.licenceNS.branding.toString().toLowerCase().indexOf("clarity/cp2")>=0) {
			GlobalVar.G_DISPLAY_START_X = 1;
			GlobalVar.G_DISPLAY_START_Y = 0;
			//GlobalVar.G_DISPLAY_WIDTH = 661;
			GlobalVar.G_DISPLAY_HEIGHT = 504;
		} else {
	
			m_btnTable					= m_clipContainer.createClassObject(	Button, "btn_Table", m_clipContainer.getNextHighestDepth(), 
																				{	label:_global.ORCHID.literalModelObj.getLiteral("progress_global_title1", "messages"), 
																					_x:BUTTON_START_X, 
																					_y:BUTTON_START_Y, 
																					color:0xFFFFFF, 
																					fontSize:BUTTON_LABEL_FONT_SIZE});		
			m_btnTable.falseUpSkin		= "btnUp_ex";
			m_btnTable.falseOverSkin	= "btnOver_ex";
			m_btnTable.falseDownSkin	= "btnUp_ex";
			m_btnTable.setSize(BUTTON_WIDTH, BUTTON_HEIGHT);
			m_btnTable.setStyle("fontFamily", "Verdana");
			m_btnTable.setStyle("fontWeight", "bold");
			
			m_btnTable["parentAppObj"]= this;
			
			m_btnCompare				= m_clipContainer.createClassObject(	Button, "btn_Comparsion", m_clipContainer.getNextHighestDepth(), 
																				{	label:_global.ORCHID.literalModelObj.getLiteral("progress_global_title2", "messages"),
																					_x:m_btnTable._x + m_btnTable.width + BUTTON_OFFSET_X,
																					_y:BUTTON_START_Y,
																					color:0xFFFFFF, 
																					fontSize:BUTTON_LABEL_FONT_SIZE});
			m_btnCompare.falseUpSkin	= "btnUp_ex";
			m_btnCompare.falseOverSkin	= "btnOver_ex";
			m_btnCompare.falseDownSkin	= "btnUp_ex";
			m_btnCompare.setSize(BUTTON_WIDTH, BUTTON_HEIGHT);
			m_btnCompare.setStyle("fontFamily", "Verdana");
			m_btnCompare.setStyle("fontWeight", "bold");
			m_btnCompare["parentAppObj"]= this;
			
			m_btnAboutU					= m_clipContainer.createClassObject(	Button, "btn_AboutU", m_clipContainer.getNextHighestDepth(), 
																				{	label:_global.ORCHID.literalModelObj.getLiteral("progress_global_title3", "messages"),
																					_x:m_btnCompare._x + m_btnCompare.width + BUTTON_OFFSET_X,
																					_y:BUTTON_START_Y,
																					color:0xFFFFFF, 
																					fontSize:BUTTON_LABEL_FONT_SIZE});
			m_btnAboutU.falseUpSkin		= "btnUp_ex";
			m_btnAboutU.falseOverSkin	= "btnOver_ex";
			m_btnAboutU.falseDownSkin	= "btnUp_ex";
			m_btnAboutU.setSize(BUTTON_WIDTH, BUTTON_HEIGHT);
			m_btnAboutU.setStyle("fontFamily", "Verdana");
			m_btnAboutU.setStyle("fontWeight", "bold");
			m_btnAboutU["parentAppObj"]= this;
																					
			// v6.5.6.4 can these be brought outside the initApp? Yes, for external buttons. No for old style. So duplicate 
			// I also have to change the syntax to reference objects...
			//function tableBtnClickedEventHandler(evt:Object):Void{
			var tableBtnClickedEventHandler:Object = new Object();
			tableBtnClickedEventHandler.click = function (evt:Object):Void{
				_global.myTrace("clicked tableBtn");
				//var me = this.parentAppObj;
				var me = evt.target.parentAppObj;
				me.m_viewCompare.SetVisible(false);
				me.m_viewNormal.SetVisible(true);
				me.m_viewAboutU.SetVisible(false);
				
				if(me.m_currentView != me.m_viewNormal){
					me.m_currentView= me.m_viewNormal;
					me.m_viewNormal.redraw();
				}
				
			}
			var comparsionBtnClickedEventHandler:Object = new Object();
			comparsionBtnClickedEventHandler.click = function(evt:Object):Void{
			//function comparsionBtnClickedEventHandler(evt:Object):Void{
				_global.myTrace("clicked compareBtn " + evt.target);
				//var me = this.parentAppObj;
				var me = evt.target.parentAppObj;
				me.m_viewNormal.SetVisible(false);
				me.m_viewAboutU.SetVisible(false);
				me.m_viewCompare.SetVisible(true);
				
				if(me.m_currentView != me.m_viewCompare){
					me.m_currentView= me.m_viewCompare;
					me.m_viewCompare.redraw();
				}
			}
			var aboutUBtnClickedEventHandler:Object = new Object();
			aboutUBtnClickedEventHandler.click = function(evt:Object):Void{
			//function aboutUBtnClickedEventHandler(evt:Object):Void{
				var me = evt.target.parentAppObj;
				me.m_viewCompare.SetVisible(false);
				me.m_viewNormal.SetVisible(false);
				me.m_viewAboutU.SetVisible(true);
				
				if(me.m_currentView != me.m_viewAboutU){
					me.m_currentView= me.m_viewAboutU;
					me.m_viewAboutU.redraw();
				}
			}
			m_btnTable.addEventListener("click", tableBtnClickedEventHandler);
			//_global.myTrace("adding click event to tableBtn " + m_btnTable);
			m_btnCompare.addEventListener("click", comparsionBtnClickedEventHandler);
			m_btnAboutU.addEventListener("click", aboutUBtnClickedEventHandler);
			
			// v6.5.5.6 Why do you update these globals?
			//GlobalVar.G_DISPLAY_WIDTH		= nAppWidth;
			//GlobalVar.G_DISPLAY_HEIGHT		= nAppHeight;
			GlobalVar.G_DISPLAY_START_Y		= 37;
			
			//_global.myTrace("GlobalVar.G_DISPLAY_WIDTH: " + GlobalVar.G_DISPLAY_WIDTH);
			//_global.myTrace("GlobalVar.G_DISPLAY_HEIGHT: " + GlobalVar.G_DISPLAY_HEIGHT);
		}
		
		// init globalvar
		// First set the width and height of the application
		// v6.5.5.6 You can't do this - if the running Flash is bigger, this shrinks it!
		// Can I just take it out - will the progress stay the same? Seems to.
		// But I still get shrinkage
		//parentClip.Stage.width = nAppWidth;
		//parentClip.Stage.height = nAppHeight;
		
		//readXML();
		
		//_global.myTrace("myXmlRecord: " + myXmlRecord);
		//_global.myTrace("everyOneXmlRecord: " + everyOneXmlRecord);
		// Read the XML
		var strTemp1= String(myXmlRecord);
		var strTemp2= String(everyOneXmlRecord);
		
		m_MyXml			= new XML(strTemp1);
		m_EveryoneXml	= new XML(strTemp2);
		
		_global.myParent	= _parent;
		_global.parentClip	= parentClip;
		_global.strLength	= strLength;
		// Init the three views
		initViews();
	}
	
	public function printPage(strHeader:String):Void{
		m_currentView.print(strHeader);
	}
	// v6.5.6.4 New SSS buttons are now outside the progress player
	public function displayCompare():Void {
		this.m_viewCompare.SetVisible(true);
		this.m_viewNormal.SetVisible(false);
		this.m_viewAboutU.SetVisible(false);
		
		if(this.m_currentView != this.m_viewCompare){
			this.m_currentView= this.m_viewCompare;
			this.m_viewCompare.redraw();
		}
	}
	public function displayScores():Void {
		this.m_viewNormal.SetVisible(true);
		this.m_viewCompare.SetVisible(false);
		this.m_viewAboutU.SetVisible(false);
			
		if(this.m_currentView != this.m_viewNormal){
			this.m_currentView= this.m_viewNormal;
			this.m_viewNormal.redraw();
		}
	}
	public function displayAnalysis():Void {
		_global.myTrace("analysis view button clicked");
		this.m_viewAboutU.SetVisible(true);
		this.m_viewCompare.SetVisible(false);
		this.m_viewNormal.SetVisible(false);
		
		if(this.m_currentView != this.m_viewAboutU){
			this.m_currentView= this.m_viewAboutU;
			this.m_viewAboutU.redraw();
		}
	}
	
	public function checkIfBothXmlLoaded():Boolean{
		return m_EveryoneXml.loaded && m_MyXml.loaded;
	}
		
	public function initViews():Void{
		// Inits the three views here
		m_viewNormal	= new NormalView(m_clipContainer, m_clipContainer.getNextHighestDepth());
		m_viewCompare	= new CompareView(m_clipContainer, m_clipContainer.getNextHighestDepth());
		m_viewAboutU	= new AboutUView(m_clipContainer, m_clipContainer.getNextHighestDepth());
		
		m_viewNormal.initView(m_MyXml, m_EveryoneXml);
		m_viewCompare.initView(m_MyXml, m_EveryoneXml);
		m_viewAboutU.initView(m_MyXml, m_EveryoneXml);
		
		m_viewNormal.SetVisible(true);
		m_viewCompare.SetVisible(false);
		m_viewAboutU.SetVisible(false);
		
		m_currentView= m_viewNormal;
		m_viewNormal.redraw();
	}
	
	public function strLength(strInput:String, strFontFamily:String, nFontSize:Number, bIsBold:Boolean):Number{
		var my_fmt:TextFormat = new TextFormat();
		with (my_fmt) {
			font 	= strFontFamily;
			bold 	= bIsBold;
			size	= nFontSize;
		}
		
		var metrics:Object = my_fmt.getTextExtent(strInput);
		
		return metrics.width + 10;
	}
}