// Fragment Shader - 3D Lighting + shadow mapping
#extension GL_OES_standard_derivatives : enable
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vWorldPos;
varying vec4 v_vShadowCoord;

uniform vec3  u_lightDir;
uniform vec3  u_lightColor;
uniform float u_ambient;
uniform float u_rimStrength;

uniform vec3  u_pl0;    uniform vec3  u_pl0col;  uniform float u_pl0rad;
uniform vec3  u_pl1;    uniform vec3  u_pl1col;  uniform float u_pl1rad;
uniform vec3  u_pl2;    uniform vec3  u_pl2col;  uniform float u_pl2rad;
uniform vec3  u_pl3;    uniform vec3  u_pl3col;  uniform float u_pl3rad;

// Sphères occludeuses pour les lumières ponctuelles (jusqu'à 8 objets-bloqueurs)
uniform vec3  u_occ0; uniform float u_occr0;
uniform vec3  u_occ1; uniform float u_occr1;
uniform vec3  u_occ2; uniform float u_occr2;
uniform vec3  u_occ3; uniform float u_occr3;
uniform vec3  u_occ4; uniform float u_occr4;
uniform vec3  u_occ5; uniform float u_occr5;
uniform vec3  u_occ6; uniform float u_occr6;
uniform vec3  u_occ7; uniform float u_occr7;

uniform vec3  u_sprpos;
uniform float u_flat_normal;

uniform sampler2D u_shadowMap;
uniform float     u_shadowEnable;
uniform float     u_shadowDark;   // noirceur ombre [0..1], 0=noir, 1=invisible
uniform float     u_shadowBias;   // biais precision [0.001..0.01]
uniform float     u_shadowRecv;   // 1=recoit ombre, 0=ne recoit pas (personnages)

float pointAtten(vec3 plPos, float plRad, vec3 fragPos) {
    float r = max(plRad, 1.0);
    float d = length(plPos - fragPos);
    float a = max(0.0, 1.0 - d / r);
    return a * a;
}

// Teste si le rayon fragPos→lightPos est bloque par une sphere occludeuse
// Renvoie 0.0 (plein ombre) a 1.0 (pleine lumiere) avec penombre douce
float plOcclude(vec3 fragPos, vec3 lightPos, vec3 occC, float occR) {
    if (occR < 0.5) return 1.0; // sphere inactive
    vec3 d  = lightPos - fragPos;
    float len = length(d);
    if (len < 0.001) return 1.0;
    vec3 dir = d / len;
    vec3 oc  = occC - fragPos;
    float t  = dot(oc, dir);
    if (t < 0.0 || t > len) return 1.0; // sphere derriere ou apres la lumiere
    float dist2 = dot(oc, oc) - t * t;
    float r2 = occR * occR;
    if (dist2 >= r2) return 1.0; // rayon ne touche pas la sphere
    // Penombre : pleine ombre au centre, 0 a l'interieur, doux a la bordure
    float penumbra = occR * 0.35; // zone de penombre = 35% du rayon
    float dist = sqrt(dist2);
    return smoothstep(0.0, penumbra, dist + penumbra - occR);
}

float plOccludeAll(vec3 fragPos, vec3 lightPos) {
    float v = 1.0;
    v *= plOcclude(fragPos, lightPos, u_occ0, u_occr0);
    v *= plOcclude(fragPos, lightPos, u_occ1, u_occr1);
    v *= plOcclude(fragPos, lightPos, u_occ2, u_occr2);
    v *= plOcclude(fragPos, lightPos, u_occ3, u_occr3);
    v *= plOcclude(fragPos, lightPos, u_occ4, u_occr4);
    v *= plOcclude(fragPos, lightPos, u_occ5, u_occr5);
    v *= plOcclude(fragPos, lightPos, u_occ6, u_occr6);
    v *= plOcclude(fragPos, lightPos, u_occ7, u_occr7);
    return v;
}

float calcShadow(vec4 shadowCoord, vec3 N) {
    if (u_shadowEnable < 0.5 || u_shadowRecv < 0.5) return 1.0;
    // Face deja dans l'ombre geometrique (dos a la lumiere) → toujours sombre, pas de biais
    float cosTheta = dot(N, normalize(u_lightDir));
    if (cosTheta <= 0.0) return u_shadowDark;
    // Biais adaptatif uniquement sur faces eclairees (evite l'acne sans effacer l'ombre)
    float bias = max(u_shadowBias * (1.0 - cosTheta), u_shadowBias * 0.3);
    vec2 uv = shadowCoord.xy * 0.5 + 0.5;
    float currentDepth = shadowCoord.z;
    if (uv.x < 0.001 || uv.x > 0.999 || uv.y < 0.001 || uv.y > 0.999) return 1.0;
    if (currentDepth < 0.0 || currentDepth > 1.0) return 1.0;
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
    if (tex.a < 0.02) discard;

    vec3 N;
    vec3 fragPos;
    if (u_flat_normal > 0.5) {
        N = vec3(0.0, 1.0, 0.0);
        fragPos = u_sprpos;
    } else {
        // Normales geometriques reelles par derivees partielles (flat shading 3D correct)
        vec3 dx = dFdx(v_vWorldPos);
        vec3 dy = dFdy(v_vWorldPos);
        N = normalize(cross(dx, dy));
        if (!gl_FrontFacing) N = -N;
        fragPos = v_vWorldPos;
    }

    vec3 L = normalize(u_lightDir);
    float diff = max(dot(N, L), 0.0);

    vec3 V = vec3(0.0, 1.0, 0.0);
    vec3 H = normalize(L + V);
    float spec = pow(max(dot(N, H), 0.0), 22.0) * 0.25;

    float rim = pow(1.0 - max(dot(N, V), 0.0), 3.0) * u_rimStrength;
    vec3 rimCol = vec3(rim * 0.50, rim * 0.42, rim * 0.60);

    vec3 pointLight = u_pl0col * pointAtten(u_pl0, u_pl0rad, fragPos) * plOccludeAll(fragPos, u_pl0)
                    + u_pl1col * pointAtten(u_pl1, u_pl1rad, fragPos) * plOccludeAll(fragPos, u_pl1)
                    + u_pl2col * pointAtten(u_pl2, u_pl2rad, fragPos) * plOccludeAll(fragPos, u_pl2)
                    + u_pl3col * pointAtten(u_pl3, u_pl3rad, fragPos) * plOccludeAll(fragPos, u_pl3);

    float shadowFactor = calcShadow(v_vShadowCoord, N);

    vec3 light = vec3(u_ambient) * shadowFactor + u_lightColor * (diff + spec) * shadowFactor + rimCol + pointLight;
    light = max(light, 0.0);

    gl_FragColor = vec4(tex.rgb * v_vColour.rgb * light, tex.a * v_vColour.a);
}
