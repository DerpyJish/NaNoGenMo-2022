---@class Arc
---@field constraint Constraint
---@field subject Value
---@field index integer
---@field funct function
---@field values Value[]

Arc = {}
local __Arc = {}

---@param constraint Constraint
---@param index integer
---@return Arc
function Arc.new(constraint, index)
    if index < 1 then
        error(("Attempt to create Arc for value %s of Constraint."):format(index))
    end
    if index > #constraint.values then
        error(("Attempt to create Arc for value %s of Constraint. (Constraint only has %s values)"):format(
            index,
            #constraint.values
        ))
    end

    local Arc = setmetatable({ ---@type Arc
        constraint = constraint,
        subject = constraint.values[index],
        index = index
    }, __Arc)

    return Arc
end

---@param self Arc
function __Arc:__tostring()
    return tostring(self):gsub("table", "arc")
end

---@param self Arc
---@param index string|number
function __Arc:__index(index)
    if index == "funct" then
        return self.constraint.funct
    end

    if index == "values" then
        return self.constraint.values
    end

    return __Arc[index]
end
