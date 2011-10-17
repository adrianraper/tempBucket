package flexUnitTests.tests {
	import com.clarityenglish.bento.model.ExerciseProxy;
	
	public class ExerciseProxyTest {
		
		private var exerciseProxy:ExerciseProxy;
		
		[Before]
		public function setUp():void {
			exerciseProxy = new ExerciseProxy();
		}
		
		[After]
		public function tearDown():void {
			exerciseProxy = null;
		}
	
	}
	
}
