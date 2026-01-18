return {
    -- Mod display settings: how things get announced.
    AccessDisplay = {
        AnnounceAnimations = true,
        AnnounceAnimationsDuringDialog = true,
        AnnounceObstacles = true,
        DescribeStatusEffects = true,
        ShortenHealthStrings = false,
        -- Use the following arrays to sort how you would like info and categories to be displayed, and which ones appear on their respective lists. Note that you can easily break this should you misspell something. 
        InfoArray = {"Armor", "Health", "Name", "DoorInfo", "ItemInfo", "WeaponInfo", "GardenInfo", "Anim", "Dist", "Effects" },
        -- this next array is used when getting info manually, such as when pressing lt + b / circle, or lt + dpad up for player info
        LongInfoArray = {"Dist", "Armor", "Health", "Mana", "LastStand", "DoorInfo", "ItemInfo", "WeaponInfo", "GardenInfo", "Anim", "Effects", "Description" },
        CategoriesArray = { "Interactibles", "EnemyTeam", "NPCs", "ConsumableItems", "Loot", "HeroTeam", "Terrain", "Traps", "Familiars", "ExitDoors" },
    },
    -- Navigation config
    AccessModNavigation = {
        PlayObstacleCollisionSounds = false, -- No sound for now
        PlayWallCollisionSounds = true,
        UseNavRadar = false, -- Unfinished
        WallCollisionSound = "{0381e8ca-ae3a-41ea-99b2-cc64dc0fff55}"
    },
    AccessModControls = {
        DOUBLE_TAP_THRESHOLD = 0.25, -- The timing window for how fast you can double tap certain controls to which this is applicable
    },
    -- Global Beacon Settings
    TrackingBeaconGlobal = {
        Toggle = true,
        -- Factor to divide raw distance by for display (e.g., 100.0 means 100 units = 1 unit display)
        ScaleFactor = 100.0,

        -- Max distance for beacon sound interval calculation (1200 by default)
        MaxDistance = 1200,

        -- Minimum and maximum interval (in seconds) that the beacon sound can play.
        MinInterval = 0.25,
        MaxInterval = 0.75,

        -- Sorting: True means targets are scored then sorted based on which is most important. False sorts by distance
        SortByScore = true,

        -- Target weights: used to prioritize object types for smart tracking
    CategoryWeights = {
        Unit = 3.0, -- both enemies and npcs
    Door = 2.5, -- Exits
    Loot = 3.0, -- Upgrades such as god boons
    Obstacle = 1.8, -- from items to interactibles
    Weapon = 1.6, -- Equippable weapons
    Familiar = 1.2,
}
        },

    -- Sound event paths/GUIDs used for the beacon
    TrackingBeaconSounds = {
        Normal = "{40f54a8d-17a4-4d33-b03e-6fe020dac116}",
        Front = "{cb919672-4850-46ed-b501-0ba4f9b515ed}",
        Behind = "{1463e33d-d26e-4974-a53d-f01ef54357ba}",
    },

    -- Target Categories
    -- This table defines which types of objects to track and the filtering options
    -- to pass to the GetClosestIds function for each category. You can use this to adjust how categories are displayed. 
    TrackingBeaconTargetCategories = {
        ConsumableItems = {
            DisplayName = "Items",
            IgnoreInvulnerable = false,
            IgnorePermanentlyInvulnerable = false,
            IgnoreHomingIneligible = false,
            IgnoreSelf = true,
            StopsProjectiles = false,
            StopsUnits = false
        },
        EnemyTeam = {
            DisplayName = "Enemies",
            IgnoreInvulnerable = false,
            IgnorePermanentlyInvulnerable = true, 
            IgnoreHomingIneligible = false,
            IgnoreSelf = true,
            StopsProjectiles = true, 
            StopsUnits = false,
            LinkedCategories = {"GroundEnemies", "FlyingEnemies", "Automatons", "ChronosForces"},
        },
        HeroTeam = {
            DisplayName = "Allies",
            IgnoreInvulnerable = false,
            IgnorePermanentlyInvulnerable = false,
            IgnoreHomingIneligible = true,
            IgnoreSelf = true,
            StopsProjectiles = true,
            StopsUnits = false,
            LinkedCategories = {"Familiars",}
        },
         Loot = {
            DisplayName = "Boons",
            IgnoreInvulnerable = false,
            IgnorePermanentlyInvulnerable = false,
            IgnoreHomingIneligible = false,
            IgnoreSelf = true,
            StopsProjectiles = false,
            StopsUnits = false,
         },
        NPCs = {
                        DisplayName = "NPCs",
            IgnoreInvulnerable = false,
            IgnorePermanentlyInvulnerable = false,
            IgnoreHomingIneligible = false,
            IgnoreSelf = true,
            StopsProjectiles = true, 
            StopsUnits = false,
            DestinationTypes = { "PastZag"},
        },
        ExitDoors = {
            DisplayName = "Exits",
            IgnoreInvulnerable = false,
            IgnorePermanentlyInvulnerable = false,
            IgnoreHomingIneligible = false,
            IgnoreSelf = true,
            StopsProjectiles = false, 
            StopsUnits = false,
            DestinationTypes = {"ShipWheels"}
        },
        Terrain = {
            DisplayName = "Terrain",
            IgnoreInvulnerable = false,
            IgnorePermanentlyInvulnerable = false,
            IgnoreHomingIneligible = false,
            IgnoreSelf = true,
            StopsProjectiles = true, 
            StopsUnits = true,
            LinkedCategories = {"Traps",}
        },
        Traps = {
            DisplayName = "Traps",
            IgnoreInvulnerable = false,
            IgnorePermanentlyInvulnerable = false,
            IgnoreHomingIneligible = false,
            IgnoreSelf = true,
            StopsProjectiles = false, 
            StopsUnits = false
        },
                Familiars= {
            DisplayName = "Familiars",
            IgnoreInvulnerable = false,
            IgnorePermanentlyInvulnerable = false,
            IgnoreHomingIneligible = false,
            IgnoreSelf = true,
            StopsProjectiles = false, 
            StopsUnits = false
        },
        Interactibles = {
            DisplayName = "Interactibles",
            IgnoreInvulnerable = false,
            IgnorePermanentlyInvulnerable = false,
            IgnoreHomingIneligible = false,
            IgnoreSelf = true,
            StopsProjectiles = false, 
            StopsUnits = false,
            DestinationTypes = {"WeaponKit01", "FamiliarKit", "ShipWheels", "NightMirror", "HadesFountain", "WitchHut", "PalaceForcefield"},
            LinkedCategories = {"Loot", "NPCs", "ConsumableItems", "ExitDoors",}
        },
    },
}