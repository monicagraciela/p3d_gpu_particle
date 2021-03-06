//GLSL
#version 140
//#pragma include "inc_config.glsl"
//The line below is more or less the same as the one above,
//just using a custom parser to avoid re-writing the include file to hd
//Don't remove it!!!!
#define import 1

uniform mat4 p3d_ModelViewProjectionMatrix;
uniform mat4 p3d_ModelViewMatrixInverse;
uniform vec2 screen_size;
uniform vec3 camera_pos;
uniform sampler2D pos_tex;
uniform sampler2D size_tex;
uniform sampler2D offset_tex;
uniform sampler2D props_tex;

uniform float index_offset;
uniform vec4 status[WFX_NUM_EMITTERS];
in vec4 p3d_Vertex;

flat out vec2 center;
flat out float point_size;
flat out float life;
out vec4 uv_offset;

void main()
    {
    float id=float(gl_VertexID)+index_offset;
    float tex_size=textureSize(pos_tex, 0).x;

    vec2 pos_uv=vec2(mod(id, tex_size)/tex_size, 1.0-ceil(id/tex_size)/tex_size);
    pos_uv+=vec2(0.5/tex_size,0.5/tex_size);//read from the center of a texel
    uv_offset=textureLod(offset_tex, pos_uv, 0);
    vec4 offset=textureLod(pos_tex, pos_uv, 0);
    vec4 props=textureLod(props_tex, pos_uv, 0);
    life=clamp(offset.w/props.y, 0.0, 0.999);
    //life=offset.w/props.y;
    vec4 size_curve=textureLod(size_tex, pos_uv, 0);
    vec4 vert = p3d_Vertex;
    vert.xyz+=offset.xyz;
    gl_Position = p3d_ModelViewProjectionMatrix * vert;
    float dist =distance(vert.xyz,camera_pos);
    point_size = screen_size.y/ dist;

    point_size*= (sin(life+size_curve.x)*3.141592653589793*size_curve.y)*size_curve.z + size_curve.w;

    if (point_size<1.0)
        point_size=0.0;
    center = (gl_Position.xy / gl_Position.w * 0.5 + 0.5);

    if (offset.w<0.0)
        point_size = 0.0;

    int emmiter_id=int(props.z);
    //if (status[emmiter_id].w == 0.0)
    //    point_size = 0.0;

    gl_PointSize = point_size;
    }
