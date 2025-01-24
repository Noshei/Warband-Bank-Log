---@class WBL
local _, WBL = ...

function WBL:RunAnalytics()
    if not WagoAnalytics then
        return
    end
    local WagoAnalytics = LibStub("WagoAnalytics"):Register("kGr0on6y")

    WagoAnalytics:Switch("AutoOpen", WBL.db.settings.autoOpen)
    WagoAnalytics:Switch("AutoClose", WBL.db.settings.autoClose)
    WagoAnalytics:Switch("MinimapButton", WBL.db.settings.minimap.enable)

    WagoAnalytics:SetCounter("timeFormat", WBL.db.settings.timeFormat)
end
