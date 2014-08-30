package com.wmgllc.twittersphere.controller.event
{
	import com.wmgllc.twittersphere.model.entity.MessageDTO;
	import com.wmgllc.twittersphere.view.component.scene.TweetMesh;
	
	import flash.events.Event;
	
	public class MessageWindowEvent extends Event
	{
		public static const OPEN_WINDOW : String = "openWindow";
		public static const CLOSE_WINDOW : String = "closeWindow";
		
		public static const TOUCH_WINDOW : String = "touchWindow";
		
		public static const HEIGHT_UPDATED : String = "heightUpdated";
		
		public var tileReference3D : TweetMesh;
		public var messageDTO : MessageDTO;
		
		public function MessageWindowEvent(type:String, messageDTO_ : MessageDTO = null, tileReference3D_ : TweetMesh = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			messageDTO = messageDTO_;
			tileReference3D = tileReference3D_;
			
			super(type, bubbles, cancelable);
		}
	}
}