
-- state bag handler to apply any deformation
AddStateBagChangeHandler("deformation", nil, function(bagName, key, value, _unused, replicated)
	if (bagName:find("entity") == nil) then return end

	local networkIdString = bagName:gsub("entity:", "")
	local networkId = tonumber(networkIdString)
	if (not WaitUntilEntityWithNetworkIdExists(networkId, 5000)) then return end

	local vehicle = NetworkGetEntityFromNetworkId(networkId)
	--if (not WaitUntilEntityExists(vehicle, 5000)) then return end

	if (#value > 0) then
		SetVehicleDeformation(vehicle, value)
	else
		SetVehicleDeformationFixed(vehicle)
	end
end)

-- loop to get deformation on current vehicle
Citizen.CreateThread(function()
	while (true) do
		Citizen.Wait(5000)

		local playerPed = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(playerPed)
		if (DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == playerPed) then
			local deformation = GetVehicleDeformation(vehicle)
			if (not IsDeformationEqual(deformation, Entity(vehicle).state["deformation"])) then
				Entity(vehicle).state:set("deformation", deformation, true)
			end
		end
	end
end)

-- fix deformation on vehicle
function FixVehicleDeformation(vehicle)
	assert(DoesEntityExist(vehicle) and NetworkGetEntityIsNetworked(vehicle), "Parameter \"vehicle\" must be a valid and networked vehicle entity!")

	TriggerServerEvent("VD:fixDeformation", NetworkGetNetworkIdFromEntity(vehicle))
end



-- waits until a given network id exists and returns true if it was found before hitting the timeout
function WaitUntilEntityWithNetworkIdExists(networkId, timeout)
	local threshold = GetGameTimer() + timeout

	while (not NetworkDoesEntityExistWithNetworkId(networkId) and GetGameTimer() < threshold) do
		Citizen.Wait(0)
	end

	return NetworkDoesEntityExistWithNetworkId(networkId)
end

-- waits until a given entity handle exists and returns true if it was found before hitting the timeout
function WaitUntilEntityExists(entityHandle, timeout)
	local threshold = GetGameTimer() + timeout

	while (not DoesEntityExist(entityHandle) and GetGameTimer() < threshold) do
		Citizen.Wait(0)
	end

	return DoesEntityExist(entityHandle)
end



exports("FixVehicleDeformation", FixVehicleDeformation)
