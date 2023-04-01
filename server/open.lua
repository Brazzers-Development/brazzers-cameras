local QBCore = exports[Config.Core]:GetCoreObject()

function notification(source, msg, type)
    TriggerClientEvent('QBCore:Notify', source, msg, type)
end

-- Useable Items

for k, v in pairs(Config.Models) do
    QBCore.Functions.CreateUseableItem(v['item'], function(source, item)
        TriggerClientEvent('brazzers-cameras:client:placeDownCamera', source, k)
    end)
end