/// Draw level selector UI

if (array_length(available_levels) <= 0) return;

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _panel_x = _gui_w - 250;
var _panel_y = 10;
var _panel_w = 240;
var _item_h = 25;

// Panel background
draw_set_color(c_black);
draw_set_alpha(0.8);
draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + min(array_length(available_levels) * _item_h + 40, _gui_h - 20), false);
draw_set_alpha(1.0);

// Title
draw_set_color(c_white);
draw_text(_panel_x + 10, _panel_y + 5, "Niveaux disponibles:");

// Level list
var _scroll_y = _panel_y + 30;
for (var _i = 0; _i < array_length(available_levels); _i++) {
    var _level_name = available_levels[_i];
    var _is_selected = (_i == current_level_idx);

    // Item background
    if (_is_selected) {
        draw_set_color(#4488FF);
    } else {
        draw_set_color(#333333);
    }
    draw_rectangle(_panel_x + 2, _scroll_y, _panel_x + _panel_w - 2, _scroll_y + _item_h, false);

    // Item text
    draw_set_color(c_white);
    var _text_y = _scroll_y + (_item_h - 16) / 2;
    draw_text(_panel_x + 10, _text_y, string_copy(_level_name, 1, 25));

    // Check for click
    if (mouse_x > _panel_x + 2 && mouse_x < _panel_x + _panel_w - 2 &&
        mouse_y > _scroll_y && mouse_y < _scroll_y + _item_h &&
        mouse_check_button_pressed(mb_left)) {
        current_level_idx = _i;
        load_level_from_file(available_levels[_i]);
    }

    _scroll_y += _item_h;
}

// Reload button
draw_set_color(#2A5A8A);
var _btn_y = _scroll_y + 5;
draw_rectangle(_panel_x + 2, _btn_y, _panel_x + _panel_w - 2, _btn_y + 25, false);
draw_set_color(c_white);
draw_text(_panel_x + 10, _btn_y + 4, "Recharger (R)");

if (keyboard_check_pressed(ord("R"))) {
    available_levels = scan_level_files();
}

// Close panel (ESC)
if (keyboard_check_pressed(vk_escape) && level_loaded) {
    level_selector_open = false;
}

// Current level info
draw_set_color(c_white);
draw_text(_panel_x + 10, _panel_y + _panel_w + 10, "Actuel: " + level_file);

draw_set_alpha(1.0);
