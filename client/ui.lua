

RegisterNUICallback("toggleWindow", function(data, cb)
    if not (inventory:GetItemCount('keys', nil, false)) then return end
    if (player.invBusy) or (player.invOpen) then return end
    if not (IDEV.Keys.EnableKeyUsageInsideVehicle) and (cache.vehicle) then return end
    TriggerServerEvent('Vlore-Kluczyki:check', 4, data)

	cb("ok")
end)



RegisterNUICallback('trunk', function(_, cb)
    if not (inventory:GetItemCount('keys', nil, false)) then return end
    if (player.invBusy) or (player.invOpen) then return end
    if not (IDEV.Keys.EnableKeyUsageInsideVehicle) and (cache.vehicle) then return end
    TriggerServerEvent('Vlore-Kluczyki:check', 3)

	cb("ok")
end)


RegisterNUICallback('alarm', function(_, cb)
    if not (inventory:GetItemCount('keys', nil, false)) then return end
    if (player.invBusy) or (player.invOpen) then return end
    if not (IDEV.Keys.EnableKeyUsageInsideVehicle) and (cache.vehicle) then return end
    TriggerServerEvent('Vlore-Kluczyki:check', 2)
    
	cb("ok")
end)

RegisterNUICallback('unlock', function(_, cb)
    if not (inventory:GetItemCount('keys', nil, false)) then return end
    if (player.invBusy) or (player.invOpen) then return end
    if not (IDEV.Keys.EnableKeyUsageInsideVehicle) and (cache.vehicle) then return end
    TriggerServerEvent('Vlore-Kluczyki:check', 0)
	cb("ok")
end)

RegisterNUICallback('lock', function(_, cb)
    if not (inventory:GetItemCount('keys', nil, false)) then return end
    if (player.invBusy) or (player.invOpen) then return end
    if not (IDEV.Keys.EnableKeyUsageInsideVehicle) and (cache.vehicle) then return end
    TriggerServerEvent('Vlore-Kluczyki:check', 0.5)
    cb("ok")
end)

-- Handle GUI stuff

RegisterNUICallback('escape', function(_, cb)
  	SetNuiFocus(false, false)
  	cb('ok')
end)