local tk = require("lib/turtlekit")

local replaceBlock
local fwdCount = 0
local running = true
local lavaFound = false

local function goBack()
    tk.turnRight(2)
    tk.forward(fwdCount)
    tk.turnRight(2)
end

local function stop()
    running = false
    goBack()
end

local function printStatus()
    term.clear()
    term.setCursorPos(1,1)
    print("replacement block: " .. replaceBlock)
    print("fuel: " .. turtle.getFuelLevel() .. "/" .. turtle.getFuelLimit())
end

tk.findItem("minecraft:bucket")
replaceBlock = tk.getUserBlock(nil, "Insert replacement block in slot")
printStatus()

while running do
    local b,d = turtle.inspectDown()
    if b and d.name=="minecraft:lava" then
        lavaFound = true

        -- refuel
        tk.findItem("minecraft:bucket")
        turtle.placeDown()
        turtle.refuel()
        printStatus()

        -- replace
        local found = tk.findItem(replaceBlock, true)
        if found then
            turtle.placeDown()
        end
    else
        if lavaFound then
            stop()
        end
    end

    if not turtle.forward() or turtle.getFuelLevel()==turtle.getFuelLimit() then
        stop()
    else
        fwdCount = fwdCount+1
    end
end