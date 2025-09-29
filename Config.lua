---@class WBL
local _, WBL = ...

-- Localize global functions
local ipairs = ipairs
local pairs = pairs
local type = type
local rawset = rawset
local setmetatable = setmetatable

WBL.db = {}
WBL.db.defaults = {
    xPos = 0,
    yPos = 0,
    relativePoint = "CENTER",
    height = 300,
    width = 500,
    timeFormat = 5,
    autoOpen = false,
    autoClose = false,
    minimap = {
        hide = false,
    },
    version = "0.0.0",
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

local function copyTable(source)
    local copy = {}

    if type(source) == "table" then
        for key, value in pairs(source) do
            if type(value) == "table" then
                value = copyTable(value)
            end
            copy[key] = value
        end
    end

    return copy
end

local function setDefaults(defaults, settings)
    settings = settings or {}
    local mt = {}
    mt.__index = {}
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            settings[key] = setDefaults(defaults[key], settings[key])
        else
            rawset(mt.__index, key, value)
        end
    end
    setmetatable(settings, mt)
    return settings
end

local function removeDefaults(settings, defaults)
    if type(settings) == "table" then
        for key, value in pairs(settings) do
            if type(value) == "table" then
                removeDefaults(value, defaults[key])
            elseif value == defaults[key] then
                settings[key] = nil
            end
        end
    end
end

function WBL:LoadDB()
    WarbandBankLogSettings = WarbandBankLogSettings or {}
    WBL.db.settings = {}

    if WarbandBankLogSettings.profiles then
        --Move AceDB settings to new setup
        WBL.db.settings = copyTable(WarbandBankLogSettings.profiles.Default)
    else
        WBL.db.settings = copyTable(WarbandBankLogSettings)
    end
    WBL.db.settings = setDefaults(WBL.db.defaults, WBL.db.settings)
end

function WBL:UnloadDB()
    WarbandBankLogSettings = {}
    removeDefaults(WBL.db.settings, WBL.db.defaults)
    WarbandBankLogSettings = copyTable(WBL.db.settings)
end

function WBL:GenerateSettingsMenu(frame)
    local function SettingsMenu(frame, rootDescription)
        rootDescription:SetTag("WarbandBankLog_Settings_Menu")
        frame.settings = {}

        frame.settings.autoOpen = rootDescription:CreateCheckbox("Auto Open with Bank",
            function() --Getter function
                return WBL.db.settings.autoOpen
            end,
            function() --Setter function
                WBL.db.settings.autoOpen = not WBL.db.settings.autoOpen
            end
        )
        frame.settings.autoClose = rootDescription:CreateCheckbox("Auto Close with Bank",
            function() --Getter function
                return WBL.db.settings.autoClose
            end,
            function() --Setter function
                WBL.db.settings.autoClose = not WBL.db.settings.autoClose
            end
        )
        frame.settings.minimap = rootDescription:CreateCheckbox("Minimap Icon",
            function() --Getter function
                return not WBL.db.settings.minimap.hide
            end,
            function() --Setter function
                WBL.db.settings.minimap.hide = not WBL.db.settings.minimap.hide
                WBL:MinimapHandler(not WBL.db.settings.minimap.hide)
            end
        )
        frame.settings.timeFormat = rootDescription:CreateButton("Time Format", function() end)
        local function IsSelected(index)
            return index == WBL.db.settings.timeFormat
        end
        local function SetSelected(index)
            WBL.db.settings.timeFormat = index
            if #WBL.Logs > 0 then
                WBL.DataProvider:Flush()
                WBL.DataProvider:InsertTable(WBL.Logs)
            end
            WBL.Display.BaseFrame.Container.ScrollBox:SetScrollPercentage(100)
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
