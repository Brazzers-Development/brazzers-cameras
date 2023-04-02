local QBCore = exports[Config.Core]:GetCoreObject()

function notification(msg, type)
    QBCore.Functions.Notify(msg, type)
end

-- NUI Callbacks

RegisterNUICallback('setupCameras', function(_, cb)
    local list = exports['brazzers-cameras']:getMyCameras() or {}
    cb(list)
end)

RegisterNUICallback('viewCam', function(data, cb)
    if not data then return end
    exports['brazzers-cameras']:viewCamera(data.camid)
    TriggerEvent('brazzers-cameras:client:animation', false)
    cb("ok")
end)

RegisterNUICallback('trackCam', function(data, cb)
    if not data then return end
    exports['brazzers-cameras']:trackCamera(data.camid)
    cb("ok")
end)

RegisterNUICallback('renameCam', function(data, cb)
    if not data then return end
    TriggerServerEvent('brazzers-cameras:server:renameCamera', data.camid, data.name)
    cb("ok")
end)

RegisterNUICallback('accessList', function(data, cb)
    if not data then return end
    local accessList = exports['brazzers-cameras']:getAccessList(data.camid)
    cb(accessList)
end)

RegisterNUICallback('isOwner', function(data, cb)
    if not data then return end
    local isOwner = exports['brazzers-cameras']:isCameraOwner(data.camid)
    cb(isOwner)
end)

RegisterNUICallback('giveAccess', function(data, cb)
    if not data then return end
    TriggerServerEvent("brazzers-cameras:server:addToCamera", data.stateid, data.camid)
    cb("ok")
end)

RegisterNUICallback('removeAccess', function(data, cb)
    if not data then return end
    TriggerServerEvent("brazzers-cameras:server:removeFromCamera", tonumber(data.stateid), data.camid)
    cb("ok")
end)

RegisterNUICallback('notify', function(data)
    if data.type == 'error' then
        QBCore.Functions.Notify(data.notify, 'error')
        notification(data.notify, 'error')
    elseif data.type == 'success' then
        notification(data.notify, 'primary')
    end
end)

RegisterNUICallback('close', function()
    SetNuiFocus(false, false)
    TriggerEvent('brazzers-cameras:client:animation', false)
end)

-- Events

RegisterNetEvent('brazzers-cameras:client:showNUI', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        cameras = exports['brazzers-cameras']:getMyCameras() or {},
    })

    TriggerEvent('brazzers-cameras:client:animation', true)
end)

RegisterNetEvent('brazzers-cameras:updateCameras', function(data)
    SendNUIMessage({
        action = "refreshCameras",
        cameras = data,
    })
end)

RegisterNetEvent('brazzers-cameras:updateAccessList', function(data)
    SendNUIMessage({
        action = "refreshAccessList",
        cameras = data,
    })
end)

-- Commands

if not Config.RenewedPhone and Config.EnableCommand then
    RegisterCommand(Config.Command, function()
        TriggerEvent('brazzers-cameras:client:showNUI')
    end)
end

-- Threads

CreateThread(function()
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true

    QBCore.Functions.TriggerCallback('brazzers-cameras:server:getCameras', function(result)
		cachedCameras = result
    end)

    for model, _ in pairs(Config.Models) do
        if Config.Target == 'ox' then
            exports.ox_target:addModel({
                models = model,
                options = {
                    {   
                        name = 'camera_target',
                        icon = Config.Lang['target']['icon'],
                        label = Config.Lang['target']['destroy'],
                        onSelect = function(entity)
                            destroyCamera(entity)
                        end,
                    },
                }
            })
        else
            exports[Config.Target]:AddTargetModel(model, {
                options = {
                    {
                        icon = Config.Lang['target']['icon'],
                        label = Config.Lang['target']['destroy'],
                        action = function(entity)
                            destroyCamera(entity)
                        end,
                    },
                },
                distance = 2.5,
            })
        end
    end
end)