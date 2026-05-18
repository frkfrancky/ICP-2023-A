/// Draw level selector UI

draw_clear(#1A1A2E);

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _panel_x = _gui_w * 0.5 - 200;
var _panel_y = _gui_h * 0.5 - 200;
var _panel_w = 400;
var _panel_h = 400;
var _item_h = 35;

// Panel background
draw_set_color(#2C3E50);
draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, false);

// Border
draw_set_color(#4488FF);
draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, true);

// Title
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(-1);
draw_text(_panel_x + _panel_w * 0.5, _panel_y + 20, "Sélectionner un niveau");

// Level list
var _item_y = _panel_y + 50;
var _max_items = 9;

draw_set_halign(fa_left);
draw_set_valign(fa_middle);

// Nouveau niveau button (index -1)
var _is_selected = (selected_idx == -1);
if (_is_selected) {
    draw_set_color(#4488FF);
} else if (point_in_rectangle(mouse_x, mouse_y, _panel_x + 10, _item_y, _panel_x + _panel_w - 10, _item_y + _item_h - 2)) {
    draw_set_color(#3A4A5F);
} else {
    draw_set_color(#2C3E50);
}
draw_rectangle(_panel_x + 10, _item_y, _panel_x + _panel_w - 10, _item_y + _item_h - 2, false);
draw_set_color(c_white);
draw_text(_panel_x + 20, _item_y + _item_h * 0.5, "[+ Nouveau niveau]");
if (mouse_check_button_pressed(mb_left) &&
    point_in_rectangle(mouse_x, mouse_y, _panel_x + 10, _item_y, _panel_x + _panel_w - 10, _item_y + _item_h)) {
    selected_idx = -1;
}
_item_y += _item_h;

// Existing levels
for (var _i = 0; _i < array_length(available_levels) && _item_y < _panel_y + _panel_h - 30; _i++) {
    var _level_name = available_levels[_i];
    var _is_selected = (_i == selected_idx);

    // Item background
    if (_is_selected) {
        draw_set_color(#4488FF);
    } else if (point_in_rectangle(mouse_x, mouse_y, _panel_x + 10, _item_y, _panel_x + _panel_w - 10, _item_y + _item_h - 2)) {
        draw_set_color(#3A4A5F);
    } else {
        draw_set_color(#2C3E50);
    }
    draw_rectangle(_panel_x + 10, _item_y, _panel_x + _panel_w - 10, _item_y + _item_h - 2, false);

    // Item text
    draw_set_color(c_white);
    draw_text(_panel_x + 20, _item_y + _item_h * 0.5, string_copy(_level_name, 1, 40));

    // Click handling
    if (mouse_check_button_pressed(mb_left) &&
        point_in_rectangle(mouse_x, mouse_y, _panel_x + 10, _item_y, _panel_x + _panel_w - 10, _item_y + _item_h)) {
        selected_idx = _i;
    }

    _item_y += _item_h;
}

// Two buttons: Éditer and Jouer
draw_set_color(#4488FF);
var _btn_y = _panel_y + _panel_h - 35;
var _btn_h = 25;
var _btn_w = (_panel_w - 30) / 2;

// Éditer button
draw_rectangle(_panel_x + 10, _btn_y, _panel_x + 10 + _btn_w, _btn_y + _btn_h, false);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(_panel_x + 10 + _btn_w * 0.5, _btn_y + 12, "Éditer");

if (mouse_check_button_pressed(mb_left) &&
    point_in_rectangle(mouse_x, mouse_y, _panel_x + 10, _btn_y, _panel_x + 10 + _btn_w, _btn_y + _btn_h)) {
    if (selected_idx == -1) {
        load_and_edit("");
    } else if (selected_idx >= 0 && selected_idx < array_length(available_levels)) {
        load_and_edit(available_levels[selected_idx]);
    }
}

// Jouer button
draw_set_color(#4488FF);
draw_rectangle(_panel_x + 20 + _btn_w, _btn_y, _panel_x + _panel_w - 10, _btn_y + _btn_h, false);
draw_set_color(c_white);
draw_text(_panel_x + 20 + _btn_w + _btn_w * 0.5, _btn_y + 12, "Jouer");

if (mouse_check_button_pressed(mb_left) &&
    point_in_rectangle(mouse_x, mouse_y, _panel_x + 20 + _btn_w, _btn_y, _panel_x + _panel_w - 10, _btn_y + _btn_h)) {
    if (selected_idx == -1) {
        load_and_play("");
    } else if (selected_idx >= 0 && selected_idx < array_length(available_levels)) {
        load_and_play(available_levels[selected_idx]);
    }
}

// Keyboard navigation
if (keyboard_check_pressed(vk_up)) {
    selected_idx = max(-1, selected_idx - 1);
}
if (keyboard_check_pressed(vk_down)) {
    selected_idx = min(array_length(available_levels) - 1, selected_idx + 1);
}
// Entrée = Éditer
if (keyboard_check_pressed(vk_enter)) {
    if (selected_idx == -1) {
        load_and_edit("");
    } else if (selected_idx >= 0 && selected_idx < array_length(available_levels)) {
        load_and_edit(available_levels[selected_idx]);
    }
}
// 'P' = Jouer
if (keyboard_check_pressed(ord("P"))) {
    if (selected_idx == -1) {
        load_and_play("");
    } else if (selected_idx >= 0 && selected_idx < array_length(available_levels)) {
        load_and_play(available_levels[selected_idx]);
    }
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
