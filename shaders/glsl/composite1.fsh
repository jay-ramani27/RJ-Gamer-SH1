// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

#include "fragmentVersionCentroid.h"

#if __VERSION__ >= 300

#if defined(TEXEL_AA) && defined(TEXEL_AA_FEATURE)
_centroid in highp vec2 uv;
#else
_centroid in vec2 uv;
#endif

#else

varying vec2 uv;

#endif

#include "BUGJUMP/uniformShaderConstants.h"
#include "BUGJUMP/util.h"
#include "BUGJUMP/uniformPerFrameConstants.h"
#include "BugSet/colorsetting.abc"

uniform sampler2D TEXTURE_0;

varying highp vec3 normal;

void ABCSkyTimeSet(out float daytime,out float dusktime,out float nighttime,out float raintime,float rain,vec4 XFOG){
raintime = clamp(1.0-pow(rain,5.0),0.0,1.0);
dusktime = clamp(((1.5-XFOG.r*2.0)+(1.0-XFOG.b))*(1.0-dot(XFOG.rgb,vec3(0.31)))*XFOG.g*2.0,0.0,1.0)*(1.0-raintime);
daytime = clamp((XFOG.b-0.5)*2.5*(1.1-dusktime),0.0,1.0);
nighttime = clamp(1.0-XFOG.g*(1.5-dusktime)*2.5,0.0,1.0);
}

vec4 ABCsunandmoon(vec4 XFOG,vec3 color,vec3 pos,float daytime,float dusktime,float nighttime,float raintime){

   vec3 sunandmoonlight=mix(vec3(1.0),daysuncolor,daytime);
   sunandmoonlight=mix(sunandmoonlight,dusksuncolor,dusktime);
   sunandmoonlight=mix(sunandmoonlight,nightsuncolor,nighttime);
   sunandmoonlight=mix(sunandmoonlight,rainsuncolor,raintime);
   
    float tarce=mix(25.0,22.0,daytime);
    tarce=mix(tarce,24.0,dusktime);
    tarce=mix(tarce,12.0,nighttime);
    tarce=mix(tarce,0.0,raintime);
    float lightset=mix(0.0,0.01,daytime);
    lightset=mix(lightset,0.2,dusktime);
    lightset=mix(lightset,0.1,nighttime);
    lightset=mix(lightset,0.0,raintime);
    float sunmoon=1.0-pow(length(pos*tarce),20.0);
    float sunmoonlight=1.0-pow(length(pos),lightset);
    vec4 sunandmoon=mix(vec4(sunandmoonlight,clamp(sunmoonlight,0.0,1.0)),mix(vec4(0.9,0.8,0.7,1.0),vec4(1.5,0.6,0.1,1.0),dusktime),clamp(sunmoon,0.0,1.0));
    if(raintime>=0.6)sunandmoon*=0.0;
 return sunandmoon;}
void main()
{

#if !defined(TEXEL_AA) || !defined(TEXEL_AA_FEATURE)
	vec4 diffuse = texture2D( TEXTURE_0, uv);
#else
	vec4 diffuse = texture2D_AA(TEXTURE_0, uv);
#endif


float daytime,dusktime,nighttime,raintime;
ABCSkyTimeSet(daytime,dusktime,nighttime,raintime,FOG_CONTROL.y,FOG_COLOR);

vec4 sunmoon=ABCsunandmoon(FOG_COLOR,diffuse.rgb,normal,daytime,dusktime,nighttime,raintime);
gl_FragColor =sunmoon;
}
