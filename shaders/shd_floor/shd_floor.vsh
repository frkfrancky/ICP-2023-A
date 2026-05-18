// Vertex Shader — sol texturé + shadow mapping
attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vWorldPos;
varying vec4 v_vShadowCoord;

uniform vec3  u_litPos;
uniform vec3  u_litRight;
uniform vec3  u_litUp;
uniform vec3  u_litFwd;
uniform float u_litHW;
uniform float u_litHH;
uniform float u_litFar;

void main() {
    gl_Position   = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.0);
    vec4 worldPos = gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1.0);
    v_vWorldPos   = worldPos.xyz;
    v_vTexcoord   = in_TextureCoord;
    v_vColour     = in_Colour;

    // Projection geometrique dans le repere lumiere
    vec3 d = worldPos.xyz - u_litPos;
    float px = dot(d, u_litRight) / u_litHW;
    float py = dot(d, u_litUp)    / u_litHH;
    float pz = dot(d, u_litFwd)   / u_litFar;
    v_vShadowCoord = vec4(px, py, pz, 1.0);
}
