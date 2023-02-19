//SHADERTOY PORT FIX
#pragma header
vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
uniform float iTime;
#define iChannel0 bitmap
#define iChannel1 bitmap
#define iChannel2 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main
#define time iTime
#define iMouse 1.0
//SHADERTOY PORT FIX

#define PI 3.14159265







void mainImage()
{
	vec2 pixel = fragCoord.xy - iResolution.xy*.5;
	
	// pixellate
	const float pixelSize = 4.0;
	pixel = floor(pixel/pixelSize);
	
	vec2 offset = vec2(iTime*3000.0,pow(max(-sin(iTime*.2),.0),2.0)*16000.0)/pixelSize;
	
	vec3 col;
	for ( int i=0; i < 8; i++ )
	{
		// parallax position, whole pixels for retro feel
		float depth = 20.0+float(i);
		vec2 uv = pixel + floor(offset/depth);
		
		uv /= iResolution.xy;
		uv *= depth/20.0;
		uv *= .4*pixelSize;
		
		col = texture( iChannel0, uv+.5 ).rgb;
		
		if ( 1.0-col.y < float(i+1)/8.0 )
		{
			col = mix( vec3(.4,.6,.7), col, exp2(-float(i)*.1) );
			break;
		}
	}
	
	fragColor = vec4(col,0.4);
}