CheckFearWardFu = AceLibrary("AceAddon-2.0"):new("FuBarPlugin-2.0", "AceConsole-2.0", "AceDB-2.0", "AceEvent-2.0", "AceHook-2.1")
-- variables
local L = AceLibrary("AceLocale-2.2"):new("CheckFearWardFu")
local tablet = AceLibrary:HasInstance("Tablet-2.0") and AceLibrary("Tablet-2.0")
local dewdrop = AceLibrary("Dewdrop-2.0")

CheckFearWardFu.hasIcon = "Interface\\AddOns\\" .. CheckFearWardFu.folderName .. "\\icon"
CheckFearWardFu.defaultPosition = "LEFT"

CheckFearWardFu:RegisterDB("CheckFearWardFuDB")
local options = {
    type='group',
    args = {
		show_high = {
			type = "toggle",
			name = L["Show high time"],
			desc = L["Show high time in FuBar text"],
			get = function() return CheckFearWardFu.db.profile.showHigh end,
			set = function()
				CheckFearWardFu.db.profile.showHigh = not CheckFearWardFu.db.profile.showHigh
				CheckFearWardFu:Update()
			end,
		},
		show_low = {
			type = "toggle",
			name = L["Show low time"],
			desc = L["Show low time in FuBar text"],
			get = function() return CheckFearWardFu.db.profile.showLow end,
			set = function()
				CheckFearWardFu.db.profile.showLow = not CheckFearWardFu.db.profile.showLow
				CheckFearWardFu:Update()
			end,
		},
                statusNotification = {
			type = 'group',
			name = L["Status Notification"],
			desc = L["Where to show Fear Wards status notifications"],
			args = {
                              DCF = {
                                    type = "toggle",
			            name = L["Warn in Chat Window"],
			            desc = L["Warn in Blizzard default chat window"],
			            get = function() return CheckFearWardFu.db.profile.DCF end,
			            set = function()
			            	CheckFearWardFu.db.profile.DCF = not CheckFearWardFu.db.profile.DCF
			            	CheckFearWardFu:Update()
			            end,
		            },
                            CTRA = {
			            type = "toggle",
			            name = L["Warn in CTRA Style"],
			            desc = L["Warn in CT_RA raid warning style"],
			            get = function() return CheckFearWardFu.db.profile.CTRA end,
			            set = function()
			            	CheckFearWardFu.db.profile.CTRA = not CheckFearWardFu.db.profile.CTRA
			            	CheckFearWardFu:Update()
			            end,
		            },
                            audible = {
			            type = "toggle",
			            name = L["Audible Warning"],
			            desc = L["Enable Audible Warning on loss of Fear Ward"],
			            get = function() return CheckFearWardFu.db.profile.audible end,
			            set = function()
			            	CheckFearWardFu.db.profile.audible = not CheckFearWardFu.db.profile.audible
			            	CheckFearWardFu:Update()
			            end,
		            },
                        }
                  },

	},
}
CheckFearWardFu:RegisterChatCommand({"/fwfu"}, options)


	-- Methods
function CheckFearWardFu:IsShowingHigh()
	return self.db.profile.showHigh
end

function CheckFearWardFu:ToggleShowingHigh()
	self.db.profile.showHigh = not self.db.profile.showHigh
	self:Update()
	return self.db.profile.showHigh
end

function CheckFearWardFu:IsShowingLow()
	return self.db.profile.showLow
end

function CheckFearWardFu:ToggleShowingLow()
	self.db.profile.showLow = not self.db.profile.showLow
	self:Update()
	return self.db.profile.showLow
end

function CheckFearWardFu:IsDCF()
	return self.db.profile.DCF
end

function CheckFearWardFu:ToggleDCF()
	self.db.profile.DCF = not self.db.profile.DCF
	self:Update()
	return self.db.profile.DCF
end

function CheckFearWardFu:IsCTRA()
	return self.db.profile.CTRA
end

function CheckFearWardFu:ToggleCTRA()
	self.db.profile.CTRA = not self.db.profile.CTRA
	self:Update()
	return self.db.profile.CTRA
end

function CheckFearWardFu:Isaudible()
	return self.db.profile.audible
end

function CheckFearWardFu:Toggleaudible()
	self.db.profile.audible = not self.db.profile.audible
	self:Update()
	return self.db.profile.audible
end

function CheckFearWardFu:OnInitialize()
		self.BUFF_SEARCH_STRING = "Fear Ward"
end

function CheckFearWardFu:OnEnable()
	self.members = {}
	self.current_high = 0
	self.current_low = 999999999999
	self.CHKWARD_TOTAL_WARDED = 0
	self.INRAID = 0;
	self.INGROUP = 0;
	self.initialscan = 1;
	self:ScheduleRepeatingEvent("UpdateSelf",self.Update,1,self);
end

CheckFearWardFu.OnMenuRequest = options
function CheckFearWardFu:announce_lost_buff(unit)
	if(CheckFearWardFu.db.profile.DCF == true) then
		DEFAULT_CHAT_FRAME:AddMessage("*** "..UnitName(unit).." has lost their FEARWARD! ***", 1, 1, 1, 1, 5)
        end
	if(CheckFearWardFu.db.profile.CTRA == true) then
		RaidWarningFrame:AddMessage("*** "..UnitName(unit).." has lost their FEARWARD! ***", 1, 1, 1, 1, 5)
        end
        if(CheckFearWardFu.db.profile.audible == true) then
                PlaySoundFile("Interface\\AddOns\\" .. CheckFearWardFu.folderName .. "\\Alert5.wav")
	end
end

function CheckFearWardFu:OnDataUpdate()
	local numraid = GetNumRaidMembers()
	local numparty = GetNumPartyMembers()
	self.current_high = 0
	self.current_low = 999999999999
	self.CHKWARD_TOTAL_WARDED = 0
	if(numraid > 1) then
		self.INRAID = 1;
		self.INGROUP = 0;
	elseif(numparty > 1) then
		if(self.INRAID == 1) then
			self.members = {};
		end
		self.INRAID = 0;
		self.INGROUP = 1;
	else
		if(self.INRAID == 1 or self.INGROUP == 1) then
			self.members = {};
		end
		self.INRAID = 0;
		self.INGROUP = 0;
	end
	if(self.INRAID == 1) then
		for i=1, numraid do
			local member_unit = "raid"..i;
			self:check_status(member_unit);
		end
	else
		if(self.INGROUP == 1) then
			for i=1, numparty do
				local member_unit = "party"..i;
				self:check_status(member_unit);
			end
		end
		self:check_status("player");
	end
	self.initialscan = 0;
end

function CheckFearWardFu:check_status(unit)
	local buff_found = CheckFearWardFu:check_buff_present(unit);
	if(members == nil) then
		members = {};
	end
	if(UnitName(unit) ~= nil) then
		if(buff_found == 1) then
			--SendChatMessage("A buff was found", "CHANNEL", nil, 4)
			if(members[UnitName(unit)] == nil) then
				if(self.initialscan == 0) then
					members[UnitName(unit)] = time();
				else
					members[UnitName(unit)] = -1;
				end
			else
				if(members[UnitName(unit)] == 0) then
					if(self.initialscan == 0) then
						members[UnitName(unit)] = time();
					else
						members[UnitName(unit)] = -1;
					end
				end
			end
		else
			if(members[UnitName(unit)] == nil) then
				members[UnitName(unit)] = 0;
			elseif(members[UnitName(unit)] ~= 0) then
				CheckFearWardFu:announce_lost_buff(unit);
				members[UnitName(unit)] = 0;
			end
		end
	end
		if(members[UnitName(unit)] > 0 or members[UnitName(unit)] == -1) then
			self.CHKWARD_TOTAL_WARDED = self.CHKWARD_TOTAL_WARDED + 1;
		end
		if((time() - members[UnitName(unit)]) > self.current_high) then
			self.current_high = members[UnitName(unit)];
		end
		if((time() - members[UnitName(unit)]) < self.current_low) then
			self.current_low = members[UnitName(unit)];
		end
end
		
function CheckFearWardFu:check_buff_present(unit)
	local buff_found = 0
	local buff_ittr = 1
	while (UnitBuff(unit, buff_ittr)) do
		if (string.find(UnitBuff(unit,buff_ittr), self.BUFF_SEARCH_STRING)) then
			buff_found = 1			
		end
			buff_ittr = buff_ittr + 1
		end
  return buff_found
end

function CheckFearWardFu:OnTextUpdate()
	local current_string = "";
	current_string = "Fear Ward's: "..self.CHKWARD_TOTAL_WARDED;
	if(self.current_high ~= 0) then
		if(self:IsShowingHigh()) then
			local high_minutes = CheckFearWardFu:calculate_time_left(self.current_high);
			current_string = current_string .. " High: "..high_minutes;
		end
		if(self:IsShowingLow()) then
			local low_minutes = CheckFearWardFu:calculate_time_left(self.current_low);
			current_string = current_string .. " Low: "..low_minutes;
		end
	end
	self:SetText(current_string);
end

function CheckFearWardFu:OnTooltipUpdate()
	local cat = tablet:AddCategory('columns', 2, 'child_textR', 0, 'child_textG', 1, 'child_textB', 0)
	local lines_added = false
	for k in pairs(members) do
		if(members[k] ~= 0) then
			if(members[k] == -1) then
				cat:AddLine('text',k..": ",'text2', "UNKNOWN");
			else
				cat:AddLine('text',k..": ",'text2', CheckFearWardFu:calculate_time_left(members[k]));
			end
			lines_added = true;
		end
	end		
	if lines_added == false then
		cat:AddLine('text', L["NO FEARWARDS"])
	end
end

function CheckFearWardFu:calculate_time_left(recorded_time)
	local elapsed_seconds = time() - recorded_time
	local total_seconds = 1800 - elapsed_seconds
	local leftover_seconds = mod(total_seconds,60)
	local total_minutes = (total_seconds - leftover_seconds) / 60
	local seconds_string = ""
	local minutes_string = ""
	if(recorded_time == -1) then
		return "UNKNOWN";
	end
	if(leftover_seconds < 10) then
		seconds_string = "0"..leftover_seconds
	else
		seconds_string = leftover_seconds
	end
	if(total_minutes == 0) then
		minutes_string = "00"
	else
		minutes_string = total_minutes
	end
  return minutes_string..":"..seconds_string
end