package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.events.Stage3DEvent;
	
	[SWF(width="960",height="640",frameRate="60",quality="HEIGHT")]
	public class AircraftMuseumAlpha extends Sprite
	{
		// Stage manager and proxy instances
		private var stage3DManager : Stage3DManager;
		private var stage3DProxy : Stage3DProxy;
		
		private var GUI:GuiLayer;
		private var away3dLayer:Away3DLayer;
		
		public function AircraftMuseumAlpha()
		{
			disableMeun();
			init();
		}
		
		private function init():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			//stage.addEventListener(Event.RESIZE, onResize);
			
			initProxies();
		}
		
		private function initProxies():void
		{
			// Define a new Stage3DManager for the Stage3D objects
			stage3DManager = Stage3DManager.getInstance(stage);
			
			// Create a new Stage3D proxy to contain the separate views
			stage3DProxy = stage3DManager.getFreeStage3DProxy();
			stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
			stage3DProxy.antiAlias = 8;
			stage3DProxy.color = 0xf8f8f8;
		}
		
		protected function onContextCreated(event:Event):void
		{
			// TODO Auto-generated method stub
			initAway3D();
			
			GUI = new GuiLayer();
			addChild(GUI);
			
			GUI.addEventListener("TextureUpdate",onTextureUpdate);
			GUI.addEventListener("EngineUpdate",onEngineUpdate);
		}
		
		private function initAway3D() : void
		{
			// Create the first Away3D view which holds the cube objects.
			away3dLayer = new Away3DLayer(this,stage3DProxy);
		}
		
		protected function onTextureUpdate(event:Event):void
		{
			// TODO Auto-generated method stub
			away3dLayer.updateTexture(GUI.currentTexture);
		}
		
		protected function onEngineUpdate(event:Event):void
		{
			// TODO Auto-generated method stub
			away3dLayer.updateEngine();
		}
		
		private function onResize(event:Event = null):void
		{
			
		}
		
		private function disableMeun():void
		{
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN,onRmd);
			function onRmd(e:MouseEvent):void{}
		}	
		
	}
}