// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

#include "fragmentVersionSimple.h"

#include "uniformShaderConstants.h"
#include "uniformPerFrameConstants.h"
#include "util.h"

varying vec4 color;
varying highp vec3 P;

void main(){
 gl_FragColor = color;
}