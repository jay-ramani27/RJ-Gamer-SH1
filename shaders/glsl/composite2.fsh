// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

#include "fragmentVersionSimple.h"

#include "uniformShaderConstants.h"
#include "uniformPerFrameConstants.h"

varying vec4 color;
varying highp vec3 P;

void main()
{
    vec4 X=color;
    float A = sin(TIME+P.x+P.z+P.x+P.x+P.z+P.z+P.x+P.z);
    vec4 X1=sin(X+A);
 gl_FragColor = X1;
}