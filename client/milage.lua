local lastVehicle = nil
local lastCoords = nil
local currentMileage = 0
local accumulatedDistance = 0
local displayInKilometers = false

function CalculateTravelledDistance(vehicle)
    local currentCoords = GetEntityCoords(vehicle)
    if lastCoords then
        return #(currentCoords - lastCoords)
    else
        return 0
    end
end

Citizen.CreateThread(function()
  while true do
        Citizen.Wait(500)
        local player = PlayerPedId()
        if IsPedInAnyVehicle(player, false) and GetPedInVehicleSeat(GetVehiclePedIsIn(player), -1) == player then
            local vehicle = GetVehiclePedIsIn(player, false)
            if DoesEntityExist(vehicle) then
                if lastVehicle == vehicle then
                    local distance = CalculateTravelledDistance(vehicle)
                    currentMileage = currentMileage + distance
                    accumulatedDistance = accumulatedDistance + distance
                    if accumulatedDistance >= 162 then
                        local dst = ESX.Math.Round((math.floor(currentMileage)/1000)/1.609, 1)
                        TriggerServerEvent('Vlore-Kluczyki:updateMileage', GetVehicleNumberPlateText(vehicle), dst)
                        TriggerEvent('Vlore-Hud:SendMialage', dst)
                        accumulatedDistance = 0
                    end
                else
                    local pierogi = nil
                    ESX.TriggerServerCallback('Vlore-Kluczyki:checkMili', function(erer)
                        pierogi = erer
                    end, GetVehicleNumberPlateText(vehicle))
                    while pierogi == nil do
                        Wait(0)
                    end
                    accumulatedDistance = 0
                    if pierogi == false then currentMileage = math.random(10*1000*1.609, 150000*1000*1.609) - 0.1 else currentMileage = pierogi*1000*1.609 end
                    local dst = ESX.Math.Round((math.floor(currentMileage)/1000)/1.609, 1)
                    TriggerEvent('Vlore-Hud:SendMialage', dst)
                end
                lastCoords = GetEntityCoords(vehicle)
            end
            lastVehicle = vehicle
        end
    end
end)