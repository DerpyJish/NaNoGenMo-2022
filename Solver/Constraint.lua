---@class Constraint
---@field funct function
---@field values Value[]

Constraint = {}
local __Constraint = {}

---@param f function
---@param ... Value
---@return Constraint
function Constraint.new(f, ...)
    local constraint = setmetatable({ ---@type Constraint
        funct = f,
        values = { ... }
    }, __Constraint)

    return constraint
end

---@param self Constraint
function __Constraint:__tostring()
    return tostring(self):gsub("table", "constraint")
end
