fx_version 'cerulean'
game 'gta5'

name "Brazzers Cameras"
author "Brazzers Development | MannyOnBrazzers#6826"
version "1.0.0"

lua54 'yes'

client_scripts {
    'client/*.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

shared_scripts {
	'shared/*.lua',
}

files {
	'html/*.html',
	'html/script.js',
	'html/style.css',
}

ui_page 'html/index.html'

escrow_ignore {
    'client/open.lua',
    'server/open.lua',
	'shared/*.lua',
	'html/*.html',
	'html/script.js',
	'html/style.css',
}