---@class WBL
local _, WBL = ...

WBL_API = {}

WBL.Display = {}

function WBL:CreateDisplay()
    local frame = CreateFrame("Frame", "WarbandBankLog_BaseFrame", UIParent, "WBLBaseFrameTemplate")
    frame:SetDontSavePosition(true)
    frame:ClearAllPoints()
    frame:SetPoint(
        WBL.db.settings.relativePoint,
        UIParent,
        WBL.db.settings.xPos,
        WBL.db.settings.yPos
    )
    frame:SetSize(WBL.db.settings.width, WBL.db.settings.height)
    frame.ResizeButton:SetOnResizeStoppedCallback(function()
        WBL.db.settings.width, WBL.db.settings.height = frame:GetSize()
    end)

    function frame:stoppedMoving()
        local rel, _, _, xPos, yPos = self:GetPoint()
        WBL.db.settings.xPos = xPos
        WBL.db.settings.yPos = yPos
        WBL.db.settings.relativePoint = rel
    end
    frame.SearchBox.clearButton:SetScript("OnClick", function() WBL:ClearSearch() end)

    WBL.Display.BaseFrame = frame

    local ScrollBox = frame.Container.ScrollBox
    local ScrollBar = frame.Container.ScrollBar

    WBL.DataProvider = CreateDataProvider()
    local ScrollView = CreateScrollBoxListLinearView()
    ScrollView:SetElementFactory(function(factory)
        factory("WBLItemListObjectTemplate", function() end)
    end)
    WBL.ScrollView = ScrollView
    ScrollView:SetDataProvider(WBL.DataProvider)

    ScrollUtil.InitScrollBoxListWithScrollBar(ScrollBox, ScrollBar, ScrollView)

    local function Initializer(frame, logData)
        frame:SetPropagateMouseMotion(true)
        local changeType = ""
        if logData.changeType == "added" then
            changeType = "|cff4bd04d" .. logData.changeType .. "|r"
        else
            changeType = "|cffd06057" .. logData.changeType .. "|r"
        end
        local message =
            "|cff979797[" ..
            date(WBL.timeFormats[WBL.db.settings.timeFormat], logData.timeStamp) ..
            "]|r " ..
            logData.name ..
            " " ..
            changeType ..
            " " ..
            logData.link

        frame.text:SetText(message)

        function frame:GetTooltipAnchor()
            local x = self:GetRight() / GetScreenWidth() > 0.8
            return x and 'ANCHOR_LEFT' or 'ANCHOR_RIGHT'
        end
    end

    ScrollView:SetElementInitializer("WBLItemListObjectTemplate", Initializer)
    WBL:InitializeDataProvider()
end

function WBL:CreateBankButton()
    local WBLButton = CreateFrame("Button", "WBLBlizzardButton", BankFrame, "UIPanelButtonTemplate")
    WBLButton:SetPoint("BOTTOMLEFT", 2, 6)
    WBLButton:SetSize(105, 21)
    WBLButton:SetFrameLevel(700)
    WBLButton:SetText("Warbank Log")

    WBLButton:SetScript("OnClick", function()
        WBL_API:Toggle()
    end)

    WBL.Display.Button = WBLButton
end

function WBL:InitializeDataProvider()
    if #WBL.Logs == 0 then
        return
    end
    WBL.DataProvider:InsertTable(WBL.Logs)
end

function WBL_API:Open()
    WBL.Display.BaseFrame:Show()
    WBL.Display.BaseFrame.Container.ScrollBox:SetScrollPercentage(100)
end

function WBL_API:Close()
    WBL.Display.BaseFrame:Hide()
end

function WBL_API:Toggle()
    if WBL.Display.BaseFrame:IsVisible() then
        WBL_API:Close()
    else
        WBL_API:Open()
    end
end
