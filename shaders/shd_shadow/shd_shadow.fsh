// Fragment Shader — shadow map : profondeur [0,1] directement dans canal R
varying float v_vDepth;

void main() {
    // pz est deja [0,1] (distance normalisee depuis la lumiere)
    gl_FragColor = vec4(v_vDepth, 0.0, 0.0, 1.0);
}
