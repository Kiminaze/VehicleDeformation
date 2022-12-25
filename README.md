
## Support

If you require any form of support after acquiring this resource, the right place to ask is our 
Discord Server: https://discord.kiminaze.de

Make sure to react to the initial message with the tick and your language to get access to all 
the different channels.

Please do not contact anyone directly unless you have a really specific request that does not 
have a place in the server.


## What does it do exactly?

This is a small resource that allows saving and reapplying of vehicle bodywork deformation. It also 
features full synchronization of the damage between all players. No more weird situations where 
other players cannot see the damage on your vehicle!

I decided to release this for free for everyone since this is nearly one-of-a-kind now.

Fully compatible to my paid script [AdvancedParking](https://forum.cfx.re/t/release-advancedparking-prevents-despawns/2099582) 
where you can park any vehicle anywhere in the world.

Showcase video:




### Requirements

- OneSync (for the sync between players)


## Features

- Functions for getting/setting vehicle bodywork deformation.
- Included exports:
  - Getting deformation
  - Setting deformation
  - Fixing deformation
  - Checking if two deformations are equal
  - Checking if one deformation is worse than the other one.
- Uses entity state bags for full synchronization of bodywork deformation to all players.


## Performance

- Client Side: idle: 0.00ms; while applying deformation: 0.01ms
- Server Side: 0.00ms


## Installation instructions

1. Extract the downloaded folder into your resources.
2. Start the resource in your server.cfg:
	```
	ensure VehicleDeformation
	```
3. Repair the deformation using the `FixVehicleDeformation` export (more below).


## Exports usage

- Getting vehicle deformation (client only)
	```lua
	local deformation = exports["VehicleDeformation"]:GetVehicleDeformation(vehicle)
	```

- Setting vehicle deformation (client only)
	```lua
	exports["VehicleDeformation"]:SetVehicleDeformation(vehicle, deformation)
	```

- Fixing vehicle deformation (needs to be called when repairing a vehicle) (client and server)
	```lua
	exports["VehicleDeformation"]:FixVehicleDeformation(vehicle)
	```

- Check if first deformation is worse than second (client only)
	```lua
	exports["VehicleDeformation"]:IsDeformationWorse(firstDeformation, secondDeformation)
	```

- Check if first deformation is equal to second deformation (client only)
	```lua
	exports["VehicleDeformation"]:IsDeformationEqual(firstDeformation, secondDeformation)
	```


## Patchnotes

### Update v2.0.0:
- Now a proper resource and not just two exports and usage example.
- Deformation application now works better for vehicles with a low deformation multiplier.
- Better performance through a better use of state bags.
- No more "in-between-syncing" of damage. This used to cause the crumbling of the whole vehicle.
- Updated the license. If you are using this script in one of your resources, make sure to read it 
  again if you want to update!

### Hotfix v1.0.1:
- Fixed FixVehicleDeformation export from the example not syncing to every client properly.
