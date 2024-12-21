---@class WBL
local _, WBL = ...

-- Localize global functions
local ipairs = ipairs
local string = string
local table = table

local function SearchLogEntry(self, logEntry, results)
    local searchString = string.lower(self:GetText())
    if string.find(string.lower(logEntry.link), searchString) then
        table.insert(results, logEntry)
        return
    end
    if string.find(string.lower(logEntry.name), searchString) then
        table.insert(results, logEntry)
        return
    end
    if string.find(string.lower(logEntry.changeType), searchString) then
        table.insert(results, logEntry)
        return
    end
end

function WBL:Search_EnterPressed(self)
    self:ClearFocus()

    local results = {}

    for index, logEntry in ipairs(WBL.Logs) do
        SearchLogEntry(self, logEntry, results)
    end

    WBL.DataProvider:Flush()

    if #results > 0 then
        WBL.DataProvider:InsertTable(results)
        WBL.Display.BaseFrame.Container.ScrollBox:SetScrollPercentage(100)
    end
end

function WBL:ClearSearch()
    if not WBL.DataProvider then
        return
    end
    WBL.DataProvider:Flush()
    if #WBL.Logs > 0 then
        WBL.DataProvider:InsertTable(WBL.Logs)
    end
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
    WBL.Display.BaseFrame.SearchBox:SetText("")
    WBL.Display.BaseFrame.SearchBox:ClearFocus()
end
