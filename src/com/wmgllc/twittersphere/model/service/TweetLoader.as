package com.wmgllc.twittersphere.model.service 
{
	import com.wmgllc.twittersphere.controller.event.PanicEvent;
	import com.wmgllc.twittersphere.model.entity.MessageDTO;
	import com.wmgllc.twittersphere.utilities.Definitions;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	public class TweetLoader extends Sprite
	{
		private var date:Date;
		private var loader:URLLoader;
		private var cronLoader:URLLoader=new URLLoader();
		private var panicLoader:URLLoader=new URLLoader();
		private var timerCron:Timer;
		private var request:URLRequest;
		private var firstLoad:Boolean = true;
		public var tweets:Object;
		
		private var waitTime:Timer=new Timer(1000);
		public var isWaitingScreensaver:Boolean=false;
		private var haveDisplayTweet:Boolean=false;
		private var numberOfTweets:Number;
		private var panicList:Object=new Object;
		
		public var messages:Vector.<MessageDTO>;
		private var uid : String;
		
		public var base_url:String="http://nba3x.wassermanexperience.com/socialsphere/scripts/";
		
		
		public function TweetLoader(Ntweets:Number,baseUrl:String)
		{
			this.base_url=baseUrl;
			messages = new Vector.<MessageDTO>();
			
			uid = Math.random().toString().split(".")[1];
			
			this.numberOfTweets=Ntweets;
			
			cronLoader.addEventListener(IOErrorEvent.IO_ERROR,cronError);
			panicLoader.addEventListener(IOErrorEvent.IO_ERROR,cronError);
			panicLoader.addEventListener(Event.COMPLETE,this.gotPanic);
			
			waitTime.addEventListener(TimerEvent.TIMER,checkScreenSaver);
			waitTime.start();
			
			this.loader = new URLLoader();
			this.loader.addEventListener(Event.COMPLETE, this.gotTweets);
			this.loader.addEventListener(IOErrorEvent.IO_ERROR, this.loadIOError);
			
			timerCron=new Timer(20000);
			timerCron.addEventListener(TimerEvent.TIMER,callCron);
			timerCron.start();
//			return;
		}
		
		private function gotPanic(event:Event) : void
		{
			try{
				panicList = JSON.parse(event.currentTarget.data);
			}catch(error:SyntaxError)
			{
				trace("TweetLoader :: gotPanic :: JSON parse error :: " + error.message);
			}
			var evt:PanicEvent;
			if(panicList != null && panicList.length>0 ) {
				for(var i:Number=0;i<panicList.length;i++) {
					evt=new PanicEvent(PanicEvent.PANIC_EVENT,panicList[i].sourceId);
					dispatchEvent(evt);
				}
			}
		}
		
		private function callCron(e:TimerEvent):void {
		//	cronLoader.load(new URLRequest(base_url + "sucktweets.php"));
			panicLoader.load(new URLRequest(base_url + "alert.php?totaltweets="+this.numberOfTweets));
		}
		
		public function Twitter():void
		{
			return;
		}
		
		public function getTweets() : void
		{
			if (this.firstLoad == true)
			{
				this.date = new Date();
				this.request = new URLRequest(base_url + "socialPush.php?deviceid=" + uid + "&client=1&query=initTweets&numberOfPosts="+this.numberOfTweets.toString());
			}
			else if (this.firstLoad == false)
			{
				this.request = new URLRequest(base_url + "socialPush.php?deviceid=" + uid + "&client=1&query=newTweets&int=" + this.date.time);
				this.date = new Date();
			}
			this.loader.load(this.request);
		}
		
		private function gotTweets(event:Event) : void
		{
			try{
				
				this.tweets = JSON.parse(event.currentTarget.data);
				
				for each(var o : Object in this.tweets)
				{
					var message : MessageDTO = new MessageDTO();
					message.id = o["id"];
					message.platform = o["platform"];
					
					message.messageName = o["name"];
					message.messageDate = o["mysqldate"];
					message.messageBody = o["text"];
					message.messageProfilePicture = o["profilePicture"];
					message.messagePicture = o["picture"];
					
					message.commentName = o["comment_name"];
					message.commentBody = o["comment_text"];
					message.commentProfilePicture = o["comment_profilePicture"];
					
					messages.push(message);
				}
			}catch(error:SyntaxError)
			{
				trace("TweetLoader :: gotTweets :: JSON parse error :: " + error.message);
			}
			
			this.request = null;
			if (this.firstLoad == true)
			{
				this.firstLoad = false;
				dispatchEvent(new Event("tweetsLoaded"));
			}
			else
			{
				if (this.tweets && this.tweets.length != 0)
				{
					haveDisplayTweet=true;
				}
				if(haveDisplayTweet==false) {
					setTimeout(this.getTweets, 3000);
				}
			}
		}
		
		private function cronError(event:IOErrorEvent): void {
			trace("CRON IO error: "+event.text);
		}
		
		private function loadIOError(event:IOErrorEvent) : void
		{
			trace("IO Error: " + event.text);
			setTimeout(this.getTweets, 3000);
		}
	
		private function checkScreenSaver(e:TimerEvent):void 
		{
			if(haveDisplayTweet==true && isWaitingScreensaver==false) 
			{
				trace("TweetLoader :: checkScreenSaver");
				haveDisplayTweet=false;
				dispatchEvent(new Event("newTweet"));
				setTimeout(this.getTweets, 3000);
			}
		}
		
	}
}
