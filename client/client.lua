
-- check if vehicle is blacklisted
function IsVehicleBlacklisted(vehicle)
	if (#typeBlacklist > 0) then
		local vehicleType = GetVehicleType(vehicle)
		for i = 1, #typeBlacklist do
			if (typeBlacklist[i] == vehicleType) then
				return true
			end
		end
	end

	if (#modelBlacklist > 0) then
		local vehicleModel = GetEntityModel(vehicle)
		for i = 1, #modelBlacklist do
			if (modelBlacklist[i] == vehicleModel) then
				return true
			end
		end
	end

	if (#plateBlacklist > 0) then
		local vehiclePlate = GetVehicleNumberPlateText(vehicle)
		for i = 1, #plateBlacklist do
			if (vehiclePlate:find(plateBlacklist[i]:upper())) then
				return true
			end
		end
	end

	return false
end

local function ApplyDeformation(vehicle, deformation)
	if (not DoesEntityExist(vehicle)) then
		local endTime = GetGameTimer() + 5000
		while (not DoesEntityExist(vehicle) and GetGameTimer() < endTime) do
			Wait(0)
		end

		if (not DoesEntityExist(vehicle)) then
			return
		end
	end
	if (not IsEntityAVehicle(vehicle)) then return end

	if (deformation and #deformation > 0) then
		SetVehicleDeformation(vehicle, deformation)
	else
		SetVehicleDeformationFixed(vehicle)
	end
end

local damageUpdate = {}
local function HandleDeformationUpdate(vehicle)
	if (damageUpdate[vehicle]) then
		damageUpdate[vehicle] = GetGameTimer() + 1000
		return
	end

	damageUpdate[vehicle] = GetGameTimer() + 1000

	while (damageUpdate[vehicle] > GetGameTimer()) do
		Wait(0)
	end

	damageUpdate[vehicle] = nil

	if (not DoesEntityExist(vehicle) or NetworkGetEntityOwner(vehicle) ~= PlayerId()) then return end

	Entity(vehicle).state:set("deformation", GetVehicleDeformation(vehicle), true)
end

-- state bag handler to apply any deformation
AddStateBagChangeHandler("deformation", nil, function(bagName, key, value, _unused, replicated)
	if (bagName:find("entity") == nil) then return end

	ApplyDeformation(GetEntityFromStateBagName(bagName), value)
end)

-- update state bag on taking damage
AddEventHandler("gameEventTriggered", function (name, args)
	if (name ~= "CEventNetworkEntityDamage") then return end

	local entity = args[1]
	if (not IsEntityAVehicle(entity) or IsVehicleBlacklisted(entity)) then return end

	HandleDeformationUpdate(entity)
end)

-- fix deformation on vehicle
local function FixVehicleDeformation(vehicle)
	assert(DoesEntityExist(vehicle) and NetworkGetEntityIsNetworked(vehicle), "Parameter \"vehicle\" must be a valid and networked vehicle entity!")

	TriggerServerEvent("VD:fixDeformation", NetworkGetNetworkIdFromEntity(vehicle))
end

exports("FixVehicleDeformation", FixVehicleDeformation)
