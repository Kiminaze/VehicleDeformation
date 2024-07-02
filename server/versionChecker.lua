
local AUTHOR <const>		= "Kiminaze"
local RESOURCE_NAME <const>	= "VehicleDeformation"
local GITHUB_URL <const>	= "https://api.github.com/repos/%s/%s/releases/latest"

local RENAME_WARNING <const>	= "^3[WARNING] This resource should not be renamed. This can and will lead to errors in the long run.^0"
local CHECK_FAILED <const>		= "^3[WARNING] Checking for latest version failed! Http Error: %s^0"
local NEW_VERSION <const>		= "^5[INFO] There is a new version available! Latest version: %s - Your version: %s\nDirect download: %s\nLatest patch notes:\n%s^0"

CreateThread(function()
	if (RESOURCE_NAME ~= GetCurrentResourceName()) then
		print(RENAME_WARNING)
	end

	PerformHttpRequest(GITHUB_URL:format(AUTHOR, RESOURCE_NAME), CheckVersionCallback, "GET")
end)

local function SplitVersionNumber(version)
	local nums = {}

	for num in version:gmatch("([^.]+)") do
		nums[#nums + 1] = tonumber(num)
	end

	return nums
end

function CheckVersionCallback(status, response, headers)
	if (status ~= 200) then
		print(CHECK_FAILED:format(status))
		return
	end

	local latestRelease = json.decode(response)

	local latestVersion = latestRelease.tag_name:gsub("v", "")
	local currentVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)

	if (latestVersion == currentVersion) then return end

	local current = SplitVersionNumber(currentVersion)
	local latest = SplitVersionNumber(latestVersion)

	for i = 1, #current do
		if (current[i] < latest[i]) then
			print(NEW_VERSION:format(latestVersion, currentVersion, latestRelease.assets[1].browser_download_url, latestRelease.body))
			break
		end
	end
end
