EditUnitEditableGui = EditUnitEditableGui or class(EditUnit)
function EditUnitEditableGui:editable(unit)	return self.super.editable(self, unit) and unit:editable_gui() ~= nil end

function EditUnitEditableGui:build_menu(units)
	local gui_options = self:group("EditableGui")
	self._element_guis = {}
	self._aligns = {
		horizontal = {
			"left",
			"center",
			"right",
			"justified"
		},
		vertical = {
			"top",
			"center",
			"bottom"
		}
	}
	self._blend_modes = {
		"normal",
		"add",
		"mul",
		"mulx2",
		"sub",
		"darken",
		"lighten"
	}
	self._render_templates = {
		"diffuse_vc_decal",
		"Text",
		"OverlayVertexColorTextured",
		"TextDistanceField",
		"diffuse_vc_decal_distance_field"
	}
	local gui = units[1]:editable_gui()
	self._color = gui_options:colorbox("Color", ClassClbk(self, "set_unit_data_parent"), gui:font_color())
	self._text = gui_options:textbox("Text", ClassClbk(self, "set_unit_data_parent"), gui:text())
	self._font_size = gui_options:slider("FontSize", ClassClbk(self, "set_unit_data_parent"), gui:font_size(), {floats = 2, min = 0.1, max = 10, help = "Set the font size using the slider"})
	self._horizontal_align = gui_options:combobox("HorizontalAlign", ClassClbk(self, "set_unit_data_parent"), self._aligns.horizontal, table.get_key(self._aligns.horizontal, gui:align()), {help = "Select an align from the combobox"})
	self._vertical_align = gui_options:combobox("VerticalAlign", ClassClbk(self, "set_unit_data_parent"), self._aligns.vertical, table.get_key(self._aligns.vertical, gui:vertical()), {help = "Select an align from the combobox"})
	self._wrapping = gui_options:tickbox("TextWrapping", ClassClbk(self, "set_unit_data_parent"), gui:wrap())
	self._word_wrapping = gui_options:tickbox("TextWordWrapping", ClassClbk(self, "set_unit_data_parent"), gui:word_wrap(), {enabled = gui:wrap()}) --
	self._debug = gui_options:tickbox("Debug", ClassClbk(self, "set_unit_data_parent"))
	self._render_template = gui_options:combobox("RenderTemplate", ClassClbk(self, "set_unit_data_parent"), self._render_templates, table.get_key(self._render_templates, gui:render_template()), {help = "Select a Render Template from the combobox"})
	self._blend_mode = gui_options:combobox("BlendMode", ClassClbk(self, "set_unit_data_parent"), self._blend_modes, table.get_key(self._blend_modes, gui:blend_mode()), {
		help = "Select a Blend Mode from the combobox",
		enabled = gui:render_template() == "Text",
	})
	self._alpha = gui_options:slider("Alpha", ClassClbk(self, "set_unit_data_parent"), gui:alpha(), {floats = 2, min = 0, max = 1, help = "Set the alpha using the slider"})
	self._shapes = {}
	for i, s in ipairs({"x", "y", "w", "h"}) do
		local shape = gui:shape()
		self._shapes[i] = gui_options:slider(s:upper(), ClassClbk(self, "set_unit_data_parent"), shape[i], {floats = 2, min = 0, max = 1, help = "Set shape using the slider"})
	end
end

function EditUnitEditableGui:set_unit_data()
	local unit = self:selected_unit()
	local gui = unit:editable_gui()
	gui:set_debug(self._debug:Value())
	gui:set_shape({self._shapes[1]:Value(), self._shapes[2]:Value(), self._shapes[3]:Value(), self._shapes[4]:Value()})
	gui:set_alpha(self._alpha:Value())
	local render_template = self._render_template:SelectedItem()
	self._blend_mode:SetEnabled(render_template == "Text")
	gui:set_render_template(render_template)
	gui:set_blend_mode(self._blend_mode:SelectedItem())
	local wrap = self._wrapping:Value()
	self._word_wrapping:SetEnabled(wrap)
	gui:set_wrap(wrap)
	gui:set_word_wrap(self._word_wrapping:Value())
	gui:set_align(self._horizontal_align:SelectedItem())
	gui:set_vertical(self._vertical_align:SelectedItem())
	gui:set_font(self._font:SelectedItem())
	gui:set_text(utf8.from_latin1(self._text:Value()))
	gui:set_font_size(self._font_size:Value())
	gui:set_font_color(self._color:VectorValue())
end

function EditUnitEditableGui:update_positions()
	self:set_unit_data()
end