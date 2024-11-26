EditorSpecialObjective = EditorSpecialObjective or class(MissionScriptEditor) --wip
EditorSpecialObjective.INSTANCE_VAR_NAMES = {
	{
		type = "special_objective_action",
		value = "so_action"
	}
}
EditorSpecialObjective._AI_SO_types = {
	"AI_defend",
	"AI_security",
	"AI_hunt",
	"AI_search",
	"AI_idle",
	"AI_escort",
	"AI_sniper",
	"AI_phalanx"
}
EditorSpecialObjective._enemies = {}
EditorSpecialObjective._nav_link_filter = {}
function EditorSpecialObjective:create_element()
	self.super.create_element(self)
	
	self._element.class = "ElementSpecialObjective"
	self._element.values.ai_group = "none"
	self._element.values.align_rotation = true
	self._element.values.align_position = true
	self._element.values.needs_pos_rsrv = true
	self._element.values.scan = true
	self._element.values.patrol_path = "none"
	self._element.values.path_style = "none"
	self._element.values.path_haste = "none"
	self._element.values.path_stance = "none"
	self._element.values.pose = "none"
	self._element.values.so_action = "none"
	self._element.values.search_position = self._element.values.position
	self._element.values.search_distance = 0
	self._element.values.interval = ElementSpecialObjective._DEFAULT_VALUES.interval
	self._element.values.base_chance = ElementSpecialObjective._DEFAULT_VALUES.base_chance
	self._element.values.chance_inc = 0
	self._element.values.action_duration_min = ElementSpecialObjective._DEFAULT_VALUES.action_duration_min
	self._element.values.action_duration_max = ElementSpecialObjective._DEFAULT_VALUES.action_duration_max
	self._element.values.interrupt_dis = 7
	self._element.values.interrupt_dmg = ElementSpecialObjective._DEFAULT_VALUES.interrupt_dmg
	self._element.values.attitude = "none"
	self._element.values.trigger_on = "none"
	self._element.values.interaction_voice = "none"
	self._element.values.SO_access = "0"
	self._element.values.followup_elements = {}
	self._element.values.spawn_instigator_ids = {}
	self._element.values.test_unit = "default"	
    self._element.values.interrupt_objective = false
end

function EditorSpecialObjective:draw_links()
	EditorSpecialObjective.super.draw_links(self)
	self:_draw_follow_up()
end

function EditorSpecialObjective:update(t, dt)
	self:update_selected(t, dt)
	EditorSpecialObjective.super.update(self, t, dt)
end

function EditorSpecialObjective:destroy()
	self:stop_test_element()
end

function EditorSpecialObjective:update_selected(t, dt)
    if not alive(self._unit) then
        return
    end

	-- TODO
	--[[if self._element.values.patrol_path ~= 'none' then
        managers.editor:layer('Ai'):draw_patrol_path_externaly(self._element.values.patrol_path)
    end]]

    local brush = Draw:brush()

    brush:set_color(Color(0.15, 1, 1, 1))

    local pen = Draw:pen(Color(0.15, 0.5, 0.5, 0.5))

    brush:sphere(self._element.values.search_position, self._element.values.search_distance, 4)
    pen:sphere(self._element.values.search_position, self._element.values.search_distance)
    brush:sphere(self._element.values.search_position, 10, 4)
	Application:draw_line(self._element.values.search_position, self._unit:position(), 0, 1, 0)

    local selected_unit = self:selected_unit()
    local unit_sel = self._unit == selected_unit

    if self._element.values.spawn_instigator_ids then
        for _, id in ipairs(self._element.values.spawn_instigator_ids) do
            local unit = self:GetPart('mission'):get_element_unit(id)
            local draw = not selected_unit or unit == selected_unit or unit_sel

            if draw then
                self:draw_link(
                    {
                        g = 0,
                        b = 0.75,
                        r = 0,
                        from_unit = unit,
                        to_unit = self._unit
                    }
                )
            end
        end
    end

    self:_highlight_if_outside_the_nav_field(t)
end

function EditorSpecialObjective:_highlight_if_outside_the_nav_field(t)
    if managers.navigation:is_data_ready() and managers.navigation._quad_field then
        local my_pos = self._unit:position()
        local nav_tracker = managers.navigation._quad_field:create_nav_tracker(my_pos, true)

        if nav_tracker:lost() then
            local t1 = t % 0.5
            local t2 = t % 1
            local alpha = nil
            alpha = t2 > 0.5 and t1 or 0.5 - t1
            alpha = math.lerp(0.1, 0.5, alpha)
            local nav_color = Color(alpha, 1, 0, 0)

            Draw:brush(nav_color):cylinder(my_pos, my_pos + math.UP * 80, 20, 4)
        end

        managers.navigation:destroy_nav_tracker(nav_tracker)
    end
end

function EditorSpecialObjective:_draw_follow_up()
    local selected_unit = self:selected_unit()
    local unit_sel = self._unit == selected_unit
	if self._element.values.followup_elements then
		for _, element_id in ipairs(self._element.values.followup_elements) do
			local unit = self:GetPart("mission"):get_element_unit(element_id)
			local draw = not selected_unit or unit == selected_unit or unit_sel
			if draw then
				self:draw_link({
					from_unit = self._unit,
					to_unit = unit,
					r = 0,
					g = 0.75,
					b = 0
				})
			end
		end
	end
end

function EditorSpecialObjective:test_element(item, loop)
    if not managers.navigation:is_data_ready() then
        BLE.Utils:Notify(
            "ERROR!",
            "Can't test spawn unit without ready navigation data (AI-graph)"
        )

        return
    elseif not self._unit then
        return
    end

    self:stop_test_element(loop)

    local spawn_unit_name = nil

    if self._element.values.test_unit == 'default' then
        local SO_access_strings = managers.navigation:convert_access_filter_to_table(self._element.values.SO_access)

        for _, access_category in ipairs(SO_access_strings) do
            if access_category == 'civ_male' then
                spawn_unit_name = 'units/payday2/characters/civ_male_casual_1/civ_male_casual_1'

                break
            elseif access_category == 'civ_female' then
                spawn_unit_name = 'units/payday2/characters/civ_female_casual_1/civ_female_casual_1'

                break
            elseif access_category == 'spooc' then
                spawn_unit_name = 'units/payday2/characters/ene_spook_1/ene_spook_1'

                break
            elseif access_category == 'shield' then
                spawn_unit_name = 'units/payday2/characters/ene_shield_2/ene_shield_2'

                break
            elseif access_category == 'tank' then
                spawn_unit_name = 'units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1'

                break
            elseif access_category == 'taser' then
                spawn_unit_name = 'units/payday2/characters/ene_tazer_1/ene_tazer_1'

                break
            else
                spawn_unit_name = 'units/payday2/characters/ene_swat_1/ene_swat_1'
                break
            end
        end
    else
        spawn_unit_name = self._element.values.test_unit
    end

    spawn_unit_name = spawn_unit_name or 'units/payday2/characters/ene_swat_1/ene_swat_1'

    if not PackageManager:has(Idstring("unit"), spawn_unit_name:id()) then
        self:GetPart("assets"):quick_load_from_db("unit", spawn_unit_name)
    end
    local enemy = safe_spawn_unit(spawn_unit_name:id(), self._unit:position(), self._unit:rotation())

    if not enemy then
        return
    end

    table.insert(self._enemies, enemy)
    managers.groupai:state():set_char_team(enemy, tweak_data.levels:get_default_team_ID('non_combatant'))
    enemy:movement():set_root_blend(false)

    local t = {
        id = self._unit:unit_data().unit_id,
        editor_name = self._unit:unit_data().name_id,
        values = deep_clone(self._element.values)
    }
    t.values.use_instigator = true
    t.values.is_navigation_link = false
    t.values.followup_elements = nil
    t.values.trigger_on = 'none'
    t.values.spawn_instigator_ids = nil
    t.values.action_duration_min = 0
    t.values.action_duration_max = 0
    t.values.enabled = true
    if string.begins(t.values.so_action, "AI") then
        t.values.so_action = "none"
    end
    self._script = MissionScript:new({elements = {}})
    self._so_class = ElementSpecialObjective:new(self._script, t)
    self._so_class._values.align_position = nil
    self._so_class._values.align_rotation = nil

    self._so_class:on_executed(enemy)
    
    if self._class_group:GetItemValue("LoopTestAnimation") then
        self._so_class:add_event_callback("complete", ClassClbk(self, "test_element", item, true))
    end

    if not loop then
        self._start_test_t = Application:time()
    end
end

function EditorSpecialObjective:stop_test_element(loop)
    for _, enemy in ipairs(self._enemies) do
        if alive(enemy) then
            enemy:set_slot(0)
        end
    end

    if type(loop) ~= "boolean" and self._start_test_t then
        log('Stop test time', Application:time() - (self._start_test_t or 0))

        self._start_test_t = nil
    end

    self._enemies = {}
end

function EditorSpecialObjective:link_managed(unit)
	if alive(unit) and unit:mission_element() then
		local element = unit:mission_element().element
		if table.contains({"ElementSpawnEnemyDummy", "ElementSpawnCivilian", "ElementSpawnEnemyGroup", "ElementSpawnCivilianGroup"}, element.class) then
			self:AddOrRemoveManaged("spawn_instigator_ids", {element = element})
        elseif table.contains({"ElementSpecialObjective", "ElementSpecialObjectiveGroup"}, element.class) then
			self:AddOrRemoveManaged("followup_elements", {element = element})
		end
	end
end

function EditorSpecialObjective:generate_search_position(item)
    if not managers.navigation:is_data_ready() then
        BLE.Utils:Notify(
            "ERROR!",
            "Can't generate search position without ready navigation data (AI-graph)"
        )
        return
    end
    local anim_set = AnimationManager:animation_set(Idstring("anims/units/enemies/cop/cop_def"))
    local action_id = Idstring(self._element.values.so_action)

    if anim_set and anim_set:has_animation(action_id) then
        local root_id = Idstring("root_point")
        local rotation = anim_set:animation_rotation(action_id, root_id, 1)
        local displacement = anim_set:animation_total_displacement(action_id, root_id)

        mrotation.invert(rotation)
        mvector3.rotate_with(displacement, rotation)
        mvector3.rotate_with(displacement, self._element.values.rotation)

        local new_pos = self._element.values.position + displacement
        local nav_tracker = managers.navigation._quad_field:create_nav_tracker(new_pos, true)
        
        new_pos = nav_tracker:field_position()
        mvector3.set_static(new_pos, math.round(new_pos.x), math.round(new_pos.y), math.round(new_pos.z))
        
        managers.navigation._quad_field:destroy_nav_tracker(nav_tracker)

        self._element.values.search_position = new_pos
        self:GetItem("search_position"):SetValue(new_pos)
    end
end

function EditorSpecialObjective:reset_search_position(item)
	local menu = item.parent.parent
	self._element.values.search_position = self._element.values.position
	self:GetItem("search_position"):SetValue(self._element.values.position)
	menu:SetValue(self._element.values.position, true)
end

function EditorSpecialObjective:apply_preset(item)
	local selection = item:SelectedItem()
	BLE.Utils:YesNoQuestion("This will apply the access flag preset " .. (selection or ""), function()
		if selection == "clear all" then
			self._element.values.SO_access = managers.navigation:convert_access_filter_to_string({})
		elseif selection == "select all" then
			self._element.values.SO_access = managers.navigation:convert_access_filter_to_string(NavigationManager.ACCESS_FLAGS)
        elseif selection == "civilians" then
			self._element.values.SO_access = managers.navigation:convert_access_filter_to_string({"civ_male", "civ_female"})
        elseif selection == "team ai" then
			self._element.values.SO_access = managers.navigation:convert_access_filter_to_string({"teamAI1", "teamAI2", "teamAI3", "teamAI4"})
        elseif selection == "all cops" then
            local filter = {
                "cop",
                "fbi",
                "swat",
                "sniper",
                "spooc",
                "shield",
                "tank",
                "taser"
            }
			self._element.values.SO_access = managers.navigation:convert_access_filter_to_string(filter)
        elseif selection == "all except civs" then
            local filter = clone(NavigationManager.ACCESS_FLAGS)
            table.delete(filter, "civ_male")
            table.delete(filter, "civ_female")
			self._element.values.SO_access = managers.navigation:convert_access_filter_to_string(filter)
		end
	end)
end

function EditorSpecialObjective:manage_flags()
    BLE.SelectDialog:Show({
        selected_list = managers.navigation:convert_access_filter_to_table(self._element.values.SO_access),
        list = NavigationManager.ACCESS_FLAGS,
        callback = function(list) self._element.values.SO_access = managers.navigation:convert_access_filter_to_string(list) end
    })
end

function EditorSpecialObjective:UnitCtrl(value_name, typ, check_match, check_not_match, opt)
	opt = self:BasicCtrlInit(value_name, opt)
	opt.check = function(unit)
		if unit:match("husk") then
			return false
		end
		local check_match_tbl = type(check_match) == "table" and check_match or {check_match}
		local check_not_match_tbl = type(check_not_match) == "table" and check_not_match or {check_not_match}
		local passed = false
        for _, check in pairs(check_match_tbl) do
			if unit:match(check) then
				passed = true
			end
		end
        if not passed then return false end
		for _, check in pairs(check_not_match_tbl) do
			if unit:match(check) then
				return false
			end
		end
		return true
	end
	opt.not_close = true
    local tb = (opt.group or self._holder):pathbox(value_name, ClassClbk(self, "set_element_data"), self:ItemData(opt)[value_name], typ, opt)
    local reset = tb:tb_imgbtn("Reset", function() 
        tb:SetValue("default", true) 
    end, nil, BLE.Utils.EditorIcons.cross, {
        help = "Reset Unit",
        size = tb.size * 1.75,
		position = function(item)
			item:SetPositionByString("RightCentery")
			item:Move(-6)
		end
    }) 
    reset:SetIndex(1)
    return tb
end

function EditorSpecialObjective:_build_panel()
	self:_create_panel()
	self._nav_link_filter = managers.navigation:convert_access_filter_to_table(self._element.values.SO_access)
	if type_name(self._element.values.SO_access) == "number" then
		self._element.values.SO_access = tostring(self._element.values.SO_access)
	end
	self._class_group:combobox("AccessFlagsPreset", ClassClbk(self, "apply_preset"), {"clear all", "select all", "team ai", "civilians", "all except civs", "all cops"}, nil, {help = "Here you can quickly select or deselect all access flags"})
	self._class_group:button("ManageAccessFlags", ClassClbk(self, "manage_flags"), {help = "Decide which types of AI are affected by this element"})
	self:BuildElementsManage("followup_elements", nil, {"ElementSpecialObjective", "ElementSpecialObjectiveGroup"})
	self:BuildElementsManage("spawn_instigator_ids", nil, {"ElementSpawnEnemyDummy", "ElementSpawnCivilian", "ElementSpawnEnemyGroup", "ElementSpawnCivilianGroup"})
    self:UnitCtrl("test_unit", "unit", {"/ene_", "/civ", "/npc"}, table.merge(BLE.Utils.EnemyBlacklist, {"dummy_corpse", "/civ_acc", "/npc_acc"}))
    local search = self:Vector3Ctrl("search_position")
    local tb = search:GetToolbar()
    tb:tb_imgbtn("generate_search_pos", ClassClbk(self, "generate_search_position"), nil, BLE.Utils.EditorIcons.browse_file, {help = "Automatically set search position based on the end point of the So Action animation. May not always give correct results and should only be used for navlinks!"})
	tb:tb_imgbtn("reset_search_pos", ClassClbk(self, "reset_search_position"), nil, BLE.Utils.EditorIcons.waypoint, {help = "Set search position back to element position."})
	self._class_group:tickbox("LoopTestAnimation", function(item) BLE.Options:SetValue("Map/LoopTestAnimation", item:Value()) end, BLE.Options:GetValue("Map/LoopTestAnimation"))
    self:BooleanCtrl("is_navigation_link", {text = "Navigation link"})
	self:BooleanCtrl("align_rotation")
	self:BooleanCtrl("align_position")
	self:BooleanCtrl("needs_pos_rsrv", {text = "Reserve position"})
	self:BooleanCtrl("repeatable")
	self:BooleanCtrl("use_instigator")
	self:BooleanCtrl("forced")
	self:BooleanCtrl("no_arrest")
	self:BooleanCtrl("scan", {text = "Idle scan"})
	self:BooleanCtrl("allow_followup_self", {text = "Allow self-followup"})
    self:BooleanCtrl("interrupt_objective", {text = "Interrupt Objectives When Disabled", help = "Allow interrupting of objectives if the element is disabled or removed"})
	local none = {"none"}
	self:ComboCtrl("ai_group", table.list_add(none, ElementSpecialObjective._AI_GROUPS), {help = "Select an ai group."})
    self:ComboCtrl("so_action", table.list_add(none, CopActionAct._act_redirects.SO, CopActionAct._act_redirects.script, self._AI_SO_types), {
        help = "Select a action that the unit should start with.", 
        not_close = true, 
        searchbox = true, 
        fit_text = true, 
        on_callback = function(item) 
            self:set_element_data(item)
            self:test_element(item)
        end, 
        close_callback = ClassClbk(self, "stop_test_element")
    })
    local path_names = {}
    for k,_ in pairs(managers.ai_data:all_patrol_paths()) do
        path_names[#path_names + 1] = k
    end
    table.sort(path_names)
    self:ComboCtrl("patrol_path", table.list_add(none, path_names), {help = "Patrol path to follow."})
	self:ComboCtrl("path_style", table.list_add(none, ElementSpecialObjective._PATHING_STYLES), {help = "Specifies how the patrol path should be used."})
	self:ComboCtrl("path_haste", table.list_add(none, ElementSpecialObjective._HASTES), {help = "Select path haste to use."})
	self:ComboCtrl("path_stance", table.list_add(none, ElementSpecialObjective._STANCES), {help = "Select path stance to use."})
	self:ComboCtrl("pose", table.list_add(none, ElementSpecialObjective._POSES), {help = "Select pose to use."})
	self:ComboCtrl("attitude", table.list_add(none, ElementSpecialObjective._ATTITUDES), {help = "Select combat attitude."})
	self:ComboCtrl("trigger_on", table.list_add(none, ElementSpecialObjective._TRIGGER_ON), {help = "Select when to trigger objective."})
	self:ComboCtrl("interaction_voice", table.list_add(none, ElementSpecialObjective._INTERACTION_VOICES), {help = "Select what voice to use when interacting with the character."})
	self:NumberCtrl("search_distance", {min = 0, help = "Used to specify the distance to use when searching for an AI"})
	self:NumberCtrl("interrupt_dis", {
		min = -1, 
		help = "Interrupt if a threat is detected closer than this distance (meters). -1 means at any distance. For non-visible threats this value is multiplied with 0.7.", 
		text = "Interrupt Distance:"
	})
	self:NumberCtrl("interrupt_dmg", {min = -1, 
		help = "Interrupt if total damage received as a ratio of total health exceeds this ratio. value: 0-1.", 
		text = "Interrupt Damage:"
	})
	self:NumberCtrl("interval", {min = -1, help = "Used to specify how often the SO should search for an actor. A negative value means it will check only once."})
	self:NumberCtrl("base_chance", {min = 0, max = 1,  help = "Used to specify chance to happen (1==absolutely!)"})
	self:NumberCtrl("chance_inc", {min = 0, max = 1, help = "Used to specify an incremental chance to happen", text = "Chance incremental:"})
	self:NumberCtrl("action_duration_min", {min = 0, help = "How long the character stays in his specified action."})
	self:NumberCtrl("action_duration_max", {min = 0, help = "How long the character stays in his specified action. Zero means indefinitely."})
end