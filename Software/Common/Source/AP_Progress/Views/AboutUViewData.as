class AP_Progress.Views.AboutUViewData{
	// member variables
	private var m_aData:Array;
	
	public function AboutUViewData(strCaption:String, nTotalWrong:Number, nTotalCorrect:Number, nTotalScore:Number, nTime:Number, nCount:Number){
		m_aData				= new Array();
		m_aData["caption"]	= strCaption;
		m_aData["wrong"]	= nTotalWrong; 
		m_aData["correct"]	= nTotalCorrect;
		m_aData[_global.ORCHID.literalModelObj.getLiteral("progress_analysis_combo_box1", "messages")]	= nTotalScore;
		m_aData[_global.ORCHID.literalModelObj.getLiteral("progress_analysis_combo_box2", "messages")]	= nTime/60;
		m_aData["count"]	= nCount;
		
		//_global.myTrace("About U View Data: " + strCaption + ", " + nTotalWrong + ", " + nTotalCorrect + ", " + nTotalScore + ", " + nTime + ", " + nCount);
	}
	
	public function getData(strFieldName:String){
		//_global.myTrace("in getData: strFieldName: " + strFieldName + ", value: " + m_aData[strFieldName]);
		return m_aData[strFieldName];
	}
}