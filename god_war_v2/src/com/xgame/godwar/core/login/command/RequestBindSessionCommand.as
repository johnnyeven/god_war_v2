package com.xgame.godwar.core.login.command
{
	
	import com.xgame.godwar.core.login.proxy.SessionProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class RequestBindSessionCommand extends SimpleCommand
	{
		public static const NAME: String = "RequestBindSessionCommand.RequestBindSessionNote";
		
		public function RequestBindSessionCommand()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			var _proxy: SessionProxy;
			if(!facade.hasProxy(SessionProxy.NAME))
			{
				_proxy = new SessionProxy();
				facade.registerProxy(_proxy);
			}
			else
			{
				_proxy = facade.retrieveProxy(SessionProxy.NAME) as SessionProxy;
			}
			_proxy.requestBindSession();
		}
	}
}