// ActionScript Document
// Exercise behaviour constants used in current Author Plus
// v6.3.3 change mode to settings
/*
_global.ORCHID.exMode = new Object();

//_global.ORCHID.exMode.DelayedMarking = 0; // use NOT instantMarking
_global.ORCHID.exMode.InstantMarking = 1;
_global.ORCHID.exMode.ChooseMarking = 512;
_global.ORCHID.exMode.NeutralMarking = 128;
//_global.ORCHID.exMode.MarkingDone = 4096;  // this is only set programmatically

_global.ORCHID.exMode.QuestionFeedback = 16; // default
//_global.ORCHID.exMode.ScoreFeedback = 32; // use NOT QuestionFeedback + can only work with delayed marking
_global.ORCHID.exMode.IndividualFeedback = 2; // the opposite (and default) is group feedback
//_global.ORCHID.exMode.GroupFeedback = 0 // use NOT individualFeedback
// v6.2 to allow author control over fb being shown for q they got right or not
_global.ORCHID.exMode.OnlyWrongFeedback = 32;

_global.ORCHID.exMode.AllowEditing = 256;
// this exercise level setting controls the collection of 'incorrect' clicks when not on a target
_global.ORCHID.exMode.HiddenTargets = 1024;
// this setting would control only the colouring of answers and wording of rubric
_global.ORCHID.exMode.ProofReading = 2048;
_global.ORCHID.exMode.OverwriteAnswers = 8192;
// settings for split window, although this will probably be handled differently
_global.ORCHID.exMode.SplitWindow  = 16384;

// button display
_global.ORCHID.exMode.RuleButton = 4; // default is off
_global.ORCHID.exMode.NoFeedbackButton = 64; // default is on
_global.ORCHID.exMode.NoMarkingButton = 8; // default is on
// I really don't think this should be an exercise mode setting, ditto MarkingDone
_global.ORCHID.exMode.ResourcesButton = 32768 // this is only set programmatically
// v6.3 New mode for drag and drop behaviour
_global.ORCHID.exMode.OnlyDragOnce = 65536 // default is to allow many drags
*/
// CUP noScroll code
// constants used to register which regions an exerise is currently showing
_global.ORCHID.regionMode = new Object();
_global.ORCHID.regionMode.body = 0;
_global.ORCHID.regionMode.title = 1;
_global.ORCHID.regionMode.noScroll = 2;
_global.ORCHID.regionMode.example = 4;
_global.ORCHID.regionMode.readingText = 8;

// Field behaviour constants 
// v6.3.3 These are not used in the current code
_global.ORCHID.fieldMode = new Object();
//_global.ORCHID.fieldMode.GroupFeedback = 1;
// this might be easier for Author Plus if at the exercise level
// try to let Orchid cope with both though
//_global.ORCHID.fieldMode.TargetMC = the default;
_global.ORCHID.fieldMode.TargetHidden = 2;
_global.ORCHID.fieldMode.TargetError = 4;

// Media behaviour constants 
_global.ORCHID.mediaMode = new Object();
_global.ORCHID.mediaMode.PlayAnyTime = 1;
_global.ORCHID.mediaMode.ShowAfterMarking = 2;
_global.ORCHID.mediaMode.AutoPlay = 4;
_global.ORCHID.mediaMode.ReadingText = 8; // don't like this one bit - not sure it is still valid
_global.ORCHID.mediaMode.PopUp = 16; // can apply to images, video, animation - 
									//means you see a button rather than the real thing at first
_global.ORCHID.mediaMode.PushTextDown = 32; // image will cause text to move down
_global.ORCHID.mediaMode.PushTextRight = 64; // image will cause text to move right
_global.ORCHID.mediaMode.DisplayUnder = 128; // the image will be displayed under any text

//scaffold behaviour constants
//v6.4.2 Use enabled flag to show if a file has been added to CE content by AP
//v6.4.1.5 Edited means look in the editedFolder to find it. noneditable means APP cannot open the file.
// v6.5.2 autoplay for menu items - currently only works on first exercise
_global.ORCHID.enabledFlag = {menuOn:1, 
							navigateOn:2, 
							randomOn:4, 
							disabled:8,
							edited:16,
							noneditable:32,
							autoplay:64,
							nonDisplay:128,
							exitAfter:256};
_global.ORCHID.privacyFlag = {privateOn:1, groupOn:2, publicOn:4};
// marking constants
_global.ORCHID.marking = new Object();
_global.ORCHID.marking.showCorrect = 1;
_global.ORCHID.marking.showWrong = 2;
_global.ORCHID.marking.showSkipped = 4;
_global.ORCHID.marking.showColours = 7;
_global.ORCHID.marking.showAnswers = 8;
_global.ORCHID.marking.showAll = 15;
// v6.3.4 Add in different mode for immediate ticks and crosses
_global.ORCHID.marking.showTicks = 16;
_global.ORCHID.marking.showColoursAndTicks = 23;
// v6.4.2.7 If you want just ticks and not crosses
_global.ORCHID.marking.hideCrosses = 32;

//storing the depths used
// These are coded into the component, so the namespace is wrong for that!
_global.ORCHID.depth = 10; // and this is??
_global.ORCHID.TitleDepth = 101;
_global.ORCHID.ExerciseDepth = 105;
_global.ORCHID.ReadingTextDepth = 106;
// v6.5.6.5 Since we have a problem with Related_Text going under countdown controller, can i just switch these two deptsh?
//_global.ORCHID.FeedbackDepth = 107;
//_global.ORCHID.CountDownControllerDepth = 108;
_global.ORCHID.CountDownControllerDepth = 107;
_global.ORCHID.FeedbackDepth = 108;
_global.ORCHID.MsgBoxDepth = 110;
// CUP noScroll code
_global.ORCHID.noScrollDepth = 104;
_global.ORCHID.exampleDepth = 103;

_global.ORCHID.fieldDepth = 2001; // this is used as a starting point for fields added to any exercise
_global.ORCHID.coverDepth = 4001; // used for drag and drop and maybe more
_global.ORCHID.overlayDepth = 6000; // used to put anything ON TOP of the field covers
_global.ORCHID.mediaDepth = 6001; // this is used as a starting point for pop fields added to any exercise plus pics etc
_global.ORCHID.mediaRelatedDepth = 8001; // If you have anything related to a media added from above
_global.ORCHID.testDepth = 100; // used for any field used to temporarily calculate something
_global.ORCHID.selectDepth = 9001; // used when creating the one drag and gap mcs.
_global.ORCHID.printDepth = 10001; // this seems wrong to have a depth just for this
_global.ORCHID.loadingDepth = 10002; // used for displaying the tlc progress bar
_global.ORCHID.cursorDepth = 10003; // used for changing the cursor icon
_global.ORCHID.backgroundDepth = -13684; // for the background

// v6.4.3 Starting depth for paragraphs in a section so that you can put layers behind
_global.ORCHID.initialParaDepth = 100; // for the background

// used for multimedia playback
_global.ORCHID.jukeBox = "jukeBox.swf";

// used for access control (results manager integration)
// v6.4.2 Add in a field that lets you make this a non-CE login account, so usernames are locally unique only
// v6.5.4.7 Add field that says it is ClarityEnglish.com - which means we will have laredy avlidated.
_global.ORCHID.accessControl = 
		{ACUserNameOnly:1,
		ACStudentIDOnly:2,
		ACUserNameAndStudentID:4,
		ACAllowAnonymous:8,
		ACNonCELogin:16,
		ACAllowChangePassword:32,
		ACCELogin:64,
		ACEmailOnly:128}
		
// path and filenames
// this object is set at the very beginning of control
//_global.ORCHID.paths = new Object();
//_global.ORCHID.paths.course = "";
//_global.ORCHID.paths.root and _global.ORCHID.paths.movie
// cannot be set here because it is already set in control.swf
//_global.ORCHID.paths.root = "";
//_global.ORCHID.paths.movie = "Source/";

// FUI styles
globalStyleFormat.textFont = "Verdana";
globalStyleFormat.textSize   = "12";

// NOT USED anymore - I think!
_global.ORCHID.widthFromLeftBorder = new Array();
_global.ORCHID.heightFromTopBorder = new Array();
_global.ORCHID.fieldArray = new Array;
	