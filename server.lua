ESX = nil
local bacLevels = {}

ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterUsableItem('beer', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('beer', 1)
    TriggerClientEvent('bennys_drunkscript:drunkEffect', source)
    TriggerClientEvent('esx:showNotification', source, "Du hast ein Bier getrunken und fühlst dich betrunken.")
end)

ESX.RegisterUsableItem('alcoholmeter', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('bennys_alcoholscript:checkBAC', source, source)
end)

RegisterServerEvent('bennys_drunkscript:updateBAC')
AddEventHandler('bennys_drunkscript:updateBAC', function(bac)
    local source = source
    playerBAC[source] = bac
end)

ESX.RegisterServerCallback('bennys_drunkscript:getBAC', function(source, cb, target)
    cb(playerBAC[target] or 0.0)
end)