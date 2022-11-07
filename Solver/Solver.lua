require "Solver.Value"
require "Solver.Constraint"
require "Solver.Arc"

---@class Solver
---
---@field values Value[]
---@field agenda Arc[]
---@field resolved Arc[]

Solver = {}
local __Solver = {}

---@return Solver
function Solver.new()
    local solver = setmetatable({
        values = {},
        agenda = {},
        resolved = {}
    }, __Solver)

    return solver
end

---@param self Solver
function __Solver:__tostring()
    return tostring(self):gsub("table", "solver")
end

-- SET UP --

---@param self Solver
---@param domain any[]
---@return Value
function Solver:value(domain)
    local value = Value.new(domain)
    table.insert(self.values, value)
    return value
end

---@param self Solver
---@param f function
---@param ... Value
---@return Constraint
function Solver:constrain(f, ...)
    local constraint = Constraint.new(f, ...)
    for i = 1, #constraint.values do
        table.insert(self.agenda, Arc.new(constraint, i))
    end
    return constraint
end

-- SOLVER --

---@param self Solver
---@return boolean
function Solver:iterate()
    if #self.agenda > 0 then
        Solver.prune_next_arc(self)
        return false
    end

    return not Solver.collapse_next_value(self)
end

---@param self Solver
function Solver:prune_next_arc()
    local arc = table.remove(self.agenda, 1) ---@type Arc
    local subject = arc.subject

    if #subject.possible < 2 then
        table.insert(self.resolved, arc)
        return
    end

    local indexes = {}
    local values = {}

    ---@param ignore integer
    ---@param i? integer
    ---@return boolean
    local function next(ignore, i)
        i = i or 1

        if i > #arc.values then
            return false
        end

        if i == ignore then
            return next(ignore, i + 1)
        end

        local overflow = indexes[i] == #arc.values[i].possible
        if overflow then
            indexes[i] = 1
        else
            indexes[i] = indexes[i] + 1
        end

        values[i] = arc.values[i].possible[indexes[i]]

        if overflow then
            return next(ignore, i + 1)
        end

        return true
    end

    local possibilities_modifed = false
    for i = #subject.possible, 1, -1 do
        for j = 1, #arc.values do
            indexes[j] = 1
            values[j] = arc.values[j].possible[1]
        end
        indexes[arc.index] = i
        values[arc.index] = arc.values[arc.index].possible[i]

        local no_valid_configuration = true
        local looking = true
        while looking do
            if arc.constraint.funct(table.unpack(values)) then
                no_valid_configuration = false
                break
            end
            looking = next(arc.index)
        end

        if no_valid_configuration then
            table.remove(subject.possible, i)
            possibilities_modifed = true
        end
    end

    if possibilities_modifed then
        Solver.add_relevant_arcs_to_agenda(self, subject)
    end

    table.insert(self.resolved, arc)
end

---@param self Solver
---@return boolean
function Solver:collapse_next_value()

    -- Find value with the lowest number of possible values
    local value = nil ---@type Value
    local count = math.huge ---@type integer
    for i, other in ipairs(self.values) do
        local c = #other.possible
        if c > 1 and c < count then
            value = other
            count = c
            if c == 2 then
                break
            end
        end
    end

    if not value then
        return false
    end

    -- Choose a random possibility to be the value, remove the others
    local j = math.random(count)
    for i = count, 1, -1 do
        if i ~= j then
            table.remove(value.possible, i)
        end
    end
    Solver.add_relevant_arcs_to_agenda(self, value)

    return true
end

-- HELPER --

---@param self Solver
---@param value Value
function Solver:add_relevant_arcs_to_agenda(value)
    for i = #self.resolved, 1, -1 do
        local arc = self.resolved[i]
        for _, other in ipairs(arc.values) do
            if other == value and value ~= arc.subject then
                table.insert(self.agenda, arc)
                table.remove(self.resolved, i)
                break
            end
        end
    end
end
