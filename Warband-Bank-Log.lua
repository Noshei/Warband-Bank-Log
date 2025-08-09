---@class WBL
local _, WBL = ...
WarbandBankLog = WBL

WBL.CallbackRegistry = CreateFromMixins(CallbackRegistryMixin)
WBL.CallbackRegistry:OnLoad()
WBL.CallbackRegistry:GenerateCallbackEvents({
    "BankItemsLoaded",
})

WBL.DebugCount = 0
WBL.EnableDebug = false

local WarbankStart = Enum.BagIndex.AccountBankTab_1
local WarbankEnd = WarbankStart + 4

-- Localize global functions
local ipairs = ipairs
local math = math
local max = max
local next = next
local pairs = pairs
local select = select
local string = string
local table = table
local time = time
local tonumber = tonumber
local tostring = tostring
local tostringall = tostringall
local type = type
local unpack = unpack

WBL.metaData = {
    name = "Warband-Bank-Log",
    version = C_AddOns.GetAddOnMetadata("Warband-Bank-Log", "Version"),
    notes = C_AddOns.GetAddOnMetadata("Warband-Bank-Log", "Notes"),
}

local function ADDON_LOADED(_, addOnName)
    WBL:Debug("ADDON_LOADED", 1, addOnName)
    if addOnName == WBL.metaData.name then
        WBL:Debug("OnInitialize", 2)

        WBL:LoadDB()
        WBL:LoadSavedVariables()

        WBL:RunAnalytics()

        EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGOUT", WBL.PLAYER_LOGOUT)
        EventRegistry:RegisterFrameEventAndCallback("BANKFRAME_OPENED", WBL.BANKFRAME_OPENED)
        EventRegistry:RegisterFrameEventAndCallback("BANKFRAME_CLOSED", WBL.BANKFRAME_CLOSED)
        EventRegistry:RegisterFrameEventAndCallback("BAG_UPDATE", WBL.BAG_UPDATE)
        EventRegistry:RegisterFrameEventAndCallback("ACCOUNT_MONEY", WBL.ACCOUNT_MONEY)

        WBL:InitializeBroker()
        WBL:CreateDisplay()
        WBL:CreateBankButton()

        SLASH_WarbandBankLog1 = "/warbandbanklog"
        SLASH_WarbandBankLog2 = "/wbl"
        function SlashCmdList.WarbandBankLog()
            WBL_API:Toggle()
        end
    end
end

local function PLAYER_LOGIN()
    WBL:MinimapHandler(WBL.db.settings.minimap.enable)
end

EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", ADDON_LOADED)
EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGIN", PLAYER_LOGIN)


function WBL:Debug(text, level, ...)
    if not WBL.EnableDebug then return end
    if level == nil then
        level = 2
    end

    if text then
        WBL.DebugCount = WBL.DebugCount + 1
        local color = "89FF9A" --#89FF9A
        if level == 2 then
            color = "FFD270"   --#FFD270
        elseif level == 3 then
            color = "FF8080"   --#FF8080
        elseif level == 4 then
            color = "E300DB"   --#E300DB
        elseif level == 5 then
            color = "3990FA"   --#3990FA
        elseif level == 6 then
            color = "D9041D"   --#D9041D
        end
        ChatFrame1:AddMessage(
            "|cffff6f00"        --#ff6f00
            .. WBL.metaData.name
            .. ":|r |cffff0000" --#ff0000
            .. date("%X")
            .. "|r |cff00a0a3"  --#00a0a3
            .. tostring(WBL.DebugCount)
            .. ": |r "
            .. strjoin(" |cff00ff00:|r ", "|cff" .. color .. text .. "|r", tostringall(...)) --#00ff00
        )
    end
end

function WBL:LoadSavedVariables()
    if WarbandBankLogDB then
        WBL.Logs = WarbandBankLogDB.Logs
        WBL.Bank = WarbandBankLogDB.Bank
        WBL.Gold = WarbandBankLogDB.Gold
    else
        WBL.Logs = {}
        WBL.Bank = {}
        WBL.Gold = -1
    end
end

local function tableDiff(oldTable, newTable)
    local diff = {}

    for itemLink, itemCount in pairs(oldTable) do
        if newTable[itemLink] then
            if itemCount ~= newTable[itemLink] then
                diff[itemLink] = {}
                diff[itemLink].stackCount = newTable[itemLink] - itemCount
                if diff[itemLink].stackCount > 0 then
                    WBL:Debug("Table Diff: Added 1", 2, itemLink, itemCount, newTable[itemLink])
                    diff[itemLink].type = "added"
                else
                    WBL:Debug("Table Diff: Removed 1", 2, itemLink, itemCount, newTable[itemLink])
                    diff[itemLink].type = "removed"
                    diff[itemLink].stackCount = math.abs(diff[itemLink].stackCount)
                end
            end
        else
            WBL:Debug("Table Diff: Removed 2", 3, itemLink, itemCount)
            diff[itemLink] = {
                type = "removed",
                stackCount = itemCount
            }
        end
    end

    for itemLink, itemCount in pairs(newTable) do
        if oldTable[itemLink] == nil then
            WBL:Debug("Table Diff: Added 2", 3, itemLink, itemCount)
            diff[itemLink] = {
                type = "added",
                stackCount = itemCount
            }
        end
    end

    return diff
end

function WBL:PLAYER_LOGOUT()
    WarbandBankLogDB = WarbandBankLogDB or {}

    while #WBL.Logs > 10000 do
        table.remove(WBL.Logs, 1)
    end

    WarbandBankLogDB.Logs = WBL.Logs
    WarbandBankLogDB.Bank = WBL.Bank
    WarbandBankLogDB.Gold = WBL.Gold

    WBL:UnloadDB()
end

function WBL:BANKFRAME_OPENED()
    WBL.BankOpen = true
    WBL:GetBankContent("BANKFRAME_OPENED")
end

function WBL:BAG_UPDATE(bag)
    WBL:Debug("BAG_UPDATE", 3, bag)
    if not bag then return end
    if not WBL.BankOpen then return end
    if bag < WarbankStart or bag > WarbankEnd then
        return
    end

    WBL:GetBankContent("BAG_UPDATE")
    WBL:Debug("BAG_UPDATE", 2, bag)
end

function WBL:GetBankData(tempBank, event)
    local tempGold = WBL:GetBankGold()
    local playerData = WBL:GetPlayerInfo()
    WBL:Debug("GetBankData", 4, tempBank, event, tempGold, playerData)

    if WBL:NeedToInitialize() then
        WBL:InitializeData(tempBank, tempGold)
        return
    end

    local diffs = tableDiff(WBL.Bank, tempBank)
    if event == "BANKFRAME_OPENED" then
        playerData = nil
        if WBL.db.settings.autoOpen then
            WBL_API:Open()
        end
    end
    WBL:UpdateChanges(diffs, tempBank, tempGold, playerData)
end
WBL.CallbackRegistry:RegisterCallback("BankItemsLoaded", WBL.GetBankData)

function WBL:BANKFRAME_CLOSED()
    WBL.BankOpen = false
    if WBL.db.settings.autoClose then
        WBL_API:Close()
    end
end

function WBL:ACCOUNT_MONEY()
    local tempGold = WBL:GetBankGold()
    local playerData = WBL:GetPlayerInfo()

    WBL:Debug("ACCOUNT_MONEY", 2, playerData.name, playerData.realm, playerData.color, tempGold)
    WBL:UpdateChanges(nil, nil, tempGold, playerData)
end

function WBL:GetPlayerInfo()
    local playerLoc = PlayerLocation:CreateFromUnit("player")
    local _, class = C_PlayerInfo.GetClass(playerLoc)
    local playerData = {
        name = C_PlayerInfo.GetName(playerLoc),
        realm = GetRealmName(),
        color = RAID_CLASS_COLORS[class].colorStr
    }
    return playerData
end

---Gets the contents of the Warband Bank and returns a temporary table that will be used to compare to cached data
---see https://warcraft.wiki.gg/wiki/BagID bag ID's that are used for initial loop values
---@param event string
function WBL:GetBankContent(event)
    local items = {}
    local continuableContainer = ContinuableContainer:Create()
    for bag = WarbankStart, WarbankEnd do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = Item:CreateFromBagAndSlot(bag, slot)
            if not item:IsItemEmpty() then
                table.insert(items, item)
                continuableContainer:AddContinuable(item)
            end
        end
    end
    continuableContainer:ContinueOnLoad(function()
        local tempBank = {}
        for _, item in ipairs(items) do
            local itemLink = item:GetItemLink()
            WBL:Debug("Get Bank Content", 3, itemLink)
            local colorNameUsed = itemLink and string.sub(itemLink, 1, 3) == "|cn" and 1 or 0
            local chunks = strsplittable(":", itemLink)
            chunks[10 + colorNameUsed] = ""
            chunks[11 + colorNameUsed] = ""
            local link = table.concat(chunks, ":")
            tempBank[link] = (tempBank[link] or 0) + item:GetStackCount()
        end
        WBL.CallbackRegistry:TriggerEvent("BankItemsLoaded", tempBank, event)
    end)
end

---@return number bankGold
function WBL:GetBankGold()
    return C_Bank.FetchDepositedMoney(Enum.BankType.Account)
end

function WBL:NeedToInitialize()
    local initialize = false
    if next(WBL.Bank) == nil then
        initialize = true
    end
    if WBL.Gold == -1 then
        initialize = true
    end
    return initialize
end

function WBL:InitializeData(tempBank, tempGold)
    if next(WBL.Bank) == nil then
        WBL.Bank = tempBank
    end
    if WBL.Gold == -1 then
        WBL.Gold = tempGold
    end
end

function WBL:UpdateChanges(diffs, tempBank, tempGold, playerData)
    WBL:Debug("UpdateChanges", 5, diffs, tempBank, tempGold, playerData)
    if diffs ~= nil then
        WBL:Debug("UpdateChanges", 6, "Diffs not nil")
        for itemLink, diff in pairs(diffs) do
            WBL:Debug("UpdateChanges", 4, "Diffs not nil", itemLink, diff)
            WBL:AddLogEntry(itemLink, "item", diff, playerData)
        end
        WBL.Bank = tempBank
    end

    if WBL.Gold ~= tempGold then
        WBL:Debug("UpdateChanges", 2, "Gold Change")
        local goldDiff = tempGold - WBL.Gold
        local logType = ""
        if goldDiff > 0 then
            logType = "added"
        else
            logType = "removed"
            goldDiff = math.abs(goldDiff)
        end
        local itemData = {
            type = logType,
            goldDiff = goldDiff
        }
        WBL:AddLogEntry(nil, "gold", itemData, playerData)
        WBL.Gold = tempGold
    end
end

---@param itemLink? string
---@param itemType string
---@param itemData table
---@param playerData? table
function WBL:AddLogEntry(itemLink, itemType, itemData, playerData)
    local playerName = ""
    if not playerData then
        playerName = "Unknown"
    else
        playerName = "|c" .. playerData.color .. playerData.name .. "|r-" .. playerData.realm
    end

    local link = ""
    if itemType == "item" then
        link = itemData.stackCount .. " " .. itemLink
    elseif itemType == "gold" then
        link = C_CurrencyInfo.GetCoinTextureString(itemData.goldDiff)
    end

    local logEntry = {
        name = playerName,
        timeStamp = time(),
        changeType = itemData.type,
        link = link
    }

    table.insert(WBL.Logs, logEntry)
    WBL.DataProvider:Insert(logEntry)
    WBL.Display.BaseFrame.Container.ScrollBox:SetScrollPercentage(100)
    WBL:Debug("added Log", 1, logEntry.name, logEntry.changeType, logEntry.link)
end
