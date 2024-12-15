---@class WBL
local WBL = LibStub("AceAddon-3.0"):GetAddon("Warband-Bank-Log")
local ldb = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")

function WBL:InitializeBroker()
    WBL:Debug("InitializeBroker", 1)
    -- Create LibDataBroker data object
    local dataObj = ldb:NewDataObject(WBL.metaData.name, {
        type = "launcher",
        icon = 1505935,
        label = "Warband Bank Log",
        OnClick = function(frame, button)
            if button == "LeftButton" then
                WBL_API:Toggle()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine(WBL.metaData.name .. " |cffff6f00v" .. WBL.metaData.version .. "|r")
            tooltip:AddLine(" ")
            tooltip:AddLine("|cff8080ffLeft-Click|r to open the Warband Bank Log")
        end,
    })

    -- Register with LibDBIcon
    LibDBIcon:Register(WBL.metaData.name, dataObj, WBL.db.profile.minimap)
end

function WBL:MinimapHandler(key)
    WBL:Debug("MinimapHandler", 1, key)
    if key then
        LibDBIcon:Show(WBL.metaData.name)
    else
        LibDBIcon:Hide(WBL.metaData.name)
    end
end
