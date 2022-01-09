
-- sync vehicle deformation
RegisterNetEvent("VehicleDeformation:sync_sv")
AddEventHandler("VehicleDeformation:sync_sv", function(netId, deformation)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if (DoesEntityExist(vehicle)) then
        Entity(vehicle).state.deformations = deformation
    end
end)

-- fix vehicle deformation
RegisterNetEvent("VehicleDeformation:fix_sv")
AddEventHandler("VehicleDeformation:fix_sv", function(netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if (DoesEntityExist(vehicle)) then
        Entity(vehicle).state.deformations = {}

        Citizen.Wait(1000)

        TriggerClientEvent("VehicleDeformation:fix_cl", -1, netId)
    end
end)
