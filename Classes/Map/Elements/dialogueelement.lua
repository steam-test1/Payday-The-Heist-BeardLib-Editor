EditorDialogue = EditorDialogue or class(MissionScriptEditor)
function EditorDialogue:create_element()
	self.super.create_element(self)
	self._element.class = "ElementDialogue"
	self._element.values.dialogue = "none"
	self._element.values.execute_on_executed_when_done = false
	self._element.values.use_position = false
	self._element.values.force_quit_current = nil 
	self._element.values.use_instigator = false 
	self._element.values.can_not_be_muted = false 
	self._element.values.play_on_player_instigator_only = false 
end
function EditorDialogue:new_save_values(...)
	local t = EditorDialogue.super.new_save_values(self, ...)
	t.position = self._element.values.use_position and self._unit:position() or nil
	return t
end
function EditorDialogue:test_element()
	if self._element.values.dialogue == "none" then
		return
	end
	managers.dialog:quit_dialog()
	managers.dialog:queue_dialog(self._element.values.dialogue, {
		case = "russian",
		position = self._element.values.position,
		skip_idle_check = true,
		done_cbk = function()
			managers.editor:set_wanted_mute(true)
			managers.editor:set_listener_enabled(false)
		end
	})
	managers.editor:set_wanted_mute(false)
	managers.editor:set_listener_enabled(true)
end
function EditorDialogue:stop_test_element()
	managers.dialog:quit_dialog()
	managers.editor:set_wanted_mute(true)
	managers.editor:set_listener_enabled(false)
end
function EditorDialogue:_build_panel()
	self:_create_panel()
	self:ComboCtrl("dialogue", table.list_add({"none"}, managers.dialog:conversation_names()), {
		help = "Select a dialogue from the combobox", 
		free_typing = true,
		not_close = true, 
        searchbox = true, 
        fit_text = true,
		on_callback = function(item) 
            self:set_element_data(item)
            self:test_element(item)
        end, 
        close_callback = ClassClbk(self, "stop_test_element")
	})
	self:BooleanCtrl("force_quit_current", {help = "Force quits current dialog to allow this to be played immediately"})
	self:BooleanCtrl("execute_on_executed_when_done", {help = "Execute on executed when done"})
	self:BooleanCtrl("use_position")
	self:BooleanCtrl("use_instigator", {help = "Play on instigator"})
	self:BooleanCtrl("can_not_be_muted", {help = "This dialogue will play regardless of if the player has disabled contractor VO"})
	self:BooleanCtrl("play_on_player_instigator_only", {help = "This dialogue will only play on the player that triggers it"})
end
