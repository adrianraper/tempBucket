package flexUnitTests.tests {
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flexunit.framework.Assert;
	
	public class XHTMLTest {
		
		private var xhtml:XHTML;
		
		[Before]
		public function setUp():void {
			xhtml = new XHTML(
				<bento xmlns="http://www.w3.org/1999/xhtml">
					<head>
						<link rel="stylesheet" href="../../css/exercises.css" type="text/css" />
						<style type="text/css" >
						<![CDATA[
							#questionList {
								list-style-type: decimal;
							}
							
							#questionList li {
								padding-bottom: 20;
							}
							
							#questionList input {
								padding-left: 60;
							}
							
							#noscroll span[draggable=true] {
								float: left;
								width: 140px;
							}
							
							a, span[draggable="true"] {
								color: #3A00FF;
							}
							
						]]>
						</style>
						<script id="model" type="application/xml">
							<questions>
								<DragQuestion source="q1Input">
									<answer correct="true" source="a5" />
									<answer correct="true" source="a7" />
								</DragQuestion>
								
								<DragQuestion source="q2Input">
									<answer correct="true" source="a1" />
									<answer correct="true" source="a8" />
								</DragQuestion>
								
								<DragQuestion source="q3Input">
									<answer correct="true" source="a5" />
									<answer correct="true" source="a7" />
								</DragQuestion>
								
								<DragQuestion source="q4Input">
									<answer correct="true" source="a5" />
									<answer correct="true" source="a7" />
								</DragQuestion>
								
								<DragQuestion source="q5Input">
									<answer correct="true" source="a5" />
									<answer correct="true" source="a7" />
								</DragQuestion>
								
								<DragQuestion source="q6Input">
									<answer correct="true" source="a2" />
									<answer correct="true" source="a4" />
								</DragQuestion>
								
								<DragQuestion source="q7Input">
									<answer correct="true" source="a5" />
									<answer correct="true" source="a7" />
								</DragQuestion>
								
								<DragQuestion source="q8Input">
									<answer correct="true" source="a3" />
									<answer correct="true" source="a6" />
								</DragQuestion>
								
								<DragQuestion source="q9Input">
									<answer correct="true" source="a3" />
									<answer correct="true" source="a6" />
								</DragQuestion>
							</questions>
						</script>
					</head>
					
					<body>
						<header>
							Answer these questions about yourself.  Drag down the correct answers.
						</header>
						
						<section id="noscroll">
							<span id="a1" draggable="true">No, she doesn't</span><tab/>
							<span id="a2" draggable="true">Yes, he does</span><tab/>
							<span id="a3" draggable="true">No, it doesn't</span><tab/>
							<span id="a4" draggable="true">No, he doesn't</span><br/>
							<span id="a5" draggable="true">Yes, I do</span><tab/>
							<span id="a6" draggable="true">Yes, it does</span><tab/>
							<span id="a7" draggable="true">No, I don't</span><tab/>
							<span id="a8" draggable="true">Yes, she does</span>
						</section>
						
						<section id="body">
							<img class="rightFloat" src="../../media/hairwash.png" />
							
							<list id="questionList">
								<li>
									Do you wash your hair every day?<br/>
									<input id="q1Input" type="droptarget" />
								</li>
								
								<li>
									Does your mother cook every night?<br/>
									<input id="q2Input" type="droptarget" />
								</li>
								
								<li>
									Do you play tennis?<br/>
									<input id="q3Input" type="droptarget" />
								</li>
								
								<li>
									Do you go to school?<br/>
									<input id="q4Input" type="droptarget" />
								</li>
								
								<li>
									Do you often travel by plane?<br/>
									<input id="q5Input" type="droptarget" />
								</li>
								
								<li>
									Does your father play golf?<br/>
									<input id="q6Input" type="droptarget" />
								</li>
								
								<li>
									Do you have a bicycle?<br/>
									<input id="q7Input" type="droptarget" />
								</li>
								
								<li>
									Does your house have a garden?<br/>
									<input id="q8Input" type="droptarget" />
								</li>
								
								<li>
									Does your town have a cinema?<br/>
									<input id="q9Input" type="droptarget" />
								</li>
							</list>
						</section>
					</body>
					
				</bento>
			);
		}
		
		[After]
		public function tearDown():void {
			xhtml = null;
		}
		
		[Test]
		public function testAddClass():void {
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testGet_body():void {
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testGetElementById():void {
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testGetHeader():void {
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testHasClass():void {
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testHasHeader():void {
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testIsExternalStylesheetsLoaded():void {
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testSelect():void {
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testSelectOne():void {
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testToggleClass():void {
			Assert.fail("Test method Not yet implemented");
		}
	}
}
