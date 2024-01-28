EditorLaserTrigger = EditorLaserTrigger or class(MissionScriptEditor)
EditorLaserTrigger.CLOSE_DISTANCE = 25
EditorLaserTrigger.SAVE_UNIT_POSITION = false
EditorLaserTrigger.SAVE_UNIT_ROTATION = false
EditorLaserTrigger.USES_INSTIGATOR_RULES = true
EditorLaserTrigger.COLORS = {red = {1,0,0}, green = {0, 1, 0}, blue = {0, 0, 1}}
EditorLaserTrigger.ON_EXECUTED_ALTERNATIVES = {"enter", "leave", "empty", "while_inside"}
function EditorLaserTrigger:init(...)
	local unit = "units/payday2/props/gen_prop_lazer_blaster_dome/gen_prop_lazer_blaster_dome"
	local assets = self:GetPart("assets")
	if not PackageManager:has(Idstring("unit"), Idstring(unit)) and assets then
		self:GetPart("assets"):quick_load_from_db("unit", unit)
	end
	self:destroy()
	self._dummy_unit = World:spawn_unit(Idstring(unit), Vector3(), Rotation())
	return EditorLaserTrigger.super.init(self, ...)
end

function EditorLaserTrigger:destroy()
    if alive(self._dummy_unit) then
        self._dummy_unit:set_enabled(false)
        self._dummy_unit:set_slot(0)
        World:delete_unit(self._dummy_unit)
		self:_break_creating_connection()
		self:_break_moving_point()
    end
end

function EditorLaserTrigger:create_element(...)
	EditorLaserTrigger.super.create_element(self, ...)
	self._element.class = "ElementLaserTrigger"
	self._element.values.trigger_times = 1
	self._element.values.interval = 0.1
	self._element.values.instigator = managers.mission:default_area_instigator()
	self._element.values.color = "red"
	self._element.values.visual_only = false
	self._element.values.skip_dummies = false
	self._element.values.cycle_interval = 0
	self._element.values.cycle_random = false
	self._element.values.cycle_active_amount = 1
	self._element.values.cycle_type = "flow"
	self._element.values.flicker_remove = nil
	self._element.values.points = {}
	self._element.values.connections = {}
end

function EditorLaserTrigger:update(t, dt, ...)
	if Input:keyboard():pressed(Idstring("tab")) then
		self:GetItem("EditPoints"):SetValue(not self._editing, true)
	end
	if self._editing then
		local ray = self:raycast()
		if self._moving_point and ray then
			local moving_point = self._element.values.points[self._moving_point]
			moving_point.pos = ray.position
			moving_point.rot = Rotation(ray.normal, math.UP)
		end
	end
	for _, point in pairs(self._element.values.points) do
		self:_draw_point(point.pos, point.rot, 0, 0.5, 0)
	end
	for i, connection in ipairs(self._element.values.connections) do
		local s_p = self._element.values.points[connection.from]
		local e_p = self._element.values.points[connection.to]
		local r, g, b = unpack(self.COLORS[self._element.values.color])
		if self._selected_connection and self._selected_connection == i then
			Application:draw_line(s_p.pos, e_p.pos, 1, 1, 1)
		else
			Application:draw_line(s_p.pos, e_p.pos, r, g, b)
		end
	end
	EditorLaserTrigger.super.update(self, t, dt)
end

function EditorLaserTrigger:raycast()
	local from = managers.editor:get_cursor_look_point(0)
	local to = managers.editor:get_cursor_look_point(100000)
	local ray = World:raycast(from, to, nil, managers.slot:get_mask("all"))
	if ray and ray.position then
		local index, point = self:_get_close_point(self._element.values.points, ray.position)
		local r, g, b = unpack(self.COLORS[self._element.values.color])
		if point then
			if self._creating_connection then
				local creating_point = self._element.values.points[self._creating_connection]
				Application:draw_line(creating_point.pos, point.pos, r * 0.6, g * 0.6, b * 0.6)
				self:_draw_point(point.pos, point.rot, 0, 1, 0)
			else
				self:_draw_point(point.pos, point.rot, 1, 0, 0)
			end
		else
			if self._creating_connection then
				local creating_point = self._element.values.points[self._creating_connection]
				Application:draw_line(creating_point.pos, ray.position, r * 0.6, g * 0.6, b * 0.6)
			end
			self:_draw_point(ray.position, Rotation(ray.normal, math.UP))
		end
        if alive(self._dummy_unit) then
            self._dummy_unit:set_position(ray.position)
            self._dummy_unit:set_rotation(Rotation(ray.normal, math.UP))
            self._dummy_unit:set_moving(true)
        end
		return ray
	end
	return nil
end

function EditorLaserTrigger:_get_close_point(points, pos)
	for i, point in pairs(points) do
		if mvector3.distance(point.pos, pos) < self.CLOSE_DISTANCE then
			return i, point
		end
	end
	return nil, nil
end

function EditorLaserTrigger:_draw_point(pos, rot, r, g, b)
	r = r or 1
	g = g or 1
	b = b or 1
	local len = 25
	local scale = 0.05
	Application:draw_sphere(pos, 5, r, g, b)
	Application:draw_arrow(pos, pos + rot:x() * len, 1, 0, 0, scale)
	Application:draw_arrow(pos, pos + rot:y() * len, 0, 1, 0, scale)
	Application:draw_arrow(pos, pos + rot:z() * len, 0, 0, 1, scale)
end

function EditorLaserTrigger:remake_dummies(pos)
	self:update_element()
	local element = managers.mission:get_element_by_id(self._element.id)
	if element then
		element:remake_dummies()
	end
end

function EditorLaserTrigger:_remove_any_close_point(pos)
	local index, point = self:_get_close_point(self._element.values.points, pos)
	if index then
		self:_check_remove_index(index)
		self._element.values.points[index] = nil
		return true
	end
	return false
end

function EditorLaserTrigger:_break_creating_connection()
	if alive(self._dummy_unit) then
		self._dummy_unit:set_enabled(true)
	end
	self._creating_connection = nil
end

function EditorLaserTrigger:_break_moving_point()
	self._moving_point = nil
	self._moving_point_undo = nil
end

function EditorLaserTrigger:mouse_busy()
	return self._editing
end

function EditorLaserTrigger:mouse_pressed(button, x, y)
	if self._editing then
		if button == Idstring("0") then
			self:create_or_remove_point()
		elseif button == Idstring("1") then
			self:connect_to_point()
		elseif button == Idstring("2") then
			self:move_point()
		end
		return true
	end
end

function EditorLaserTrigger:create_or_remove_point()
	if self._moving_point then
		self._element.values.points[self._moving_point] = self._moving_point_undo
		self:_break_moving_point()
		return
	end
	if self._creating_connection then
		self:_break_creating_connection()
		return
	end
	local ray = self:raycast()
	if not ray then
		return
	end
	local pos = ray.position
	local rot = Rotation(ray.normal, math.UP)
	if self:_remove_any_close_point(pos) then
		self:remake_dummies()
		return
	end
	table.insert(self._element.values.points, {pos = pos, rot = rot})
	self:remake_dummies()
end

function EditorLaserTrigger:connect_to_point()
	if self._moving_point then
		return
	end
	local ray = self:raycast()
	if not ray then
		return
	end
	local pos = ray.position
	local rot = Rotation(ray.normal, math.UP)
	local index, point = self:_get_close_point(self._element.values.points, pos)
	if not point then
		self:_break_creating_connection()
		return
	end
	if self._creating_connection then
		if self._creating_connection ~= index then
			if not self:_check_remove_connection(self._creating_connection, index) then
				table.insert(self._element.values.connections, {
					from = self._creating_connection,
					to = index
				})
				self:fill_connections_box()
			end
		end
		self:_break_creating_connection()
	else
		self._dummy_unit:set_enabled(false)
		self._creating_connection = index
	end
end

function EditorLaserTrigger:move_point()
	if self._creating_connection then
		return
	end
	local ray = self:raycast()
	if not ray then
		return
	end
	local pos = ray.position
	local rot = Rotation(ray.normal, math.UP)
	local index, point = self:_get_close_point(self._element.values.points, pos)
	if not point then
		self:remake_dummies()
		return
	end
	self._moving_point_undo = clone(point)
	self._moving_point = index
	self:remake_dummies()
end

function EditorLaserTrigger:mouse_released()
	if self._moving_point then
		self:_break_moving_point()
	end
end

function EditorLaserTrigger:_check_remove_index(index)
	for i, connection in ipairs(clone(self._element.values.connections)) do
		if connection.from == index or connection.to == index then
			if self._selected_connection and self._selected_connection == i then
				self:fill_connections_box()
				self._selected_connection = nil
				self:update_selection()
			end
			table.remove(self._element.values.connections, i)
			self:fill_connections_box()
			self:_check_remove_index(index)
			return
		end
	end
end

function EditorLaserTrigger:_check_remove_connection(i1, i2)
	for i, connection in ipairs(clone(self._element.values.connections)) do
		if connection.from == i1 and connection.to == i2 or connection.from == i2 and connection.to == i1 then
			table.remove(self._element.values.connections, i)
			if self._selected_connection and self._selected_connection == i then
				self:fill_connections_box()
				self._selected_connection = nil
				self:update_selection()
			end
			return true
		end
	end
	return false
end

function EditorLaserTrigger:set_edit_points(item)
	self._editing = item:Value()
	self._dummy_unit:set_visible(self._editing)
	self:remake_dummies()
end

function EditorLaserTrigger:fill_connections_box()
	local items = {"None"}
	for i, connection in ipairs(self._element.values.connections) do
		table.insert(items, {text = "Connection #" .. tostring(i), value = i})
	end
	self._connections_box:SetItems(items)
end

function EditorLaserTrigger:set_connection_from_position(item)
	local connection = self._element.values.connections[self._selected_connection]
	local from = self._element.values.points[connection.from]
	from.pos = self:GetItemValue("FromPosition")
	from.rot = self:GetItemValue("FromRotation")
	self:remake_dummies()
end

function EditorLaserTrigger:set_connection_to_position(item)
	local connection = self._element.values.connections[self._selected_connection]
	local to = self._element.values.points[connection.to]
	to.pos = self:GetItemValue("ToPosition")
	to.rot = self:GetItemValue("ToRotation")
	self:remake_dummies()
end

function EditorLaserTrigger:update_selection(item)
	self._selected_connection_box:ClearItems()
	self._selected_connection_box:SetVisible(self._selected_connection ~= nil)
	if self._selected_connection then
		local connection = self._element.values.connections[self._selected_connection]
		local from = self._element.values.points[connection.from]
		local to = self._element.values.points[connection.to]
		self._selected_connection_box:Vec3Rot("From", ClassClbk(self, "set_connection_from_position"), from.pos, from.rot, {use_gridsnap_step = true})
		self._selected_connection_box:Vec3Rot("To", ClassClbk(self, "set_connection_to_position"), to.pos, to.rot, {use_gridsnap_step = true})
	end
	self._holder:AlignItems(true)
end

function EditorLaserTrigger:select_connection(item)
	local selected_index = item:SelectedItem().value
	if not selected_index then
		self._selected_connection = nil
		self:update_selection()
		return
	end
	self._selected_connection = tonumber(selected_index)
	self:update_selection()
end

function EditorLaserTrigger:_build_panel()
	self:_create_panel()
	self:Info("Editing points:\nLMB to create/remove/place a point\nRMB to connect points\nMMB to move an existing point")
	self._class_group:tickbox("EditPoints", ClassClbk(self, "set_edit_points"), false)
	self._connections_box = self._class_group:combobox("SelectedConnection", ClassClbk(self, "select_connection"), {"None"}, 1)
	self._selected_connection_box = self._class_group:group("SelectedConnection", {visible = false})
	local options = self._class_group:group("Options")
	self:NumberCtrl("interval", {floats = 2, min = 0.01, help = "Set the check interval for the laser, in seconds", text = "Check interval", group = options})
	self:ComboCtrl("instigator", managers.mission:area_instigator_categories(), {help = "Select an instigator type", group = options})
	self:ComboCtrl("color", {"red","green","blue"}, {group = options})
 	self:ComboCtrl("cycle_type", {"flow", "pop"}, {group = options})
	self:BooleanCtrl("flicker_remove", {help = "Will flicker the lasers when removed", group = options})
	self:NumberCtrl("cycle_interval", {floats = 2, min = 0, help = "Set the check cycle interval for the laser, in seconds (0 == disabled)", group = options})
	self:NumberCtrl("cycle_active_amount", {floats = 0, min = 1, help = "Defines how many are active during cycle", group = options})
	self:BooleanCtrl("visual_only", {group = options})
	self:BooleanCtrl("skip_dummies", {group = options})
	self:BooleanCtrl("cycle_random", {group = options})
	self:fill_connections_box()
end
