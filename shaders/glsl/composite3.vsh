// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

#include "vertexVersionCentroidUV.h"

#include "uniformWorldConstants.h"
#include "uniformShaderConstants.h"

attribute POS4 POSITION;
attribute vec2 TEXCOORD_0;

varying highp vec3 P;

void main()
{
    gl_Position = WORLDVIEWPROJ * POSITION;
    P=POSITION.xyz;

    uv = (UV_TRANSFORM * vec4(TEXCOORD_0, 0, 1)).xy;
}