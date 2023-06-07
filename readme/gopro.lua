RegisterNUICallback('SetupGoPros', function(_, cb)
    local list = exports['brazzers-cameras']:getMyCameras() or {}
    cb(list)
end)

RegisterNUICallback('gopro-viewcam', function(data, cb)
    if not data then return end
    exports['brazzers-cameras']:viewCamera(data.camid)
    cb("ok")
end)

RegisterNUICallback('gopro-track', function(data, cb)
    if not data then return end
    exports['brazzers-cameras']:trackCamera(data.camid)
    cb("ok")
end)

RegisterNUICallback('gopro-rename', function(data, cb)
    if not data then return end
    TriggerServerEvent('brazzers-cameras:server:renameCamera', data.camid, data.name)
    cb("ok")
end)

RegisterNUICallback('gopro-giveaccess', function(data, cb)
    if not data then return end
    TriggerServerEvent("brazzers-cameras:server:addToCamera", data.stateid, data.camid)
    cb("ok")
end)

RegisterNUICallback('gopro-removeaccess', function(data, cb)
    if not data then return end
    TriggerServerEvent("brazzers-cameras:server:removeFromCamera", data.stateid, data.camid)
    cb("ok")
end)

RegisterNUICallback('gopro-accesslist', function(data, cb)
    if not data then return end
    local accessList = exports['brazzers-cameras']:getAccessList(data.camid)
    cb(accessList)
end)

RegisterNUICallback('gopro-isowner', function(data, cb)
    if not data then return end
    local isOwner = exports['brazzers-cameras']:isCameraOwner(data.camid)
    cb(isOwner)
end)

RegisterNetEvent('qb-phone:client:updateCameras', function(data)
    SendNUIMessage({
        action = "updateCameras",
        cameras = data,
    })
end)

RegisterNetEvent('qb-phone:client:updateAccessList', function(data)
    SendNUIMessage({
        action = "updateAccessList",
        cameras = data,
    })
end)