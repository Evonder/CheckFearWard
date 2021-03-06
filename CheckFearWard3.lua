--[[
CheckFearWard3

File Author: @file-author@
File Revision: @file-abbreviated-hash@
File Date: @file-date-iso@

* Copyright (c) 2011, @file-author@
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
* THIS SOFTWARE IS PROVIDED BY @file-author@ ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL @file-author@ BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]--
local CheckFearWard3 = CheckFearWard3 or LibStub("AceAddon-3.0"):NewAddon("CheckFearWard3", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L =  LibStub("AceLocale-3.0"):GetLocale("CheckFearWard3")
local LibQTip = LibStub("LibQTip-1.0")
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LDB and LibStub("LibDBIcon-1.0")
local CFW3 = CheckFearWard3

--[[ Locals ]]--
local ipairs = ipairs
local pairs = pairs
local find = string.find
local formatIt = string.format
local len = string.len
local time = time
local mod = mod
local sub = string.sub
local buffSearchString = L["Fear Ward"]
local members = {}
local players = {}
local currentHigh = 0
local currentLow = 180
local checkTotalWarded = 0
local inGroup = 0
local inRaid = 0
local initialscan = 1
local launcher
local tooltip
local feedTimer
local tocVersion = select(4, GetBuildInfo())
local numraid = GetNumGroupMembers()
local numparty = GetNumSubgroupMembers()

local MAJOR_VERSION = GetAddOnMetadata("CheckFearWard3", "Version")
if (len(MAJOR_VERSION)<=6) then
	CFW3.version = sub(MAJOR_VERSION, 0, 6)
else
	CFW3.version = MAJOR_VERSION .. " DEV"
end
CFW3.date = GetAddOnMetadata("CheckFearWard3", "X-Date")

defaults = {
	profile = {
		turnOn = true,
		showIcon = true,
		showText =  true,
		showHighTime = false,
		showLowTime = false,
		dcf = false,
		ctra = false,
		audible = false,
		debug = true,
		HeaderFont = 14,
		ContentFont = 12,
		AttachMinimap = false,
		HideMinimapButton = false,
		MinimapIcon = {},
	},
}

function CFW3:OnInitialize()
	--[[ Libraries ]]--
	local ACD = LibStub("AceConfigDialog-3.0")
	local LAP = LibStub("LibAboutPanel")

	self.db = LibStub("AceDB-3.0"):New("CheckFearWard3DB", defaults);

	local ACP = LibStub("AceDBOptions-3.0"):GetOptionsTable(CheckFearWard3.db);

	local AC = LibStub("AceConsole-3.0")
	AC:RegisterChatCommand("cfw", function() CFW3:OpenOptions() end)
	AC:Print("CheckFearWard3 " .. CFW3.version .. " Loaded!")

	local ACR = LibStub("AceConfigRegistry-3.0")
	ACR:RegisterOptionsTable("CheckFearWard3", options)
	ACR:RegisterOptionsTable("CheckFearWard3P", ACP)

	-- Set up options panels.
	self.OptionsPanel = ACD:AddToBlizOptions(self.name, self.name, nil, "generalGroup")
	self.OptionsPanel.profiles = ACD:AddToBlizOptions("CheckFearWard3P", "Profiles", self.name)
	self.OptionsPanel.about = LAP.new(self.name, self.name)
	
	if IsLoggedIn() then
		self:IsLoggedIn()
	else
		self:RegisterEvent("PLAYER_LOGIN", "IsLoggedIn")
	end
end

-- :OpenOptions(): Opens the options window.
function CFW3:OpenOptions()
	InterfaceOptionsFrame_OpenToCategory(self.OptionsPanel)
end

function CFW3:IsLoggedIn()
	self:ScheduleRepeatingTimer("OnDataUpdate", 0.25)
	if LDB then	
		self.launcher = LDB:NewDataObject(L["CheckFearWard3"], {
			type = "data source",
			icon = "Interface\\Icons\\spell_holy_excorcism",
			label = "",
			value = OnTextUpdate,
			OnClick = OnClick,
			OnEnter = function(self)
				OnEnter(self)
			end,
			OnLeave = function(self)
				if tooltip and MouseIsOver(tooltip) then 
					tooltip:SetScript("OnUpdate", HideTooltips)
				else
					OnLeave(self)
				end
			end,
		})
		self.feedTimer = self:ScheduleRepeatingTimer("OnTextUpdate", 0.25)
			
		if LDBIcon then
			LDBIcon:Register("CheckFearWard3", self.launcher, self.db.profile.MinimapIcon)
		end
		self:OnTextUpdate()
	end
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "CheckFearWard_CL")
	self:UnregisterEvent("PLAYER_LOGIN")
end

function CFW3:OnDataUpdate()
	currentHigh = 0
	currentLow = 180
	checkTotalWarded = 0
	if(numraid >= 1) then
		inRaid = 1;
		inGroup = 0;
	elseif(numparty >= 1) then
		if(inRaid == 1) then
			members = {};
		end
		inRaid = 0;
		inGroup = 1;
	else
		if(inRaid == 1 or inGroup == 1) then
			members = {};
		end
		inRaid = 0;
		inGroup = 0;
	end
	if(inRaid == 1) then
		for i=1, numraid do
			local member_unit = "raid"..i;
			CFW3:CheckStatus(member_unit);
		end
	else
		if(inGroup == 1) then
			for i=1, numparty do
				local member_unit = "party"..i;
				CFW3:CheckStatus(member_unit);
			end
		end
		CFW3:CheckStatus("player");
	end
	initialscan = 0;
end

function CFW3:CheckStatus(unit)
	local buffFound = CFW3:CheckBuffPresent(unit);
	local msg = "*** "..UnitName(unit).." " .. L["has lost their"] .. " "..buffSearchString.."! ***"
	if(members == nil) then
		members = {};
	end
	if(UnitName(unit) ~= nil) then
		if(buffFound == 1) then
			if(members[UnitName(unit)] == nil) then
				if(initialscan == 0) then
					members[UnitName(unit)] = time();
				else
					members[UnitName(unit)] = -1;
				end
			else
				if(members[UnitName(unit)] == 0) then
					if(initialscan == 0) then
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
			checkTotalWarded = checkTotalWarded + 1;
		end
		if((time() - members[UnitName(unit)]) > currentHigh) then
			currentHigh = members[UnitName(unit)];
		end
		if((time() - members[UnitName(unit)]) < currentLow) then
			currentLow = members[UnitName(unit)];
		end
end

function CFW3:CheckBuffPresent(unit)
	local buffFound = 0
	local buffIttr = 1
	while (UnitBuff(unit, buffIttr)) do
		if (find(UnitBuff(unit,buffIttr), buffSearchString)) then
			buffFound = 1
		end
			buffIttr = buffIttr + 1
		end
	return buffFound
end

function CFW3:CalculateTimeLeft(recordedTime)
	local elapsedSeconds = time() - recordedTime
	local totalSeconds = 180 - elapsedSeconds
	local leftoverSeconds = mod(totalSeconds,60)
	local totalMinutes = (totalSeconds - leftoverSeconds) / 60
	local secondsString = ""
	local minutesString = ""
	if(recordedTime == -1) then
		return L["Unknown"];
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

function CFW3:AnnounceLostBuff(msg, unit)
	if (CFW3.db.profile.dcf) then
		DEFAULT_CHAT_FRAME:AddMessage(msg, 1.0, 0.0, 0.0, 0.0, 53, 5.0)
	end
	if (CFW3.db.profile.ctra) then
		RaidNotice_AddMessage(RaidBossEmoteFrame,msg , ChatTypeInfo["RAID_WARNING"])
	end
	if (CFW3.db.profile.audible) then
		PlaySoundFile("Interface\\AddOns\\CheckFearWard3\\Alert.mp3", "SFX")
	end
	if (CFW3.db.profile.brd and CFW3.db.profile.bs) then
		SendChatMessage(msg, "SAY", language, "CHANNEL")
	end
	if (CFW3.db.profile.brd and CFW3.db.profile.bp and numparty >= 1) then
		SendChatMessage(msg, "PARTY", language, "CHANNEL")
	end
	if (CFW3.db.profile.brd and CFW3.db.profile.br and numraid >= 1) then
		SendChatMessage(msg, "RAID", language, "CHANNEL")
	end
end

--[[ LDB ]]--
local function OnEnter(self)
	local headFont = CreateFont("headFont")
	headFont:SetFont(GameTooltipText:GetFont(), CFW3.db.profile.HeaderFont or 14)
	
	local contentFont = CreateFont("contentFont")
	contentFont:SetFont(GameTooltipText:GetFont(), CFW3.db.profile.ContentFont or 12)

	if tooltip then QTip:Release(tooltip) end
	local tooltip = LibStub('LibQTip-1.0'):Acquire('CFW3Tip', 2, "LEFT", "RIGHT")
	self.tooltip = tooltip
	tooltip:SetFont(contentFont)
  tooltip:SetHeaderFont(headFont)
	tooltip:AddHeader(L["CheckFearWard3"])
	if(members == nil) then
		members = {};
	end
	local linesAdded = false
	for k in pairs(members) do
		if(members[k] ~= 0) then
			if(members[k] == -1) then
				line = tooltip:AddLine(k .. ": ", L["Unknown"])
			else
				for j,v in pairs(players) do
					if find(v,k) then
						line = tooltip:AddLine(j .. " > " .. k .. ": ", CFW3:CalculateTimeLeft(members[k]))
					else
						line = tooltip:AddLine(k .. ": ", CFW3:CalculateTimeLeft(members[k]))
					end
				end
			end
			linesAdded = true;
		end
	end
	if linesAdded == false then
		line = tooltip:AddLine(L["No"] .. " "..buffSearchString.." " .. L["BUFF"], "")
	end
	tooltip:SmartAnchorTo(self)
	tooltip:Show()
end

local function OnLeave(self)
  LibQTip:Release(self.tooltip)
  self.tooltip = nil
end

local function OnClick(clickedframe, button)
	if (button == "RightButton") then
		self:OpenOptions()
	else
		if(members == nil) then
			members = {};
		end
		for k in pairs(members) do
			if(members[k] ~= 0) then
				msg = buffSearchString.." [".. k .."]: "..CFW3:CalculateTimeLeft(members[k])
				self:AnnounceLostBuff(msg, unit)
			end
		end
	end
end

function CFW3:OnTextUpdate()
	local str = "";
	str = buffSearchString.." " .. L["BUFF"] .. ": " .. checkTotalWarded;
	if(currentHigh ~= 0) then
		if(CFW3.db.profile.showHighTime and not CFW3.db.profile.showLowTime) then
			local highMinutes = CFW3:CalculateTimeLeft(currentHigh)
			str = str .. formatIt("%s"," - " .. L["High"] .. ": " .. highMinutes)
		end
		if(CFW3.db.profile.showLowTime and not CFW3.db.profile.showHighTime) then
			local lowMinutes = CFW3:CalculateTimeLeft(currentLow)
			str = str .. formatIt("%s"," - " .. L["Low"] .. ": " .. lowMinutes)
		end
		if(CFW3.db.profile.showLowTime and CFW3.db.profile.showHighTime) then
			local lowMinutes = CFW3:CalculateTimeLeft(currentLow)
			local highMinutes = CFW3:CalculateTimeLeft(currentHigh)
			str = str .. formatIt("%s || %s"," - " .. L["Low"] .. ": "..lowMinutes, L["High"] .. ": " .. highMinutes)
		end
	end
	self.launcher.text = str
	return str
end

function CFW3:CheckFearWard_CL(event, ...)
	local timestamp, combatEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool = select(1, ...)
	if (combatEvent == "SPELL_AURA_APPLIED" and find(spellName, buffSearchString)) then
		players[sourceName] = destName
	end
end
