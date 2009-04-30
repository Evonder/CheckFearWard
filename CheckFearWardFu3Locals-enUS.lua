--[[
File Author: @file-author@
File Revision: @file-revision@
File Date: @file-date-iso@
]]--
local debug = false
--@debug@
debug = true
--@end-debug@

local L = Rock("LibRockLocale-1.0"):GetTranslationNamespace("FuBar_CheckFearWardFu3")
L:AddTranslations("enUS", function() return {
	["SHT"] = "Show high time",
	["SHTD"] = "Show high time in FuBar text",
	["SLT"] = "Show low time",
	["SLTD"] = "Show low time in FuBar text",
	["debug"] = "Debugging",
	["debugD"] = "Enable Debugging",
	["SN"] = "Status Notification",
	["SND"] = "Where to show Fear Wards status notifications",
	["DCF"] = "Warn in Chat Window",
	["DCFD"] = "Warn in Blizzard default chat window",
	["CTRA"] = "Warn in CT_RA Style",
	["CTRAD"] = "Warn in CT_RA raid warning style",
	["AUD"] = "Audible Warning",
	["AUDD"] = "Enable Audible Warning on loss of Fear Ward",
	["BUFF"] = "No Fear Wards",
} end)

--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true, handle-subnamespaces="concat")@
