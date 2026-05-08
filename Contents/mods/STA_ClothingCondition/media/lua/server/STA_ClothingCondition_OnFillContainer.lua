local Server = require "STA_ClothingCondition_Server"

---@param container ItemContainer
local function processContainer(room, _, container)
    if not container then return end

    local items = ArrayList.new()
    container:getAllCategoryRecurse("Clothing", items)
    if not items then return end

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        Server.randomizeClothingCondition(item, room)
    end
end

Events.OnFillContainer.Add(processContainer)