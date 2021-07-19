// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

#include "vertexVersionSimple.h"

#include "uniformWorldConstants.h"
#include "uniformPerFrameConstants.h"

attribute mediump vec4 POSITION;
attribute vec4 COLOR;

varying vec4 color;
varying highp vec3 P;

void main()
{
    gl_Position = WORLDVIEWPROJ * POSITION;
    P = POSITION.xyz;
    color = COLOR;
}