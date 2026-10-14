-- Mouse/nav F1-F5 sends Control + Option + Command + Shift + F1-F5.
-- These bundle IDs match the apps installed on this Mac, including Codex
-- packaged as ChatGPT.app. App assignments can change without reflashing ZMK.
local apps = {
    { key = "F1", name = "Teams", bundleID = "com.microsoft.teams2" },
    { key = "F2", name = "Sequel Ace", bundleID = "com.sequel-ace.sequel-ace" },
    { key = "F3", name = "PhpStorm", bundleID = "com.jetbrains.PhpStorm" },
    { key = "F4", name = "Firefox", bundleID = "org.mozilla.firefox" },
    { key = "F5", name = "Codex", bundleID = "com.openai.codex" },
}

local modifiers = { "ctrl", "alt", "cmd", "shift" }
local module = { hotkeys = {} }
local pendingTimer

local function cancelPending()
    if pendingTimer then
        pendingTimer:stop()
        pendingTimer = nil
    end
end

local function selectApp(target)
    -- A newer shortcut supersedes any pending pointer move from the old one.
    cancelPending()
    if not hs.application.launchOrFocusByBundleID(target.bundleID) then
        hs.alert.show("Could not open " .. target.name)
        return
    end

    local deadline = hs.timer.secondsSinceEpoch() + 8
    local lastWindowID, lastFrame, stableSince

    -- Activation, app startup and Spaces transitions are asynchronous.
    -- Wait for the target window and its frame to settle before centering.
    pendingTimer = hs.timer.doEvery(0.1, function()
        local now = hs.timer.secondsSinceEpoch()
        if now >= deadline then
            cancelPending()
            hs.alert.show("No focused window for " .. target.name)
            return
        end

        local window = hs.window.focusedWindow()
        local app = window and window:application()
        if not app or app:bundleID() ~= target.bundleID or not app:isFrontmost() then
            lastWindowID, lastFrame, stableSince = nil, nil, nil
            return
        end

        local frame = window:frame()
        if frame.w <= 0 or frame.h <= 0 then
            lastWindowID, lastFrame, stableSince = nil, nil, nil
            return
        end

        if lastWindowID ~= window:id() or not lastFrame
            or frame.x ~= lastFrame.x or frame.y ~= lastFrame.y
            or frame.w ~= lastFrame.w or frame.h ~= lastFrame.h then
            lastWindowID, lastFrame, stableSince = window:id(), frame, now
            return
        end

        if now - stableSince >= 0.4 then
            cancelPending()
            hs.mouse.absolutePosition({
                x = frame.x + frame.w / 2,
                y = frame.y + frame.h / 2,
            })
        end
    end)
end

for _, target in ipairs(apps) do
    local hotkey = hs.hotkey.bind(modifiers, target.key, function()
        selectApp(target)
    end)
    if hotkey then
        table.insert(module.hotkeys, hotkey)
    else
        hs.alert.show("Could not bind Glove80 " .. target.key)
    end
end

function module.stop()
    cancelPending()
    for _, hotkey in ipairs(module.hotkeys) do
        hotkey:delete()
    end
    module.hotkeys = {}
end

return module
