var camera = camera_get_active();
camera_set_view_mat(camera, matrix_build_lookat(640, 360, 1000, 0, 0, 0, 0, 0, 1));
var _asp = surface_get_width(application_surface) / surface_get_height(application_surface);
camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(45, _asp, 3, 3200));
camera_apply(camera);

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_alphatestenable(true);
gpu_set_texrepeat(true);
gpu_set_cullmode(cull_noculling);

// === RENDU OBJETS CHARGÉS ===
if (array_length(match_objects) > 0) {
    var _objs = match_objects;

    // Collecter lumières ponctuelles
    var _pls_pos = [[0,0,100000],[0,0,100000],[0,0,100000],[0,0,100000]];
    var _pls_col = [[0,0,0],[0,0,0],[0,0,0],[0,0,0]];
    var _pls_rad = [1.0, 1.0, 1.0, 1.0];
    var _li = 0;
    for (var _oi = 0; _oi < array_length(_objs) && _li < 4; _oi++) {
        var _oo = _objs[_oi];
        if (_oo.type != "light") continue;
        var _inten = variable_struct_exists(_oo, "intensity") ? _oo.intensity : 1.0;
        _pls_pos[_li] = [_oo.x, _oo.y, _oo.z];
        _pls_col[_li] = [color_get_red(_oo.col)/255*_inten, color_get_green(_oo.col)/255*_inten, color_get_blue(_oo.col)/255*_inten];
        _pls_rad[_li] = variable_struct_exists(_oo, "range") ? _oo.range : 500;
        _li++;
    }

    // Rendu mesh avec Shader1
    shader_set(Shader1);
    shader_set_uniform_f_array(u_ldir, lit_dir);
    shader_set_uniform_f_array(u_lcol, lit_color);
    shader_set_uniform_f(u_lamb, lit_amb);
    shader_set_uniform_f(u_lrim, lit_rim);
    shader_set_uniform_f_array(u_pl0, _pls_pos[0]);
    shader_set_uniform_f_array(u_pl1, _pls_pos[1]);
    shader_set_uniform_f_array(u_pl2, _pls_pos[2]);
    shader_set_uniform_f_array(u_sprpos, [0,0,0]);
    shader_set_uniform_f(u_flat_normal, 0.0);

    for (var _oi = 0; _oi < array_length(_objs); _oi++) {
        var _o = _objs[_oi];
        if (_o.type != "mesh" || _o.vb < 0) continue;
        var _r = color_get_red(_o.col)/255;
        var _g = color_get_green(_o.col)/255;
        var _b = color_get_blue(_o.col)/255;
        shader_set_uniform_f_array(u_lcol, [lit_color[0]*_r, lit_color[1]*_g, lit_color[2]*_b]);
        matrix_set(matrix_world, matrix_build(_o.x, _o.y, _o.z, _o.rx, _o.ry, _o.rz, _o.sx, _o.sy, _o.sz));
        vertex_submit(_o.vb, pr_trianglelist, -1);
    }

    matrix_set(matrix_world, matrix_build_identity());
    shader_reset();

    // Rendu terrain avec shd_floor
    for (var _oi = 0; _oi < array_length(_objs); _oi++) {
        var _o = _objs[_oi];
        if (_o.type != "terrain" || _o.vb < 0) continue;
        shader_set(shd_floor);
        shader_set_uniform_f_array(u_fldir, lit_dir);
        shader_set_uniform_f(u_flcol, lit_color[0], lit_color[1], lit_color[2]);
        shader_set_uniform_f(u_flamb, lit_amb);
        matrix_set(matrix_world, matrix_build(_o.x, _o.y, _o.z, _o.rx, _o.ry, _o.rz, _o.sx, _o.sy, _o.sz));
        vertex_submit(_o.vb, pr_trianglelist, sprite_get_texture(su_ter1, 0));
        matrix_set(matrix_world, matrix_build_identity());
        shader_reset();
    }

    // Rendu personnages
    shader_set(Shader1);
    shader_set_uniform_f_array(u_ldir, lit_dir);
    shader_set_uniform_f_array(u_lcol, lit_color);
    shader_set_uniform_f(u_lamb, lit_amb);
    shader_set_uniform_f(u_lrim, lit_rim);

    for (var _oi = 0; _oi < array_length(_objs); _oi++) {
        var _o = _objs[_oi];
        if (_o.type != "char" || _o.vb < 0) continue;
        var _r = color_get_red(_o.col)/255;
        var _g = color_get_green(_o.col)/255;
        var _b = color_get_blue(_o.col)/255;
        shader_set_uniform_f_array(u_lcol, [lit_color[0]*_r, lit_color[1]*_g, lit_color[2]*_b]);
        matrix_set(matrix_world, matrix_build(_o.x, _o.y, _o.z, _o.rx, _o.ry, _o.rz, _o.sx, _o.sy, _o.sz));
        vertex_submit(_o.vb, pr_trianglelist, -1);
    }

    matrix_set(matrix_world, matrix_build_identity());
    shader_reset();
}
