// Fragment Shader - eclairage sol + shadow mapping
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vWorldPos;
varying vec4 v_vShadowCoord;

uniform vec3  u_lightDir;
uniform vec3  u_lightColor;
uniform float u_ambient;

uniform vec3  u_pl0;    uniform vec3  u_pl0col;  uniform float u_pl0rad;
uniform vec3  u_pl1;    uniform vec3  u_pl1col;  uniform float u_pl1rad;
uniform vec3  u_pl2;    uniform vec3  u_pl2col;  uniform float u_pl2rad;
uniform vec3  u_pl3;    uniform vec3  u_pl3col;  uniform float u_pl3rad;

uniform sampler2D u_shadowMap;
uniform float     u_shadowEnable;
uniform float     u_shadowDark;   // noirceur ombre [0..1]
uniform float     u_shadowBias;   // biais precision

float pointAtten(vec3 plPos, float plRad, vec3 fragPos) {
    float r = max(plRad, 1.0);
    float d = length(plPos - fragPos);
    float a = max(0.0, 1.0 - d / r);
    return a * a;
}

float calcShadow(vec4 shadowCoord) {
    if (u_shadowEnable < 0.5) return 1.0;
    vec2 uv = shadowCoord.xy * 0.5 + 0.5;
    float currentDepth = shadowCoord.z;
    if (uv.x < 0.001 || uv.x > 0.999 || uv.y < 0.001 || uv.y > 0.999) return 1.0;
    if (currentDepth < 0.0 || currentDepth > 1.0) return 1.0;
    float bias = u_shadowBias; // sol horizontal : biais reglable
    // PCF 3x3
    float inShadow = 0.0;
    float ts = 1.0 / 2048.0;
    inShadow += (currentDepth - bias > texture2D(u_shadowMap, uv + vec2(-ts,-ts)).r) ? 1.0 : 0.0;
    inShadow += (currentDepth - bias > texture2D(u_shadowMap, uv + vec2(0.0,-ts)).r) ? 1.0 : 0.0;
    inShadow += (currentDepth - bias > texture2D(u_shadowMap, uv + vec2( ts,-ts)).r) ? 1.0 : 0.0;
    inShadow += (currentDepth - bias > texture2D(u_shadowMap, uv + vec2(-ts, 0.0)).r) ? 1.0 : 0.0;
    inShadow += (currentDepth - bias > texture2D(u_shadowMap, uv + vec2(0.0, 0.0)).r) ? 1.0 : 0.0;
    inShadow += (currentDepth - bias > texture2D(u_shadowMap, uv + vec2( ts, 0.0)).r) ? 1.0 : 0.0;
    inShadow += (currentDepth - bias > texture2D(u_shadowMap, uv + vec2(-ts,  ts)).r) ? 1.0 : 0.0;
    inShadow += (currentDepth - bias > texture2D(u_shadowMap, uv + vec2(0.0,  ts)).r) ? 1.0 : 0.0;
    inShadow += (currentDepth - bias > texture2D(u_shadowMap, uv + vec2( ts,  ts)).r) ? 1.0 : 0.0;
    return mix(1.0, u_shadowDark, inShadow / 9.0);
}

void main() {
    vec4 tex = texture2D(gm_BaseTexture, v_vTexcoord);

    vec3 N = vec3(0.0, 0.0, 1.0);
    vec3 L = normalize(u_lightDir);
    vec3 Lf = normalize(vec3(L.x, L.z, L.y));
    float diff = max(dot(N, Lf), 0.0) * 0.35;

    vec3 pointLight = u_pl0col * pointAtten(u_pl0, u_pl0rad, v_vWorldPos)
                    + u_pl1col * pointAtten(u_pl1, u_pl1rad, v_vWorldPos)
                    + u_pl2col * pointAtten(u_pl2, u_pl2rad, v_vWorldPos)
                    + u_pl3col * pointAtten(u_pl3, u_pl3rad, v_vWorldPos);

    float shadowFactor = calcShadow(v_vShadowCoord);

    vec3 light = vec3((u_ambient + diff) * shadowFactor) + pointLight;
    light = clamp(light, 0.0, 1.5);

    gl_FragColor = vec4(tex.rgb * v_vColour.rgb * light, tex.a * v_vColour.a);
}
