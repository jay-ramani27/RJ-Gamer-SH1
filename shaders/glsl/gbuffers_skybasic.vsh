// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

#include "vertexVersionSimple.h"

#include "BUGJUMP/uniformWorldConstants.h"
#include "BUGJUMP/uniformPerFrameConstants.h"
#include "BUGJUMP/uniformShaderConstants.h"
#include "BUGJUMP/uniformInterFrameConstants.h"

attribute mediump vec4 POSITION;
attribute vec4 COLOR;

varying vec4 color;
varying highp vec3 posx;
const float fogNear = 0.3;

void main()
{

    posx=POSITION.xyz*8.0;

    gl_Position = WORLDVIEWPROJ *vec4(POSITION.x,POSITION.y-mix(0.0,0.04,length(posx)),POSITION.z,POSITION.w);
    
    color = mix( CURRENT_COLOR, FOG_COLOR, COLOR.r );
}