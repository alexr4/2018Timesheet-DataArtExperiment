#ifdef GL_ES
precision highp float;
precision highp int;
#endif

#define PI 3.14159265359
#define TWO_PI PI * 2.0

uniform sampler2D texture;
uniform vec2 resolution;
uniform float data[365];
uniform float dataDay[365];
uniform vec2 mouse;
uniform float time;

in vec4 vertTexCoord;
out vec4 fragColor;

float inoutexp(float value){
  float nvalue = value * 2.0;
  float inc = 1.0;
  float eased = 0.0;
  float stepper = step(1.0, value);
  eased += (0.5 * pow(2.0, 10.0 * (nvalue - 1.0))) * (1.0 - stepper);
  value--;
  eased += (0.5 * (-pow(2.0, -10.0 * (nvalue - 1.0)) + 2.0)) * stepper;

  return (value == 0.0 || value == 1.0) ? value : clamp(eased, 0.0, 1.0);
}

float inoutquad(float value){
    value *= 2.0;
    float inc = 1.0;
    float eased = 0.0;
    float stepper = step(1.0, value);
    eased += (0.5 * value * value) * (1.0 - stepper);
    value--;
    eased += (-0.5 * (value * (value - 2.0) - 1.0)) * stepper;
    return clamp(eased, 0.0, 1.0);
}

float inoutcubic(float value)
{ 
   float duration = 1.0;
   value /= duration/2;
   float inc = 1.0;
   float eased = 0.0;
   float stepper = step(1.0, value);
   eased += (0.5 * pow(value, 3.0)) * (1.0 - stepper);
   value -= 2.0;
   eased += 0.5 *  (pow(value, 3.0) + 2.0) * stepper;
   
  return (value == 0.0 || value == 1.0) ? value : clamp(eased, 0.0, 1.0);
}

float inoutquart(float value)
{ 
   float duration = 1.0;
   value /= duration/2;
   float inc = 1.0;
   float eased = 0.0;
   float stepper = step(1.0, value);
   eased += (0.5 * pow(value, 4.0)) * (1.0 - stepper);
   value -= 2.0;
   eased += 0.5 *  (pow(value, 4.0) - 2.0) * stepper;
   
  return (value == 0.0 || value == 1.0) ? value : clamp(eased, 0.0, 1.0);
}

float inoutquint(float value)
{ 
   float duration = 1.0;
   value /= duration/2;
   float inc = 1.0;
   float eased = 0.0;
   float stepper = step(1.0, value);
   eased += (0.5 * pow(value, 5.0)) * (1.0 - stepper);
   value -= 2.0;
   eased += 0.5 *  (pow(value, 5.0) + 2.0) * stepper;
   
  return (value == 0.0 || value == 1.0) ? value : clamp(eased, 0.0, 1.0);
}

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(10.9898,78.233)))*43758.5453123);
}

vec2 random2D( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
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

vec4 voronoiDistance(vec2 st, vec2 colsrows)
{
	vec2 nuv = st * colsrows;
	vec2 iuv = floor(nuv);
	vec2 fuv = fract(nuv);

    vec2 nearestNeighborsIndex;
    vec2 nearestDiff;
    vec2 cellindex;

    //compute voronoi
    float dist = 8.0;
    for( int j=-1; j<=1; j++ ){
    	for( int i=-1; i<=1; i++ )
    	{
    		//neightbor
        	vec2 neighbor = vec2(i, j);

        	//randomPoint
        	vec2 point = random2D(iuv + neighbor);

        	//animation
        	//point = 0.5 + 0.5* sin(time + TWO_PI * point);

        	//define the vector between the pixel and the point
        	vec2  diff = neighbor + point - fuv;

        	//Compute the Dot product
        	float d = dot(diff,diff);

    	    if(d < dist)
    	    {
    	        dist = d;
    	        nearestDiff = diff;
    	        nearestNeighborsIndex = neighbor;
    	        cellindex = (iuv + vec2(i, j)) / colsrows;
    	    }
    	}
	}
	float basedVoronoi = dist;

    //compute distance
    dist = 8.0;
    float sdist = 8.0;
    for( int j=-2; j<=2; j++ ){
    	for( int i=-2; i<=2; i++ )
    	{
    		//neightbor
    	    vec2 neighbor = nearestNeighborsIndex + vec2(i, j);

    	    //randomPoint
    	    vec2 point = random2D(iuv + neighbor);
        	
        	//animation
        	//point = 0.5 + 0.5* sin(time + TWO_PI * point);

        	//define the vector between the pixel and the point
    	    vec2  diff = neighbor + point - fuv;

        	//Compute the Dot product to get the distance
    	    float d = dot(0.5 * (nearestDiff + diff), normalize(diff - nearestDiff));


    	   //rounded voronoi distance from https://www.shadertoy.com/view/lsSfz1
    	   //Skip the same cell
    	    if( dot(diff-nearestDiff, diff-nearestDiff)>.00001){
    	   		 // Abje's addition. Border distance using a smooth minimum. Insightful, and simple.
           		 // On a side note, IQ reminded me that the order in which the polynomial-based smooth
           		 // minimum is applied effects the result. However, the exponentional-based smooth
           		 // minimum is associative and commutative, so is more correct. In this particular case,
           		 // the effects appear to be negligible, so I'm sticking with the cheaper polynomial-based
           		 // smooth minimum, but it's something you should keep in mind. By the way, feel free to
           		 // uncomment the exponential one and try it out to see if you notice a difference.
           		 //
           		 // // Polynomial-based smooth minimum.
           		sdist = smin(sdist, d, .15);

            
            	// Exponential-based smooth minimum. By the way, this is here to provide a visual reference
            	// only, and is definitely not the most efficient way to apply it. To see the minor
            	// adjustments necessary, refer to Tomkh's example here: Rounded Voronoi Edges Analysis -
            	// https://www.shadertoy.com/view/MdSfzD
            	//sdist = sminExp(sdist, d, 20.);
        	}	

    	    //voronoi distance
    	    dist = min(dist, d);

    	}
	}

    return vec4(sdist, dist, cellindex);
}


//to be replace by DCusrom function
float getBorder(vec2 st, vec2 colsrows, float thickness, float smoothness)
{
	vec4 voronoi = voronoiDistance(st, colsrows);
    float dist = voronoi.y;
    float sdist = voronoi.x;
    int index = int(floor(voronoi.z + voronoi.w * colsrows.x));
    float hour = data[index];
    float day = dataDay[index];


    float stepper = step(0.58, day);
    float fdist =  sdist * stepper + dist *  (1.0 - stepper);


    //to be replace by Data
    float stepperHour = step(0.09090909, hour);
    float remap = inoutcubic(hour);
    float edge = mix(0.3, 0.0, remap);

    float randThickness = thickness;//random(vec2(day, hour) + voronoi.zw) * (thickness * 2.0) + thickness;

 	
 	float cell = smoothstep(edge - randThickness * 0.5 - smoothness, edge - randThickness * 0.5, fdist) * (1.0 - smoothstep(edge + randThickness * 0.5, edge + randThickness * 0.5 + smoothness, fdist));
 // float cell = smoothstep(0.0, edge + randThickness * 0.5, fdist) * (1.0 - smoothstep(edge + randThickness * 0.5, edge + randThickness * 0.5 + smoothness, fdist));
  
  //return smoothstep(edge, edge + smoothness, fdist);
   //float cell = step(edge, fdist);
   return cell * (remap * 0.65 + 0.35);
}

mat2 scale2d(vec2 scale){
  return mat2(scale.x, 0.0,
              0.0    , scale.y);
}

vec2 scale(vec2 st, vec2 scale){
  //move to center
  st -= vec2(0.5);
  st = scale2d(scale) * st;
  //reset position
  st += vec2(0.5);

  return st;
}

void main(){
	vec2 uv = vertTexCoord.xy;

	float sqrtDay = sqrt(365);
	float iSqrtDay = ceil(sqrtDay);
/*
	uv = scale(uv, vec2(1.00));

	vec2 stepmax = 1.0 - step(vec2(1.0), uv);
	vec2 stepmin = step(vec2(0.0), uv);

	uv *= (stepmin.x * stepmin.y);
	uv *= (stepmax.x * stepmax.y);
*/
	//to be replace
	float voronoiBorder = getBorder(uv, vec2(iSqrtDay), 0.025, 0.025);


	float voronoi = voronoiDistance(uv, vec2(iSqrtDay * 0.5)).x;

	vec3 color = vec3(uv, 0.0) * 0.0 + vec3(voronoiBorder) * 1.0;
	fragColor = vec4(color, 1.0);
}
