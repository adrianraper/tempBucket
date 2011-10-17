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
		
		[Test]
		public function testObjectMapping():void {
			var a:Object = {};
			var b:Object = {};
			
			vectorMap.put(a, "value-a");
			vectorMap.put(b, "value-b");
			
			Assert.assertEquals(vectorMap.fetch(a), "value-a");
			Assert.assertEquals(vectorMap.fetch(b), "value-b");
		}
		
		[Test]
		public function testXMLMapping():void {
			var a:XML = <node />
			var b:XML = <node />
			
			vectorMap.put(a, "value-a");
			vectorMap.put(b, "value-b");
			
			Assert.assertEquals(vectorMap.fetch(a), "value-a");
			Assert.assertEquals(vectorMap.fetch(b), "value-b");
		}
		
		[Test]
		public function testReplace():void {
			var a:XML = <node />
			var b:XML = <node />
			
			vectorMap.put(a, "value-a");
			vectorMap.put(b, "value-b");
			vectorMap.put(a, "value-c");
			
			Assert.assertEquals(vectorMap.fetch(a), "value-c");
			Assert.assertEquals(vectorMap.fetch(b), "value-b");
			Assert.assertEquals(vectorMap.getKeys().length, 2);
		}
		
	}
}
