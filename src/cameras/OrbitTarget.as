package cameras
{
	import flash.events.MouseEvent;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	
	public class OrbitTarget extends CameraController
	{
		private var mController:HoverController;
		
		/** 带鼠标控制器的目标镜头**/
		public function OrbitTarget(view3d:View3D,target:ObjectContainer3D = null,panAngle:Number = 0,tiltAngle:Number = 0)
		{
			super(view3d,target);
			mController = new HoverController(this.camera, this.target, panAngle, tiltAngle, 
				distance, minTiltAngle, maxTiltAngle,minPanAngle,maxPanAngle, smooth, 1);
			_Controller = mController;
			
			addMouseDownListener();
			addMouseDisActiveListener();
			addMouseWheelListener();
		}
		
		protected override function onMouseDown(event:MouseEvent):void
		{
			this.lastPanAngle = this.mController.panAngle;
			this.lastTiltAngle = this.mController.tiltAngle;
			this.lastMouseX = this.stage.mouseX;
			this.lastMouseY = this.stage.mouseY;
			this.isMouseActive = true;
		}
		
		protected override function onMouseDisActive(event:MouseEvent):void
		{
			this.isMouseActive = false;
		}
		
		protected override function onMouseWheel(event:MouseEvent):void
		{
			var value:Number = this.distance - event.delta / 0.5;
			if (value < minDistance)
			{
				value = minDistance;
			}
			if (value > maxDistance)
			{
				value = maxDistance;
			}
			this.distance = value;
		}
		
		/** 刷新镜头位置**/
		protected override function updateCamera():void
		{
			this.mController.distance = this.mController.distance + (this.distance - this.mController.distance) / 8;
			if (this.isMouseActive)
			{
				this.mController.panAngle = 0.3 * (this.stage.mouseX - this.lastMouseX) + this.lastPanAngle;
				this.mController.tiltAngle = 0.3 * (this.stage.mouseY - this.lastMouseY) + this.lastTiltAngle;
			}
		}
	}
}