import AP_Progress.Views.ViewBase;
import mx.controls.*;
import mx.controls.gridclasses.DataGridColumn;
import AP_Progress.GlobalVar;
import AP_Progress.CustomizeDevice;

class AP_Progress.Views.NormalView extends ViewBase
{
	// const 
	static public var CLIP_NAME:String					= "NormalView"; 
	private var MINS_SCORE_SUB:String					= "---";
	private var MONTH_ARRAY:Array						= ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
	private var BORDER_OFFSET_X:Number					= 20;
	private var TITLE_HINT_TEXT:String					= "";
	private var NO_RECORD_BACKGROUND_FILE_NAME:String	= "";
	
	// member variables
	private var m_strColumnName1:String 	= "";
	private var m_strColumnName2:String 	= "";
	private var m_strColumnName3:String 	= "";
	private var m_strColumnName4:String 	= "";
	private var m_strColumnName5:String 	= "";
	
	private var m_dataGrid:DataGrid;
	private var m_aColNames:Array			= ["Unit", 	"Exercise", "Score", 	"Date", "Time_in_mins"];
	private var m_aColWidth:Array			= [0, 		0, 			55, 		93, 	105];
	
	public function NormalView(parent:MovieClip, numDepth:Number){
		super(parent, CLIP_NAME, numDepth);
		super.SetNoRecordBackgroundFilePath(NO_RECORD_BACKGROUND_FILE_NAME);
		
		TITLE_HINT_TEXT	= _global.ORCHID.literalModelObj.getLiteral("progress_your_scores_headline", "messages");
		
		m_strColumnName1= _global.ORCHID.literalModelObj.getLiteral("progress_your_scores_grid_t1", "messages");
		m_strColumnName2= _global.ORCHID.literalModelObj.getLiteral("progress_your_scores_grid_t2", "messages");
		m_strColumnName3= _global.ORCHID.literalModelObj.getLiteral("progress_your_scores_grid_t3", "messages");
		m_strColumnName4= _global.ORCHID.literalModelObj.getLiteral("progress_your_scores_grid_t4", "messages");
		m_strColumnName5= _global.ORCHID.literalModelObj.getLiteral("progress_your_scores_grid_t5", "messages");
	}
	
	public function initView(myXmlRec:XML, everyoneXmlRec:XML){
		super.initView(myXmlRec, everyoneXmlRec, TITLE_HINT_TEXT);
		
		var numDepth:Number	= 0;
		var aData:Array= new Array;
		var v1:Number;
		
		m_dataGrid= m_clipContainer.createClassObject(DataGrid, "m_dataGrid", m_clipContainer.getNextHighestDepth());
		m_dataGrid.setStyle("fontFamily", "Verdana");
		m_dataGrid.hScrollPolicy= "on";
		// v6.5.4.3 tweak the width
		//m_dataGrid.setSize(GlobalVar.G_DISPLAY_WIDTH, GlobalVar.G_DISPLAY_HEIGHT - GlobalVar.G_DISPLAY_START_Y - HEADER_HINT_HEIGHT);
		// v6.5.5.8 The CP height is different as a different type of window
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
			var thisHeight = GlobalVar.G_DISPLAY_HEIGHT-20;
			var thisWidth = GlobalVar.G_DISPLAY_WIDTH-8;
		} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
			_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
			var thisHeight = GlobalVar.G_DISPLAY_HEIGHT;
			var thisWidth = GlobalVar.G_DISPLAY_WIDTH;
		} else {
			var thisHeight = GlobalVar.G_DISPLAY_HEIGHT;
			var thisWidth = GlobalVar.G_DISPLAY_WIDTH;
			m_dataGrid.hScrollPolicy= "off";
		}
		
		m_dataGrid.setSize(thisWidth+1,  thisHeight - GlobalVar.G_DISPLAY_START_Y - HEADER_HINT_HEIGHT);
		
		m_dataGrid.move(GlobalVar.G_DISPLAY_START_X, GlobalVar.G_DISPLAY_START_Y + HEADER_HINT_HEIGHT);
		
		m_dataGrid.setStyle("color", CustomizeDevice.ChangeStyleColor(CLIP_NAME, "color"));
		m_dataGrid.setStyle("backgroundColor", CustomizeDevice.ChangeStyleColor(CLIP_NAME, "backgroundColor"));
		m_dataGrid.setStyle("themeColor", CustomizeDevice.ChangeStyleColor(CLIP_NAME, "themeColor"));
		m_dataGrid.setStyle("alternatingRowColors", CustomizeDevice.ChangeStyleColor(CLIP_NAME, "alternatingRowColors"));
		m_dataGrid.setStyle("selectionColor", CustomizeDevice.ChangeStyleColor(CLIP_NAME, "selectionColor"));
		m_dataGrid.setStyle("headerColor", CustomizeDevice.ChangeStyleColor(CLIP_NAME, "headerColor"));
		// v6.5.4.3 Update for Active Reading, hide teh border a bit.
		//m_dataGrid.setStyle("borderStyle", "menuBorder");
		m_dataGrid.setStyle("borderStyle", "inset"); // Remember that this is the Flash datagrid component, not amCharts
		
		// Give the grid column name
		for(v1= 0; v1< m_aColNames.length; v1++){
			var dgc:DataGridColumn = m_dataGrid.getColumnAt(v1);
			dgc.headerText = m_aColNames[v1];
		}
		
		var aNode:XMLNode;
		var bNode:XMLNode;
		var tempTime;
		var tempScore:String;
		var tempDate;
		var tempDay;
		var tempYear;
		var tempMonth;
		var tempDateArray:Array= new Array();
		
		// Get the maxium size of each column text
		var nTempStrLength:Number			= 0;
		var nMaxUnitLength:Number			= 0;
		var nMaxExerciseLength:Number		= 0;		
		
		for(aNode= m_myXmlRecCopy.firstChild.firstChild; aNode != undefined; aNode= aNode.nextSibling){
			for(bNode= aNode.firstChild; bNode != undefined; bNode= bNode.nextSibling){
				// calculate the Max Unit Length and Max Exercise Length
				
				nTempStrLength= _global.strLength(	String(aNode.attributes.caption), 
													m_dataGrid.getStyle("fontFamily"), 
													m_dataGrid.getStyle("fontSize"), 
													false);
				if(nMaxUnitLength < nTempStrLength)
					nMaxUnitLength= nTempStrLength;
								
				nTempStrLength= _global.strLength(	String(bNode.attributes.caption), 
													m_dataGrid.getStyle("fontFamily"), 
													m_dataGrid.getStyle("fontSize"), 
													false);
				if(nMaxExerciseLength < nTempStrLength)
					nMaxExerciseLength= nTempStrLength;
				
				// prepare the time, replace the min < 1 to "<1" in the row
				tempTime= Math.round(bNode.attributes.duration / 60);
				if(tempTime<1)
					tempTime= "<1";
				
				// replace the "-1" score to "---"
				tempScore= bNode.attributes.score;
				if(tempScore<0){
					tempScore= MINS_SCORE_SUB;
				} else {
					tempScore+= "%";
				}
				
				// extract the date, formate it in a more readable form
				tempDate		= bNode.attributes.dateStamp;
				tempDateArray	= tempDate.split("-");
				tempYear		= tempDateArray[0];
				tempMonth		= tempDateArray[1];
				tempDate		= tempDateArray[2];
				tempDate		= tempDate.split(" ")[0];
				
				tempMonth= MONTH_ARRAY[Number(tempMonth)-1];
				
				// recombine it into a whole string
				tempDate= tempDate + " " + tempMonth + " " + tempYear;
				
				// end extract the date
				aData.push	({	Unit:aNode.attributes.caption,
								Exercise:bNode.attributes.caption, 
								Score:tempScore,
								Date:tempDate,
								Time_in_mins:tempTime
							});
			}
		}
		
		m_dataGrid.addEventListener("headerRelease", DataGridCustomizeSort);
		m_dataGrid.dataProvider= aData;
		
		// Customerize each column's width
		var tempGridColumn:DataGridColumn;
		var tempIndexNumber:Number;
		
		m_aColWidth[0]	= nMaxUnitLength;
		m_aColWidth[1]	= nMaxExerciseLength;
		
		var nTotalWidth:Number= 0;
		for(v1=0; v1<m_aColWidth.length; ++v1){
			nTotalWidth+= m_aColWidth[v1];
		}
		
		var nTotalWidthDif:Number= 0;
		// v6.5.5.8 If you do this width thing in CP you end up horizontal scrolling that you don't need.
		// Actually it seems to be all.
		//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
			nTotalWidthDif= GlobalVar.G_DISPLAY_WIDTH- nTotalWidth - 25;
		//} else {
		//	nTotalWidthDif= GlobalVar.G_DISPLAY_WIDTH- nTotalWidth;
		//}
		m_aColWidth[0]+= nTotalWidthDif/2;
		m_aColWidth[1]+= nTotalWidthDif/2;
				
		for(v1=0; v1<m_aColNames.length; ++v1){
			tempGridColumn			= m_dataGrid.getColumnAt(v1);
			
		//GlobalVar.G_DISPLAY_WIDTH		= nAppWidth;
		//GlobalVar.G_DISPLAY_HEIGHT	= nAppHeight;
			tempGridColumn.width	= m_aColWidth[v1];
		}
		
		tempIndexNumber	= m_dataGrid.getColumnIndex("Unit");
		tempGridColumn	= m_dataGrid.getColumnAt(tempIndexNumber);
		tempGridColumn.headerText = m_strColumnName1;
		
		tempIndexNumber	= m_dataGrid.getColumnIndex("Exercise");
		tempGridColumn	= m_dataGrid.getColumnAt(tempIndexNumber);
		tempGridColumn.headerText = m_strColumnName2;
		
		tempIndexNumber	= m_dataGrid.getColumnIndex("Score");
		tempGridColumn	= m_dataGrid.getColumnAt(tempIndexNumber);
		tempGridColumn.headerText = m_strColumnName3;
		
		tempIndexNumber	= m_dataGrid.getColumnIndex("Date");
		tempGridColumn	= m_dataGrid.getColumnAt(tempIndexNumber);
		tempGridColumn.headerText = m_strColumnName4;
		
		// change the titles name from "Time_in_mins" to "Time (mins)"
		tempIndexNumber	= m_dataGrid.getColumnIndex("Time_in_mins");
		tempGridColumn	= m_dataGrid.getColumnAt(tempIndexNumber);
		tempGridColumn.headerText= m_strColumnName5;
	}
	
	private function DataGridCustomizeSort(evt:Object){		
		var dataGrid 	= evt.target;
		var data 		= dataGrid.dataProvider;
        var column 		= evt.columnIndex;
		var columnName 	= dataGrid.columnNames[column];
		var direction 	= evt.target.sortDirection.toUpperCase();
		var sortOptions = 0;
		
		if(columnName == "Time_in_mins"){
			data.sort(sortTimeInMins, sortOptions);
		}
		
		if(columnName == "Score"){
			data.sort(sortScore, sortOptions);
		}
		
		if(columnName == "Date"){
			data.sort(sortDate, sortOptions);
		}
		
		function sortTimeInMins(recordA, recordB){
			var str1:String;
			var str2:String;
			var num1:Number;
			var num2:Number;
			
			str1	= recordA[columnName];
			str2	= recordB[columnName];
			
			num1	= Number(str1);
			num2	= Number(str2);
			
			if(str1.charAt(0) == "<"){
				num1= 0;
			}
			if(str2.charAt(0) == "<"){
				num2	= 0;
			}
			
			return direction == "DESC" ? (num2 - num1) : (num1 - num2);
		}
		
		function sortScore(recordA, recordB){
			var tempStr1:String;
			var tempStr2:String;
			
			var tempNum1:Number;
			var tempNum2:Number;
			
			tempStr1= String(recordA[columnName]);
			tempStr2= String(recordB[columnName]);
			
			tempStr1= tempStr1.substring(0, tempStr1.length-1);
			tempStr2= tempStr2.substring(0, tempStr2.length-1);
			
			tempNum1= Number(tempStr1);
			tempNum2= Number(tempStr2);
			
			if(tempStr1 == MINS_SCORE_SUB)
				tempNum1= 0;
			
			if(tempStr2 == MINS_SCORE_SUB)
				tempNum2= 0;
			
			return direction == "DESC" ? (tempNum2 - tempNum1) : (tempNum1 - tempNum2);
		}
		
		function sortDate(recordA, recordB){
			var tempStr1:String;
			var tempStr2:String;
			
			var tempNum1:Number;
			var tempNum2:Number;
			
			var tempArray:Array;
			var v1;
			
			tempStr1	= String(recordA[columnName]);
			tempStr2	= String(recordB[columnName]);
						
			// first date
			tempArray= tempStr1.split(" ");
			for(v1=0; v1<tempArray.length; ++v1)
			{
				if(tempArray[1] == MONTH_ARRAY[v1])
					break;
			}
			
			tempNum1= Number(tempArray[2] + String(v1) + tempArray[0]);
			
			// second date
			tempArray= tempStr2.split(" ");
			for(v1=0; v1<tempArray.length; ++v1)
			{
				if(tempArray[1] == MONTH_ARRAY[v1])
					break;
			}
			
			tempNum2= Number(tempArray[2] + String(v1) + tempArray[0]);
			
			return direction == "DESC" ? (tempNum2 - tempNum1) : (tempNum1 - tempNum2);
		}
	}
	
	public function redraw():Void{
		if(!haveData()){
			showNoDataInterface();
		}
		else{
			_global.myTrace("NormalView from redraw()");
			hiddenNoDataInterface();
		}
	}
	
	public function print(strHeader:String):Void
	{
		if(!haveData()){
			showNoDataInterface();
			return ;
		}
		else{
			_global.myTrace("NormalView from print()");
			hiddenNoDataInterface();
		}
		
		var pagesToPrint:Number = 0;
		var objPrintJob:PrintJob = new PrintJob();	
		// display print dialog box
		var printOK:Boolean = objPrintJob.start();
		//abort if cancelled;
		if (!printOK)
		{
			delete objPrintJob; 
			return;
		}
		
		/*NOTE: If you want you could add other pages to the print output
		before or after the DataGrid pages. E.g. the following would add a 
		snapshot of the main timeline as initial page:
		if (_objPrintJob.addPage(0))
		{
			pagesToPrint++;
		}
		End Note */
	 
		//START ADDING PAGES FOR THE DATAGRID
		//create new movieclip for the datagrid data
		var printOutput:MovieClip = createDgPrintClip(m_dataGrid,objPrintJob); 
		//define the height of the page snapshots depending on how many rows fit
		//into the pageheight returned by the printer
		var pageHeight:Number = Math.floor(objPrintJob.pageHeight/printOutput.rowHeight)*printOutput.rowHeight;
		
		var yMin:Number  = 0;
		var xMargin:Number  = -20;
		var rightMargin = 30;
		
		printOutput._width	*= 0.8;
		printOutput._height	*= 0.8;
								
		var headerFormat:TextFormat = new TextFormat()
		headerFormat.size = 12;
		headerFormat.font = "Verdana";
		headerFormat.bold = true;
		
		var nPageNumber:Number= 0;
		
		while(yMin <  printOutput._height)
		{	
			nPageNumber	= pagesToPrint + 1;
			var headlineTb:TextField = printOutput.createTextField(	"headlineTextField" + String(pagesToPrint), 
																	printOutput.getNextHighestDepth(), 
																	20, yMin + 40, 1000, 30);
			headlineTb.setNewTextFormat(headerFormat);
			headlineTb.text = strHeader + "\t\t\t\tYour records in detail\t\t page: " + nPageNumber;
			
			var yMax:Number = yMin + pageHeight;
			if (objPrintJob.addPage(	printOutput,
										{	xMin:xMargin,
											//xMax:objPrintJob.pageWidth + xMargin - rightMargin,
											xMax:650,
											yMin:yMin,
											yMax:yMax} ))
											//yMax:354 - yMin} ))
			{
				pagesToPrint++;
			}
			yMin = yMax;
		}
		//END ADDING PAGES FOR THE DATAGRID
			
		// send pages from the spooler to the printer
		if (pagesToPrint > 0)
		{
			objPrintJob.send(); 
		}
		// clean up
		delete objPrintJob; 
		printOutput.removeMovieClip();
	}

	public function createDgPrintClip(targetDG:DataGrid,printJob:PrintJob):MovieClip
	{
		var headerFormat:TextFormat = new TextFormat()
		headerFormat.size = 12;
		headerFormat.font = "Verdana";
		headerFormat.bold = true;
		headerFormat.leftMargin = 4;
		
		var txtFormat:TextFormat = new TextFormat()
		txtFormat.size = 12;
		txtFormat.font = "Verdana";
		txtFormat.leftMargin = 4;
		
		var rowHeight:Number = 18;
		//calculate rows per page taking off 4 rows for margin
		var rowsPerPage:Number = Math.floor(printJob.pageHeight/rowHeight) - 4;

		//note: the static value 100000 is used for the mc depth as using 
		//this.getNextHighestDepth() will result in the mc not being removed 
		//using removeMovieClip()
		var printClip:MovieClip = m_clipContainer.createEmptyMovieClip("print_mc", 100000);
		printClip._visible = false;
		
		//get colums
		var columns:Array = targetDG.columnNames;
		
		//Start printing headers  
		var xPos:Number = 0;
		var tbWidth:Number = 0;
		//leave 2 rows margin at top 
		var rowY:Number = rowHeight * 4;
		for (var i = 0; i < columns.length; i++)
		{
			//define xPos by adding the tbWidth of the last loop
			xPos = xPos + tbWidth;
			var column:DataGridColumn = targetDG.getColumnAt(i);
			//get width of this column
			tbWidth = column.width;
			//add textField
			printClip.createTextField("header_" + i , printClip.getNextHighestDepth(), xPos, rowY,tbWidth, rowHeight);
			var thisTb:TextField = printClip["header_" + i];
			thisTb.setNewTextFormat(headerFormat);
			thisTb.border = true;
			thisTb.borderColor = 0xCCCCCC;
			thisTb.background = true;
			thisTb.backgroundColor = 0xD5EAFF;
			thisTb.text = column.headerText;
		}
		//End printing headers  
		
		//Start printing rows
		//start row counter taking in count the header row  
		var pageRows:Number = 1;
		var pages:Number = 1;
		var dataArray:Object = targetDG.dataProvider;
		//add data rows
		for (var j = 0; j < dataArray.length; j++)
		{
			//insert margins if rows per page are full
			if (pageRows == rowsPerPage)
			{
				rowY +=  rowHeight * 5;
				pageRows = 1;
				pages++;
				//add headers
				xPos = 0;
				tbWidth = 0;
				for (var i = 0; i < columns.length; i++)
				{
					//define xPos by adding the tbWidth of the last loop
					xPos = xPos + tbWidth;
					var column:DataGridColumn = targetDG.getColumnAt(i);
					//get width of this column
					tbWidth = column.width;
					//add textField
					printClip.createTextField("header_" + pages +"_" + i , printClip.getNextHighestDepth(), xPos, rowY,tbWidth, rowHeight);
					var thisTb:TextField = printClip["header_" + pages +"_" + i];
					thisTb.setNewTextFormat(headerFormat);
					thisTb.border = true;
					thisTb.borderColor = 0xCCCCCC;
					thisTb.background = true;
					thisTb.backgroundColor = 0xD5EAFF;
					thisTb.text = column.headerText;
				}
			}
			
			rowY +=  rowHeight;
			pageRows++
			
			//add TextFields for each row
			xPos = 0;
			tbWidth = 0;
			var rowData:Object = dataArray.getItemAt(j);
			for (var i = 0; i < columns.length; i++)
			{
				// A4 size
				//Width=595.2756 px
				//Height=841.8898 px
				
				//define xPos by adding the tbWidth of the last loop
				xPos = xPos + tbWidth;
				var column:DataGridColumn = targetDG.getColumnAt(i);
				//get width of this column
				tbWidth = column.width;
				//add textField
				printClip.createTextField("field_"+ j + "_" + i  , printClip.getNextHighestDepth(), xPos, rowY,tbWidth, rowHeight);
				var thisTb:TextField  = printClip["field_"+ j + "_" + i];
				thisTb.setNewTextFormat(txtFormat);
				thisTb.border = true;
				thisTb.borderColor = 0xCCCCCC;
				//as columns was defined as the array of field identifiers (= columnNames)
				//for the datagrid we can use the array items to identify the properties
				//in the dataProvider
				thisTb.text = rowData[columns[i]];
			}
		}
		//End printing rows
		
		//store rowHeight with printclip to be retrieved later
		printClip.rowHeight = rowHeight;
		return printClip;
	}
	
	// HERE! fill in haveData function
	public function haveData():Boolean{
		return (m_dataGrid.dataProvider.length > 0);
	}
	
	public function showNoDataInterface():Void{
		//_global.myTrace("NormalView showNoDataInterface()");

		var aData:Array= new Array();
		aData.push	({	Unit:"",
						Exercise:"",
						Score:"",
						Date:"",
						Time_in_mins:""
					});
		m_dataGrid.dataProvider= aData;
		
		var tempIndexNumber:Number	= 0;
		var tempGridColumn:DataGridColumn;
		// change the titles name from "Time_in_mins" to "Time (mins)"
		tempIndexNumber	= m_dataGrid.getColumnIndex("Time_in_mins");
		tempGridColumn	= m_dataGrid.getColumnAt(tempIndexNumber);
		tempGridColumn.headerText= "Time(mins)";
		m_dataGrid.dataProvider= "";
		
		super.showNoDataMessgeBox();
		m_txtNoData1._y = 200;
		
		m_dataGrid._visible	= false;
	}
		
	private function hiddenNoDataInterface():Void{
		//_global.myTrace("NormalView hiddenNoDataInterface()");
		super.hiddenNoDataMessgeBox();
	}
}