--[[ FX Information ]]--
fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
game        'gta5'

--[[ Resource Information ]]--
description  'A key system with parking and lot more.'

--[[ Manifest ]]--
dependencies {
    '/server:5848',
    '/onesync',
    'ox_lib',
    'ox_inventory',
    'es_extended'
}


shared_scripts {
    '@ox_lib/init.lua',
	'shared/config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/index.js',
	'html/main.css',
	'html/sounds/*.ogg',
	'html/images/*.png',
    'locales/en.json' -- to avoid to load other locales than the one you need just replace the * by the locale you need (for example en)

}