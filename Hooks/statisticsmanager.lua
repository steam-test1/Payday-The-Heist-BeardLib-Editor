function StatisticsManager:start_session(data)
	if self._session_started then
		return
	end
	-- if Global.level_data.level_id then
	-- 	self._global.sessions.levels[Global.level_data.level_id].started = self._global.sessions.levels[Global.level_data.level_id].started + 1
	-- 	self._global.sessions.levels[Global.level_data.level_id].from_beginning = self._global.sessions.levels[Global.level_data.level_id].from_beginning + (data.from_beginning and 1 or 0)
	-- 	self._global.sessions.levels[Global.level_data.level_id].drop_in = self._global.sessions.levels[Global.level_data.level_id].drop_in + (data.drop_in and 1 or 0)
	-- end
	self._global.session = deep_clone(self._defaults)
	self._global.sessions.count = self._global.sessions.count + 1
	self._start_session_time = Application:time()
	self._start_session_from_beginning = data.from_beginning
	self._start_session_drop_in = data.drop_in
	self._session_started = true
end
function StatisticsManager:stop_session(data)
	if not self._session_started then
		return
	end
	self:_flush_log()
	self._data_log = nil
	self._session_started = nil
	local success = data and data.success
	local session_time = Application:time() - self._start_session_time
	-- if Global.level_data.level_id then
	-- 	self._global.sessions.levels[Global.level_data.level_id].time = self._global.sessions.levels[Global.level_data.level_id].time + session_time
	-- 	if success then
	-- 		self._global.sessions.levels[Global.level_data.level_id].completed = self._global.sessions.levels[Global.level_data.level_id].completed + 1
	-- 	else
	-- 		self._global.sessions.levels[Global.level_data.level_id].quited = self._global.sessions.levels[Global.level_data.level_id].quited + 1
	-- 	end
	-- end
	self._global.sessions.time = self._global.sessions.time + session_time
	self._global.session.sessions.time = session_time
	self._global.last_session = deep_clone(self._global.session)
	self:_calculate_average()
	managers.challenges:session_stopped({
		success = success,
		from_beginning = self._start_session_from_beginning,
		drop_in = self._start_session_drop_in,
		last_session = self._global.last_session
	})
	managers.challenges:reset("session")
	if SystemInfo:platform() == Idstring("WIN32") then
		self:publish_to_steam(self._global.session, success)
	end
end