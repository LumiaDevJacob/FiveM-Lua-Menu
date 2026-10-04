--   ██████╗ █████╗ ██╗     ██╗██████╗ ██████╗
--  ██╔════╝██╔══██╗██║     ██║██╔══██╗██╔══██╗
--  ██║     ███████║██║     ██║██████╔╝██████╔╝
--  ██║     ██╔══██║██║     ██║██╔══██╗██╔═══╝
--  ╚██████╗██║  ██║███████╗██║██║  ██║██║
--   ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═╝╚═╝
--
--  Open menu: '-' (Minus)   Move: Arrow Up / Arrow Down   Select: Enter   Close: Backspace

print("^5[CaliRP] Loaded - press '-' (Minus) to open^7")

local Menu = {
    isOpen = false,
    index = 1,
    x = 0.845,
    y = 0.50,
    width = 0.145,
    titleHeight = 0.055,
    itemHeight = 0.034
}

local Toggles = {
    { label = "Cuff", action = "cuff", state = false },
    { label = "Uncuff", action = "uncuff", state = false }
}

local function Notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, true)
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

local function DrawTextEx(text, x, y, scale, r, g, b, centre, alignRight)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextDropShadow()

    if centre then
        SetTextCentre(true)
    elseif alignRight then
        SetTextWrap(0.0, x)
        SetTextRightJustify(true)
    end

    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

local function DrawMenu()
    local x, y = Menu.x, Menu.y
    local w = Menu.width
    local titleY = y - Menu.titleHeight / 2

    DrawRect(x, titleY, w, Menu.titleHeight, 20, 110, 220, 255)
    DrawTextEx("CaliRP", x, titleY - 0.019, 0.55, 255, 255, 255, true)

    for i, option in ipairs(Toggles) do
        local itemY = y + Menu.itemHeight * (i - 0.5)
        local selected = (Menu.index == i)

        DrawRect(x, itemY, w, Menu.itemHeight, selected and 245 or 10, selected and 245 or 10,
            selected and 245 or 15, selected and 230 or 190)

        local tr = selected and 15 or 240
        local tg = selected and 15 or 240
        local tb = selected and 15 or 240

        DrawTextEx(option.label, x - w / 2 + 0.008, itemY - 0.011, 0.34, tr, tg, tb)
        DrawTextEx(option.state and "ON" or "OFF", x + w / 2 - 0.008, itemY - 0.011, 0.34,
            option.state and (selected and 20 or 80) or tr,
            option.state and (selected and 140 or 220) or tg,
            option.state and (selected and 60 or 120) or tb, false, true)
    end

    local footerY = y + Menu.itemHeight * #Toggles
    DrawRect(x, footerY + 0.012, w, 0.024, 20, 110, 220, 255)
    DrawTextEx(Menu.index .. " / " .. #Toggles, x, footerY + 0.004, 0.28, 255, 255, 255, true)
end

local function RunToggle(index)
    local option = Toggles[index]
    local target = GetNearestPlayer()

    if not target then
        Notify("~r~CaliRP~s~ no player within 6m")
        return
    end

    local sid = GetPlayerServerId(target)
    local randId = 'glradial:server:' .. option.action .. ':' .. math.random(10000, 99999)

    option.state = not option.state

    if option.state then
        for i, other in ipairs(Toggles) do
            if i ~= index then
                other.state = false
            end
        end

        if option.action == "cuff" then
            TriggerServerEvent('__ox_cb_glradial:server:cuff', 'GLRadial', randId, sid, 'hard')
            Notify("~b~CaliRP~s~ cuffed " .. sid)
        else
            TriggerServerEvent('__ox_cb_glradial:server:uncuff', 'GLRadial', randId, sid)
            Notify("~b~CaliRP~s~ uncuffed " .. sid)
        end
    end
end

local function HandleInput()
    if IsControlJustPressed(0, 172) then
        Menu.index = Menu.index - 1
        if Menu.index < 1 then
            Menu.index = #Toggles
        end
        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    elseif IsControlJustPressed(0, 173) then
        Menu.index = Menu.index + 1
        if Menu.index > #Toggles then
            Menu.index = 1
        end
        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    elseif IsControlJustPressed(0, 191) then
        RunToggle(Menu.index)
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    elseif IsControlJustPressed(0, 177) then
        Menu.isOpen = false
        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end
end

Citizen.CreateThread(function()
    while true do
        if Menu.isOpen then
            DrawMenu()
            HandleInput()
            Wait(0)
        else
            Wait(100)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 84) then
            Menu.isOpen = not Menu.isOpen
            Menu.index = 1
        end
    end
end)
