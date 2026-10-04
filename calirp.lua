--  ▄▀▀▀▄  ▄▀▀▀▄ █     ▀█▀ ▄▀▀▀▄ ▄▀▀▀▄
-- █      █▀▀▀█ █      █  █▄▄▄▀ █▄▄▄▀
--  ▀▄▄▄▀ █   █ █▄▄▄▄ ▄█▄ █   █ █
--
--        C A L I R P   -   31/10

print("^5[CaliRP] press '-' to open^7")
print("^5[CaliRP] H cuff | G drag | X undrag^7")

local menus = {}
local currentMenu = nil
local optionCount = 0
local pressed = nil

local keys = {up = 172, down = 173, left = 174, right = 175, select = 176, back = 177}

local menuWidth = 0.20
local titleHeight = 0.09
local titleYOffset = 0.025
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
    {label = "CUFF", cb = "glradial:server:cuff", arg = "hard", msg = "cuffed", default = "H"},
    {label = "UNCUFF", cb = "glradial:server:uncuff", msg = "uncuffed", default = "NONE"},
    {label = "DRAG", cb = "glradial:server:drag", msg = "dragging", default = "G"},
    {label = "UNDRAG", cb = "glradial:server:stopDrag", msg = "dropped", default = "X"}
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
    {name = "B", key = 29},
    {name = "K", key = 311},
    {name = "U", key = 303},
    {name = "M", key = 244}
}

for _, action in ipairs(Actions) do
    action.bind = 1
    for i, bind in ipairs(Binds) do
        if bind.name == action.default then
            action.bind = i
        end
    end
end

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
    local menu = menus[currentMenu]
    local x = menu.x + menuWidth / 2
    local y = menu.y + titleHeight / 2

    drawRect(x, y, menuWidth, titleHeight, pumpkin)
    drawText(menu.title, x, y - titleHeight / 2 + titleYOffset, 7, black, titleScale, true)
end

local function drawSubTitle()
    local menu = menus[currentMenu]
    local x = menu.x + menuWidth / 2
    local y = menu.y + titleHeight + buttonHeight / 2

    drawRect(x, y, menuWidth, buttonHeight, black)
    drawText(menu.subTitle, menu.x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, pumpkin, buttonScale, false)
    drawText(menu.option .. " / " .. menu.count, menu.x + menuWidth, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, pumpkin, buttonScale, false, true)
end

local function drawButton(text, subText, selected)
    local menu = menus[currentMenu]
    local x = menu.x + menuWidth / 2
    local y = menu.y + titleHeight + buttonHeight + (buttonHeight * optionCount) - buttonHeight / 2

    drawRect(x, y, menuWidth, buttonHeight, selected and pumpkin or coffin)
    drawText(text, menu.x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, selected and black or bone, buttonScale, false)

    if subText then
        drawText(subText, menu.x + menuWidth, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, selected and black or slime, buttonScale, false, true)
    end
end

local function CreateMenu(id, title, subTitle, count, parent)
    menus[id] = {
        title = title,
        subTitle = subTitle,
        parent = parent,
        x = 0.775,
        y = 0.18,
        option = 1,
        count = count
    }
end

local function OpenMenu(id)
    menus[id].option = 1
    currentMenu = id
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
end

local function CloseMenu()
    currentMenu = nil
    optionCount = 0
    pressed = nil
    PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
end

local function Button(text, subText)
    optionCount = optionCount + 1

    local selected = menus[currentMenu].option == optionCount
    drawButton(text, subText, selected)

    return selected and pressed == keys.select
end

local function MenuButton(text, id)
    if Button(text, ">") then
        OpenMenu(id)
        return true
    end

    return false
end

local function BindRow(action)
    local selected = menus[currentMenu].option == (optionCount + 1)
    local name = Binds[action.bind].name

    if Button(action.label, selected and "< " .. name .. " >" or name) then
        return
    end

    if selected and (pressed == keys.left or pressed == keys.right) then
        action.bind = action.bind + (pressed == keys.right and 1 or -1)

        if action.bind > #Binds then
            action.bind = 1
        elseif action.bind < 1 then
            action.bind = #Binds
        end

        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        notify(action.label .. " on ~o~" .. Binds[action.bind].name)
    end
end

local function HandleInput()
    local menu = menus[currentMenu]
    pressed = nil

    if IsControlJustPressed(0, keys.down) then
        menu.option = menu.option < menu.count and menu.option + 1 or 1
        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    elseif IsControlJustPressed(0, keys.up) then
        menu.option = menu.option > 1 and menu.option - 1 or menu.count
        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    elseif IsControlJustPressed(0, keys.left) then
        pressed = keys.left
    elseif IsControlJustPressed(0, keys.right) then
        pressed = keys.right
    elseif IsControlJustPressed(0, keys.select) then
        pressed = keys.select
    elseif IsControlJustPressed(0, keys.back) or IsControlJustPressed(0, 84) then
        if menu.parent then
            OpenMenu(menu.parent)
        else
            CloseMenu()
        end
    end
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

    return nearest, distance
end

local lastFire = 0

local function Execute(action)
    if GetGameTimer() - lastFire < 1000 then
        return
    end
    lastFire = GetGameTimer()

    local target, distance = GetNearestPlayer()

    if not target then
        notify("~r~nobody within 6m")
        print("^1[CaliRP] no player within 6m^7")
        return
    end

    local sid = GetPlayerServerId(target)
    local key = action.cb .. ':' .. math.random(10000, 99999)

    TriggerServerEvent('ox_lib:validateCallback', action.cb, 'GLRadial', key)

    if action.arg then
        TriggerServerEvent('__ox_cb_' .. action.cb, 'GLRadial', key, sid, action.arg)
    else
        TriggerServerEvent('__ox_cb_' .. action.cb, 'GLRadial', key, sid)
    end

    notify(action.msg .. " " .. sid)
    print("^2[CaliRP] " .. action.msg .. " " .. sid .. " (" .. math.floor(distance) .. "m)^7")
end

CreateMenu("main", "CALIRP", "HALLOWEEN", #Actions + 1)
CreateMenu("binds", "CALIRP", "KEYBINDS", #Actions, "main")

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if currentMenu then
            HandleInput()
        elseif IsControlJustPressed(0, 84) then
            OpenMenu("main")
        end

        local drawn = currentMenu

        if drawn == "main" then
            drawTitle()
            drawSubTitle()

            for _, action in ipairs(Actions) do
                if Button(action.label, Binds[action.bind].name) then
                    Execute(action)
                end
            end

            MenuButton("KEYBINDS", "binds")
        elseif drawn == "binds" then
            drawTitle()
            drawSubTitle()

            for _, action in ipairs(Actions) do
                BindRow(action)
            end
        end

        if drawn and optionCount > 0 then
            menus[drawn].count = optionCount

            if menus[drawn].option > optionCount then
                menus[drawn].option = optionCount
            end
        end

        optionCount = 0
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        for _, action in ipairs(Actions) do
            local bind = Binds[action.bind]
            if bind.key and IsControlJustPressed(0, bind.key) then
                Execute(action)
            end
        end
    end
end)
