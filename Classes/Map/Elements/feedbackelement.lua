EditorFeedback = EditorFeedback or class(MissionScriptEditor)
EditorFeedback.USES_POINT_ORIENTATION = true
function EditorFeedback:create_element()
	EditorFeedback.super.create_element(self)
	self._element.class = "ElementFeedback"
	self._element.values.effect = "mission_triggered"
	self._element.values.range = 0
	self._element.values.use_camera_shake = true
	self._element.values.use_rumble = true
	self._element.values.camera_shake_effect = "mission_triggered"
	self._element.values.camera_shake_amplitude = 1
	self._element.values.camera_shake_frequency = 1
	self._element.values.camera_shake_attack = 0.1
	self._element.values.camera_shake_sustain = 0.3
	self._element.values.camera_shake_decay = 2.1
	self._element.values.rumble_peak = 1
	self._element.values.rumble_attack = 0.1
	self._element.values.rumble_sustain = 0.3
	self._element.values.rumble_release = 2.1
	self._element.values.above_camera_effect = "none"
	self._element.values.above_camera_effect_distance = 0.5 
end

function EditorFeedback:update_selected(t, dt)
    if self._element.values.orientation_elements then
        for _, id in ipairs(self._element.values.orientation_elements) do
            local unit = self:GetPart('mission'):get_element_unit(id)

            self:_draw_ranges(unit:position())
        end
    else
        self:_draw_ranges(self._unit:position())
    end
end

function EditorFeedback:_draw_ranges(pos)
    local brush = Draw:brush()

    brush:set_color(Color(0.15, 1, 1, 1))

    local pen = Draw:pen(Color(0.15, 0.5, 0.5, 0.5))

    brush:sphere(pos, self._element.values.range, 4)
    pen:sphere(pos, self._element.values.range)
    brush:set_color(Color(0.15, 0, 1, 0))
    pen:set(Color(0.15, 0, 1, 0))
    brush:sphere(pos, self._element.values.range * self._element.values.above_camera_effect_distance, 4)
    pen:sphere(pos, self._element.values.range * self._element.values.above_camera_effect_distance)
end


function EditorFeedback:_build_panel()
	self:_create_panel()
	self:NumberCtrl("range", {min = -1, help = "The range the effect should be felt. 0 means that it will be felt everywhere"})
	self:ComboCtrl("above_camera_effect", table.list_add({"none"}, self:_effect_options()), {help = "Select an above camera effect", text = "Above Camera Effect"})
	self:NumberCtrl("above_camera_effect_distance", {
		min = 0,
		max = 1,
		help = "A filter value to use with the range. A value of 1 means that the effect will be played whenever inside the range, a lower value means you need to be closer to the position.", 
		text = "Distance filter"
	})
	self:BooleanCtrl("use_camera_shake")
	self:ComboCtrl("camera_shake_effect", {"mission_triggered","headbob","player_land","breathing"}, {help = "Select a camera shake effect", "effect"})
	self:NumberCtrl("camera_shake_amplitude", {min = -1, help = "Amplitude basically decides the strenght of the shake", text = "Amplitude"})
	self:NumberCtrl("camera_shake_frequency", {min = -1, help = "Changes the frequency of the shake", text = "Frequency"})
	self:NumberCtrl("camera_shake_attack", {min = -1, help = "Time to reach maximum shake", text = "Attack"})
	self:NumberCtrl("camera_shake_sustain", {min = -1, help = "Time to sustain maximum shake", text = "Sustain"})
	self:NumberCtrl("camera_shake_decay", {min = -1, help = "Time to decay from maximum shake to zero", text = "Decay"})
	self:BooleanCtrl("use_rumble")
	self:NumberCtrl("rumble_peak", {min = -1, help = "A value to determine the strength of the rumble", text = "Peak"})
	self:NumberCtrl("rumble_attack", {min = -1, help = "Time to reach maximum rumble", text = "Attack"})
	self:NumberCtrl("rumble_sustain", {min = -1, help = "Time to sustain maximum rumble", text = "Sustain"})
	self:NumberCtrl("rumble_release", {min = -1, help = "Time to decay from maximum rumble to zero", text = "Release"})
end

function EditorFeedback:_effect_options()
	return BLE.Utils:GetEntries({type = "effect", loaded = true})
end