--[[
wget http://192.168.0.52:8080/installer.lua installer.lua
---]]

local function createFolder(path)
    if fs.exists(path) and fs.isDir(path) then return end
    shell.run("mkdir " .. path)
end
local function dlFile(urlPath, path)
    path = path or urlPath

    if fs.exists(path) then
        shell.run("rm " .. path)
    end
    shell.run("wget http://192.168.0.52:8080/" .. urlPath .. " " .. path)
end

createFolder("lib")
dlFile("installer.lua")
dlFile("lib/turtlekit.lua")
dlFile("safetunnel.lua")
dlFile("lavaRefuel.lua")
dlFile("quicktunnel.lua")

term.clear()
term.setCursorPos(1,1)
print("done")