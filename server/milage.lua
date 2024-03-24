local millage = {}
RegisterServerEvent('Vlore-Kluczyki:updateMileage')
AddEventHandler('Vlore-Kluczyki:updateMileage', function(plate, mileage)
    millage[plate] = mileage
    UpdateMileageInDatabase(plate, tostring(mileage))
end)

function UpdateMileageInDatabase(plate, mileage)
    MySQL.Async.execute('UPDATE owned_vehicles SET miles = @miles WHERE plate = @plate', {
        ['@plate'] = plate,
        ['@miles'] = mileage
    }, function(affectedRows)
        if affectedRows == 0 then
            -- Życie jest cool 4 rana ja to pisze 
        end
    end)
end

ESX.RegisterServerCallback('Vlore-Kluczyki:checkMili', function(source, cb, plate)
    if millage[plate] ~= nil then cb(millage[plate]) else cb(false) end
end)

CreateThread(function()
    local response = MySQL.query.await('SELECT plate, miles FROM owned_vehicles')
    if response then
        for i = 1, #response do
            local row = response[i]
            millage[row.plate] = row.miles
        end
    end
end)