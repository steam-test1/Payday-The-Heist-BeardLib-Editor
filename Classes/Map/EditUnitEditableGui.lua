EditUnitEditableGui = EditUnitEditableGui or class(EditUnit)
function EditUnitEditableGui:editable(unit)	return self.super.editable(self, unit) and unit:editable_gui() ~= nil end

function EditUnitEditableGui:build_menu(units)
	local gui_options = self:group("EditableGui")
	self._element_guis = {}
	local gui = units[1]:editable_gui()
	self._color = gui_options:colorbox("Color", ClassClbk(self, "set_unit_data_parent"), gui:font_color())
	self._text = gui_options:textbox("Text", ClassClbk(self, "set_unit_data_parent"), gui:text())
	self._font_size = gui_options:slider("FontSize", ClassClbk(self, "set_unit_data_parent"), gui:font_size(), {floats = 2, min = 0.1, max = 10, help = "Set the font size using the slider"})
end

function EditUnitEditableGui:set_unit_data()
	local unit = self:selected_unit()
	local gui = unit:editable_gui()
	gui:set_text(self._text:Value())
	gui:set_font_size(self._font_size:Value())
	gui:set_font_color(self._color:VectorValue())
end

function EditUnitEditableGui:update_positions()
	self:set_unit_data()
end