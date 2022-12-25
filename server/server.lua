
function FixVehicleDeformation(vehicle)
	assert(vehicle and DoesEntityExist(vehicle), "Parameter \"vehicle\" must be a valid vehicle entity!")

	Entity(vehicle).state:set("deformation", {}, true)
end

RegisterNetEvent("VD:fixDeformation", function(networkId)
	FixVehicleDeformation(NetworkGetEntityFromNetworkId(networkId))
end)



exports("FixVehicleDeformation", FixVehicleDeformation)
