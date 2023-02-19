//SHADERTOY PORT FIX
#pragma header
vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main
#define time iTime
//SHADERTOY PORT FIX

#define PI 3.14159265


//Random function
float Hash (vec2 p)
{
	return fract (sin (dot (p, vec2 (12.56, 167.89))) * 6750.21);
}

//Simple noise
float Noise (vec2 p)
{
   	vec2 lv = fract (p);
    vec2 index = floor (p);
    
    vec2 sm = 6.0 * lv * lv * lv * lv * lv -
       	 15.0 * lv * lv * lv * lv + 
         10.0 * lv * lv * lv; //smooth function
    
    float bl = Hash (index);
    float br = Hash (index + vec2 (1.0, 0.0));
    float b = mix (bl, br, sm.x);
    float tl = Hash (index + vec2 (0.0, 1.0));
    float tr = Hash (index + vec2 (1.0, 1.0));
    float t = mix (tl, tr, sm.x);
    
    return mix (b, t, sm.y);   
}

//Fractal Brownian Motion
float FBM (vec2 p)
{
    const int OCTAVES = 6;
    
    float result = 0.0;
    float m = 0.0;
    
    float amplitude = 1.0;
    float freq = 1.0;
    
    for (int i=0; i<6; i++)
    {
        result += Noise (p * freq) * amplitude;
        m += amplitude;
        amplitude *= 0.5; //lacunarity
        freq *= 2.0; //gain
    }
    
    return result/m;
}

//Distort the domain.
//f(p) = fbm( p + fbm( p + fbm( p ) ) )
//IQ Domain Wraping
//https://iquilezles.org/articles/warp
float DistortDomain (vec2 p, out vec2 fDstr, out vec2 sDstr)
{
	fDstr = vec2 (
    	FBM (p + vec2 (.5, 0.3)),
        FBM (p + vec2 (2.2, 0.1)  * iTime * 0.03)
    );
             
    sDstr = vec2 (
        FBM (p + 5.0 * fDstr + vec2 (2.5, 0.2)  * iTime * 0.1),
        FBM (p + 5.0 * fDstr + vec2 (-0.2, .3)  * iTime * 0.5)
    );
             
   	return FBM (p + 5.0 * sDstr);
}

//Draw a circle with a radius/thickness based on a noise
float DrawCircle (vec2 uv, vec2 pos, float r, out vec2 fDstr, out vec2 sDstr)
{
    float aspectRatio = iResolution.x/iResolution.y;
    uv.x *= aspectRatio;
    pos.x *= aspectRatio;
    
    float noise = DistortDomain (uv, fDstr, sDstr);
    
    pos += vec2 (cos(iTime) * .75, sin(iTime) * .3);
    r += sin (noise * r * 1.2);
    float d = distance (uv, pos);
    
    //Apply a smoothstep
    float circle = smoothstep (r * noise - 2.0, r * noise, d);
    return circle * noise;
}

void mainImage()
{
	vec2 uv = fragCoord/iResolution.xy;
    
    vec2 fDistortion;
    vec2 sDistortion;
   	
    
    float noise = DrawCircle (uv, vec2 (0.5, 0.5), 0.5, fDistortion, sDistortion);
    
    vec3 col1 = mix(vec3(1.,0.,0.),
                	vec3(0.624,0.,0.),
                	clamp((noise*noise)*5.0,0.0,1.0));
    
    vec3 col2 =  mix(col1,
                	 vec3(0.35,0.34,0.87),
                	 clamp(length(fDistortion),0.0,1.0));
    
    vec3 col3 = mix (col2, 
                     vec3(0.624,0.,0.),
                     clamp (length (sDistortion.x), 0.0, 1.0));
    
    
    //Gamma
    fragColor = pow (vec4((noise * noise * (1.03 - 1.0 * noise)) * col3, 1.), vec4 (1./1.2)) + texture(iChannel0,uv);            
}