ESX = nil
local drunkLevel = 0
local bac = 0.0 -- Blood Alcohol Content (BAC) level

ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('bennys_drunkscript:drunkEffect')
AddEventHandler('bennys_drunkscript:drunkEffect', function()
    local playerPed = PlayerPedId()
    local baseDrunkTime = 60000 -- Base duration of the drunk effect in milliseconds

    drunkLevel = drunkLevel + 1
    bac = bac + 0.02 -- Increase BAC level by 0.02 for each beer
    local drunkTime = baseDrunkTime * drunkLevel

    -- Notify server about the updated BAC
    TriggerServerEvent('bennys_drunkscript:updateBAC', bac)

    -- Play drinking animation
    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_DRINKING', 0, true)
    Citizen.Wait(10000) -- Time to simulate drinking

    ClearPedTasksImmediately(playerPed)

    -- Apply drunk effects
    RequestAnimSet("move_m@drunk@verydrunk")
    while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
        Citizen.Wait(0)
    end
    SetPedMovementClipset(playerPed, "move_m@drunk@verydrunk", true)
    SetTimecycleModifier("spectator5")
    ShakeGameplayCam("DRUNK_SHAKE", 1.0)
    SetPedIsDrunk(playerPed, true)

    Citizen.Wait(drunkTime)

    -- Reset player state
    drunkLevel = drunkLevel - 1
    if drunkLevel <= 0 then
        ResetPedMovementClipset(playerPed, 0)
        ClearTimecycleModifier()
        ShakeGameplayCam("DRUNK_SHAKE", 0.0)
        SetPedIsDrunk(playerPed, false)
        drunkLevel = 0
        bac = 0.0 -- Reset BAC level
        -- Notify server to reset BAC
        TriggerServerEvent('bennys_drunkscript:updateBAC', bac)
    end
end)

RegisterNetEvent('bennys_alcoholscript:checkBAC')
AddEventHandler('bennys_alcoholscript:checkBAC', function(target)
    local targetBac = GetPlayerBac(target)
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        multiline = true,
        args = {"Alkoholmessgerät", "Der Blutalkoholspiegel der Person beträgt: " .. string.format("%.2f", targetBac) .. " ‰"}
    })
end)

function GetPlayerBac(player)
    local bac = 0.0
    ESX.TriggerServerCallback('bennys_drunkscript:getBAC', function(bacResult)
        bac = bacResult
    end, GetPlayerServerId(player))
    return bac
end

RegisterCommand('drunk', function()
    TriggerEvent('bennys_drunkscript:drunkEffect')
end, false)