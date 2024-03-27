local tk = require("lib/turtlekit")

local length
local block

local args = {...}
length = tonumber(args[1])
if length==nil then
    length = tk.askUser("Enter length: ",true)
end

block = tk.getUserBlock(1)

for i = 1,length do
    tk.dig()
    tk.forward()
    tk.digUp()
    tk.digDown()

    local found, slot = tk.findItem(block)
    if found then
        turtle.select(slot)
    else
        print("no items remaining - stopped with "..length-i.." blocks remaining")
        break
    end
    tk.placeDown()
end