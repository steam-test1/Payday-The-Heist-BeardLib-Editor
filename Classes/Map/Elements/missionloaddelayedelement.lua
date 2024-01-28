EditorLoadDelayed = EditorLoadDelayed or class(MissionScriptEditor)
EditorLoadDelayed.SAVE_UNIT_POSITION = false
EditorLoadDelayed.SAVE_UNIT_ROTATION = false
function EditorLoadDelayed:create_element(...)
	EditorLoadDelayed.super.create_element(self, ...)
	self._element.class = "ElementLoadDelayed"
	self._element.values.unit_ids = {}
end

function EditorLoadDelayed:update(t, dt)
	for _, id in pairs(self._element.values.unit_ids) do
		local unit = managers.worlddefinition:get_unit(id)
		if alive(unit) then
			self:draw_link({
				from_unit = self._unit,
				to_unit = unit,
				r = 1,
				g = 0,
				b = 1
			})
			Application:draw(unit, 1, 0, 1)
		else
			table.delete(self._element.values.unit_ids, id)
			return
		end
	end
	EditorLoadDelayed.super.update(self, t, dt)
end

function EditorLoadDelayed:check_unit(unit)
	return unit:unit_data().delayed_load ~= nil
end

function EditorLoadDelayed:_build_panel()
	self:_create_panel()
	self:BuildUnitsManage("unit_ids", nil, nil, {check_unit = ClassClbk(self, "check_unit")})
end

function EditorLoadDelayed:link_managed(unit)
	if alive(unit) and unit:unit_data() and self:check_unit(unit) then
		self:AddOrRemoveManaged("unit_ids", {unit = unit})
	end
end