EditorPlayerStyle = EditorPlayerStyle or class(MissionScriptEditor)
function EditorPlayerStyle:create_element()
    self.super.create_element(self) 
    self._element.class = "ElementPlayerStyle"
    self._element.values.style = ""
end
function EditorPlayerStyle:_build_panel()
	self:_create_panel()
	self:ComboCtrl("style", table.map_keys(tweak_data.scene_poses.player_style), {help = "Select a style from the combobox"})
	self:Text("Change player style.")
end
