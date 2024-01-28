UpperMenu = UpperMenu or class(EditorPart)
function UpperMenu:get_menu_h() return self._menu:Panel():parent():h() - self._menu.h - 1 end
function UpperMenu:init(parent, menu)
    self._parent = parent
    local normal = not Global.editor_safe_mode
    self._tabs = {
        {name = "world", icon = "upper_world"},
        {name = "static", icon = "upper_static", enabled = normal},
        {name = "spawn", icon = "upper_spawn", enabled = normal},
        {name = "select", icon = "upper_select", enabled = normal},
        {name = "tools", icon = "upper_tools", enabled = normal},
        {name = "opt", icon = "upper_opt"},
        {name = "save", icon = "upper_save", callback = ClassClbk(self, "save"), enabled = normal},
    }
    local w = BLE.Options:GetValue("MapEditorPanelWidth")
    self._menu = menu:Menu({
        name = "upper_menu",
        background_color = BLE.Options:GetValue("BackgroundColor"),
        accent_color = BLE.Options:GetValue("AccentColor"),
        w = w,
        position = BLE.Options:GetValue("GUIOnRight") and "Right" or nil,
        h = 300 / #self._tabs - 4,
        auto_foreground = true,
        offset = 0,
        align_method = "centered_grid",
        scrollbar = false,
        visible = true,
    })
    self._tab_size = self._menu:ItemsWidth(#self._tabs) / #self._tabs
    ItemExt:add_funcs(self)
end

function UpperMenu:build_tabs()
    local icons = BLE.Utils.EditorIcons or {}
    for _, tab in pairs(self._tabs) do
        local s = self._menu:H()
        local t = self:Tab(tab.name, icons.texture, icons[tab.icon], tab.callback, s, tab.enabled)
        if tab.name:match("_widget_toggle") then
            self:update_toggle(t)
        end
    end
end

function UpperMenu:Tab(name, texture, texture_rect, clbk, s, enabled)
    return self._menu:ImageButton({
        name = name,
        texture = texture,
        texture_rect = texture_rect,
        is_page = not clbk,
        enabled = enabled,
        cannot_be_enabled = enabled == false,
        on_callback = ClassClbk(self, "select_tab", name, clbk or false),
        disabled_alpha = 0.2,
        w = self._tab_size,
        h = self._menu:H(),
        icon_w = s - 12,
        icon_h = s - 12,
    })
end

function UpperMenu:select_tab(tab, clbk, item)
    item = item or self._menu:GetItem(tab)
    if clbk then
        clbk(item)
    else
        self:Switch(BLE.Utils:GetPart(item.name))
    end
end

function UpperMenu:is_tab_enabled(manager)
    local item = self:GetItem(manager)
    if item then
        return item:Enabled()
    end
    return true
end

function UpperMenu:set_tabs_enabled(enabled)
    for manager in pairs(self._parent.parts) do
        local item = self:GetItem(manager)
        if item and not item.cannot_be_enabled then
            item:SetEnabled(enabled)
        end
    end
end

function UpperMenu:Switch(manager, no_anim)
    if not self:is_tab_enabled(manager.manager_name) then
        return
    end

    local item = self:GetItem(manager.manager_name)
    local menu = manager._menu

    if self._parent._current_menu then
        self._parent._current_menu:SetVisible(false)
    end
    self._parent._current_menu = menu
    self._parent._current_menu_name = item.name
    menu:SetVisible(true)
    for _, it in pairs(self._menu:Items()) do
        it:SetBorder({bottom = it == item})
    end
end

function UpperMenu:save()
    self._parent:Log("Saving Map..")
    BLE.Utils:GetPart("opt"):save()
end

function UpperMenu:enable()
    UpperMenu.super.enable(self)
    self:bind_opt("WorldMenu", ClassClbk(self, "select_tab", "world"))
    self:bind_opt("SelectionMenu", ClassClbk(self, "select_tab", "static"))
    self:bind_opt("SpawnMenu", ClassClbk(self, "select_tab", "spawn"))
    self:bind_opt("SelectMenu", ClassClbk(self, "select_tab", "select"))
    self:bind_opt("ToolsMenu", ClassClbk(self, "select_tab", "tools"))
    self:bind_opt("OptionsMenu", ClassClbk(self, "select_tab", "opt"))
end