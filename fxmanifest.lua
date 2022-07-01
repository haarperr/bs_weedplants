fx_version 'cerulean'
games {'gta5'}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "config.lua",
    "sv/main.lua"
}

client_scripts {
    "config.lua",
    "cl/main.lua"
}
