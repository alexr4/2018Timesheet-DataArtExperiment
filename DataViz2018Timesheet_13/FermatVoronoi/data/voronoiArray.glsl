//blend sources : http://wiki.polycount.com/wiki/Blending_functions

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

//pre-processor macro defining the key word PI as 3.14159265359 will compiled
#define PI 3.1415926535897932384626433832795
#define TWOPI (PI*2.0)
#define HYP sqrt(2.0)

uniform sampler2D texture;
uniform vec2 resolution;
uniform float fermat[240 * 3];
uniform int maxElements = 720;
uniform vec2 mouse;

in vec4 vertTexCoord;
out vec4 fragColor;


struct VoroStruct{
  vec2 dist;
  vec2 indices;
};

float random(float value){
		return fract(sin(value) * 43758.5453123);
}


float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(10.9898,78.233)))*43758.5453123);
}

vec2 random2D( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

float linear(float fmin, float fmax, float foffset){
  return mix(fmin, fmax, foffset);
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

// IQ's polynomial-based smooth minimum function.
float smin( float a, float b, float k ){

    float h = clamp(.5 + .5*(b - a)/k, 0., 1.);
    return mix(b, a, h) - k*h*(1. - h);
}

// Commutative smooth minimum function. Provided by Tomkh and taken from
// Alex Evans's (aka Statix) talk:
// http://media.lolrus.mediamolecule.com/AlexEvans_SIGGRAPH-2015.pdf
// Credited to Dave Smith @media molecule.
float smin2(float a, float b, float r)
{
   float f = max(0., 1. - abs(b - a)/r);
   return min(a, b) - r*.25*f*f;
}

// IQ's exponential-based smooth minimum function. Unlike the polynomial-based
// smooth minimum, this one is associative and commutative.
float sminExp(float a, float b, float k)
{
    float res = exp(-k*a) + exp(-k*b);
    return -log(res)/k;
}

VoroStruct voronoiDistance(vec2 st, vec2 colsrows, float seed, float minRound, float maxRound)
{
	vec2 nuv = st * colsrows;
	vec2 iuv = floor(nuv);
	vec2 fuv = fract(nuv);

    vec2 nearestNeighborsIndex;
    vec2 nearestDiff;
    vec2 cellindex;

    //compute voronoi
    float dist = 8.0;
	for(int i=0; i<fermat.length; i+=3){
		if(i>=maxElements){
			break;
		}else{
			vec2 nei = vec2(fermat[i], fermat[i+1])/resolution;
	       // float d = distance(uv, nei);
	        vec2  diff = nei - st;

	        //Compute the Dot product
	        float d = dot(diff,diff);
	        
		    if(d < dist)
		    {
		        dist = d;
		        nearestDiff = diff;
		        nearestNeighborsIndex = nei;
		        //cellindex = (iuv + vec2(i, i)) / colsrows;
		        cellindex = vec2(float(i));// (iuv + vec2(i, i)) / colsrows;
		    }
		}
		
	}

   
	float basedVoronoi = dist;

  //compute distance
  dist = 8.0;
  float sdist = 8.0;


    for(int i=0; i<fermat.length; i+=3){
    	if(i>=maxElements){
			break;
		}else{
			vec2 nei = vec2(fermat[i], fermat[i+1])/resolution;
	       // float d = distance(uv, nei);
	        vec2  diff = nei - st;

	        //Compute the Dot product
	       //Compute the Dot product to get the distance
	  	    float d = dot(0.5 * (nearestDiff + diff), normalize(diff - nearestDiff));


	  	   //rounded voronoi distance from https://www.shadertoy.com/view/lsSfz1
	  	   //Skip the same cell
	  	    if( dot(diff-nearestDiff, diff-nearestDiff)>.00001){
	  	    		float t= fermat[i+2];
	  	    		float roundFactor = mix(minRound, maxRound, t); 
	         		sdist = smin(sdist, d, roundFactor);
	      	}
	  	    //voronoi distance
	  	    dist = min(dist, d);
  		}
	}

    VoroStruct vs = VoroStruct(
        vec2(sdist, dist),
        cellindex
      );

    return vs;
}



//to be replace by DCusrom function
float getBorder(VoroStruct voronoi, float minSize, float maxSize, float minThickness, float maxThickness, float minSmoothness, float maxSmoothness)
{
    float offset = random(voronoi.indices);
    float stepper = 1.0 - step(0.5, offset);
    float dist = voronoi.dist.x;

    float size = mix(minSize, maxSize, offset);
    float thickness = mix(minThickness, maxThickness, offset);
    float smoothness = mix(minSmoothness, maxSmoothness, offset);

    //to be replace by Data
    return smoothstep(size - thickness - smoothness, size - thickness, dist);
    // - (1.0 - smoothstep(size + thickness * 5.5 + smoothness, size + thickness * 5.5 , dist));
}

mat2 rotate2d(float angle){
  return mat2(cos(angle), -sin(angle),
              sin(angle),  cos(angle));
}

vec2 fromCartToPolar(vec2 st){
  vec2 toCenter = vec2(0.5) - st;
  float angle   = atan(toCenter.y, toCenter.x) + PI;
  float dist = length(toCenter) / (sqrt(2.0) * 0.5);

  float nangle = (angle /TWOPI) * 2.0 - 1.0;
  return vec2(nangle, dist);
}



float circularIn(float t) {
  return 1.0 - sqrt(1.0 - t * t);
}

float qinticIn(float t) {
  return pow(t, 5.0);
}

float quadraticIn(float t) {
  return t * t;
}

float exponentialIn(float t) {
  return t == 0.0 ? t : pow(2.0, 10.0 * (t - 1.0));
}

float cubicIn(float t) {
  return t * t * t;
}

vec3 colorPalette(float value, vec3 start, vec3 end, vec3 devA, vec3 devB){
	return start+end * (cos(TWOPI * (devA*value+devB)));
}

void main(){
	vec2 uv = vertTexCoord.xy;	

	vec4 tex = texture(texture, uv);

    VoroStruct voronoi = voronoiDistance(uv, vec2(5.0), 0.0, 0.0075, 0.09);
	
	float res = resolution.x / resolution.y;
	vec2 uvAspectRatio = vec2(0.5) - uv;
	uvAspectRatio = vec2(uvAspectRatio.x, uvAspectRatio.y / res);
	uvAspectRatio = vec2(0.5) + uvAspectRatio;
	float dCenter = 1.0 - (length(vec2(0.5) - uvAspectRatio) / (HYP * 0.45));
	float edgeCirc = 0.25;
	

 	float dist = voronoi.dist.x;
 	float edge = 0.0025;
 	float noiseuv0025 = noise(uv * resolution * 0.015);
 	float thickness = 0.00025;
 	float smoothness = noiseuv0025 * 0.015 + 0.0001;
	float innerdist = smoothstep(edge - thickness*0.5 - smoothness, edge - thickness*0.5, dist);
	float idist = smoothstep(edge - thickness*0.5 - smoothness, edge - thickness*0.5, dist) * (1.0 -  smoothstep(edge + thickness*0.5, edge+thickness + thickness*0.5 + smoothness, dist));
	
	//edge
	float outerCenterEasing = smoothstep(edgeCirc - thickness * 0.25, edgeCirc + thickness * 0.25 , dCenter);
	float dCenterEasing = smoothstep(edgeCirc - thickness * 0.5 - smoothness, edgeCirc - thickness * 0.5 , dCenter) * (1.0 - smoothstep(edgeCirc + thickness * 0.5, edgeCirc + thickness * 0.5 + smoothness , dCenter));
	dCenterEasing *= innerdist;

	float oeasing = outerCenterEasing * idist + dCenterEasing;
	float oceasing = clamp(oeasing, 0.0, 1.0);

	//eading
	float easing = circularIn(oceasing);
  	easing = exponentialIn(easing);
	easing = clamp(easing, 0.0, 1.0);

  	//grain of path tracing
	float noiseuv = noise(uv * resolution);
	float grain = random(noiseuv) * 2.0 - 1.0;
  	float ograd = easing;
  	easing += grain * 0.1;
  	easing *= oeasing * 1.25;

 	vec3 color = vec3(easing);

	fragColor = vec4(color, 1.0);
}