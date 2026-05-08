local Server = require "STA_ClothingCondition_Server"

---@param room IsoRoom
local function onSeeNewRoom(room)
    local squares = room:getSquares()
    local roomName = room:getName()
    for i = 0, squares:size() - 1 do
        local sq = squares:get(i) ---@cast sq IsoGridSquare
        local worldObjects = sq:getObjects()
        for j = 0, worldObjects:size() - 1 do
            local obj = worldObjects:get(j)
            if instanceof(obj, "IsoWorldInventoryObject") then ---@cast obj IsoWorldInventoryObject
                local item = obj:getItem()
                if item:IsClothing() then ---@cast item Clothing
                    Server.randomizeClothingCondition(item, roomName)
                end
            end
        end
    end
end

Events.OnSeeNewRoom.Add(onSeeNewRoom)