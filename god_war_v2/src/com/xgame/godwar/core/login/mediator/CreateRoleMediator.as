package com.xgame.godwar.core.login.mediator
{
	import com.xgame.godwar.core.general.mediator.BaseMediator;
	import com.xgame.godwar.core.login.command.ShowWelcomeMediatorCommand;
	import com.xgame.godwar.core.login.proxy.RoleProxy;
	
	import flash.events.MouseEvent;
	
	import game.view.CreateRoleView;
	
	import org.puremvc.as3.interfaces.INotification;
	
	public class CreateRoleMediator extends BaseMediator
	{
		public static const NAME: String = "CreateRoleMediator";
		
		public static const SHOW_NOTE: String = NAME + ".ShowNote";
		public static const HIDE_NOTE: String = NAME + ".HideNote";
		
		public function CreateRoleMediator()
		{
			super(NAME, new CreateRoleView());
			
			component.btnStart.addEventListener(MouseEvent.CLICK, onButtonStartClick);
			component.btnBack.addEventListener(MouseEvent.CLICK, onButtonBackClick);
		}
		
		public function get component(): CreateRoleView
		{
			return viewComponent as CreateRoleView;
		}
		
		override public function listNotificationInterests():Array
		{
			return [SHOW_NOTE, HIDE_NOTE];
		}
		
		override public function handleNotification(notification: INotification):void
		{
			switch(notification.getName())
			{
				case SHOW_NOTE:
					show(notification.getBody() as Function);
					break;
				case HIDE_NOTE:
					hide(notification.getBody() as Function);
					break;
			}
		}
		
		private function onButtonStartClick(evt: MouseEvent): void
		{
			var _proxy: RoleProxy = facade.retrieveProxy(RoleProxy.NAME) as RoleProxy;
			if(_proxy == null)
			{
				_proxy = new RoleProxy();
				facade.registerProxy(_proxy);
			}
			_proxy.registerAccountRole(component.iptName.text);
		}
		
		private function onButtonBackClick(evt: MouseEvent): void
		{
			hide(function(): void
			{
				if(!facade.hasCommand(ShowWelcomeMediatorCommand.SHOW_NOTE))
				{
					facade.registerCommand(ShowWelcomeMediatorCommand.SHOW_NOTE, ShowWelcomeMediatorCommand);
				}
				facade.sendNotification(ShowWelcomeMediatorCommand.SHOW_NOTE);
			});
		}
	}
}