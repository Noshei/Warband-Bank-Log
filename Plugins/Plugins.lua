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
            Baganator.Skins.AddFrame("IconButton", WBLButton)
        end

        return WBLButton
    end
    Baganator.API.Skins.RegisterListener(CreateWBLButton)
end)
