package com.wmgllc.twittersphere.view.component.scene
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.wmgllc.twittersphere.controller.event.MessageWindowEvent;
	import com.wmgllc.twittersphere.controller.event.PanicEvent;
	import com.wmgllc.twittersphere.model.entity.MessageDTO;
	import com.wmgllc.twittersphere.model.service.TweetLoader;
	import com.wmgllc.twittersphere.view.away3d.controller.HoverController;
	import com.wmgllc.twittersphere.view.component.loadindicator.LoadIndicator;
	import com.wmgllc.twittersphere.view.component.messagewindow.TweetWindow;
	
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.events.MouseEvent3D;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.loaders.Loader3D;
	import away3d.loaders.parsers.Parsers;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.SkyBox;
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapCubeTexture;
	import away3d.utils.Cast;
	
	import net.hires.debug.Stats;
	
	//	[SWF(backgroundColor="#000000", frameRate="30", quality="BEST")]
	
	public class SphereScene extends Sprite
	{
		// Environment map.
		[Embed(source="../../../../../../../assets/images/stars_sam.jpg")]
		private var EnvPosX:Class;
		[Embed(source="../../../../../../../assets/images/stars_sam.jpg")]
		private var EnvPosY:Class;
		[Embed(source="../../../../../../../assets/images/stars_sam.jpg")]
		private var EnvPosZ:Class;
		[Embed(source="../../../../../../../assets/images/stars_sam.jpg")]
		private var EnvNegX:Class;
		[Embed(source="../../../../../../../assets/images/stars_sam.jpg")]
		private var EnvNegY:Class;
		[Embed(source="../../../../../../../assets/images/stars_sam.jpg")]
		private var EnvNegZ:Class;
		
		// Away3D4 Vars
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		private var cameraController:HoverController;
		
		// Away3D4 Camera handling variables (Hover Camera)
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		// Away3D Config
		private var cameraViewDistance:Number = 100000;
		private var antiAlias:Number = 16;
		
		// Lights
		private var lightPicker:StaticLightPicker;
		private var light2Picker:StaticLightPicker;
		private var light:PointLight;
		private var light2:PointLight;
		
		// Materials        
		private var skyBoxCubeMap:BitmapCubeTexture;
		private var sphereTexture:TextureMaterial;
		
		// Primitives etc
		private var skyBox:SkyBox;
		private var sphereGeometry:SphereGeometry;
		private var centralSphere:Mesh;
		
		private var planeGeom:CustomCubeGeometry;
		
		private var pointLightParamaters:Object;
		
		private var loader:LoadIndicator;
		
		private var twitter:TweetLoader;
		private var tweetCount:int = 0;
		private var meshes:Vector.<TweetMesh>;
		private var geometries:Vector.<CustomCubeGeometry>
		private var recentMeshes:Vector.<TweetMesh>;
		private var windows:Vector.<TweetWindow>;
		private var order:Vector.<uint>;
		
		private var degrees:Number;
		
		private var currentRow:int = 12;
		private var mode:int = 3;
		private var spinDelay:uint;
		private var spinDirection:Number = 0.25;
		private var screensaverDelay:uint;
		private var screensaverWait:uint;
		private var screensaverOn:Boolean;
		private var lastX:Number;
		private var lastY:Number;
		
		private var loader3D:Loader3D;
		
		private var sharedGeom:CustomCubeGeometry=new CustomCubeGeometry(14, 14, 0.05);
		
		private var mustUpdateCamera:Boolean=false;
		private var hoverDinstance:Number;
		
		private var loadStatus:TextField;
		private var format:TextFormat;
		private var updateText:String;
		
		private var sphereRadius:int = 330;
		private var scaling:Number = 0.5;
		private var scaleMin:Number=1;
		private var scaleMax:Number=4;
		private var screenSaverScale:Number = 1.2;
		private var blockTween:Boolean=false;
		
		private var maxTweets:Number=200;
		
		private var isTweetsArranging:Boolean=false;
		
		private var tempDebug:DebugWin;
		private var tweetHolder:Sprite;
		private var spotlight:DirectionalLight;
		private var stats:Stats;
		
		private var baseUrl:String;
		
		public function SphereScene()
		{
		}

		public function initialise(baseUrl:String):void
		{
			this.baseUrl=baseUrl;
			setupAway3D4();
			setupNativeElements();
			
			setupLights();
			setupMaterials();
			
			setupPrimitivesAndModels();
			setupEventListeners();
		}
		
		private function setupNativeElements():void
		{
			tweetHolder = new Sprite();
			addChild(tweetHolder);
		}
		
		private function setupEventListeners():void
		{
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			stage.addEventListener(TransformGestureEvent.GESTURE_ZOOM,this.zoomCamera);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			stage.addEventListener(Event.RESIZE, resizeHandler);
			resizeHandler(); 
			
			stage.addEventListener(Event.ENTER_FRAME,renderHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDown);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, this.keyDown);
		}
		
		private function renderHandler(e:Event):void
		{
			if(meshes.length>=maxTweets) {
				blockTween=true;
			}
			if (this.cameraController.steps > 4)
			{
				(this.cameraController.steps - 1);
			}
			if (this.mode == 1)
			{
				cameraController.panAngle = 0.3 * (stage.mouseX - lastMouseX) + lastPanAngle;
				cameraController.tiltAngle = 0.3 * (stage.mouseY - lastMouseY) + lastTiltAngle;			}
			else if (this.mode == 3)
			{
				this.cameraController.panAngle = this.cameraController.panAngle + this.spinDirection;
			}
			light2.moveTo(this.camera.x, this.camera.y, this.camera.z);
			this.view.render();
		}
		
		private function setupLights():void
		{
			this.light = new PointLight();
			this.light.specular = 0.005;			
			
			this.light2 = new PointLight();
			this.light2.specular = 0.1;
			this.light2.diffuse=.8;
			this.light2.ambient=0.1;
			light2.radius=2000;
			
			this.lightPicker = new StaticLightPicker([this.light]);
			this.light2Picker = new StaticLightPicker([this.light2]);
		}
		
		private function screensaverOpen() : void
		{
			if (this.screensaverOn == false)
			{
				this.screensaverOn = true;
			}
			if(!isTweetsArranging) {
				var count:Number = 0;
				var newScale:Number;
				
				twitter.isWaitingScreensaver=true;
				while (count < this.meshes.length)
				{
					newScale=this.meshes[count].scaleX*screenSaverScale;
					if (count == (this.meshes.length - 1) && this.screensaverOn == true)
					{
						this.meshes[count].currentScale=this.meshes[count].scaleX;
						TweenMax.to(this.meshes[count], 1.5, {ease:Bounce.easeOut,delay:(count*0.005),x:this.meshes[count].x * screenSaverScale, y:this.meshes[count].y * screenSaverScale, z:this.meshes[count].z * screenSaverScale, onComplete:this.nextPhase, onCompleteParams:["close"]});
					}
					else
					{ 
						this.meshes[count].currentScale=this.meshes[count].scaleX;
						TweenMax.to(this.meshes[count], 1.5, {ease:Bounce.easeOut,delay:(count*0.005), x:this.meshes[count].x * screenSaverScale, y:this.meshes[count].y * screenSaverScale, z:this.meshes[count].z * screenSaverScale});
					}
					count++;
				}
			} else {
				setTimeout(screensaverOpen,1000);
			}
		}
		
		private function screensaverClose() : void
		{
			setTimeout(this.screensaverCloseDo, 10000);
			twitter.isWaitingScreensaver=false;
		}
		
		private function screensaverCloseDo() : void
		{
			var _loc_1:Number = this.meshes.length-1;
			var delayCount:Number=0;
			twitter.isWaitingScreensaver=true;
			while (_loc_1 >= 0)
			{
				if (_loc_1 == 1 && this.screensaverOn == true)
				{
					
					TweenMax.to(this.meshes[_loc_1], 1.5, {ease:Bounce.easeOut,delay:(delayCount*0.005), x:this.meshes[_loc_1].origX, y:this.meshes[_loc_1].origY, z:this.meshes[_loc_1].origZ, onComplete:this.nextPhase, onCompleteParams:["open"]});
				}
				else
				{
					TweenMax.to(this.meshes[_loc_1], 1.5, {ease:Bounce.easeOut,delay:(delayCount*0.005),x:this.meshes[_loc_1].origX, y:this.meshes[_loc_1].origY, z:this.meshes[_loc_1].origZ});
				}
				delayCount++;
				_loc_1--;
			}
		}
		
		private function nextPhase(param1 : String) : void
		{
			twitter.isWaitingScreensaver=false;
			if (param1 == "open")
			{
				this.screensaverDelay = setTimeout(this.screensaverOpen, 1000);
			}
			else if (param1 == "close")
			{
				this.screensaverDelay = setTimeout(this.screensaverClose, 1000);
			}
		}
		
		private function setupAway3D4():void
		{
			scene = new Scene3D();
			
			camera = new Camera3D();
			camera.lens.far = cameraViewDistance;
			
			view = new View3D();
			view.width=400;
			view.height=400;
			view.scene = scene;
			view.camera = camera;
			view.antiAlias = antiAlias;
			
			addChild(view);
			
			cameraController = new HoverController(this.camera);
			cameraController.yFactor=1.5;
			cameraController.distance = 800;
			cameraController.minTiltAngle = -45;
			cameraController.maxTiltAngle = 45;
			cameraController.panAngle = 45;
			cameraController.tiltAngle = 20;
			cameraController.steps=4;
			cameraController.autoUpdate=true;
			
			loader = new LoadIndicator();
			addChild(this.loader);
			loader.init();
			loader.x = stage.stageWidth / 2;
			loader.y = stage.stageHeight / 2;
			
			stage.displayState=StageDisplayState.FULL_SCREEN_INTERACTIVE;
			
			this.twitter = new TweetLoader(maxTweets,baseUrl);
			this.meshes = new Vector.<TweetMesh>;
			this.geometries = new Vector.<CustomCubeGeometry>;
			this.recentMeshes = new Vector.<TweetMesh>;
			this.windows = new Vector.<TweetWindow>(8, true);
			this.order = new Vector.<uint>;
			this.twitter.getTweets();
			this.twitter.addEventListener("tweetsLoaded", this.initTweetDisplay);
			this.twitter.addEventListener(PanicEvent.PANIC_EVENT,killaTweet);
		}
		
		private function initTweetDisplay(e:Event):void {
			
			loader.newMessage("Setting Up Tweets...");
			onRowLoader();
		}
		
		private function onRowLoader() : void
		{
			if(!twitter.tweets)
			{
				return;
			}
			if (this.tweetCount == this.twitter.tweets.length || this.tweetCount>=maxTweets)
			{
				this.setupBall();
				return;
			}
			
			var max : Number;
			
			if(this.twitter.tweets.length < maxTweets) {
				max=twitter.tweets.length;
			} else {
				max=maxTweets;
			}
			loader.loadStatus.text=("PLEASE WAIT "+tweetCount.toString()+"/"+String(max))
			
			var tweetMeshInstance:TweetMesh = new TweetMesh();
			
			var planeGeomInstance:CustomCubeGeometry = new CustomCubeGeometry(14, 14, 0.05);
			
			tweetMeshInstance.init(this.twitter.tweets[this.tweetCount], planeGeomInstance, false, twitter.messages[tweetCount]);
			tweetMeshInstance.addEventListener("profileLoaded", this.showMesh);
			tweetMeshInstance.moveTo(1,1,1);
			
			this.meshes.push(tweetMeshInstance);
			this.geometries.push(planeGeomInstance);
			this.scene.addChild(tweetMeshInstance);
			if(tweetCount==0) {
				tweetMeshInstance.visible=false;
			}
			tweetMeshInstance = null;
			
			tweetCount+=1;
		}
		
		private function moveTweets():void 
		{
			isTweetsArranging=true;
			setTimeout(finishMoveTweets,1100);
			
			var newScale:Number=Scale(meshes.length,50,600,4,1.35);
			
			var l:Number=this.meshes.length;
			var tweetMeshInstance:TweetMesh;
			var destx:Number;
			var desty:Number;
			var destz:Number;
			
			for (var i:Number=0;i<this.meshes.length;i++){
				
				tweetMeshInstance=meshes[i];
				
				var phi:Number = Math.acos( -1 + ( 2 * i ) / l );
				var theta:Number = Math.sqrt( l * Math.PI ) * phi;
				
				tweetMeshInstance.origX = (sphereRadius+5) * Math.cos( theta ) * Math.sin( phi );
				tweetMeshInstance.origY= (sphereRadius+5) * Math.sin( theta ) * Math.sin( phi );
				tweetMeshInstance.origZ = (sphereRadius+5) * Math.cos( phi );
				
				destx=sphereRadius * Math.cos( theta ) * Math.sin( phi );
				desty=sphereRadius * Math.sin( theta ) * Math.sin( phi );
				destz=sphereRadius * Math.cos( phi );
				
				TweenMax.to(tweetMeshInstance, 1, {scaleX:newScale,scaleY:newScale,x:destx,y:desty,z:destz,onUpdate:onLookAtTween, onUpdateParams:[tweetMeshInstance]});
			}
		}
		
		private function onLookAtTween(theMesh:TweetMesh):void 
		{
			theMesh.lookAt(new Vector3D());
		}
		
		private function finishMoveTweets():void 
		{
			isTweetsArranging=false;
		}
		
		private function showMesh(event:Event) : void
		{
			var _loc_2:TweetMesh = event.currentTarget as TweetMesh;
			_loc_2.visible = true;
			_loc_2.removeEventListener("profileLoaded", this.showMesh);
			_loc_2.mouseEnabled = true;
			_loc_2.addEventListener(MouseEvent3D.CLICK, this.tweetClick);
			_loc_2.material.lightPicker = this.light2Picker;
			_loc_2 = null;
			
			moveTweets();
			
			this.onRowLoader();
		}
		
		private function tweetClick(param1:MouseEvent3D = null, param2:TweetMesh = null) : void
		{
			var currentMesh:TweetMesh = null;
			var _loc_6:* = NaN;
			var _loc_9:* = 0;
			var _loc_10:* = null;
			if (param1 != null)
			{
				currentMesh = param1.currentTarget as TweetMesh;
				TweenMax.to(currentMesh, 0.3, {x:currentMesh.x * 1.15, y:currentMesh.y * 1.15, z:currentMesh.z * 1.15, onComplete:this.onFinishClickTween, onCompleteParams:[currentMesh]});
			}
			else if (param2 != null)
			{
				currentMesh = param2;
			}
			
			var _loc_4:* = new Object();
			
			
			var tweetLocation:Vector3D = this.getStagePosition(this.camera, currentMesh);
			
			if (currentMesh.tweetImage != null)
			{
				_loc_6 = 0.4;
			}
			else
			{
				_loc_6 = 0.5;
			}
			
			dispatchEvent(new MessageWindowEvent(MessageWindowEvent.OPEN_WINDOW, currentMesh.messageDTO, currentMesh));
			
//			var tweetWinInstance:TweetWindow = new TweetWindow();
//			tweetWinInstance.init(currentMesh.tweetName, currentMesh.tweetText, currentMesh.tweetProfile, currentMesh.tweetDate, currentMesh.tweetImage, _loc_6);
//			tweetWinInstance.tweetRef = currentMesh;
//			tweetWinInstance.addEventListener("windowTouch", this.touchWindow);
//			tweetHolder.addChild(tweetWinInstance);
//			
//			_loc_4.width = tweetWinInstance.width;
//			_loc_4.height = tweetWinInstance.height;
//			var _loc_8:Array = new Array();
//			var _loc_11:Number = 0;
//			while (_loc_11 < this.windows.length)
//			{
//				
//				if (this.windows[_loc_11] == null)
//				{
//					_loc_8.push(_loc_11);
//				}
//				_loc_11 = _loc_11 + 1;
//			}
//			if (_loc_8.length == 0 || param2 != null && _loc_8.length <= 3)
//			{
//				this.closeWindow(null, this.windows[this.order[0]]);
//				this.windows[this.order[0]] = tweetWinInstance;
//				_loc_10 = this.calculatePositions(this.order[0]);
//				this.order.push(this.order.shift());
//			}
//			else
//			{
//				_loc_9 = this.randomNumber((_loc_8.length - 1));
//				this.windows[_loc_8[_loc_9]] = tweetWinInstance;
//				_loc_10 = this.calculatePositions(_loc_8[_loc_9]);
//				this.order.push(_loc_8[_loc_9]);
//			}
//			tweetWinInstance.alpha = 0.2;
//			var _loc_12:Number = currentMesh.planeSize;
//			tweetWinInstance.height = currentMesh.planeSize;
//			tweetWinInstance.width = _loc_12;
//			
//			tweetWinInstance.x = tweetLocation.x;
//			tweetWinInstance.y = tweetLocation.y;
//			tweetWinInstance.z = tweetLocation.z;
//			if(!TweenMax.isTweening(tweetWinInstance)) {
//				TweenMax.to(tweetWinInstance, 0.8, {alpha:1, x:_loc_10.x, y:_loc_10.y, z:0, rotationX:0, rotationY:0, rotationZ:0, width:_loc_4.width, height:_loc_4.height});
//			}
//			currentMesh = null;
//			_loc_4 = null;
//			tweetLocation = null;
//			tweetWinInstance = null;
//			_loc_10 = null;
//			_loc_8 = null;
		}
		
		private function touchWindow(event:Event) : void
		{
			event.currentTarget.addEventListener("windowRelease", this.releaseWindow);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, this.mouseDown);
		}
		
		private function releaseWindow(event:Event) : void
		{
			if (event.currentTarget.canTap == true)
			{
				this.closeWindow(event);
			}
			stage.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDown);
			event.currentTarget.removeEventListener("windowRelease", this.releaseWindow);
		}
		
		private function mouseDown(event:MouseEvent) : void
		{
			var _loc_2:* = undefined;
			clearTimeout(this.spinDelay);
			clearTimeout(this.screensaverDelay);
			clearTimeout(this.screensaverWait);
			this.spinDelay = 0;
			this.screensaverDelay = 0;
			this.screensaverWait = 0;
			
			if (this.screensaverOn == true)
			{
				twitter.isWaitingScreensaver=true;
				
				this.screensaverOn = false;
				this.screensaverClose();
				_loc_2 = 0;
				while (_loc_2 < this.windows.length)
				{
					
					if (this.windows[_loc_2] != null)
					{
						this.closeWindow(null, this.windows[_loc_2], "on");
					}
					_loc_2 = _loc_2 + 1;
				}
			}
			stage.addEventListener(MouseEvent.MOUSE_UP, this.mouseUp);
			this.lastPanAngle = this.cameraController.panAngle;
			this.lastTiltAngle = this.cameraController.tiltAngle;
			this.lastX = stage.mouseX;
			this.lastY = stage.mouseY;
			this.mode = 1; 
		}
		
		private function mouseUp(event:MouseEvent) : void
		{
			this.mode = 2;
			this.spinDelay = setTimeout(this.resumeSpinning, 3000);
			stage.removeEventListener(MouseEvent.MOUSE_UP, this.mouseUp);
			if (this.cameraController.panAngle < this.lastPanAngle)
			{
				this.spinDirection = -0.25;
			}
			else if (this.cameraController.panAngle > this.lastPanAngle)
			{
				this.spinDirection = 0.25;
			}
			this.screensaverWait = setTimeout(this.screensaverOpen, 16000);
		}
		
		private function resumeSpinning() : void
		{
			clearTimeout(this.spinDelay);
			this.spinDelay = 0;
			if (this.cameraController.tiltAngle < 0 || this.cameraController.tiltAngle > 20)
			{
				this.cameraController.tiltAngle = 10;
				this.cameraController.steps = 30;
			}
			this.mode = 3;
		}
		
		private function onFinishClickTween(param1:TweetMesh) : void
		{
			TweenMax.to(param1, 0.4, {x:param1.x / 1.15, y:param1.y / 1.15, z:param1.z / 1.15});
		}
		
		private function closeWindow(event:Event = null, param2:TweetWindow = null, param3:String = "off") : void
		{
			var _loc_4:* = undefined;
			var _loc_6:* = undefined;
			var _loc_7:* = undefined;
			if (event != null)
			{
				_loc_4 = event.currentTarget;
				_loc_6 = 0;
				while (_loc_6 < this.windows.length)
				{
					
					if (_loc_4 == this.windows[_loc_6])
					{
						this.windows[_loc_6] = null;
						this.order.splice(this.order.indexOf(_loc_6), 1);
					}
					_loc_6 = _loc_6 + 1;
				}
			}
			else if (param2 != null)
			{
				_loc_4 = param2;
				if (param3 == "on")
				{
					_loc_7 = 0;
					while (_loc_7 < this.windows.length)
					{
						
						if (_loc_4 == this.windows[_loc_7])
						{
							this.windows[_loc_7] = null;
							this.order.splice(this.order.indexOf(_loc_7), 1);
						}
						_loc_7 = _loc_7 + 1;
					}
				}
			}
			var _loc_5:* = this.getStagePosition(this.camera, _loc_4.tweetRef);
			TweenMax.to(_loc_4, 0.4, {alpha:0.2, x:_loc_5.x, y:_loc_5.y, z:_loc_5.z, width:_loc_4.tweetRef.planeSize, height:_loc_4.tweetRef.planeSize, onComplete:this.destroyWindow, onCompleteParams:[_loc_4]});
			_loc_4.removeEventListener("windowTouch", this.touchWindow);
			_loc_4 = null;
			_loc_5 = null;
		}
		
		private function destroyWindow(param1:TweetWindow) : void
		{
			if (tweetHolder.contains(param1))
			{
				while (param1.numChildren) 
				{
					param1.removeChildAt(0);
				}
				tweetHolder.removeChild(param1);
			}
		}
		
		public function getTweetPosition(tweet : TweetMesh):Vector3D
		{
			return getStagePosition(camera, tweet);
		}
		
		private function getStagePosition(cam:Camera3D, obj:ObjectContainer3D) : Vector3D
		{
			var pv:Vector3D;
			
			try{
				var camT:Matrix3D = cam.viewProjection.clone(); 
				var planT:Matrix3D = obj.sceneTransform.clone(); 
				
				camT.prepend(planT);
				pv = Utils3D.projectVector(camT, new Vector3D()); 
				pv.x = (pv.x * stage.stageWidth / 2) + stage.stageWidth / 2;
				pv.y  = (pv.y*-1 * stage.stageHeight / 2) + stage.stageHeight / 2;
			}catch(error : TypeError)
			{
				pv = new Vector3D(stage.stageWidth / 2, stage.stageHeight / 2);
			}
			
			return pv; 
		}
		
		private function killaTweet(e:PanicEvent):void 
		{
			var currentTweet:TweetMesh;
			for(var i:int=0; i<this.meshes.length; i++) 
			{
				currentTweet=this.meshes[i];
				if(currentTweet.sourceID==e.sourceID) 
				{
					currentTweet = this.meshes[i];
					var tempGeom:CubeGeometry=this.geometries[i];
					this.meshes.splice(i,1);
					this.geometries.splice(i,1);
					TweenMax.to(currentTweet, 1, {scaleX:0,scaleY:0,scaleZ:0, x:0,y:0,z:0, onComplete:killTweetMesh, onCompleteParams:[currentTweet,tempGeom]});
					currentTweet=null;
					tempGeom=null;
					break;
				}
			}
		}
		
		private function displayNewTweet(event:Event) : void
		{
			var planeGeomInstance:CustomCubeGeometry = new CustomCubeGeometry(14, 14, 0.05);
			if(this.meshes.length>=maxTweets) 
			{
				var pos:Number=Math.floor( Math.random() * this.meshes.length )
				var _loc_2:TweetMesh = this.meshes[pos];
				var tempGeom:CubeGeometry=this.geometries[pos];
				var _loc_3:TweetMesh = new TweetMesh();
				_loc_3.init(this.twitter.tweets[0], planeGeomInstance, false, twitter.messages[0]);
				_loc_3.x = _loc_2.x;
				_loc_3.y = _loc_2.y;
				_loc_3.z = _loc_2.z;
				_loc_3.origX = _loc_2.origX;
				_loc_3.origY = _loc_2.origY;
				_loc_3.origZ = _loc_2.origZ;
				_loc_3.lookAt(new Vector3D(0, 0, 0));
				_loc_3.addEventListener("profileLoaded", this.showTweet);
				this.meshes.splice(pos,1);
				this.geometries.splice(pos,1);
				this.meshes.push(_loc_3);
				this.geometries.push(planeGeomInstance);
				TweenMax.to(_loc_2, 1, {scaleX:0,scaleY:0,scaleZ:0, x:0,y:0,z:0, onComplete:killTweetMesh, onCompleteParams:[_loc_2,tempGeom]});
				tempGeom=null;
				_loc_2=null;
			} else 
			{
				var newMesh:TweetMesh = new TweetMesh();
				newMesh.init(this.twitter.tweets[0], planeGeomInstance, false, twitter.messages[0]);
				newMesh.moveTo(1,1,1);
				newMesh.lookAt(new Vector3D(0, 0, 0));
				newMesh.addEventListener("profileLoaded", this.showTweet);
				this.meshes.push(newMesh);
				this.geometries.push(planeGeomInstance);
			}
			planeGeomInstance=null;
		}
		
		private function killTweetMesh(theMesh:TweetMesh,tempGeom:CustomCubeGeometry):void {
			view.scene.removeChild(theMesh);
			theMesh.kill();
			theMesh.material.dispose();
			tempGeom.dispose();
			theMesh.geometry.dispose();
			theMesh=null;
			tempGeom=null;
		}
		
		private function showTweet(event:Event) : void
		{
			var _loc_2:TweetMesh = event.currentTarget as TweetMesh;
			_loc_2.removeEventListener("profileLoaded", this.showTweet);
			_loc_2.visible = true;
			_loc_2.mouseEnabled = true;
			_loc_2.addEventListener(MouseEvent3D.CLICK, this.tweetClick);
			_loc_2.material.lightPicker = this.light2Picker;
			
			moveTweets();
			this.scene.addChild(_loc_2);
			this.tweetClick(null, _loc_2);
			_loc_2 = null;
		}
		
		private function setupBall() : void
		{
			moveTweets();
			this.screensaverWait = setTimeout(this.screensaverOpen, 30000);
			setTimeout(this.twitter.getTweets, 15000);
			TweenMax.to(this.loader, 0.3, {alpha:0});
			this.twitter.addEventListener("newTweet", this.displayNewTweet);
		}
		
		private function zoomCamera(event:TransformGestureEvent) : void
		{
			if(event.phase!="end") {
				twitter.isWaitingScreensaver=true;
				var _loc_2:* = undefined;
				clearTimeout(this.spinDelay);
				clearTimeout(this.screensaverDelay);
				clearTimeout(this.screensaverWait);
				this.spinDelay = 0;
				this.screensaverDelay = 0;
				this.screensaverWait = 0;
				if (this.screensaverOn == true)
				{
					this.screensaverOn = false;
					this.screensaverClose();
					_loc_2 = 0;
					while (_loc_2 < this.windows.length)
					{
						if (this.windows[_loc_2] != null)
						{
							this.closeWindow(null, this.windows[_loc_2]);
						}
						_loc_2 = _loc_2 + 1;
					}
				}
				var dinst:Number=this.cameraController.distance / event.scaleX;
				
				if (dinst >= 900)
				{
					dinst=900;
				}
				else if (dinst <= 643)
				{
					dinst=643;
				} 
				hoverDinstance=dinst;
				if(! isNaN(dinst)) 
				{
					this.cameraController.distance=dinst;
				}
				mustUpdateCamera=true;
			} else 
			{
				twitter.isWaitingScreensaver=false;
				this.screensaverWait = setTimeout(this.screensaverOpen, 10000);
				this.spinDelay = setTimeout(this.resumeSpinning, 3000);
			}
		}
		
		private function updateZoom(): void 
		{
			this.cameraController.update();
		}
		
		private function keyDown(event:KeyboardEvent) : void
		{
			if (event.keyCode == 38)
			{
				this.cameraController.distance = this.cameraController.distance + 5;
			}
			else if (event.keyCode == 40)
			{
				this.cameraController.distance = this.cameraController.distance - 5;
			}
		}
		
		private function setupMaterials():void
		{
			skyBoxCubeMap = new BitmapCubeTexture(Cast.bitmapData(EnvPosX), Cast.bitmapData(EnvNegX), Cast.bitmapData(EnvPosY), Cast.bitmapData(EnvNegY), Cast.bitmapData(EnvPosZ), Cast.bitmapData(EnvNegZ));
		}
		
		private function setupPrimitivesAndModels():void
		{
			skyBox = new SkyBox(skyBoxCubeMap);
			scene.addChild(skyBox);
			Parsers.enableAllBundled();
			
			loader3D=new Loader3D();
			loader3D.addEventListener(LoaderEvent.RESOURCE_COMPLETE,onResourceComplete);
			loader3D.addEventListener(LoaderEvent.LOAD_ERROR,onLoadResourceError);
			loader3D.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			loader3D.load(new URLRequest("models/nbaball2014.awd"));
		}
		
		private function onAssetComplete(event :AssetEvent) : void 
		{
			if (event.asset.assetType == "mesh") {
				var mesh : Mesh = event.asset as Mesh;
				mesh.material.lightPicker=light2Picker;
				mesh.material.mipmap=false;
			}
		}
		
		private function onResourceComplete(ev : LoaderEvent) : void
		{
			loader3D.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			loader3D.removeEventListener(LoaderEvent.LOAD_ERROR, onLoadResourceError);
			loader3D.scaleX=loader3D.scaleY=loader3D.scaleZ=0.5;
			scene.addChild(loader3D);
		}
		
		private function onLoadResourceError(ev : LoaderEvent) : void
		{
			trace("SphereScene :: onLoadResourceError :: " + ev.message);
			loader3D.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			loader3D.removeEventListener(LoaderEvent.LOAD_ERROR, onLoadResourceError);
			loader3D = null;
		}
		
		private function mouseDownHandler(e:MouseEvent):void
		{
			lastPanAngle = cameraController.panAngle;
			lastTiltAngle = cameraController.tiltAngle;
			lastMouseX = stage.mouseX;
			lastMouseY = stage.mouseY;
			move = true;
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		private function mouseUpHandler(e:MouseEvent):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		private function onStageMouseLeave(e:Event):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		private function resizeHandler(e:Event=null):void
		{
			if(stage.stageWidth >= 800 && stage.stageHeight>600){
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
			view.width = stage.stageWidth;
			view.height = stage.stageHeight;
			loader.x = stage.stageWidth / 2;
			loader.y = stage.stageHeight / 2;
		}
		
		private function calculatePositions(param1 : int) : Point
		{
			var _loc_2:Point;
			var _loc_3:Number = 25;
			if (param1 == 0)
			{
				_loc_2 = new Point(_loc_3, _loc_3);
			}
			else if (param1 == 1)
			{
				_loc_2 = new Point(_loc_3, stage.stageHeight / 4 + _loc_3);
			}
			else if (param1 == 2)
			{
				_loc_2 = new Point(_loc_3, stage.stageHeight / 4 * 2 + _loc_3);
			}
			else if (param1 == 3)
			{
				_loc_2 = new Point(_loc_3, stage.stageHeight / 4 * 3 + _loc_3);
			}
			else if (param1 == 4)
			{
				_loc_2 = new Point(stage.stageWidth - this.windows[param1].realWidth - _loc_3, _loc_3);
			}
			else if (param1 == 5)
			{
				_loc_2 = new Point(stage.stageWidth - this.windows[param1].realWidth - _loc_3, stage.stageHeight / 4 + _loc_3);
			}
			else if (param1 == 6)
			{
				_loc_2 = new Point(stage.stageWidth - this.windows[param1].realWidth - _loc_3, stage.stageHeight / 4 * 2 + _loc_3);
			}
			else if (param1 == 7)
			{
				_loc_2 = new Point(stage.stageWidth - this.windows[param1].realWidth - _loc_3, stage.stageHeight / 4 * 3 + _loc_3);
			}
			return _loc_2;
		}
		
		private function randomNumber(param1:Number, param2:Number = 0) : Number
		{
			return Math.floor(Math.random() * (param1 - param2 + 1)) + param2;
		}
		
		public function Scale(elementToScale:Number, rangeMin:Number, rangeMax:Number, scaledRangeMin:Number, scaledRangeMax:Number):Number
		{
			if(elementToScale<rangeMin) {
				elementToScale=rangeMin;
			}
			if(elementToScale>rangeMax) {
				elementToScale=rangeMax;
			}
			var scaled:Number = scaledRangeMin + ((elementToScale - rangeMin) * (scaledRangeMax - scaledRangeMin) / (rangeMax - rangeMin));
			return scaled;
		}
	}
}