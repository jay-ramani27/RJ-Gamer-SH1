// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

#include "vertexVersionCentroid.h"
#if __VERSION__ >= 300
	#ifndef BYPASS_PIXEL_SHADER
		_centroid out vec2 uv0;
		_centroid out vec2 uv1;
	#endif
#else
	#ifndef BYPASS_PIXEL_SHADER
		varying vec2 uv0;
		varying vec2 uv1;
	#endif
#endif

#ifndef BYPASS_PIXEL_SHADER
	varying vec4 color;
#endif

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
#include "BUGJUMP/uniformEntityConstants.h"

attribute POS4 POSITION;
attribute vec4 COLOR;
attribute vec2 TEXCOORD_0;
attribute vec2 TEXCOORD_1;

const float rA = 1.0;
const float rB = 1.0;
const vec3 UNIT_Y = vec3(0,1,0);
const float DIST_DESATURATION = 56.0 / 255.0; //WARNING this value is also hardcoded in the water color, don'tchange

void main()
{
    POS4 worldPos;
    POS4 worldPos1;
#ifdef AS_ENTITY_RENDERER
		POS4 pos = WORLDVIEWPROJ * POSITION;
		worldPos = pos;
		worldPos1=pos;
#else
    worldPos.xyz = (POSITION.xyz * CHUNK_ORIGIN_AND_SCALE.w) + CHUNK_ORIGIN_AND_SCALE.xyz;
    worldPos.w = 1.0;
    worldPos1.xyz=POSITION.xyz+vec3(CHUNK_ORIGIN_AND_SCALE.x,0.0,CHUNK_ORIGIN_AND_SCALE.z);
   
    // Transform to view space before projection instead of all at once to avoid floating point errors
    // Not required for entities because they are already offset by camera translation before rendering
    // World position here is calculated above and can get huge
    POS4 pos = WORLDVIEW * worldPos;
    pos = PROJ * pos;
#endif
    gl_Position = pos;
    vec3 wav=POSITION.xyz;
    worldpos=worldPos.xyz;
    posx=pos.xyz;
    position=POSITION.xyz;
    torchpos = TILE_LIGHT_COLOR;
    shadowpos=worldPos.xyz;

#ifndef BYPASS_PIXEL_SHADER
    uv0 = TEXCOORD_0;
    uv1 = TEXCOORD_1;
	color = COLOR;
#endif

#ifdef ALPHA_TEST 
#ifdef FANCY 
float rainwav=0.03;
float timeset=abs(sin(TIME*0.1))+0.4;
float wavs1=rainwav*timeset*sin(TIME*4.0+wav.x+wav.x+wav.z+cos(TIME*2.5+wav.z+wav.y))*sin(wav.x+wav.y)*uv1.y;
if(color.g!=color.r&&color.g!=color.b&&color.a!=0.0){gl_Position.x += wavs1;}
#endif
#endif

if(COLOR.a==0.0){
float rainwav=0.03;
float timeset=abs(sin(TIME*0.1))+0.4;
gl_Position.x +=rainwav*timeset*sin(TIME*4.0+wav.x+wav.y+wav.x+cos(TIME*2.0+wav.x))*sin(wav.y+wav.x+wav.z)*TEXCOORD_1.y;
}

///// find distance from the camera

#if defined(FOG) || defined(BLEND)
	#ifdef FANCY
		vec3 relPos = -worldPos.xyz;
		float cameraDepth = length(relPos);
	#else
		float cameraDepth = pos.z;
	#endif
#endif

///// apply fog

#ifdef FOG
	float len = cameraDepth / RENDER_DISTANCE;
	#ifdef ALLOW_FADE
		len += RENDER_CHUNK_FOG_ALPHA;
	#endif

    fogColor.rgb = FOG_COLOR.rgb;
	fogColor.a = clamp((len - FOG_CONTROL.x) / (FOG_CONTROL.y - FOG_CONTROL.x), 0.0, 1.0);
#endif

///// blended layer (mostly water) magic
#ifdef BLEND
	//Mega hack: only things that become opaque are allowed to have vertex-driven transparency in the Blended layer...
	//to fix this we'd need to find more space for a flag in the vertex format. color.a is the only unused part
	bool shouldBecomeOpaqueInTheDistance = color.a < 0.95;
	if(shouldBecomeOpaqueInTheDistance) {
		#ifdef FANCY  /////enhance water
			float cameraDist = cameraDepth / FAR_CHUNKS_DISTANCE;
			color = COLOR;
		#else
			// Completely insane, but if I don't have these two lines in here, the water doesn't render on a Nexus 6
			vec4 surfColor = vec4(color.rgb, 1.0);
			color = surfColor;
				
			vec3 relPos = -worldPos.xyz;
			float camDist = length(relPos);
			float cameraDist = camDist / FAR_CHUNKS_DISTANCE;
		#endif //FANCY
		
		float alphaFadeOut = clamp(cameraDist, 0.0, 1.0);
		color.a = mix(color.a, 1.0, alphaFadeOut);
	}
#endif

#ifndef BYPASS_PIXEL_SHADER
	#ifndef FOG
		// If the FOG_COLOR isn't used, the reflection on NVN fails to compute the correct size of the constant buffer as the uniform will also be gone from the reflection data
		color.rgb += FOG_COLOR.rgb * 0.000001;
	#endif
#endif
}
