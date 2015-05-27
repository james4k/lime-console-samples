package;


import openfl.geom.Rectangle;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.Assets;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;


class Main extends Sprite {
	
	
	public function new () {
		
		super ();
		
		test(""       , 0x4488FF,   0,   0);
		
		test("Arial"  , 0xFF8844, 200,   0);
		
		test(""       , 0x88FF44,   0, 200);
		
		test("Arial"  , 0x44FF88, 200, 200);
	}
	
	private function test(font:String, color:Int, X:Int, Y:Int):Void
	{
		var text:TextField = new TextField();
		text.width = 200;
		var tf:TextFormat = new TextFormat(font, 24, color, true);
		text.defaultTextFormat = tf;
		text.text = "Hello, World!";
		addChild(text);
		
		text.x = X;
		text.y = Y;
		
		var bmp:BitmapData = new BitmapData(cast text.textWidth, cast text.textHeight, true, 0x00000000);
		bmp.draw(text);
		
		var b = new Bitmap(bmp);
		b.x = text.x;
		b.y = text.y + text.textHeight + 10;
		addChild(b);
		
		var bmp2 = new BitmapData(cast text.textWidth, cast text.textHeight, true, 0xFF000000);
		var r = new Rectangle(1, 1, bmp2.width - 2, bmp2.height - 2);
		bmp2.fillRect(r, 0x00000000);
		bmp2.draw(text);
		
		var b2 = new Bitmap(bmp2);
		b2.x = b.x;
		b2.y = b.y + b.height + 10;
		addChild(b2);
	}
}