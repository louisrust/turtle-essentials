local m = {}

local printDebug = false

-- log functions
local printInfo
local printDebug
printInfo = print

printDebug = function(msg)
    if not printDebug then return end
    term.setTextColor(colors.yellow)
    print("[debug] " .. msg)
    term.setTextColor(colors.white)
end

function m.setPrintInfo(handler)
    printInfo = handler
end

-- terminal functions
function m.askUser(message, intRequired)
    if intRequired==nil then intRequired = false end
    printInfo(message)
    
    local valid = false
    local input
    while not valid do
        input = read()
        if intRequired then
            input = tonumber(input)
            if (input==nil) then
                printInfo("Must be a number.")
                printInfo(message)
            else
                valid = true
            end
        else
            valid = true
        end
    end

    return input
end

-- items functions
function m.shouldSort()
    local incompleteStacks = {}

    -- if inventory is empty
    local totalCount = 0
    for i = 1,16 do
        totalCount = totalCount + turtle.getItemCount(i)
    end
    if totalCount==0 then
        printDebug("should not sort: inventory has no items")
        return false
    end

    -- inventory has items, check for empty gaps
    local prevCount = turtle.getItemCount(1)
    for i = 2,16 do
        local count = turtle.getItemCount()
        if count>prevCount then
            printDebug("should sort: inventory has gaps")
            return true
        end
        prevCount = count
    end

    -- no gaps, do normal search
    for i = 1,16 do
        local count = turtle.getItemCount(i)
        local item = turtle.getItemDetail(i)
        local freeSpace = turtle.getItemSpace(i)

        if item and item.name then
            for x = 1,#incompleteStacks do
                if incompleteStacks[x] == item.name then
                    printDebug("should sort: inventory has incomplete stacks that can be sorted")
                    return true
                end
            end
        end
        
        if count>0 and freeSpace>0 then
            table.insert(incompleteStacks, item.name)
        end
    end

    return false
end
function m.sortInv()
    if not m.shouldSort() then
        return
    end

    for x = 2,16 do
        if turtle.getItemCount(x)>0 then
            turtle.select(x)
            for y = 1,x do
                turtle.transferTo(y)
                if turtle.getItemCount(x)==0 then
                    break
                end
            end
        end
    end
end

function m.findEmptySlot(shouldSelect)
    -- find next empty slot
    -- returns slot number or -1 if no empty slots
    -- shouldSelect: whether or not to select the slot when found
    -- by default, this is true

    if shouldSelect==nil then shouldSelect = true end

    local slot = -1
    for i = 1,16 do
        local count = turtle.getItemCount(i)
        if (count==0) then
            slot = i
            break
        end
    end

    if shouldSelect and not slot==-1 then
        turtle.select(slot)
    end

    return slot
end

function m.getUserBlock(slot, message)
    -- get block name from user based on slot
    -- if slot is undefined, find next empty slot
    -- returns block name

    if not slot then slot = m.findEmptySlot() end
    message = message or "Insert item to use in slot"

    printInfo(message .. " " .. slot)
    local found = false
    while not found do
        -- check slot for items
        while not turtle.getItemDetail(slot) do
            sleep(0)
        end

        -- item found, get detail
        local block = turtle.getItemDetail(slot)
        if block and block.name then -- found, return block name
            found = true
            printInfo("using " .. block.name)
            return block.name
        end
    end
end

function m.countItems(name)
    local count = 0
    for i = 1,16 do
        local item = turtle.getItemDetail(i)
        if item and item.name and item.name==name then
            count = count+item.count
        end
    end
    return count
end

function m.waitForItem(name, count)
    local slot = 0
    printInfo("waiting for " .. name)
    os.pullEvent("turtle_inventory")
    while not found do
        for i = 1,16 do
            local item = turtle.getItemDetail(i)
            if item and item.name and item.name==name then
                slot = i
                found = true
                break
            end
        end
        sleep(0)
    end

    return slot
end

function m.findItem(name, shouldRequest)
    -- search for item in inventory and select
    -- name: item to search for
    -- shouldRequest: ask user for item if not found
    -- returns boolean found: true if found, false if not

    if shouldRequest==nil then shouldRequest = true end
    local found = false
    local slot = -1

    -- search for item
    for i = 1,16 do
        local item = turtle.getItemDetail(i)
        if item and item.name and item.name==name then
            slot = i
            found = true
            break
        end
    end

    -- item not found, request from user
    if shouldRequest and not found then
        slot = m.waitForItem(name, 1)
        found = true
    end

    -- item not found, cannot request, select empty slot or first
    if not shouldRequest and not found then
        slot = m.findEmptySlot()
        if slot==-1 then
            slot = 1
        end
    end

    turtle.select(slot)
    return found
end

-- replace functions
local function replaceHandler(block, placeFunction, digFunction)
    m.findItem(block)
    while not placeFunction() do
        digFunction()
    end
end

function m.replace(block)
    replaceHandler(block, turtle.place, turtle.dig)
end
function m.replaceDown(block)
    replaceHandler(block, turtle.placeDown, turtle.digDown)
end
function m.replaceUp(block)
    replaceHandler(block, turtle.placeUp, turtle.digUp)
end

-- turtle functions
m.dig = turtle.dig
m.digUp = turtle.digUp
m.digDown = turtle.digDown

-- move functions
local function forceMoveHandler(n, tMoveHandler, digHandler)
    if n==1 then
        while not tMoveHandler() do
            digHandler()
        end
    else
        for i = 1,n do
            while not tMoveHandler() do
                digHandler()
            end
        end
    end
end

local function moveHandler(n, force, tMoveHandler, digHandler)
    if force then
        forceMoveHandler(n, tMoveHandler, digHandler)
    else
        if n==1 then
            tMoveHandler()
        else
            for i = 1,n do
                tMoveHandler()
            end
        end
    end
end

function m.forward(n, force)
    if n==nil then n = 1 end
    if force==nil then force = true end
    moveHandler(n, force, turtle.forward, turtle.dig)
end
function m.back(n, force)
    if n==nil then n = 1 end
    if force==nil then force = true end

    local function digBack()
        m.turnLeft(2)
        m.digForward()
        m.turnLeft(2)
    end

    moveHandler(n, force, digBack)
end
function m.up(n, force)
    if n==nil then n = 1 end
    if force==nil then force = true end
    moveHandler(n, force, turtle.up, turtle.digUp)
end
function m.down(n, force)
    if n==nil then n = 1 end
    if force==nil then force = true end
    moveHandler(n, force, turtle.down, turtle.digDown)
end

function m.turnLeft(n)
    if n==1 or n==nil then
        turtle.turnLeft()
    else
        for i = 1,n do
            turtle.turnLeft()
        end
    end
end
function m.turnRight(n)
    if n==1 or n==nil then
        turtle.turnRight()
    else
        for i = 1,n do
            turtle.turnRight()
        end
    end
end

-- forward print functions
m.printDebug = printDebug
m.printInfo = printInfo

return m