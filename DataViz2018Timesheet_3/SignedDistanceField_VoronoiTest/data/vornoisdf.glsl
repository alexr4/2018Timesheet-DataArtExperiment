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

in vec4 vertTexCoord;
out vec4 fragColor;

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

	float stepper = 1.0 - step(0.5, normRadius);

	float distFromMouse = length(mouse - uv) / (hyp);

	vec2 nuv = uv * 80.0;// * stepper;
	float dataTest = pow(texture(texture, uv).r, 1.0);// + distFromMouse;
	float v =getBorder(nuv, 0.0 +  0.5 * dataTest, 0.015 + 0.005 * (1.0 - dataTest), 0.05) * stepper;


	vec3 color = vec3( v);
	fragColor = vec4(color, 1.0);
}