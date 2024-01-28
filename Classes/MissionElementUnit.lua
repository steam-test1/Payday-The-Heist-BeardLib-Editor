MissionElementUnit = MissionElementUnit or class()
function MissionElementUnit:init(unit)
    self._unit = unit

    local iconsize = EditorPart:Val("ElementsSize") or 32
    local root = self._unit:get_objects_by_type(Idstring("object3d"))[1]
    if root == nil then
        return
    end
    
    if self._noicon then
        managers.occlusion:remove_occlusion(self._unit)
    end

    self._gui = World:newgui()
    local pos = root:position() - Vector3(iconsize / 2, iconsize / 2, self._noicon and -unit:bounding_sphere_radius() + iconsize / 4 or 0)
    self._ws = self._gui:create_linked_workspace(iconsize / 2, iconsize / 2, root, pos, Vector3(iconsize, 0, 0), Vector3(0, iconsize, 0))
    self._ws:set_billboard(self._ws.BILLBOARD_BOTH)
    local colors = {
        Color("ffffff"),
        Color("0d449c"),
        Color("16b329"),
        Color("eec022"),
        Color("9519ca"),
        Color("d31f07"),
        Color("555555"),
        Color("ea34ca"),
        Color("179d9b"),
        Color("0c243e"),
        Color("2c2c2c"),
        Color("5fc16f"),
    }

    self._color = EditorPart:Val("RandomizedElementsColor") and colors[math.random(1, #colors)] or EditorPart:Val("ElementsColor")
    local texture, rect = BLE.Utils:GetElementIcon("default")
    local size = iconsize / 4
    local font_size = iconsize / 8
    self._icon = self._ws:panel():bitmap({
        texture = texture,
        texture_rect = rect,
        render_template = "OverlayVertexColorTextured",
        color = self._color,
        rotation = 360,
        visible = not self._noicon,
        y = font_size,
        x = font_size,
        w = size,
        h = size,
    }) 
    self._text = self._ws:panel():text({
        render_template = "OverlayVertexColorTextured",
        font = tweak_data.menu.pd2_large_font,
        font_size = font_size,
        w = iconsize / 2,
        h = font_size,
        rotation = 360,
        align = "center",
        color = self._color,
        text = "",
    })
    self._enabled = true
    self._visible = true
    self._text:set_bottom(self._icon:top() - font_size)
end

function MissionElementUnit:update_text(t, dt)
	if self.element and self._text and alive(self._text) then
        if EditorPart:Val("SimplifiedElementHeaders") then
            self._text:set_text("\n"..tostring(self.element.editor_name))
        else
            self._text:set_text(tostring(self.element.editor_name).."\n" .. tostring(self.element.id) .. " - " .. tostring(self.element.class):gsub("Element", ""))
        end
	end
end

function MissionElementUnit:update_icon()
    if self.element and self._icon and alive(self._icon) then
        local element_name = tostring(self.element.class):gsub("Element", "")
        local texture, texture_rect = BLE.Utils:GetElementIcon(element_name)

        local editor_color = self.element.editor_color or BLE.EditorOptions:get_element_color(element_name)
        if editor_color and editor_color.len and editor_color:len() > 0 then
            self:set_color(Color:from_hex(editor_color))
        end

        if EditorPart:Val("UniqueElementIcons") and texture and texture_rect and not self._noicon then
            self._icon:set_image(texture, unpack(texture_rect))
            self._icon_outline = self._icon_outline or self._ws:panel():bitmap({
                texture = texture,
                texture_rect = texture_rect,
                render_template = "OverlayVertexColorTextured",
                color = Color.black,
                rotation = 360,
                layer = -1,
            }) 
            self._icon_outline:set_size(self._icon:w() * 1.1, self._icon:h() * 1.1)
            self._icon_outline:set_center(self._icon:center())
        end
    end
end
function MissionElementUnit:get_link_color()
    return self._color:unpack()
end

function MissionElementUnit:set_enabled(enabled, save)
    if save then
        self._enabled = enabled
    end
    self._visible = enabled and self._enabled
	if self._visible then
        self._ws:show()
	else
		self._ws:hide()
	end
    self._unit:set_enabled(self._visible)
end

function MissionElementUnit:visible()
    return self._visible
end

function MissionElementUnit:select()
    if self._icon_outline then
        self._icon_outline:set_color(self._color*2)
    else
        local _, rect = BLE.Utils:GetElementIcon("selected")
        self._icon:set_texture_rect(unpack(rect))
    end
end

function MissionElementUnit:unselect()
    if self._icon_outline then
        self._icon_outline:set_color(Color.black)
    else
        local _, rect = BLE.Utils:GetElementIcon("default")
        self._icon:set_texture_rect(unpack(rect))
    end
end

function MissionElementUnit:set_color(color)
    self._color = color
	self._icon:set_color(color)
	self._text:set_color(color)
end

function MissionElementUnit:destroy()
	self._gui:destroy_workspace(self._ws)
end
