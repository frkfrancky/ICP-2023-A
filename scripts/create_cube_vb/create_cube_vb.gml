/// Create a simple cube vertex buffer (matching o_level's le_make_cube_vb)
function create_cube_vb(_hw) {
    if (!variable_global_exists("vFormat")) {
        vertex_format_begin();
        vertex_format_add_position_3d();
        vertex_format_add_texcoord();
        vertex_format_add_color();
        global.vFormat = vertex_format_end();
    }

    var _vb = vertex_create_buffer();
    vertex_begin(_vb, global.vFormat);

    // 8 vertices of a cube
    var _cv = [
        [-_hw, -_hw, 0],      // 0
        [_hw, -_hw, 0],       // 1
        [_hw, _hw, 0],        // 2
        [-_hw, _hw, 0],       // 3
        [-_hw, -_hw, _hw*2],  // 4
        [_hw, -_hw, _hw*2],   // 5
        [_hw, _hw, _hw*2],    // 6
        [-_hw, _hw, _hw*2]    // 7
    ];

    // Face indices (2 triangles per face)
    var _cf = [[0,2,1,0,3,2], [4,5,6,4,6,7], [0,1,5,0,5,4], [2,3,7,2,7,6], [0,4,7,0,7,3], [1,2,6,1,6,5]];
    var _cn = [[0,0,-1], [0,0,1], [0,-1,0], [0,1,0], [-1,0,0], [1,0,0]];

    for (var _fi = 0; _fi < 6; _fi++) {
        var _nx = _cn[_fi][0];
        var _ny = _cn[_fi][1];
        var _nz = _cn[_fi][2];
        // Encode normal into color for basic shading (same as o_level)
        var _col2 = make_color_rgb(round((_nz*0.5+0.5)*255), 128, 128);

        for (var _vi = 0; _vi < 6; _vi++) {
            var _idx = _cf[_fi][_vi];
            vertex_position_3d(_vb, _cv[_idx][0], _cv[_idx][1], _cv[_idx][2]);
            vertex_texcoord(_vb, _nx*0.5+0.5, _ny*0.5+0.5);
            vertex_color(_vb, _col2, 1.0);
        }
    }

    vertex_end(_vb);
    vertex_freeze(_vb);
    return _vb;
}

/// Create a simple terrain/floor plane
function create_terrain_vb(_w, _h) {
    if (!variable_global_exists("vFormat")) {
        vertex_format_begin();
        vertex_format_add_position_3d();
        vertex_format_add_texcoord();
        vertex_format_add_color();
        global.vFormat = vertex_format_end();
    }

    var _vb = vertex_create_buffer();
    vertex_begin(_vb, global.vFormat);

    var _hw = _w / 2;
    var _hh = _h / 2;

    // Single plane (2 triangles)
    vertex_position_3d(_vb, -_hw, -_hh, 0);
    vertex_texcoord(_vb, 0, 0);
    vertex_color(_vb, c_white, 1.0);

    vertex_position_3d(_vb, _hw, -_hh, 0);
    vertex_texcoord(_vb, 1, 0);
    vertex_color(_vb, c_white, 1.0);

    vertex_position_3d(_vb, _hw, _hh, 0);
    vertex_texcoord(_vb, 1, 1);
    vertex_color(_vb, c_white, 1.0);

    vertex_position_3d(_vb, -_hw, -_hh, 0);
    vertex_texcoord(_vb, 0, 0);
    vertex_color(_vb, c_white, 1.0);

    vertex_position_3d(_vb, _hw, _hh, 0);
    vertex_texcoord(_vb, 1, 1);
    vertex_color(_vb, c_white, 1.0);

    vertex_position_3d(_vb, -_hw, _hh, 0);
    vertex_texcoord(_vb, 0, 1);
    vertex_color(_vb, c_white, 1.0);

    vertex_end(_vb);
    vertex_freeze(_vb);
    return _vb;
}
