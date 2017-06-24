--[[
File Author: @file-author@
File Revision: @file-abbreviated-hash@
File Date: @file-date-iso@
]]--
local CheckFearWard3 = LibStub("AceAddon-3.0"):GetAddon("CheckFearWard3")
local L = LibStub("AceLocale-3.0"):GetLocale("CheckFearWard3")
local CFW3 = CheckFearWard3

local sub = string.sub

options = {
  name = CFW3.name,
  desc = L["DESC"],
  handler = CheckFearWard3,
  type='group',
  args = {
    generalGroup = {
      type = "group",
      name = CFW3.name,
      childGroups = 'tab',
      args = {
				mainHeader = {
					type = "description",
					name = "  " .. L["Addon"] .. "\n  " .. CFW3.version .. "\n  " .. sub(CFW3.date,6,7) .. "-" .. sub(CFW3.date,9,10) .. "-" .. sub(CFW3.date,1,4),
					order = 1,
					image = "Interface\\Icons\\spell_holy_excorcism",
					imageWidth = 32, imageHeight = 32,
				},
        turnOn = {
          type = 'toggle',
          order = 1,
          width = "full",
          name = L["TurnOn"],
          desc = L["TurnOnDesc"],
          get = function() return CFW3.db.profile.turnOn end,
          set = function()
            if (CFW3.db.profile.turnOn == false) then
              print("|cFF33FF99CheckFearWard3|r: " .. CheckFearWard3.version .. " |cff00ff00Enabled|r")
              CFW3.db.profile.turnOn = not CFW3.db.profile.turnOn
            else
              print("|cFF33FF99CheckFearWard3|r: " .. CheckFearWard3.version .. " |cffff8080Disabled|r")
              CFW3.db.profile.turnOn = not CFW3.db.profile.turnOn
            end
          end,
        },
        debug = {
          type = 'toggle',
          order = 2,
          width = "full",
          name = L["debug"],
          desc = L["debugD"],
          get = function() return CFW3.db.profile.debug end,
          set = function()
            CFW3.db.profile.debug = not CFW3.db.profile.debug
          end,
          hidden = function() return CFW3.db.profile.debug end,
        },
        statusNotification = {
          type = 'group',
          order = 1,
          disabled = function() return not CFW3.db.profile.turnOn end,
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
                  width = "full",
                  name = L["BROD"],
                  desc = L["BRODD"],
                  get = function() return CFW3.db.profile.brd end,
                  set = function()
                    CFW3.db.profile.brd = not CFW3.db.profile.brd
                  end,
                },
                chat = {
                  type = 'toggle',
                  order = 2,
                  width = "full",
                  disabled = function() return not CFW3.db.profile.brd end,
                  name = L["BS"],
                  desc = L["BSD"],
                  get = function() return CFW3.db.profile.bs end,
                  set = function()
                    CFW3.db.profile.bs = not CFW3.db.profile.bs
                  end,
                },
                party = {
                  type = 'toggle',
                  order = 3,
                  width = "full",
                  disabled = function() return not CFW3.db.profile.brd end,
                  name = L["BP"],
                  desc = L["BPD"],
                  get = function() return CFW3.db.profile.bp end,
                  set = function()
                    CFW3.db.profile.bp = not CFW3.db.profile.bp
                  end,
                },
                raid = {
                  type = 'toggle',
                  order = 4,
                  width = "full",
                  disabled = function() return not CFW3.db.profile.brd end,
                  name = L["BR"],
                  desc = L["BRD"],
                  get = function() return CFW3.db.profile.br end,
                  set = function()
                    CFW3.db.profile.br = not CFW3.db.profile.br
                  end,
                },
              },
            },
            dcf = {
              type = 'toggle',
              order = 1,
              width = "full",
              name = L["DCF"],
              desc = L["DCFD"],
              get = function() return CFW3.db.profile.dcf end,
              set = function()
                CFW3.db.profile.dcf = not CFW3.db.profile.dcf
              end,
            },
            ctra = {
              type = 'toggle',
              order = 2,
              width = "full",
              name = L["CTRA"],
              desc = L["CTRAD"],
              get = function() return CFW3.db.profile.ctra end,
              set = function()
                CFW3.db.profile.ctra = not CFW3.db.profile.ctra
              end,
            },
            audible = {
              type = 'toggle',
              order = 3,
              width = "full",
              name = L["AUD"],
              desc = L["AUDD"],
              get = function() return CFW3.db.profile.audible end,
              set = function()
                CFW3.db.profile.audible = not CFW3.db.profile.audible
              end,
            },
          },
        },
        LDBOptions = {
          type = 'group',
          order = 2,
          disabled = function()
            if (LibStub:GetLibrary("LibDataBroker-1.1", true)) then
              return false
            else
              return true
            end
          end,
          name = L["LDB Options"],
          args = {
            MinimapIcon = {
              type = "toggle",
              order = 1,
              width = "full",
              name = L["Show minimap button"],
              desc = L["Show the CFW3 minimap button"],
              get = function(info) return not CFW3.db.profile.MinimapIcon.hide end,
              set = function(info, value)
                local LDBIcon = LibStub("LibDBIcon-1.0")
                CFW3.db.profile.MinimapIcon.hide = not value
                if value then LDBIcon:Show("CheckFearWard3") else LDBIcon:Hide("CheckFearWard3") end
              end,
              disabled = function()
                if (LibStub:GetLibrary("LibDBIcon-1.0", true)) then
                  return false
                else
                  return true
                end
              end,             
            },
            showHighTime = {
              type = 'toggle',
              order = 2,
              name = L["SHT"],
              desc = L["SHTD"],
              get = function() return CFW3.db.profile.showHighTime end,
              set = function()
                CFW3.db.profile.showHighTime = not CFW3.db.profile.showHighTime
              end,
            },
            showLowTime = {
              type = 'toggle',
              order = 3,
              width = "double",
              name = L["SLT"],
              desc = L["SLTD"],
              get = function() return CFW3.db.profile.showLowTime end,
              set = function()
                CFW3.db.profile.showLowTime = not CFW3.db.profile.showLowTime
              end,
            },
             HeaderFont = {
              type = 'range',
              order = 4,
              width = "double",
							min = 10,
							max = 24,
							step = 1.00,
              name = L["LDB Header Font Size"],
              desc = L["LDB Header Font Size"],
              get = function(info) return CFW3.db.profile.HeaderFont or 14 end,
              set = function(info,v) CFW3.db.profile.HeaderFont = v end,
            },
            ContentFont = {
              type = 'range',
              order = 5,
              width = "double",
							min = 10,
							max = 24,
							step = 1.00,
              name = L["LDB Content Font Size"],
              desc = L["LDB Content Font Size"],
              get = function(info) return CFW3.db.profile.ContentFont or 12 end,
              set = function(info,v) CFW3.db.profile.ContentFont = v end,
            },
          },
        },
      },
    },  
  },
}
