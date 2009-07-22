--[[
File Author: @file-author@
File Revision: @file-revision@
File Date: @file-date-iso@
]]--
local CheckFearWard3 = LibStub("AceAddon-3.0"):GetAddon("CheckFearWard3")
local L = LibStub("AceLocale-3.0"):GetLocale("CheckFearWard3")
local CFW3, self = CheckFearWard3, CheckFearWard3

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
            CFW3:UpdateFuBarPlugin()
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
          name = L["LDB Options"],
          args = {
            MinimapIcon = {
              type = "toggle",
              order = 1,
              name = "Show minimap button",
              desc = "Show the CFW3 minimap button",
              get = function(info) return not CFW3.db.profile.MinimapIcon.hide end,
              set = function(info, value)
                CFW3.db.profile.MinimapIcon.hide = not value
                if value then LDBIcon:Show("CheckFearWard3") else LDBIcon:Hide("CheckFearWard3") end
              end,
              hidden = function() return not LDBIcon end,
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
          },
        },
      },
    },  
  },
}