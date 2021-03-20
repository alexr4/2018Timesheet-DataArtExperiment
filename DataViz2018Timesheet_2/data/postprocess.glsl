#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform sampler2D ramp;
uniform float start;
uniform float end;
uniform float startlunch;
uniform float endlunch;
uniform vec2 resolution;

in vec4 vertTexCoord;
out vec4 fragColor;


vec3 lookUp(vec3 xyz, sampler2D lut1d){
	vec3 colorLookedUp = vec3(texture(lut1d, vec2(xyz.x, 0.0)).r,
							  texture(lut1d, vec2(xyz.y, 0.0)).g,
							  texture(lut1d, vec2(xyz.z, 0.0)).b);
	return colorLookedUp;
}

//  Iñigo Quiles : https://www.shadertoy.com/view/MsS3Wc
vec3 hsb2rgb(vec3 c){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0,
                     0.0,
                     1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

void main(){
	vec2 uv = vertTexCoord.xy;
	vec4 tex = texture(texture, uv);
	vec4 ramptex = texture(ramp, vec2(uv.x, 0.0));

	float isData = step(0.5, tex.r);
	float smoothness = 0.001;
	float dataZone =  smoothstep(start, start + smoothness, uv.x) * (1.0 - smoothstep(end - smoothness, end, uv.x));
	float morning = smoothstep(start, startlunch, uv.x) * (1.0 - step(startlunch, uv.x));
	float afternoon = smoothstep(endlunch, end, uv.x) * (1.0 - step(end, uv.x));
	float premorning = smoothstep(0.0, start, uv.x) * (1.0 - step(start, uv.x));
	float night = smoothstep(end, 1.0, uv.x);

	vec4 globalData = vec4(premorning, morning, afternoon, night);
	float dayCutout = (premorning + morning + afternoon + night) * 0.9 + 0.1;
	float day = tex.g;
	float weekday = tex.b;
	float isWeekend = step((1.0/7.0) * 5.0, weekday);
	vec3 targetuv = vec3(dayCutout, day, weekday);


	float hueOffset = (isWeekend * (60.0 / 360.0));
	float startHue = 200.0;
	float endHue = startHue + 80.0;
	float minhue = (startHue / 360.0) - hueOffset;
	float maxhue = hueOffset + (endHue / 360.0) - minhue;
	vec3 dayColor = hsb2rgb(
		vec3(minhue + dayCutout * maxhue, 
			pow(day, 0.35), 
			0.95)
		); 

	vec3 background = hsb2rgb(
		vec3(fract(minhue + 0.35), 
			1.0, 
			0.095)
		); 

	vec3 color = dayColor * isData + background * (1.0 - isData);
	vec3 blackNWhite = pow(vec3((targetuv.r * targetuv.g * targetuv.b) * 0.85 + 0.15), vec3(0.75));
	fragColor = vec4(color, 1.0);
}