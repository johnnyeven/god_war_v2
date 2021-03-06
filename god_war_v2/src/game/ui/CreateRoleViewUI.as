/**Created by the Morn,do not modify.*/
package game.ui {
	import morn.core.components.*;
	public class CreateRoleViewUI extends View {
		public var btnRandName:Button;
		public var iptName:TextInput;
		public var btnBack:Button;
		public var btnStart:Button;
		protected var uiXML:XML =
			<View>
			  <Image url="png.login.role_selected_forward" x="0" y="672"/>
			  <Image url="png.login.login_nameinput_BG" x="446" y="548"/>
			  <Button skin="png.login.btn_random_name" x="686" y="548" var="btnRandName"/>
			  <TextInput x="470" y="567" size="16" width="204" height="28" align="left" font="Microsoft YaHei" var="iptName"/>
			  <Button label="返回" skin="png.login.btn_back" x="71" y="661" labelColors="0xFFFFFF,0xFFFF00,0xAAAAAA" labelMargin="20,0,0,3" labelSize="14" var="btnBack" labelFont="Microsoft YaHei"/>
			  <Button label="进入游戏" skin="png.login.btn_start" x="475" y="670" labelColors="0xFFFFFF,0xFFFF00,0xAAAAAA" labelSize="20" labelFont="Microsoft YaHei" var="btnStart"/>
			</View>;
		public function CreateRoleViewUI(){}
		override protected function createChildren():void {
			createView(uiXML);
		}
	}
}