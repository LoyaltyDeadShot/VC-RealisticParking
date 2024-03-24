RegisterNetEvent('Vlore-Kluczyki:OpenKey', function()
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
	SendNUIMessage({
		type = "enableKeyFob",
	})
    while IsNuiFocused() do
        Wait(1)
        DisableControlAction(2, 1, true)
        DisableControlAction(2, 2, true)
        DisableControlAction(2, 13, true)
        DisableControlAction(2, 24, true)
        DisableControlAction(2, 200, true)
        DisableControlAction(2, 245, true)

    end
end)

--[[
    Event handler for vehicle animation and notification related to key actions.
    When triggered, it gets the closest vehicle based on the player's coordinates.
    If the distance to the vehicle is greater than the configured distance limit, it returns.
    It retrieves the lock state of the vehicle and performs animation and notification accordingly.
]]-- 
RegisterNetEvent('Vlore-Kluczyki:vehicle', function(notify)
    if not (IDEV.Keys.EnableKeyUsageInsideVehicle) and (cache.vehicle) then
        print("Weird?")
        return
    end
    
    local closestVehicle, distance = ESX.Game.GetClosestVehicle(cache.coords)
    if (distance > IDEV.Keys.MaxDistance) then return end
    
    local vehicleState <const> = Entity(closestVehicle)?.state
    
    if (IDEV.Keys.EnableKeyAnimationOutside) and not (cache.vehicle)  then
        CreateThread(performKeyFobAnimation)
    end
    
    if (IDEV.Keys.EnableLightAnimationOutside) or (cache.vehicle and IDEV.Keys.EnableLightAnimationInsideVehicle) then
        activateVehicleLightAnimation(closestVehicle)
    end
    
    if (cache.vehicle) and (IDEV.Keys.EnableKeyAnimationInsideVehicle) then
        CreateThread(performKeyFobAnimation)
    end
    
    if notfiy then local doorsSound <const> = vehicleState.isLocked and PlayVehicleDoorCloseSound(closestVehicle, 0) or PlayVehicleDoorOpenSound(closestVehicle, 0) end
    if notify then displayNotification(vehicleState.isLocked) end
end)

local odpala = false
RegisterNetEvent('Vlore-Kluczyki:engine', function()
    local player = PlayerPedId()
    local veh = GetVehiclePedIsIn(player, false)
    local engine = GetIsVehicleEngineRunning(veh)
    local health = GetVehicleEngineHealth(veh)
    if not IsPedInAnyVehicle(player, false) then return end
    if not engine and not odpala then
        odpala = true
        local chance = math.random(math.floor(health), 1000)
        if chance > 995 then 
            lib.notify({
                title = 'Rotating Key',
                description = 'Turning On Engine',
                type = 'infrom'
            })
        else
            lib.notify({
                title = 'Rotating Key',
                description = 'Trying to turn on engine',
                type = 'warning'
            })
        end
        repeat
            Wait(0)
            SetVehicleEngineOn(veh, true, false, true)
            Wait(150)
            SetVehicleEngineOn(veh, false, false, true)
            if not IsEntityPlayingAnim(player, 'oddjobs@towing', 'start_engine_loop', 3) then
                playAnim(player, 'oddjobs@towing', 'start_engine_loop', 100*(1000-chance) + 1000)
            end
            chance = chance+1
            if not IsPedInAnyVehicle(player, false) or odpala == false then return SetVehicleEngineOn(veh, false, false, true) end
        until chance == 1000 or chance > 1000
        SetVehicleEngineOn(veh, true, false, true)
        odpala = false
    elseif odpala == true and not engine then
        lib.notify({
            title = 'What are u doin bro',
            description = 'I`m Micheal Jordan Stop it get some help',
            type = 'warning'
        })
    else
        lib.notify({
            title = 'Rotating Key',
            description = 'Turning Engine OFF',
            type = 'inform'
        })
        playAnim(player, 'oddjobs@towing', 'start_engine_exit', 500)
        SetVehicleEngineOn(veh, false, false, true)
    end
end)

RegisterNetEvent('Vlore-Kluczyki:SpawnVehicle', function(slot)
    local ped = GetPlayerPed(-1)
	local pos = GetEntityCoords(ped)

    ESX.TriggerServerCallback('Vlore-Kluczyki:checkcoordscar', function(cars)
        if cars == false then return end
        local distanceToVeh = GetDistanceBetweenCoords(pos.x,pos.y,pos.z, tonumber(cars.x), tonumber(cars.y), tonumber(cars.z), true)
        if distanceToVeh <= 424 then
            local clear = ESX.Game.IsSpawnPointClear(vec3(tonumber(cars.x), tonumber(cars.y), tonumber(cars.z)), 2.0)
            if clear then
                TriggerServerEvent('Vlore-Kluczyki:SpawnVehicle', cars)
            else
                lib.notify({
                    title = 'Przywoływanie pojazdu',
                    description = 'Miejsce parkowania pojazdu jest zablokowane',
                    type = 'error'
                })
            end
        else
            lib.notify({
                title = 'Przywoływanie pojazdu',
                description = 'Jesteś za daleko od pojazdu sprawdź jego ostatnią lokalizację udaj się tam a następnie go przywołaj',
                type = 'error'
            })
        end
    end, slot)
end)

RegisterNetEvent('Vlore-Kluczyki:CheckVehPos', function(slot)
    ESX.TriggerServerCallback('Vlore-Kluczyki:checkcoordscar', function(cars)
        if cars == false then return end
        print(cars.x, cars.y)
        SetNewWaypoint(tonumber(cars.x), tonumber(cars.y))
        lib.notify({
            title = 'Pozycja oznaczona',
            description = 'Na mapie zaznaczono ostanią pozycje parkowania pojazdu.',
            type = 'success'
        })
    end, slot)
end)

RegisterNetEvent('Vlore-Kluczyki:SpawnedVeh', function(nId, Properties, h)
    local car = NetworkGetEntityFromNetworkId(nId)
    if not car then return end
    NetworkRequestControlOfEntity(car)
    SetEntityAsMissionEntity(car, true, false)
    SetVehicleHasBeenOwnedByPlayer(car, true)
    SetVehicleEngineHealth(car, h + 0.0)
    SetVehicleBodyHealth(car, h + 0.0)
    SetVehicleProperties(car, Properties)
end)

RegisterNetEvent('Vlore-Kluczyki:CheckProperties', function(vehicleNetId)
    odpala = false
    local veh = NetworkGetEntityFromNetworkId(vehicleNetId)
    local coords =  GetEntityCoords(veh)
    local props = GetVehicleProperties(veh)

    TriggerServerEvent('Vlore-Kluczyki:SaveVeh', props, coords.x, coords.y, coords.z, GetEntityHeading(veh), GetVehicleEngineHealth(veh))
end)


RegisterNetEvent('Vlore-Kluczyki:Window', function(car,data)
    local vehicle = NetworkGetEntityFromNetworkId(car)
    local id = data.window
	if IsVehicleWindowIntact(vehicle, id) then
		RollDownWindow(vehicle, id)
	else
		RollUpWindow(vehicle, id)
	end
end)

RegisterNetEvent('Vlore-Kluczyki:Trunk', function(car)
    local vehicle = NetworkGetEntityFromNetworkId(car)
	local hasTrunk = GetIsDoorValid(vehicle, 5)
	local door = hasTrunk and 5 or 4
	local isTrunkOpen = GetVehicleDoorAngleRatio(vehicle, door)

	if isTrunkOpen == 0 then
		SetVehicleDoorOpen(vehicle, door, false, false)
	else
		SetVehicleDoorShut(vehicle, door, false)
	end
end)

RegisterNetEvent('Vlore-Kluczyki:Alarm', function (car)
    local vehicle = NetworkGetEntityFromNetworkId(car)
	local isAlarmActive = IsVehicleAlarmActivated(vehicle)
	if isAlarmActive then
		SetVehicleAlarm(vehicle, false)
	else
		SetVehicleAlarm(vehicle, true)
        Wait(100)
		StartVehicleAlarm(vehicle)
	end
end)

RegisterNetEvent('idev_keys:vehicle:door', function (veh, locked)
    local vehicle = NetworkGetEntityFromNetworkId(veh)
    if not locked then
        print(locked)
        SetVehicleIndividualDoorsLocked(vehicle, 1, 1)
        SetVehicleIndividualDoorsLocked(vehicle, 3, 1)
    else
        SetVehicleIndividualDoorsLocked(vehicle, 1, 4)
        SetVehicleIndividualDoorsLocked(vehicle, 3, 4)
    end
end)


RegisterKeyMapping("engine", locale("engine_command"), 'keyboard', "Y")
RegisterCommand("engine", function()
    if not (inventory:GetItemCount('keys', nil, false)) then return end
    if (player.invBusy) or (player.invOpen) then return end
    TriggerServerEvent('Vlore-Kluczyki:check', 1)
end, false)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
    
        local currentPlayerPed = PlayerPedId()
    
        if currentPlayerPed ~= playerPed then
            playerPed = currentPlayerPed
    
            SetPedConfigFlag(playerPed, 241, true) -- PED_FLAG_DISABLE_STOPPING_VEHICLE_ENGINE
            SetPedConfigFlag(playerPed, 429, true) -- PED_FLAG_DISABLE_STARTING_VEHICLE_ENGINE
        end
    end
end)


RegisterNetEvent('Vlore-Kluczyki:CheckVehIsIn', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local class = GetVehicleClass(veh)
    if class == 11 then
        while true do
            if GetVehiclePedIsIn(PlayerPedId(), false) ~= veh then break end
            Wait(100)
            if GetEntityAttachedToTowTruck(veh) ~= 0 then
                local towed = GetEntityAttachedToTowTruck(veh)
                while true do
                    Wait(10)
                    if towed ~= GetEntityAttachedToTowTruck(veh) then
                        local coords = GetEntityCoords(towed)
                        local props = GetVehicleProperties(towed)
                        TriggerServerEvent('Vlore-Kluczyki:SaveVeh', props, coords.x, coords.y, coords.z, GetEntityHeading(towed), GetVehicleEngineHealth(towed))
                        break
                    end
                end
            else
                Wait(1000)
            end
        end
    end
end)