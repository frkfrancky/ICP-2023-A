// Vertex Shader — shadow map depth pass (geometrique, sans convention matricielle)
attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

uniform vec3  u_litPos;    // position de la lumiere dans le monde
uniform vec3  u_litRight;  // vecteur droit (normalise)
uniform vec3  u_litUp;     // vecteur haut (normalise)
uniform vec3  u_litFwd;    // vecteur avant (litPos → scene, normalise)
uniform float u_litHW;     // demi-largeur frustum ortho
uniform float u_litHH;     // demi-hauteur frustum ortho
uniform float u_litFar;    // distance max

varying float v_vDepth;    // profondeur [0,1]

void main() {
    vec4 worldPos = gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1.0);
    vec3 d = worldPos.xyz - u_litPos;

    float px = dot(d, u_litRight) / u_litHW;   // [-1,1]
    float py = dot(d, u_litUp)    / u_litHH;   // [-1,1]
    float pz = dot(d, u_litFwd)   / u_litFar;  // [0,1]

    // gl_Position en clip space manuel (GMS2 flip Y pour surface -> on annule avec -py)
    gl_Position = vec4(px, -py, pz, 1.0);
    v_vDepth    = clamp(pz, 0.0, 1.0);
}
