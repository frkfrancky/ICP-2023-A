/// Create a simple cube vertex buffer with neutral color (let shader handle lighting)
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

        for (var _vi = 0; _vi < 6; _vi++) {
            var _idx = _cf[_fi][_vi];
            vertex_position_3d(_vb, _cv[_idx][0], _cv[_idx][1], _cv[_idx][2]);
            vertex_texcoord(_vb, _nx*0.5+0.5, _ny*0.5+0.5);
            vertex_color(_vb, c_white, 1.0);  // Use white - let shader handle color
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

    var _hw = max(1, _w / 2);
    var _hh = max(1, _h / 2);

    // Simple plane with 4 triangles for better tessellation
    var _cols = 3;
    var _rows = 3;
    for (var _row = 0; _row < _rows - 1; _row++) {
        for (var _col = 0; _col < _cols - 1; _col++) {
            var _x0 = -_hw + _col * (2*_hw) / (_cols-1);
            var _x1 = -_hw + (_col+1) * (2*_hw) / (_cols-1);
            var _y0 = -_hh + _row * (2*_hh) / (_rows-1);
            var _y1 = -_hh + (_row+1) * (2*_hh) / (_rows-1);
            var _u0 = _col / (_cols-1);
            var _u1 = (_col+1) / (_cols-1);
            var _v0 = _row / (_rows-1);
            var _v1 = (_row+1) / (_rows-1);

            // Triangle 1
            vertex_position_3d(_vb, _x0, _y0, 0);
            vertex_texcoord(_vb, _u0, _v0);
            vertex_color(_vb, c_white, 1.0);

            vertex_position_3d(_vb, _x1, _y0, 0);
            vertex_texcoord(_vb, _u1, _v0);
            vertex_color(_vb, c_white, 1.0);

            vertex_position_3d(_vb, _x1, _y1, 0);
            vertex_texcoord(_vb, _u1, _v1);
            vertex_color(_vb, c_white, 1.0);

            // Triangle 2
            vertex_position_3d(_vb, _x0, _y0, 0);
            vertex_texcoord(_vb, _u0, _v0);
            vertex_color(_vb, c_white, 1.0);

            vertex_position_3d(_vb, _x1, _y1, 0);
            vertex_texcoord(_vb, _u1, _v1);
            vertex_color(_vb, c_white, 1.0);

            vertex_position_3d(_vb, _x0, _y1, 0);
            vertex_texcoord(_vb, _u0, _v1);
            vertex_color(_vb, c_white, 1.0);
        }
    }

    vertex_end(_vb);
    vertex_freeze(_vb);
    return _vb;
}

/// Create a simple cylinder for character rendering (placeholder)
function create_character_vb(_radius, _height) {
    if (!variable_global_exists("vFormat")) {
        vertex_format_begin();
        vertex_format_add_position_3d();
        vertex_format_add_texcoord();
        vertex_format_add_color();
        global.vFormat = vertex_format_end();
    }

    var _vb = vertex_create_buffer();
    vertex_begin(_vb, global.vFormat);

    var _segs = 8;

    // Cylinder body
    for (var _i = 0; _i < _segs; _i++) {
        var _a0 = _i / _segs * 2 * pi;
        var _a1 = (_i + 1) / _segs * 2 * pi;
        var _x0 = cos(_a0) * _radius;
        var _y0 = sin(_a0) * _radius;
        var _x1 = cos(_a1) * _radius;
        var _y1 = sin(_a1) * _radius;

        // Bottom triangle
        vertex_position_3d(_vb, _x0, _y0, 0);
        vertex_texcoord(_vb, _i / _segs, 0);
        vertex_color(_vb, c_white, 1.0);

        vertex_position_3d(_vb, _x1, _y1, 0);
        vertex_texcoord(_vb, (_i+1) / _segs, 0);
        vertex_color(_vb, c_white, 1.0);

        vertex_position_3d(_vb, _x1, _y1, _height);
        vertex_texcoord(_vb, (_i+1) / _segs, 1);
        vertex_color(_vb, c_white, 1.0);

        // Top triangle
        vertex_position_3d(_vb, _x0, _y0, 0);
        vertex_texcoord(_vb, _i / _segs, 0);
        vertex_color(_vb, c_white, 1.0);

        vertex_position_3d(_vb, _x1, _y1, _height);
        vertex_texcoord(_vb, (_i+1) / _segs, 1);
        vertex_color(_vb, c_white, 1.0);

        vertex_position_3d(_vb, _x0, _y0, _height);
        vertex_texcoord(_vb, _i / _segs, 1);
        vertex_color(_vb, c_white, 1.0);
    }

    // Top cap
    for (var _i = 0; _i < _segs; _i++) {
        var _a0 = _i / _segs * 2 * pi;
        var _a1 = (_i + 1) / _segs * 2 * pi;
        var _x0 = cos(_a0) * _radius;
        var _y0 = sin(_a0) * _radius;
        var _x1 = cos(_a1) * _radius;
        var _y1 = sin(_a1) * _radius;

        vertex_position_3d(_vb, 0, 0, _height);
        vertex_texcoord(_vb, 0.5, 0.5);
        vertex_color(_vb, c_white, 1.0);

        vertex_position_3d(_vb, _x0, _y0, _height);
        vertex_texcoord(_vb, 0.5 + cos(_a0)*0.5, 0.5 + sin(_a0)*0.5);
        vertex_color(_vb, c_white, 1.0);

        vertex_position_3d(_vb, _x1, _y1, _height);
        vertex_texcoord(_vb, 0.5 + cos(_a1)*0.5, 0.5 + sin(_a1)*0.5);
        vertex_color(_vb, c_white, 1.0);
    }

    vertex_end(_vb);
    vertex_freeze(_vb);
    return _vb;
}
