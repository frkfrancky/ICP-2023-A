var camera= camera_get_active();
/*
if(o_target.camera_libre == false){
	x = o_target.x;
}*/
//camera_set_view_mat(camera, matrix_build_lookat(x,y,-200,object3.x,object3.y,0,0,0,1));
/*camera_set_view_mat(camera, matrix_build_lookat(x,y, -300,o_target.x, o_target.y,0,0,0,1));
camera_set_proj_mat(camera, matrix_build_projection_ortho(room_width, room_height,1, 3200));
z_look at = -500;
*/



z_target = zt_p;

camera_set_view_mat(camera, matrix_build_lookat(x,y,-500,o_target.x,o_target.y,-o_b.z/z_target,0,0,1));
var _asp = surface_get_width(application_surface) / surface_get_height(application_surface);
camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(fov_y, _asp, 3, 3200));
camera_apply(camera);

// Sauvegarder les matrices pour projection 3D→2D dans Draw GUI
cam_view_mat = camera_get_view_mat(camera);
cam_proj_mat = camera_get_proj_mat(camera);
cam_surf_w   = surface_get_width(application_surface);
cam_surf_h   = surface_get_height(application_surface);



gpu_set_ztestenable(true);
gpu_set_alphatestenable(true);
gpu_set_texrepeat(true);

// ═══════════════════════════════════════════════════════
// Niveau chargé depuis o_match_setup
// ═══════════════════════════════════════════════════════

if (instance_exists(o_match_setup) && array_length(o_match_setup.level_objects) > 0) {
    var _objs = o_match_setup.level_objects;

    // Rendu objets mesh avec Shader1
    shader_set(Shader1);
    shader_set_uniform_f_array(u_ldir, lit_dir);
    shader_set_uniform_f_array(u_lcol, lit_color);
    shader_set_uniform_f(u_lamb, lit_amb);
    shader_set_uniform_f(u_lrim, lit_rim);
    shader_set_uniform_f_array(u_sprpos, [0,0,0]);
    shader_set_uniform_f(u_flat_normal, 0.0);

    // Collecter premières lumières ponctuelles
    var _pl_count = 0;
    for (var _oi = 0; _oi < array_length(_objs) && _pl_count < 1; _oi++) {
        var _oo = _objs[_oi];
        if (_oo.type != "light") continue;
        var _inten = variable_struct_exists(_oo, "intensity") ? _oo.intensity : 1.0;
        var _lr = color_get_red(_oo.col)/255 * _inten;
        var _lg = color_get_green(_oo.col)/255 * _inten;
        var _lb = color_get_blue(_oo.col)/255 * _inten;
        var _lrange = variable_struct_exists(_oo, "range") ? _oo.range : 500;
        shader_set_uniform_f_array(u_pl0, [_oo.x, _oo.y, _oo.z]);
        shader_set_uniform_f_array(u_pl1, [_oo.x, _oo.y, _oo.z]);
        _pl_count++;
    }

    for (var _oi = 0; _oi < array_length(_objs); _oi++) {
        var _o = _objs[_oi];
        if (_o.type != "mesh" || _o.vb < 0) continue;
        var _r = color_get_red(_o.col)/255;
        var _g = color_get_green(_o.col)/255;
        var _b = color_get_blue(_o.col)/255;
        shader_set_uniform_f_array(u_lcol, [lit_color[0]*_r, lit_color[1]*_g, lit_color[2]*_b]);
        matrix_set(matrix_world, matrix_build(_o.x, _o.y, _o.z, _o.rx, _o.ry, _o.rz, _o.sx, _o.sy, _o.sz));
        vertex_submit(_o.vb, pr_trianglelist, -1);
        shader_set_uniform_f_array(u_lcol, lit_color);
    }

    matrix_set(matrix_world, matrix_build_identity());
    shader_reset();

    // Rendu terrain
    for (var _oi = 0; _oi < array_length(_objs); _oi++) {
        var _o = _objs[_oi];
        if (_o.type != "terrain" || _o.vb < 0) continue;
        shader_set(shd_floor);
        shader_set_uniform_f_array(u_fldir, lit_dir);
        shader_set_uniform_f_array(u_flcol, lit_color);
        shader_set_uniform_f(u_flamb, lit_amb);
        matrix_set(matrix_world, matrix_build(_o.x, _o.y, _o.z, _o.rx, _o.ry, _o.rz, _o.sx, _o.sy, _o.sz));
        vertex_submit(_o.vb, pr_trianglelist, sprite_get_texture(su_ter1, 0));
        matrix_set(matrix_world, matrix_build_identity());
        shader_reset();
    }
}
