--[[
CheckFearWardFu3

File Author: @file-author@
File Revision: @file-revision@
File Date: @file-date-iso@

* Copyright (c) 2008, Evonder
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the <organization> nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY <copyright holder> ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]--

local L = Rock("LibRockLocale-1.0"):GetTranslationNamespace("FuBar_CheckFearWardFu3")
local Tablet = AceLibrary("Tablet-2.0")

CheckFearWardFu3 = Rock:NewAddon("CheckFearWardFu3", "LibFuBarPlugin-3.0", "LibRockTimer-1.0", "LibRockDB-1.0", "LibRockConfig-1.0", "LibRockEvent-1.0", "LibRockHook-1.0")
local CFW3 = CheckFearWardFu3

local MAJOR_VERSION = "3.0"
local MINOR_VERSION = 000 + tonumber(("$Revision: @project-revision@ $"):match("%d+"))
CheckFearWardFu3.version = MAJOR_VERSION .. "." .. MINOR_VERSION
CheckFearWardFu3.date = string.sub("Date: @file-date-iso@", 1, 10)

CFW3:SetFuBarOption('hasIcon', true)
CFW3:SetFuBarOption('hasNoColor', true)
CFW3:SetFuBarOption('detachedTooltip', false)
CFW3:SetFuBarOption('iconPath', [[Interface\AddOns\FuBar_CheckFearWardFu3\icon]])
CFW3:SetFuBarOption('defaultPosition', "CENTER")
CFW3:SetFuBarOption('tooltipType', "Tablet-2.0")
CFW3:SetFuBarOption('clickableTooltip', true)

CFW3:SetDatabase("CheckFearWardFu3DB")
CFW3:SetDatabaseDefaults('profile', {
	showIcon = true,
	showText =  true,
	showHighTime = false,
	showLowTime = false,
	dcf = false,
	ctra = false,
	audible = false,
	debug = false,
})

function CFW3:IsShowHighTime()
	return self.db.profile.showHighTime
end

function CFW3:ToggleShowHighTime()
	self.db.profile.showHighTime = not self.db.profile.showHighTime
	self:UpdateFuBarPlugin()
end

function CFW3:IsShowLowTime()
	return self.db.profile.showLowTime
end

function CFW3:ToggleShowLowTime()
	self.db.profile.showLowTime = not self.db.profile.showLowTime
	self:UpdateFuBarPlugin()
end

function CFW3:IsDebug()
	return self.db.profile.debug
end

function CFW3:ToggleDebug()
	self.db.profile.debug = not self.db.profile.debug
	self:UpdateFuBarPlugin()
end

function CFW3:IsBRD()
	return self.db.profile.brd
end

function CFW3:ToggleBRD()
	self.db.profile.brd = not self.db.profile.brd
	self:UpdateFuBarPlugin()
end

function CFW3:IsBS()
	return self.db.profile.bs
end

function CFW3:ToggleBS()
	self.db.profile.bs = not self.db.profile.bs
	self:UpdateFuBarPlugin()
end

function CFW3:IsBP()
	return self.db.profile.bp
end

function CFW3:ToggleBP()
	self.db.profile.bp = not self.db.profile.bp
	self:UpdateFuBarPlugin()
end

function CFW3:IsBR()
	return self.db.profile.br
end

function CFW3:ToggleBR()
	self.db.profile.br = not self.db.profile.br
	self:UpdateFuBarPlugin()
end

function CFW3:IsDCF()
	return self.db.profile.dcf
end

function CFW3:ToggleDCF()
	self.db.profile.dcf = not self.db.profile.dcf
	self:UpdateFuBarPlugin()
end

function CFW3:IsCTRA()
	return self.db.profile.ctra
end

function CFW3:ToggleCTRA()
	self.db.profile.ctra = not self.db.profile.ctra
	self:UpdateFuBarPlugin()
end

function CFW3:IsAudible()
	return self.db.profile.audible
end

function CFW3:ToggleAudible()
	self.db.profile.audible = not self.db.profile.audible
	self:UpdateFuBarPlugin()
end

function CFW3:PostEnable()
	print("|cFF33FF99CheckFearWardFu3|r: " .. CheckFearWardFu3.version .. " |cff00ff00Enabled|r")
end

function CFW3:OnDisable()
	print("|cFF33FF99CheckFearWardFu3|r: " .. CheckFearWardFu3.version .. " |cffff8080Disabled|r")
end

local optionsTable = {
	name = "FuBar_CheckFearWardFu3",
	desc = L["DESC"],
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
			hidden = false,
		},
		statusNotification = {
			type = 'group',
			name = L["SN"],
			desc = L["SND"],
			args = {
				broadcast = {
					type = 'group',
					name = L["BRODG"],
					desc = L["BRODD"],
					args = {
						broadcast = {
							type = 'toggle',
							order = 1,
							name = L["BROD"],
							desc = L["BRODD"],
							get = "IsBRD",
							set = "ToggleBRD",
						},
						chat = {
							type = 'toggle',
							order = 2,
							disabled = function()
								return not CFW3:IsBRD()
							end,
							name = L["BS"],
							desc = L["BSD"],
							get = "IsBS",
							set = "ToggleBS",
						},
						party = {
							type = 'toggle',
							order = 3,
							disabled = function()
								return not CFW3:IsBRD()
							end,
							name = L["BP"],
							desc = L["BPD"],
							get = "IsBP",
							set = "ToggleBP",
						},
						raid = {
							type = 'toggle',
							order = 4,
							disabled = function()
								return not CFW3:IsBRD()
							end,
							name = L["BR"],
							desc = L["BRD"],
							get = "IsBR",
							set = "ToggleBR",
						},
					},
				},
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

function CFW3:OnInitialize()
	self.buffSearchString = "Fear Ward"
	CFW3:SetConfigTable(optionsTable)
	CFW3:SetConfigSlashCommand("/CFW")
	CFW3.OnMenuRequest = optionsTable
end

function CFW3:OnEnable()
	self.members = {}
	self.currentHigh = 0
	self.currentLow = 180
	self.checkTotalWarded = 0
	self.inGroup = 0
	self.inRaid = 0
	self.initialscan = 1
	CFW3:FubarUpdates()
	CFW3:AddTimer(0, "PostEnable")
end

function CFW3:FubarUpdates()
	CFW3:UpdateFuBarPlugin()
	CFW3:AddRepeatingTimer(1, "UpdateFuBarPlugin")
	CFW3:AddRepeatingTimer(1, "OnDataUpdate")
end

function CFW3:OnDataUpdate()
	local numraid = GetNumRaidMembers()
	local numparty = GetNumPartyMembers()
	self.currentHigh = 0
	self.currentLow = 180
	self.checkTotalWarded = 0
	if(numraid >= 1) then
		self.inRaid = 1;
		self.inGroup = 0;
	elseif(numparty >= 1) then
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
			CFW3:CheckStatus(member_unit);
		end
	else
		if(self.inGroup == 1) then
			for i=1, numparty do
				local member_unit = "party"..i;
				CFW3:CheckStatus(member_unit);
			end
		end
		CFW3:CheckStatus("player");
	end
	self.initialscan = 0;
end

function CFW3:CheckStatus(unit)
	local buffFound = CFW3:CheckBuffPresent(unit);
	local msg = "*** "..UnitName(unit).." has lost their "..self.buffSearchString.."! ***"
	if(members == nil) then
		members = {};
	end
	if(UnitName(unit) ~= nil) then
		if(buffFound == 1) then
			-- Debug
			if CFW3:IsDebug() then
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
				CFW3:AnnounceLostBuff(msg, unit);
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

function CFW3:OnFuBarClick(button)
	if(members == nil) then
		members = {};
	end
	for k in pairs(members) do
		if(members[k] ~= 0) then
			msg = self.buffSearchString.." ["..UnitName("player").."]: "..CFW3:CalculateTimeLeft(members[k])
			CFW3:AnnounceLostBuff(msg, unit)
		end
	end
end

function CFW3:AnnounceLostBuff(msg, unit)
	local numraid = GetNumRaidMembers()
	local numparty = GetNumPartyMembers()
	if (CFW3:IsDCF()) then
		DEFAULT_CHAT_FRAME:AddMessage(msg, 1.0, 0.0, 0.0, 0.0, 53, 5.0)
	end
	if (CFW3:IsCTRA()) then
		RaidNotice_AddMessage(RaidBossEmoteFrame,msg , ChatTypeInfo["RAID_WARNING"])
	end
	if (CFW3:IsAudible()) then
		PlaySoundFile("Interface\\AddOns\\FuBar_CheckFearWardFu3\\Alert.wav")
	end
	if (CFW3:IsBRD() and CFW3:IsBS()) then
		SendChatMessage(msg, "SAY", ChatFrameEditBox.language, "CHANNEL")
	end
	if (CFW3:IsBRD() and CFW3:IsBP() and numparty >= 1) then
		SendChatMessage(msg, "PARTY", ChatFrameEditBox.language, "CHANNEL")
	end
	if (CFW3:IsBRD() and CFW3:IsBR() and numraid >= 1) then
		SendChatMessage(msg, "RAID", ChatFrameEditBox.language, "CHANNEL")
	end
end

function CFW3:CheckBuffPresent(unit)
	local buffFound = 0
	local buffIttr = 1
	while (UnitBuff(unit, buffIttr)) do
		if (string.find(UnitBuff(unit,buffIttr), self.buffSearchString)) then
			-- Debug
			if CFW3:IsDebug() then
				DEFAULT_CHAT_FRAME:AddMessage("Debug: CheckBuffPresent()", 1.0, 0.0, 0.0, 0.0, 53, 5.0)
			end
			buffFound = 1
		end
			buffIttr = buffIttr + 1
		end
	return buffFound
end

function CFW3:OnUpdateFuBarText()
	local str = "";
	str = self.buffSearchString.." Buff: " .. self.checkTotalWarded;
	if(self.currentHigh ~= 0) then
		if(CFW3:IsShowHighTime() and not CFW3:IsShowLowTime()) then
			local highMinutes = CFW3:CalculateTimeLeft(self.currentHigh)
			str = str .. string.format("%s"," - High: " .. highMinutes)
		end
		if(CFW3:IsShowLowTime() and not CFW3:IsShowHighTime()) then
			local lowMinutes = CFW3:CalculateTimeLeft(self.currentLow)
			str = str .. string.format("%s"," - Low: " .. lowMinutes)
		end
		if(CFW3:IsShowLowTime() and CFW3:IsShowHighTime()) then
			local lowMinutes = CFW3:CalculateTimeLeft(self.currentLow)
			local highMinutes = CFW3:CalculateTimeLeft(self.currentHigh)
			str = str .. string.format("%s || %s"," - Low: "..lowMinutes, "High: " .. highMinutes)
		end
	end
	CFW3:SetFuBarText(str)
end

function CFW3:OnUpdateFuBarTooltip()
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
					'text2', CFW3:CalculateTimeLeft(members[k])
					)
			end
			linesAdded = true;
		end
	end
	if linesAdded == false then
		cat:AddLine(
			'text', "No "..self.buffSearchString.." Buff"
			)
	end
end

function CFW3:CalculateTimeLeft(recordedTime)
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
