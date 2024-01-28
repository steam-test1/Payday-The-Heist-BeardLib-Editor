Hooks:PostHook(GameSetup, "init_finalize", "BeardLibEditorInitFinalize", function()
	BLE:SetLoadingText("Almost There")
	if Global.editor_mode then 
		if Global.game_settings.single_player then
			log("editor state")
			game_state_machine:change_state_by_name("ingame_standard") --No transition from IngameWaitingForPlayers to editor state in raid so intermediary for now.
			game_state_machine:change_state_by_name("editor") --Already told Rex about it, a proper transition will be added
		end
	end
end)

Hooks:PostHook(GameSetup, "destroy", "BeardLibEditorDestroy",function()
	if alive(BLE._vp) then
		BLE._vp:destroy()
	end
end)