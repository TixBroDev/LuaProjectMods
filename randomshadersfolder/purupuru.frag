//from tetaes's Late-night tower
#pragma header

const vec2 fixedSize = vec2(1280., 720.);
const vec2 imageSize = vec2(1280., 720.);

float beat = 4.;

float tyusoi = .1;
float frequencib = .2;

void main() {
	vec2 uv = openfl_TextureCoordv;
	
	float w = (0.5 * imageSize.x / fixedSize.x - uv.x) * (fixedSize.x / fixedSize.y);
    float h = (0.5 * imageSize.y / fixedSize.y - uv.y);
	float distanceFromCenter = sqrt(w * w + h * h);
	
	float sinArg = distanceFromCenter * frequencib - beat * 6.0;
	float slope = cos(sinArg);
	
	vec4 color = flixel_texture2D(bitmap, uv + normalize(vec2(w, h)) * slope * tyusoi);
	
	if (color.r < 0.1 && color.g < 0.1 && color.b < 0.1) {discard;}
	
	//if (beat > 36 && beat < 68){
	//	if (color.r > 0.2 && color.g > 0.2 && color.b > 0.2 && uv.x > 0.9 * imageSize.x / fixedSize.x){
	//		discard;
	//	}
	//	if (color.r > 0.2 && color.g > 0.2 && color.b > 0.2 && uv.y > 0.9 * imageSize.y / fixedSize.y){
	//		discard;
	//	}
	//}
	
	//if (beat > 37 && beat < 38){
	//	if ((color.r > 0.2 || color.g > 0.2 || color.b > 0.2) && uv.x > 0.49 * imageSize.x / fixedSize.x && uv.x < 0.51 * imageSize.x / fixedSize.x && uv.y > 0.49 * imageSize.y / fixedSize.y && uv.y < 0.51 * imageSize.y / fixedSize.y){
	//		discard;
	//	}
	//}
	
	gl_FragColor = color;
}