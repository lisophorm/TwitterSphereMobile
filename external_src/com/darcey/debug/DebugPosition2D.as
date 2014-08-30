package com.darcey.debug
{	
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	
	public class DebugPosition2D
	{
		private var stage:Stage;
		private var target:*;
		private var debugBox:DebugBox;
		
		public function DebugPosition2D(stage:Stage,target:*,debugBox:DebugBox=null)
		{
			this.stage = stage;
			this.target = target;
			this.debugBox = debugBox;
			
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			stage.addEventListener( KeyboardEvent.KEY_UP, keyUpHandler );
			
			trace("DebugPosition2D(): Attached to [" + target + "] name: [" + target.name + "]");
			addToDebugBox("DebugPosition2D(): Attached to [" + target + "] name: [" + target.name + "]");
		}
		
		private var shiftKeyPressed:Boolean = false;
		private var nStep:Number = 1;
		
		private function keyDownHandler( e:KeyboardEvent ):void
		{
			var keyCodeRecognised:Boolean = false;
			
			if (shiftKeyPressed){
				
			}
			
			switch (e.keyCode)
			{
				case 38: // up
					target.y -= nStep;
					keyCodeRecognised = true;
					break;
				case 40: // down
					target.y += nStep;
					keyCodeRecognised = true;
					break;
				case 37: // left
					target.x -= nStep;
					keyCodeRecognised = true;
					break;
				case 39: // right
					target.x += nStep;
					keyCodeRecognised = true;
					break;
				
				case 16: // shift key
					shiftKeyPressed = true;
					break;
				
				case 107: // keypad +
					nStep++;
					keyCodeRecognised = true;
					break;
				
				case 187: // +
					nStep++;
					keyCodeRecognised = true;
					break;
				
				case 109: // keypad -
					nStep--;
					keyCodeRecognised = true;
					break;
				
				case 189: // -
					nStep--;
					keyCodeRecognised = true;
					break;
				
				
				case 90: // z
					target.width += 1;
					keyCodeRecognised = true;
					break;
				
				case 88: // x
					target.width -= 1;
					keyCodeRecognised = true;
					break;
				
				case 67: // c
					target.height += 1;
					keyCodeRecognised = true;
					break;
				
				case 86: // v
					target.height -= 1;
					keyCodeRecognised = true;
					break;
			}
			
			if (keyCodeRecognised){
				msg = "DEBUG nStep:[" + nStep + "] target:["+target+"]   x:" + target.x + "   y:" + target.y + "   w:" + target.width + "   h:" + target.height;
				trace(msg);
				addToDebugBox(msg);
				if (!target.visible)
				{
					msg = "Warning: " + target + " visible = false";
					trace(msg);
					addToDebugBox(msg);
				}
			} else {
				msg = "DebugPosition2D(): key code not recognised keycode = " + e.keyCode;
				trace(msg);
				addToDebugBox(msg);
			}
			
		}
		
		private var msg:String;
		
		
		private function keyUpHandler(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case 16: // shift key
					shiftKeyPressed = false;
					break;
			}
		}
		
		
		public function dispose():void
		{
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			stage.removeEventListener( KeyboardEvent.KEY_UP, keyUpHandler );
		}
		
		
		
		
		// ----------------------------------------------------------------------------------------
		private function addToDebugBox(str:String):void
		{
			if (debugBox)
			{
				debugBox.add(str);				
			}
		}
		// ----------------------------------------------------------------------------------------
	}
}