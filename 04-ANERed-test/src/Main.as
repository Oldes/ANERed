package
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.TextFormat;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.ui.Keyboard;
	
	import flash.text.TextField;
	
	import org.redlang.Red;
	/**
	 * ...
	 * @author Oldes
	 */
	public class Main extends Sprite 
	{
		
		public var tf:TextField;
		
		public function Main() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			tf = new TextField();
			tf.width = stage.stageWidth;
			tf.height = stage.stageHeight;
			tf.defaultTextFormat = new TextFormat(null, 24);
			addChild(tf);
			
			log("Testing Red ANE...");
			log("Red is supported: " + Red.isSupported);
			log("Hello: " + Red.instance.hello());
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		}
		
		
		private function onKey(event:KeyboardEvent):void {
			switch(event.keyCode) {
				case Keyboard.BACK:
					event.preventDefault();
					event.stopImmediatePropagation();
				break;
			}
		}
		
		private function log(value:String):void {
			trace(value);
			tf.appendText(value+"\n");
			tf.scrollV = tf.maxScrollV;
		}
		
		private function deactivate(e:Event):void 
		{
			// make sure the app behaves well (or exits) when in background
			//NativeApplication.nativeApplication.exit();
		}
		
	}
	
}