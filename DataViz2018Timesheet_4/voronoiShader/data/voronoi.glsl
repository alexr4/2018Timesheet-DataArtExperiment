#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PI 3.14159265359
#define TWO_PI PI * 2.0

uniform sampler2D texture;
uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;

in vec4 vertTexCoord;
out vec4 fragColor;


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
float getBorder(vec2 st, vec2 colsrows, float size, float thickness, float smoothness)
{
	vec4 voronoi = voronoiDistance(st, colsrows);
    float dist = voronoi.y;
    float sdist = voronoi.x;

    float rand = random(voronoi.zw * 20.0);
    float stepper = step(0.5, rand);

    float fdist =  sdist * stepper + dist * (1.0 - stepper);
    fdist = dist;

    //to be replace by Data
    float randEdge = random(voronoi.zw);
    float randThick = random(vec2(randEdge, randEdge)) * 0.05;

    randEdge = mix(randThick * 0.5 + smoothness, 0.3, randEdge);

    return smoothstep(randEdge - randThick * 0.5 - smoothness, randEdge - randThick * 0.5, fdist) * (1.0 - smoothstep(randEdge + randThick * 0.5, randEdge + randThick * 0.5 + smoothness, fdist));
   //return 1.0 - smoothstep(randEdge + randThick * 0.5, randEdge + randThick * 0.5 + smoothness, sdist);
}


void main(){
	vec2 uv = vertTexCoord.xy;

	float sqrtDay = sqrt(365);
	float iSqrtDay = ceil(sqrtDay) * .75;

	//to be replace
	float voronoiBorder = getBorder(uv, vec2(iSqrtDay), 0.001, 0.025, 0.025);


	float voronoi = voronoiDistance(uv, vec2(iSqrtDay * 0.5)).x;

	vec3 color = vec3(uv, 0.0) * 0.0 + vec3(voronoiBorder) * 1.0;
	fragColor = vec4(color, 1.0);
}
