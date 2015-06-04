package cameras
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.controllers.ControllerBase;

	public class CameraController extends EventDispatcher
	{
		private var _camera:Camera3D;
		private var _stage:DisplayObject;
		private var _target:ObjectContainer3D;
		
		protected var isMouseActive:Boolean = false;
		protected var isKeyActive:Boolean = false;
		
		protected var lastPanAngle:Number;
		protected var lastTiltAngle:Number;
		protected var lastMouseX:Number;
		protected var lastMouseY:Number;
		
		//镜头参数
		/** 最小距离**/public var minDistance:Number =230;
		/** 最大距离**/public var maxDistance:Number =330;
		/** 初始距离**/public var distance:Number =maxDistance-10;
		
		/** 最小俯仰角**/public var minTiltAngle:Number = 10;//-90;
		/** 最大俯仰角**/public var maxTiltAngle:Number =90;
		/** 自由俯仰角**/public var freeTilt:Boolean = true;
		
		/** 最小倾角**/public var minPanAngle:Number =NaN;
		/** 最大倾角**/public var maxPanAngle:Number =NaN;
		/** 自由倾角**/public var freePan:Boolean = true;
		
		/** 平滑系数**/public var smooth:Number =6;
		
		private var _controllPlane:Sprite;
		protected var _Controller:ControllerBase;
		
		public function CameraController(view3d:View3D,target:ObjectContainer3D = null)
		{
			this._stage = view3d;
			this._camera = view3d.camera;
			this._target = target;
			view3d.addEventListener(Event.ENTER_FRAME, updateController);
			
			_controllPlane = new Sprite();
			_controllPlane.graphics.beginFill(0x111111,0);
			_controllPlane.graphics.drawRect(0,0,view3d.width,view3d.height);
			view3d.parent.addChild(_controllPlane);
			
		}
		
		protected final function get camera():Camera3D{return _camera;}
		protected final function get stage():DisplayObject{return _stage;}
		protected final function get target():ObjectContainer3D{return _target;}
		
		/**添加鼠标按下侦听器**/
		protected final function addMouseDownListener():void
		{
			_controllPlane.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		/**添加鼠标按下侦听器**/
		protected final function removeMouseDownListener():void
		{
			_controllPlane.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		/**添加鼠标弹起侦听器**/
		protected final function addMouseUpListener():void
		{
			_controllPlane.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		/**添加鼠标移动侦听器**/
		protected final function addMouseMoveListener():void
		{
			_controllPlane.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		/**添加鼠标移动侦听器**/
		protected final function removeMouseMoveListener():void
		{
			_controllPlane.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		/**添加鼠标未激活侦听器**/
		protected final function addMouseDisActiveListener():void
		{
			var func:Function = onMouseDisActive;
			_controllPlane.addEventListener(MouseEvent.MOUSE_UP, func);
			_controllPlane.addEventListener(MouseEvent.ROLL_OUT, func);
		}
		
		/**添加鼠标滚轮侦听器**/
		protected final function addMouseWheelListener():void
		{
			_controllPlane.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		/**鼠标按下**/protected function onMouseDown(event:MouseEvent):void{}
		/**鼠标弹起**/protected function onMouseUp(event:MouseEvent):void{}
		/**鼠标移动**/protected function onMouseMove(event:MouseEvent):void{}
		/**鼠标未激活**/protected function onMouseDisActive(event:MouseEvent):void{}
		/**鼠标滚轮**/protected function onMouseWheel(event:MouseEvent):void{}
		
		/**添加鼠标滚轮侦听器**/
		protected final function addKeyBoardListener():void
		{
			this._stage.parent.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			this._stage.parent.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		/**鼠标按下**/protected function onKeyDown(event:KeyboardEvent):void{}
		/**鼠标按下**/protected function onKeyUp(event:KeyboardEvent):void{}
		
		/**更新镜头**/
		private function updateController(event:Event):void{
			this._Controller.update();
			updateCamera();
		}
		
		/**如何更新镜头**/
		protected function updateCamera():void{
			
		}
	}
}