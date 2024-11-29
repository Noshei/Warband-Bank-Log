---@class WBL : AceAddon-3.0, AceDB-3.0
local WBL = LibStub("AceAddon-3.0"):GetAddon("Warband-Bank-Log")

WBL.defaults = {
    profile = {
        xPos = 0,
        yPos = 0,
        relativePoint = "CENTER",
        timeFormat = 5,
        autoOpen = false,
        autoclose = false,
        minimap = {
            enable = true,
        }
    }
}

WBL.timeFormats = {
    "%H:%M",             --20:16
    "%I:%M %p",          --08:16 AM
    "%X",                --20:16:41
    "%I:%M:%S %p",       --08:16:41 AM
    "%c",                --Thu Nov 28 20:16:41 2024
    "%x %X",             --11/28/24 20:16:41
    "%m/%d/%Y %H:%M:%S", --11/28/2024 20:16:41
    "%b %d %Y %X",       --Nov 28 2024 20:16:41
    "%d %b %Y %X",       --28 Nov 2024 20:16:41
    "%Y-%m-%d %H:%M:%S", --2024-11-28 20:16:41
}

function WBL:GenerateSettingsMenu(frame)
    local function SettingsMenu(frame, rootDescription)
        rootDescription:SetTag("WarbandBankLog_Settings_Menu")
        frame.settings = {}

        frame.settings.autoOpen = rootDescription:CreateCheckbox("Auto Open with Bank",
            function() --Getter function
                return WBL.db.profile.autoOpen
            end,
            function() --Setter function
                WBL.db.profile.autoOpen = not WBL.db.profile.autoOpen
            end
        )
        frame.settings.autoClose = rootDescription:CreateCheckbox("Auto Close with Bank",
            function() --Getter function
                return WBL.db.profile.autoClose
            end,
            function() --Setter function
                WBL.db.profile.autoClose = not WBL.db.profile.autoClose
            end
        )
        frame.settings.minimap = rootDescription:CreateCheckbox("Minimap Icon",
            function() --Getter function
                return WBL.db.profile.minimap.enable
            end,
            function() --Setter function
                WBL.db.profile.minimap.enable = not WBL.db.profile.minimap.enable
                WBL:MinimapHandler(WBL.db.profile.minimap.enable)
            end
        )
        frame.settings.timeFormat = rootDescription:CreateButton("Time Format", function() end)
        local function IsSelected(index)
            return index == WBL.db.profile.timeFormat
        end
        local function SetSelected(index)
            WBL.db.profile.timeFormat = index
            if #WBL.Logs > 0 then
                WBL.DataProvider:Flush()
                WBL.DataProvider:InsertTable(WBL.Logs)
            end
        end
        frame.settings.timeFormat.options = {}
        for index, format in ipairs(WBL.timeFormats) do
            frame.settings.timeFormat.options[index] = frame.settings.timeFormat:CreateRadio(date(format, 1732849485), IsSelected, SetSelected, index)
        end
    end

    WBL.Display.Menu = MenuUtil.CreateContextMenu(frame, SettingsMenu)
end

function WarbandBankLog_OnAddonCompartmentClick(addonName, button)
    if (button == "LeftButton") then
        WBL_API:Toggle()
    end
end
