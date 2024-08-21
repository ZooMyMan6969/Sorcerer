local my_utility = require("my_utility/my_utility");

local menu_elements_sorc_base =
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_teleport_base")),
    teleport_mode         = combo_box:new(0, get_hash(my_utility.plugin_label .. "teleport_mode_base")),
}

local function menu()
    if menu_elements_sorc_base.tree_tab:push("Teleport") then
        menu_elements_sorc_base.main_boolean:render("Enable Spell", "");
        local options =  {"Auto", "Keybind"};
        menu_elements_sorc_base.teleport_mode:render("Mode", options, "");
        menu_elements_sorc_base.tree_tab:pop();
    end
end

local spell_id_tp = 288106;
local spell_radius = 2.5;
local spell_max_range = 10.0;

local next_time_allowed_cast = 0.0;
local function logics(entity_list, target_selector_data, best_target)
    local menu_boolean = menu_elements_sorc_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean,
                next_time_allowed_cast,
                spell_id_tp);

    if not is_logic_allowed then
        return false;
    end

    local player_position = get_player_position()
    local teleport_mode = menu_elements_sorc_base.teleport_mode:get();
    if teleport_mode == 1 then
        if orbwalker.get_orb_mode() == orb_mode.none then
            return false;
        end
    end

    local area_data = target_selector.get_most_hits_target_circular_area_heavy(player_position, 10.0, 2.5)
    if not area_data.main_target then
        return false;
    end

    if not area_data.main_target:is_enemy() then
        return false;
    end

    if area_data.score < 2.0 then
        return false;
    end

    local cast_position = area_data.main_target:get_position();
    local cast_position_distance_sqr = cast_position:squared_dist_to_ignore_z(player_position);
    if cast_position_distance_sqr < 2.0 then
        return false;
    end

    cast_spell.position(spell_id_tp, cast_position, 0.3);
    local current_time = get_time_since_inject();
    next_time_allowed_cast = current_time + 0.4;

    console.print("Sorcerer Plugin, Casted Tp");
    return true;
end

return
{
    menu = menu,
    logics = logics,
}
