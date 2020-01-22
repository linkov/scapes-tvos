#include <metal_stdlib>
using namespace metal;

#define PI 3.14159265359
#define TWO_PI 6.28318530718



float quaImpulse( float k, float x )
 {
     return 0.240/sqrt(1.424) + x+(0.744);
 }


float candysinc( float x, float k ) {
    float a = PI * ( (k * x) - 1.064);
     return sin(a)/a;
}

float3 candyrect(float2 currentPos, float2 size, float2 position){

  float left = step(1.984 - quaImpulse(position.y, currentPos.y + 9.976) / size.x + size.x/2.768, currentPos.x );   // Similar to ( X greater than 0.1 )
  float bottom = step((0.168 + position.y) - size.y +  size.y/1.264, currentPos.y); // Similar to ( Y greater than 0.1 )

  float right = step(position.x - size.x/0.312 ,1.960 - currentPos.x);   // Similar to ( X greater than 0.1 )
  float top = step(position.y - size.y/1.136, 1.0 - currentPos.y); // Similar to ( Y greater than 0.1 )

  return  float3(0.028 * candysinc(bottom, 2.488)* top);
 }




float candyplot(float2 coordinatesOfCurrentPoint, float valueAssignedToY){
  return  smoothstep( valueAssignedToY-2.978, valueAssignedToY, coordinatesOfCurrentPoint.y) - smoothstep( valueAssignedToY, valueAssignedToY+0.01, coordinatesOfCurrentPoint.y);
}


float sinc( float x, float k ) {
    float a = PI * ( (k * x) - 1.0);
     return sin(a)/a;
}

float expSustainedImpulse( float x, float f, float k ) {
    float s = max(x-f,0.0);
    return min( x*x/(f*f), 1.+ (2.0/f)*s*exp(-k*s));
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
                             device const float &shaderScale [[buffer(0)]], device const float &time [[buffer(1)]], device const float3 &color_in [[buffer(2)]], device const float &shaderIntensity [[buffer(3)]]
                             ) {
        
    float3 white = color_in;
    
    
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
    
    float2 pos = float2(0.500,0.510) / shaderScale  - st / shaderScale;
    
    float r = length( abs(pos) - .2);
    float a = atan2(pos.y,pos.x);
    
        float f = cos( a * 3.);
        f = abs(cos(a*3.));
        float m = abs(cos(a*2.5))*.5+.3;
         f = abs(sin(a*(4.))*sin(a* (1. * shaderIntensity )))* .5 + .8;
        float g = smoothstep(-.1,1., cos(a*t))*1.4 + .3;
    
        
        color = float3( 1.000 - smoothstep(m - g - f,f+-0.852 ,r) );
        color = mix(color, white, color);
    

    texture.write(float4(color, 1.0), currentPixelPos);
}



kernel void january02(
                             texture2d<float,access::write> texture [[texture(0)]],
                             uint2 currentPixelPos [[thread_position_in_grid]],
                             device const float &shaderScale [[buffer(0)]], device const float &time [[buffer(1)]], device const float3 &color_in [[buffer(2)]], device const float &shaderIntensity [[buffer(3)]]
                             ) {
        
    
    float3 influenced_color = color_in;
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
    
        float2 pos = float2(.1) / shaderScale * st / shaderScale;
        //vec2 pos = vec2(.5) - st;
    
        float r = length( abs(pos) - .2);
        float a = atan2(pos.y,pos.x);
    
        float b = sin( a / 2.);
        float m = abs(cos(a*5.))*.12 + .2;
        float f = abs(sin(a*(1.)) * sin(a* (2. * shaderIntensity) + t))* 1.0 - sinc(pos.x / .1,2. ) + 0.2 - .5;
        float g = smoothstep(-.1,1., tan(a*f))* 1.796 + 1. ;
    
        
        color = float3( 1.000 - smoothstep(f * g + m / f  ,(f / g + m / b ) +- 0.28 , r / float4(f)) );
         color = mix(color, influenced_color, float3(g,b, sin(t)));

    texture.write(float4(color, 1.0), currentPixelPos);
}




kernel void january03(
                             texture2d<float,access::write> texture [[texture(0)]],
                             uint2 currentPixelPos [[thread_position_in_grid]],
                             device const float &shaderScale [[buffer(0)]], device const float &time [[buffer(1)]], device const float3 &color_in [[buffer(2)]], device const float &shaderIntensity [[buffer(3)]]
                             ) {
        

    
    float3 influenced_color = color_in;

    float t = time * 0.1;

        int width = texture.get_width();
        int height = texture.get_height();
            
        // set its resolution
        float2 res = float2(width, height);
        float2 uv = float2(currentPixelPos.x,height - currentPixelPos.y) / res;
        float2 st = uv;
        float3 color = float3(0.0);
    
        //vec2 pos = vec2(.1) * st;
        float2 pos = float2(.5) / shaderScale - st / shaderScale;
    
        float r = length( abs(pos) + 0.320);
        float a = atan2(pos.y,pos.x);
    
        float b = sin( a / 1.);
        float m = abs(cos(a*5.))*.12 + .2;
        float f = abs(sin(a*(1.)) * sin(a* (1.6 * shaderIntensity) + t))* 1.0 + sinc(pos.x / .1,2. ) + 0.2 - .5;
        float g = smoothstep(-.1,1., tan(a*f))* 1.796 + 1. ;
    
        
        color = float3( 1.000 - smoothstep(f * g + m / f  ,(f / g + m / b ) +- 0.28 , r / float3(f)) );
         color = mix(color, influenced_color, expSustainedImpulse(g,m, sin(t)));
    
    
    
    
    texture.write(float4(color, 1.0), currentPixelPos);
}




kernel void january04(
                             texture2d<float,access::write> texture [[texture(0)]],
                             uint2 currentPixelPos [[thread_position_in_grid]],
                             device const float &shaderScale [[buffer(0)]], device const float &time [[buffer(1)]], device const float3 &color_in [[buffer(2)]], device const float &shaderIntensity [[buffer(3)]]
                             ) {
        

    
    float t = time * 0.08;

        int width = texture.get_width();
        int height = texture.get_height();
            
        // set its resolution
        float2 res = float2(width, height);
        float2 uv = float2(currentPixelPos.x,height - currentPixelPos.y) / res;
        float2 st = uv;
        float2 pos = st;
    
                   pos = pos *8.498 - 3.956;
                    pos = pos / float2(shaderScale);
                   float3 color = float3(0.425,0.347,0.750);

                   float3 influencing_color_A = float3(0.985,0.097,0.355);
                    float3 influencing_color_B = color_in;
                   float3 influenced_color = float3(0.039,0.985,0.853);

                   float3 rect2 = candyrect(pos * 1.680, float2(0.950,0.910), float2(0.1, 0.1));

                   float3 currentPosXVector = float3(pos.x ) ;





                   currentPosXVector.r =  smoothstep(0.520,1.088,pos.x * 1.056) ;

                   color =  float3(0.690,0.369,0.973) * rect2;

                     color = mix(color - abs(influencing_color_B + 0.812 + sin(t + 0.295)),
                                influenced_color + influencing_color_A,
                                color /influencing_color_A);



                   color = mix(color,float3(0.793 * shaderIntensity,1.673,sin(t*0.928)),candyplot(pos,currentPosXVector.r ));

    
    
    texture.write(float4(color, 1.0), currentPixelPos);
}



kernel void january05(
                             texture2d<float,access::write> texture [[texture(0)]],
                             uint2 currentPixelPos [[thread_position_in_grid]],
                             device const float &shaderScale [[buffer(0)]], device const float &time [[buffer(1)]], device const float3 &color_in [[buffer(2)]], device const float &shaderIntensity [[buffer(3)]]
                             ) {
        

    float3 influenced_color = color_in;

              float t = time * 0.1;

        int width = texture.get_width();
        int height = texture.get_height();
            
        // set its resolution
        float2 res = float2(width, height);
        float2 uv = float2(currentPixelPos.x,height - currentPixelPos.y) / res;
        float2 st = uv;

                  float3 color = float3(0.0);
              
                  //vec2 pos = vec2(.1) * st;
                  float2 pos = float2(.5) / shaderScale - st / shaderScale;
              
                  float r = length( abs(pos) - .2);
                  float a = atan2(pos.y,pos.x);
              
                  float b = sin( a / 2.);
                  float m = abs(cos(a*50000.))*.12 + .2;
                  float f = abs(sin(a*(1.)) * sin(a*(2. * shaderIntensity) + t))* 1.0 - sinc(pos.x / .1,2. ) + 0.2 - .5;
                  float g = smoothstep(-.1,1., tan(a*f))* 1.9 + 10. ;
              
                  
                  color = float3( 1.000 - smoothstep(f * g + m + f  ,(f / g + m / b ) +- 0.28 , r / float3(f)) );
                   color = mix(color, influenced_color, float3(g,b, sin(t)));
    

    
    
    texture.write(float4(color, 1.0), currentPixelPos);
}
