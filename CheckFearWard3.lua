--[[
CheckFearWard3

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
CheckFearWard3 = LibStub("AceAddon-3.0"):NewAddon("CheckFearWard3", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L =  LibStub("AceLocale-3.0"):GetLocale("CheckFearWard3", false)
local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
local Tablet = AceLibrary("Tablet-2.0")
local CFW3, self = CheckFearWard3, CheckFearWard3

local MAJOR_VERSION = "3.1"
local MINOR_VERSION = 000 + tonumber(("$Revision: @project-revision@ $"):match("%d+"))
CheckFearWard3.version = MAJOR_VERSION .. "." .. MINOR_VERSION
CheckFearWard3.date = string.sub("$Date: @file-date-iso@ $", 1, 10)

--[[ Locals ]]--
local ipairs = ipairs
local pairs = pairs
local find = string.find
local formatIt = string.format
local time = time
local mod = mod
local buffSearchString = L["Fear Ward"]
local members = {}
local currentHigh = 0
local currentLow = 180
local checkTotalWarded = 0
local inGroup = 0
local inRaid = 0
local initialscan = 1

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
		AttachMinimap = false,
		HideMinimapButton = false,
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
	AC:Print("CheckFearWard3 " .. MAJOR_VERSION .. "." .. MINOR_VERSION .. " Loaded!")

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
	InterfaceOptionsFrame_OpenToCategory(self.OptionsPanel.profiles)
	InterfaceOptionsFrame_OpenToCategory(self.OptionsPanel)
end

function CFW3:IsLoggedIn()
	-- LDB launcher
	if LDB then
		CheckFearWard3Launcher = LDB:NewDataObject("CheckFearWard3", {
			type = "launcher",
			icon = "Interface\\AddOns\\CheckFearWard3\\icon",
			OnClick = function(clickedframe, button)
				if (button == "RightButton") then
					CFW3:OpenOptions()
				else
					if(members == nil) then
						members = {};
					end
					for k in pairs(members) do
						if(members[k] ~= 0) then
							msg = buffSearchString.." ["..UnitName("player").."]: "..CFW3:CalculateTimeLeft(members[k])
							CFW3:AnnounceLostBuff(msg, unit)
						end
					end
				end
			end,
			OnTooltipShow = function(tt)
				tt:AddLine(CFW3:OnUpdateFuBarText())
				if(members == nil) then
					members = {};
				end
				local linesAdded = false
				for k in pairs(members) do
					if(members[k] ~= 0) then
						if(members[k] == -1) then
							tt:AddLine(k .. ": " .. L["Unknown"])
						else
							tt:AddLine(k .. ": " .. CFW3:CalculateTimeLeft(members[k]))
						end
						linesAdded = true;
					end
				end
				if linesAdded == false then
					tt:AddLine(L["No"] .. " "..buffSearchString.." " .. L["Buff"])
				end
			end,
		})
		if LDBIcon and not IsAddOnLoaded("Broker2FuBar") and not IsAddOnLoaded("FuBar") then
			LDBIcon:Register("CheckFearWard3", CheckFearWard3Launcher, db.MinimapIcon)
		end
	end

	-- Optional launcher support for LFBP-3.0 if present, this code is placed here so
	-- that it runs after all other addons have loaded since we don't embed LFBP-3.0
	-- Yes, this is one big hack since LFBP-3.0 is a Rock library, and we embed it
	-- via Ace3. OnEmbedInitialize() needs to be called manually.  --Omen
	if LibStub:GetLibrary("LibFuBarPlugin-3.0", true) and not IsAddOnLoaded("FuBar2Broker") then
		local LFBP = LibStub:GetLibrary("LibFuBarPlugin-3.0")
		LibStub("AceAddon-3.0"):EmbedLibrary(self, "LibFuBarPlugin-3.0")
		self:SetFuBarOption('hasIcon', true)
		self:SetFuBarOption('hasNoColor', true)
		self:SetFuBarOption('detachedTooltip', false)
		self:SetFuBarOption('iconPath', [[Interface\AddOns\CheckFearWard3\icon]])
		self:SetFuBarOption('defaultPosition', "CENTER")
		self:SetFuBarOption('tooltipType', "Tablet-2.0")
		self:SetFuBarOption('clickableTooltip', true)
		self:SetFuBarOption("configType", "None")
		LFBP:OnEmbedInitialize(self)
		function CFW3:OnFuBarClick(button)
			if (button == "RightButton") then
				CFW3:OpenOptions()
			else
				if(members == nil) then
					members = {};
				end
				for k in pairs(members) do
					if(members[k] ~= 0) then
						msg = buffSearchString.." ["..UnitName("player").."]: "..CFW3:CalculateTimeLeft(members[k])
						CFW3:AnnounceLostBuff(msg, unit)
					end
				end
			end
		end
		CFW3:UpdateFuBarPlugin()
		CFW3:UpdateFuBarSettings()
		CFW3:ScheduleRepeatingTimer("UpdateFuBarPlugin", 1)
		CFW3:ScheduleRepeatingTimer("OnDataUpdate", 1)
	end
end

function CFW3:UpdateFuBarSettings()
	if LibStub:GetLibrary("LibFuBarPlugin-3.0", true) then
		if CFW3.db.profile.HideMinimapButton then
			self:Hide()
		else
			self:Show()
			if self:IsFuBarMinimapAttached() ~= CFW3.db.profile.AttachMinimap then
				self:ToggleFuBarMinimapAttached()
			end
		end
	end
end

local function GetFuBarMinimapAttachedStatus(info)
	return CFW3:IsFuBarMinimapAttached() or CFW3.db.profile.HideMinimapButton
end

function CFW3:OnDataUpdate()
	local numraid = GetNumRaidMembers()
	local numparty = GetNumPartyMembers()
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

function CFW3:AnnounceLostBuff(msg, unit)
	local numraid = GetNumRaidMembers()
	local numparty = GetNumPartyMembers()
	if (CFW3.db.profile.dcf) then
		DEFAULT_CHAT_FRAME:AddMessage(msg, 1.0, 0.0, 0.0, 0.0, 53, 5.0)
	end
	if (CFW3.db.profile.ctra) then
		RaidNotice_AddMessage(RaidBossEmoteFrame,msg , ChatTypeInfo["RAID_WARNING"])
	end
	if (CFW3.db.profile.audible) then
		PlaySoundFile("Interface\\AddOns\\CheckFearWard3\\Alert.wav")
	end
	if (CFW3.db.profile.brd and CFW3.db.profile.bs) then
		SendChatMessage(msg, "SAY", ChatFrameEditBox.language, "CHANNEL")
	end
	if (CFW3.db.profile.brd and CFW3.db.profile.bp and numparty >= 1) then
		SendChatMessage(msg, "PARTY", ChatFrameEditBox.language, "CHANNEL")
	end
	if (CFW3.db.profile.brd and CFW3.db.profile.br and numraid >= 1) then
		SendChatMessage(msg, "RAID", ChatFrameEditBox.language, "CHANNEL")
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

function CFW3:OnUpdateFuBarText()
	local str = "";
	str = buffSearchString.." " .. L["Buff"] .. ": " .. checkTotalWarded;
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
	CFW3:SetFuBarText(str)
	return str
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
					'text2', L["Unknown"]
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
			'text', L["No"] .. " "..buffSearchString.." " .. L["Buff"]
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
