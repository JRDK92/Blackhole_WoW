local f = CreateFrame("Frame")
f:RegisterEvent("MERCHANT_SHOW")

local HEARTHSTONE_NAME = GetItemInfo(6948) or "Hearthstone" -- fallback if info not cached

local function DestroyEverything()
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
            if itemInfo and itemInfo.hyperlink then
                local itemName = C_Item.GetItemName(itemInfo.hyperlink)
                if itemName and itemName ~= HEARTHSTONE_NAME then
                    C_Container.PickupContainerItem(bag, slot)
                    DeleteCursorItem()
                end
            end
        end
    end
end

f:SetScript("OnEvent", function(self, event)
    if event == "MERCHANT_SHOW" then
        -- Sell phase
        for bag = 0, NUM_BAG_SLOTS do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                if itemInfo and itemInfo.hyperlink then
                    local _, _, _, _, _, _, _, _, _, _, sellPrice = GetItemInfo(itemInfo.hyperlink)
                    if sellPrice and sellPrice > 0 then
                        C_Container.UseContainerItem(bag, slot)
                    end
                end
            end
        end
        -- Destroy phase
        DestroyEverything()
    end
end)
