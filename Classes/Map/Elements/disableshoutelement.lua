EditorDisableShout = EditorDisableShout or class(MissionScriptEditor)
EditorDisableShout.ELEMENT_FILTER = {"ElementSpawnCivilian", "ElementSpawnEnemyDummy"}
function EditorDisableShout:create_element()
    self.super.create_element(self)
	self._element.class = "ElementDisableShout"
	self._element.values.elements = {}
	self._element.values.disable_shout = true
end
function EditorDisableShout:_build_panel()
	self:_create_panel()
	self:BuildElementsManage("elements", nil, self.ELEMENT_FILTER)
	self:BooleanCtrl("disable_shout")
end
 