require("lib/states/GameState")
EditorState = EditorState or class(GameState)
function EditorState:init(game_state_machine)
	GameState.init(self, "editor", game_state_machine)
end

function EditorState:at_enter()
	if not Global.editor_mode then
		return
	end
	 
	managers.editor:set_enabled(true)
    managers.achievment.award = function() end
end

function EditorState:at_exit(new_state)
	if Global.editor_mode then
		managers.editor:set_enabled(false)
		managers.mission:activate()
	end
end