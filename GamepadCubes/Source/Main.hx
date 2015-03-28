package;


import lime.app.Application;
import lime.math.Matrix4;
import lime.math.Vector4;
import lime.graphics.RenderContext;
import lime.graphics.ConsoleRenderContext;
import lime.graphics.console.RenderState;
import lime.graphics.console.Shader;
import lime.graphics.console.PointerUtil;
import lime.graphics.console.Primitive;
import lime.graphics.console.IndexBuffer;
import lime.graphics.console.VertexBuffer;
import lime.graphics.console.VertexDecl;
import lime.system.System;
import lime.ui.Gamepad;
import lime.ui.GamepadAxis;
import lime.ui.GamepadButton;
import lime.utils.Float32Array;


class Main extends Application {

	
	private var shader:Shader;
	private var vertexBuffer:VertexBuffer;
	private var indexBuffer:IndexBuffer;

	private var prevTime:Float;
	private var t:Float;

	private var x:Float;
	private var y:Float;
	private var pitch:Float;
	private var yaw:Float;

	private var spread:Float;
	private var speed:Float = 1.0;

	private var buttonA:Bool;
	private var buttonB:Bool;
	private var buttonX:Bool;
	private var buttonY:Bool;
	
	
	public function new () {
		
		super ();
		
	}


	public override function init (context:RenderContext):Void {

		switch (context) {

			case CONSOLE (ctx):

				shader = ctx.lookupShader ("basic");

				vertexBuffer = ctx.createVertexBuffer (VertexDecl.PositionColor, 8);	
				var out = vertexBuffer.lock ();
				out.vec3 (-1, 1, 1);
				out.color (0x00, 0x00, 0x00, 0xff);
				out.vec3 (1, 1, 1);
				out.color (0xff, 0x00, 0x00, 0xff);
				out.vec3 (-1, -1, 1);
				out.color (0x00, 0xff, 0x00, 0xff);
				out.vec3 (1, -1, 1);
				out.color (0xff, 0xff, 0x00, 0xff);
				out.vec3 (-1, 1, -1);
				out.color (0x00, 0x00, 0xff, 0xff);
				out.vec3 (1, 1, -1);
				out.color (0xff, 0x00, 0xff, 0xff);
				out.vec3 (-1, -1, -1);
				out.color (0x00, 0xff, 0xff, 0xff);
				out.vec3 (1, -1, -1);
				out.color (0xff, 0xff, 0xff, 0xff);
				vertexBuffer.unlock ();

				var indices:Array<cpp.UInt16> = [
					0, 1, 2, // 0
					1, 3, 2,
					4, 6, 5, // 2
					5, 6, 7,
					0, 2, 4, // 4
					4, 2, 6,
					1, 5, 3, // 6
					5, 7, 3,
					0, 4, 1, // 8
					4, 5, 1,
					2, 3, 6, // 10
					6, 3, 7,
				];
				indexBuffer = ctx.createIndexBuffer (
					cpp.Pointer.arrayElem (indices, 0),
					indices.length
				);

			default:

		}

	}
	
	
	public override function render (context:RenderContext):Void {
		
		switch (context) {
			
			case CONSOLE (context):

				context.clear (0xc0, 0xff, 0x00, 0xff);
				
				renderCubes (context);
			
			default:
			
		}
		
	}


	// Taken largely from the bgfx rendering library sample.
	// https://github.com/bkaradzic/bgfx/blob/master/examples/01-cubes/cubes.cpp
	private function renderCubes (context:ConsoleRenderContext):Void {

		var time = System.getTimer () * 1e-3;
		var dt = time - prevTime;
		t += dt * speed;
		prevTime = time;

		var orthoSquare = 20;
		var extent = orthoSquare * context.width / context.height;
		var zNear = -orthoSquare * 2;
		var zFar = orthoSquare * 2;
		var proj = Matrix4.createOrtho (-extent, extent, -orthoSquare, orthoSquare, zNear, zFar);
		// map Z to [0, 1] instead of [-1, 1]
		proj[10] = 1 / (zFar - zNear);
		proj[14] = -zNear / (zFar - zNear);

		var view = new Matrix4 ();
		view.appendRotation (pitch, new Vector4 (1, 0, 0));
		view.appendRotation (yaw, new Vector4 (0, 1, 0));
		view[12] = x;
		view[13] = y;

		view.append (proj);

		var model = new Matrix4 ();

		context.setRasterizerState (CULLCW_SOLID);
		context.setDepthStencilState (DEPTHTESTON_DEPTHWRITEON_DEPTHLESS_STENCILOFF);
		context.setBlendState (NONE_RGB);

		for (y in -5...6) {
			for (x in -5...6) {

				var scale = 1.0;
				if (buttonA && y < -2) {
					scale = 1.2;
				}
				if (buttonB && x > 2) {
					scale = 1.2;
				}
				if (buttonX && x < -2) {
					scale = 1.2;
				}
				if (buttonY && y > 2) {
					scale = 1.2;
				}

				model.identity ();
				model.appendRotation (degrees (t + x*0.21), new Vector4 (0, 1, 0));
				model.appendRotation (degrees (t + y*0.37), new Vector4 (1, 0, 0));
				model.appendScale (scale, scale, scale);
				model.position = new Vector4 (
					x * (3.0 + 1.25 * spread),
					y * (3.0 + 0.5 * spread),
					0
				);
				model.append (view);
				model.transpose ();

				context.bindShader (shader);
				context.setVertexShaderConstantF (0, PointerUtil.fromMatrix (model), 4);
				context.setVertexSource (vertexBuffer);
				context.setIndexSource (indexBuffer);
				context.drawIndexed (Primitive.Triangle, 8, 0, 12);

			}
		}

	}


	private function degrees (radians:Float):Float {

		return radians * 180 / Math.PI;

	}


	public override function onGamepadAxisMove (gamepad:Gamepad, axis:GamepadAxis, value:Float):Void {

		switch (axis) {

			case LEFT_X:

				x = value * 6.0;

			case LEFT_Y:

				y = value * 3.0;

			case RIGHT_X:

				yaw = -value * 70;

			case RIGHT_Y:

				pitch = value * 70;

			case TRIGGER_LEFT:

				spread = value;

			case TRIGGER_RIGHT:

				speed = 1.0 + value * 5;

		}

	}


	public override function onGamepadButtonDown (gamepad:Gamepad, button:GamepadButton):Void {

		switch (button) {

			case A:

				buttonA = true;

			case B:

				buttonB = true;

			case X:

				buttonX = true;

			case Y:

				buttonY = true;

			case LEFT_SHOULDER:

				spread = 1;	

			case RIGHT_SHOULDER:

				speed = 6;

			case DPAD_UP:
			
				y = 3;

			case DPAD_DOWN:

				y = -3;

			case DPAD_LEFT:

				x = -6;

			case DPAD_RIGHT:

				x = 6;

			default:

		}

	}


	public override function onGamepadButtonUp (gamepad:Gamepad, button:GamepadButton):Void {

		switch (button) {

			case A:

				buttonA = false;

			case B:

				buttonB = false;

			case X:

				buttonX = false;

			case Y:

				buttonY = false;

			case LEFT_SHOULDER:

				spread = 0;	

			case RIGHT_SHOULDER:

				speed = 1;

			case DPAD_UP:
			
				y = 0;

			case DPAD_DOWN:

				y = 0;

			case DPAD_LEFT:

				x = 0;

			case DPAD_RIGHT:

				x = 0;

			default:

		}

	}

	
}
