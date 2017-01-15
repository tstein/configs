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

-- Auto-sync music when on home wifi.
local musicNotification
function withdrawMusicNotification()
    if musicNotification ~= nil then
        musicNotification:withdraw()
        musicNotification = nil
    end
end

function wifiChanged(watcher, message, interface)
    function syncOutput(task, stdOut, stdErr)
        if stdOut ~= "" then print(stdOut) end
        if stdErr ~= "" then print(stdErr) end
        return true
    end

    function syncComplete(exitCode, stdOut, stdErr)
        withdrawMusicNotification()
        if exitCode == 0 then
            musicNotification = hs.notify.show("music synced", "", "")
        else
            musicNotification = hs.notify.show(
                "error syncing music",
                "Check the hs console for details.",
                "")
        end
    end

    if message ~= "SSIDChange" then return end

    local newSSID = hs.wifi.currentNetwork(interface)
    if newSSID == "armory" or newSSID == "armory legacy" then
        if hs.fs.volume.allVolumes()["/Volumes/bonus"] ~= nil then
            withdrawMusicNotification()
            musicNotification = hs.notify.show("syncing music...", "", "")
            local syncTask = hs.task.new(
                "/usr/local/bin/zsh",
                syncComplete,
                syncOutput,
                {"-ic", "syncmusic"})
            syncTask:start()
        end
    end
end
local wifiWatcher = hs.wifi.watcher.new(wifiChanged)
wifiWatcher:start()

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
