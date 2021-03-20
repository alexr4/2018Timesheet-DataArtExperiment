#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PI 3.14159265359
#define TWO_PI PI * 2.0
uniform sampler2D texture;
uniform vec2 resolution;
uniform float time;
uniform vec2 mouse;
uniform float numberOfHours;

in vec4 vertTexCoord;
out vec4 fragColor;

float circleSmooth(vec2 st, vec2 center, float radius, float smoothness){
  float distFromCenter = length(center - st);
  return 1.0 - smoothstep(radius - smoothness * 0.5, radius + smoothness * 0.5, distFromCenter);
}

float random2f (vec2 st) {
    return fract(sin(dot(st.xy, vec2(10.9898,78.233)))*43758.5453123);
}


float voronoiDistance( in vec2 x )
{
    ivec2 p = ivec2(floor( x ));
    vec2  f = fract( x );

    ivec2 mb;
    vec2 mr;

    float res = 8.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        ivec2 b = ivec2( i, j );
        vec2  r = vec2( b ) + random2f( p + b ) - f;
        float d = dot(r,r);

        if( d < res )
        {
            res = d;
            mr = r;
            mb = b;
        }
    }

    res = 8.0;
    for( int j=-2; j<=2; j++ )
    for( int i=-2; i<=2; i++ )
    {
        ivec2 b = mb + ivec2( i, j );
        vec2  r = vec2( b ) + random2f( p + b ) - f;
        float d = dot( 0.5*(mr+r), normalize(r-mr) );

        res = min( res, d );
    }

    return res;
}

float getBorder( in vec2 p, in float size, in float thickness, in float smoothness)
{
    float dis = voronoiDistance( p );

    return smoothstep(size - thickness - smoothness, size - thickness, dis) * (1.0 - smoothstep(size + thickness, size + thickness + smoothness, dis));
}

float random (vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233)))*43758.5453123);
}

//noise from Morgan McGuire
//https://www.shadertoy.com/view/4dS3Wd
float noise(vec2 st){
  vec2 ist = floor(st);
  vec2 fst = fract(st);

  //get 4 corners of the pixel
  float bl = random(ist);
  float br = random(ist + vec2(1.0, 0.0));
  float tl = random(ist + vec2(0.0, 1.0));
  float tr = random(ist + vec2(1.0, 1.0));

  //smooth interpolation using cubic function
  vec2 si = fst * fst * (3.0 - 2.0 * fst);

  //mix the four corner to get a noise value
  return mix(bl, br, si.x) +
         (tl - bl) * si.y * (1.0 - si.x) +
         (tr - br) * si.x * si.y;
}



void main(){
	vec2 uv = vertTexCoord.xy;

	vec2 center = vec2(0.5);
	vec2 toCenter = center - uv;
	float radius = length(toCenter);
	float hyp = sqrt(2.0);
	float theta = atan(toCenter.y, toCenter.x) + PI;
	float normTheta = abs((theta / (TWO_PI)) * 2.0 - 1.0);
	float normRadius = radius / (hyp * 0.5);

	//vec2 raduv = vec2(abs(normTheta * 2.0 - 1.0), 1.0 - normRadius);
	vec2 raduv = vec2(1.0 - normRadius, normTheta);

	float stepper = 1.0 - step(0.7, normRadius);
	float circInside  = 1.0 - circleSmooth(uv, vec2(0.5), 0.4945, 0.0005);
	float circOutside = circleSmooth(uv, vec2(0.5), 0.496, 0.0005);
	float circ 		  = circInside * circOutside;

	float distFromMouse = length(mouse - uv) / (hyp);

	vec2 nuv = uv * numberOfHours;
	float noisevalue = noise(nuv) * 0.75 + 0.25;
	float dataTest = pow(texture(texture, uv).r, 1.0) * noisevalue;

	//float v = getBorder(nuv, 0.01 +  0.45 * dataTest, 0.015 + 0.005 * (1.0 - dataTest), 0.05) * stepper;
	float v = getBorder(nuv, 0.01 +  0.45 * dataTest, 0.01 + 0.005 * (1.0 - dataTest), 0.0025) * stepper;



	vec3 color = vec3(circOutside * circInside + v);
	fragColor = vec4(color, 1.0);
}