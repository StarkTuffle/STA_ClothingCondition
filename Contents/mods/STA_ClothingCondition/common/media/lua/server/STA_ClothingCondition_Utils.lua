local Utils = STA_ClothingCondition_Utils or {}

Utils.modID = "STA_ClothingCondition"

Utils.SandboxDefaults = {
    ["NormalChanceBloody"] = 0.35,
    ["NormalChanceDirty"] = 0.70,
    ["NormalMinCond"] = 0.30,
    ["NormalMaxCond"] = 0.80,
    ["StoreChanceBloody"] = 0.00,
    ["StoreChanceDirty"] = 0.05,
    ["StoreMinCond"] = 0.80,
    ["StoreMaxCond"] = 0.99,
    ["TrashModifyItems"] = false,
    ["TrashChanceBloody"] = 0.50,
    ["TrashChanceDirty"] = 0.95,
    ["TrashMinCond"] = 0.10,
    ["TrashMaxCond"] = 0.50,
    ["PerfectCondChance"] = 0.10,
}

---@param key string
---@return any
local function getSandboxValue(key)
    local moduleName = Utils.modID
    if SandboxVars and SandboxVars[moduleName] and SandboxVars[moduleName][key] then
        return SandboxVars[moduleName][key]
    end
    return nil
end

---@param key string
---@return Boolean|nil
function Utils.getSandboxBool(key)
    local defaultVal = Utils.SandboxDefaults[key]
    local val = getSandboxValue(key)
    if val == nil then return type(defaultVal) == "boolean" and defaultVal or nil end
    if type(val) == "boolean" then return val end
    if type(val) == "number" then return val ~= 0 end
    if type(val) == "string" then
        local valLower = val:lower()
        return valLower == "true" or valLower =="1" or valLower == "yes" or valLower == "on"
    end
    return type(defaultVal) == "boolean" and defaultVal or nil
end

---@param key string
---@return number|nil
function Utils.getSandboxNum(key)
    local defaultVal = Utils.SandboxDefaults[key]
    local val = getSandboxValue(key)
    if val == nil then return type(defaultVal) == "number" and defaultVal or nil end
    if type(val) == "number" then return val end
    if type(val) == "boolean" then return val and 1 or 0 end
    if type(val) == "string" then
        local num = tonumber(val)
        if num then return num end
    end
    return type(defaultVal) == "number" and defaultVal or nil
end

_G.STA_ClothingCondition_Utils = Utils
return Utils