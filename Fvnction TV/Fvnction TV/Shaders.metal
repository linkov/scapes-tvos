#include <metal_stdlib>

using namespace metal;

#define PI 3.14159265359
#define TWO_PI 6.28318530718
#define r(a) float2x2(cos(a + .78*float4(0,6,2,0)))


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
                      texture2d<float,access::sample> textureInput [[texture(1)]],
                             uint2 currentPixelPos [[thread_position_in_grid]],
                             device const float &shaderScale [[buffer(0)]], device const float &time [[buffer(1)]], device const float3 &color_in [[buffer(2)]], device const float &shaderIntensity [[buffer(3)]], device const float4 &gamepad_in [[buffer(4)]]
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
                      texture2d<float,access::sample> textureInput [[texture(1)]],
                             uint2 currentPixelPos [[thread_position_in_grid]],
                             device const float &shaderScale [[buffer(0)]], device const float &time [[buffer(1)]], device const float3 &color_in [[buffer(2)]], device const float &shaderIntensity [[buffer(3)]], device const float4 &gamepad_in [[buffer(4)]]
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






kernel void january06(
                             texture2d<float,access::write> texture [[texture(0)]],
                             texture2d<float,access::sample> textureInput [[texture(1)]],
                             uint2 currentPixelPos [[thread_position_in_grid]],
                             device const float &shaderScale [[buffer(0)]],
                             device const float &time [[buffer(1)]],
                             device const float3 &color_in [[buffer(2)]],
                             device const float &shaderIntensity [[buffer(3)]],
                            device const float4 &gamepad_in [[buffer(4)]]
                             ) {
        

    

        float t = time * 5.;

        int width = texture.get_width();
        int height = texture.get_height();
            
        // set its resolution
        float2 res = float2(width, height);
      
    
   
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     min_filter::linear,
                                     mag_filter::linear,
                                     mip_filter::linear );
    
    
    
    //////
    
    
    
    float4 c = float4(0.0,0.0,0.0, 1.0);
    float2 u = float2( float(currentPixelPos.x), float(currentPixelPos.y) ) ;
    float3 iResolution = float3(res, 1.0);
   
    
    c.xyz = iResolution;
    u = (u+u-c.xy)/ c.y * shaderScale;
    
    float4 n = float4(u, sqrt(max(0., 1.-dot(u,u))),1.0);
    
    float4 m0 = cos(0.8 + .78 * float4(0,6,2,0));
    float4 m1 = cos(-0.6 + .78 * float4(0,6,2,0));
    float4 m2 = cos(n.z*4.+t*.3 + .78 * float4(0,6,2,0));
    

    n.xy = float2(m0[0] * n.x + m0[1] * n.y, m0[2] * n.x + m0[3] * n.y);
    n.xz = float2(m1[0] * n.x + m1[1] * n.z, m1[2] * n.x + m1[3] * n.z);
    n.xy = float2(m2[0] * n.x + m2[1] * n.y, m2[2] * n.x + m2[3] * n.y);


    c =  (n*1.6+.9) * max(.4,n.z ) * textureInput.sample(textureSampler,n.xz*.1 * shaderIntensity).r;
   
    if (color_in.x == color_in.y == color_in.z == 0.) {
        
    } else {
         c += float4(color_in,c.z);
    }
    c.r *= candysinc(0.6, t * 0.3);
    
    texture.write(c, currentPixelPos);

}



#define FIELD 10.0
#define HEIGHT 0.7
#define ITERATION 2.0
#define TONE float4(.2,.4,.8,0)
#define SPEED 0.5
float eq(float2 p,float t){
    float x = sin( p.y-t +cos(t+p.x*.8) ) * cos(p.x-t);
    x *= acos(x);
    return - x * abs(x-.05) * p.x/p.y*4.9;
}

kernel void january07(
                             texture2d<float,access::write> texture [[texture(0)]],
                             texture2d<float,access::sample> textureInput [[texture(1)]],
                             uint2 currentPixelPos [[thread_position_in_grid]],
                             device const float &shaderScale [[buffer(0)]],
                             device const float &time [[buffer(1)]],
                             device const float3 &color_in [[buffer(2)]],
                             device const float &shaderIntensity [[buffer(3)]],
                             device const float4 &gamepad_in [[buffer(4)]]
                             ) {
        

    
     float4 influenced_color = float4(color_in, 0.2);

        float t = time * 4.;

        int width = texture.get_width();
        int height = texture.get_height();
            
        // set its resolution
        float2 res = float2(width, height);
        float2 uv = float2(width - currentPixelPos.x,height - currentPixelPos.y) / res * shaderScale;
        float2 st = uv;
    
    float intesity = 1. - shaderIntensity;
    
   
       float4 X = influenced_color;
    float2  p = FIELD * uv;
    float tt = t*SPEED,
          hs = FIELD*(HEIGHT+cos(t)*1.9),
          x = eq(p,tt),
          y = p.y-x*0.1;
    
    for(float i=0.; i<ITERATION; ++i) {
                p.x *= 1.5,
        X = x + float4(0, eq(p,t+i+1.), eq(p,tt+i+2.) ,0),
        x = X.z += X.y,
        influenced_color += (TONE - intesity) / abs(y-X-hs);
        texture.write(influenced_color, currentPixelPos);
    }
    
}
float circle(float2 _st, float _radius, float shaderIntensity, float shaderScale){
    float2 dist = _st - float2(0.5 + (1. - shaderIntensity) * 0.02);
    return 1.-smoothstep(_radius-(_radius*0.01),
                         _radius+(_radius*0.01),
                         dot(dist,dist)*(3.0+shaderScale));
}


kernel void january08(
                             texture2d<float,access::write> texture [[texture(0)]],
                             texture2d<float,access::sample> textureInput [[texture(1)]],
                             uint2 currentPixelPos [[thread_position_in_grid]],
                             device const float &shaderScale [[buffer(0)]],
                             device const float &time [[buffer(1)]],
                             device const float3 &color_in [[buffer(2)]],
                             device const float &shaderIntensity [[buffer(3)]], device const float4 &gamepad_in [[buffer(4)]]
                             ) {
        
    
    float SI = shaderScale;
    float SS = shaderIntensity;

    
    float4 influenced_color = float4(0.9,0.,0.,0.);
    if ((color_in.x + color_in.y + color_in.z)  != 0.0) {
             influenced_color = float4(color_in, 0.2);
         }

    

        float t = time * 4.;

        int width = texture.get_width();
        int height = texture.get_height();
            
        // set its resolution
        float2 res = float2(width, height);
        float2 uv = float2(width - currentPixelPos.x,height - currentPixelPos.y) / res;

    
        float2 st = ( float2( float(currentPixelPos.x),  float(currentPixelPos.y))  / (1.1 + SI) - 0.1 * res.xy) / res.y+0.35;
       
    
        float pct = 1.3-st.y*1.2;
        
       for(int i=0; i<40 + shaderIntensity;i++){
           //change i to float so I can multiply by it
           float i_float = float(i);
           pct += circle(st+(0.6*sin(t/3.-i_float*st.yx)),0.01, SI, SS)*st.y*0.8;
           
       }
    
       
       pct=pct-1.;

       // Output to screen, adjust colour

    
       influenced_color = float4(pct+.1,pct+.1,pct,1.0)*influenced_color+float4(0.,0.0,0.3,0.);
        texture.write(influenced_color, currentPixelPos);
    
}


float4 permute(float4 x){return fmod(((x*14.0)+1.0)*x, 89.0);}
float4 taylorInvSqrt(float4 r){return 1.79284291400159 - 0.85373472095314 * r;}

float4 snoise(float3 v){
  const float2  C = float2(1.0/6.0, 1.0/3.0) ;
  const float4  D = float4(0.0, 0.5, 1.0, 2.0);

// First corner
  float3 i  = floor(v + dot(v, C.yyy) );
  float3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  float3 g = step(x0.yzx, x0.xyz);
  float3 l = 1.0 - g;
  float3 i1 = min( g.xyz, l.zxy );
  float3 i2 = max( g.xyz, l.zxy );

  //  x0 = x0 - 0. + 0.0 * C
  float3 x1 = x0 - i1 + 1.0 * C.xxx;
  float3 x2 = x0 - i2 + 2.0 * C.xxx;
  float3 x3 = x0 - 1. + 3.0 * C.xxx;

// Permutations
  i = fmod(i, 89.0 );
  float4 p = permute( permute( permute(
             i.z + float4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + float4(0.0, i1.y, i2.y, 1.0 ))
           + i.x + float4(0.0, i1.x, i2.x, 1.0 ));

// Gradients
// ( N*N points uniformly over a square, mapped onto an octahedron.)
  float n_ = 1.0/7.0; // N=7
  float3  ns = n_ * D.wyz - D.xzx;

  float4 j = p - 9.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)

  float4 x_ = floor(j * ns.z);
  float4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  float4 x = x_ *ns.x + ns.yyyy;
  float4 y = y_ *ns.x + ns.yyyy;
  float4 h = 1.0 - abs(x) - abs(y);

  float4 b0 = float4( x.xy, y.xy );
  float4 b1 = float4( x.zw, y.zw );

  float4 s0 = floor(b0)*2.0 + 1.0;
  float4 s1 = floor(b1)*2.0 + 1.0;
  float4 sh = -step(h, float4(0.0));

  float4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  float4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  float3 p0 = float3(a0.xy,h.x);
  float3 p1 = float3(a0.zw,h.y);
  float3 p2 = float3(a1.xy,h.z);
  float3 p3 = float3(a1.zw,h.w);

//Normalise gradients
  float4 norm = taylorInvSqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

    
// Mix final noise value
float4 m = max(0.6 - float4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    float4 m2 = m * m;
    float4 m4 = m2 * m2;

    float4 pdotx = float4(dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3));

    float4 temp = m2 * m * pdotx;
    float3 grad = -8.0 * (temp.x * x0 + temp.y * x1 + temp.z * x2 + temp.w * x3);
    grad += m4.x * p0 + m4.y * p1 + m4.z * p2 + m4.w * p3;
 
    return 42.0 * float4(grad, dot(m4, pdotx));
}

float3x3 fromEuler(float3 ang) {
    float2 a1 = float2(sin(ang.x), cos(ang.x));
    float2 a2 = float2(sin(ang.y), cos(ang.y));
    float2 a3 = float2(sin(ang.z), cos(ang.z));
    return float3x3(
        float3(a1.y * a3.y + a1.x * a2.x * a3.x, a1.y * a2.x * a3.x + a3.y * a1.x, -a2.y * a3.x),
        float3(-a2.y * a1.x, a1.y * a2.y, a2.x),
        float3(a3.y * a1.x * a2.x + a1.y * a3.x, a1.x * a3.x - a1.y * a3.y * a2.x, a2.y * a3.y)
    );
}









float2 hash( float2 p )
{
    p = float2( dot(p,float2(127.1,311.7)),
             dot(p,float2(269.5,183.3)) );
    return -1.0 + 1.0*fract(sin(p)*43758.5453123);
}

float noise66(float2 p )
{
    const float K1 = 0.366025404;
    const float K2 = 0.211324865;
    
    float2 i = floor( p + (p.x+p.y)*K1 );
    
    float2 a = p - i + (i.x+i.y)*K2;
    float2 o = (a.x>a.y) ? float2(1.0,0.0) : float2(0.0,1.0);
    float2 b = a - o + K2;
    float2 c = a - 1.0 + 2.0*K2;
    
    float3 h = max( 0.5-float3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
    
    float3 n = h*h*h*h*float3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
    
    return dot( n, float3(70.0) );
}



float fbm4(float2 p )
{
    const float2x2 m = float2x2( 0.80,  0.60, -0.60,  0.80 );
    float f = 0.0;
    f += 0.5000*noise66( p ); p = m*p*2.02;
    f += 0.2500*noise66( p ); p = m*p*2.03;
    f += 0.1250*noise66( p ); p = m*p*2.01;
    f += 0.0625*noise66( p );
    return f;
}

float fbm6(float2 p )
{
    const float2x2 m = float2x2( 0.80,  0.60, -0.60,  0.80 );
    float f = 0.0;
    f += 0.5000*noise66( p ); p = m*p*2.02;
    f += 0.2500*noise66( p ); p = m*p*2.03;
    f += 0.1250*noise66( p ); p = m*p*2.01;
    f += 0.0625*noise66( p ); p = m*p*2.04;
    f += 0.031250*noise66( p ); p = m*p*2.01;
    f += 0.015625*noise66( p );
    return f;
}

float4x4 CreatePerspectiveMatrix(float fov, float aspect, float near, float far)
{
    float4x4 m = float4x4(0.0);
    float angle = (fov / 180.0) * PI;
    float f = 1. / tan( angle * 0.5 );
    m[0][0] = f / aspect;
    m[1][1] = f;
    m[2][2] = (far + near) / (near - far);
    m[2][3] = -1.;
    m[3][2] = (2. * far*near) / (near - far);
    return m;
}

float4x4 CamControl( float3 eye, float pitch)
{
    float cosPitch = cos(pitch);
    float sinPitch = sin(pitch);
    float3 xaxis = float3( 1, 0, 0. );
    float3 yaxis = float3( 0., cosPitch, sinPitch );
    float3 zaxis = float3( 0., -sinPitch, cosPitch );
    // Create a 4x4 view matrix from the right, up, forward and eye position vectors
    float4x4 viewMatrix = float4x4(
        float4(       xaxis.x,            yaxis.x,            zaxis.x,      0 ),
        float4(       xaxis.y,            yaxis.y,            zaxis.y,      0 ),
        float4(       xaxis.z,            yaxis.z,            zaxis.z,      0 ),
        float4( -dot( xaxis, eye ), -dot( yaxis, eye ), -dot( zaxis, eye ), 1 )
    );
    return viewMatrix;
}






kernel void january09(
                             texture2d<float,access::write> texture [[texture(0)]],
                             texture2d<float,access::sample> textureInput [[texture(1)]],
                             uint2 currentPixelPos [[thread_position_in_grid]],
                             device const float &shaderScale [[buffer(0)]],
                             device const float &time [[buffer(1)]],
                             device const float3 &color_in [[buffer(2)]],
                             device const float &shaderIntensity [[buffer(3)]],
                            device const float4 &gamepad_in [[buffer(4)]]
                             ) {




        float t = time * 4.;

        int width = texture.get_width();
        int height = texture.get_height();

        // set its resolution
        float2 res = float2(width, height);
    float2 uv = float2( (width  - currentPixelPos.x) / (shaderScale == 1.0 ? shaderScale : (shaderScale / 2.)),(height - currentPixelPos.y) / (shaderScale == 1.0 ? shaderScale : (shaderScale / 2.)) ) / res;
    

    
        float2 p = 2.*uv-1.;
        p.x *= res.x/res.y;
             
        float3 eye = float3(0., 0.25+0.25*cos(0.5*time), -1.);
        float4x4 projmat = CreatePerspectiveMatrix(50., res.x/res.y, 0.1, 10.);
        float4x4 viewmat = CamControl(eye, -5. * PI/180.);
        float4x4 vpmat = viewmat*projmat;
        
        float3 col = color_in;
        float3 acc = float3(0.);
        float d;
        
        float4 pos = float4(0.);
        float lh = - res.y;
        float off = 0.1*time;
        float h = 0.;
        float z = 0.1;
        float zi = 0.005;
        for (int i=0; i<3; ++i)
        {
            pos = float4(p.x, 0.5*fbm4(0.5*float2(eye.x+p.x, z+off)), eye.z+z, 1.);
            h = (vpmat*pos).y - p.y;
            if (h>lh)
            {
                d = abs(h);
                col = float3( d < 1.005 ? smoothstep(1.,0.,d*192. + (1. - shaderIntensity)):0. );
                col *= exp(-0.1*float(i));
                
                if ((color_in.x + color_in.y + color_in.z)  != 0.0) {
                    col *= color_in;
                }
                
                acc += col;
//                float3 rainbowcolor = float3(0.1 + t,0.1 - t,0.1);
//                acc += rainbowcolor;
                lh = h;
            }
            z += zi;
        }
        col = sqrt(clamp(acc, 0., 1.));
        // Background
        float3 bkg = float3(0.1,0.1,0.1);
        col += bkg;
      
        float2 r = -1.0 + 1.0*(uv);
        float vb = max(abs(r.x), abs(r.y));
        col *= (0.15 + 0.15*(1.0-exp(-(1.0-vb)*20.0)));
        float4 fragColor = float4(col,1.0);
    
    //

        texture.write(fragColor, currentPixelPos);

}


float2 rayIntersectNearestGridPlanes(float3 orig, float3 ray)
{
    orig = fract(orig);
    float zInv = 1.0 / ray.z;
    float dFront = (1.0 - orig.z) * zInv;
    float dBack = (2.0 - orig.z) * zInv;

    if (ray.z < 0.0)
    {
        dFront = (orig.z) * -zInv;
        dBack = (orig.z + 1.0) * -zInv;
    }
    
    return float2(dFront, dBack);
}

float4 moduloUvPlanes(float3 orig, float3 ray, float2 dist)
{
    return float4(fract(orig.xy + ray.xy * dist.x), fract(orig.xy + ray.xy * dist.y));
}

float2 shortestPathStepDist(float4 uvs)
{
    float2 stepDist = uvs.zw - uvs.xy;
    
    // Modulo range [-0.5, +0.5]
    stepDist = fract(stepDist + 0.5) - 0.5;
    return stepDist;
}

float calculateSteps(float orig, float dist)
{
    // Plane hit: xy = [0, 0.5] modulo range on each integer z
    if (orig < 0.5) return 0.0;
    
    // How many steps to hit (modulo) 0.0 or 1.0?
    float steps = (dist < 0.0) ?
        (orig - 0.5) / -dist :
        (1.0 - orig) / dist;
    
    return ceil(steps);
}

float3 intersectInfiniteGrid(float3 orig, float3 ray)
{
    float2 intersections = rayIntersectNearestGridPlanes(orig, ray);
    float4 uv = moduloUvPlanes(orig, ray, intersections);
    float2 dist = shortestPathStepDist(uv);
    float stepsX = calculateSteps(uv.x, dist.x);
    float stepsY = calculateSteps(uv.y, dist.y);

    float steps = min(stepsX, stepsY);
    uv.xy += steps * dist.xy;
    
    return float3(uv.xy, intersections.y + steps / abs(ray.z));
}

float2 rot2D(float2 p, float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    return p * float2x2(c,s,-s,c);
}


kernel void january10(
                             texture2d<float,access::write> texture [[texture(0)]],
                             texture2d<float,access::sample> textureInput [[texture(1)]],
                             uint2 currentPixelPos [[thread_position_in_grid]],
                             device const float &shaderScale [[buffer(0)]],
                             device const float &time [[buffer(1)]],
                             device const float3 &color_in [[buffer(2)]],
                             device const float &shaderIntensity [[buffer(3)]], device const float4 &gamepad_in [[buffer(4)]]
                             ) {
        

    

        float t = time * 5.;

        int width = texture.get_width();
        int height = texture.get_height();
            
        // set its resolution
        float2 res = float2(width, height);
      
    
   
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     min_filter::linear,
                                     mag_filter::linear,
                                     mip_filter::linear );
    
    
    
     float2 u = float2( float(currentPixelPos.x), float(currentPixelPos.y) ) ;
    
    float2 uv = ( u / res.xy ) * (2.0 + shaderScale ) - 1.0;
    uv.x *= res.x / res.y;
    
    
    float leftEye = 0.0;
    {
        float3 orig = float3(0.65, 0.75, 0.1 + t);
        float3 ray = normalize(float3(uv, 1.2));
    
        
//        ray.xz = rot2D(ray.xz, t * 0.15 );
//        ray.yz = rot2D(ray.yz, t * 0.1 );
        
        ray.xz = rot2D(ray.xz, gamepad_in.z > 0.0 ? gamepad_in.x/10.0 : time * 0.15 );
        ray.yz = rot2D(ray.yz, gamepad_in.z > 0.0 ? gamepad_in.y/10.0 : time * 0.1 );
    
        float3 uvDist = intersectInfiniteGrid(orig, ray);
        uvDist.xy *= 2.0 + (1. - shaderIntensity);
        
        float3 texC = textureInput.sample(textureSampler, uvDist.xy).rgb;
        texC.r += color_in.r;
        leftEye = dot( texC, float3(0.3, 0.59, 0.11));
    }
    
    float rightEye = 0.0;
    {
        float3 orig = float3(0.65 + 0.03, 0.75, 0.1 + t);
        float3 ray = normalize(float3(uv, 1.2));
    
//        ray.xz = rot2D(ray.xz, t * 0.15 );
//        ray.yz = rot2D(ray.yz, t * 0.1 );
        
        ray.xz = rot2D(ray.xz, gamepad_in.z > 0.0 ? gamepad_in.x/10.0 : time * 0.15 );
        ray.yz = rot2D(ray.yz, gamepad_in.z > 0.0 ? gamepad_in.y/10.0 : time * 0.1 );
        
        float3 uvDist = intersectInfiniteGrid(orig, ray);
        uvDist.xy *= 2.0;
    
        float3 texC = textureInput.sample(textureSampler, uvDist.xy).rgb;
         texC.b += color_in.b;
        rightEye = dot(texC, float3(0.3, 0.59, 0.11));
    }
    
//    float4 fragColor = float4(leftEye, leftEye, leftEye, 1.0);
    float4 fragColor = float4(leftEye, rightEye, rightEye, 1.0);
    texture.write(fragColor, currentPixelPos);
}
