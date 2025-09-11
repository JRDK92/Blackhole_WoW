-- Create a hidden frame to handle game events
local frame = CreateFrame("Frame")

-- Hearthstone's unique item ID. This is more reliable than checking the name.
local HEARTHSTONE_ID = 6948

-- Function to sell all sellable items
local function SellAllItems()
    -- Iterate through each bag, from the backpack (0) to the last bag slot
    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        -- Iterate through each slot in the current bag
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemID = C_Container.GetContainerItemID(bag, slot)
            -- Check if an item exists in the slot and it is NOT a Hearthstone
            if itemID and itemID ~= HEARTHSTONE_ID then
                local _, _, _, _, _, _, _, _, _, _, sellPrice = GetItemInfo(itemID)
                -- If the item has a sell price, sell it.
                -- Using C_Container.UseContainerItem sells the item when a merchant is open.
                if sellPrice and sellPrice > 0 then
                    C_Container.UseContainerItem(bag, slot)
                end
            end
        end
    end
end

-- Function to destroy all remaining non-Hearthstone items
local function DestroyAllItems()
    -- Iterate through all bags and slots again
    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemID = C_Container.GetContainerItemID(bag, slot)
            -- If an item exists and it's not the Hearthstone, destroy it.
            -- The game's own confirmation pop-ups will still appear for high-quality items.
            if itemID and itemID ~= HEARTHSTONE_ID then
                C_Container.DeleteContainerItem(bag, slot)
            end
        end
    end
end

-- Register the events we want to listen for
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_CLOSED")

-- Set the function to be called when one of our registered events occurs
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "MERCHANT_SHOW" then
        -- When the merchant window opens, sell everything.
        SellAllItems()
    elseif event == "MERCHANT_CLOSED" then
        -- When the merchant window closes, destroy the leftovers.
        DestroyAllItems()
    end
end)


