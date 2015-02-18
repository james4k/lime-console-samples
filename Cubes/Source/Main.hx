package;


import lime.app.Application;
import lime.math.Matrix4;
import lime.math.Vector4;
import lime.graphics.RenderContext;
import lime.graphics.ConsoleRenderContext;
import lime.graphics.console.Shader;
import lime.graphics.console.Primitive;
import lime.graphics.console.IndexBuffer;
import lime.graphics.console.VertexBuffer;
import lime.system.System;


class Main extends Application {

	
	private var shader:Shader;
	private var vertexBuffer:VertexBuffer;
	private var indexBuffer:IndexBuffer;
	
	
	public function new () {
		
		super ();
		
	}


	public override function init (context:RenderContext):Void {

		shader = new Shader ("basic");	

		vertexBuffer = new VertexBuffer (VertexDecl.PositionColor, 8);	
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

		indexBuffer = new IndexBuffer ([
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
		]);	

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

		var orthoSquare = 20;
		var extent = orthoSquare * context.width / context.height;
		var zNear = -orthoSquare;
		var zFar = orthoSquare;
		var proj = Matrix4.createOrtho (-extent, extent, -orthoSquare, orthoSquare, zNear, zFar);
		// map Z to [0, 1] instead of [-1, 1]
		proj[10] = 1 / (zFar - zNear);
		proj[14] = -zNear / (zFar - zNear);

		var model = new Matrix4 ();

		var y = 0;
		while (y < 11) {
			var x = 0;
			while (x < 11) {

				model.identity ();
				model.appendRotation (degrees (time + x*0.21), new Vector4 (0, 1, 0));
				model.appendRotation (degrees (time + y*0.37), new Vector4 (1, 0, 0));
				model.position = new Vector4 (
					-15.0 + x*3.0,
					-15.0 + y*3.0,
					0
				);
				model.append (proj);
				model.transpose ();

				context.bindShader (shader);
				context.setVertexShaderConstantMatrix (0, model);
				context.setVertexSource (vertexBuffer);
				context.setIndexSource (indexBuffer);
				context.drawIndexed (Primitive.Triangle, 8, 0, 12);

				x++;
			}
			y++;
		}

	}


	private function degrees (radians:Float):Float {

		return radians * 180 / Math.PI;

	}
	
	
}
