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
			
			Assert.assertEquals(vectorMap.get("a"), "value-a");
			Assert.assertEquals(vectorMap.get("b"), "value-b");
		}
		
		[Test]
		public function testObjectMapping():void {
			var a:Object = {};
			var b:Object = {};
			
			vectorMap.put(a, "value-a");
			vectorMap.put(b, "value-b");
			
			Assert.assertEquals(vectorMap.get(a), "value-a");
			Assert.assertEquals(vectorMap.get(b), "value-b");
		}
		
		[Test]
		public function testXMLMapping():void {
			var a:XML = <node />
			var b:XML = <node />
			
			vectorMap.put(a, "value-a");
			vectorMap.put(b, "value-b");
			
			Assert.assertEquals(vectorMap.get(a), "value-a");
			Assert.assertEquals(vectorMap.get(b), "value-b");
			
			Assert.assertTrue(vectorMap.containsKey(a));
			Assert.assertTrue(vectorMap.containsKey(b));
			Assert.assertFalse(vectorMap.containsKey(<node />));
		}
		
		[Test]
		public function testReplace():void {
			var a:XML = <node />
			var b:XML = <node />
			
			vectorMap.put(a, "value-a");
			vectorMap.put(b, "value-b");
			vectorMap.put(a, "value-c");
			
			Assert.assertEquals(vectorMap.get(a), "value-c");
			Assert.assertEquals(vectorMap.get(b), "value-b");
			Assert.assertEquals(vectorMap.keys.length, 2);
			
			Assert.assertTrue(vectorMap.containsKey(a));
			Assert.assertTrue(vectorMap.containsKey(b));
		}
		
		[Test(expects="Error")]
		public function testNullPut():void {
			vectorMap.put(null, "can't put a null key");
		}
		
		[Test(expects="Error")]
		public function testNullGet():void {
			vectorMap.put(null, "can't get a null key");
		}
		
		[Test(expects="Error")]
		public function testNullContainsKey():void {
			vectorMap.containsKey(null);
		}
		
	}
}
