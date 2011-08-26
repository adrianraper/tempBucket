import Classes.test;

class Classes.testCasesClass extends test {
	
	var testFuncs:Array=new Array();
	
	function testCasesClass() {
		with (testFuncs) {
			push("getMaxCourseID");
			push("getMaxUnitID");
			push("getMaxExerciseID");
			push("traceCurrentCourse");
			push("traceCurrentUnit");
			push("traceCurrentExercise");
			push("traceXmlCourse");
			push("traceXmlUnit");
			push("traceXmlExercise");
			push("traceLiterals");
			push("traceAudios");
			push("traceTxtText");
			push("tracePhotos");
			push("traceFields");
		}
	}
	
	function test_getMaxCourseID() : Void {
		var expected = 2;
		var pass = assertTrue(expected, data.getMaxCourseID());
		output(pass+" , "+expected+" , "+data.getMaxCourseID());
	}
	
	function test_getMaxUnitID() : Void {
		var expected = 5;
		var pass = assertTrue(expected, data.currentCourse.getMaxUnitID());
		output(pass+" , "+expected+" , "+data.currentCourse.getMaxUnitID());
	}
	
	function test_getMaxExerciseID() : Void {
		var expected = 113;
		var pass = assertTrue(expected, data.currentCourse.getMaxExerciseID());
		output(pass+" , "+expected+" , "+data.currentCourse.getMaxExerciseID());
	}
	
	function test_traceCurrentCourse() : Void {
		output("data.currentCourse:");
		for (var i in data.currentCourse) {
			output("\t"+i+" : "+data.currentCourse[i]);
		}
	}
	
	function test_traceCurrentUnit() : Void {
		output("data.currentUnit:");
		for (var i in data.currentUnit) {
			output("\t"+i+" : "+data.currentUnit[i]);
		}
	}
	
	function test_traceCurrentExercise() : Void {
		output("data.currentExercise:");
		for (var i in data.currentExercise) {
			output("\t"+i+" : "+data.currentExercise[i]);
		}
	}
	
	function test_traceXmlCourse() : Void {
		output("xmlCourse:");
		output(xmlCourse.toString());
	}
	
	function test_traceXmlUnit() : Void {
		output("xmlUnit:");
		output(xmlUnit.toString());
	}
	
	function test_traceXmlExercise() : Void {
		output("xmlExercise:");
		output(xmlExercise.toString());
	}
	
	function test_traceLiterals() : Void {
		output("default literals for "+literals.SelectedLanguage+":");
		for (var i in literals.Strings[literals.SelectedLanguage]) {
			output(i+" : "+literals.getLiteral(i));
		}
	}
	
	function test_traceAudios() : Void {
		output("audios:");
		for (var i in audios.files) {
			output(i+" : "+audios.getFilename(i));
		}
	}
	
	function test_traceTxtText() : Void {
		output("trace txtText.text:");
		output(_global.NNW.screens.txts.txtText.text);
	}
	
	function test_tracePhotos() : Void {
		output("trace photos sizes: ");
		for (var i in photos.Sizes) {
			output(i+":");
			for (var j in photos.Sizes[i].Categories) {
				output("\t"+j);
			}
		}
	}
	
	function test_traceFields() : Void {
		output("trace fields: ");
		var ex = _global.NNW.control.data.currentExercise;
		var fields = ex.fieldManager.fields;
		for (var i=0; i<fields.length; i++) {
			output("field id: "+fields[i].attr.id);
			for (var j=0; j<fields[i].answers.length; j++) {
				output("\t"+j+": "+fields[i].answers[j].value);
			}
		}
	}
}