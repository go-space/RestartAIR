package 
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.Font;
	import jp.mztm.desktop.ApplicationManager;
	/**
	 * ...
	 * @author GO
	 */
	[SWF(width = "800", height = "600", frameRate = "60", backgroundColor = "0x000000")]
	public class Main extends Sprite 
	{
		private static var applicationManager:ApplicationManager;
		
		public function Main ()
		{
			init();
		}
		
		private function init ():void 
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.HIGH;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(MouseEvent.CLICK, onStageClick);
			
			applicationManager = ApplicationManager.getInstance() as ApplicationManager;
		}
		
		private function onStageClick (event:MouseEvent):void
		{
			trace( "onStageClick" );
			applicationManager.restartApp();
		}
	}
}