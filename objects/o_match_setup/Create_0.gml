/// Match Setup - Charge le niveau et initialise la scène

// Variable de contrôle
level_loaded = false;
level_objects = [];
level_file = "";

// Fonction de chargement du niveau
load_level_from_file = function(_filename) {
    level_objects = level_loader(_filename);
    level_file = _filename;

    // Spawn les objets chargés
    for (var _i = 0; _i < array_length(level_objects); _i++) {
        var _o = level_objects[_i];
        // Les objets du match (o_cc, o_cam, etc.) auront besoin d'accéder à ces données
    }

    level_loaded = true;
};

// Charger automatiquement le niveau par défaut
load_level_from_file("niveau.json");

// Debug
show_message("DEBUG o_match_setup:\nlevel_loaded = " + string(level_loaded) +
             "\nlevel_objects count = " + string(array_length(level_objects)));
