require "Solver.Solver"
require "Solver.Value"
require "Solver.Constraint"

local domain = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
local givens = {
    [3] = 2,
    [7] = 7,
    [9] = 3,
    [11] = 3,
    [15] = 2,
    [17] = 8,
    [20] = 9,
    [21] = 1,
    [22] = 7,
    [26] = 5,
    [33] = 7,
    [36] = 8,
    [37] = 3,
    [39] = 8,
    [40] = 5,
    [45] = 4,
    [46] = 6,
    [49] = 9,
    [51] = 1,
    [60] = 3,
    [61] = 6,
    [62] = 4,
    [68] = 1,
    [69] = 8,
    [72] = 2,
    [74] = 5,
}

local function no_duplicates(...)
    local found = {}
    for _, v in ipairs({ ... }) do
        if found[v] then
            return false
        end
        found[v] = true
    end
    return true
end

local solver = Solver.new()

for i = 1, 81 do
    if givens[i] then
        Solver.value(solver, { givens[i] })
    else
        Solver.value(solver, domain)
    end
end

for i = 1, 9 do
    -- Rows
    local f = (i - 1) * 9
    Solver.constrain(solver,
        no_duplicates,
        solver.values[f + 1],
        solver.values[f + 2],
        solver.values[f + 3],
        solver.values[f + 4],
        solver.values[f + 5],
        solver.values[f + 6],
        solver.values[f + 7],
        solver.values[f + 8],
        solver.values[f + 9]
    )

    -- Columns
    Solver.constrain(solver,
        no_duplicates,
        solver.values[i],
        solver.values[i + 9],
        solver.values[i + 18],
        solver.values[i + 27],
        solver.values[i + 36],
        solver.values[i + 45],
        solver.values[i + 54],
        solver.values[i + 63],
        solver.values[i + 72]
    )

    -- Sqaures
    local c = ({ 1, 4, 7, 28, 31, 34, 55, 58, 61 })[i]
    Solver.constrain(solver,
        no_duplicates,
        solver.values[c],
        solver.values[c + 1],
        solver.values[c + 2],
        solver.values[c + 9],
        solver.values[c + 10],
        solver.values[c + 11],
        solver.values[c + 18],
        solver.values[c + 19],
        solver.values[c + 20]
    )
end

local running = true
while running do
    print(
        #solver.agenda .. " arcs on the agenda (" ..
        #solver.resolved .. "/" .. #solver.agenda + #solver.resolved .. " resolved)"
    )
    for i, value in ipairs(solver.values) do
        if #value.possible == 1 then
            io.write(value.possible[1] .. " ")
        else
            io.write(({ "₁", "₂", "₃", "₄", "₅", "₆", "₇", "₈", "₉" })[#value.possible] .. " ") -- If these don't render in Windows cmd, try the command `chcp 65001`
        end
        if i % 9 == 0 then
            print()
        end
    end
    print()
    running = not Solver.iterate(solver)
end
