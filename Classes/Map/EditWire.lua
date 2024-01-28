EditWire = EditWire or class(EditUnit)
local A_TARGET = Idstring("a_target")
function EditWire:editable(unit) return unit:wire_data() and unit:get_object(A_TARGET) end

function EditWire:build_menu(parent)
	local group = self:group("Wire")
	group:numberbox("Slack", ClassClbk(self._parent, "set_unit_data"), 0)
	group:tickbox("EditTarget", ClassClbk(self, "set_edit_target"), false, {help = "Allows editing the end point of the wire. Can be toggled with TAB"})
	group:Vec3Rot("Target", ClassClbk(self, "set_target_axis"))
end

function EditWire:update_positions() 
	self:set_unit_data()
	local object = self:target_object()
	self:SetItemValue("TargetPosition", object:position())
	self:SetItemValue("TargetRotation", object:rotation())
end

function EditWire:set_menu_unit(unit)
	self._menu:GetItem("Slack"):SetValue(unit and unit:wire_data() and unit:wire_data().slack)
	local object = self:target_object()
	self:SetItemValue("TargetPosition", object:position())
	self:SetItemValue("TargetRotation", object:rotation())
end

function EditWire:target_object()
	return self:selected_unit():get_object(A_TARGET)
end

function EditWire:widget_unit()
	if self._editing then
		return self:target_object()
	end
	return self:selected_unit()
end

function EditWire:set_edit_target(item)
	self._editing = item:Value()
end

function EditWire:update(t, dt)
	if Input:keyboard():pressed(Idstring("tab")) then
		self._menu:GetItem("EditTarget"):SetValue(not self._editing, true)
	end
end

function EditWire:set_target_axis()
	local object = self:target_object()
	object:set_position(self:GetItem("TargetPosition"):Value())
	object:set_rotation(self:GetItem("TargetRotation"):Value())
	self:set_unit_data_parent()
end

function EditWire:set_unit_data()
	local unit = self:selected_unit()
	if unit then
		unit:wire_data().slack = self:GetItem("Slack"):Value()
		local target = unit:get_object(A_TARGET)
		unit:wire_data().target_pos = target:position()
		local rot = target:rotation()
		unit:wire_data().target_rot = type(rot) ~= "number" and rot or Rotation() 
		unit:set_moving()
		CoreMath.wire_set_midpoint(unit, unit:orientation_object():name(), A_TARGET, Idstring("a_bender"))
	end
end