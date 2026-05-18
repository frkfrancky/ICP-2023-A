/// @function level_loader(filename)
/// @description Charge un niveau sauvegardé depuis JSON dans le dossier datafiles
/// @param {string} filename - Nom du fichier JSON (ex: "niveau.json")
/// @return {array} Array d'objets créés

function level_loader(_filename) {
    // Les fichiers JSON sont dans le répertoire de travail courant
    if (!file_exists(_filename)) {
        show_error("Fichier niveau non trouvé: " + _filename, true);
        return [];
    }

    // Lire le fichier texte
    var _f = file_text_open_read(_filename);
    var _json_str = "";
    while (!file_text_eof(_f)) {
        _json_str += file_text_readln(_f);
    }
    file_text_close(_f);

    // Parser le JSON
    var _sdata = json_parse(_json_str);

    var _result = [];
    var _obj_count = 0;

    // Parcourir les objets chargés directement par index
    for (var _i = 0; _i < 100; _i++) {
        var _key = "obj_" + string(_i);

        // Vérifier si la clé existe dans la struct
        if (!variable_struct_exists(_sdata, _key)) continue;

        var _obj = _sdata[$ _key];
        if (is_undefined(_obj)) continue;

        // Créer un struct avec toutes les propriétés
        // Ajouter offset Z négatif pour les objets chargés (sauf terrain)
        var _z = _obj.z;
        if (_obj.type != "terrain") {
            _z = -_obj.z - 100;  // Inverser et offset négatif pour placer au-dessus du terrain
        }

        var _o = {
            type: _obj.type,
            name: _obj.name,
            x: _obj.x, y: _obj.y, z: _z,
            rx: _obj.rx, ry: _obj.ry, rz: _obj.rz,
            sx: _obj.sx, sy: _obj.sy, sz: _obj.sz,
            col: _obj.col,
            vb: -1
        };

        // Créer vertex buffers pour les objets rendus
        if (_obj.type == "mesh") {
            var _scale = max(_obj.sx, max(_obj.sy, _obj.sz));
            _o.vb = create_cube_vb(_scale * 50);
            if (variable_struct_exists(_obj, "tex_spr")) _o.tex_spr = _obj.tex_spr;
        }

        if (_obj.type == "terrain") {
            // Pour les terrains, utiliser le même vertex buffer que le terrain par défaut
            // avec les mêmes UV coordinates de su_ter1
            var _hw = 700 * _obj.sx;
            var _hd = 400 * _obj.sy;
            var _vb = vertex_create_buffer();
            vertex_begin(_vb, global.vFormat);
            var _uvs = sprite_get_uvs(su_ter1, 0);
            var _u0 = _uvs[0]; var _v0 = _uvs[1];
            var _u1 = _uvs[2]; var _v1 = _uvs[3];
            vertex_position_3d(_vb,-_hw,-_hd,0); vertex_texcoord(_vb,_u0,_v0); vertex_color(_vb,c_white,1.0);
            vertex_position_3d(_vb, _hw,-_hd,0); vertex_texcoord(_vb,_u1,_v0); vertex_color(_vb,c_white,1.0);
            vertex_position_3d(_vb, _hw, _hd,0); vertex_texcoord(_vb,_u1,_v1); vertex_color(_vb,c_white,1.0);
            vertex_position_3d(_vb,-_hw,-_hd,0); vertex_texcoord(_vb,_u0,_v0); vertex_color(_vb,c_white,1.0);
            vertex_position_3d(_vb, _hw, _hd,0); vertex_texcoord(_vb,_u1,_v1); vertex_color(_vb,c_white,1.0);
            vertex_position_3d(_vb,-_hw, _hd,0); vertex_texcoord(_vb,_u0,_v1); vertex_color(_vb,c_white,1.0);
            vertex_end(_vb);
            vertex_freeze(_vb);
            _o.vb = _vb;
        }

        if (_obj.type == "char") {
            _o.vb = create_character_vb(_obj.sx * 30, _obj.sz * 80);
        }

        // Propriétés optionnelles pour lumières
        if (_obj.type == "light") {
            if (variable_struct_exists(_obj, "intensity")) _o.intensity = _obj.intensity;
            if (variable_struct_exists(_obj, "range")) _o.range = _obj.range;
        }

        array_push(_result, _o);
        _obj_count++;
        show_debug_message("  obj_" + string(_i) + ": type=" + _o.type + ", vb=" + string(_o.vb) + ", pos=(" + string(_o.x) + "," + string(_o.y) + "," + string(_o.z) + ")");
    }

    show_debug_message("Level loader: " + string(_obj_count) + " objets chargés au total");
    return _result;
}
