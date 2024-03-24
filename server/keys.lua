
local spawnedVehs = {}
--[[
    Removes leading and trailing white spaces from a string.
    Uses pattern matching to match and extract the non-whitespace content of the string.
    Credit: https://stackoverflow.com/questions/10460126/how-to-remove-spaces-from-a-string-in-lua
]]
function TrimString(string)
    if string == nil then return end
    return string:match("^%s*(.-)%s*$")
end

--[[ 
    Prints an error message with the given message and function name 
    and returns false.
]]
function PrintErrorMessage(message, functionName)
    if not (IDEV.Keys.Debug) then return end
    print(GetCurrentResourceName(), message, 'function:', functionName)
end


--[[
    Event handler for checking vehicle key ownership and handling key actions on the server.
    When triggered, it retrieves the closest vehicle to the player and checks its proximity.
    If the vehicle is too far or doesn't exist, it returns.
    It then checks if the player has the corresponding key item and metadata for the vehicle.
    If not, it prints a message and returns.
    Next, it retrieves the lock status of the vehicle and performs the necessary door locking or unlocking.
    It updates the lock state of the vehicle and triggers a client event to play the vehicle animation.
]]
RegisterServerEvent('Vlore-Kluczyki:check')
AddEventHandler('Vlore-Kluczyki:check', function(type, d)
    if type == 0 then
        local player <const> = ESX?.GetPlayerFromId(source)

        local closestVehicle <const>, distance <const> = ESX.OneSync.GetClosestVehicle(player.getCoords(true))
        if not (closestVehicle) or (distance > IDEV.Keys.MaxDistance) and TriggerClientEvent('ox_lib:notify', source,{
            title = 'Nie możesz tego zrobić',
            description = 'Brak zasięgu',
            type = 'error'
        }) then return end

        local vehicle <const> = NetworkGetEntityFromNetworkId(closestVehicle)
        if not (vehicle) then return end

        local plate <const> = TrimString(GetVehicleNumberPlateText(vehicle))
        local vehicleMetadata <const> = {
            plate = plate,
            -- TODO: add a description like "Model: Adder"
        }

        local keyItem <const> = Inventory:GetItem(source, 'keys', vehicleMetadata, true)
        if (keyItem <= 0) then
            return PrintErrorMessage('Not your vehicle', 'Vlore-Kluczyki:check')
        end
        if GetVehicleDoorLockStatus(vehicle) == 1 then TriggerClientEvent('ox_lib:notify', source,{
            title = 'Nie możesz tego zrobić',
            description = 'Pojazd jest otwarty',
            type = 'error'
        }) return end
        local isLocked <const> = false -- based on fivem docs GetVehicleDoorLockStatus should return only 0 when the vehicle is unlocked because of the game who going to sync both state and use 0, however i couldn't get the 0 state so i added it here just in case
        SetVehicleDoorsLocked(vehicle, 1)
        TriggerClientEvent('Vlore-Kluczyki:door', -1, closestVehicle, false)

        Entity(vehicle)?.state.isLocked = isLocked
        TriggerClientEvent('Vlore-Kluczyki:vehicle', player.source, true)
        --[[
            Does animations are synced like that (i don't think so?)
            Maybe trigger the animation on the scope of the original client (players in the scope of the player who is using the key)
        ]]
    elseif type == 0.5 then
        local player <const> = ESX?.GetPlayerFromId(source)

        local closestVehicle <const>, distance <const> = ESX.OneSync.GetClosestVehicle(player.getCoords(true))
        if not (closestVehicle) or (distance > IDEV.Keys.MaxDistance) and TriggerClientEvent('ox_lib:notify', source,{
            title = 'Nie możesz tego zrobić',
            description = 'Brak zasięgu',
            type = 'error'
        }) then return end

        local vehicle <const> = NetworkGetEntityFromNetworkId(closestVehicle)
        if not (vehicle) then return end

        local plate <const> = TrimString(GetVehicleNumberPlateText(vehicle))
        local vehicleMetadata <const> = {
            plate = plate,
            -- TODO: add a description like "Model: Adder"
        }

        local keyItem <const> = Inventory:GetItem(source, 'keys', vehicleMetadata, true)
        if (keyItem <= 0) then
            return PrintErrorMessage('Not your vehicle', 'Vlore-Kluczyki:check')
        end
        if GetVehicleDoorLockStatus(vehicle) == 2 then TriggerClientEvent('ox_lib:notify', source,{
            title = 'Nie możesz tego zrobić',
            description = 'Pojazd jest zamknięty',
            type = 'error'
        }) return end
        local isLocked <const> = true -- based on fivem docs GetVehicleDoorLockStatus should return only 0 when the vehicle is unlocked because of the game who going to sync both state and use 0, however i couldn't get the 0 state so i added it here just in case
        SetVehicleDoorsLocked(vehicle, 2)
        TriggerClientEvent('Vlore-Kluczyki:door', -1, closestVehicle, true)

        Entity(vehicle)?.state.isLocked = isLocked
        TriggerClientEvent('Vlore-Kluczyki:vehicle', player.source, true)
    
    elseif type == 1 then
        local player <const> = ESX?.GetPlayerFromId(source)

        local plate <const> = TrimString(GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(source), false)))
        local vehicleMetadata <const> = {
            plate = plate,
            -- TODO: add a description like "Model: Adder"
        }

        local keyItem <const> = Inventory:GetItem(source, 'keys', vehicleMetadata, true)
        if (keyItem <= 0) then
            TriggerClientEvent('ox_lib:notify', source,{
                title = 'Nie możesz tego zrobić',
                description = 'Nie posiadasz kluczyków do pojazdu',
                type = 'error'
            })
            return PrintErrorMessage('Not your vehicle', 'Vlore-Kluczyki:check')
        end

        TriggerClientEvent('Vlore-Kluczyki:engine', player.source)
        --[[
            Does animations are synced like that (i don't think so?)
            Maybe trigger the animation on the scope of the original client (players in the scope of the player who is using the key)
        ]]
    elseif type == 2 then
        local player <const> = ESX?.GetPlayerFromId(source)

        local closestVehicle <const>, distance <const> = ESX.OneSync.GetClosestVehicle(player.getCoords(true))
        if not (closestVehicle) or (distance > IDEV.Keys.MaxDistance) and TriggerClientEvent('ox_lib:notify', source,{
            title = 'Nie możesz tego zrobić',
            description = 'Brak zasięgu',
            type = 'error'
        }) then return end

        local vehicle <const> = NetworkGetEntityFromNetworkId(closestVehicle)
        if not (vehicle) then return end

        local plate <const> = TrimString(GetVehicleNumberPlateText(vehicle))
        local vehicleMetadata <const> = {
            plate = plate,
            -- TODO: add a description like "Model: Adder"
        }

        local keyItem <const> = Inventory:GetItem(source, 'keys', vehicleMetadata, true)
        if (keyItem <= 0) then
            return PrintErrorMessage('Not your vehicle', 'Vlore-Kluczyki:check')
        end

        SetVehicleAlarm(vehicle, true)
        TriggerClientEvent('Vlore-Kluczyki:Alarm', -1, closestVehicle)
        TriggerClientEvent('Vlore-Kluczyki:vehicle', player.source, false)

        --[[
            Does animations are synced like that (i don't think so?)
            Maybe trigger the animation on the scope of the original client (players in the scope of the player who is using the key)
        ]]
    elseif type == 3 then
        local player <const> = ESX?.GetPlayerFromId(source)

        local closestVehicle <const>, distance <const> = ESX.OneSync.GetClosestVehicle(player.getCoords(true))
        if not (closestVehicle) or (distance > IDEV.Keys.MaxDistance) and TriggerClientEvent('ox_lib:notify', source,{
            title = 'Nie możesz tego zrobić',
            description = 'Brak zasięgu',
            type = 'error'
        }) then return end

        local vehicle <const> = NetworkGetEntityFromNetworkId(closestVehicle)
        if not (vehicle) then return end

        local plate <const> = TrimString(GetVehicleNumberPlateText(vehicle))
        local vehicleMetadata <const> = {
            plate = plate,
            -- TODO: add a description like "Model: Adder"
        }

        local keyItem <const> = Inventory:GetItem(source, 'keys', vehicleMetadata, true)
        if (keyItem <= 0) then
            return PrintErrorMessage('Not your vehicle', 'Vlore-Kluczyki:check')
        end

        TriggerClientEvent('Vlore-Kluczyki:Trunk', -1, closestVehicle)
        TriggerClientEvent('Vlore-Kluczyki:vehicle', player.source, false)

        --[[
            Does animations are synced like that (i don't think so?)
            Maybe trigger the animation on the scope of the original client (players in the scope of the player who is using the key)
        ]]
    elseif type == 4 then
        local player <const> = ESX?.GetPlayerFromId(source)

        local closestVehicle <const>, distance <const> = ESX.OneSync.GetClosestVehicle(player.getCoords(true))
        if not (closestVehicle) or (distance > IDEV.Keys.MaxDistance) then return end

        local vehicle <const> = NetworkGetEntityFromNetworkId(closestVehicle)
        if not (vehicle) then return end

        local plate <const> = TrimString(GetVehicleNumberPlateText(vehicle))
        local vehicleMetadata <const> = {
            plate = plate,
            -- TODO: add a description like "Model: Adder"
        }

        local keyItem <const> = Inventory:GetItem(source, 'keys', vehicleMetadata, true)
        if (keyItem <= 0) then
            return PrintErrorMessage('Not your vehicle', 'Vlore-Kluczyki:check')
        end

        TriggerClientEvent('Vlore-Kluczyki:Window', -1, closestVehicle, d)
        TriggerClientEvent('Vlore-Kluczyki:vehicle', player.source, false)

        --[[
            Does animations are synced like that (i don't think so?)
            Maybe trigger the animation on the scope of the original client (players in the scope of the player who is using the key)
        ]]
    elseif type == 5 then
        local player <const> = ESX?.GetPlayerFromId(source)

        local closestVehicle <const>, distance <const> = ESX.OneSync.GetClosestVehicle(player.getCoords(true))
        if not (closestVehicle) or (distance > IDEV.Keys.MaxDistance) then return end

        local vehicle <const> = NetworkGetEntityFromNetworkId(closestVehicle)
        if not (vehicle) then return end

        local plate <const> = TrimString(GetVehicleNumberPlateText(vehicle))
        local vehicleMetadata <const> = {
            plate = plate,
            -- TODO: add a description like "Model: Adder"
        }

        local keyItem <const> = Inventory:GetItem(source, 'keys', vehicleMetadata, true)
        if (keyItem <= 0) then
            return TriggerClientEvent('rcore:sdisfsoafjskofijasjiusfhjsfauisfiusfbuisfabuisfbiufsbiusfa', source)
        end
        --[[
            Does animations are synced like that (i don't think so?)
            Maybe trigger the animation on the scope of the original client (players in the scope of the player who is using the key)
        ]]
    end
end)


ESX.RegisterServerCallback('Vlore-Kluczyki:checkcoordscar', function(source, cb, slot)
    local itemSlot = exports.ox_inventory:GetSlot(source, slot)
	local car = MySQL.query.await("SELECT * FROM owned_vehicles WHERE plate = @plate", {['@plate'] = itemSlot.metadata.plate})
    if #car == 0 then cb(false) end
    cb(car[1])
end)

RegisterNetEvent('Vlore-Kluczyki:SpawnVehicle', function(car)
    local spawned = false
    for k, v in ipairs(spawnedVehs) do
        if car.plate == v.plate then spawned = DoesEntityExist(NetworkGetEntityFromNetworkId(v.netId)) break end
    end
    if spawned == 1 then TriggerClientEvent('ox_lib:notify', source,{
        title = 'Nie możesz tego zrobić',
        description = 'Pojazd jest już na mapie',
        type = 'error'
    }) return end
    local callbackValue = 0
    ::sync::
    local Properties = json.decode(car.vehicle)
    ESX.OneSync.SpawnVehicle(Properties.model, vector3(tonumber(car.x), tonumber(car.y), tonumber(car.z)), tonumber(car.h), Properties, function(obj)
        callbackValue = obj
    end)
    while callbackValue == 0 do
        Wait(10)
    end
    if DoesEntityExist(NetworkGetEntityFromNetworkId(callbackValue)) then else goto sync end
    table.insert(spawnedVehs, {plate = car.plate, netId = callbackValue, coords = vector3(tonumber(car.x), tonumber(car.y), tonumber(car.z))})
    TriggerClientEvent('Vlore-Kluczyki:SpawnedVeh', -1, callbackValue, Properties, car.health)
    TriggerClientEvent('ox_lib:notify', source,{
        title = 'Pojazd się pojawił',
        description = 'Udaj się na miejsce ostatniego parkowania by zobaczyć twoją gablote.',
        type = 'success'
    })
end)


RegisterNetEvent("baseevents:leftVehicle", function(currentVehicle, currentSeat, vehicleDisplayName, vehicleNetId)
    TriggerClientEvent("Vlore-Kluczyki:CheckProperties", source, vehicleNetId)
end)

RegisterNetEvent("baseevents:enteredVehicle", function(currentVehicle, currentSeat, vehicleDisplayName)
    TriggerClientEvent("Vlore-Kluczyki:CheckVehIsIn", source)
end)

RegisterServerEvent('Vlore-Kluczyki:SaveVeh')
AddEventHandler('Vlore-Kluczyki:SaveVeh', function(vehiclePropsa, x, y, z, headings, he)
    if vehiclePropsa?.plate == nil then return end
    MySQL.Sync.execute("UPDATE owned_vehicles SET x = @x, y = @y, z = @z, h = @h, health = @he, vehicle = @vehicle WHERE plate=@plate",{['@x'] = x , ['@y'] = y , ['@z'] = z , ['@h'] = headings , ['@he'] = he , ['@vehicle'] = json.encode(vehiclePropsa) , ['@plate'] = vehiclePropsa.plate})
end)