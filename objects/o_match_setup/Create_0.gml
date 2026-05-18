/// Match Setup - Charge le niveau et initialise la scène

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
