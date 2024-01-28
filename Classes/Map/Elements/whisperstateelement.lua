EditorWhisperState = EditorWhisperState or class(MissionScriptEditor)
function EditorWhisperState:create_element()
    self.super.create_element(self)
    self._element.class = "ElementWhisperState"
    self._element.values.state = false
    self._element.values.disable_hud = false
end

function EditorWhisperState:_build_panel()
	self:_create_panel()
    self:BooleanCtrl("state", {help = "Sets if whisper state should be turned on or off.", text = "Whisper State"})
    self:BooleanCtrl("disable_hud", {help = "Sets if the stealth HUD should be turned off, even in stealth.", text = "Disable HUD"})
end
