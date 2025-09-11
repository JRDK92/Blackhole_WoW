-- Create a hidden frame to handle game events
local frame = CreateFrame("Frame")

-- Hearthstone's unique item ID. This is more reliable than checking the name.
local HEARTHSTONE_ID = 6948

-- Safe function to delete items, compatible with Retail and Classic
local function DeleteContainerItemSafe(bag, slot)
    if C_Container.DeleteContainerItem then
        -- Classic WoW
        C_Container.DeleteContainerItem(bag, slot)
    else
        -- Retail WoW
        C_Container.PickupContainerItem(bag, slot)
        DeleteCursorItem()
    end
end

-- Function to sell all sellable items (excluding Hearthstone)
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

-- Function to destroy all remaining non-Hearthstone items
local function DestroyAllItems()
    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemID = C_Container.GetContainerItemID(bag, slot)
            if itemID and itemID ~= HEARTHSTONE_ID then
                DeleteContainerItemSafe(bag, slot)
            end
        end
    end
end

-- Register events
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_CLOSED")

-- Event handler
frame:SetScript("OnEvent", function(self, event)
    if event == "MERCHANT_SHOW" then
        SellAllItems()
    elseif event == "MERCHANT_CLOSED" then
        DestroyAllItems()
    end
end)
