local Utils = require "STA_ClothingCondition_Utils"
local Log = require "STA_ClothingCondition_Log"
local Server = STA_ClothingCondition_Server or {}

local storeZones = {
    names = {"leatherclothesstore", "clothingstore", "clothingstorage", "departmentstore", "departmentstorage"},
    min = Utils.getSandboxNum("StoreMinCond"),
    max = Utils.getSandboxNum("StoreMaxCond"),
    chanceBloody = Utils.getSandboxNum("StoreChanceBloody"),
    chanceDirty = Utils.getSandboxNum("StoreChanceDirty")
}

---@param item Clothing
---@param room string
function Server.randomizeClothingCondition(item, room)
    if not (item and item:IsClothing()) then return end

    local maxCond = item:getConditionMax()
    if not maxCond and maxCond <= 0 then return end

    local perfectChance = Utils.getSandboxNum("PerfectCondChance")
    if ZombRandFloat(0.0, 1.0) < perfectChance then
        item:fullyRestore()
        item:synchWithVisual()
        Log.debug("Perfect Item; aborting")
        return
    end

    local minPercent, maxPercent, chanceBloody, chanceDirty

    for _, zone in ipairs(storeZones.names) do
        if room == zone then
            minPercent = storeZones.min
            maxPercent = storeZones.max
            chanceBloody = storeZones.chanceBloody
            chanceDirty = storeZones.chanceDirty
        end
    end

    if item:getCondition() < maxCond then
        if Utils.getSandboxBool("TrashModifyItems") then
            item:fullyRestore()
            minPercent = Utils.getSandboxNum("TrashMinCond")
            maxPercent = Utils.getSandboxNum("TrashMaxCond")
            chanceBloody = Utils.getSandboxNum("TrashChanceBloody")
            chanceDirty = Utils.getSandboxNum("TrashChanceDirty")
        else
            Log.debug("Trash item found; aborting")
            return
        end
    end

    if not (minPercent and maxPercent) then
        minPercent = Utils.getSandboxNum("NormalMinCond")
        maxPercent = Utils.getSandboxNum("NormalMaxCond")
        chanceBloody = Utils.getSandboxNum("NormalChanceBloody")
        chanceDirty = Utils.getSandboxNum("NormalChanceDirty")
    end

    if not (minPercent and maxPercent) then return end

    local minP = math.max(0, math.min(minPercent, 1))
    local maxP = math.max(minP, math.min(maxPercent, 1))

    local u1, u2 = ZombRandFloat(0.0, 1.0), ZombRandFloat(0.0, 1.0)
    local tri = (u1 + u2) / 2.0

    local conditionPercent = minP + tri * (maxP - minP)
    local baseCond = math.floor(conditionPercent * maxCond)
    if baseCond < 1 then baseCond = 1 end

    local canHaveHoles = item:getCanHaveHoles()
    local nbrParts = item:getNbrOfCoveredParts() or 0
    local condLossPerHole = 0

    if canHaveHoles and nbrParts > 0 then
        condLossPerHole = item:getCondLossPerHole() or 1
    end

    local wearRatio = 1 - (baseCond / maxCond)
    local numHoles = 0

    if canHaveHoles and nbrParts > 0 then
        local maxHoles = math.max(1, math.floor(nbrParts * wearRatio + 0.5))
        for i = 1, maxHoles do
            if (numHoles + 1) * condLossPerHole >= maxCond - baseCond then break end
            if ZombRandFloat(0.0, 1.0) < wearRatio * 0.5 then
                numHoles = numHoles + 1
                item:addRandomHole()
            end
        end
    end

    local dirtAmount = conditionPercent * math.pow(ZombRandFloat(0.0, 1.0), 0.8)
    local bloodAmount = conditionPercent * math.pow(ZombRandFloat(0.0, 1.0), 1.2)

    local function shuffleList(list)
        for i = list:size() - 1, 1, -1 do
            local j = ZombRand(i + 1)
            local tmp = list:get(i)
            list:set(i, list:get(j))
            list:set(j, tmp)
        end
    end

    if ZombRandFloat(0.0, 1.0) < chanceDirty then
        if nbrParts > 0 then
            local bodyParts = item:getCoveredParts()
            local maxParts = math.floor(bodyParts:size() * ZombRandFloat(0.5, 1.0))
            local dirtBank = dirtAmount * bodyParts:size()
            shuffleList(bodyParts)
            Log.debug("Setting Dirt Level dirtAmount:%.2f maxParts:%d bodyParts:%s", dirtAmount, maxParts, tostring(bodyParts))
            for i = 0, maxParts - 1 do
                local rand = ZombRandFloat(0.0, dirtBank)
                item:setDirt(bodyParts:get(i), rand)
                dirtBank = dirtBank - rand
                if dirtBank <= 0 then break end
            end
        end
        if dirtAmount > 0 then item:setDirtiness(100 * dirtAmount) end
    end

    if ZombRandFloat(0.0, 1.0) < chanceBloody then
        if nbrParts > 0 then
            local bodyParts = item:getCoveredParts()
            local maxParts = math.floor(bodyParts:size() * ZombRandFloat(0.5, 1.0))
            local bloodBank = bloodAmount * bodyParts:size()
            shuffleList(bodyParts)
            Log.debug("Setting Blood Level bloodAmount:%.2f maxParts:%d bodyParts:%s", bloodAmount, maxParts, tostring(bodyParts))
            for i = 0, maxParts - 1 do
                local rand = ZombRandFloat(0.0, bloodBank)
                item:setBlood(bodyParts:get(i), rand)
                bloodBank = bloodBank - rand
                if bloodBank <= 0 then break end
            end
        end
        if bloodAmount > 0 then item:setBloodLevel(100 * bloodAmount) end
    end

    local holeConditionLoss = numHoles * condLossPerHole
    Log.debug("Cond Calc max:%d base:%d holes:%d holeLoss:%d", maxCond, baseCond, numHoles, holeConditionLoss)
    item:setCondition(baseCond)
    item:synchWithVisual()

    Log.info("Modified Item Durability item:%s cond:%d/%d", tostring(item), baseCond, maxCond)
end

_G.STA_ClothingCondition_Server = Server
return Server