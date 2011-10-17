package flexUnitTests.tests {
	import flexunit.framework.Assert;
	
	import org.davekeen.collections.VectorMap;
	
	public class VectorMapTest {
		
		private var vectorMap:VectorMap;
		
		[Before]
		public function setUp():void {
			vectorMap = new VectorMap();
		}
		
		[After]
		public function tearDown():void {
			vectorMap = null;
		}
		
		[Test]
		public function testStringMapping():void {
			vectorMap.put("a", "value-a");
			vectorMap.put("b", "value-b");
			
			Assert.assertEquals(vectorMap.fetch("a"), "value-a");
			Assert.assertEquals(vectorMap.fetch("b"), "value-b");
		}
		
	}
}
