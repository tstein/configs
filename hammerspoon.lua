-- caffeination
local caffeine = hs.menubar.new()
function setCaffeineDisplay(state)
    if state then
        caffeine:setTitle("☕️")
    else
        caffeine:setTitle("〰")
    end
end

function caffeineClicked()
    setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
    caffeine:setClickCallback(caffeineClicked)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end

-- screen-locking
hs.hotkey.bind({"cmd", "option"}, "L", function()
  hs.caffeinate.lockScreen()
end)

-- screen scaling
-- list of modes is hand-picked for a 13" rMBP
local modes = {}
modes[0] = {w = 1024, h =  640}
modes[1] = {w = 1280, h =  800}
modes[2] = {w = 1440, h =  900}
modes[3] = {w = 1680, h = 1050}
local modeIndex = 1

function setNewMode()
    local newMode = modes[modeIndex]
    local newWidth = newMode['w']
    local newHeight = newMode['h']
    print("changing resolution to " .. newWidth .. "x" .. newHeight)
    -- 2 means hidpi
    hs.screen.primaryScreen():setMode(newWidth, newHeight, 2)
end

hs.hotkey.bind({"cmd", "option"}, "down", function()
    if modeIndex > 0 then
        modeIndex = modeIndex - 1
        setNewMode()
    end
end)

hs.hotkey.bind({"cmd", "option"}, "up", function()
    if modeIndex < 3 then
        modeIndex = modeIndex + 1
        setNewMode()
    end
end)

-- auto-reload this file when it's saved
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
local hsInitWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
local codeConfigWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/code/configs/hammerspoon.lua", reloadConfig):start()
hs.notify.withdrawAll()
hs.notify.show("config loaded", "", "")
