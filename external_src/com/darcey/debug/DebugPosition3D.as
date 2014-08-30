package com.darcey.debug
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	
	// ------------------------------------------------------------------------------------------------------------
	public class DebugPosition3D
	{
		// ------------------------------------------------------------------------------------------------------------
		private var stage:Stage;
		public var target:*;
		public var reverseY:Boolean = false;
		public var correctRotationsTo360:Boolean = false;
		private var nStep:Number = 10;
		private var callbackFunction:Function;
		private var dissableTrace:Boolean = false;
		private var db:DebugBox;
		private var msg:String = "";
		// ------------------------------------------------------------------------------------------------------------
		
		
		// ------------------------------------------------------------------------------------------------------------
		public function help():void
		{
			msg = "";
			msg += "#########################################################" + "\n";
			msg += "DebugPosition3D(): Attached to: " + target.name + " (" + typeof(target) + ")\n";
			msg += "DebugPosition3D(): Usage keys" + "\n";
			msg += "DebugPosition3D(): Q + Rotation X" + "   \t   " + "A - Rotation X" + "\n";
			msg += "DebugPosition3D(): W + Rotation Y" + "   \t   " + "S - Rotation Y" + "\n";
			msg += "DebugPosition3D(): E + Rotation Z" + "   \t   " + "E - Rotation Z" + "\n";
			msg += "DebugPosition3D(): Z - Width" + "   \t   " + "X + Width" + "\n";
			msg += "DebugPosition3D(): C - Height" + "   \t   " + "v + Height" + "\n";
			msg += "DebugPosition3D(): R + Movement step" + "   \t   " + "F - Movement step" + "\n";
			msg += "DebugPosition3D(): Move using Arrow keys" + "\n";
			msg += "DebugPosition3D(): H = Show this help message" + "\n";
			msg += "#########################################################";
			trace(msg);
			addToDebugBox(msg);
		}
		// ------------------------------------------------------------------------------------------------------------
		
		
		// ------------------------------------------------------------------------------------------------------------
		public function DebugPosition3D(
			stage:Stage,
			target:*,
			reverseY:Boolean = false,
			correctRotationsTo360:Boolean = false,
			callbackFunction:Function=null,
			dissableTrace:Boolean=false,
			db:DebugBox=null
		)
		{
			this.stage = stage;
			this.target = target;
			this.reverseY = reverseY;
			this.correctRotationsTo360 = correctRotationsTo360;
			this.callbackFunction = callbackFunction;
			this.dissableTrace = dissableTrace;
			this.db = db;
			
			help();
			
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN,handleKeyDown);
		}
		// ------------------------------------------------------------------------------------------------------------
		
		
		
		
		// ------------------------------------------------------------------------------------------------------------
		private function handleKeyDown(e:KeyboardEvent):void
		{
			//trace("handleKeyDown");
			if (callbackFunction!=null){
				callbackFunction();
			}
			
			
			
			
			/*
			81  = q					87 = w				69 = e				82 = r
			65 = a					83 = s				68 = d				70 = f
			38 = up					40 = down			37 = left			39 = right
			189 = keypad -			107 = keypad +
			32 = space
			90 = z
			88 = x
			67 = c
			86 = v
			*/
			
			
			if (target == null){
				msg = "DebugPosition3D(): TARGET IS NULL!!!!";
				addToDebugBox(msg);
				trace(msg);
				return;
			}
			
			switch (e.keyCode){
				
				case 90: target.width -= nStep; traceout(); break; // dec width
				case 88: target.width += nStep; traceout(); break; // inc width
				
				case 67: target.height -= nStep; traceout(); break; // dec width
				case 86: target.height += nStep; traceout(); break; // inc width
				
				
				
				case 32: target.rotationX = 0; target.rotationY = 0; target.rotationZ = 0; break;
				
				case 81: target.rotationX += nStep; traceout(); break;
				case 65: target.rotationX -= nStep; traceout(); break;
				
				case 87: target.rotationY += nStep; traceout(); break;
				case 83: target.rotationY -= nStep; traceout(); break;
				
				case 69: target.rotationZ += nStep; traceout(); break;
				case 68: target.rotationZ -= nStep; traceout(); break;
				
				case 38: target.y += reverseY? -nStep: nStep; traceout(); break;
				case 40: target.y -= reverseY? -nStep: nStep; traceout(); break;
				case 37: target.x -= nStep; traceout(); break;
				case 39: target.x += nStep; traceout(); break;
				case 107: target.z += nStep; traceout(); break;
				case 189: target.z -= nStep; traceout(); break;
				
				case 82: nStep += 1; traceout(); break;
				case 70: nStep -= 1; traceout(); break;
				
				case 72: help(); return; break;
				
				default:
					//msg = "Key press = " + e.keyCode;
					addToDebugBox(msg);
					trace(msg);
					break;
			}
		}
		// ------------------------------------------------------------------------------------------------------------
		
		
		
		
		// ------------------------------------------------------------------------------------------------------------
		private function limitDegreesTo360(degrees:Number):Number
		{
			var rotations:Number = Math.floor(Math.abs(degrees)/360);
			return Math.round(Math.abs(degrees) - (rotations * 360));
		}
		// ------------------------------------------------------------------------------------------------------------
		
		
		
		
		// ----------------------------------------------------------------------------------------
		private function traceout():void
		{
			if (dissableTrace){
				return;
			}
			
			
			msg = "";
			msg += "" + target.name + ":\n";
			
			msg += "" + "x:" + target.x.toFixed(2);
			msg += " " + "y:" + target.y.toFixed(2);
			msg += " " + "z:" + target.z.toFixed(2);
			
			//msg += "\n";
			if (correctRotationsTo360){
				msg += "\t" + "rx:" + limitDegreesTo360(target.rotationX).toFixed(2);
				msg += " " + "ry:" + limitDegreesTo360(target.rotationY).toFixed(2);
				msg += " " + "rz:" + limitDegreesTo360(target.rotationZ).toFixed(2);
			} else {
				msg += "\t" + "rx:" + Math.round(target.rotationX).toFixed(2);
				msg += " " + "ry:" + Math.round(target.rotationY).toFixed(2);
				msg += " " + "rz:" + Math.round(target.rotationZ).toFixed(2);
			}
			
			
			try {
				msg += "\t" + "w:" + target.width.toFixed(2);
				msg += " " + "h:" + target.height.toFixed(2);
			} catch (e:Error) {};
			
			
			//msg += "\n";
			
			msg += "\t" + "step:" + nStep;
			trace(msg);
			addToDebugBox(msg);
		}
		// ----------------------------------------------------------------------------------------
		
		
		
		// ----------------------------------------------------------------------------------------
		private function addToDebugBox(str:String):void
		{
			if (db)
			{
				db.add(str);				
			}
		}
		// ----------------------------------------------------------------------------------------
		
		
		
		
		
		
	}
	// ------------------------------------------------------------------------------------------------------------
	
	
	
	
}