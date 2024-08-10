
-- set to true to see debug messages
local DEBUG = true

-- iterations for damage application
local MAX_DEFORM_ITERATIONS <const> = 50

-- the minimum damage value at a deformation point before being registered as actual damage
local DEFORMATION_DAMAGE_THRESHOLD <const> = 0.05

-- max difference for angle to be considered to steep (0.0-1.0)
local ANGLE_THRESHOLD <const> = 0.5

local INITIAL_DAMAGE <const> = 50.0
local DAMAGE_INCREMENTS <const> = 5.0

-- cache for deformation offsets
local deformationOffsets = {}

local math_floor, table_insert, table_remove = math.floor, table.insert, table.remove

-- gets deformation from a vehicle
function GetVehicleDeformation(vehicle)
	assert(vehicle ~= nil and DoesEntityExist(vehicle), "Parameter \"vehicle\" must be a valid vehicle entity!")

	local offsets = GetVehicleOffsetsForDeformation(vehicle)

	-- get deformation from vehicle
	local deformationPoints = {}
	for i = 1, #offsets do
		local projectedDamageVector = ClampVectorAlongAxis(GetVehicleDeformationAtPos(vehicle, offsets[i].x, offsets[i].y, offsets[i].z), -offsets[i])
		if (#(projectedDamageVector) > DEFORMATION_DAMAGE_THRESHOLD) then
			deformationPoints[#deformationPoints + 1] = { offsets[i], projectedDamageVector }
		end
	end

	LogDebug("Got %s deformation point(s) from \"%s\".", #deformationPoints, GetVehicleNumberPlateText(vehicle))

	return deformationPoints
end

-- sets deformation on a vehicle
function SetVehicleDeformation(vehicle, deformationPoints, callback)
	assert(vehicle ~= nil and DoesEntityExist(vehicle), "Parameter \"vehicle\" must be a valid vehicle entity!")
	assert(deformationPoints ~= nil and type(deformationPoints) == "table", "Parameter \"deformationPoints\" must be a table!")

	-- ignore if deformation is already worse
	-- TODO: BROKEN AS OF NOW
	--if (not IsDeformationWorse(deformationPoints, GetVehicleDeformation(vehicle))) then return end

	if (deformationPoints[1] and type(deformationPoints[1][2]) == "number") then
		LogDebug("Got pre v2.2.0 data, ignoring function call...")
		return
	end

	CreateThread(function()
		local deform = true
		local iterations = 0
		while (deform and iterations < MAX_DEFORM_ITERATIONS) do
			if (not DoesEntityExist(vehicle)) then
				LogDebug("Vehicle got deleted mid-deformation.")
				return
			end

			deform = false

			for i, def in ipairs(deformationPoints) do
				local currDef = GetVehicleDeformationAtPos(vehicle, def[1].x, def[1].y, def[1].z)
				local clampedDef = ClampVectorAlongAxis(currDef, -vector3(def[1].x, def[1].y, def[1].z))
				if (#clampedDef < #vector(def[2].x, def[2].y, def[2].z)) then
					-- damage/radius increase method - seems to work best for most vehicles
					if (def[3] == nil) then
						def[3] = INITIAL_DAMAGE
					else
						def[3] = def[3] + DAMAGE_INCREMENTS
					end
					SetVehicleDamage(
						vehicle, 
						def[1].x, def[1].y, def[1].z, 
						def[3], -- damage
						def[3], -- radius
						true
					)

					deform = true

					Wait(0)
				end
			end

			iterations = iterations + 1

			Wait(0)
		end

		if (not IsVehicleBlacklisted(vehicle)) then
			local state = Entity(vehicle).state
			if (state.deformation == nil) then
				state:set("deformation", deformationPoints, true)
			end
		end

		LogDebug("Applying deformation finished for \"%s\" in %s iterations.", GetVehicleNumberPlateText(vehicle), iterations)

		if (callback) then
			callback()
		end
	end)
end

-- returns true if deformation is worse
-- TODO: BROKEN AS OF NOW
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
			if (#new[1] == #old[1]) then
				found = true

				if (#new[2] > #old[2]) then
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
-- TODO: PROBABLY BROKEN AS WELL
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
		if (#def[2] ~= #oldDef[i][2]) then
			return false
		end
	end

	return true
end

-- returns offsets for deformation check
function GetVehicleOffsetsForDeformation(vehicle)
	local model = GetEntityModel(vehicle)

	if (deformationOffsets[model]) then
		return deformationOffsets[model]
	end

	local pos = GetEntityCoords(PlayerPedId()) + vector3(0, 0, -50)
	local newVehicle = CreateVehicle(model, pos.x, pos.y, pos.z, 0.0, false, false)
	FreezeEntityPosition(newVehicle, true)
	SetEntityAlpha(newVehicle, 0)

	local min, max = GetModelDimensions(model)

	local defPoints = {}

	local count = 0
	for x = -1, 1, 0.25 do
		for y = 1, -1, -0.25 do
			for z = -1, 1, 0.5 do
				if ((y < -0.55 or y > 0.55) and z > -0.6) then
					count += 1

					defPoints[count] = vector3(
						(max.x - min.x) * x * 0.5 + (max.x + min.x) * 0.5,
						(max.y - min.y) * y * 0.5 + (max.y + min.y) * 0.5,
						(max.z - min.z) * z * 0.5 + (max.z + min.z) * 0.5
					)
				end
			end
		end
	end

	for i = #defPoints, 1, -1 do
		if (IsPointTooFarFromVehicle(defPoints[i], newVehicle)) then
			table_remove(defPoints, i)
		end
	end

	DeleteEntity(newVehicle)

	deformationOffsets[model] = defPoints

	return defPoints
end

-- checks if a point is too far from the vehicle or the angle too steep
function IsPointTooFarFromVehicle(point, vehicle)
	local vehPos = GetEntityCoords(vehicle)
	local pointInWorld = GetOffsetFromEntityInWorldCoords(vehicle, point.x, point.y, point.z)
	local _, hit, position, normal, hitEntity = GetShapeTestResult(
		StartExpensiveSynchronousShapeTestLosProbe(pointInWorld.x, pointInWorld.y, pointInWorld.z, vehPos.x, vehPos.y, vehPos.z, 2, 0, 0)
	)

	if (not hit or hitEntity ~= vehicle) then
		return true
	end

	-- return angle difference > threshold
	return 1.0 - dot(norm(pointInWorld - position), norm(normal)) > ANGLE_THRESHOLD
end

-- clamps a vector on an an arbitrary axis
function ClampVectorAlongAxis(v, axis)
	local axisNorm = norm(axis)

	return dot(v, axisNorm) * axisNorm
end

-- rounds a float to the given number of decimals
function Round(value, numDecimals)
	return math_floor(value * 10^numDecimals) / 10^numDecimals
end

function LogDebug(text, ...)
	if (DEBUG) then
		print(("^0[DEBUG] %s^0"):format(text):format(...))
	end
end



exports("GetVehicleDeformation", GetVehicleDeformation)
exports("SetVehicleDeformation", SetVehicleDeformation)
exports("IsDeformationWorse", IsDeformationWorse)
exports("IsDeformationEqual", IsDeformationEqual)
exports("GetDeformationOffsets", GetVehicleOffsetsForDeformation)
