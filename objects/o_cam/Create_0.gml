y+= 350;
x_analogue_b = 150;
y_analogue_b = 450;
x_analogue = 150;
y_analogue = 450;
x_analogue_r = 150;
y_analogue_r = 450;
r_analogue = 32;

button_pressed = false;
button_down_left = false;
button_down_right = false;
button_down_up = false;
button_down_down = false;

button_analogue = false;
d_analogue = -1;

///////////////////////////////////
x_action1 = 800;
y_action1 = 450;
r_actions = 32;
button_action1 = false;
d_action1 = -1;

x_action2 = 900;
y_action2 = 400;
button_action2 = false;
d_action2 = -1;

///////////PERSPECTIVE CAMERA
fov_y = 35;
z_target = 16;
zt_p = 16;

// === ÉCLAIRAGE JOUR/NUIT ===
// day_hour : 0-24  (peut être modifié dynamiquement ou via UI)
day_hour = 14.0;   // 14h par défaut (après-midi ensoleillé)

// Calcul de la lumière depuis l'heure (appelé à chaque changement)
day_update_light = function() {
    var _hour    = day_hour;
    // Angle solaire : 6h = lever (est), 12h = zénith, 18h = coucher (ouest), nuit = lune
    var _sun_ang = (_hour - 6.0) / 12.0 * 180.0;  // 0°=lever 90°=midi 180°=coucher
    var _is_day  = (_hour >= 6.0 && _hour <= 20.0);
    var _t_day   = clamp((_hour - 6.0) / 14.0, 0, 1);  // 0=lever 1=coucher

    if (_is_day) {
        // Direction soleil : tourne de est→zénith→ouest, incliné depuis sud
        var _elev = sin(degtorad(_sun_ang));     // hauteur 0→1→0
        var _azm  = cos(degtorad(_sun_ang));     // horizontal -1→0→1
        lit_dir   = [_azm * 0.5, 0.6, _elev * 0.8];
        // Couleur : orange lever/coucher, blanc midi
        var _mid  = 1.0 - abs(_t_day - 0.5) * 2.0;  // 1 au milieu
        lit_color = [lerp(1.0, 0.92, _mid), lerp(0.55, 0.88, _mid), lerp(0.25, 0.78, _mid)];
        lit_amb   = lerp(0.12, 0.36, _mid);
        lit_rim   = lerp(0.30, 0.55, _mid);
    } else {
        // Nuit : lumière douce bleue (lune)
        lit_dir   = [0.0, 0.5, 0.8];
        lit_color = [0.25, 0.30, 0.55];
        lit_amb   = 0.08;
        lit_rim   = 0.15;
    }
};
day_update_light();  // appel initial
// Matrices de projection (initialisées dans Draw_0 après camera_apply)
cam_view_mat = matrix_get(matrix_view);
cam_proj_mat = matrix_get(matrix_projection);
cam_surf_w   = 1280;
cam_surf_h   = 720;

// Uniformes shader directionnels
u_ldir  = shader_get_uniform(Shader1, "u_lightDir");
u_lcol  = shader_get_uniform(Shader1, "u_lightColor");
u_lamb  = shader_get_uniform(Shader1, "u_ambient");
u_lrim  = shader_get_uniform(Shader1, "u_rimStrength");
// Point lights fixes de salle
u_pl0    = shader_get_uniform(Shader1, "u_pl0");
u_pl1    = shader_get_uniform(Shader1, "u_pl1");
u_plcol  = shader_get_uniform(Shader1, "u_plcol");
u_plrad  = shader_get_uniform(Shader1, "u_plrad");
u_sprpos      = shader_get_uniform(Shader1, "u_sprpos");
u_flat_normal = shader_get_uniform(Shader1, "u_flat_normal");
// Floor lighting
u_fldir = shader_get_uniform(shd_floor, "u_lightDir");
u_flcol = shader_get_uniform(shd_floor, "u_lightColor");
u_flamb = shader_get_uniform(shd_floor, "u_ambient");



