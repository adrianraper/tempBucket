package com.clarityenglish.tests.manageables {
	import com.clarityenglish.tests.DTestCase;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.common.vo.manageable.Manageable;
	import com.clarityenglish.common.vo.manageable.User;
	import net.digitalprimates.fluint.tests.TestCase;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class ManageableTest extends DTestCase {
		
		private static var groupCount:Number = 1;
		private static var userCount:Number = 1;
		
		private var year1:Group;
		private var classA:Group;
		private var classB:Group;
		private var student1:User;
		private var student3:User;
		private var student2:User;
		
		override protected function setUp():void {
			super.setUp();
			
			year1 = createGroup("Top Group");
			classA = createGroup("Class A");
			classB = createGroup("Class B");
			
			student1 = createUser("Student 1");
			student2 = createUser("Student 2");
			student3 = createUser("Student 3");
			
			classA.children = [ student1 ];
			classB.children = [ student2, student3 ];
			year1.children = [ classA, classB ];
		}
		
		private function createGroup(name:String):Group {
			var group:Group = new Group();
			group.id = (groupCount++).toString();
			group.name = name;
			
			return group;
		}
		
		private function createUser(name:String):User {
			var user:User = new User();
			// v3.4 Multi-group users
			//user.id = (userCount++).toString();
			user.userID = (userCount++).toString();
			user.name = name;
			
			return user;
		}
		
		public function testContains():void {
			assertTrue(year1.contains(classA));
			assertTrue(year1.contains(classA));
			assertTrue(year1.contains(student1));
			assertTrue(year1.contains(student2));
			assertTrue(year1.contains(student3));
			assertTrue(classA.contains(student1));
			assertTrue(classB.contains(student2));
			assertTrue(classB.contains(student3));
			
			assertFalse(student1.contains(year1));
			assertFalse(classA.contains(classB));
			assertFalse(classA.contains(student2));
			assertFalse(classB.contains(student1));
			assertFalse(classB.contains(year1));
		}
		
		public function testNormalize():void {
			assertArrayEquals([ classA, classB ], Manageable.normalizeManageables([ classA, classB ]));
			assertArrayEquals([ year1 ], Manageable.normalizeManageables([ year1, classA ]));
			assertArrayEquals([ classB ], Manageable.normalizeManageables([ classB, student3 ]));
			assertArrayEquals([ classA, classB ], Manageable.normalizeManageables([ student1, student2, student3, classA, classB ]));
			
			assertArrayEquals([ student1, student2, student3 ], Manageable.normalizeManageables([ student1, student2, student3 ]));
			assertArrayEquals([ ], Manageable.normalizeManageables([ ]));
		}
		
	}
	
}