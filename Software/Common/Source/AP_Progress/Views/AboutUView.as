import AP_Progress.Views.ViewBase;
import AP_Progress.Views.AboutUViewDataMgr;
import AP_Progress.GlobalVar;
import AP_Progress.CustomizeDevice;
import mx.controls.*;
import mx.data.types.Int;

class AP_Progress.Views.AboutUView extends ViewBase
{
	// const variable
	private var COMBO_BOX_WIDTH:Number				= 150;
	private var COMBO_BOX_OFFSET_X:Number 			= 10;
	
	// Make sure you change TITLE_HINT_TEXT_ARRAY and EXPLANATION_ARRAY if you change the words in DATA_COMBO_BOX_ITEM_ARRAY
	//private var DATA_COMBO_BOX_ITEM_ARRAY:Array			= new Array("score", "time");
	private var DATA_COMBO_BOX_ITEM_ARRAY:Array;
	private var TITLE_HINT_TEXT_ARRAY:Array;
	private var EXPLANATION_ARRAY:Array;
	private var NO_RECORD_BACKGROUND_FILE_NAME:String	= "analysis_background_ex";
	
	// v6.5.5.8
	static private var CP_PRODUCT_NAME:String = "clarity/pro";
	static private var CP2_PRODUCT_NAME:String = "clarity/cp2";
	static private var SSSV9_PRODUCT_NAME:String = "clarity/sssv9";
	
	// member variables
	static public var CLIP_NAME:String						= "AboutUView";
	private var m_mcPie:MovieClip;
	private var m_mcPieListener:Object;
	private var m_mcPieLoader:MovieClipLoader;
	private var m_DataMgr:AboutUViewDataMgr;
	private var m_DataComboBox:ComboBox;
	private var m_nMyDepth:Number;
	private var m_explainText:TextField;
	private var m_explainNoRecord:TextField;
	
	static private var s_strComboBoxIndex1:String			= "score";
	static private var s_strComboBoxIndex2:String			= "time";
	
	public function AboutUView(parent:MovieClip, numDepth:Number){
		super(parent, CLIP_NAME, numDepth);
		super.SetNoRecordBackgroundFilePath(NO_RECORD_BACKGROUND_FILE_NAME);
		
		m_DataMgr						= new AboutUViewDataMgr();
		
		DATA_COMBO_BOX_ITEM_ARRAY		= new Array(	_global.ORCHID.literalModelObj.getLiteral("progress_analysis_combo_box1", "messages"), 
														_global.ORCHID.literalModelObj.getLiteral("progress_analysis_combo_box2", "messages"));
	
		TITLE_HINT_TEXT_ARRAY		= new Array({	score:_global.ORCHID.literalModelObj.getLiteral("progress_analysis_score_title", "messages"), 
														time:_global.ORCHID.literalModelObj.getLiteral("progress_analysis_time_title", "messages")
													});
									
		EXPLANATION_ARRAY			= new Array({	score:_global.ORCHID.literalModelObj.getLiteral("progress_global_score", "messages") + " (%)", 
													time:_global.ORCHID.literalModelObj.getLiteral("progress_analysis_time_subtitle", "messages")
												});
	}
	
	public function initView(myXmlRec:XML, everyoneXmlRec:XML){
		super.initView(myXmlRec, everyoneXmlRec, TITLE_HINT_TEXT_ARRAY[0][s_strComboBoxIndex1]);
		
		// First analysis the data, change them into viewdata
		m_DataMgr.analysisData(myXmlRec);
							
		//////////////////////////////////////////////
		// Init ComboBoxs
		var aCaption:Array= m_DataMgr.getAllUnitName();
		var cbListener2:Object= new Object();
		
		cbListener2["parentViewObj"]= this;
		//cbListener2["parentViewObj"]= m_clipContainer;
		
		cbListener2.change= function(evt:Object){
			this.parentViewObj.showAmPie();
		}	
		var v1:Number= 0;
		
		// v6.5.6.4 New SSS realigned a bit
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
			_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
			var xOffset = 18;
			var yOffset = 18;
		} else {
			var xOffset = 8;
			var yOffset = 8;
		}
		m_DataComboBox		= m_clipContainer.createClassObject(ComboBox, "m_DataComboBox", 1000);
		m_DataComboBox.setSize(COMBO_BOX_WIDTH, m_DataComboBox.height);
		m_DataComboBox._x	= xOffset;
		m_DataComboBox._y	= GlobalVar.G_DISPLAY_START_Y + HEADER_HINT_HEIGHT + yOffset;
		
		for(v1=0; v1<DATA_COMBO_BOX_ITEM_ARRAY.length; ++v1){
			m_DataComboBox.addItem({data:v1, label:DATA_COMBO_BOX_ITEM_ARRAY[v1]});
		}
		m_DataComboBox.setStyle("borderStyle", "solid");
		m_DataComboBox.setStyle("themeColor", 0xffffff);
		m_DataComboBox.addEventListener("change", cbListener2);
		m_clipContainer._lockroot= true;
		m_DataComboBox.setStyle("fontFamily", "Verdana");
		
		// End Init ComboBoxs
		///////////////////////////////////////////////
		
		//////////////////////////////////////////////
		// Explain no record text
		// v6.5.5.8 CP changes coordinates a little
		var s_strCurProductName	= _global.ORCHID.root.licenceHolder.licenceNS.branding.toString().toLowerCase();
		switch(s_strCurProductName) {
			case CP_PRODUCT_NAME:
				var explainNoRecord_y = 472;
				break;
			case SSSV9_PRODUCT_NAME:
			case CP2_PRODUCT_NAME:
				var explainNoRecord_y = 456;
				break;
			default:
				explainNoRecord_y = 482;
		}			
		
		m_explainNoRecord	= m_clipContainer.createTextField(	"m_explainNoRecord", 
																m_clipContainer.getNextHighestDepth(), 
																xOffset, 
																explainNoRecord_y,
																400,
																30);
		var my_fmt:TextFormat = new TextFormat();
		with(my_fmt){
			font 	= "Verdana"; 
			size 	= 12;
			bold	= true;
		}
		
		var strIndex:String			= "";
		strIndex					= getStrIDWithCurrentComboBoxIndex();
		
		//m_explainNoRecord.text		= _global.ORCHID.literalModelObj.getLiteral("progress_analysis_warn_part1", "messages") + m_DataComboBox.text + " " + _global.ORCHID.literalModelObj.getLiteral("progress_analysis_warn_part2", "messages");
		m_explainNoRecord.text		= _global.ORCHID.literalModelObj.getLiteral("progress_analysis_warn_part1", "messages") + strIndex + " " + _global.ORCHID.literalModelObj.getLiteral("progress_analysis_warn_part2", "messages");
		m_explainNoRecord.setTextFormat(my_fmt);
		// End m_explainNoRecord
		
		// Init amPie stuff here
		m_mcPieListener= new Object(); 
		m_mcPieListener["parentViewObj"]= this;
		m_mcPieListener.onLoadComplete = function(target_mc:MovieClip):Void {
			target_mc.path = _global.ORCHID.paths.movie + "ampie/";
			
			// for testing, you may dynamic change the setting file and click "progress" button to see the result
			//target_mc.settings_file 					= _global.ORCHID.paths.movie + "ampie/ampie_settings.xml";
			
			switch(this.parentViewObj.m_DataComboBox.text){
				case this.parentViewObj.DATA_COMBO_BOX_ITEM_ARRAY[0]:	// score
					target_mc.chart_settings	= CustomizeDevice.GetXmlSetting(AboutUView.CLIP_NAME, "score");
					break;
				case this.parentViewObj.DATA_COMBO_BOX_ITEM_ARRAY[1]:	// time
					target_mc.chart_settings	= CustomizeDevice.GetXmlSetting(AboutUView.CLIP_NAME, "time");
					break;
			} 
			
			target_mc.chart_data = this.parentViewObj.m_DataMgr.givePieXmlDataOn(this.parentViewObj.m_ExerciseComboBox.text, this.parentViewObj.m_DataComboBox.text);
			
			// m_explainText
			this.parentViewObj.m_explainText.removeTextField();
			this.parentViewObj.m_explainText	= target_mc.createTextField(	"m_explainText", 
																				target_mc.getNextHighestDepth(), 
																				450, 
																				xOffset,
																				200,
																				30);
			var my_fmt:TextFormat = new TextFormat();
			with(my_fmt){
				font 	= "Verdana"; 
				size 	= 12;
				bold	= true;
			}
			
			this.parentViewObj.m_explainText.text		= this.parentViewObj.EXPLANATION_ARRAY[0][this.parentViewObj.m_DataComboBox.text];
			this.parentViewObj.m_explainText.setTextFormat(my_fmt);
			// end m_explainText
						
			// v6.5.5.8 Too wide and high, and also seems irrelevant. Why does this have to be here with a border?
			// The border is set in CustomizeDevice xml settings for about_u. I am setting width and height to have -20, but not sure it matters at all.
			target_mc.flash_width 				= GlobalVar.G_DISPLAY_WIDTH-20;
			target_mc.flash_height 				= GlobalVar.G_DISPLAY_HEIGHT - (GlobalVar.G_DISPLAY_START_Y + this.parentViewObj.HEADER_HINT_HEIGHT)-20;
			//target_mc.flash_width = 10;
			//target_mc.flash_height = 10;
			target_mc._x						= 0;
			target_mc._y						= GlobalVar.G_DISPLAY_START_Y + this.parentViewObj.HEADER_HINT_HEIGHT;
			//m_mcPieLoader.removeListener(m_mcPieListener);
		}
 		// v6.5.5.5 Stop stage.scaleMode becoming noScale
		m_mcPieListener.onLoadInit = function(target_mc:MovieClip):Void {
			// v6.5.5.5 On frame 2 of amcolumn.swf there is code that defaults scaleMode if you don't have a parameter 'scale' set.
			//target_mc.scale = 'showAll';
			target_mc.scale = Stage.scaleMode;
			target_mc.align = Stage.align;
			//_global.myTrace("ampie onLoadInit, stage.scaleMode=" + Stage.scaleMode);
		}

		m_mcPieLoader= new MovieClipLoader();
		m_mcPieLoader.addListener(m_mcPieListener);
				
		showAmPie();
		
	}
	
	private function getStrIDWithCurrentComboBoxIndex():String{
		return getStrIDWithComboBoxIndex(m_DataComboBox.selectedIndex);
	}
	
	private function getStrIDWithComboBoxIndex(nIndex:Number):String{
		var strID:String			= "";
		
		switch(nIndex)
		{
			case 0:
				strID	= s_strComboBoxIndex1;
				break;
			case 1:
				strID	= s_strComboBoxIndex2;
				break;
		}
		
		return strID;
	}
	
	private function showAmPie():Void{
		m_mcPie.removeMovieClip();
		
		var my_fmt:TextFormat = new TextFormat();
		with(my_fmt){
			font 	= "Verdana"; 
			size 	= 12;
			bold	= true;
		}
		
		var strIndex:String			= "";
		strIndex					= getStrIDWithCurrentComboBoxIndex(); 
		
		m_titleHint.text		= TITLE_HINT_TEXT_ARRAY[0][strIndex]; 
		m_titleHint.setTextFormat(my_fmt);
		
		my_fmt.size= 10;
		//m_explainNoRecord.text		= _global.ORCHID.literalModelObj.getLiteral("progress_analysis_warn_part1", "messages") + " " + m_DataComboBox.text + " " + _global.ORCHID.literalModelObj.getLiteral("progress_analysis_warn_part2", "messages");
		m_explainNoRecord.text		= _global.ORCHID.literalModelObj.getLiteral("progress_analysis_warn_part1", "messages") + " " + strIndex + " " + _global.ORCHID.literalModelObj.getLiteral("progress_analysis_warn_part2", "messages");
		m_explainNoRecord.setTextFormat(my_fmt);
		
		if(!haveData()){
			_global.myTrace("showAmPie(), dont haveData");
			showNoDataInterface();
			createAndShowNoRecordBackground();
		} else {
			_global.myTrace("showAmPie(), haveData");
			hiddenNoDataInterface();
						
			m_mcPie= m_clipContainer.createEmptyMovieClip("m_mcPie", m_clipContainer.getNextHighestDepth());
			m_mcPieLoader.loadClip(_global.ORCHID.paths.movie + "ampie/ampie.swf", m_mcPie);
		}
	}
	
	public function redraw():Void{
		if(!haveData()){
			return ;
		}
			
		super.redraw(m_mcPie);
	}
	
	public function print(strHeader:String):Void{
		if(!haveData()){
			_global.myTrace("chart not printed because there is no record");
			return ;
		}
		
		super.printing(m_mcPie, strHeader, 10, 10, 0.77, 0.77);
		_global.myTrace("super.print(m_mcPie, strHeader): " + strHeader);
	}
	
	public function haveData():Boolean{
		var bHaveRecord:Boolean	=  m_DataMgr.haveData();
		if(!bHaveRecord){
			_global.myTrace("You dont have anyr ecords");
			return false;
		}
			
		// Check if the student only have 0 records
		var strStudentRecord:String	= m_DataMgr.givePieXmlDataOn("", m_DataComboBox.text);
		var bResult					= (!checkIfOnlyGotZeroScore(strStudentRecord));
		
		//_global.myTrace("strStudentRecord: " + strStudentRecord);
		//_global.myTrace("bResult" + bResult);
		
		if (!bResult){
			_global.myTrace("You only got Zero Score!");
		}
		return bResult;
	}
	
	public function showNoDataInterface():Void{
		super.showNoDataMessgeBox();
		super.createAndShowNoRecordBackground();
		
		// only shown in About U View
		m_titleHint._visible	= true;
		m_DataComboBox._visible	= false;
	}
		
	private function hiddenNoDataInterface():Void{
		super.hiddenNoDataMessgeBox();
		super.hiddenAndReleaseNoRecordBackground();
		m_DataComboBox._visible	= true;
	}
	
	private function checkIfOnlyGotZeroScore(strStudentRecord:String):Boolean{
		//_global.myTrace("Student record in xml format: " + strStudentRecord);
		var index1:Number= 0;
		var index2:Number= 0;
		var strFristTarget:String 	= "<slice";
		var strSecondTarget:String 	= ">";
		var strThirdTarget:String	= "<";
		var nTarValue:Number		= 0;
		
		while((index1	= strStudentRecord.indexOf(strFristTarget, index2)) != -1){
			index2	= index1;
			index1	= strStudentRecord.indexOf(strSecondTarget, index2);
			index2	= strStudentRecord.indexOf(strThirdTarget, index1);
			
			nTarValue= Number(strStudentRecord.slice(index1+1, index2));
			//_global.myTrace("my tarvalue: " + nTarValue);
			
			if(nTarValue>0)
				return false;
		}
		return true;
	}
}