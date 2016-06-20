# Penguin Jump: CIS55 Project

Penguin Jump is a 2D infinite runner game created for the iOS programming CIS55 course at De Anza College.

## Team Members

Matthew Tso, Seung (David) Park

## Requirements

### Build

Xcode 7.2, iOS 9.0 SDK

### Runtime

iOS 9.2

## About Penguin Jump

### Premise:

As sea levels rise, survive extreme weather by jumping from one iceberg to another for as long as you can! Don’t let high winds, lightning, and hungry sharks get in your way. Collect coins to unlock all the items in your wardrobe!

### Gameplay

Penguin Jump has one game mode: an endless mode. The world is comprised of an open ocean and a path of platforms made of icebergs. When the player lands on an iceberg, the iceberg begins to slowly sink and disappear when it reaches sea level. The goal is to survive by jumping from one sinking iceberg to another and avoid falling into the ocean, where deadly sharks are waiting.

A storm mode is activated when the player's storm bar is fully charged from coin particles. During storm mode, strong winds constantly push the player left or right. Because the wind can be deadly, points collected during storm mode are doubled.

A storm cloud appears periodically and when the player moves into range, lightning strikes underneath the cloud several times. Once the lightning strikes end, the cloud disappears.

A shark will periodically roam in front of an iceberg. This shark's fin sticks up out of the water, and when the player jumps over the shark, the shark ends the player's run by jumping out of the water and pulling the player down.

Coins around the stage can be collected towards a persistent total. Watch out, though, picking up coins charges a bar that initiates storm mode which can catch the player off guard depending on the other obstacles already on the stage. This persistent coin total is used to unlock clothing items in the wardrobe accessible from the game's start menu.

### Touch Controls

The player can only jump in a positive Y (up and down) direction. The targeting reticle locks when the reticle's Y position is the same as the penguin. 

When the player touches the penguin, a targeting reticle appears while the touch is registered. The targeting reticle is aimed opposite of where the touch is relative to the penguin. The penguin performs a jump to the location of the targeting reticle at the moment of touch release. The jump lasts the same amount of time no matter the distance traveled. 

While the penguin is in the air, a swift swipe gesture will make the penguin perform a second jump that resets the jump timer and jump direction.

## More Information

The project is hosted at https://github.com/seungprk/PenguinJump/ .

Copyright (C) Seung Park and Matthew Tso
