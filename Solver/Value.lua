---@class Value
---@field domain any[]
---@field possible any[]
---@field value any
---@field resolved boolean

Value = {}
local __Value = {}

---@param domain any[]
---@return Value
function Value.new(domain)
    local value = setmetatable({ ---@type Value
        domain = domain,
        possible = {}
    }, __Value)

    for _, v in ipairs(domain) do
        table.insert(value.possible, v)
    end

    return value
end

---@param self Value
function __Value:__tostring()
    return "{ " .. table.concat(self.possible, ", ") .. " }"
end

---@param self Value
---@param index string|integer
function __Value:__index(index)
    if index == "resolved" then
        return #self.possible == 1
    end

    if index == "value" and #self.possible == 1 then
        return self.possible[1]
    end
end
