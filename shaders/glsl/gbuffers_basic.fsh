// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

#include "fragmentVersionCentroid.h"

#if __VERSION__ >= 300
	#ifndef BYPASS_PIXEL_SHADER
		#if defined(TEXEL_AA) && defined(TEXEL_AA_FEATURE)
			_centroid in highp vec2 uv0;
			_centroid in highp vec2 uv1;
		#else
			_centroid in vec2 uv0;
			_centroid in vec2 uv1;
		#endif
	#endif
#else
	#ifndef BYPASS_PIXEL_SHADER
		varying vec2 uv0;
		varying vec2 uv1;
	#endif
#endif

varying vec4 color;
varying highp vec3 worldpos;
varying highp vec3 posx;
varying highp vec3 position;
varying highp vec3 shadowpos;
varying vec4 torchpos;

#ifdef FOG
varying vec4 fogColor;
#endif

#include "BUGJUMP/uniformWorldConstants.h"
#include "BUGJUMP/uniformPerFrameConstants.h"
#include "BUGJUMP/uniformShaderConstants.h"
#include "BUGJUMP/uniformRenderChunkConstants.h"
#include "BUGJUMP/util.h"
#include "BugSet/colorsetting.abc"

LAYOUT_BINDING(0) uniform sampler2D TEXTURE_0;
LAYOUT_BINDING(1) uniform sampler2D TEXTURE_1;
LAYOUT_BINDING(2) uniform sampler2D TEXTURE_2;

bool UnWater(vec4 X){if((X.b>=X.r*1.8)&&(X.g>X.r*1.5)&&(X.b>=X.g*1.1)&&X.b>0.15){return true;}else{return false;}}

void ABCTimeSet(float rain,float uy,inout float daytime,inout float dusktime,inout float nighttime,inout float raintime){
float ussr=texture2D(TEXTURE_1,vec2(0.0,1.0)).r;
raintime= (1.0-pow(rain,6.0))*uy;
daytime=max((ussr-0.6)*2.5,0.0)*uy;
dusktime=(1.0-min((ussr-0.5)*2.5,1.0))*max((ussr-0.4)*2.5,0.0)*(1.0-raintime)*2.5*uy;
nighttime=(1.0-daytime)*(0.8-dusktime)*uy;}

vec3 ABCToneMap(vec3 x) {
    float A = 2.35;
    float B = 0.05;
    float C = 2.40;
    float D = 0.40;
    float E = 0.40;
    float F = 1.0;
    
    x=x*(A*x+B)/(x*(C*x+D)+E/F);
  
return (x-dot(x,vec3(0.1)))*1.5+0.05;}

vec3 ABCWorldLight(vec3 color,float uy,float as,float bs,float cs,float ds,float ts){
   color=mix(color,color*dayworldcolor,as);
   color=mix(color,vec3(dot(color,vec3(0.55)))*nightworldcolor,bs*ts);
   color=mix(color,color*duskworldcolor,cs);
   color=mix(color,color*vec3(0.41,0.52,0.63),ds*uy*ts);
   color=ABCToneMap(color);
 return color;}

vec3 ABCShadow(vec3 color,float ds,float cw,float uy,float ux,float ts){
float shadowy =1.0-min(max((uy-0.89)*100.0,0.0),1.0);
float shadowx =1.0-min(max((ux-0.89)*20.0,0.0),1.0);
if(cw==0.0){shadowy=0.0;color*=1.2;}

color=mix(color,color*shadowcolor,shadowy*ts*(1.0-ds));
color=mix(color,color*shadowcolor,shadowx*ts*(1.0-shadowy)*uy*(1.0-ds));

 return color;
 }

 vec3 ABCNomalTorch(vec3 color,vec3 cli,vec2 u, float ns){
    u.x=u.x*1.15+abs(0.05*sin(TIME))*0.8;
    color = mix(mix(color,cli,pow(u.x,3.5)),color,u.y);
    color=mix(color,cli,pow(u.x,3.5)*pow(ns,3.0));
 return color;}
 
 vec3 UnWaterLight(vec4 XFOG,vec3 color,inout vec3 cli){
    vec3 unwatercolor=vec3(0.3,0.4,0.8);
 if(UnWater(XFOG)){
    cli=color*vec3(0.1,0.6,1.3)*2.3;
   color*=unwatercolor;
   }
 return color;}
 
void main()
{
#ifdef BYPASS_PIXEL_SHADER
	gl_FragColor = vec4(0, 0, 0, 0);
	return;
#else 

#if USE_TEXEL_AA
	vec4 diffuse = texture2D_AA(TEXTURE_0, uv0);
#else
	vec4 diffuse = texture2D(TEXTURE_0, uv0);
#endif

float as,cs,bs,ds;
ABCTimeSet(FOG_CONTROL.y,uv1.y,as,cs,bs,ds);
float ts=1.0-uv1.x;
 
float ux=color.g+0.35;
//if(color.w!=0.0){ux=(color.r+color.g+color.b)-0.35;}
	
#ifdef SEASONS_FAR
	diffuse.a = 1.0;
#endif

#if USE_ALPHA_TEST
	#ifdef ALPHA_TO_COVERAGE
	#define ALPHA_THRESHOLD 0.05
	#else
	#define ALPHA_THRESHOLD 0.5
	#endif
	if(diffuse.a < ALPHA_THRESHOLD)
		discard;
#endif
	
vec4 inColor = color;

#if defined(BLEND)
	diffuse.a *= inColor.a;
#endif

#if !defined(ALWAYS_LIT)
	diffuse *= texture2D( TEXTURE_1, uv1 );
#endif

#ifndef SEASONS
	#if !USE_ALPHA_TEST && !defined(BLEND)
		diffuse.a = inColor.a;
	#endif
	
	diffuse.rgb *= inColor.rgb;
#else
	vec2 uv = inColor.xy;
	diffuse.rgb *= mix(vec3(1.0,1.0,1.0), texture2D( TEXTURE_2, uv).rgb*2.0, inColor.b);
	diffuse.rgb *= inColor.aaa;
	diffuse.a = 1.0;
#endif

#ifdef BLEND
ux=color.r+color.g+color.b;
#endif

if(color.r==color.g){diffuse.rgb*=0.9;}

vec3 cli=diffuse.rgb*vec3(1.2,0.7,0.1)*1.5;
diffuse.rgb=UnWaterLight(FOG_COLOR,diffuse.rgb,cli);
diffuse.rgb=ABCShadow(diffuse.rgb,ds,color.w,uv1.y,ux,ts);
diffuse.rgb=ABCNomalTorch(diffuse.rgb,cli,uv1,(1.0-as)*(1.0-cs));
diffuse.rgb=ABCWorldLight(diffuse.rgb,uv1.y,as,bs,cs,ds,ts);

#ifdef FOG
	diffuse.rgb = mix( diffuse.rgb, fogColor.rgb, fogColor.a*0.5);
#endif

	gl_FragColor = diffuse;
	
#endif // BYPASS_PIXEL_SHADER
}
