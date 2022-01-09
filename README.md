
**Support**

If you require any form of support after acquiring this resource, the right place to ask is our 
Discord Server: https://discord.gg/UyAu2jABzE

Make sure to react to the initial message with the tick and your language to get access to all 
the different channels.

Please do not contact anyone directly unless you have a really specific request that does not 
have a place in the server.


## What does it do exactly?

This is a small code snippet (and resource that can be used with it) that allows the saving and 
applying of vehicle bodywork deformation.

This is actively been used in my paid script [AdvancedParking](https://forum.cfx.re/t/release-advancedparking-prevents-despawns/2099582) where you can park any vehicle 
anywhere on the map completely dynamically.

I decided to release this for free for everyone since this is nearly one-of-a-kind now.

Showcase video: https://www.youtube.com/watch?v=bxdsG5_DeXo


### Requirements

- OneSync (optional, only for the example resource and not for the actual functions needed)


## Features

- Functions for getting/setting vehicle bodywork deformation
- exports to go with it
- example resource to see how it works


## Planned Features

- More optimizations regarding the visual damage application.


### Performance

- Client Side: 0.00ms

Example Resource:
- Client Side: 0.00-0.01ms
- Server Side: 0.00ms


### Installation instructions

1. Extract the downloaded folder into your resources.
2. Start the resource in your server.cfg:
```
ensure VehicleDeformation
```
However this is not necessary if not using the example resource. If you know how to write/edit lua 
code, you can just copy the deformation.lua inside your own script and use it there. This could e.g. 
be used inside the es_extended framework (in ESX.Game.Get/SetVehicleProperties).
Please always keep the license in mind!


### Export usage (client side)

- getting vehicle deformation
```lua
local deformation = exports["VehicleDeformation"]:GetVehicleDeformation(vehicle)
```

- setting vehicle deformation
```lua
exports["VehicleDeformation"]:SetVehicleDeformation(vehicle, deformation)
```

- fixing vehicle deformation (when using the example; needs to be called when repairing the vehicle)
```lua
exports["VehicleDeformation"]:FixVehicleDeformation(vehicle)
```


### Patchnotes

Hotfix v1.0.1:
- Fixed FixVehicleDeformation export from the example not syncing to every client properly.
