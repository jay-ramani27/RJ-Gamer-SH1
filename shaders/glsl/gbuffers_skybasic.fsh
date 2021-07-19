// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

#include "fragmentVersionSimple.h"
#include "BUGJUMP/uniformPerFrameConstants.h"
#include "BUGJUMP/uniformShaderConstants.h"
#include "BUGJUMP/util.h"
#include "BugSet/colorsetting.abc"

varying vec4 color;
varying highp vec3 posx;

void ABCTimeSystem1(out float daytime,out float dusktime,out float nighttime,out float raintime,float rain,vec4 XFOG){
raintime = clamp(1.0-pow(rain,5.0),0.0,1.0);
dusktime = clamp(((1.5-XFOG.r*2.0)+(1.0-XFOG.b))*(1.0-dot(XFOG.rgb,vec3(0.31)))*XFOG.g*2.0,0.0,1.0)*(1.0-raintime);
daytime = clamp((XFOG.b-0.5)*2.5*(1.1-dusktime),0.0,1.0);
nighttime = clamp(1.0-XFOG.g*(1.5-dusktime)*2.5,0.0,1.0);
}

vec4 ABCSkyLight(vec4 color,vec4 Folor,float ps,float daytime,float dusktime,float nighttime,float raintime){

    vec4 skyrainlight=mix(skydayrainlight,skynightrainlight,nighttime);
    
    color = mix(skydaylight,skydusklight,dusktime);
    color = mix(color,skynightlight,nighttime);
    color = mix(color,skyrainlight,raintime);
    
    color = mix(color,Folor*color*1.2,clamp(pow(ps*4.8,1.2),0.0,1.0)*(1.0-nighttime));
    color = mix(color,Folor*1.2,clamp(pow(ps*1.9,1.5),0.0,1.0)*(1.0-nighttime));
    color = mix(color,Folor,clamp(pow(ps*1.1,1.0),0.0,1.0));

 return color;}

void main()
{
float ps = length(posx/7.0);

float daytime,dusktime,nighttime,raintime;
ABCTimeSystem1(daytime,dusktime,nighttime,raintime,FOG_CONTROL.y,FOG_COLOR);

vec4 skylightabc = ABCSkyLight(color,FOG_COLOR,ps,daytime,dusktime,nighttime,raintime);

gl_FragColor = skylightabc;

}