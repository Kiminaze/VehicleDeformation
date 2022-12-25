
fx_version "cerulean"
games { "gta5" }

author "Philipp Decker"
description "Vehicle deformation getting/setting including synchronisation via entity state bags."
version "2.0.0"

dependencies {
	"/onesync"
}

client_scripts {
	"client/deformation.lua",
	"client/client.lua"
}

server_scripts {
	"server/server.lua"
}
