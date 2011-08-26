import AP_Progress.ProgressApp;
import AP_Progress.Views.AboutUView;
import AP_Progress.Views.CompareView;

class AP_Progress.CustomizeDevice
{
	static private var AP_PRODUCT_NAME:String	= "clarity/ap";
	// v6.5.4.3 No such title
	//static private var APP_PRODUCT_NAME:String	= "clarity/ap";
	static private var TB_PRODUCT_NAME:String	= "clarity/tb";
	// v6.5.4.3 New title
	static private var AR_PRODUCT_NAME:String	= "clarity/ar";
	static private var PEP_PRODUCT_NAME:String = "bc/pep";
	// v6.5.5.5
	static private var CP_PRODUCT_NAME:String = "clarity/pro";
	// v6.5.5.5
	static private var CP2_PRODUCT_NAME:String = "clarity/cp2";
	// v6.5.5.5
	static private var EFHS_PRODUCT_NAME:String = "sky/efhs";
	static private var AUK_PRODUCT_NAME:String = "york/auk";
	// v6.5.6.4
	static private var SSS_PRODUCT_NAME:String = "clarity/sss";
	static private var SSSV9_PRODUCT_NAME:String = "clarity/sssv9";
	
	static private var s_strCurProductName:String	= "";
	//static private var s_strCurProductName:String	= TB_PRODUCT_NAME;
		
	static private var NORMAL_VIEW_NAME:String	= AP_Progress.Views.NormalView.CLIP_NAME;
	static private var COMPARE_VIEW_NAME:String	= AP_Progress.Views.CompareView.CLIP_NAME;
	static private var ABOUT_U_VIEW_NAME:String	= AP_Progress.Views.AboutUView.CLIP_NAME;
	static private var PROGRESS_APP_NAME:String	= AP_Progress.ProgressApp.CLIP_NAME;
	
	static public function ChangeStyleColor(strViewName:String, strRequestType:String):Object
	{
		s_strCurProductName = _global.ORCHID.root.licenceHolder.licenceNS.branding.toString().toLowerCase();
		//_global.myTrace("Progress customize to " + s_strCurProductName);
		switch(strViewName)
		{
			case NORMAL_VIEW_NAME:						//		NORMAL_VIEW_NAME
				switch(s_strCurProductName)
				{
					case TB_PRODUCT_NAME:		// TB
						switch(strRequestType)
						{ 
							case "color":
								return 0x000000;
								break;
							case "backgroundColor":
								return 0xffffff;
								break; 
							case "themeColor":
								return 0xF7E6E6;
								break;
							case "alternatingRowColors":
								return [0xFFFFFF, 0xE5E5E5];
								break;
							case "selectionColor":
								return 0xf7e6e6;
								break;
							case "headerColor":
								return 0xF7E6E6;
								break;
						}
						break;
					// v6.5.4.3 New title
					case AR_PRODUCT_NAME:		// Active Reading
						switch(strRequestType)
						{ 
							case "color": // This means font colour
								return 0x000000;
								break;
							case "backgroundColor": // behind the grid, hardly shows
								return 0xFFFFFF;
								break; 
							case "themeColor": // means mouse over rows colour
								return 0xFFCC33;
								break;
							case "alternatingRowColors":
								return [0xFFFFFF, 0xFFEDB5];
								break;
							case "selectionColor": // means when you select a row - not really used
								return 0xFF0000;
								break;
							case "headerColor": // just for the grid
								//_global.myTrace("setting AR headerColor");
								return 0xFFCC33;
								break;
						}
						break;
					// v6.5.4.3 New title
					case CP_PRODUCT_NAME:		// Clear Pronunciation
						switch(strRequestType)
						{ 
							case "color": // This means font colour
								return 0x0F157A;
								break;
							case "backgroundColor": // behind the grid, hardly shows
								return 0xFFFFFF;
								break; 
							case "themeColor": // means mouse over rows colour
								return 0xFFCC33;
								break;
							case "alternatingRowColors":
								return [0xFFFFFF, 0xE4E6FC];
								break;
							case "selectionColor": // means when you select a row - not really used
								return 0x6D97C9;
								break;
							case "headerColor": // just for the grid
								//_global.myTrace("setting AR headerColor");
								return 0x6D97C9;
								break;
						}
						break;
					// v6.5.6.4 New SSS
					case SSSV9_PRODUCT_NAME:		
					case CP2_PRODUCT_NAME:		// Clear Pronunciation 2
						switch(strRequestType)
						{ 
							case "color": // This means font colour
								return 0x0F157A;
								break;
							case "backgroundColor": // behind the grid, hardly shows
								return 0xFFFFFF;
								break; 
							case "themeColor": // means mouse over rows colour
								return 0xFFCC33;
								break;
							case "alternatingRowColors":
								return [0xFFFFFF, 0xE4E6FC];
								break;
							case "selectionColor": // means when you select a row - not really used
								return 0x6D97C9;
								break;
							case "headerColor": // just for the grid
								//_global.myTrace("setting AR headerColor");
								return 0xD4D6D8;
								break;
						}
					// v6.5.5.5 New title
					case EFHS_PRODUCT_NAME:		// English for Hotel Staff
						switch(strRequestType)
						{ 
							case "color": // This means font colour
								return 0x0F157A;
								break;
							case "backgroundColor": // behind the grid, hardly shows
								return 0xFFFFFF;
								break; 
							case "themeColor": // means mouse over rows colour
								return 0xEDB3C6;
								break;
							case "alternatingRowColors":
								return [0xFFFFFF, 0xFCE6ED];
								break;
							case "selectionColor": // means when you select a row - not really used
								return 0xEDB3C6;
								break;
							case "headerColor": // just for the grid
								//_global.myTrace("setting AR headerColor");
								return 0x5F5F5F;
								break;
						}
						break;
					// v6.5.6.6
					case AUK_PRODUCT_NAME:		// AccessUK
						switch(strRequestType)
						{ 
							case "color": // This means font colour
								return 0x000000;
								break;
							case "backgroundColor": // behind the grid, hardly shows
								return 0xFFFFFF;
								break; 
							case "themeColor": // means mouse over rows colour
								return 0xD1D6B4;
								break;
							case "alternatingRowColors":
								return [0xFFFFFF, 0xE6E6E6];
								break;
							case "selectionColor": // means when you select a row - not really used
								return 0xD1D6B4;
								break;
							case "headerColor": // just for the grid
								//_global.myTrace("setting AR headerColor");
								return 0xD1D6B4;
								break;
						}
						break;
					// v6.5.4.3 Defaults to Author Plus colours and style
					case AP_PRODUCT_NAME:		// AP
					//case APP_PRODUCT_NAME:		// APP
					default:
						switch(strRequestType)
						{
							case "color":
								return 0x0F157A;
								break;
							case "backgroundColor":
								return 0xffffff;
								break;
							case "themeColor":
								return 0xFFDE2C;
								break;
							case "alternatingRowColors":
								return [0xFFFFFF, 0xE4E6FC];
								break;
							case "selectionColor":
								return 0xFFDE2C;
								break;
							case "headerColor":
								return 0xFFDE2C;
								break;
						}
						break;
				}
				break;
			case COMPARE_VIEW_NAME:						//		COMPARE_VIEW_NAME
				break;
			case ABOUT_U_VIEW_NAME:						//		ABOUT_U_VIEW_NAME
				break;
			case PROGRESS_APP_NAME:						//		PROGRESS_APP_NAME
				switch(s_strCurProductName)
				{
					case TB_PRODUCT_NAME:		// TB
						switch(strRequestType)
						{
							case "grBtnBg_colors":
								return [0x000000, 0x888888];
								break;
						}
						break;
					// v6.5.4.3 New title
					case AR_PRODUCT_NAME:		// Active Reading
						switch(strRequestType)
						{
							case "grBtnBg_colors": // These are the colours used in the alternating gradient of the header behind the main buttons
								return [0xA11015, 0xA11015];
								break;
						}
						break;
					// v6.5.5.5
					case CP_PRODUCT_NAME:		// Clear Pronunciation
						switch(strRequestType)
						{
							case "grBtnBg_colors": // These are the colours used in the alternating gradient of the header behind the main buttons
								return [0x346D73, 0x346D73];
								break;
						}
						break;
					// v6.5.6.4 New SSS
					case SSSV9_PRODUCT_NAME:
					case CP2_PRODUCT_NAME:		// Clear Pronunciation 2
						switch(strRequestType)
						{
							case "grBtnBg_colors": // These are the colours used in the alternating gradient of the header behind the main buttons
								return [0xD4D6D8, 0xD4D6D8];
								break;
						}
						break;
					// v6.5.5.5
					case EFHS_PRODUCT_NAME:		// English for Hotel Staff
						switch(strRequestType)
						{
							case "grBtnBg_colors": // These are the colours used in the alternating gradient of the header behind the main buttons
								return [0xAD002C, 0xAD002C];
								break;
						}
						break;
					// v6.5.6.6
					case AUK_PRODUCT_NAME:		// Access UK
						switch(strRequestType)
						{
							case "grBtnBg_colors": // These are the colours used in the alternating gradient of the header behind the main buttons
								return [0x383838, 0x383838];
								break;
						}
						break;
					case AP_PRODUCT_NAME:		// AP
					//case APP_PRODUCT_NAME:		// APP
					default:
						switch(strRequestType)
						{
							case "grBtnBg_colors":
								return [0xAB0D0D, 0xAB0D0D];
								break;
						}
						break;
				}
				break;
		}
	}
	
	static public function SetCurProductName(strCurProductName:String):Void
	{
		s_strCurProductName	= strCurProductName;
	}
	
	static public function GetXmlSetting(strViewName:String, strRequestType:String):String
	{
		s_strCurProductName	= _global.ORCHID.root.licenceHolder.licenceNS.branding.toString().toLowerCase();
		
		switch(strViewName)
		{
			case NORMAL_VIEW_NAME:
				break;
			case COMPARE_VIEW_NAME:
				switch(s_strCurProductName)
				{
					case TB_PRODUCT_NAME:
						var compareYourChartColour = "#F00000";
						var compareOthersChartColour = "#5C5C5C";
						// v6.5.4.3 This is a very long string, originally read from an external xml file - but this is too open to accidental change
						// But here it is too difficult to edit! At least try to take out the bits that do or could change and break it into sections.
						// See below
						//return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><settings><type>column</type><data_type>xml</data_type><csv_separator/><skip_rows/><font>verdana</font><text_size>12</text_size><text_color/><decimals_separator/><thousands_separator/><digits_after_decimal/><redraw>false</redraw><reload_data_interval/><preloader_on_reload/><add_time_stamp/><precision/><depth>30</depth><angle>30</angle>    <column><type>clustered</type><width>70</width><spacing>0</spacing><grow_time>3</grow_time><grow_effect/><alpha>65</alpha><border_color/><border_alpha/><data_labels><![CDATA[]]></data_labels><data_labels_text_color/><data_labels_text_size/><data_labels_position/><balloon_text><![CDATA[]]></balloon_text><link_target/><gradient/></column>  <line><connect/><width/><alpha/><fill_alpha/><bullet/><bullet_size/><data_labels><![CDATA[]]></data_labels><data_labels_text_color/><data_labels_text_size/><balloon_text><![CDATA[]]></balloon_text><link_target/></line>    <background><color>#FFFFFF</color><alpha/><border_color>#000000</border_color><border_alpha>15</border_alpha><file/></background>     <plot_area><color>#FFFFFF</color><alpha>10</alpha><border_color/><border_alpha/><margins><left>100</left><top>100</top><right>80</right><bottom>140</bottom></margins></plot_area>  <grid><category><color>#000000</color><alpha>20</alpha><dashed>false</dashed><dash_length>5</dash_length></category><value><color>#000000</color><alpha>20</alpha><dashed>false</dashed><dash_length>5</dash_length><approx_count>10</approx_count></value></grid>  <values><category><enabled>true</enabled><frequency>1</frequency><rotate>38</rotate><color/><text_size/></category><value><enabled>true</enabled><reverse/><min>0</min><max/><strict_min_max/><frequency>1</frequency><rotate/><skip_first/><skip_last/><color/><text_size/><unit/><unit_position>right</unit_position><integers_only/></value></values>  <axes><category><color>#000000</color><alpha>100</alpha><width>1</width><tick_length>7</tick_length></category><value><color>#000000</color><alpha>100</alpha><width>1</width><tick_length>7</tick_length><logarithmic/></value></axes>  <balloon><enabled>true</enabled><color/><alpha>100</alpha><text_color/><text_size>12</text_size></balloon>    <legend><enabled>true</enabled><x>20</x><y>12</y><width/><max_columns/><color>#FFFFFF</color><alpha>0</alpha><border_color>#000000</border_color><border_alpha>0</border_alpha><text_color/><text_size>12</text_size><spacing/><margins>0</margins><key><size>12</size><border_color/></key></legend>  <export_as_image><file/><target/><x/><y/><color/><alpha/><text_color/><text_size/></export_as_image>  <error_messages><enabled/><x/><y/><color/><alpha/><text_color/><text_size/></error_messages>  <strings><no_data/><export_as_image/><collecting_data/></strings>  <labels><label><x>500</x><y>10</y><rotate>false</rotate><width/><align>left</align><text_color>5C5C5C</text_color><text_size>20</text_size><text><![CDATA[<b></b>]]></text></label></labels>  <graphs><graph gid=\"0\"><type>column</type>                                                        <title>" + _global.ORCHID.literalModelObj.getLiteral("progress_compare_label1", "messages") + "</title><color>F00000</color><alpha/><data_labels><![CDATA[]]></data_labels><gradient_fill_colors/><balloon_color>0x000000</balloon_color><balloon_alpha/><balloon_text_color/><balloon_text><![CDATA[Your average score in {series}: {value}%]]></balloon_text><fill_alpha/><width/><bullet/><bullet_size/><bullet_color/><visible_in_legend/></graph><graph gid=\"1\"><type>column</type>                                                        <title>" + _global.ORCHID.literalModelObj.getLiteral("progress_compare_label2", "messages") + "</title><color>5C5C5C</color><alpha/><data_labels><![CDATA[]]></data_labels><gradient_fill_colors/><balloon_color>0x000000</balloon_color><balloon_alpha/><balloon_text_color/><balloon_text><![CDATA[Other learners average score in {series}: {value}%]]></balloon_text><fill_alpha/><width/><bullet/><bullet_size/><bullet_color/><visible_in_legend/></graph></graphs></settings>";
						break;
					case AR_PRODUCT_NAME:	// Active Reading
						var compareYourChartColour = "#A11015"; // colours for the bars on the compare chart
						var compareOthersChartColour = "#FFCC33";
						break;
					case CP_PRODUCT_NAME:	// Clear Pronunciation
						var compareYourChartColour = "#FFD25E"; // colours for the bars on the compare chart
						var compareOthersChartColour = "#305455";
						break;
					// v6.5.6.4 New SSS
					case SSSV9_PRODUCT_NAME:	
						var compareYourChartColour = "#F5A719"; // colours for the bars on the compare chart
						var compareOthersChartColour = "#7074D6";
						break;
					// v6.5.6.4 CP2
					case CP2_PRODUCT_NAME:	// Clear Pronunciation 2
						var compareYourChartColour = "#535DB8"; // colours for the bars on the compare chart
						var compareOthersChartColour = "#B4C443";
						break;
					case AP_PRODUCT_NAME:
					//case APP_PRODUCT_NAME:		// APP
					default:
						var compareYourChartColour = "#FFDE2C";
						var compareOthersChartColour = "#0F157A";
						//return "<?xml version=\"1.0\" encoding=\"UTF - 8\"?><settings><type>column</type><data_type>xml</data_type><csv_separator/><skip_rows/><font>verdana</font><text_size>12</text_size><text_color/><decimals_separator/><thousands_separator/><digits_after_decimal/><redraw>false</redraw><reload_data_interval/><preloader_on_reload/><add_time_stamp/><precision/><depth>30</depth><angle>30</angle>    <column><type>clustered</type><width>70</width><spacing>0</spacing><grow_time>3</grow_time><grow_effect/><alpha>65</alpha><border_color/><border_alpha/><data_labels><![CDATA[]]></data_labels><data_labels_text_color/><data_labels_text_size/><data_labels_position/><balloon_text><![CDATA[]]></balloon_text><link_target/><gradient/></column>  <line><connect/><width/><alpha/><fill_alpha/><bullet/><bullet_size/><data_labels><![CDATA[]]></data_labels><data_labels_text_color/><data_labels_text_size/><balloon_text><![CDATA[]]></balloon_text><link_target/></line>    <background><color>#FFFFFF</color><alpha/><border_color>#000000</border_color><border_alpha>15</border_alpha><file/></background>     <plot_area><color>#FFFFFF</color><alpha>10</alpha><border_color/><border_alpha/><margins><left>100</left><top>100</top><right>80</right><bottom>140</bottom></margins></plot_area>  <grid><category><color>#000000</color><alpha>20</alpha><dashed>false</dashed><dash_length>5</dash_length></category><value><color>#000000</color><alpha>20</alpha><dashed>false</dashed><dash_length>5</dash_length><approx_count>10</approx_count></value></grid>  <values><category><enabled>true</enabled><frequency>1</frequency><rotate>38</rotate><color/><text_size/></category><value><enabled>true</enabled><reverse/><min>0</min><max/><strict_min_max/><frequency>1</frequency><rotate/><skip_first/><skip_last/><color/><text_size/><unit/><unit_position>right</unit_position><integers_only/></value></values>  <axes><category><color>#000000</color><alpha>100</alpha><width>1</width><tick_length>7</tick_length></category><value><color>#000000</color><alpha>100</alpha><width>1</width><tick_length>7</tick_length><logarithmic/></value></axes>  <balloon><enabled>true</enabled><color/><alpha>100</alpha><text_color/><text_size>12</text_size></balloon>    <legend><enabled>true</enabled><x>20</x><y>12</y><width/><max_columns/><color>#FFFFFF</color><alpha>0</alpha><border_color>#000000</border_color><border_alpha>0</border_alpha><text_color/><text_size>12</text_size><spacing/><margins>0</margins><key><size>12</size><border_color/></key></legend>  <export_as_image><file/><target/><x/><y/><color/><alpha/><text_color/><text_size/></export_as_image>  <error_messages><enabled/><x/><y/><color/><alpha/><text_color/><text_size/></error_messages>  <strings><no_data/><export_as_image/><collecting_data/></strings>  <labels><label><x>500</x><y>10</y><rotate>false</rotate><width/><align>left</align><text_color>5C5C5C</text_color><text_size>20</text_size><text><![CDATA[<b></b>]]></text></label></labels>  <graphs><graph gid=\"0\"><type>column</type>                                                        <title>" + _global.ORCHID.literalModelObj.getLiteral("progress_compare_label1", "messages") + "</title><color>#FFDE2C</color><alpha/><data_labels><![CDATA[]]></data_labels><gradient_fill_colors/><balloon_color>0x000000</balloon_color><balloon_alpha/><balloon_text_color/><balloon_text><![CDATA[Your average score in {series}: {value}%]]></balloon_text><fill_alpha/><width/><bullet/><bullet_size/><bullet_color/><visible_in_legend/></graph><graph gid=\"1\"><type>column</type>                                                        <title>" + _global.ORCHID.literalModelObj.getLiteral("progress_compare_label2", "messages") + "</title><color>#0F157A</color><alpha/><data_labels><![CDATA[]]></data_labels><gradient_fill_colors/><balloon_color>0x000000</balloon_color><balloon_alpha/><balloon_text_color/><balloon_text><![CDATA[Other learners average score in {series}: {value}%]]></balloon_text><fill_alpha/><width/><bullet/><bullet_size/><bullet_color/><visible_in_legend/></graph></graphs></settings>";
				}
				var compareYourChartTitle = _global.ORCHID.literalModelObj.getLiteral("progress_compare_label1", "messages");
				var compareOthersChartTitle = _global.ORCHID.literalModelObj.getLiteral("progress_compare_label2", "messages");
				
				// v6.5.5.6 Is there anything in here that is resizing my movie?
				// try <settings><redraw>true</redraw></settings> - no that didn't work, but it might be a good idea to leave it anyway
				var xmlHeader = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><settings>";
				var xmlFooter = "</settings>";
				var settingsGeneral = "<type>column</type><data_type>xml</data_type><csv_separator/><skip_rows/><font>verdana</font><text_size>12</text_size><text_color/><decimals_separator/><thousands_separator/><digits_after_decimal/><redraw>true</redraw><reload_data_interval/><preloader_on_reload/><add_time_stamp/><precision/><depth>30</depth><angle>30</angle>";
				var settingsColumn = "<column><type>clustered</type><width>70</width><spacing>0</spacing><grow_time>3</grow_time><grow_effect/><alpha>65</alpha><border_color/><border_alpha/><data_labels><![CDATA[]]></data_labels><data_labels_text_color/><data_labels_text_size/><data_labels_position/><balloon_text><![CDATA[]]></balloon_text><link_target/><gradient/></column>";
				var settingsLine = "<line><connect/><width/><alpha/><fill_alpha/><bullet/><bullet_size/><data_labels><![CDATA[]]></data_labels><data_labels_text_color/><data_labels_text_size/><balloon_text><![CDATA[]]></balloon_text><link_target/></line>";
				var settingsBackground = "<background><color>#FFFFFF</color><alpha/><border_color>#000000</border_color><border_alpha>0</border_alpha><file/></background>";
				var settingsPlotArea = "<plot_area><color>#FFFFFF</color><alpha>10</alpha><border_color>#FFFFFF</border_color><border_alpha/><margins><left>100</left><top>100</top><right>80</right><bottom>140</bottom></margins></plot_area>";
				var settingsGrid = "<grid><category><color>#000000</color><alpha>20</alpha><dashed>false</dashed><dash_length>5</dash_length></category><value><color>#000000</color><alpha>20</alpha><dashed>false</dashed><dash_length>5</dash_length><approx_count>10</approx_count></value></grid>";
				var settingsValues = "<values><category><enabled>true</enabled><frequency>1</frequency><rotate>38</rotate><color/><text_size/></category><value><enabled>true</enabled><reverse/><min>0</min><max/><strict_min_max/><frequency>1</frequency><rotate/><skip_first/><skip_last/><color/><text_size/><unit/><unit_position>right</unit_position><integers_only/></value></values>";
				var settingsAxes = "<axes><category><color>#000000</color><alpha>100</alpha><width>1</width><tick_length>7</tick_length></category><value><color>#000000</color><alpha>100</alpha><width>1</width><tick_length>7</tick_length><logarithmic/></value></axes>";
				var settingsBalloon = "<balloon><enabled>true</enabled><color/><alpha>100</alpha><text_color/><text_size>12</text_size></balloon>";
				var settingsLegend = "<legend><enabled>true</enabled><x>20</x><y>12</y><width/><max_columns/><color>#FFFFFF</color><alpha>0</alpha><border_color>#000000</border_color><border_alpha>0</border_alpha><text_color/><text_size>12</text_size><spacing/><margins>0</margins><key><size>12</size><border_color/></key></legend>";
				var settingsExportAsImage = "<export_as_image><file/><target/><x/><y/><color/><alpha/><text_color/><text_size/></export_as_image>";
				var settingsErrorMessages = "<error_messages><enabled/><x/><y/><color/><alpha/><text_color/><text_size/></error_messages>";
				var settingsStrings = "<strings><no_data/><export_as_image/><collecting_data/></strings>";
				var settingsLabels = "<labels><label><x>500</x><y>10</y><rotate>false</rotate><width/><align>left</align><text_color>#5C5C5C</text_color><text_size>20</text_size><text><![CDATA[<b></b>]]></text></label></labels>";
				var graphsHeader = "<graphs>";
				var graphsFooter = "</graphs>";
				var graphsCompareYou = "<graph gid=\"0\"><type>column</type><title>" +  compareYourChartTitle + "</title><color>" + compareYourChartColour + "</color><alpha/><data_labels><![CDATA[]]></data_labels><gradient_fill_colors/><balloon_color>0x000000</balloon_color><balloon_alpha/><balloon_text_color/><balloon_text><![CDATA[Your average score in {series}: {value}%]]></balloon_text><fill_alpha/><width/><bullet/><bullet_size/><bullet_color/><visible_in_legend/></graph>";
				var graphsCompareOthers = "<graph gid=\"1\"><type>column</type><title>" +  compareOthersChartTitle + "</title><color>" + compareOthersChartColour + "</color><alpha/><data_labels><![CDATA[]]></data_labels><gradient_fill_colors/><balloon_color>0x000000</balloon_color><balloon_alpha/><balloon_text_color/><balloon_text><![CDATA[Other learners average score in {series}: {value}%]]></balloon_text><fill_alpha/><width/><bullet/><bullet_size/><bullet_color/><visible_in_legend/></graph>";
				return xmlHeader + settingsGeneral + settingsColumn + settingsLine
								+ settingsBackground 
								+ settingsPlotArea 
								+ settingsGrid
								+ settingsValues + settingsAxes + settingsBalloon
								+ settingsLegend + settingsExportAsImage + settingsErrorMessages
								+ settingsStrings + settingsLabels + 
								+ graphsHeader + graphsCompareYou + graphsCompareOthers + graphsFooter
								+ xmlFooter;
				break;
			case ABOUT_U_VIEW_NAME:
				switch(strRequestType)
				{
					case "score":
						// v6.5.4.3 Remove the space in the pie callouts before the %
						// v6.5.4.3 This is a very long string, originally read from an external xml file - but this is too open to accidental change
						// But here it is too difficult to edit! At least try to take out the bits that do or could change and break it into sections.
						// See above
						//return "<?xml version=\"1.0\" encoding=\"UTF - 8\"?><settings><data_type>xml</data_type><csv_separator>;</csv_separator><skip_rows>1</skip_rows><font>Verdana</font><text_size>12</text_size><text_color>#000000</text_color><decimals_separator>.</decimals_separator><thousands_separator>,</thousands_separator><digits_after_decimal/><reload_data_interval/><preloader_on_reload/><redraw>false</redraw><add_time_stamp>false</add_time_stamp><precision>0</precision><exclude_invisible/>                                                                <pie><x>335</x><y>240</y><radius>100</radius><inner_radius>40</inner_radius><height>20</height><angle>20</angle><outline_color>#F0F0F0</outline_color><outline_alpha>#FFF0F0</outline_alpha><base_color/><brightness_step/><colors>0xFF0F00,0xFF99CC,0xaaF0F1,0xFCD202,0xF8FF01,0xB0DE09,0x04D215,0x0D8ECF,0x0D52D1,0x2A0CD0,0x8A0CCF,0xCD0D74</colors><link_target/><alpha>80</alpha></pie>  <animation><start_time>2</start_time><start_effect>strong</start_effect><start_radius/><start_alpha>0</start_alpha><pull_out_on_click/><pull_out_time>1</pull_out_time><pull_out_effect>Bounce</pull_out_effect><pull_out_radius>25</pull_out_radius><pull_out_only_one/></animation>  <data_labels><radius>60</radius><text_color/><text_size/><max_width>300</max_width><show><![CDATA[{title}: {value} %]]></show><show_lines/><line_color/><line_alpha/><hide_labels_percent>2</hide_labels_percent></data_labels><group><percent/><color/><title/><url/><description/><pull_out/></group><background><color/><alpha/><border_color>#000000</border_color><border_alpha>15</border_alpha><file/></background><legend><enabled>false</enabled><x>90</x><y>330</y><width>500</width><color>#FFFFFF</color><max_columns>2</max_columns><alpha>0</alpha><border_color>#000000</border_color><border_alpha>20</border_alpha><text_color/><text_size>10</text_size><spacing>8</spacing><margins>20</margins><key><size>16</size><border_color/></key><values><enabled>true</enabled><width>120</width><text><![CDATA[: {value}]]></text></values></legend>  <export_as_image><file/><target/><x/><y/><color/><alpha/><text_color/><text_size/></export_as_image>  <error_messages><enabled/><x/><y/><color/><alpha/><text_color/><text_size/></error_messages>  <strings><no_data/><export_as_image/><collecting_data/></strings>  <labels><label><x>500</x><y>10</y><rotate>false</rotate><width/><align>left</align><text_color>5C5C5C</text_color><text_size>20</text_size><text><![CDATA[<b></b>]]></text></label></labels></settings>";
						//return "<?xml version=\"1.0\" encoding=\"UTF - 8\"?><settings><data_type>xml</data_type><csv_separator>;</csv_separator><skip_rows>1</skip_rows><font>Verdana</font><text_size>12</text_size><text_color>#000000</text_color><decimals_separator>.</decimals_separator><thousands_separator>,</thousands_separator><digits_after_decimal/><reload_data_interval/><preloader_on_reload/><redraw>false</redraw><add_time_stamp>false</add_time_stamp><precision>0</precision><exclude_invisible/>                                                                <pie><x>335</x><y>240</y><radius>100</radius><inner_radius>40</inner_radius><height>20</height><angle>20</angle><outline_color>#F0F0F0</outline_color><outline_alpha>#FFF0F0</outline_alpha><base_color/><brightness_step/><colors>0xFF0F00,0xFF99CC,0xaaF0F1,0xFCD202,0xF8FF01,0xB0DE09,0x04D215,0x0D8ECF,0x0D52D1,0x2A0CD0,0x8A0CCF,0xCD0D74</colors><link_target/><alpha>80</alpha></pie>  <animation><start_time>2</start_time><start_effect>strong</start_effect><start_radius/><start_alpha>0</start_alpha><pull_out_on_click/><pull_out_time>1</pull_out_time><pull_out_effect>Bounce</pull_out_effect><pull_out_radius>25</pull_out_radius><pull_out_only_one/></animation>  <data_labels><radius>60</radius><text_color/><text_size/><max_width>300</max_width><show><![CDATA[{title}: {value}%]]></show><show_lines/><line_color/><line_alpha/><hide_labels_percent>2</hide_labels_percent></data_labels><group><percent/><color/><title/><url/><description/><pull_out/></group><background><color/><alpha/><border_color>#000000</border_color><border_alpha>15</border_alpha><file/></background><legend><enabled>false</enabled><x>90</x><y>330</y><width>500</width><color>#FFFFFF</color><max_columns>2</max_columns><alpha>0</alpha><border_color>#000000</border_color><border_alpha>20</border_alpha><text_color/><text_size>10</text_size><spacing>8</spacing><margins>20</margins><key><size>16</size><border_color/></key><values><enabled>true</enabled><width>120</width><text><![CDATA[: {value}]]></text></values></legend>  <export_as_image><file/><target/><x/><y/><color/><alpha/><text_color/><text_size/></export_as_image>  <error_messages><enabled/><x/><y/><color/><alpha/><text_color/><text_size/></error_messages>  <strings><no_data/><export_as_image/><collecting_data/></strings>  <labels><label><x>500</x><y>10</y><rotate>false</rotate><width/><align>left</align><text_color>5C5C5C</text_color><text_size>20</text_size><text><![CDATA[<b></b>]]></text></label></labels></settings>";
						var sliceCaption = "{title}: {value}%";
						break;
					case "time":
					default:
						// v6.5.4.3 Try removing the whole min(s) part to reduce overlap
						//return "<?xml version=\"1.0\" encoding=\"UTF - 8\"?><settings><data_type>xml</data_type><csv_separator>;</csv_separator><skip_rows>1</skip_rows><font>Verdana</font><text_size>12</text_size><text_color>#000000</text_color><decimals_separator>.</decimals_separator><thousands_separator>,</thousands_separator><digits_after_decimal/><reload_data_interval/><preloader_on_reload/><redraw>false</redraw><add_time_stamp>false</add_time_stamp><precision>0</precision><exclude_invisible/>                                                                <pie><x>335</x><y>240</y><radius>100</radius><inner_radius>40</inner_radius><height>20</height><angle>20</angle><outline_color>#F0F0F0</outline_color><outline_alpha>#FFF0F0</outline_alpha><base_color/><brightness_step/><colors>0xFF0F00,0xFF99CC,0xaaF0F1,0xFCD202,0xF8FF01,0xB0DE09,0x04D215,0x0D8ECF,0x0D52D1,0x2A0CD0,0x8A0CCF,0xCD0D74</colors><link_target/><alpha>80</alpha></pie>  <animation><start_time>2</start_time><start_effect>strong</start_effect><start_radius/><start_alpha>0</start_alpha><pull_out_on_click/><pull_out_time>1</pull_out_time><pull_out_effect>Bounce</pull_out_effect><pull_out_radius>25</pull_out_radius><pull_out_only_one/></animation>  <data_labels><radius>60</radius><text_color/><text_size/><max_width>300</max_width><show><![CDATA[{title}: {value} min(s)]]></show><show_lines/><line_color/><line_alpha/><hide_labels_percent>2</hide_labels_percent></data_labels><group><percent/><color/><title/><url/><description/><pull_out/></group><background><color/><alpha/><border_color>#000000</border_color><border_alpha>15</border_alpha><file/></background><legend><enabled>false</enabled><x>90</x><y>330</y><width>500</width><color>#FFFFFF</color><max_columns>2</max_columns><alpha>0</alpha><border_color>#000000</border_color><border_alpha>20</border_alpha><text_color/><text_size>10</text_size><spacing>8</spacing><margins>20</margins><key><size>16</size><border_color/></key><values><enabled>true</enabled><width>120</width><text><![CDATA[: {value}]]></text></values></legend>  <export_as_image><file/><target/><x/><y/><color/><alpha/><text_color/><text_size/></export_as_image>  <error_messages><enabled/><x/><y/><color/><alpha/><text_color/><text_size/></error_messages>  <strings><no_data/><export_as_image/><collecting_data/></strings>  <labels><label><x>500</x><y>10</y><rotate>false</rotate><width/><align>left</align><text_color>5C5C5C</text_color><text_size>20</text_size><text><![CDATA[<b></b>]]></text></label></labels></settings>";
						//return "<?xml version=\"1.0\" encoding=\"UTF - 8\"?><settings><data_type>xml</data_type><csv_separator>;</csv_separator><skip_rows>1</skip_rows><font>Verdana</font><text_size>12</text_size><text_color>#000000</text_color><decimals_separator>.</decimals_separator><thousands_separator>,</thousands_separator><digits_after_decimal/><reload_data_interval/><preloader_on_reload/><redraw>false</redraw><add_time_stamp>false</add_time_stamp><precision>0</precision><exclude_invisible/>                                                                <pie><x>335</x><y>240</y><radius>100</radius><inner_radius>40</inner_radius><height>20</height><angle>20</angle><outline_color>#F0F0F0</outline_color><outline_alpha>#FFF0F0</outline_alpha><base_color/><brightness_step/><colors>0xFF0F00,0xFF99CC,0xaaF0F1,0xFCD202,0xF8FF01,0xB0DE09,0x04D215,0x0D8ECF,0x0D52D1,0x2A0CD0,0x8A0CCF,0xCD0D74</colors><link_target/><alpha>80</alpha></pie>  <animation><start_time>2</start_time><start_effect>strong</start_effect><start_radius/><start_alpha>0</start_alpha><pull_out_on_click/><pull_out_time>1</pull_out_time><pull_out_effect>Bounce</pull_out_effect><pull_out_radius>25</pull_out_radius><pull_out_only_one/></animation>  <data_labels><radius>60</radius><text_color/><text_size/><max_width>300</max_width><show><![CDATA[{title}: {value}]]></show><show_lines/><line_color/><line_alpha/><hide_labels_percent>2</hide_labels_percent></data_labels><group><percent/><color/><title/><url/><description/><pull_out/></group><background><color/><alpha/><border_color>#000000</border_color><border_alpha>15</border_alpha><file/></background><legend><enabled>false</enabled><x>90</x><y>330</y><width>500</width><color>#FFFFFF</color><max_columns>2</max_columns><alpha>0</alpha><border_color>#000000</border_color><border_alpha>20</border_alpha><text_color/><text_size>10</text_size><spacing>8</spacing><margins>20</margins><key><size>16</size><border_color/></key><values><enabled>true</enabled><width>120</width><text><![CDATA[: {value}]]></text></values></legend>  <export_as_image><file/><target/><x/><y/><color/><alpha/><text_color/><text_size/></export_as_image>  <error_messages><enabled/><x/><y/><color/><alpha/><text_color/><text_size/></error_messages>  <strings><no_data/><export_as_image/><collecting_data/></strings>  <labels><label><x>500</x><y>10</y><rotate>false</rotate><width/><align>left</align><text_color>5C5C5C</text_color><text_size>20</text_size><text><![CDATA[<b></b>]]></text></label></labels></settings>";
						//var sliceCaption = "{title}: {value} min(s)";
						var sliceCaption = "{title}: {value}";
						break;
				}
				var xmlHeader = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><settings>";
				var xmlFooter = "</settings>";
				var settingsGeneral = "<data_type>xml</data_type><csv_separator>;</csv_separator><skip_rows>1</skip_rows><font>Verdana</font><text_size>12</text_size><text_color>#000000</text_color><decimals_separator>.</decimals_separator><thousands_separator>,</thousands_separator><digits_after_decimal/><reload_data_interval/><preloader_on_reload/><redraw>true</redraw><add_time_stamp>false</add_time_stamp><precision>0</precision><exclude_invisible/>";
				var settingsPie = "<pie><x>335</x><y>240</y><radius>100</radius><inner_radius>40</inner_radius><height>20</height><angle>20</angle><outline_color>#F0F0F0</outline_color><outline_alpha>#FFF0F0</outline_alpha><base_color/><brightness_step/><colors>0xFF0F00,0xFF99CC,0xaaF0F1,0xFCD202,0xF8FF01,0xB0DE09,0x04D215,0x0D8ECF,0x0D52D1,0x2A0CD0,0x8A0CCF,0xCD0D74</colors><link_target/><alpha>80</alpha></pie>";				
				var settingsAnimation = "<animation><start_time>2</start_time><start_effect>strong</start_effect><start_radius/><start_alpha>0</start_alpha><pull_out_on_click/><pull_out_time>1</pull_out_time><pull_out_effect>Bounce</pull_out_effect><pull_out_radius>25</pull_out_radius><pull_out_only_one/></animation>";
				// v6.5.4.3 Trying to get labels a bit closer
				//var settingsDataLabels = "<data_labels><show><![CDATA[" + sliceCaption+ "]]></show><avoid_overlapping>true</avoid_overlapping><radius>60</radius><text_color/><text_size/><max_width>300</max_width><show_lines/><line_color/><line_alpha/><hide_labels_percent>2</hide_labels_percent></data_labels>";
				var settingsDataLabels = "<data_labels><show><![CDATA[" + sliceCaption+ "]]></show><avoid_overlapping>true</avoid_overlapping><radius>40</radius><text_color/><text_size/><max_width>300</max_width><show_lines/><line_color/><line_alpha/><hide_labels_percent>2</hide_labels_percent></data_labels>";
				var settingsBackground = "<background><color/><alpha/><border_color>#000000</border_color><border_alpha>0</border_alpha><file/></background>";
				var settingsLegend = "<legend><enabled>false</enabled><x>90</x><y>330</y><width>500</width><color>#FFFFFF</color><max_columns>2</max_columns><alpha>0</alpha><border_color>#000000</border_color><border_alpha>20</border_alpha><text_color/><text_size>10</text_size><spacing>8</spacing><margins>20</margins><key><size>16</size><border_color/></key><values><enabled>true</enabled><width>120</width><text><![CDATA[: {value}]]></text></values></legend>";
				var settingsExportAsImage = "<export_as_image><file/><target/><x/><y/><color/><alpha/><text_color/><text_size/></export_as_image>";
				var settingsErrorMessages = "<error_messages><enabled/><x/><y/><color/><alpha/><text_color/><text_size/></error_messages>";
				var settingsStrings = "<strings><no_data/><export_as_image/><collecting_data/></strings>";
				var settingsLabels = "<labels><label><x>500</x><y>10</y><rotate>false</rotate><width/><align>left</align><text_color>5C5C5C</text_color><text_size>20</text_size><text><![CDATA[<b></b>]]></text></label></labels>";
				return xmlHeader + settingsGeneral + settingsPie + settingsAnimation
								+ settingsBackground 
								+ settingsDataLabels 
								+ settingsLegend + settingsExportAsImage + settingsErrorMessages
								+ settingsStrings + settingsLabels + 
								+ xmlFooter;
				break;
			case PROGRESS_APP_NAME:
				break;
		}
	}
}