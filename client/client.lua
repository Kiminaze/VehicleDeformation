
local function ApplyDeformation(vehicle, deformation)
	if (not IsEntityAVehicle(vehicle)) then return end

	Wait(500)

	if (not DoesEntityExist(vehicle)) then return end

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

	local deformation = GetVehicleDeformation(vehicle)
	if (not IsDeformationEqual(deformation, Entity(vehicle).state["deformation"])) then
		Entity(vehicle).state:set("deformation", deformation, true)
	end
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
	if (not IsEntityAVehicle(entity)) then return end

	HandleDeformationUpdate(entity)
end)

-- fix deformation on vehicle
local function FixVehicleDeformation(vehicle)
	assert(DoesEntityExist(vehicle) and NetworkGetEntityIsNetworked(vehicle), "Parameter \"vehicle\" must be a valid and networked vehicle entity!")

	TriggerServerEvent("VD:fixDeformation", NetworkGetNetworkIdFromEntity(vehicle))
end

exports("FixVehicleDeformation", FixVehicleDeformation)
