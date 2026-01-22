# Introduction

This mod is designed to assist blind or visually impaired players navigate hades II better, by helping them locate enemies, interactibles, NPCs, breakables, and exits. It includes the following features:
-A tracking Beacon: Sound pings that change based on whether a target is in front of or behind you.
-Animation Announcements: Realtime report of tracked targets' animations, useful to learn enemy patterns.
-Navigation Tools: Optional wall collision sounds, as well as teleportation to targets (Experimental).
-Target info announcements: Announces the selected target's distance and status
Note that while this mod requires Lirin's Tolk Compatibility mod to function, it does not conflict with any other accessibility mods. This mod is meant to be complementary to Lirin's Accessibility Mod. If you do not have it installed, make sure to download it. (Instructions for installation can be found here)https://forum.audiogames.net/topic/53522/hades-ii-106-full-accessibility-is-out/ . 

# Usage

## Controller 

Mod features are accessed via a Mod Layer. You hold down the modifier key to "freeze" your character and use other buttons to scan the room.
###Controls:
-Modifier Key: Hold LT to activate the mod layer.
-Cycle Category: While holding the modifier, press Attack (X / Square) for previous category, and special attack (Y / Triangle) for next
-Cycle Targets: While holding the modifier, press Special interact (LB / L1) or Interact (RB / R1) for previous and next respectively
-Track most important or closest: Press Dash (Cross / a) while holding the modifier button. Keep in mind that this behaves differently depending on whether or not sort by score is enabled. See config section for details.
-Get Target Info: Press Cast (Circle / b) while holding modifier. Speaks name, health, distance.
-Teleport to Target: Press Inventory (Dpad right) (Only works if no enemies are active).
-Speak Player Info: Press Codex(Dpad up) while holding modifier.
-Place or remove a permanent beacon for the focused object: Hold Cast (Circle / B) for 0.25 seconds (default) while holding down the modifier button. Note: Permanent beacons work based on object type rather than unique objects. If you place a permanent beacon on 'Ashes', all instances of that item will beep without you having to track it. Permanent beacon objects appear in the 'Active beacon objects' category. 
-Toggle beacon sounds on and off: Hold Special Attack (Triangle / y) for 0.25 seconds (default) while holding the modifier button
-Stop Tracking: Double-tap the Modifier button (LT).

### Keyboard controls

These do not require you to  use the mod layer. In addition, these controls can be changed from the mod's config under [config.AccessModControls.KeyboardControls]. The defaults are:
-Prev/Next Target: [ and ]
-Prev/Next Category: Shift + [ and Shift + ]
-Track Closest | most important: \ depends on if sort by score is enabled
-Target Info: '
-Player Info: P
-Teleport to Target: O, (Only outside combat)
-Place or remove a permanent beacon for the focused object: Shift + \ (Does not require holding). Note: Permanent beacons work based on object type rather than unique objects. If you place a permanent beacon on 'Ashes', all instances of that item will beep without you having to track it. Permanent beacon objects appear in the 'Active beacon objects' category. 
-Stop tracking: Backspace
-Toggle beacon on or off: Shift + Bakspace (Does not require holding)

# Configuration (config.cfg)

## AccessDisplay (How things are spoken)

- AnnounceAnimations: Speak animation names of tracked targets when they update.
- AnnounceAnimationsDuringDialog: Animations are automatically sspoken for all participents during dialog. You can choose to turn this off  here
- AnnounceObstacles: Speak the name of objects you collide with.
- DescribeStatusEffects: Gives a short description of what an effect does when it's announced in player or target info
- ShortenHealthStrings: Set to true for "50 of 100" instead of "50 of 100 health."
- InfoArray: The order of data spoken during a target check (e.g., Name, Health, Dist). Set any entry to "None" or any invalid string to prevent it from appearing. 
- LongInfoArray: The order of data spoken during a manual target or player info check, functions similarly to InfoArray but usually contains more information. Set any entry to "None" or any invalid string to prevent it from appearing. 
- CategoriesArray: Determines which groups are available when cycling categories, as well as their order. Note that a category has to also be configured down in the CategoryTables, otherwise it would just appear as "Unconfigured".

## AccessModNavigation (Collisions)
- PlayWallCollisionSounds: Plays a sound when walking into walls.
- PlayObstacleCollisionSounds: Plays a sound when running in to objects, (useless for now).
- WallCollisionSound: The audio GUID used for the collision ping, if you wanted to use your own audioBank for some reason.

## AccessModControls
 DOUBLE_TAP_THRESHOLD: How fast you must press the modifier to stop tracking (default 0.25 seconds).
- controlHoldTimer: For actions that require you to hold a specific control, this determines the amount of time (in seconds) you have to hold it for. Defaults to 0.25
### Keyboard controls
Allows you to change the default keyboard controls and customize them however you wish. Sintax for control names is "Modifier Key", or "None Key", should you wish to not use any modifiers. For a list of every possible key, refer to [this map](https://github.com/SGG-Modding/Hell2Modding/blob/6d1cb8ed8870a401ac1cefd599bf2ae3a270d949/src/lua_extensions/bindings/hades/inputs.cpp#L204-L298)
####Examples of default controls, so that you have an idea: 
- PreviousCategory = Shift OemOpenBrackets
- NextCategory = Shift OemCloseBrackets
- PreviousTarget = None OemOpenBrackets
- NextTarget = None OemCloseBrackets
- TargetFirst = None OemPipe
- SpeakTargetInfo = None OemQuotes
- SpeakPlayerInfo = None P
- TeleportToTarget = None O
- StopTracking = "None Back"
            - ToggleBeaconSounds = "Shift Back"
            - TogglePermanentBeacon = "Shift OemPipe"

## TrackingBeaconGlobal (Audio Beacon)

- Toggle: Enable or disable beacon sounds. In case you wanted this mod just for target info
- ScaleFactor: Distance divider. 100.0 means 500 units is spoken as "5."
- MaxDistance: Objects beyond this range are ignored by the beacon.
- MinInterval / MaxInterval: The speed of the ping. The ping is faster (Min) when close and slower (Max) when far.
- SortByScore: If true, the beacon prioritizes important targets (Bosses/HighThreat enemies, boons, Harvestables etc...). if this is set to false, the mod defaults to sorting targets by distance

## CategoryWeights

Adjusts the priority of object types when SortByScore is active:
- Unit: 3.0 (Enemies/NPCs)
- Loot: 3.0 (Boons/Hammer)
- Door: 2.5 (Exits)
- Weapon: 1.6 (Weapon Kits)

## TrackingBeaconTargetCategories (Filters)

Modify how specific categories behave: You can either make your own categories or edit existing ones. Filter examples include:
- IgnoreInvulnerable: If true, the beacon skips objects that cannot be damaged.
- IgnoreSelf: Prevents the beacon from tracking the player character.
- LinkedCategories: Allows a category to search for multiple types (e.g., Terrain also finds Traps). Note, these use the configuration of the parrent category
- DestinationTypes: Adds specific internal object names (like ShipWheels) to a category.

# Target Scoring System (For the curious)

If sort by score is enabled, the Tracking Beacon uses a dynamic scoring system to prioritize objects and enemies based on their immediate importance to gameplay. Instead of simply tracking the closest target, it calculates a score by evaluating the following factors:

## Enemies and NPCs

- Aggression: Enemies actively attacking or chasing you receive a massive score increase to ensure they are tracked first.
- Threat Level: Bosses and Elite enemies are prioritized over standard units.
- Health and Armor: Targets with high maximum health or active armor buffers receive higher scores. 
- Story and Progression: NPCs with new dialogue, important "wants to talk" icons, or those required to progress the current room are given higher priority.
- Gifting: Any character eligible to receive a gift (like Nectar) receives a score boost.

## Exit Doors

- Pinned Items: If you have "pinned" a specific resource, any door offering that reward becomes a top priority.
- High-Value Upgrades: Doors offering Hammers (Weapon Upgrades), God Boons, or Pom Upgrades are scored higher.
- Health Needs: If your health is low, doors offering healing rewards receive a significant boost. Conversely, doors with a health cost are penalized when your health is low but prioritized when you are healthy.
- Encounter Type: Doors leading to Boss or Mini-boss encounters are prioritized over standard rooms.

## Loot and Consumables

- Loot: Major loot like Boons from Gods or Selene are prioritized over generic items.
- Dropped Rewards: Items already on the ground, such as Gold or bones, receive a high priority boost to ensure they are collected.
- Affordability: If an item has a resource cost (like Gold Crowns) that you cannot afford, its score is reduced to prevent the beacon from leading you to something you cannot buy.

## Resources and Obstacles

- Gathering Tools: Resource nodes (like Ore or Fish) receive a score boost, but this is heavily reduced if you do not have the required tool equipped.
- Stat Boosts: Objects that provide Max Health, Mana, or Rerolls increase in priority based on the value of the boost.
- Interaction Blocks: If an object is currently blocked by enemies or is otherwise not useable, its score is reduced.

## Weapons

- Bonus Rewards: In the training area, weapons currently offering a "Grave Thirst" bonus are prioritized over others.

If you run in to any issues, please contact me at aminelog25@gmail.com. have fun
