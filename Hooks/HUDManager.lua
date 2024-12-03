Hooks:PostHook(HUDManager, "init", "EditorToggleFixInit", function(self)
    HUDManager.HIDEABLE_HUDS = {
		[PlayerBase.PLAYER_HUD:key()] = true,
		[PlayerBase.PLAYER_INFO_HUD_FULLSCREEN:key()] = true,
		[PlayerBase.PLAYER_DOWNED_HUD:key()] = true
	}

    self._visible_huds_states = {}
	self._disabled = Global.hud_disabled
end)

Hooks:PostHook(HUDManager, "show", "EditorToggleFixShow", function(self, name)
    if name == PlayerBase.PLAYER_INFO_HUD then
		name = PlayerBase.PLAYER_INFO_HUD
	end

	if name == PlayerBase.PLAYER_INFO_HUD_FULLSCREEN then
		name = PlayerBase.PLAYER_INFO_HUD_FULLSCREEN
	end

	self._visible_huds_states[name:key()] = true

	if self._disabled and HUDManager.HIDEABLE_HUDS[name:key()] then
		return
	end
end)

function HUDManager:disabled()
	return self._disabled
end

function HUDManager:set_disabled()
	self._disabled = true
	Global.hud_disabled = true

	for name, _ in pairs(HUDManager.HIDEABLE_HUDS) do
		if self._visible_huds_states[name] then
			local component = self._component_map[name]

			if component and alive(component.panel) then
				component.panel:hide()
			end
		end
	end
end

function HUDManager:set_enabled()
	self._disabled = false
	Global.hud_disabled = nil

	for name, _ in pairs(HUDManager.HIDEABLE_HUDS) do
		if self._visible_huds_states[name] then
			local component = self._component_map[name]

			if component and alive(component.panel) then
				component.panel:show()
			end
		end
	end
end