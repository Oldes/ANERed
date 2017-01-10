package
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.TextFormat;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	
	import org.redlang.Red;
	import org.redlang.events.*;
	/**
	 * ...
	 * @author Oldes
	 */
	public class Main extends Sprite 
	{
		
		public var tfOutput:TextField;
		public var tfInput:TextField;
		
		public var history:Vector.<String> = new Vector.<String>();
		public var historyPosition:int = -1;
		private var lastCode:String;
		
		public var tests:Array = [
			"Basic test:",
				'a: 2 b: 21 append "Universe means: " to-char (a * b)',
			"Reading directory test:",
				'foreach file read %. [probe file]',
			"Reading web page and parse it:",
				'parse to-string read http://red-lang.org [thru <title> copy title to </title>] title',
			"Reading file:",
				'print read %Test.red',
			"Evaluating script from file:",
				'do %Test.red'
		];
		private var currentTestPos:int = 0;
		
		public function Main() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			tfOutput = new TextField();
			tfOutput.width = stage.stageWidth;
			tfOutput.height = stage.stageHeight - 20;
			tfOutput.wordWrap = true;
			tfOutput.defaultTextFormat = new TextFormat("Lucida Console", 11);
			
			tfInput = new TextField();
			tfInput.width = stage.stageWidth - 1;
			tfInput.height = 20;
			tfInput.border = true;
			tfInput.borderColor = 0xFF0000;
			tfInput.backgroundColor = 0xFFF0F0;
			tfInput.y = tfOutput.height;
			tfInput.type = TextFieldType.INPUT;
			tfInput.background = true; 
			tfInput.defaultTextFormat = new TextFormat("Lucida Console", 13, 0xFF0000);
			tfInput.addEventListener(KeyboardEvent.KEY_DOWN, onInputCapture);

			addChild(tfOutput);
			addChild(tfInput);
			
			stage.addEventListener(Event.RESIZE, onResize);
			
			if(Red.isSupported) {
				log("Testing Red ANE...");
				Red.instance.addEventListener("RED_PRINT", onRedPrint);
				nextTest();
			} else {
				log("Red ANE is not supported on this platform yet!");
			}
		}
		
		public function nextTest():void {
			if (currentTestPos < tests.length) {
				log("\n" + tests[currentTestPos]);
				doRed(tests[currentTestPos + 1]);
				currentTestPos += 2;
				if (currentTestPos < tests.length) {
					setTimeout(nextTest, 500); //wait 0.5s before next test
				}
			}
		}
		public function doRed(code:String):void {
			if (lastCode != code) {
				historyPosition = history.length;
				history.push(code);
			}
			lastCode = code;
			log(">> " + code);
			log("== " + Red.instance.redDo("mold " +code));
		}
		
		private function onRedPrint(event:RedPrintEvent):void {
			tfOutput.appendText(event.data);
			tfOutput.scrollV = tfOutput.maxScrollV;
		}
		
		private function onResize(event:Event):void {
			tfOutput.width = stage.stageWidth;
			tfInput.width = stage.stageWidth - 1;
			tfOutput.height = tfInput.y = stage.stageHeight - 20;
		}
		public function onInputCapture(event:KeyboardEvent):void 
        { 
			switch(event.keyCode) {
				case Keyboard.ENTER:
					doRed(tfInput.text);
					tfInput.text = "";
					break;
				case Keyboard.DOWN:
					if (historyPosition>=0 && historyPosition < history.length-1) {
						historyPosition++;
						tfInput.text = history[historyPosition];
					}
					break;
				case Keyboard.UP:
					if (historyPosition > 0) {
						historyPosition--;
						tfInput.text = history[historyPosition];
					}
					break;	
					
			}
        } 
		
		private function log(value:String):void {
			trace(value);
			tfOutput.appendText(value+"\n");
			tfOutput.scrollV = tfOutput.maxScrollV;
		}
		
		private function deactivate(e:Event):void 
		{
			// make sure the app behaves well (or exits) when in background
			//NativeApplication.nativeApplication.exit();
		}
		
	}
	
}