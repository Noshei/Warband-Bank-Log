EventUtil.ContinueOnAddOnLoaded("Baganator", function()
    local function CreateWBLButton(details)
        if details.regionType ~= "ButtonFrame" or tIndexOf(details.tags or {}, "bank") == nil then
            return
        end
        local parent = details.region.Warband

        local WBLButton = CreateFrame("Button", "WarbandBankLogButton", parent, "WBLBaganatorIcon")
        WBLButton:SetPoint("TOPLEFT", 5, 0)
        WBLButton:SetFrameLevel(700)
        WBLButton.tooltipHeader = "Warband Bank Log"
        WBLButton.tooltipText = ""

        if Baganator.API.Skins.GetCurrentSkin() == "gw2_ui" then
            WBLButton:SetSize(30, 30)
            WBLButton:SetPoint("TOPLEFT", parent:GetParent().CustomiseButton, "BOTTOMLEFT", 0, -12)
            WBLButton.Left:Hide()
            WBLButton.Right:Hide()
            WBLButton.Middle:Hide()
            WBLButton:ClearHighlightTexture()
            WBLButton:SetHighlightTexture("Interface\\AddOns\\Warband-Bank-Log\\Media\\Plugins\\Scroll-GW2")
            WBLButton:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)

            WBLButton.Icon:SetTexture("Interface\\AddOns\\Warband-Bank-Log\\Media\\Plugins\\Scroll-GW2")
            WBLButton.Icon:SetTexCoord(0, 1, 0, 1)
            WBLButton.Icon:SetDrawLayer("OVERLAY")
            WBLButton.Icon:SetSize(30, 30)
        elseif Baganator.API.Skins.GetCurrentSkin() ~= "blizzard" then
            WBLButton:SetPoint("TOPLEFT", 1.5, -1.5)
            WBLButton.Left:Hide()
            WBLButton.Right:Hide()
            WBLButton.Middle:Hide()
            WBLButton:ClearHighlightTexture()

            Mixin(WBLButton, BackdropTemplateMixin)
            WBLButton:SetBackdrop({
                bgFile = "Interface/AddOns/Baganator/Assets/Skins/dark-backgroundfile",
                edgeFile = "Interface/AddOns/Baganator/Assets/Skins/dark-edgefile",
                tile = true,
                tileEdge = true,
                tileSize = 32,
                edgeSize = 6,
            })
            local color = { r = 0, g = 0, b = 0 }
            WBLButton:SetBackdropColor(color.r, color.g, color.b, 0.5)
            WBLButton:SetBackdropBorderColor(color.r, color.g, color.b, 1)
            WBLButton:HookScript("OnEnter", function()
                if WBLButton:IsEnabled() then
                    local r, g, b = 0.3, 0.3, 0.3
                    WBLButton:SetBackdropColor(r, g, b, 0.8)
                    WBLButton:SetBackdropBorderColor(r, g, b, 1)
                end
            end)
            WBLButton:HookScript("OnMouseDown", function()
                if WBLButton:IsEnabled() then
                    local r, g, b = 0.2, 0.2, 0.2
                    WBLButton:SetBackdropColor(r, g, b, 0.8)
                    WBLButton:SetBackdropBorderColor(r, g, b, 1)
                end
            end)
            WBLButton:HookScript("OnMouseUp", function()
                if WBLButton:IsEnabled() and WBLButton:IsMouseOver() then
                    local r, g, b = 0.3, 0.3, 0.3
                    WBLButton:SetBackdropColor(r, g, b, 0.8)
                    WBLButton:SetBackdropBorderColor(r, g, b, 1)
                end
            end)
            WBLButton:HookScript("OnLeave", function()
                WBLButton:SetBackdropColor(color.r, color.g, color.b, 0.5)
                WBLButton:SetBackdropBorderColor(color.r, color.g, color.b, 1)
            end)
            WBLButton:HookScript("OnDisable", function()
                WBLButton:SetBackdropColor(color.r, color.g, color.b, 0.1)
            end)
            WBLButton:HookScript("OnEnable", function()
                WBLButton:SetBackdropColor(color.r, color.g, color.b, 0.5)
            end)
        end
        return WBLButton
    end
    Baganator.API.Skins.RegisterListener(CreateWBLButton)
end)
