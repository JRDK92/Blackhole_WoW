-- Create a hidden frame to handle game events
local frame = CreateFrame("Frame")

-- Hearthstone's unique item ID. This is more reliable than checking the name.
local HEARTHSTONE_ID = 6948

-- Queues for selling and destroying
local itemsToSell = {}
local itemsToDestroy = {}

-------------------------------------------------
-- SELLING LOGIC
-------------------------------------------------
local function ProcessNextSell()
    local entry = table.remove(itemsToSell, 1)
    if entry then
        local bag, slot = entry.bag, entry.slot
        C_Container.UseContainerItem(bag, slot)
        -- Delay before selling next item to avoid skips
        C_Timer.After(0.2, ProcessNextSell)
    end
end

local function SellAllItems()
    itemsToSell = {}
    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local numSlots = C_Container.GetContainerNumSlots(bag)
        if numSlots > 0 then
            for slot = 1, numSlots do
                local itemID = C_Container.GetContainerItemID(bag, slot)
                if itemID and itemID ~= HEARTHSTONE_ID then
                    local _, _, _, _, _, _, _, _, _, _, sellPrice = GetItemInfo(itemID)
                    if sellPrice and sellPrice > 0 then
                        table.insert(itemsToSell, { bag = bag, slot = slot })
                    end
                end
            end
        end
    end
    ProcessNextSell()
end

-------------------------------------------------
-- DESTROYING LOGIC
-------------------------------------------------
local function ProcessNextDestroy()
    local entry = table.remove(itemsToDestroy, 1)
    if entry then
        local bag, slot = entry.bag, entry.slot
        -- Double-check the item still exists before deleting
        local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
        if itemInfo and itemInfo.itemID and itemInfo.itemID ~= HEARTHSTONE_ID then
            C_Container.PickupContainerItem(bag, slot)
            DeleteCursorItem()
        end
        -- Delay before destroying next item
        C_Timer.After(0.2, ProcessNextDestroy)
    end
end

local function DestroyAllItems()
    itemsToDestroy = {}
    -- Delay slightly to make sure merchant window is fully closed
    C_Timer.After(0.5, function()
        for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
            local numSlots = C_Container.GetContainerNumSlots(bag)
            if numSlots > 0 then
                for slot = 1, numSlots do
                    local itemID = C_Container.GetContainerItemID(bag, slot)
                    if itemID and itemID ~= HEARTHSTONE_ID then
                        local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                        if itemInfo and itemInfo.itemID then
                            table.insert(itemsToDestroy, { bag = bag, slot = slot })
                        end
                    end
                end
            end
        end
        ProcessNextDestroy()
    end)
end

-------------------------------------------------
-- EVENT HANDLER
-------------------------------------------------
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_CLOSED")

frame:SetScript("OnEvent", function(self, event)
    if event == "MERCHANT_SHOW" then
        SellAllItems()
    elseif event == "MERCHANT_CLOSED" then
        DestroyAllItems()
    end
end)
