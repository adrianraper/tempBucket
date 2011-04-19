import AP_Progress.Views.ViewBase;
import AP_Progress.Views.CompareViewData;
import AP_Progress.GlobalVar;
import AP_Progress.CustomizeDevice;
import mx.controls.*;

class AP_Progress.Views.CompareView extends ViewBase
{
	// const variables 
	private var TITLE_HINT_TEXT:String					= "";
	private var EXPLANATION_TEXT:String					= "";
	private var NO_RECORD_BACKGROUND_FILE_NAME:String	= "compare_background_ex";
	
	// member variables
	static public var CLIP_NAME:String					= "CompareView";
	private var m_mcAmColumn:MovieClip;
	private var m_columnLoader:MovieClipLoader;
	private var m_explainText:TextField;
	
	// testing data
	private var m_compareData:CompareViewData;
	
	public function CompareView(parent:MovieClip, numDepth:Number)
	{
		super(parent, CLIP_NAME, numDepth);
		super.SetNoRecordBackgroundFilePath(NO_RECORD_BACKGROUND_FILE_NAME);
		
		TITLE_HINT_TEXT		= _global.ORCHID.literalModelObj.getLiteral("progress_compare_title", "messages");
		EXPLANATION_TEXT	= _global.ORCHID.literalModelObj.getLiteral("progress_global_score", "messages") + " (%)";
	
		m_compareData= new CompareViewData();
	}
	
	public function initView(myXmlRec:XML, everyoneXmlRec:XML){
		super.initView(myXmlRec, everyoneXmlRec, TITLE_HINT_TEXT);
		amChartXmlFileGenerator();
		
		var listener:Object = new Object();
		listener["parentViewObj"]= this;
		listener.onLoadComplete = function(target_mc:MovieClip):Void {
			
		// v6.5.6.4 New SSS realigned a bit
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
			var xOffset = 0;
			var yOffset = 10;
		} else {
			var xOffset = 0;
			var yOffset = 0;
		}
			target_mc.path 				= _global.ORCHID.paths.movie + "amcolumn/";
			//target_mc.settings_file 	= _global.ORCHID.paths.movie + "amcolumn/amcolumn_settings_AP.xml";
			//target_mc.chart_settings	= "<?xml version=\"1.0\" encoding=\"UTF - 8\"?><settings><type>column</type><data_type>xml</data_type><csv_separator></csv_separator><skip_rows></skip_rows><font>verdana</font><text_size>12</text_size><text_color></text_color><decimals_separator></decimals_separator><thousands_separator></thousands_separator><digits_after_decimal></digits_after_decimal><redraw>true</redraw><reload_data_interval></reload_data_interval><preloader_on_reload></preloader_on_reload><add_time_stamp></add_time_stamp><precision></precision><depth>30</depth><angle>30</angle>    <column><type>clustered</type><width>70</width><spacing>0</spacing><grow_time>3</grow_time><grow_effect></grow_effect><alpha>65</alpha><border_color></border_color><border_alpha></border_alpha><data_labels><![CDATA[]]></data_labels><data_labels_text_color></data_labels_text_color><data_labels_text_size></data_labels_text_size><data_labels_position></data_labels_position><balloon_text><![CDATA[]]></balloon_text><link_target></link_target><gradient></gradient></column>  <line><connect></connect><width></width><alpha></alpha><fill_alpha></fill_alpha><bullet></bullet><bullet_size></bullet_size><data_labels><![CDATA[]]></data_labels><data_labels_text_color></data_labels_text_color><data_labels_text_size></data_labels_text_size><balloon_text><![CDATA[]]></balloon_text><link_target></link_target></line>    <background><color>#FFFFFF</color><alpha></alpha><border_color>#000000</border_color><border_alpha>15</border_alpha><file></file></background>     <plot_area><color>#FFFFFF</color><alpha>10</alpha><border_color></border_color><border_alpha></border_alpha><margins><left>100</left><top>100</top><right>80</right><bottom>140</bottom></margins></plot_area>  <grid><category><color>#000000</color><alpha>20</alpha><dashed>false</dashed><dash_length>5</dash_length></category><value><color>#000000</color><alpha>20</alpha><dashed>false</dashed><dash_length>5</dash_length><approx_count>10</approx_count></value></grid>  <values><category><enabled>true</enabled><frequency>1</frequency><rotate>38</rotate><color></color><text_size></text_size></category><value><enabled>true</enabled><reverse></reverse><min>0</min><max></max><strict_min_max></strict_min_max><frequency>1</frequency><rotate></rotate><skip_first></skip_first><skip_last></skip_last><color></color><text_size></text_size><unit></unit><unit_position>right</unit_position><integers_only></integers_only></value></values>  <axes><category><color>#000000</color><alpha>100</alpha><width>1</width><tick_length>7</tick_length></category><value><color>#000000</color><alpha>100</alpha><width>1</width><tick_length>7</tick_length><logarithmic></logarithmic></value></axes><legend><enabled>true</enabled><x>400</x><y>30</y><width></width><max_columns></max_columns><color>#FFFFFF</color><alpha>0</alpha><border_color>#000000</border_color><border_alpha>0</border_alpha><text_color></text_color><text_size></text_size><spacing>5</spacing><margins>0</margins><key><size>12</size><border_color></border_color></key></legend>  <export_as_image><file></file><target></target><x></x><y></y><color></color><alpha></alpha><text_color></text_color><text_size></text_size></export_as_image>  <error_messages><enabled></enabled><x></x><y></y><color></color><alpha></alpha><text_color></text_color><text_size></text_size></error_messages>  <strings><no_data></no_data><export_as_image></export_as_image><collecting_data></collecting_data></strings>  <labels><label><x>500</x><y>10</y><rotate>false</rotate><width></width><align>left</align><text_color>5C5C5C</text_color><text_size>12</text_size><text><![CDATA[<b></b>]]></text></label></labels>  <graphs><graph gid=\"0\"><type>column</type><title>You</title><font>Verdana</font><color>F00000</color><alpha></alpha><data_labels><![CDATA[]]></data_labels><gradient_fill_colors></gradient_fill_colors><balloon_color>0x000000</balloon_color><balloon_alpha></balloon_alpha><balloon_text_color></balloon_text_color><balloon_text><![CDATA[Your average score in<p></p>{series}: {value}%]]></balloon_text><fill_alpha></fill_alpha><width></width><bullet></bullet><bullet_size></bullet_size><bullet_color></bullet_color><visible_in_legend></visible_in_legend></graph><graph gid=\"1\"><type>column</type><title>Other learners</title><font>Verdana</font><color>5C5C5C</color><alpha></alpha><data_labels><![CDATA[]]></data_labels><gradient_fill_colors></gradient_fill_colors><balloon_color>0x000000</balloon_color><balloon_alpha></balloon_alpha><balloon_text_color></balloon_text_color><balloon_text><![CDATA[Other learners' average score in<p></p>{series}: {value}%]]></balloon_text><fill_alpha></fill_alpha><width></width><bullet></bullet><bullet_size></bullet_size><bullet_color></bullet_color><visible_in_legend></visible_in_legend></graph></graphs></settings>";
			target_mc.chart_settings	= CustomizeDevice.GetXmlSetting(CompareView.CLIP_NAME);
			target_mc.chart_data		= this.parentViewObj.m_compareData.outputAmData();
			target_mc._x				= GlobalVar.G_DISPLAY_START_X + xOffset;
			target_mc._y				= GlobalVar.G_DISPLAY_START_Y + this.parentViewObj.HEADER_HINT_HEIGHT + yOffset;
			// v6.5.5.6 I can change these and the chart changes size
			target_mc.flash_width 		= GlobalVar.G_DISPLAY_WIDTH;
			target_mc.flash_height 		= GlobalVar.G_DISPLAY_HEIGHT - GlobalVar.G_DISPLAY_START_Y - this.parentViewObj.HEADER_HINT_HEIGHT;
			
			this.parentViewObj.m_explainText.removeTextField();
			this.parentViewObj.m_explainText	= target_mc.createTextField(	"m_explainText", 
																				target_mc.getNextHighestDepth(), 
																				10, 
																				50,
																				200,
																				30);
			
			this.parentViewObj.m_explainText.text		= this.parentViewObj.EXPLANATION_TEXT;
			
			var my_fmt:TextFormat = new TextFormat();
			with(my_fmt){
				font 	= "Verdana"; 
				size 	= 12;
				bold	= true;
			}
			this.parentViewObj.m_explainText.setTextFormat(my_fmt);
			//_global.myTrace("loaded amcolumn into stage.scaleMode=" + Stage.scaleMode)
		} 
		// v6.5.5.5 Stop stage.scaleMode becoming noScale
		listener.onLoadInit = function(target_mc:MovieClip):Void {
			// On frame 2 of amcolumn.swf there is code that defaults scaleMode if you don't have a parameter 'scale' set.
			//target_mc.scale = 'showAll';
			// Setting the parameter like this works fine in browser, but not in projector.
			// However the align bit does work in that it doesn't got off TL anymore.
			// OK, once I upgrade to the latest amcolumn swf it does work in the projector too.
			target_mc.scale = Stage.scaleMode;
			target_mc.align = Stage.align;
			_global.myTrace("amcolumn onLoadInit, stage.scaleMode=" + Stage.scaleMode);
		}
		
		m_columnLoader= new MovieClipLoader();
		m_columnLoader.addListener(listener);
		
		showAmColumn();
	}
		
	private function showAmColumn():Void{
		if(!haveData()){
			showNoDataInterface();
		} else {
			hiddenNoDataInterface();
			m_mcAmColumn= null;
			// v6.5.5.6 Does it make any difference to load into somewhere else? No. If I load into any active screen it still shrinks me.
			//m_mcAmColumn = _level0.buttonsHolder.MenuScreen.createEmptyMovieClip("m_mcAmColumn", 55487);
			m_mcAmColumn = m_clipContainer.createEmptyMovieClip("m_mcAmColumn", m_clipContainer.getNextHighestDepth());
			//_global.myTrace("load amcolumn root=" + _root._xscale + "," + _level0.buttonsHolder.MenuScreen._xscale);
			// v6.5.5.6 Is this the resizing culprit? Yes. Well, between amcolumn and ampie anyway.
			m_columnLoader.loadClip(_global.ORCHID.paths.movie + "amcolumn/amcolumn.swf", m_mcAmColumn);
		}
	}
	
	private function amChartXmlFileGenerator():Void
	{
		var aNode:XMLNode;
		
		var v1:Number= 0;
		var aUnitName:Array= new Array();
		
		var myTarChild:XMLNode		= m_myXmlRecCopy.firstChild.firstChild;
		var everyoneTarChild:XMLNode= m_everyoneXmlRecCopy.firstChild.firstChild;

		// v6.5.5.6 This puts my units in first, then adds units that I haven't done but that others have done.
		// So you can end up with strange ordering. They should be merged, but the XML doesn't contain anything 
		// that we can sort on (which is really only unitID);
		// Assume that myXML and everyoneXML are sorted correctly within themselves
		// So need to make this unit array composed of name AND unit number
		for(aNode= myTarChild; aNode != undefined; aNode= aNode.nextSibling){
			//aUnitName.push(aNode.attributes.caption);
			//_global.myTrace("add myXML unit " + aNode.attributes.caption);
			aUnitName.push({caption:aNode.attributes.caption, unit:aNode.attributes.unit});
		}
			
		var bValueFound:Boolean= false;
		for(aNode= everyoneTarChild; aNode != undefined; aNode= aNode.nextSibling){
			bValueFound= false;
			for(v1=0; v1<aUnitName.length; ++v1){
				//if(aUnitName[v1] == aNode.attributes.caption){
				if(aUnitName[v1].caption == aNode.attributes.caption){
					//_global.myTrace("merge everyone XML unit " + aNode.attributes.caption);
					bValueFound= true;
					break;
				}
			}

			// v6.5.5.6 Don't just add to the end, add at the correct slot based on unit number
			if(!bValueFound) {
				//aUnitName.push(aNode.attributes.caption);
				//var unitAdded=false;
				//_global.myTrace("check everyone XML unit " +aNode.attributes.unit +">" + aUnitName[aUnitName.length-1].unit);
				// If the unit you are adding is at the end, just go there, no need to loop
				if (Number(aNode.attributes.unit)<Number(aUnitName[aUnitName.length-1].unit)) {
					for (var v2=aUnitName.length-1;v2>=0; v2--) {
						//_global.myTrace("check against unit " +aUnitName[v2].unit +" - " + aUnitName[v2].caption);
						if (Number(aUnitName[v2].unit)<Number(aNode.attributes.unit)) {
							//_global.myTrace("insert everyone XML unit after " + v2 + "-" + aUnitName[v2].caption);
							// insert the new unit
							aUnitName.splice(v2+1,0,{caption:aNode.attributes.caption, unit:aNode.attributes.unit});
							//unitAdded = true;
							break;
						}
					}
				// Add it to the end if you haven't put it anywhere else
				} else {
					//_global.myTrace("add everyone XML unit at the end " + aNode.attributes.caption);
					aUnitName.push({caption:aNode.attributes.caption, unit:aNode.attributes.unit});
				}
			}
		}
		
		var nValueFound:Number= 0;
		for(v1=0; v1<aUnitName.length; ++v1){
			//_global.myTrace("compare name order=" + aUnitName[v1].caption);
			//m_compareData.addSeries(aUnitName[v1]);
			m_compareData.addSeries(aUnitName[v1].caption);
			nValueFound= 0;
			
			for(aNode= myTarChild; aNode != undefined; aNode= aNode.nextSibling){
				//if(aNode.attributes.caption==aUnitName[v1]){
				if(aNode.attributes.caption==aUnitName[v1].caption){
					nValueFound= Math.round(Number(aNode.attributes.score));
				}
			}
			//m_compareData.addGraphValue(aUnitName[v1], nValueFound);
			m_compareData.addGraphValue(aUnitName[v1].caption, nValueFound);
			
			nValueFound= 0;
			for(aNode= everyoneTarChild; aNode != undefined; aNode= aNode.nextSibling){
				//if(aNode.attributes.caption==aUnitName[v1]){
				if(aNode.attributes.caption==aUnitName[v1].caption){
					nValueFound= Number(aNode.attributes.score);
				}
			}
			//m_compareData.addGraphValue(aUnitName[v1], nValueFound);
			m_compareData.addGraphValue(aUnitName[v1].caption, nValueFound);
		}
	}
	
	public function redraw():Void{
		if(!haveData())
			return ;
			
		super.redraw(m_mcAmColumn);
		//showAmColumn();
	}
	
	public function print(strHeader:String):Void{
		if(!haveData()){
			_global.myTrace("chart not printed because there is no record");
			return ;
		}
		super.printing(m_mcAmColumn, strHeader, 10, 10, 0.77, 0.77);
		_global.myTrace("super.print(m_mcAmColumn, strHeader): " + strHeader);
	}
	
	public function haveData():Boolean{
		return m_compareData.haveData();
	}
	
	private function showNoDataInterface():Void{
		_global.myTrace("CompareView showNoDataMessgeBox()");
		super.showNoDataMessgeBox();
		super.createAndShowNoRecordBackground();
	}
	
	private function hiddenNoDataInterface():Void{
		super.hiddenAndReleaseNoRecordBackground();
	}
}