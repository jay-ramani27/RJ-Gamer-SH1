// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

#include "vertexVersionSimple.h"

#include "uniformWorldConstants.h"
#include "uniformPerFrameConstants.h"
#include "uniformShaderConstants.h"

attribute mediump vec4 POSITION;
attribute vec4 COLOR;

varying vec4 color;
varying highp vec3 P;
const float fogNear = 0.9;

const vec3 inverseLightDirection = vec3(0.62, 0.78, 0.0);
const float ambient = 0.7;

void main()
{
    POS4 pos = WORLDVIEWPROJ * POSITION;
	POS4 worldPos = WORLD * POSITION;
	P=POSITION.xyz;

 	gl_Position = pos;
 	color = COLOR * CURRENT_COLOR;

 	float depth = length(worldPos.xyz) / RENDER_DISTANCE;
 	float fog =1.0;

 	color.a *=(1.0 - fog);
}