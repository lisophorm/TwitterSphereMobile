package com.wmgllc.twittersphere.model.entity
{
	public class MessageDTO
	{
		[Bindable]
		public var id : String;
		[Bindable]
		public var platform : String;
		
		[Bindable]
		public var messageName : String;
		[Bindable]
		public var  messageDate : String;
		[Bindable]
		public var messageBody : String;
		[Bindable]
		public var messageProfilePicture : String;
		[Bindable]
		public var messagePicture : String;
		
		[Bindable]
		public var commentName : String;
		[Bindable]
		public var commentDate : String;
		[Bindable]
		public var commentBody : String;
		[Bindable]
		public var commentProfilePicture : String;
		
		public function MessageDTO()
		{
		}
	}
}