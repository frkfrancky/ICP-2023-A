// Fragment Shader — Bloom multi-pass (Kawase-style)
varying vec2 v_vTexcoord;

uniform vec2  u_texelSize;
uniform float u_threshold;
uniform float u_intensity;

void main() {
    vec2 uv = v_vTexcoord;
    vec2 t  = u_texelSize;

    // Kawase tap : 4 coins à distance (0.5 + offset) * texelSize
    vec4 c  = texture2D(gm_BaseTexture, uv);
    vec4 c1 = texture2D(gm_BaseTexture, uv + vec2( t.x,  t.y));
    vec4 c2 = texture2D(gm_BaseTexture, uv + vec2(-t.x,  t.y));
    vec4 c3 = texture2D(gm_BaseTexture, uv + vec2( t.x, -t.y));
    vec4 c4 = texture2D(gm_BaseTexture, uv + vec2(-t.x, -t.y));

    // Moyenne pondérée (centre plus fort)
    vec4 col = c * 0.36 + (c1 + c2 + c3 + c4) * 0.16;

    // Extraction zones lumineuses
    float lum = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));
    float bright = smoothstep(u_threshold, u_threshold + 0.25, lum);
    col *= bright * u_intensity;

    // Teinte solaire chaude sur le glow
    col.r *= 1.12;
    col.g *= 1.02;
    col.b *= 0.84;

    gl_FragColor = clamp(col, 0.0, 3.0);
}
