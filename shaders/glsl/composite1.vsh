// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

#include "vertexVersionCentroidUV.h"

#include "BUGJUMP/uniformWorldConstants.h"
#include "BUGJUMP/uniformShaderConstants.h"

attribute POS4 POSITION;
attribute vec2 TEXCOORD_0;

varying highp vec3 normal;

void main()
{
 normal =POSITION.xyz*vec3(2.0,1.0,2.0);
   POS4 position = WORLDVIEWPROJ*(POSITION*vec4(6.0,2.0,6.0,1.0));
   gl_Position = position;
    uv = TEXCOORD_0;
}