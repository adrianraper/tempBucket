class Classes.test {
	
	// references
	private var control:Object;
	private var xmlCourse:Object;
	private var xmlUnit:Object;
	private var xmlExercise:Object;
	private var data:Object;
	private var view:Object;
	private var literals:Object;
	private var photos:Object;
	private var audios:Object;
	
	function test() {
		// set up references to classes
		control = _global.NNW.control;
		xmlCourse = control.xmlCourse;
		xmlUnit = control.xmlUnit;
		xmlExercise = control.xmlExercise;
		data = control.data;
		view = _global.NNW.view;
		literals = view.literals;
		photos = _global.NNW.photos;
		audios = _global.NNW.audios;
	}
	
	function output(s:String) : Void {
		_global.NNW.screens.txts.txtTestOutput.text += s+"\n";
	}
	
	function clearOutput() : Void {
		_global.NNW.screens.txts.txtTestOutput.text = "";
	}
		
	function runTest(func:String) : Void {
		clearOutput();
		this["test_"+func]();
	}
	
	function assertTrue(value1, value2) : Boolean {
		return (value1==value2);
	}
}
