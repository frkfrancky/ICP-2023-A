var _sw = display_get_gui_width();
var _sh = display_get_gui_height();

// ═══════════════════════════════════════════════════════
// 0. SHADOW MAP PASS (rendu profondeur depuis le soleil)
// ═══════════════════════════════════════════════════════
if (le_shadow_enable) {
    if (!surface_exists(le_shadow_surf))
        le_shadow_surf = surface_create(le_shadow_sz, le_shadow_sz);

    // ── Calcul de la base orthonormee de la lumiere (approche geometrique pure) ──
    var _ld = le_lit_dir;  // direction scene→soleil, normalisee
    var _sd  = 1500;       // distance lumiere depuis le centre de scene
    var _cx  = 0; var _cy = 0; var _cz = 150; // centre de la scene (mi-hauteur)
    // Position de la source lumineuse centree sur la scene
    var _lpx = _cx + _ld[0]*_sd;
    var _lpy = _cy + _ld[1]*_sd;
    var _lpz = _cz + _ld[2]*_sd;

    // Vecteur avant lumiere : du soleil vers la scene (oppose a le_lit_dir)
    var _fx = -_ld[0]; var _fy = -_ld[1]; var _fz = -_ld[2];

    // Vecteur world-up : Z si lumiere est horizontale, X si lumiere est quasi-verticale
    var _wux = 0.0; var _wuy = 0.0; var _wuz = 1.0;
    if (abs(_ld[2]) > 0.85) { _wux = 1.0; _wuz = 0.0; }

    // right = cross(worldUp, fwd) pour systeme left-handed GMS2
    var _rx = _wuy*_fz - _wuz*_fy;
    var _ry = _wuz*_fx - _wux*_fz;
    var _rz = _wux*_fy - _wuy*_fx;
    var _rlen = sqrt(_rx*_rx + _ry*_ry + _rz*_rz);
    _rx /= _rlen; _ry /= _rlen; _rz /= _rlen;

    // up = cross(fwd, right)
    var _ux = _fy*_rz - _fz*_ry;
    var _uy = _fz*_rx - _fx*_rz;
    var _uz = _fx*_ry - _fy*_rx;

    // Dimensions de la zone couverte (far reduit = meilleure precision de profondeur)
    var _hw = 1200; var _hh = 800; var _far = 3000;

    // Stocker pour utilisation dans les shaders principaux
    le_lit_pos   = [_lpx, _lpy, _lpz];
    le_lit_right = [_rx,  _ry,  _rz];
    le_lit_up    = [_ux,  _uy,  _uz];
    le_lit_fwd   = [_fx,  _fy,  _fz];
    le_lit_hw    = _hw;
    le_lit_hh    = _hh;
    le_lit_far   = _far;

    // ── Passe depth : rendu depuis le soleil (terrain EXCLU) ──
    surface_set_target(le_shadow_surf);
    draw_clear(c_white);

    // z-test activé : le GPU garde automatiquement le fragment le plus proche de la lumiere
    // → ombre cube-sur-cube correcte sans triage manuel
    gpu_set_ztestenable(true);
    gpu_set_zwriteenable(true);
    gpu_set_cullmode(cull_noculling);

    shader_set(shd_shadow);
    shader_set_uniform_f_array(le_u_sh_litPos,   le_lit_pos);
    shader_set_uniform_f_array(le_u_sh_litRight, le_lit_right);
    shader_set_uniform_f_array(le_u_sh_litUp,    le_lit_up);
    shader_set_uniform_f_array(le_u_sh_litFwd,   le_lit_fwd);
    shader_set_uniform_f(le_u_sh_litHW,  le_lit_hw);
    shader_set_uniform_f(le_u_sh_litHH,  le_lit_hh);
    shader_set_uniform_f(le_u_sh_litFar, le_lit_far);

    // Rendu des mesh dans la shadow map
    for (var _si = 0; _si < array_length(le_objects); _si++) {
        var _so = le_objects[_si];
        if (_so.type != "mesh" || _so.vb < 0) continue;
        matrix_set(matrix_world, matrix_build(_so.x,_so.y,_so.z, _so.rx,_so.ry,_so.rz, _so.sx,_so.sy,_so.sz));
        vertex_submit(_so.vb, pr_trianglelist, -1);
    }

    // Ombre personnage : geometrie FK per-part (silhouette humaine)
    matrix_set(matrix_world, matrix_build_identity());
    var _sbx = le_lit_right[0]; var _sby = le_lit_right[1];
    var _sblen = max(sqrt(_sbx*_sbx + _sby*_sby), 0.001);
    _sbx /= _sblen; _sby /= _sblen;

    if (variable_global_exists("char_parts") && variable_global_exists("char_fk")) {
        var _fk_sh = global.char_fk("idle", le_anim_t);
        for (var _si2 = 0; _si2 < array_length(le_objects); _si2++) {
            var _so2 = le_objects[_si2];
            if (_so2.type != "char") continue;
            var _cx2 = _so2.x; var _cy2 = _so2.y; var _cz2 = _so2.z;
            var _sc2 = _so2.sx;
            var _dir2 = _so2.rz;
            var _prx2 = dsin(_dir2); var _pry2 = dcos(_dir2);
            var _fwdx2 = dcos(_dir2); var _fwdy2 = -dsin(_dir2);

            var _cvbsh = vertex_create_buffer();
            vertex_begin(_cvbsh, global.vFormat);
            for (var _pi = 0; _pi < 10; _pi++) {
                var _part_sh = global.char_parts[_pi];
                var _bone_sh = _fk_sh[_pi];
                var _hw_sh   = _part_sh.hw * _sc2;

                var _piv_by_sh = variable_struct_exists(_bone_sh,"piv_by") ? _bone_sh.piv_by : 0;
                var _pwx = _cx2 + _bone_sh.piv_bx*_sc2*_prx2 + _piv_by_sh*_sc2*_fwdx2;
                var _pwy = _cy2 + _bone_sh.piv_bx*_sc2*_pry2 + _piv_by_sh*_sc2*_fwdy2;
                var _pwz = _cz2 + _bone_sh.piv_bz * _sc2;

                var _end_by_sh = variable_struct_exists(_bone_sh,"end_by") ? _bone_sh.end_by : 0;
                var _ewx = _cx2 + _bone_sh.end_bx*_sc2*_prx2 + _end_by_sh*_sc2*_fwdx2;
                var _ewy = _cy2 + _bone_sh.end_bx*_sc2*_pry2 + _end_by_sh*_sc2*_fwdy2;
                var _ewz = _cz2 + _bone_sh.end_bz * _sc2;

                var _Ax = _pwx+_sbx*_hw_sh; var _Ay = _pwy+_sby*_hw_sh;
                var _Bx = _pwx-_sbx*_hw_sh; var _By = _pwy-_sby*_hw_sh;
                var _Cx = _ewx-_sbx*_hw_sh; var _Cy = _ewy-_sby*_hw_sh;
                var _Dx = _ewx+_sbx*_hw_sh; var _Dy = _ewy+_sby*_hw_sh;

                vertex_position_3d(_cvbsh,_Ax,_Ay,_pwz); vertex_texcoord(_cvbsh,0,0); vertex_color(_cvbsh,c_white,1);
                vertex_position_3d(_cvbsh,_Bx,_By,_pwz); vertex_texcoord(_cvbsh,1,0); vertex_color(_cvbsh,c_white,1);
                vertex_position_3d(_cvbsh,_Cx,_Cy,_ewz);  vertex_texcoord(_cvbsh,1,1); vertex_color(_cvbsh,c_white,1);
                vertex_position_3d(_cvbsh,_Ax,_Ay,_pwz); vertex_texcoord(_cvbsh,0,0); vertex_color(_cvbsh,c_white,1);
                vertex_position_3d(_cvbsh,_Cx,_Cy,_ewz);  vertex_texcoord(_cvbsh,1,1); vertex_color(_cvbsh,c_white,1);
                vertex_position_3d(_cvbsh,_Dx,_Dy,_ewz);  vertex_texcoord(_cvbsh,0,1); vertex_color(_cvbsh,c_white,1);
            }
            vertex_end(_cvbsh);
            vertex_submit(_cvbsh, pr_trianglelist, -1);
            vertex_delete_buffer(_cvbsh);
        }
    }

    matrix_set(matrix_world, matrix_build_identity());
    shader_reset();
    gpu_set_ztestenable(false);
    gpu_set_zwriteenable(false);
    surface_reset_target();
} else {
    if (surface_exists(le_shadow_surf)) { surface_free(le_shadow_surf); le_shadow_surf = -1; }
}

// ═══════════════════════════════════════════════════════
// 1. RENDU 3D DANS LA SURFACE
// ═══════════════════════════════════════════════════════
if (!surface_exists(le_surf))
    le_surf = surface_create(le_viewport_w, le_viewport_h);

surface_set_target(le_surf);

// Ciel dégradé selon heure
var _t_sky = clamp((le_day_hour - 5.5) / 15.0, 0, 1);
var _sky_top = make_color_rgb(
    lerp(10,  lerp(20, 80,  _t_sky),  min(_t_sky*2,1)),
    lerp(10,  lerp(30, 130, _t_sky),  min(_t_sky*2,1)),
    lerp(30,  lerp(80, 200, _t_sky),  min(_t_sky*2,1)));
var _sky_bot = make_color_rgb(
    lerp(20,  lerp(60, 160, _t_sky),  min(_t_sky*2,1)),
    lerp(20,  lerp(80, 190, _t_sky),  min(_t_sky*2,1)),
    lerp(40,  lerp(110,230, _t_sky),  min(_t_sky*2,1)));
draw_clear(_sky_top);
draw_primitive_begin(pr_trianglefan);
draw_vertex_color(0,le_viewport_h, _sky_bot,1);
draw_vertex_color(le_viewport_w,le_viewport_h, _sky_bot,1);
draw_vertex_color(le_viewport_w,0, _sky_top,1);
draw_vertex_color(0,0, _sky_top,1);
draw_primitive_end();

// Caméra
var _cr = degtorad(le_cam_angle);
var _cy2 = degtorad(le_cam_yaw);
var _ex = le_cam_cx + le_cam_dist * cos(_cr) * cos(_cy2);
var _ey = le_cam_cy + le_cam_dist * cos(_cr) * sin(_cy2);
var _ez = le_cam_cz + le_cam_dist * sin(_cr);
var _cam = camera_create();
camera_set_view_mat(_cam, matrix_build_lookat(_ex,_ey,_ez, le_cam_cx,le_cam_cy,le_cam_cz, 0,0,1));
camera_set_proj_mat(_cam, matrix_build_projection_perspective_fov(le_cam_fov, le_viewport_w/le_viewport_h, 1, 20000));
camera_apply(_cam);
camera_destroy(_cam);

// Matrices pour projection manuelle 3D→GUI (meme methode que o_p/Draw_64)
var _le_vmat = matrix_build_lookat(_ex,_ey,_ez, le_cam_cx,le_cam_cy,le_cam_cz, 0,0,1);
var _le_pmat = matrix_build_projection_perspective_fov(le_cam_fov, le_viewport_w/le_viewport_h, 1, 20000);

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_cullmode(cull_noculling);

// Shader lumiere — jusqu'a 4 lumieres ponctuelles independantes
// Par defaut : couleur nulle = pas de contribution
var _pls_pos = [[0,0,100000],[0,0,100000],[0,0,100000],[0,0,100000]];
var _pls_col = [[0,0,0],[0,0,0],[0,0,0],[0,0,0]];
var _pls_rad = [1.0, 1.0, 1.0, 1.0];
var _li = 0;
for (var _oi = 0; _oi < array_length(le_objects); _oi++) {
    var _oo = le_objects[_oi];
    if (_oo.type != "light") continue;
    var _inten  = variable_struct_exists(_oo,"intensity") ? _oo.intensity : 1.0;
    var _lr     = color_get_red(_oo.col)/255*_inten;
    var _lg     = color_get_green(_oo.col)/255*_inten;
    var _lb     = color_get_blue(_oo.col)/255*_inten;
    var _lrange = variable_struct_exists(_oo,"range") ? _oo.range : 500;
    _pls_pos[_li] = [_oo.x, _oo.y, _oo.z];
    _pls_col[_li] = [_lr, _lg, _lb];
    _pls_rad[_li] = _lrange;
    _li++; if (_li >= 4) break;
}
var _pl0=_pls_pos[0]; var _pl1=_pls_pos[1]; var _pl2=_pls_pos[2]; var _pl3=_pls_pos[3];
var _pl0col=_pls_col[0]; var _pl1col=_pls_col[1]; var _pl2col=_pls_col[2]; var _pl3col=_pls_col[3];
var _pl0rad=_pls_rad[0]; var _pl1rad=_pls_rad[1]; var _pl2rad=_pls_rad[2]; var _pl3rad=_pls_rad[3];

shader_set(Shader1);
shader_set_uniform_f_array(le_u_ldir,   le_lit_dir);
shader_set_uniform_f_array(le_u_lcol,   le_lit_color);
shader_set_uniform_f(le_u_lamb,         le_lit_amb);
shader_set_uniform_f(le_u_lrim,         le_lit_rim);
shader_set_uniform_f_array(le_u_pl0,    _pl0);    shader_set_uniform_f_array(le_u_pl0col, _pl0col); shader_set_uniform_f(le_u_pl0rad, _pl0rad);
shader_set_uniform_f_array(le_u_pl1,    _pl1);    shader_set_uniform_f_array(le_u_pl1col, _pl1col); shader_set_uniform_f(le_u_pl1rad, _pl1rad);
shader_set_uniform_f_array(le_u_pl2,    _pl2);    shader_set_uniform_f_array(le_u_pl2col, _pl2col); shader_set_uniform_f(le_u_pl2rad, _pl2rad);
shader_set_uniform_f_array(le_u_pl3,    _pl3);    shader_set_uniform_f_array(le_u_pl3col, _pl3col); shader_set_uniform_f(le_u_pl3rad, _pl3rad);
shader_set_uniform_f_array(le_u_sprpos, [0,0,0]);
shader_set_uniform_f(le_u_flat_normal,  0.0);
// Shadow uniforms — Shader1 (geometriques, sans matrice)
shader_set_uniform_f(le_u_shadow_en,   le_shadow_enable ? 1.0 : 0.0);
shader_set_uniform_f(le_u_shadow_dark, le_shadow_darkness);
shader_set_uniform_f(le_u_shadow_bias, le_shadow_bias);
shader_set_uniform_f(le_u_shadow_recv, 1.0); // mesh = recoit l'ombre
// Occluders : spheres englobantes des mesh pour bloquer les lumieres ponctuelles
var _nocc = 0;
for (var _oci = 0; _oci < array_length(le_objects) && _nocc < 8; _oci++) {
    var _oo2 = le_objects[_oci];
    if (_oo2.type != "mesh" || _oo2.vb < 0) continue;
    var _orad = max(_oo2.sx, max(_oo2.sy, _oo2.sz)) * 70.0; // rayon approx
    shader_set_uniform_f_array(le_u_occ[_nocc],  [_oo2.x, _oo2.y, _oo2.z]);
    shader_set_uniform_f(le_u_occr[_nocc], _orad);
    _nocc++;
}
// Desactiver les slots non utilises
for (var _oci2 = _nocc; _oci2 < 8; _oci2++) {
    shader_set_uniform_f_array(le_u_occ[_oci2],  [0,0,0]);
    shader_set_uniform_f(le_u_occr[_oci2], 0.0);
}
shader_set_uniform_f_array(le_u_litPos,   le_lit_pos);
shader_set_uniform_f_array(le_u_litRight, le_lit_right);
shader_set_uniform_f_array(le_u_litUp,    le_lit_up);
shader_set_uniform_f_array(le_u_litFwd,   le_lit_fwd);
shader_set_uniform_f(le_u_litHW,  le_lit_hw);
shader_set_uniform_f(le_u_litHH,  le_lit_hh);
shader_set_uniform_f(le_u_litFar, le_lit_far);
if (le_shadow_enable && surface_exists(le_shadow_surf))
    texture_set_stage(le_u_shadow_samp, surface_get_texture(le_shadow_surf));

// Dessiner objets mesh (Shader1)
for (var _oi = 0; _oi < array_length(le_objects); _oi++) {
    var _o = le_objects[_oi];
    if (_o.type != "mesh" || _o.vb < 0) continue;
    var _tex_sp2 = variable_struct_exists(_o,"tex_spr") ? _o.tex_spr : -1;
    var _r = (_tex_sp2 >= 0) ? 1.0 : color_get_red(_o.col)/255;
    var _g = (_tex_sp2 >= 0) ? 1.0 : color_get_green(_o.col)/255;
    var _b2= (_tex_sp2 >= 0) ? 1.0 : color_get_blue(_o.col)/255;
    shader_set_uniform_f_array(le_u_lcol, [le_lit_color[0]*_r, le_lit_color[1]*_g, le_lit_color[2]*_b2]);
    matrix_set(matrix_world, matrix_build(_o.x,_o.y,_o.z, _o.rx,_o.ry,_o.rz, _o.sx,_o.sy,_o.sz));
    // Texture OBJ si presente (les cubes n'ont pas tex_spr)
    var _tex_sp = variable_struct_exists(_o,"tex_spr") ? _o.tex_spr : -1;
    var _tex = (_tex_sp >= 0) ? sprite_get_texture(_tex_sp, 0) : -1;
    vertex_submit(_o.vb, pr_trianglelist, _tex);
    shader_set_uniform_f_array(le_u_lcol, le_lit_color);
}
matrix_set(matrix_world, matrix_build_identity());

// Terrain de match (shd_floor + texture su_ter1)
shader_reset();
for (var _oi = 0; _oi < array_length(le_objects); _oi++) {
    var _o = le_objects[_oi];
    if (_o.type != "terrain" || _o.vb < 0) continue;
    shader_set(shd_floor);
    shader_set_uniform_f_array(le_u_fldir,     le_lit_dir);
    shader_set_uniform_f_array(le_u_flcol,     le_lit_color);
    shader_set_uniform_f(le_u_flamb,           le_lit_amb);
    shader_set_uniform_f_array(le_u_fl_pl0, _pl0); shader_set_uniform_f_array(le_u_fl_pl0col, _pl0col); shader_set_uniform_f(le_u_fl_pl0rad, _pl0rad);
    shader_set_uniform_f_array(le_u_fl_pl1, _pl1); shader_set_uniform_f_array(le_u_fl_pl1col, _pl1col); shader_set_uniform_f(le_u_fl_pl1rad, _pl1rad);
    shader_set_uniform_f_array(le_u_fl_pl2, _pl2); shader_set_uniform_f_array(le_u_fl_pl2col, _pl2col); shader_set_uniform_f(le_u_fl_pl2rad, _pl2rad);
    shader_set_uniform_f_array(le_u_fl_pl3, _pl3); shader_set_uniform_f_array(le_u_fl_pl3col, _pl3col); shader_set_uniform_f(le_u_fl_pl3rad, _pl3rad);
    shader_set_uniform_f(le_u_fl_shadow_en,   le_shadow_enable ? 1.0 : 0.0);
    shader_set_uniform_f(le_u_fl_shadow_dark, le_shadow_darkness);
    shader_set_uniform_f(le_u_fl_shadow_bias, le_shadow_bias);
    shader_set_uniform_f_array(le_u_fl_litPos,   le_lit_pos);
    shader_set_uniform_f_array(le_u_fl_litRight, le_lit_right);
    shader_set_uniform_f_array(le_u_fl_litUp,    le_lit_up);
    shader_set_uniform_f_array(le_u_fl_litFwd,   le_lit_fwd);
    shader_set_uniform_f(le_u_fl_litHW,  le_lit_hw);
    shader_set_uniform_f(le_u_fl_litHH,  le_lit_hh);
    shader_set_uniform_f(le_u_fl_litFar, le_lit_far);
    if (le_shadow_enable && surface_exists(le_shadow_surf))
        texture_set_stage(le_u_fl_shadow_samp, surface_get_texture(le_shadow_surf));
    matrix_set(matrix_world, matrix_build(_o.x,_o.y,_o.z, _o.rx,_o.ry,_o.rz, _o.sx,_o.sy,_o.sz));
    vertex_submit(_o.vb, pr_trianglelist, sprite_get_texture(su_ter1, 0));
    matrix_set(matrix_world, matrix_build_identity());
    shader_reset();
}

// Personnages FK articulé (exactement comme o_p)
var _cr3 = degtorad(le_cam_angle);
var _cy4 = degtorad(le_cam_yaw);
var _cam_ex3 = le_cam_cx + le_cam_dist * cos(_cr3) * cos(_cy4);
var _cam_ey3 = le_cam_cy + le_cam_dist * cos(_cr3) * sin(_cy4);

if (variable_global_exists("char_parts")) {
    shader_set(Shader1);
    shader_set_uniform_f_array(le_u_ldir,   le_lit_dir);
    shader_set_uniform_f_array(le_u_lcol,   le_lit_color);
    shader_set_uniform_f(le_u_lamb,         le_lit_amb);
    shader_set_uniform_f(le_u_lrim,         le_lit_rim);
    shader_set_uniform_f_array(le_u_pl0, _pl0); shader_set_uniform_f_array(le_u_pl0col, _pl0col); shader_set_uniform_f(le_u_pl0rad, _pl0rad);
    shader_set_uniform_f_array(le_u_pl1, _pl1); shader_set_uniform_f_array(le_u_pl1col, _pl1col); shader_set_uniform_f(le_u_pl1rad, _pl1rad);
    shader_set_uniform_f_array(le_u_pl2, _pl2); shader_set_uniform_f_array(le_u_pl2col, _pl2col); shader_set_uniform_f(le_u_pl2rad, _pl2rad);
    shader_set_uniform_f_array(le_u_pl3, _pl3); shader_set_uniform_f_array(le_u_pl3col, _pl3col); shader_set_uniform_f(le_u_pl3rad, _pl3rad);
    shader_set_uniform_f(le_u_flat_normal,  1.0);
    shader_set_uniform_f(le_u_shadow_en,   le_shadow_enable ? 1.0 : 0.0);
    shader_set_uniform_f(le_u_shadow_dark, le_shadow_darkness);
    shader_set_uniform_f(le_u_shadow_bias, le_shadow_bias);
    shader_set_uniform_f(le_u_shadow_recv, 0.0); // personnage = ne recoit pas sa propre ombre
    shader_set_uniform_f_array(le_u_litPos,   le_lit_pos);
    shader_set_uniform_f_array(le_u_litRight, le_lit_right);
    shader_set_uniform_f_array(le_u_litUp,    le_lit_up);
    shader_set_uniform_f_array(le_u_litFwd,   le_lit_fwd);
    shader_set_uniform_f(le_u_litHW,  le_lit_hw);
    shader_set_uniform_f(le_u_litHH,  le_lit_hh);
    shader_set_uniform_f(le_u_litFar, le_lit_far);
    if (le_shadow_enable && surface_exists(le_shadow_surf))
        texture_set_stage(le_u_shadow_samp, surface_get_texture(le_shadow_surf));

    for (var _oi2 = 0; _oi2 < array_length(le_objects); _oi2++) {
        var _o = le_objects[_oi2];
        if (_o.type != "char") continue;
        var _ox = _o.x; var _oy = _o.y; var _oz = _o.z;
        var _sc = _o.sx;
        var _dir = _o.rz; // orientation (rz = rotation Z = cap)

        var _cam_dir3 = point_direction(_ox, _oy, _cam_ex3, _cam_ey3);
        var _rel_ang  = ((_cam_dir3 - _dir) mod 360 + 360) mod 360;
        var _frame    = (8 - (round(_rel_ang / 45) mod 8)) mod 8;

        var _brx3 = lengthdir_x(1, _cam_dir3 - 90);
        var _bry3 = lengthdir_y(1, _cam_dir3 - 90);

        var _prx = dsin(_dir); var _pry = dcos(_dir);
        var _cd  = max(point_distance(_ox, _oy, _cam_ex3, _cam_ey3), 1);
        var _cdx = (_cam_ex3 - _ox) / _cd;
        var _cdy = (_cam_ey3 - _oy) / _cd;
        var _right_dot_cam = _prx*_cdx + _pry*_cdy;
        var _fwd_x = dcos(_dir); var _fwd_y = -dsin(_dir);

        var _fk    = global.char_fk("idle", le_anim_t);
        var _order = global.char_layer_order[_frame];

        var _cvb = vertex_create_buffer();
        vertex_begin(_cvb, global.vFormat);

        for (var _pi = 0; _pi < 10; _pi++) {
            var _pid  = _order[_pi];
            var _part = global.char_parts[_pid];
            var _bone = _fk[_pid];
            var _hw   = _part.hw * _sc;

            var _piv_by_v = variable_struct_exists(_bone,"piv_by") ? _bone.piv_by : 0;
            var _piv_bias = _bone.piv_bx * _right_dot_cam * 0.8;
            var _piv_wx = _ox + _bone.piv_bx*_sc*_prx + _piv_by_v*_sc*_fwd_x + _cdx*_piv_bias*_sc;
            var _piv_wy = _oy + _bone.piv_bx*_sc*_pry + _piv_by_v*_sc*_fwd_y + _cdy*_piv_bias*_sc;
            var _piv_wz = _oz + _bone.piv_bz * _sc; // éditeur : Z positif vers le haut

            var _end_by_v = variable_struct_exists(_bone,"end_by") ? _bone.end_by : 0;
            var _end_bias = _bone.end_bx * _right_dot_cam * 0.8;
            var _end_wx = _ox + _bone.end_bx*_sc*_prx + _end_by_v*_sc*_fwd_x + _cdx*_end_bias*_sc;
            var _end_wy = _oy + _bone.end_bx*_sc*_pry + _end_by_v*_sc*_fwd_y + _cdy*_end_bias*_sc;
            var _end_wz = _oz + _bone.end_bz * _sc;

            var _Ax = _piv_wx+_brx3*_hw; var _Ay = _piv_wy+_bry3*_hw; var _Az = _piv_wz;
            var _Bx = _piv_wx-_brx3*_hw; var _By = _piv_wy-_bry3*_hw; var _Bz = _piv_wz;
            var _Cx = _end_wx-_brx3*_hw; var _Cy = _end_wy-_bry3*_hw; var _Cz = _end_wz;
            var _Dx = _end_wx+_brx3*_hw; var _Dy = _end_wy+_bry3*_hw; var _Dz = _end_wz;

            var _col = _part.col;
            vertex_position_3d(_cvb,_Ax,_Ay,_Az); vertex_texcoord(_cvb,0,0); vertex_color(_cvb,_col,1);
            vertex_position_3d(_cvb,_Bx,_By,_Bz); vertex_texcoord(_cvb,1,0); vertex_color(_cvb,_col,1);
            vertex_position_3d(_cvb,_Cx,_Cy,_Cz); vertex_texcoord(_cvb,1,1); vertex_color(_cvb,_col,1);
            vertex_position_3d(_cvb,_Ax,_Ay,_Az); vertex_texcoord(_cvb,0,0); vertex_color(_cvb,_col,1);
            vertex_position_3d(_cvb,_Cx,_Cy,_Cz); vertex_texcoord(_cvb,1,1); vertex_color(_cvb,_col,1);
            vertex_position_3d(_cvb,_Dx,_Dy,_Dz); vertex_texcoord(_cvb,0,1); vertex_color(_cvb,_col,1);
        }

        vertex_end(_cvb);
        vertex_freeze(_cvb);
        shader_set_uniform_f(le_u_sprpos, _ox, _oy, _oz);
        vertex_submit(_cvb, pr_trianglelist, -1);
        vertex_delete_buffer(_cvb);
    }
    shader_reset();
}

// Grille
if (le_grid_vb >= 0)
    vertex_submit(le_grid_vb, pr_linelist, -1);

// Gizmos lumières — croix 3D en vertex buffer temporaire
for (var _oi = 0; _oi < array_length(le_objects); _oi++) {
    var _o = le_objects[_oi];
    if (_o.type != "light") continue;
    var _gc = _o.col;
    var _gr = 22; // rayon gizmo
    var _gvb = vertex_create_buffer();
    vertex_begin(_gvb, global.vFormat);
    // Croix XYZ
    vertex_position_3d(_gvb,_o.x-_gr,_o.y,_o.z); vertex_texcoord(_gvb,0.5,0.5); vertex_color(_gvb,_gc,1.0);
    vertex_position_3d(_gvb,_o.x+_gr,_o.y,_o.z); vertex_texcoord(_gvb,0.5,0.5); vertex_color(_gvb,_gc,1.0);
    vertex_position_3d(_gvb,_o.x,_o.y-_gr,_o.z); vertex_texcoord(_gvb,0.5,0.5); vertex_color(_gvb,_gc,1.0);
    vertex_position_3d(_gvb,_o.x,_o.y+_gr,_o.z); vertex_texcoord(_gvb,0.5,0.5); vertex_color(_gvb,_gc,1.0);
    vertex_position_3d(_gvb,_o.x,_o.y,_o.z-_gr); vertex_texcoord(_gvb,0.5,0.5); vertex_color(_gvb,_gc,1.0);
    vertex_position_3d(_gvb,_o.x,_o.y,_o.z+_gr); vertex_texcoord(_gvb,0.5,0.5); vertex_color(_gvb,_gc,1.0);
    vertex_end(_gvb);
    vertex_submit(_gvb, pr_linelist, -1);
    vertex_delete_buffer(_gvb);
}

// ── Projection 3D→GUI ──────────────────────────────────────────────
// La surface est dessinee avec draw_surface_ext(..., -1, -1) :
//   surf pixel (px,py) → GUI (le_viewport_x+le_viewport_w - px, le_viewport_h - py)
// NDC → surf pixel : px=(ndcx*0.5+0.5)*vp_w, py=(orig_ndcy*0.5+0.5)*vp_h
// orig_ndcy = -_ndcy (puisqu'on pose _ndcy=-c[1]/vz pour corriger Y)
// Donc : GUI_x = le_viewport_x + le_viewport_w - (ndcx*0.5+0.5)*le_viewport_w
//        GUI_y = le_viewport_h - ((-_ndcy)*0.5+0.5)*le_viewport_h = (_ndcy*0.5+0.5)*le_viewport_h
for (var _oi = 0; _oi < array_length(le_objects); _oi++) {
    var _o = le_objects[_oi];
    // Centre vertical selon type
    var _cz_off = 0;
    switch (_o.type) {
        case "terrain": _cz_off = 0;          break;
        case "light":   _cz_off = 0;          break;
        case "char":    _cz_off = 100*_o.sz;  break;
        default:        _cz_off = 50*_o.sz;   break;
    }
    var _wx = _o.x; var _wy = _o.y; var _wz = _o.z + _cz_off;
    // Passe 1 : view transform
    var _v  = matrix_transform_vertex(_le_vmat, _wx, _wy, _wz);
    var _vz = _v[2];
    if (_vz <= 0) { le_obj_sx[_oi]=-1; le_obj_sy[_oi]=-1; continue; }
    // Passe 2 : projection
    var _c    = matrix_transform_vertex(_le_pmat, _v[0], _v[1], _vz);
    var _ndcx =  _c[0] / _vz;
    var _ndcy = -_c[1] / _vz;
    // Convertir NDC → GUI en tenant compte du flip horizontal de la surface
    var _sx = le_viewport_x + le_viewport_w - (_ndcx*0.5+0.5)*le_viewport_w;
    var _sy = (_ndcy*0.5+0.5)*le_viewport_h;
    // Hors ecran
    if (_sx < le_viewport_x-50 || _sx > le_viewport_x+le_viewport_w+50 || _sy < -50 || _sy > le_viewport_h+50)
        { le_obj_sx[_oi]=-1; le_obj_sy[_oi]=-1; continue; }
    le_obj_sx[_oi] = _sx;
    le_obj_sy[_oi] = _sy;
}

gpu_set_ztestenable(false);
gpu_set_zwriteenable(false);
gpu_set_cullmode(cull_noculling);
surface_reset_target();

// Dessiner la surface (xscale=-1 miroir H, yscale=-1 corrige sol/ciel)
draw_surface_ext(le_surf, le_viewport_x + le_viewport_w, le_viewport_h, -1, -1, 0, c_white, 1.0);

// ── Panneau parametres ombres (flottant sur la vue 3D, coin haut-gauche) ──────
if (le_shadow_panel) {
    var _spx  = le_viewport_x + 8;
    var _spy  = 8;
    var _spw  = 250;
    var _slx0 = _spx + 8; var _slx1 = _spx + _spw - 8;
    var _slw  = _slx1 - _slx0;
    var _sph  = 194;

    // Fond + bordure
    draw_set_alpha(0.94); draw_set_color(#0D131E);
    draw_rectangle(_spx, _spy, _spx+_spw, _spy+_sph, false);
    draw_set_color(#3D5080); draw_set_alpha(1.0);
    draw_rectangle(_spx, _spy, _spx+_spw, _spy+_sph, true);
    draw_set_font(my_font); draw_set_valign(fa_top); draw_set_alpha(1.0);
    var _sy = _spy + 6;

    // Titre
    draw_set_color(#AABBDD);
    draw_text(_slx0, _sy, "  Parametres ombres"); _sy += 18;
    draw_set_color(#2A3A55); draw_line(_spx+4, _sy, _spx+_spw-4, _sy); _sy += 5;

    // Bouton ON/OFF
    draw_set_color(le_shadow_enable ? #22AA55 : #772222);
    draw_rectangle(_slx0, _sy, _slx1, _sy+18, false);
    draw_set_color(#FFFFFF);
    draw_text(_slx0+6, _sy+2, le_shadow_enable ? "ON  (clic = desactiver)" : "OFF (clic = activer)");
    _sy += 24; draw_set_color(#2A3A55); draw_line(_spx+4, _sy, _spx+_spw-4, _sy); _sy += 5;

    // Slider azimut
    var _az_deg = round(radtodeg(le_sun_azimuth));
    draw_set_color(#FFCC44); draw_text(_slx0, _sy, "Direction soleil");
    draw_set_color(#FFFFFF); draw_text(_slx1-40, _sy, string(_az_deg)+"deg"); _sy += 14;
    var _az_px = _slx0 + clamp((le_sun_azimuth+pi)/(2*pi), 0, 1) * _slw;
    draw_set_color(#1C2C3C); draw_rectangle(_slx0, _sy, _slx1, _sy+10, false);
    draw_set_color(#FFCC44); draw_rectangle(_slx0, _sy, _az_px, _sy+10, false);
    draw_set_color(#FFFFFF); draw_circle(_az_px, _sy+5, 5, false); _sy += 16;
    draw_set_color(#2A3A55); draw_line(_spx+4, _sy, _spx+_spw-4, _sy); _sy += 5;

    // Slider noirceur
    var _dk_t = 1.0 - le_shadow_darkness;
    draw_set_color(#6699AA); draw_text(_slx0, _sy, "Noirceur");
    draw_set_color(#FFFFFF); draw_text(_slx1-28, _sy, string(round(_dk_t*100))+"%"); _sy += 14;
    var _dk_px = _slx0 + clamp(_dk_t, 0, 1) * _slw;
    draw_set_color(#1C2C3C); draw_rectangle(_slx0, _sy, _slx1, _sy+10, false);
    draw_set_color(#22CCFF); draw_rectangle(_slx0, _sy, _dk_px, _sy+10, false);
    draw_set_color(#FFFFFF); draw_circle(_dk_px, _sy+5, 5, false); _sy += 16;
    draw_set_color(#2A3A55); draw_line(_spx+4, _sy, _spx+_spw-4, _sy); _sy += 5;

    // Slider biais
    var _bias_min = 0.001; var _bias_max = 0.010;
    var _bias_t = (le_shadow_bias - _bias_min) / (_bias_max - _bias_min);
    draw_set_color(#6699AA); draw_text(_slx0, _sy, "Biais (precision)");
    draw_set_color(#FFFFFF); draw_text(_slx1-44, _sy, string(round(le_shadow_bias*10000)/10)+"e-4"); _sy += 14;
    var _bias_px = _slx0 + clamp(_bias_t, 0, 1) * _slw;
    draw_set_color(#1C2C3C); draw_rectangle(_slx0, _sy, _slx1, _sy+10, false);
    draw_set_color(#FFBB22); draw_rectangle(_slx0, _sy, _bias_px, _sy+10, false);
    draw_set_color(#FFFFFF); draw_circle(_bias_px, _sy+5, 5, false); _sy += 16;

    draw_set_color(#445566); draw_set_alpha(0.6);
    draw_text(_slx0, _sy, "[O] ou clic hors = fermer");
    draw_set_alpha(1.0);
}

// ── Cercles selection/hover — coords deja en GUI space ───────────
for (var _oi = 0; _oi < array_length(le_objects); _oi++) {
    var _sx = le_obj_sx[_oi]; var _sy = le_obj_sy[_oi];
    if (_sx < 0) continue;
    if (_oi == le_sel_obj) {
        draw_set_color(#FFFF00); draw_set_alpha(0.9);
        draw_circle(_sx, _sy, 16, true);
    } else if (_oi == le_hover_obj) {
        draw_set_color(#FFFFFF); draw_set_alpha(0.5);
        draw_circle(_sx, _sy, 14, true);
    }
}
draw_set_alpha(1.0);

// ═══════════════════════════════════════════════════════
// 2. UI PANNEAUX
// ═══════════════════════════════════════════════════════
draw_set_halign(fa_left); draw_set_valign(fa_top);
draw_set_font(my_font);

// Fond panneaux
draw_set_color(#141820); draw_set_alpha(0.96);
draw_rectangle(0, 0, le_panel_left_w, _sh, false);
draw_rectangle(le_viewport_x+le_viewport_w, 0, _sw, _sh, false);
draw_set_color(#3D4B6A); draw_set_alpha(1.0);
draw_line(le_panel_left_w, 0, le_panel_left_w, _sh);
draw_line(le_viewport_x+le_viewport_w, 0, le_viewport_x+le_viewport_w, _sh);

// ── Panneau gauche ──────────────────────────────────────
draw_set_color(#AABBDD); draw_set_alpha(1.0);
draw_set_valign(fa_middle);
draw_text(12, 16, "EDITEUR DE NIVEAU");
draw_set_color(#556677); draw_set_valign(fa_top);
draw_text(12, 34, "Clic droit+drag=orbite  Milieu=pan");

// Slider heure
var _sl_x0=8; var _sl_x1=le_panel_left_w-8;
var _sl_y=64;
draw_set_color(#2A3A5A); draw_set_alpha(0.9);
draw_rectangle(_sl_x0,_sl_y-8,_sl_x1,_sl_y+8,false);
// Couleur selon heure
var _h_t = clamp((le_day_hour-5.5)/15.0,0,1);
var _sl_grad = make_color_rgb(
    lerp(20,lerp(255,50,_h_t*_h_t),_h_t),
    lerp(20,lerp(150,200,_h_t),_h_t),
    lerp(60,lerp(50,255,_h_t),_h_t));
var _sl_px = _sl_x0 + (le_day_hour/24.0)*(_sl_x1-_sl_x0);
draw_set_color(_sl_grad); draw_set_alpha(1.0);
draw_rectangle(_sl_x0,_sl_y-8,_sl_px,_sl_y+8,false);
draw_set_color(#FFFFFF); draw_circle(_sl_px,_sl_y,7,false);
// Heure
var _hh = floor(le_day_hour); var _mm = floor((le_day_hour-_hh)*60);
draw_set_color(#DDEEFF); draw_set_valign(fa_middle);
draw_text(_sl_x0+4, _sl_y, string(_hh)+"h"+string(_mm));

// ── Barre ombres (clic = ouvre panneau parametres) ──────────────
draw_set_valign(fa_middle);
var _shbar_col = le_shadow_enable ? #44EE88 : #667788;
draw_set_color(_shbar_col); draw_set_alpha(1.0);
draw_rectangle(8, 74, le_panel_left_w-8, 88, false);
draw_set_color(le_shadow_enable ? #FFFFFF : #AABBCC);
draw_text(14, 81, le_shadow_enable ? "  Ombres : ON " : "  Ombres : OFF");
draw_set_color(#FFFFFF); draw_set_alpha(0.7);
draw_text(le_panel_left_w-20, 81, le_shadow_panel ? "v" : ">");

// Boutons + Ajouter / Supprimer (jamais decales — panneau ombre est sur la vue 3D)
var _le_btn_top = 90;
draw_set_valign(fa_middle);
draw_set_color(le_hover_btn_add ? #33AA66 : #226644); draw_set_alpha(le_hover_btn_add ? 1.0 : 0.85);
draw_rectangle(8, _le_btn_top,    le_panel_left_w-8, _le_btn_top+26, false);
draw_set_color(le_hover_btn_add ? #FFFFFF : #AADDBB); draw_set_alpha(1.0);
draw_text(20, _le_btn_top+13, "+ Ajouter objet");

draw_set_color(le_hover_btn_del ? #AA3333 : #662222); draw_set_alpha(le_hover_btn_del ? 1.0 : 0.85);
draw_rectangle(8, _le_btn_top+32, le_panel_left_w-8, _le_btn_top+58, false);
draw_set_color(le_hover_btn_del ? #FFFFFF : #DDAAAA); draw_set_alpha(1.0);
draw_text(20, _le_btn_top+45, "- Supprimer");

// Liste objets
var _le_list_top = _le_btn_top + 64;
draw_set_color(#8899BB); draw_set_alpha(1.0);
draw_text(8, _le_list_top, "Objets :");
var _nob = array_length(le_objects);
for (var _i = le_obj_scroll; _i < _nob; _i++) {
    var _oy = _le_list_top + 8 + (_i - le_obj_scroll)*28;
    if (_oy > _sh - 8) break;
    var _osel = (le_sel_obj == _i);
    var _ohov = (le_hover_obj == _i);
    var _ocol = _osel ? #3355BB : (_ohov ? #2A3A5A : #1C2433);
    draw_set_color(_ocol); draw_set_alpha(0.85);
    draw_rectangle(8,_oy,le_panel_left_w-8,_oy+24,false);
    var _ico = (le_objects[_i].type=="light") ? "💡" : "□";
    draw_set_color(_osel ? #FFFFFF : #8899BB); draw_set_alpha(1.0);
    draw_text(14, _oy+12, string(_i)+". "+le_objects[_i].name);
    // Point coloré type
    draw_set_color(le_objects[_i].col);
    draw_circle(le_panel_left_w-20, _oy+12, 5, false);
}

// Panneau droit : proprietes
var _rx = le_viewport_x+le_viewport_w;
draw_set_color(#AABBDD); draw_set_alpha(1.0);
draw_set_halign(fa_left); draw_set_valign(fa_top);
draw_text(_rx+10, 10, "PROPRIETES");

if (le_sel_obj >= 0 && le_sel_obj < array_length(le_objects)) {
    var _o2 = le_objects[le_sel_obj];
    draw_set_color(#7799BB);
    draw_text(_rx+10, 28, _o2.name + " ["+_o2.type+"]");

    // _btn : ligne unique [label] [-] [valeur] [+]
    // _cy = y haut de la rangee (hauteur 20px)
    // Detection Step_0 : minus = _mx in [_rx+90.._rx+112], plus = _mx in [_rx+168.._rx+190]
    var _btn = function(_label, _val_str, _cy, _bn_minus, _bn_plus) {
        var _rp = le_viewport_x+le_viewport_w;
        draw_set_halign(fa_left); draw_set_valign(fa_middle);
        draw_set_color(#8899BB); draw_set_alpha(1.0);
        draw_text(_rp+10, _cy+10, _label);
        // [-]
        var _am = (le_hold_btn == _bn_minus);
        draw_set_color(_am ? #CC4422 : #662222); draw_set_alpha(0.9);
        draw_rectangle(_rp+90, _cy+2, _rp+112, _cy+18, false);
        draw_set_color(#FFFFFF); draw_set_halign(fa_center);
        draw_text(_rp+101, _cy+10, "-");
        // valeur
        draw_set_color(#DDEEFF);
        draw_text(_rp+140, _cy+10, _val_str);
        // [+]
        var _ap = (le_hold_btn == _bn_plus);
        draw_set_color(_ap ? #33CC66 : #226633); draw_set_alpha(0.9);
        draw_rectangle(_rp+168, _cy+2, _rp+190, _cy+18, false);
        draw_set_color(#FFFFFF);
        draw_text(_rp+179, _cy+10, "+");
        draw_set_halign(fa_left); draw_set_alpha(1.0);
    };
    var _sh_col = #4A6080;

    draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_color(_sh_col); draw_text(_rx+10, 48, "--- Position ---");
    _btn("X",  string(round(_o2.x)),           64, "px-","px+");
    _btn("Y",  string(round(_o2.y)),            88, "py-","py+");
    _btn("Z",  string(round(_o2.z)),           112, "pz-","pz+");

    draw_set_color(_sh_col); draw_text(_rx+10, 136, "--- Echelle ---");
    _btn("S",  string(round(_o2.sx*100)/100),  152, "s-","s+");

    draw_set_color(_sh_col); draw_text(_rx+10, 176, "--- Rotation ---");
    _btn("Rz", string(round(_o2.rz)),          192, "rz-","rz+");
    _btn("Ry", string(round(_o2.ry)),          216, "ry-","ry+");
    _btn("Rx", string(round(_o2.rx)),          240, "rx-","rx+");

    draw_set_color(#334455);
    draw_text(_rx+10, 266, "Shift = x5 plus rapide");

    if (_o2.type == "light") {
        var _inten = variable_struct_exists(_o2,"intensity") ? _o2.intensity : 1.0;
        var _range = variable_struct_exists(_o2,"range") ? _o2.range : 500;
        draw_set_color(_sh_col); draw_text(_rx+10, 286, "--- Lumiere ---");
        _btn("Intensite", string(round(_inten*10)/10), 302, "li-","li+");
        _btn("Portee",    string(round(_range)),       326, "lr-","lr+");
        // Couleur (clic pour changer)
        draw_set_color(#8899BB);
        draw_text(_rx+10, 350, "Couleur (clic) :");
        draw_set_color(_o2.col); draw_set_alpha(0.95);
        draw_rectangle(_rx+10, 366, _rx+230, 386, false);
        draw_set_color(#AABBDD); draw_set_alpha(0.4);
        draw_rectangle(_rx+10, 366, _rx+230, 386, true); // bordure
        draw_set_alpha(1.0);
    }
} else {
    draw_set_color(#445566); draw_set_alpha(1.0);
    draw_text(_rx+10, 60, "Cliquer un objet\npour le selectionner.");
}

// Barre bas viewport
draw_set_color(#0E1218); draw_set_alpha(0.85);
draw_rectangle(le_panel_left_w, _sh-26, le_panel_left_w+le_viewport_w, _sh, false);
draw_set_color(#667788); draw_set_alpha(1.0); draw_set_valign(fa_middle);
draw_text(le_panel_left_w+8, _sh-13,
    "Yaw:"+string(round(le_cam_yaw))+"°  Pitch:"+string(round(le_cam_angle))+"°  Dist:"+string(round(le_cam_dist))
    +"    ESC=Retour  Ctrl+S=Sauver");

// Notif
if (le_notif_time > 0) {
    draw_set_color(#FFEE66); draw_set_alpha(min(1.0, le_notif_time/20.0));
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text(le_panel_left_w + le_viewport_w*0.5, _sh-48, le_notif);
}

// MODAL AJOUT D'OBJET
if (le_modal_open) {
    // Categories fixes (0-4) + assets 3D (5+)
    var _col_cube  = make_color_rgb(170,187,136);
    var _col_light = make_color_rgb(255,221,136);
    var _col_char  = make_color_rgb(100,170,255);
    var _col_ter   = make_color_rgb(100,200,100);
    var _col_obj   = make_color_rgb(136,170,187);
    var _col_asset = make_color_rgb(200,160,255);
    var _cats  = ["Cube", "Lumiere", "Personnage", "Terrain de match", "Importer OBJ..."];
    var _cols  = [_col_cube, _col_light, _col_char, _col_ter, _col_obj];
    var _descs = ["Boite 3D simple", "Lumiere ponctuelle reglable", "Silhouette FK articulee", "Sol texturee (su_ter1)", "Fichier .obj externe"];
    // Ajouter les assets 3D du projet
    var _na = array_length(le_asset_list);
    for (var _ai = 0; _ai < _na; _ai++) {
        array_push(_cats,  le_asset_list[_ai].name);
        array_push(_cols,  _col_asset);
        array_push(_descs, "Modele 3D du projet");
    }
    var _nc = array_length(_cats);
    var _mod_w = 320;
    var _row_h = 46; // hauteur par rangee
    var _mod_h = 48 + _nc*_row_h + 24;
    var _mod_x = le_viewport_x + (le_viewport_w - _mod_w)*0.5;
    var _mod_y = max(10, (_sh - _mod_h)*0.5);
    // Fond
    draw_set_color(#0A0E16); draw_set_alpha(0.94);
    draw_rectangle(_mod_x, _mod_y, _mod_x+_mod_w, _mod_y+_mod_h, false);
    draw_set_color(#3D5A8A); draw_set_alpha(1.0);
    draw_rectangle(_mod_x, _mod_y, _mod_x+_mod_w, _mod_y+_mod_h, true);
    draw_set_color(#AABBDD); draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text(_mod_x+_mod_w*0.5, _mod_y+22, "Ajouter un objet");
    // Separateur avant assets 3D
    var _mx2 = device_mouse_x_to_gui(0); var _my2 = device_mouse_y_to_gui(0);
    for (var _i = 0; _i < _nc; _i++) {
        // Separateur visuel avant la section assets
        if (_i == 5) {
            draw_set_color(#2A4A6A); draw_set_alpha(0.8);
            draw_rectangle(_mod_x+16, _mod_y+44+_i*_row_h-4, _mod_x+_mod_w-16, _mod_y+44+_i*_row_h-4+1, false);
            draw_set_color(#6688AA); draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_alpha(1.0);
            draw_text(_mod_x+20, _mod_y+44+_i*_row_h-14, "-- Modeles 3D du projet --");
        }
        var _by = _mod_y+44+_i*_row_h;
        var _hov = (_mx2>=_mod_x+16 && _mx2<=_mod_x+_mod_w-16 && _my2>=_by && _my2<_by+_row_h-2);
        draw_set_color(_hov ? _cols[_i] : #1C2840); draw_set_alpha(0.88);
        draw_rectangle(_mod_x+16, _by, _mod_x+_mod_w-16, _by+_row_h-2, false);
        draw_set_color(_cols[_i]); draw_set_alpha(1.0);
        draw_set_halign(fa_left); draw_set_valign(fa_middle);
        draw_text(_mod_x+26, _by+(_row_h-2)*0.35, _cats[_i]);
        draw_set_color(#556677); draw_set_valign(fa_top);
        draw_text(_mod_x+26, _by+(_row_h-2)*0.55, _descs[_i]);
    }
    draw_set_color(#334455); draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text(_mod_x+_mod_w*0.5, _mod_y+_mod_h-12, "ESC ou clic hors = fermer");
}

draw_set_alpha(1.0); draw_set_halign(fa_left); draw_set_valign(fa_top);