--  ▄▀▀▀▄  ▄▀▀▀▄ █     ▀█▀ ▄▀▀▀▄ ▄▀▀▀▄
-- █      █▀▀▀█ █      █  █▄▄▄▀ █▄▄▄▀
--  ▀▄▄▄▀ █   █ █▄▄▄▄ ▄█▄ █   █ █
--
--        C A L I R P   -   31/10

print("^5[CaliRP] press '-' to open^7")
print("^5[CaliRP] arrows left/right to set a keybind^7")

local CaliRP = {}

local menus = {}
local currentMenu = nil
local optionCount = 0
local currentKey = nil

local keys = {up = 172, down = 173, left = 174, right = 175, select = 176, back = 177}

local menuWidth = 0.20
local titleHeight = 0.09
local titleYOffset = 0.026
local titleScale = 0.95
local buttonHeight = 0.038
local buttonFont = 4
local buttonScale = 0.36
local buttonTextXOffset = 0.006
local buttonTextYOffset = 0.006

local pumpkin = {r = 255, g = 110, b = 0, a = 255}
local black = {r = 10, g = 5, b = 14, a = 255}
local bone = {r = 235, g = 225, b = 240, a = 255}
local slime = {r = 140, g = 255, b = 90, a = 255}
local coffin = {r = 14, g = 8, b = 20, a = 225}

local Actions = {
    {label = "CUFF", event = "cuff", bind = 1},
    {label = "UNCUFF", event = "uncuff", bind = 1},
    {label = "DRAG", event = "drag", bind = 1},
    {label = "UNDRAG", event = "undrag", bind = 1}
}

local Binds = {
    {name = "NONE"},
    {name = "F1", key = 288},
    {name = "F2", key = 289},
    {name = "F3", key = 170},
    {name = "F5", key = 166},
    {name = "F6", key = 167},
    {name = "F7", key = 168},
    {name = "E", key = 38},
    {name = "G", key = 47},
    {name = "H", key = 74},
    {name = "X", key = 73},
    {name = "Z", key = 20},
    {name = "K", key = 311},
    {name = "U", key = 303},
    {name = "M", key = 244}
}

local function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString("~o~CaliRP~s~ " .. text)
    DrawNotification(false, true)
end

local function drawText(text, x, y, font, colour, scale, centre, alignRight)
    SetTextColour(colour.r, colour.g, colour.b, colour.a)
    SetTextFont(font)
    SetTextScale(scale, scale)

    if centre then
        SetTextCentre(true)
    elseif alignRight then
        SetTextWrap(menus[currentMenu].x, menus[currentMenu].x + menuWidth - buttonTextXOffset)
        SetTextRightJustify(true)
    end

    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

local function drawRect(x, y, width, height, colour)
    DrawRect(x, y, width, height, colour.r, colour.g, colour.b, colour.a)
end

local function drawTitle()
    local x = menus[currentMenu].x + menuWidth / 2
    local y = menus[currentMenu].y + titleHeight / 2

    drawRect(x, y, menuWidth, titleHeight, pumpkin)
    drawText(menus[currentMenu].title, x, y - titleHeight / 2 + titleYOffset, 7, black, titleScale, true)
end

local function drawSubTitle()
    local x = menus[currentMenu].x + menuWidth / 2
    local y = menus[currentMenu].y + titleHeight + buttonHeight / 2

    drawRect(x, y, menuWidth, buttonHeight, black)
    drawText(
        menus[currentMenu].subTitle,
        menus[currentMenu].x + buttonTextXOffset,
        y - buttonHeight / 2 + buttonTextYOffset,
        buttonFont,
        pumpkin,
        buttonScale,
        false
    )
    drawText(
        menus[currentMenu].currentOption .. " / " .. #Actions,
        menus[currentMenu].x + menuWidth,
        y - buttonHeight / 2 + buttonTextYOffset,
        buttonFont,
        pumpkin,
        buttonScale,
        false,
        true
    )
end

local function drawButton(text, subText)
    local x = menus[currentMenu].x + menuWidth / 2
    local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * optionCount) - buttonHeight / 2
    local selected = menus[currentMenu].currentOption == optionCount

    drawRect(x, y, menuWidth, buttonHeight, selected and pumpkin or coffin)
    drawText(
        text,
        menus[currentMenu].x + buttonTextXOffset,
        y - buttonHeight / 2 + buttonTextYOffset,
        buttonFont,
        selected and black or bone,
        buttonScale,
        false
    )

    if subText then
        drawText(
            subText,
            menus[currentMenu].x + menuWidth,
            y - buttonHeight / 2 + buttonTextYOffset,
            buttonFont,
            selected and black or slime,
            buttonScale,
            false,
            true
        )
    end
end

function CaliRP.CreateMenu(id, title, subTitle)
    menus[id] = {
        title = title,
        subTitle = subTitle,
        visible = false,
        x = 0.775,
        y = 0.18,
        currentOption = 1
    }
end

function CaliRP.IsOpen(id)
    return menus[id] and menus[id].visible
end

function CaliRP.OpenMenu(id)
    if menus[id] then
        menus[id].visible = true
        menus[id].currentOption = 1
        currentMenu = id
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end
end

function CaliRP.CloseMenu()
    if menus[currentMenu] then
        menus[currentMenu].visible = false
        PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        optionCount = 0
        currentMenu = nil
        currentKey = nil
    end
end

function CaliRP.Button(text, subText)
    optionCount = optionCount + 1
    drawButton(text, subText)

    if menus[currentMenu].currentOption == optionCount and currentKey == keys.select then
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        return true
    end

    return false
end

function CaliRP.BindButton(action)
    local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)
    local label = Binds[action.bind].name

    if isCurrent then
        label = "< " .. label .. " >"
    end

    if CaliRP.Button(action.label, label) then
        return true
    elseif isCurrent then
        if currentKey == keys.left then
            action.bind = action.bind - 1
            if action.bind < 1 then
                action.bind = #Binds
            end
            PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            notify(action.label .. " bound to ~o~" .. Binds[action.bind].name)
        elseif currentKey == keys.right then
            action.bind = action.bind + 1
            if action.bind > #Binds then
                action.bind = 1
            end
            PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            notify(action.label .. " bound to ~o~" .. Binds[action.bind].name)
        end
    end

    return false
end

function CaliRP.Display()
    drawTitle()
    drawSubTitle()

    currentKey = nil

    if IsControlJustPressed(0, keys.down) then
        if menus[currentMenu].currentOption < optionCount then
            menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
        else
            menus[currentMenu].currentOption = 1
        end
        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    elseif IsControlJustPressed(0, keys.up) then
        if menus[currentMenu].currentOption > 1 then
            menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
        else
            menus[currentMenu].currentOption = optionCount
        end
        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    elseif IsControlJustPressed(0, keys.left) then
        currentKey = keys.left
    elseif IsControlJustPressed(0, keys.right) then
        currentKey = keys.right
    elseif IsControlJustPressed(0, keys.select) then
        currentKey = keys.select
    elseif IsControlJustPressed(0, keys.back) or IsControlJustPressed(0, 84) then
        CaliRP.CloseMenu()
    end

    optionCount = 0
end

local function GetNearestPlayer()
    local myCoords = GetEntityCoords(PlayerPedId())
    local nearest, distance = nil, 6.0

    for _, player in ipairs(GetActivePlayers()) do
        if player ~= PlayerId() then
            local ped = GetPlayerPed(player)
            if DoesEntityExist(ped) then
                local dist = #(myCoords - GetEntityCoords(ped))
                if dist < distance then
                    nearest, distance = player, dist
                end
            end
        end
    end

    return nearest
end

local function Execute(event)
    local target = GetNearestPlayer()

    if not target then
        notify("~r~nobody within 6m")
        return
    end

    local sid = GetPlayerServerId(target)
    local randId = 'glradial:server:' .. event .. ':' .. math.random(10000, 99999)

    if event == "cuff" then
        TriggerServerEvent('__ox_cb_glradial:server:cuff', 'GLRadial', randId, sid, 'hard')
        notify("cuffed " .. sid)
    elseif event == "uncuff" then
        TriggerServerEvent('__ox_cb_glradial:server:uncuff', 'GLRadial', randId, sid)
        notify("uncuffed " .. sid)
    elseif event == "drag" then
        TriggerServerEvent('__ox_cb_glradial:server:drag', 'GLRadial', randId, sid)
        notify("dragging " .. sid)
    elseif event == "undrag" then
        TriggerServerEvent('__ox_cb_glradial:server:stopDrag', 'GLRadial', randId, sid)
        notify("dropped " .. sid)
    end
end

CaliRP.CreateMenu("main", "CALIRP", "HALLOWEEN")

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if CaliRP.IsOpen("main") then
            for _, action in ipairs(Actions) do
                if CaliRP.BindButton(action) then
                    Execute(action.event)
                end
            end
            CaliRP.Display()
        elseif IsControlJustPressed(0, 84) then
            CaliRP.OpenMenu("main")
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if not CaliRP.IsOpen("main") then
            for _, action in ipairs(Actions) do
                local bind = Binds[action.bind]
                if bind.key and IsControlJustPressed(0, bind.key) then
                    Execute(action.event)
                end
            end
        end
    end
end)
