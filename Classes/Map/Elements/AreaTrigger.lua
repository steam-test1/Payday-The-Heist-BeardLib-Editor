core:import("CoreShapeManager")
EditorAreaTrigger = EditorAreaTrigger or class(MissionScriptEditor)
function EditorAreaTrigger:init(...)
	local unit = EditorAreaTrigger.super.init(self, ...)
	self._scripts = {}
	return unit
end

function EditorAreaTrigger:create_element()
	EditorAreaTrigger.super.create_element(self)
	self._element.class = "ElementAreaTrigger"
	self._element.module = "CoreElementArea"
	self._element.values.trigger_times = 1
	self._element.values.interval = 0.1
	self._element.values.trigger_on = "on_enter"
	self._element.values.instigator = managers.mission:default_area_instigator()
	self._element.values.shape_type = "box"
	self._element.values.width = 500
	self._element.values.depth = 500
	self._element.values.height = 500
	self._element.values.radius = 250
	self._element.values.spawn_unit_elements = {}
	self._element.values.amount = "1"
	self._element.values.instigator_name = ""
	self._element.values.use_shape_element_ids = nil
	self._element.values.use_disabled_shapes = false
	self._element.values.rules_element_ids = nil
	self._element.values.unit_ids = nil
	self._element.values.substitute_object = ""
end

function EditorAreaTrigger:set_shape_property(item)
	self:set_element_data(item)
	self._shape:set_property(item.name, item:Value())
	self._cylinder_shape:set_property(item.name, item:Value())
	self._sphere_shape:set_property(item.name, item:Value())
end

function EditorAreaTrigger:destroy()
	if self._scripts then
		for _, script in pairs(self._scripts) do
			if script.destroy then
				script:destroy()
			end
		end
	end
	if self._shape then
		self._shape:destroy()
	end
	if self._cylinder_shape then
		self._cylinder_shape:destroy()
	end
	if self._sphere_shape then
		self._sphere_shape:destroy()
	end
end

function EditorAreaTrigger:create_shapes()
	self._shape = CoreShapeManager.ShapeBoxMiddle:new({position = self._element.values.position, rotation = self._element.values.rotation, width = self._element.values.width, depth = self._element.values.depth, height = self._element.values.height})
	self._cylinder_shape = CoreShapeManager.ShapeCylinderMiddle:new({position = self._element.values.position, rotation = self._element.values.rotation, radius = self._element.values.radius, height = self._element.values.height})	
	self._sphere_shape = CoreShapeManager.ShapeSphere:new({position = self._element.values.position, rotation = self._element.values.rotation, radius = self._element.values.radius, height = self._element.values.height})
end

function EditorAreaTrigger:get_shape()
	if not self._shape then
		EditorAreaTrigger.create_shapes(self)
	end
	local st = self._element.values.shape_type
	return st == "box" and self._shape or st == "cylinder" and self._cylinder_shape or st == "sphere" and self._sphere_shape
end

function EditorAreaTrigger:update(t, dt)
	if not alive(self._unit) then
		return
	end
    if not self._element.values.use_shape_element_ids then
        local shape = self:get_shape()
        if shape then
            shape:draw(t, dt, 1, 1, 1)
        end
    else
        for _, id in ipairs(self._element.values.use_shape_element_ids) do
            if not self._scripts[id] then
                local element = managers.mission:get_mission_element(id)
                local clss = MissionEditor:get_editor_class(element.class)
                if clss then
                    self._scripts[id] = clss:new(element)
                end
            else
				if not self._scripts[id]._shape then
					EditorAreaTrigger.create_shapes(self._scripts[id])
				end

                local shape = EditorAreaTrigger.get_shape(self._scripts[id])
                shape:draw(t, dt, 0.85, 0.85, 0.85)
            end
        end
    end

	self:update_shape_position()
	EditorAreaTrigger.super.update(self, t, dt)
end

function EditorAreaTrigger:update_shape_position()
	if self._shape then
		local pos, rot = self._unit:position(), self._unit:rotation()
	    self._shape:set_position(pos)
	    self._cylinder_shape:set_position(pos)    
	    self._sphere_shape:set_position(pos)    
	    self._shape:set_rotation(rot)
	    self._cylinder_shape:set_rotation(rot)
	    self._sphere_shape:set_rotation(rot)
	end
end

function EditorAreaTrigger:set_element_data(params, ...)
	EditorAreaTrigger.super.set_element_data(self, params, ...)
	if params.name == "shape_type" then
		self:set_shape_type(self)
	elseif params.name == "instigator" then
		self._instigator_name_ctrlr:SetVisible(params:SelectedItem() == "equipment")
		self._holder:AlignItems(true)
	end
end

function EditorAreaTrigger:set_shape_type()
	local is_box = self._element.values.shape_type == "box"
	local is_cylinder = self._element.values.shape_type == "cylinder"
	local is_sphere = self._element.values.shape_type == "sphere"
	local uses_external = self._element.values.use_shape_element_ids
	is_box = (not uses_external and is_box)
	is_cylinder = (not uses_external and is_cylinder)
	self._depth:SetEnabled(is_box)
	self._width:SetEnabled(is_box)
	self._height:SetEnabled(is_box or is_cylinder)
	self._radius:SetEnabled(is_cylinder or is_sphere)
	if self._use_disabled then
		self._shape_type:SetEnabled(not uses_external)
		self._use_disabled:SetEnabled(uses_external)
	end
end

function EditorAreaTrigger:create_values_ctrlrs(disable)
	self:NumberCtrl("interval", {min = 0.01, help ="Set the check interval for the area, in seconds."})
	
	if not disable or not disable.trigger_type then
		self:ComboCtrl("trigger_on", {"on_enter", "on_exit", "both", "on_empty", "while_inside"})
	end

	if not disable or not disable.instigator then
		local instigator, _ = self:ComboCtrl("instigator", managers.mission:area_instigator_categories(), {help = "Select an instigator type for the area"})
		self._instigator_ctrlr = instigator
		local unit_ids = self._element.values.unit_ids
		self._instigator_ctrlr:SetEnabled(not unit_ids or not next(unit_ids))
	end

	if not disable or not disable.instigator_name then
		local instigator = self._element.values.instigator
		self._instigator_name_ctrlr = self:ComboCtrl("instigator_name", {
			"trip_mine",
			"ecm_jammer",
			"ammo_bag",
			"doctor_bag",
			"bodybags_bag"
		}, {help = "Select which units will trigger the area (equipment only)", visible = instigator and instigator == "equipment"})
	end

	if not disable or not disable.amount then
		self:ComboCtrl("amount", {"1", "2", "3", "4", "all"}, {help = "Select how many are required to trigger area"})
	end

	if not disable or not disable.substitute_object then
		self:StringCtrl("substitute_object", {help = "Named object's position will replace it's parent when checking against this trigger area"})
	end

	self._use_disabled_shapes = self:BooleanCtrl("use_disabled_shapes")
end

function EditorAreaTrigger:nil_if_empty(value_name)
	if self._element.values[value_name] and #self._element.values[value_name] == 0 then
		self._element.values[value_name] = nil
	end
end

function EditorAreaTrigger:_build_panel(disable_params)
	self:_create_panel()
	self:BuildUnitsManage("unit_ids", nil, ClassClbk(self, "nil_if_empty"))
	self:BuildElementsManage("spawn_unit_elements", nil, {"ElementSpawnUnit"})
	self:BuildElementsManage("use_shape_element_ids", nil, {"ElementAreaTrigger", "ElementShape"}, ClassClbk(self, "nil_if_empty"))
	self:BuildElementsManage("rules_element_ids", nil, {"ElementInstigatorRule"}, ClassClbk(self, "nil_if_empty"))
	self:create_values_ctrlrs(disable_params)
 	
	self._shape_type = self:ComboCtrl("shape_type", {"box", "cylinder", "sphere"}, {help = "Select shape for area"})
	self._width = self:NumberCtrl("width", {floats = 0, on_callback = ClassClbk(self, "set_shape_property"), help ="Set the width for the shape"})
	self._depth = self:NumberCtrl("depth", {floats = 0, on_callback = ClassClbk(self, "set_shape_property"), help ="Set the depth for the shape"})
	self._height = self:NumberCtrl("height", {floats = 0, on_callback = ClassClbk(self, "set_shape_property"), help ="Set the height for the shape"})
	self._radius = self:NumberCtrl("radius", {floats = 0, on_callback = ClassClbk(self, "set_shape_property"), help ="Set the radius for the shape"})
	self:set_shape_type()
end

function EditorAreaTrigger:link_managed(unit)
	if alive(unit) and unit:mission_element() then
		local element = unit:mission_element().element
		if table.contains({"ElementAreaTrigger", "ElementShape"}, element.class) then
			self:AddOrRemoveManaged("use_shape_element_ids", {element = element}, nil, ClassClbk(self, "nil_if_empty"))
		elseif element.class == "ElementInstigatorRule" then
			self:AddOrRemoveManaged("rules_element_ids", {element = element}, nil, ClassClbk(self, "nil_if_empty"))
		end
	end
end

function EditorAreaTrigger:update_selected(t, dt)
	if self._element.values.use_shape_element_ids then
		for _, id in ipairs(self._element.values.use_shape_element_ids) do
			local unit = self:GetPart('mission'):get_element_unit(id)

			if alive(unit) then
				local r, g, b = unit:mission_element():get_link_color()

				self:draw_link({
					from_unit = unit,
					to_unit = self._unit,
					r = r,
					g = g,
					b = b
				})
			end
		end
	end
	
	if self._element.values.rules_element_ids then
		for _, id in ipairs(self._element.values.rules_element_ids) do
			local unit = self:GetPart('mission'):get_element_unit(id)

			if alive(unit) then
				local r, g, b = unit:mission_element():get_link_color()

				self:draw_link({
					from_unit = unit,
					to_unit = self._unit,
					r = r,
					g = g,
					b = b
				})
			end
		end
	end
end

EditorAreaOperator = EditorAreaOperator or class(MissionScriptEditor)
function EditorAreaOperator:init(...)
	local unit = EditorAreaOperator.super.init(self, ...)
	self._apply_on_checkboxes = {"interval", "use_disabled_shapes"}
	for _,uses in ipairs(self._apply_on_checkboxes) do
		self._element.values["apply_on_" .. uses] = false
	end
	return unit
end

function EditorAreaOperator:create_element()
	self.super.create_element(self)
	self._element.class = "ElementAreaOperator"
	self._element.module = "CoreElementArea"
	self._element.values.elements = {}
	self._element.values.interval = 0.1
	self._element.values.trigger_on = "on_enter"
	self._element.values.instigator = managers.mission:default_area_instigator()
	self._element.values.amount = "1"
	self._element.values.use_disabled_shapes = false
	self._element.values.operation = "none"	
end

function EditorAreaOperator:_build_panel()
	self:_create_panel()
	self:BuildElementsManage("elements", nil, {"ElementAreaTrigger"})
	EditorAreaTrigger.create_values_ctrlrs(self, {trigger_type = true, instigator = true, amount = true})
	self:ComboCtrl("operation", {"none", "clear_inside"}, {help = "Select an operation for the selected elements"})
	for _,uses in ipairs(self._apply_on_checkboxes) do
		local name = "apply_on_" .. uses
		self:BooleanCtrl(name)
	end
	self:Text("This element can modify trigger_area element. Select areas to modify using insert and clicking on the elements.")
end

EditorAreaReportTrigger = EditorAreaReportTrigger or class(EditorAreaTrigger)
EditorAreaReportTrigger.ON_EXECUTED_ALTERNATIVES = {"enter", "leave", "empty", "while_inside", "on_death", "rule_failed", "reached_amount"}
function EditorAreaReportTrigger:create_element()
	EditorAreaReportTrigger.super.create_element(self)
	self._element.class = "ElementAreaReportTrigger"
	self._element.module = "CoreElementArea"
	self._element.values.trigger_on = nil
end

function EditorAreaReportTrigger:_build_panel()
	EditorAreaReportTrigger.super._build_panel(self, {trigger_type = true})
end