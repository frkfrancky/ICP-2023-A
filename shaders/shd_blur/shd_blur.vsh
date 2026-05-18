// Vertex Shader — Bloom post-process (fullscreen quad)
attribute vec2 in_Position;
attribute vec2 in_TextureCoord;
attribute vec4 in_Colour;

varying vec2 v_vTexcoord;

void main() {
    gl_Position  = vec4(in_Position.x, in_Position.y, 0.0, 1.0);
    v_vTexcoord  = in_TextureCoord;
}
