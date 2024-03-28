Ox_Inventory

```
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
```


DataBase SQL

```
CREATE TABLE `owned_vehicles` (
  `owner` varchar(60) DEFAULT NULL,
  `plate` varchar(12) NOT NULL,
  `vehicle` longtext DEFAULT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'car',
  `job` varchar(20) DEFAULT NULL,
  `stored` tinyint(4) NOT NULL DEFAULT 0,
  `parking` varchar(60) DEFAULT NULL,
  `pound` varchar(60) DEFAULT NULL,
  `trunk` longtext DEFAULT NULL,
  `glovebox` longtext DEFAULT NULL,
  `x` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0',
  `y` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0',
  `z` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0',
  `h` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0',
  `health` int(11) DEFAULT 0,
  `miles` varchar(10) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```


DISCORD = https://discord.gg/mPHu4sqhwG
