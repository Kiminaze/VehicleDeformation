
-- set to true to see debug messages
local DEBUG = false

-- iterations for damage application
local MAX_DEFORM_ITERATIONS = 50
-- the minimum damage value at a deformation point before being registered as actual damage
local DEFORMATION_DAMAGE_THRESHOLD = 0.05

-- gets deformation from a vehicle
function GetVehicleDeformation(vehicle)
	assert(vehicle ~= nil and DoesEntityExist(vehicle), "Parameter \"vehicle\" must be a valid vehicle entity!")

	local offsets = GetVehicleOffsetsForDeformation(vehicle)

	-- get deformation from vehicle
	local deformationPoints = {}
	for i, offset in ipairs(offsets) do
		-- translate damage from vector3 to a float
		local dmg = math.floor(#(GetVehicleDeformationAtPos(vehicle, offset)) * 1000.0) / 1000.0
		if (dmg > DEFORMATION_DAMAGE_THRESHOLD) then
			table.insert(deformationPoints, { offset, dmg })
		end
	end

	LogDebug("Got %s deformation point%s from \"%s\".", #deformationPoints, #deformationPoints == 1 and "" or "s", GetVehicleNumberPlateText(vehicle))

	return deformationPoints
end

-- sets deformation on a vehicle
function SetVehicleDeformation(vehicle, deformationPoints, callback)
	assert(vehicle ~= nil and DoesEntityExist(vehicle), "Parameter \"vehicle\" must be a valid vehicle entity!")
	assert(deformationPoints ~= nil and type(deformationPoints) == "table", "Parameter \"deformationPoints\" must be a table!")

	-- ignore if deformation is already worse
	if (not IsDeformationWorse(deformationPoints, GetVehicleDeformation(vehicle))) then return end

	Citizen.CreateThread(function()
		-- set damage multiplier from vehicle handling data
		local fDeformationDamageMult = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDeformationDamageMult")
		local damageMult = 20.0
		if (fDeformationDamageMult <= 0.55) then
			damageMult = 1000.0
		elseif (fDeformationDamageMult <= 0.65) then
			damageMult = 400.0
		elseif (fDeformationDamageMult <= 0.75) then
			damageMult = 200.0
		end

		local printMsg = false

		for i, def in ipairs(deformationPoints) do
			def[1] = vector3(def[1].x, def[1].y, def[1].z)
		end

		-- iterate over all deformation points and check if more than one application is necessary
		-- looping is necessary for most vehicles that have a really bad damage model or take a lot of damage (e.g. neon, phantom3)
		local deform = true
		local iteration = 0
		while (deform and iteration < MAX_DEFORM_ITERATIONS) do
			if (not DoesEntityExist(vehicle)) then
				LogDebug("Vehicle \"" .. tostring(GetVehicleNumberPlateText(vehicle)) .. "\" got deleted mid-deformation.")
				return
			end

			deform = false

			-- apply deformation if necessary
			for i, def in ipairs(deformationPoints) do
				if (#(GetVehicleDeformationAtPos(vehicle, def[1])) < def[2]) then
					SetVehicleDamage(
						vehicle, 
						def[1] * 2.0, 
						def[2] * damageMult, 
						1000.0, 
						true
					)

					deform = true
				end
			end

			iteration = iteration + 1

			Citizen.Wait(100)
		end

		LogDebug("Applying deformation finished for \"" .. tostring(GetVehicleNumberPlateText(vehicle)) .. "\"")

		if (callback) then
			callback()
		end
	end)
end

-- returns true if deformation is worse
function IsDeformationWorse(newDef, oldDef)
	assert(newDef ~= nil and type(newDef) == "table", "Parameter \"newDeformation\" must be a table!")
	assert(oldDef == nil or type(oldDef) == "table", "Parameter \"oldDeformation\" must be nil or a table!")

	if (oldDef == nil or #newDef > #oldDef) then
		return true
	elseif (#newDef < #oldDef) then
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

-- returns true if deformation is equal
function IsDeformationEqual(newDef, oldDef)
	assert(newDef == nil or type(newDef) == "table", "Parameter \"newDeformation\" must be nil or a table!")
	assert(oldDef == nil or type(oldDef) == "table", "Parameter \"oldDeformation\" must be nil or a table!")

	if (oldDef == nil and newDef == nil) then
		return true
	end
	if (oldDef == nil or newDef == nil or #newDef ~= #oldDef) then
		return false
	end

	for i, def in ipairs(newDef) do
		if (def[2] ~= oldDef[i][2]) then
			return false
		end
	end

	return true
end

-- returns offsets for deformation check
function GetVehicleOffsetsForDeformation(vehicle)
	-- check vehicle size and pre-calc values for offsets
	local min, max = GetModelDimensions(GetEntityModel(vehicle))
	local X = Round((max.x - min.x) * 0.5, 2)
	local Y = Round((max.y - min.y) * 0.5, 2)
	local Z = Round((max.z - min.z) * 0.5, 2)
	local halfY = Round(Y * 0.5, 2)

	return {
		vector3(-X, Y,  0.0),
		vector3(-X, Y,  Z),

		vector3(0.0, Y,  0.0),
		vector3(0.0, Y,  Z),

		vector3(X, Y,  0.0),
		vector3(X, Y,  Z),


		vector3(-X, halfY,  0.0),
		vector3(-X, halfY,  Z),

		vector3(0.0, halfY,  0.0),
		vector3(0.0, halfY,  Z),

		vector3(X, halfY,  0.0),
		vector3(X, halfY,  Z),


		vector3(-X, 0.0,  0.0),
		vector3(-X, 0.0,  Z),

		vector3(0.0, 0.0,  0.0),
		vector3(0.0, 0.0,  Z),

		vector3(X, 0.0,  0.0),
		vector3(X, 0.0,  Z),


		vector3(-X, -halfY,  0.0),
		vector3(-X, -halfY,  Z),

		vector3(0.0, -halfY,  0.0),
		vector3(0.0, -halfY,  Z),

		vector3(X, -halfY,  0.0),
		vector3(X, -halfY,  Z),


		vector3(-X, -Y,  0.0),
		vector3(-X, -Y,  Z),

		vector3(0.0, -Y,  0.0),
		vector3(0.0, -Y,  Z),

		vector3(X, -Y,  0.0),
		vector3(X, -Y,  Z),
	}
end

-- rounds a float to the given number of decimals
function Round(value, numDecimals)
	return math.floor(value * 10^numDecimals) / 10^numDecimals
end

function LogDebug(text, ...)
	if (DEBUG) then
		print(string.format(string.format("^0[DEBUG] %s^0", text), ...))
	end
end



exports("GetVehicleDeformation", GetVehicleDeformation)
exports("SetVehicleDeformation", SetVehicleDeformation)
exports("IsDeformationWorse", IsDeformationWorse)
exports("IsDeformationEqual", IsDeformationEqual)
