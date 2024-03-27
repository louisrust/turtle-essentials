local tk = require("lib/turtlekit")

local block
local length

-- get length
local args = {...}
length = tonumber(args[1])
if length==nil then
    length = tk.askUser("Enter length: ",true)
end

local function calculateFuelUsage()
    local fuelPerRun = 11
    local fuelRunning = length*fuelPerRun
    local fuelBack = length

    return fuelRunning + fuelBack
end

local function printStatus()
    term.clear()
    term.setCursorPos(1,1)
    tk.printInfo("Using " .. block)
    tk.printInfo("Fuel: " .. turtle.getFuelLevel())
end

local function run()
    printStatus()
    -- middle col
    tk.dig()
    tk.forward()
    tk.digUp()
    tk.digDown()
    tk.down()
    tk.replaceDown(block)
    tk.turnLeft()

    -- left col
    tk.dig()
    tk.forward()
    tk.replaceDown(block)
    tk.replace(block)
    tk.digUp()
    tk.up()
    tk.replace(block)
    tk.digUp()
    tk.up()
    tk.replace(block)
    tk.replaceUp(block)
    tk.turnRight(2)
    tk.dig()

    -- middle again
    tk.forward()
    tk.replaceUp(block)
    tk.dig()
    
    -- right col
    tk.forward() -- top right
    tk.replaceUp(block)
    tk.replace(block)
    tk.digDown()
    tk.down() -- middle
    tk.replace(block)
    tk.digDown()
    tk.down() -- bottom right
    tk.replace(block)
    tk.replaceDown(block)
    tk.turnLeft(2)
    
    -- back to origin
    tk.forward()
    tk.turnRight()
    tk.up()
end

local function init()
    block = tk.getUserBlock(1)

    local fuelStart = turtle.getFuelLevel()
    tk.printInfo("current fuel: " .. fuelStart)
    local fuelUsageEstimated = calculateFuelUsage()
    tk.printInfo("estimated fuel usage: " .. fuelUsageEstimated)
    if fuelStart<fuelUsageEstimated then
        tk.printInfo("extra fuel required to run: " .. fuelStart-fuelUsageEstimated)
    end

    for i = 1,length do
        run()
    end

    tk.turnLeft(2)

    -- go back
    tk.forward(length)
    tk.turnLeft(2)
    tk.sortInv()

    local fuelEnd = turtle.getFuelLevel()
    local fuelUsageActual = fuelStart-fuelEnd
    tk.printDebug("estimated fuel usage: " .. fuelUsageEstimated)
    tk.printDebug("actual fuel usage: " .. fuelUsageActual)
end

init()