Ox_Inventory

['keys'] = {
        label = 'Car Key',
        description = "Your car keys, better dont drive after drinking",
        weight = 5,
        client = {
            event = 'Vlore-Kluczyki:OpenKey',
        },
        buttons = {
            {
                label = 'Spawn Vehicle',
                action = function(slot)
                    TriggerEvent('Vlore-Kluczyki:SpawnVehicle', slot)
                end
            },
            {
                label = 'Check last location',
                action = function(slot)
                    TriggerEvent('Vlore-Kluczyki:CheckVehPos', slot)
                end
            },
        }
    }, 