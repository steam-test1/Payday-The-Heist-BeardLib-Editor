EditorPrePlanning = EditorPrePlanning or class(MissionScriptEditor)
function EditorPrePlanning:create_element()
	self.super.create_element(self)
	self._element.class = "ElementPrePlanning"
	self._element.values.allowed_types = {}
	self._element.values.disables_types = {}
	self._element.values.location_group = tweak_data.preplanning.location_groups[1]
	self._element.values.upgrade_lock = "none"
	self._element.values.dlc_lock = "none"	
end

function EditorPrePlanning:_data_updated(value_type, value)
	self._element.values[value_type] = value
end

function EditorPrePlanning:_build_panel()
	self:_create_panel()
	self:ComboCtrl("upgrade_lock", tweak_data.preplanning.upgrade_locks, {help =  "Select a upgrade lock from the combobox"})
	self:ComboCtrl("dlc_lock", tweak_data.preplanning.dlc_locks, {help = "Select a DLC lock from the combobox"})
	self:ComboCtrl("location_group", tweak_data.preplanning.location_groups, {help = "Select a location group from the combobox"})
	local types = managers.preplanning:types()
	self._class_group:button("SelectAllowedTypes", function()
	    BLE.SelectDialog:Show({
	        selected_list = self._element.values.allowed_types,
	        list = types,
	        callback = ClassClbk(self, "_data_updated", "allowed_types")
	    })
	end)
	self._class_group:button("SelectDisablesTypes", function()
	    BLE.SelectDialog:Show({
	        selected_list = self._element.values.disables_types,
	        list = types,
	        callback = ClassClbk(self, "_data_updated", "disables_types")
	    })
	end)
end

EditorPrePlanningExecuteGroup = EditorPrePlanningExecuteGroup or class(MissionScriptEditor)

function EditorPrePlanningExecuteGroup:create_element()
	EditorPrePlanning.super.create_element(self)
	self._element.class = "ElementPrePlanningExecuteGroup"
	self._element.values.location_groups = {}
end

function EditorPrePlanningExecuteGroup:_build_panel()
	self:_create_panel()
	self._class_group:button("SelectLocationGroups", function()
	    BLE.SelectDialog:Show({
	        selected_list = self._element.values.location_groups,
	        list = tweak_data.preplanning.location_groups,
	        callback = SimpleClbk(EditorPrePlanning._data_updated, self, "disables_types")
	    })
	end, {text = "Location Groups To Activate (Spawn)"})
end