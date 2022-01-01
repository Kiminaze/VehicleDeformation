
local isInVehicle = false
local isDriver = false
local vehicle = nil

local currentlySetting = {}

-- main loop - checks for vehicles with deformation in a state bag and applies them if necessary
Citizen.CreateThread(function()

    while (true) do
        Citizen.Wait(1000)

        local playerPed = PlayerPedId()

        -- apply deformation
        local vehicles = GetAllVehiclesWithStateBag("deformations")
        for i, veh in ipairs(vehicles) do
            if (currentlySetting[plate] == nil) then
                local plate = GetVehicleNumberPlateText(veh)
                currentlySetting[plate] = true

                SetVehicleDeformation(veh, Entity(veh).state.deformations, function()
                    currentlySetting[plate] = nil
                end)
            end
        end

        if (not isInVehicle and IsPedInAnyVehicle(playerPed)) then
            isInVehicle = true
            vehicle = GetVehiclePedIsIn(playerPed)
        elseif (isInVehicle and not IsPedInAnyVehicle(playerPed)) then
            isInVehicle = false
            isDriver = false
        end
    end
end)

Citizen.CreateThread(function()
    local deformation = {}

    while (true) do
        Citizen.Wait(5000)

        -- get deformation from current vehicle
        if (isInVehicle and DoesEntityExist(vehicle)) then
            local playerPed = PlayerPedId()
            isDriver = GetPedInVehicleSeat(vehicle, -1) == playerPed

            if (isDriver) then
                local newDeformation = GetVehicleDeformation(vehicle)

                if (IsDeformationWorse(newDeformation, deformation)) then
                    deformation = newDeformation

                    SyncVehicleDeformation(vehicle, deformation)
                end
            end
        end
    end
end)



-- returns all client side vehicles with a specified state bag
function GetAllVehiclesWithStateBag(bagName)
    local stateVehicles = {}

    local vehicles = GetGamePool("CVehicle")
    for i, vehicle in ipairs(vehicles) do
        if (NetworkGetEntityIsNetworked(vehicle) and Entity(vehicle).state[bagName]) then
            table.insert(stateVehicles, vehicle)
        end
    end

    return stateVehicles
end

function IsDeformationWorse(newDef, oldDef)
    if (#newDef > #oldDef) then
        return true
    end
    if (#newDef < #oldDef) then
        return false
    end

    for i, new in ipairs(newDef) do
        local found = false
        for j, old in ipairs(oldDef) do
            if (new[1] == old[1]) then
                found = true

                if (new[2] > old[2]) then
                    return true
                end
            end
        end

        if (not found) then
            return true
        end
    end

    return false
end

-- sync deformation to all players
function SyncVehicleDeformation(vehicle, deformation)
    if (DoesEntityExist(vehicle) and NetworkGetEntityIsNetworked(vehicle)) then
        Log("Syncing deformation to other players.")
		TriggerServerEvent("VehicleDeformation:sync_sv", NetworkGetNetworkIdFromEntity(vehicle), deformation or GetVehicleDeformation(vehicle))
    end
end

-- fix deformation
function FixVehicleDeformation(vehicle)
    if (DoesEntityExist(vehicle) and NetworkGetEntityIsNetworked(vehicle)) then
		TriggerServerEvent("VehicleDeformation:fix_sv", NetworkGetNetworkIdFromEntity(vehicle))
    end
end
exports("FixVehicleDeformation", FixVehicleDeformation)

RegisterNetEvent("VehicleDeformation:fix_cl")
AddEventHandler("VehicleDeformation:fix_cl", function(netId)
	local vehicle = NetworkGetEntityFromNetworkId(netId)

	if (DoesEntityExist(vehicle)) then
		SetVehicleDeformationFixed(vehicle)
	end
end)
