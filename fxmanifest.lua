
fx_version "cerulean"
games { "gta5" }

author "Philipp Decker"
description "Vehicle deformation getting/setting including synchronisation via entity state bags."
version "3.0.0"

lua54 "yes"
use_experimental_fxv2_oal "yes"

dependencies {
	"/onesync"
}

client_scripts {
	"config.lua",
	"client/deformation.lua",
	"client/client.lua"
}

server_scripts {
	"server/versionChecker.lua",
	"server/server.lua"
}
