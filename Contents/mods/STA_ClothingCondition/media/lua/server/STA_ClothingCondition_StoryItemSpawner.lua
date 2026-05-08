local Server = require "STA_ClothingCondition_Server"

local function onWorldInit()
    if not StoryItemSpawner or not StoryItemSpawner.TweakItem then return end

    local origFunc = StoryItemSpawner.TweakItem
    function StoryItemSpawner.TweakItem(item, roomName)
        if item:IsClothing() then
            Server.randomizeClothingCondition(item, roomName)
        end
        origFunc(item, roomName)
    end
    Events.OnInitWorld.Remove(onWorldInit)
end

Events.OnInitWorld.Add(onWorldInit)