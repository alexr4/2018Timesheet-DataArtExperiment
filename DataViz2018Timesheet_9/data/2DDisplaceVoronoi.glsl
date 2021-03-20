/*
Pre-processor macro defining the behavior of the GLSL program according to the GLSL version
Here we define, if the program run on a GL_ES environment (mainly used for web and mobile devices) we will use float value with medium precision
More precision (highp) will goes will more latency and low precision (lowp) will be faster but not precise
*/
#ifdef GL_ES
precision mediump float;
#endif

//pre-processor macro defining the key word PI as 3.14159265359 will compiled
#define PI 3.14159265359
#define TWOPI (PI*2.0)

/*
uniform variables are the variables bounds to the shader from the CPU side (Javascript in our case)
They are set to read-only and cannot be modified by the shader because they need to be identical for each fragment of the images
u_time, u_resolution, u_mouse and image are uniform provided by the glsl-preview package. See the documentation of the package online for more informations
*/
uniform float u_time;
uniform vec2 u_resolution;
uniform sampler2D texture; //image10.png
uniform float numberOfCell = 5.0;
uniform float numberOfLines = 100;

in vec4 vertTexCoord;
out vec4 fragColor;

struct VoroStruct{
  vec2 dist;
  vec2 indices;
};

float linear(float fmin, float fmax, float foffset){
  return mix(fmin, fmax, foffset);
}

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(10.9898,78.233)))*43758.5453123);
}

vec2 random2D( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
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

VoroStruct voronoiDistance(vec2 st, vec2 colsrows)
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
        	point = 0.5 + 0.5* sin(u_time+ TWOPI * point);

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
        	point = 0.5 + 0.5* sin(u_time + TWOPI * point);

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
               float randIndex = linear(0.05, 0.35, random(cellindex));
           		sdist = smin(sdist, d, randIndex);


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

    VoroStruct vs = VoroStruct(
        vec2(sdist, dist),
        cellindex
      );
      return vs;
  //  return vec4(sdist, dist, cellindex);
}


//to be replace by DCusrom function
float getBorder(vec2 st, vec2 colsrows, float size, float thickness, float smoothness)
{
	 //vec4 voronoi = voronoiDistance(st, colsrows);
   VoroStruct voronoi = voronoiDistance(st, colsrows);
    float dist = voronoi.dist.y;
    float sdist = voronoi.dist.x;

    float rand = random(voronoi.indices * 20.0);
    float stepper = step(size, rand);

    float fdist =  sdist * stepper + dist * (1.0 - stepper);
    fdist = dist;

    //to be replace by Data
    float randEdge = random(voronoi.indices) * 0.5;
    float randThick = random(vec2(randEdge, randEdge)) * 0.35;

    randEdge = mix(randThick * 0.5 + smoothness, 0.3, randEdge);

    return smoothstep(randEdge - randThick * 0.5 - smoothness, randEdge - randThick * 0.5, fdist) * (1.0 - smoothstep(randEdge + randThick * 0.5, randEdge + randThick * 0.5 + smoothness, fdist));
}

mat2 rotate2d(float angle){
  return mat2(cos(angle), -sin(angle),
              sin(angle),  cos(angle));
}

float lineSmooth(float x, float edge, float thickness, float smoothness){
  return smoothstep(edge, edge + smoothness, x + thickness * 0.5) - smoothstep(edge - smoothness, edge, x - thickness * 0.5);
}

float rectangleSDF(vec2 st, vec2 thickness){
  //remap st coordinate from 0.0 to 1.0 to -1.0, 1.0
  st = st * 2.0 - 1.0;
  float edgeX = abs(st.x / thickness.x);
  float edgeY = abs(st.y / thickness.y);
  return max(edgeX, edgeY);
}


void main(){
  //compute the normalize screen coordinate
  vec2 st = vertTexCoord.xy;// gl_FragCoord.xy/u_resolution.xy;
  float res = u_resolution.x / u_resolution.y;
  vec2 str = fract(vec2(vertTexCoord.x, vertTexCoord.y / res)) * 2.0 - 1.0;

  vec2 colsrows = vec2(numberOfCell, numberOfCell / res);
  VoroStruct voronoi = voronoiDistance(st, colsrows);
  float index = voronoi.indices.x +  voronoi.indices.y * colsrows.x + 1.0;

  //rand elements
  float noiseVor = noise(voronoi.indices);
  float randVor = random(voronoi.indices);

  //linear
  float thickness = linear(0.005, 0.025, noiseVor);
  float smoothness =  linear(0.0005, 0.0025, noiseVor) * numberOfCell;
  float noiseAngle = noiseVor * TWOPI;
  float speed = linear(0.005, 0.01, randVor);

  float angleAnimation = (u_time * index * speed) * TWOPI;

  float displaceScale = 0.015 * numberOfCell * 0.035;
  vec2 displace = vec2(cos(noiseAngle + angleAnimation), sin(noiseAngle + angleAnimation)) * displaceScale;

  float isHard = step(0.5, randVor);

  float edge = voronoi.dist.x;
  float border = smoothstep(thickness, thickness + smoothness, edge);

  //textures
  vec3 texDisplace = texture2D(texture, st + displace).rgb * border;
  vec3 tex = texture2D(texture, st).rgb;

  st -= vec2(0.5);
  st = rotate2d(noiseAngle + angleAnimation * speed * 50.0) * st;
  st += vec2(0.5);

  //pattern
  vec2 nuv = st * numberOfLines;//linear(100.0, 150.0, randVor);
  vec2 iuv = floor(nuv);
  vec2 fuv = fract(nuv);

  float lthick = linear(0.15, 0.75, randVor);
  float lsmooth = linear(0.05, 0.25, randVor);
  float line = lineSmooth(fuv.y, 0.5, lthick, lsmooth);
  vec3 color = vec3(line);

  //draw everything
  vec3 col = vec3(border);
  fragColor = vec4(texDisplace * color, 1.0);
}
