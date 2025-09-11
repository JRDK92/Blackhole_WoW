local frame = CreateFrame("Frame")

-- Hearthstone's unique item ID
local HEARTHSTONE_ID = 6948

-- Sell all vendorable items except Hearthstone
local function SellAllItems()
    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemID = C_Container.GetContainerItemID(bag, slot)
            if itemID and itemID ~= HEARTHSTONE_ID then
                local _, _, _, _, _, _, _, _, _, _, sellPrice = GetItemInfo(itemID)
                if sellPrice and sellPrice > 0 then
                    C_Container.UseContainerItem(bag, slot)
                end
            end
        end
    end
end

-- Destroy everything else except Hearthstone
local function DestroyAllItems()
    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemID = C_Container.GetContainerItemID(bag, slot)
            if itemID and itemID ~= HEARTHSTONE_ID then
                C_Container.DestroyContainerItem(bag, slot)
            end
        end
    end
end

frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_CLOSED")

frame:SetScript("OnEvent", function(self, event)
    if event == "MERCHANT_SHOW" then
        SellAllItems()
    elseif event == "MERCHANT_CLOSED" then
        DestroyAllItems()
    end
end)
