-- Create a hidden frame to handle game events
local frame = CreateFrame("Frame")

-- Hearthstone's unique item ID. This is more reliable than checking the name.
local HEARTHSTONE_ID = 6948

-- Function to sell all sellable items (excluding Hearthstone)
local function SellAllItems()
    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local numSlots = C_Container.GetContainerNumSlots(bag)
        if numSlots > 0 then
            for slot = 1, numSlots do
                local itemID = C_Container.GetContainerItemID(bag, slot)
                if itemID and itemID ~= HEARTHSTONE_ID then
                    local _, _, _, _, _, _, _, _, _, _, sellPrice = GetItemInfo(itemID)
                    if sellPrice and sellPrice > 0 then
                        C_Container.UseContainerItem(bag, slot)
                        -- Small delay to prevent issues with rapid selling
                        C_Timer.After(0.1, function() end)
                    end
                end
            end
        end
    end
end

-- Function to destroy all remaining non-Hearthstone items
local function DestroyAllItems()
    -- Add a small delay to ensure merchant window is fully closed
    C_Timer.After(0.5, function()
        for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
            local numSlots = C_Container.GetContainerNumSlots(bag)
            if numSlots > 0 then
                for slot = 1, numSlots do
                    local itemID = C_Container.GetContainerItemID(bag, slot)
                    if itemID and itemID ~= HEARTHSTONE_ID then
                        -- Check if item exists before trying to delete
                        local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                        if itemInfo and itemInfo.itemID then
                            -- Pick up the item first
                            C_Container.PickupContainerItem(bag, slot)
                            -- Delete it from cursor
                            DeleteCursorItem()
                            -- Small delay between deletions to prevent issues
                            C_Timer.After(0.1, function() end)
                        end
                    end
                end
            end
        end
    end)
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
