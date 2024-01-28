EditorUnitSequenceTrigger = EditorUnitSequenceTrigger or class(MissionScriptEditor)
function EditorUnitSequenceTrigger:work(...)
	self._draw = {key = "sequence_list", id_key = "unit_id"}
	self:add_draw_units(self._draw)
	EditorUnitSequenceTrigger.super.work(self, ...)
end

function EditorUnitSequenceTrigger:create_element()
    self.super.create_element(self)
	self._element.class = "ElementUnitSequenceTrigger"
	self._element.module = "CoreElementUnitSequenceTrigger"
	self._element.values.trigger_times = 1
	self._element.values.sequence_list = {}
end

function EditorUnitSequenceTrigger:_build_panel()
	self:_create_panel()
	self:BuildUnitsManage("sequence_list", {
		key = "unit_id", values_name = "Sequence", value_key = "sequence", orig = {unit_id = 0, sequence = ""}, combo_items_func = function(name, value)
			local unit_name = value.unit:name() or ""
			local sequences = table.list_union({"interact", "complete", "load"}, managers.sequence:get_sequence_list(unit_name))
			return sequences
		end 
	}, self._draw.update_units)
end

function EditorUnitSequenceTrigger:link_managed(unit)
	if alive(unit) and unit:unit_data() then
		self:AddOrRemoveManaged("sequence_list", {unit = unit, key = "unit_id", orig = {unit_id = 0, sequence = ""}}, nil, self._draw.update_units)
	end
end