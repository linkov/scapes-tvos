#include <metal_stdlib>
using namespace metal;

#define PI 3.14159265359
#define TWO_PI 6.28318530718

float sinc( float x, float k ) {
    float a = PI * ( (k * x) - 1.0);
     return sin(a)/a;
}

float plot(float2 coordinatesOfCurrentPoint, float valueAssignedToY){
  return  smoothstep( valueAssignedToY-0.01, valueAssignedToY, coordinatesOfCurrentPoint.y) - smoothstep( valueAssignedToY, valueAssignedToY+0.01, coordinatesOfCurrentPoint.y);
}

vertex float4 basic_vertex (
    const device packed_float3* vertex_array [[ buffer(0) ]],
    unsigned int vid [[ vertex_id ]]
    ) {
    return float4(vertex_array[vid], 1.0);
}

fragment float4 basic_fragment() {
    return float4(float3(0.5, 0.5, 0.5),1.0);
}
kernel void january01(
                             texture2d<float,access::write> texture [[texture(0)]],
                             uint2 currentPixelPos [[thread_position_in_grid]],
                             device const float &time [[buffer(0)]]
                             ) {
        
    float3 white = float3(1.0,1.0,1.0);
    // Set Metal input variables -- begin
    // get the width and height of the screen texture
    int width = texture.get_width();
    int height = texture.get_height();
    
    
    // set its resolution
    float2 res = float2(width, height);
    
    float2 uv = float2(currentPixelPos.x,height - currentPixelPos.y) / res;
    

    float t = time * 0.5;
    float2 st = uv;
    float3 color = float3(0.0);
    
    float2 pos = float2(0.500,0.510)  - st;
    
    float r = length( abs(pos) - .2);
    float a = atan2(pos.y,pos.x);
    
        float f = cos( a * 3.);
        f = abs(cos(a*3.));
        float m = abs(cos(a*2.5))*.5+.3;
         f = abs(sin(a*(4.))*sin(a*1.))* .5 + .8;
        float g = smoothstep(-.1,1., cos(a*t))*1.4 + .3;
    
        
        color = float3( 1.000 - smoothstep(m - g - f,f+-0.852 ,r) );
        color = mix(color, white, color);
    

    texture.write(float4(color, 1.0), currentPixelPos);
}



kernel void january02(
                             texture2d<float,access::write> texture [[texture(0)]],
                             uint2 currentPixelPos [[thread_position_in_grid]],
                             device const float &time [[buffer(0)]]
                             ) {
        
    
    float3 influenced_color = float3(0.010,0.103,0.185);
    float t = time * 0.1;
    
    // Set Metal input variables -- begin
    // get the width and height of the screen texture
    int width = texture.get_width();
    int height = texture.get_height();
        
    // set its resolution
    float2 res = float2(width, height);
    float2 uv = float2(currentPixelPos.x,height - currentPixelPos.y) / res;
        float2 st = uv;
        float3 color = float3(0.0);
    
        float2 pos = float2(.1) * st;
        //vec2 pos = vec2(.5) - st;
    
        float r = length( abs(pos) - .2);
        float a = atan2(pos.y,pos.x);
    
        float b = sin( a / 2.);
        float m = abs(cos(a*5.))*.12 + .2;
        float f = abs(sin(a*(1.)) * sin(a*2. + t))* 1.0 - sinc(pos.x / .1,2. ) + 0.2 - .5;
        float g = smoothstep(-.1,1., tan(a*f))* 1.796 + 1. ;
    
        
        color = float3( 1.000 - smoothstep(f * g + m / f  ,(f / g + m / b ) +- 0.28 , r / float4(f)) );
         color = mix(color, influenced_color, float3(g,b, sin(t)));

    texture.write(float4(color, 1.0), currentPixelPos);
}
