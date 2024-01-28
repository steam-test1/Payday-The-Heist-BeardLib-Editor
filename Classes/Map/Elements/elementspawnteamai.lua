EditorSpawnTeamAI = EditorSpawnTeamAI or class(MissionScriptEditor)
function EditorSpawnTeamAI:create_element()
	self.super.create_element(self)	
	self._element.class = "ElementSpawnTeamAI"
	self._element.values.character = "any"
end

function EditorSpawnTeamAI:_build_panel()
	self:_create_panel()

	local characters = {"any"}

	for _, data in ipairs(managers.criminals:characters()) do
		table.insert(characters, data.name)
	end

	self:ComboCtrl("character", characters)
	self:Text("Spawns a team AI if possible. NOTE: If a character is provided and it's not available it will not be spawned at all!")
end