inventory = exports.ox_inventory
ESX = exports.es_extended:getSharedObject()
player = LocalPlayer?.state

lib.locale()
inventory:displayMetadata('plate', locale('plate_tooltip'))

--[[
    Performs an animation for using a key fob.
]]
function performKeyFobAnimation()
    local animationDict <const> = 'anim@mp_player_intmenu@key_fob@'

    playAnim(cache.ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', -1)

    local modelHash <const> = GetHashKey('lr_prop_carkey_fob')
    RequestModel(modelHash)

    while not HasModelLoaded(modelHash) do
        Wait(100)
        RequestModel(modelHash)
    end

    local playerCoords <const> = GetEntityCoords(cache.ped)
    local prop = CreateObject(modelHash, playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)
    AttachEntityToEntity(prop, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.14, 0.03, -0.01, 24.0, -152.0, 164.0, true, true, false, false, 1, true)

    Wait(1000)
    DeleteObject(prop)
    ClearPedTasks(cache.ped)
end

--[[
    Activates the vehicle's light animation.
]]
function activateVehicleLightAnimation(vehicle)
    for _ = 1, 2 do
        SetVehicleLights(vehicle, 2)
        Wait(150)
        SetVehicleLights(vehicle, 0)
        Wait(150)
    end
end

--[[
    Displays a notification message based on the vehicle's lock status.
    If 'isLocked' is true, it shows a success notification for a locked vehicle.
    If 'isLocked' is false, it shows a success notification for an unlocked vehicle.
]]
function displayNotification(isLocked)
    local title <const> = isLocked and locale('title_vehicle_locked') or locale('title_vehicle_unlocked')
    local description <const> = isLocked and locale('vehicle_locked') or locale('vehicle_unlocked')

    lib.notify({
        title = title,
        description = description,
        type = 'success'
    })
end


--[[
    Plays Animation.
]]

function playAnim(ped, dictionary, anim, time)
    Citizen.CreateThread(function()
        RequestAnimDict(dictionary)
        while not HasAnimDictLoaded(dictionary) do
            Citizen.Wait(0)
        end
        TaskPlayAnim(ped, dictionary, anim ,8.0, -8.0, time, 49, 0, false, false, false)
    end)
end


function GetVehicleProperties(vehicle)
    if not DoesEntityExist(vehicle) then return ESX.Game.GetVehicleProperties(vehicle) end
    local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
    vehicleProps["tyres"] = {}
    vehicleProps["windows"] = {}
    vehicleProps["doors"] = {}

    for id = 1, 7 do
        local tyreId = IsVehicleTyreBurst(vehicle, id, false)
    
        if tyreId then
            vehicleProps["tyres"][#vehicleProps["tyres"] + 1] = tyreId
    
            if tyreId == false then
                tyreId = IsVehicleTyreBurst(vehicle, id, true)
                vehicleProps["tyres"][ #vehicleProps["tyres"]] = tyreId
            end
        else
            vehicleProps["tyres"][#vehicleProps["tyres"] + 1] = false
        end
    end

    for id = 1, 13 do
        local windowId = IsVehicleWindowIntact(vehicle, id)

        if windowId ~= nil then
            vehicleProps["windows"][#vehicleProps["windows"] + 1] = windowId
        else
            vehicleProps["windows"][#vehicleProps["windows"] + 1] = true
        end
    end
    
    for id = 0, 5 do
        local doorId = IsVehicleDoorDamaged(vehicle, id)
    
        if doorId then
            vehicleProps["doors"][#vehicleProps["doors"] + 1] = doorId
        else
            vehicleProps["doors"][#vehicleProps["doors"] + 1] = false
        end
    end

    vehicleProps["fuelLevel"] = GetVehicleFuelLevel(vehicle)

    return vehicleProps
end

function SetVehicleProperties(vehicle, vehicleProps)
    ESX.Game.SetVehicleProperties(vehicle, vehicleProps)

    if vehicleProps["windows"] then
        for windowId = 1, 13, 1 do
            if vehicleProps["windows"][windowId] == false then
                RemoveVehicleWindow(vehicle, windowId)
            end
        end
    end

    if vehicleProps["tyres"] then
        for tyreId = 1, 7, 1 do
            if vehicleProps["tyres"][tyreId] ~= false then
                SetVehicleTyreBurst(vehicle, tyreId, true, 1000)
            end
        end
    end

    if vehicleProps["doors"] then
        for doorId = 0, 5, 1 do
            if vehicleProps["doors"][doorId] ~= false then
                SetVehicleDoorBroken(vehicle, doorId - 1, true)
            end
        end
    end
end