package
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.TextFormat;
	
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	

	
	
	import org.redlang.Red;
	import org.redlang.events.*;
	/**
	 * ...
	 * @author Oldes
	 */
	public class Main extends Sprite 
	{
		public var tests:Array = [
			"Basic test:",
				'a: 2 b: 21 append "Universe means: " to-char (a * b)',
			"Reading directory test:",
				'foreach file read %. [probe file]',
			"Reading file:",
				'print read %Test.red',
			"Evaluating script from file:",
				'do %Test.red',
			"Error handling:",
				'1 / 0',
			"Reading web page and parse it (blocking until Red will have proper I/O with async):",
				'parse read http://red-lang.org [thru <title> copy title to </title>] title',
		];
		private var currentTestPos:int = 0;
		private var tFormatComment:TextFormat = new TextFormat("_sans", 12, 0x222266, true);
		
		public function Main() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			
			
			if(Red.isSupported) {
				addChild(Red.instance);
				log("Testing Red ANE...");
				Red.instance.resize(stage.stageWidth, stage.stageHeight - 1);
				
				
				stage.addEventListener(Event.RESIZE, onResize);
				Red.instance.addEventListener(Event.ENTER_FRAME, Red.instance.redDoEventLoop);
				nextTest();
			} else {
				trace("Red ANE is not supported on this platform yet!");
			}
		}
		
		private function onResize(event:Event):void {
			Red.instance.resize(stage.stageWidth, stage.stageHeight - 1);
		}
		
		public function nextTest():void {
			if (currentTestPos < tests.length) {
				log("\n" + tests[currentTestPos]);
				Red.instance.doRed(tests[currentTestPos + 1]);
				currentTestPos += 2;
				if (currentTestPos < tests.length) {
					setTimeout(nextTest, 100); //wait some time before next test
				}
			}
		}
		
		
		
		
		private function log(value:String):void {
			trace(value);
			Red.instance.printFormated(value+"\n", tFormatComment);
		}
		
		private function deactivate(e:Event):void 
		{
			Red.instance.dispose();
			// make sure the app behaves well (or exits) when in background
			//NativeApplication.nativeApplication.exit();
		}
		
	}
	
}