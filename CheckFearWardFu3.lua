local L = Rock("LibRockLocale-1.0"):GetTranslationNamespace("FuBar_CheckFearWardFu3")
local Tablet = AceLibrary("Tablet-2.0")

CheckFearWardFu3 = Rock:NewAddon("CheckFearWardFu3", "LibFuBarPlugin-3.0", "LibRockTimer-1.0", "LibRockDB-1.0", "LibRockConfig-1.0", "LibRockEvent-1.0", "LibRockHook-1.0")

CheckFearWardFu3.version = "3.0" .. string.sub("$Revision: 053 $", 12, -3)
CheckFearWardFu3.date = string.sub("$Date: 2008-11-25 00:00:00 -0800 (Tue, 25 Nov 2008) $", 8, 17)
CheckFearWardFu3:SetFuBarOption('hasIcon', true)
CheckFearWardFu3:SetFuBarOption('hasNoColor', true)
CheckFearWardFu3:SetFuBarOption('detachedTooltip', false)
CheckFearWardFu3:SetFuBarOption('iconPath', [[Interface\AddOns\FuBar_CheckFearWardFu3\icon]])
CheckFearWardFu3:SetFuBarOption('defaultPosition', "CENTER")
CheckFearWardFu3:SetFuBarOption('tooltipType', "Tablet-2.0")
CheckFearWardFu3:SetFuBarOption('clickableTooltip', true)

CheckFearWardFu3:SetDatabase("CheckFearWardFu3DB")
CheckFearWardFu3:SetDatabaseDefaults('profile', {
	showHighTime = false,
	showLowTime = false,
	dcf = false,
	ctra = false,
	audible = false,
	debug = false,
})

function CheckFearWardFu3:IsShowHighTime()
	return self.db.profile.showHighTime
end

function CheckFearWardFu3:ToggleShowHighTime()
	self.db.profile.showHighTime = not self.db.profile.showHighTime
	self:UpdateFuBarPlugin()
end

function CheckFearWardFu3:IsShowLowTime()
	return self.db.profile.showLowTime
end

function CheckFearWardFu3:ToggleShowLowTime()
	self.db.profile.showLowTime = not self.db.profile.showLowTime
	self:UpdateFuBarPlugin()
end

function CheckFearWardFu3:IsDebug()
	return self.db.profile.debug
end

function CheckFearWardFu3:ToggleDebug()
	self.db.profile.debug = not self.db.profile.debug
	self:UpdateFuBarPlugin()
end

function CheckFearWardFu3:IsDCF()
	return self.db.profile.dcf
end

function CheckFearWardFu3:ToggleDCF()
	self.db.profile.dcf = not self.db.profile.dcf
	self:UpdateFuBarPlugin()
end

function CheckFearWardFu3:IsCTRA()
	return self.db.profile.ctra
end

function CheckFearWardFu3:ToggleCTRA()
	self.db.profile.ctra = not self.db.profile.ctra
	self:UpdateFuBarPlugin()
end

function CheckFearWardFu3:IsAudible()
	return self.db.profile.audible
end

function CheckFearWardFu3:ToggleAudible()
	self.db.profile.audible = not self.db.profile.audible
	self:UpdateFuBarPlugin()
end

function CheckFearWardFu3:OnInitialize()
local optionsTable = {
		name = "FuBar_CheckFearWardFu3",
		desc = self.notes,
		handler = CheckFearWardFu3,
    type='group',
    args = {
			showHighTime = {
				type = 'toggle',
				name = L["SHT"],
				desc = L["SHTD"],
				get = "IsShowHighTime",
				set = "ToggleShowHighTime",
			},
			showLowTime = {
				type = 'toggle',
				name = L["SLT"],
				desc = L["SLTD"],
				get = "IsShowLowTime",
				set = "ToggleShowLowTime",
			},
			debug = {
				type = 'toggle',
				name = L["debug"],
				desc = L["debugD"],
				get = "IsDebug",
				set = "ToggleDebug",
				hidden = true,
			},
			statusNotification = {
				type = 'group',
				name = L["SN"],
				desc = L["SND"],
				args = {
					dcf = {
						type = 'toggle',
						name = L["DCF"],
			      desc = L["DCFD"],
			      get = "IsDCF",
			      set = "ToggleDCF",
					},
          ctra = {
						type = 'toggle',
						name = L["CTRA"],
			      desc = L["CTRAD"],
			      get = "IsCTRA",
			      set = "ToggleCTRA",
					},
          audible = {
						type = 'toggle',
			      name = L["AUD"],
			      desc = L["AUDD"],
			      get = "IsAudible",
			      set = "ToggleAudible",
					},
				}
			},
		},
	}
	self.buffSearchString = "Fear Ward"
	CheckFearWardFu3:SetConfigTable(optionsTable)
	CheckFearWardFu3.OnMenuRequest = optionsTable
end

function CheckFearWardFu3:OnEnable()
	self.members = {}
	self.currentHigh = 0
	self.currentLow = 180
	self.checkTotalWarded = 0
	self.inGroup = 0
	self.inRaid = 0
	self.initialscan = 1
	self:FubarUpdates()
end

function CheckFearWardFu3:FubarUpdates()
	self:UpdateFuBarPlugin()
	self:AddRepeatingTimer(1, "UpdateFuBarPlugin")
	self:AddRepeatingTimer(1, "OnDataUpdate")
end

function CheckFearWardFu3:OnDataUpdate()
	local numraid = GetNumRaidMembers()
	local numparty = GetNumPartyMembers()
	self.currentHigh = 0
	self.currentLow = 180
	self.checkTotalWarded = 0
	if(numraid > 1) then
		self.inRaid = 1;
		self.inGroup = 0;
	elseif(numparty > 1) then
		if(self.inRaid == 1) then
			self.members = {};
		end
		self.inRaid = 0;
		self.inGroup = 1;
	else
		if(self.inRaid == 1 or self.inGroup == 1) then
			self.members = {};
		end
		self.inRaid = 0;
		self.inGroup = 0;
	end
	if(self.inRaid == 1) then
		for i=1, numraid do
			local member_unit = "raid"..i;
			self:CheckStatus(member_unit);
		end
	else
		if(self.inGroup == 1) then
			for i=1, numparty do
				local member_unit = "party"..i;
				self:CheckStatus(member_unit);
			end
		end
		self:CheckStatus("player");
	end
	self.initialscan = 0;
end

function CheckFearWardFu3:CheckStatus(unit)
	local buffFound = CheckFearWardFu3:CheckBuffPresent(unit);
	if(members == nil) then
		members = {};
	end
	if(UnitName(unit) ~= nil) then
		if(buffFound == 1) then
			-- Debug
			if self:IsDebug() then
				DEFAULT_CHAT_FRAME:AddMessage("Debug: CheckStatus()", 1.0, 0.0, 0.0, 0.0, 53, 5.0)
			end
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
				CheckFearWardFu3:AnnounceLostBuff(unit);
				members[UnitName(unit)] = 0;
			end
		end
	end
		if(members[UnitName(unit)] > 0 or members[UnitName(unit)] == -1) then
			self.checkTotalWarded = self.checkTotalWarded + 1;
		end
		if((time() - members[UnitName(unit)]) > self.currentHigh) then
			self.currentHigh = members[UnitName(unit)];
		end
		if((time() - members[UnitName(unit)]) < self.currentLow) then
			self.currentLow = members[UnitName(unit)];
		end
end

function CheckFearWardFu3:AnnounceLostBuff(unit)
	if (self:IsDCF()) then
		DEFAULT_CHAT_FRAME:AddMessage("*** "..UnitName(unit).." has lost their FEARWARD! ***", 1.0, 0.0, 0.0, 0.0, 53, 5.0)
	end
	if (self:IsCTRA()) then
		RaidNotice_AddMessage(RaidBossEmoteFrame,"*** "..UnitName(unit).." has lost their FEARWARD! ***", ChatTypeInfo["RAID_WARNING"])
	end
	if (self:IsAudible()) then
		PlaySoundFile("Interface\\AddOns\\FuBar_CheckFearWardFu3\\Alert.wav")
	end
end
		
function CheckFearWardFu3:CheckBuffPresent(unit)
	local buffFound = 0
	local buffIttr = 1
	while (UnitBuff(unit, buffIttr)) do
		if (string.find(UnitBuff(unit,buffIttr), self.buffSearchString)) then
			-- Debug
			if self:IsDebug() then
				DEFAULT_CHAT_FRAME:AddMessage("Debug: CheckBuffPresent()", 1.0, 0.0, 0.0, 0.0, 53, 5.0)
			end
			buffFound = 1			
		end
			buffIttr = buffIttr + 1
		end
  return buffFound
end

function CheckFearWardFu3:OnUpdateFuBarText()
	local str = "";
	str = "Fear Ward's: " .. self.checkTotalWarded;
	if(self.currentHigh ~= 0) then
		if(self:IsShowHighTime() and not self:IsShowLowTime()) then
			local highMinutes = CheckFearWardFu3:CalculateTimeLeft(self.currentHigh)
			str = str .. string.format("%s"," - High: " .. highMinutes)
		end
		if(self:IsShowLowTime() and not self:IsShowHighTime()) then
			local lowMinutes = CheckFearWardFu3:CalculateTimeLeft(self.currentLow)
			str = str .. string.format("%s"," - Low: " .. lowMinutes)
		end
		if(self:IsShowLowTime() and self:IsShowHighTime()) then
			local lowMinutes = CheckFearWardFu3:CalculateTimeLeft(self.currentLow)
			local highMinutes = CheckFearWardFu3:CalculateTimeLeft(self.currentHigh)
			str = str .. string.format("%s || %s"," - Low: "..lowMinutes, "High: " .. highMinutes)
		end
	end
	self:SetFuBarText(str)
end

function CheckFearWardFu3:OnUpdateFuBarTooltip()
	local cat = Tablet:AddCategory(
		'columns', 2,
		'child_textR', 1,
		'child_textG', 1,
		'child_textB', 0,
		'child_text2R', 1,
		'child_text2G', 1,
		'child_text2B', 1
	)
	if(members == nil) then
		members = {};
	end
	local linesAdded = false
	for k in pairs(members) do
		if(members[k] ~= 0) then
			if(members[k] == -1) then
				cat:AddLine(
					'text',k..": ",
					'text2', "Unknown"
					)
			else
				cat:AddLine(
					'text',k..": ",
					'text2', CheckFearWardFu3:CalculateTimeLeft(members[k])
					) 
			end
			linesAdded = true;
		end
	end		
	if linesAdded == false then
		cat:AddLine(
			'text', L["BUFF"]
			)
	end
end

function CheckFearWardFu3:CalculateTimeLeft(recordedTime)
	local elapsedSeconds = time() - recordedTime
	local totalSeconds = 180 - elapsedSeconds
	local leftoverSeconds = mod(totalSeconds,60)
	local totalMinutes = (totalSeconds - leftoverSeconds) / 60
	local secondsString = ""
	local minutesString = ""
	if(recordedTime == -1) then
		return "Unknown";
	end
	if(leftoverSeconds < 10) then
		secondsString = "0"..leftoverSeconds
	else
		secondsString = leftoverSeconds
	end
	if(totalMinutes == 0) then
		minutesString = "00"
	else
		minutesString = totalMinutes
	end
  return minutesString..":"..secondsString
end
