/// Match Setup - Charge le niveau et initialise la scène

// Créer global.vFormat avant de charger le niveau
if (!variable_global_exists("vFormat")) {
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_texcoord();
    vertex_format_add_color();
    global.vFormat = vertex_format_end();
}

// Variable de contrôle
level_loaded = false;
level_objects = [];
level_file = "";

// Fonction de chargement du niveau
load_level_from_file = function(_filename) {
    level_objects = level_loader(_filename);
    level_file = _filename;
    level_loaded = true;
};

// Charger le niveau par défaut
load_level_from_file("niveau.json");
