package com.cetesdirecto.ventana
{
	import avmplus.getQualifiedClassName;
	
	import com.cetesdirecto.skins.SkinBtnMaximizar;
	import com.cetesdirecto.skins.SkinBtnRestaurar;
	import com.cetesdirecto.skins.SkinVentana;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.graphics.SolidColor;
	import mx.managers.PopUpManager;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.TitleWindow;
	import spark.effects.Move;
	import spark.effects.Resize;
	import spark.events.TitleWindowBoundsEvent;
	import spark.primitives.Rect;
	
	public class Ventana extends TitleWindow		
	{
		/** Almacena el borde de la ventana**/
		[Bindable]
		public var contenedor:BorderContainer;
		
		/** Bandera que identifica si la ventana esta abierta o cerrada**/
		[Bindable]
		public var isMaximizada:Boolean;
		
		/** Correponde al color de fondo del header de la ventana**/
		[SkinPart(required="false")]
		public var colorFondoTitulo:SolidColor;
		
		/** Corresponde al boton de maximizar y minimizar**/
		[SkinPart(required="false")]
		public var btnMaxyMin:Button;
		
		[SkinPart (required="false")]
		public var btnImprimir:Button;
		
		[SkinPart (required="false")]
		public var txtMensajeFooter:Label;
		
		[SkinPart (required="false")]
		public var colorFooter:SolidColor;
		
		[SkinPart (required="false")]
		public var footer:Rect;
		
		private var _colorFondoFooter:uint;
		
		private var _colorFondoHeader:uint;
		
		/** Reliza el resize de la ventana **/
		private var resizeVentana:Resize;
		
		/** Realiza el movimiento de la ventana **/
		private var mover:Move;
		
		/** Guarda el ancho antes de ser maximizado**/
		[Bindable]
		private var anchoParaRestaurar:int;
		
		/** Guarda el alto antes de ser maximizado **/
		[Bindable]
		private var altoParaRestaurar:int;
		
		/** Guarda la posicion de X antes de ser maximizada**/
		private var xParaRestaurar:int;
		
		/** Guarda la posicion de Y antes de ser maximizada **/
		private var yParaRestaurar:int;
		
		private var _mostrarFooter:Boolean;
		
		public function Ventana()
		{
			super();
			this.addEventListener(CloseEvent.CLOSE,cerrarVentana);
			this.addEventListener(FlexEvent.CREATION_COMPLETE,initVentana);
			this.addEventListener(TitleWindowBoundsEvent.WINDOW_MOVING,limitarVentana);
			
			asignarValoresPorDefault();
		}



		[Bindable]
		public function get mostrarFooter():Boolean
		{
			return _mostrarFooter;
		}

		public function set mostrarFooter(value:Boolean):void
		{
			_mostrarFooter = value;
			if (footer != null){
				footer.visible = footer.includeInLayout = mostrarFooter;
				txtMensajeFooter.visible = txtMensajeFooter.includeInLayout = mostrarFooter;
				btnImprimir.visible = btnImprimir.includeInLayout = mostrarFooter;
			}
		}

		[Bindable]
		public function get colorFondoFooter():uint
		{
			return _colorFondoFooter;
			
		}

		public function set colorFondoFooter(value:uint):void
		{
			_colorFondoFooter = value;
			if (colorFooter != null){
				colorFooter.color = colorFondoFooter;
			}
		}

		[Bindable]
		public function get colorFondoHeader():uint
		{
			return _colorFondoHeader;
		}

		public function set colorFondoHeader(value:uint):void
		{
			_colorFondoHeader = value;
			if (colorFondoTitulo != null){
				colorFondoTitulo.color = colorFondoHeader;	
			}
		}

		protected function limitarVentana(event:TitleWindowBoundsEvent):void 
		{
			if (contenedor != null)
			{
				if (event.afterBounds.left < contenedor.x){
					event.afterBounds.left = contenedor.x;
				}else if (event.afterBounds.right > (contenedor.width + contenedor.x)){
					event.afterBounds.left = ( contenedor.width - event.afterBounds.width) + contenedor.x;
				}
				
				if (event.afterBounds.top < contenedor.y){
					event.afterBounds.top = contenedor.y;
				}else if (event.afterBounds.bottom > (contenedor.height + contenedor.y)){
					event.afterBounds.top = (contenedor.height - event.afterBounds.height) + contenedor.y;
				}		
			}else{ //si no tiene un contenedor donde limitarse, se limita al ancho de stage 
				
				if (event.afterBounds.left < 0){
					event.afterBounds.left = 0;
				}else if (event.afterBounds.right > systemManager.stage.stageWidth){
					event.afterBounds.left = systemManager.stage.stageWidth - event.afterBounds.width;
				}
				
				if (event.afterBounds.top < 0){
					event.afterBounds.top = 0;
				}else if (event.afterBounds.bottom > systemManager.stage.stageHeight){
					event.afterBounds.top = systemManager.stage.stageHeight - event.afterBounds.height;
				}
			}
			
			
		}
		/** Asigna los valores por default a las propiedades**/
		protected function asignarValoresPorDefault():void{
			
			setStyle("skinClass",com.cetesdirecto.skins.SkinVentana);
			width = 400;
			height = 300;
			colorFondoHeader = 0xFF0000;
			colorFondoFooter = 0x00FF00;
			mostrarFooter = false;
			
			resizeVentana = new Resize();
			mover = new Move();
			mover.target = this;
			resizeVentana.target = this;
			
		}
		
		/** Asigna los valores cuando se terminaron de crear los elementos de la ventana**/
		protected function initVentana(event:FlexEvent):void {
			
		}
		/** Cierra la Ventana **/
		protected function cerrarVentana(evento:CloseEvent):void {
			PopUpManager.removePopUp(this);
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == colorFondoTitulo){
				colorFondoTitulo.color = colorFondoHeader;
			}else if (instance == btnMaxyMin){
				btnMaxyMin.addEventListener(MouseEvent.CLICK,maximizarORestaurarVentana);
			}else if (instance == colorFooter){
				colorFooter.color = colorFondoFooter;
			}else if (instance == footer){
				footer.visible = footer.includeInLayout = mostrarFooter;
				
			}
			
		}
		
		protected function maximizarORestaurarVentana(event:MouseEvent):void
		{
			if (getQualifiedClassName(btnMaxyMin.getStyle("skinClass")) == getQualifiedClassName(com.cetesdirecto.skins.SkinBtnRestaurar)){
				restaurarVentana();
			}else{				
				maximizarVentana();
			}
		}
		
		/** realiza las funciones para mover y resize la ventana par restaurar**/
		public function maximizarVentana():void
		{
			if (contenedor != null)
			{
				// === MOVE ===
				
				//inicia a moverse en
				mover.xFrom = this.x;
				mover.yFrom = this.y;
				
				//hasta donde se movera
				mover.xTo = contenedor.x,
					mover.yTo = contenedor.y;
				
				//realiza el movimiento
				mover.end();
				mover.play();
				
				
				// ==== RESIZE ===== 
				anchoParaRestaurar = this.width;
				altoParaRestaurar = this.height;
				
				//guarda el valor de x y y antes de ser restaurado
				xParaRestaurar = this.x;
				yParaRestaurar = this.y
				
				//Tamanio hasta donde se realizara resize
				resizeVentana.heightTo = contenedor.height;
				resizeVentana.widthTo = contenedor.width;
				
				resizeVentana.end();
				resizeVentana.play();
			}else{
				// === MOVE ===
				
				//inicia a moverse en
				mover.xFrom = this.x;
				mover.yFrom = this.y;
				
				//hasta donde se movera
				mover.xTo = 0
				mover.yTo = 0
				
				//realiza el movimiento
				mover.end();
				mover.play();
				
				
				// ==== RESIZE ===== 
				anchoParaRestaurar = this.width;
				altoParaRestaurar = this.height;
				
				//guarda el valor de x y y antes de ser restaurado
				xParaRestaurar = this.x;
				yParaRestaurar = this.y
				
				//Tamanio hasta donde se realizara resize
				resizeVentana.heightTo = systemManager.stage.stageHeight;
				resizeVentana.widthTo = systemManager.stage.stageWidth;
				
				resizeVentana.end();
				resizeVentana.play();
			}
						
			
			btnMaxyMin.setStyle("skinClass",com.cetesdirecto.skins.SkinBtnRestaurar);		
			btnMaxyMin.toolTip = "Minimizar";
			isMaximizada = true;
			dispatchEvent(new Event("ventanaMaximizada"));
		}
		
		/** realiza las funciones para mover y resize la ventana par restaurar**/
		public function restaurarVentana():void
		{
			// === MOVE ===
			mover.xFrom = this.x;
			mover.yFrom = this.y;
			
			mover.xTo = xParaRestaurar;
			mover.yTo = yParaRestaurar;
			
			//realiza el movimiento
			mover.end();
			mover.play();
			
			
			
			// === RESIZE ==
			resizeVentana.heightTo = altoParaRestaurar;
			resizeVentana.widthTo = anchoParaRestaurar;
			
			resizeVentana.end();
			resizeVentana.play();
			
			
			
			btnMaxyMin.setStyle("skinClass",com.cetesdirecto.skins.SkinBtnMaximizar);
			btnMaxyMin.toolTip = "Restaurar";
			isMaximizada = false;
			
			dispatchEvent(new Event("ventanaRestaurada"));
		}
		
			
		
		
	}
}