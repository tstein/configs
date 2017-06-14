-- Caffeination.
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

-- Hotkeys.
hs.hotkey.bind({"cmd", "option"}, "L", function()
  hs.caffeinate.lockScreen()
end)

-- Auto-reload this file when it's saved.
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
