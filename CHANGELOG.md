# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.0] - 2026-01-22

### Added

- You can now add permanent beacons to objects to make them beep without having to track them. Useful with familiars. Note that this is still experimental and not as good as I'd want it to be, so feedback would be appreciated. 
- You can now mute or unmute beacon sounds. This includes those of the permanent beacon
- For controler users: Added a system for control holds to perform alternative actions, so now I have more options for controls to use in for if new features get added. You can configure how long you have to hold buttons for in [AccessModControls.controlHoldTimer] set to 0.25 by default
- Added the option to override user config entries for necessary resets. This shouldn't happen often, but know that it is necessary for this particular update. 
- For anyone wanting to mess around with the sounds, The repository now includes the fmod project used to create the  audiobank. The data folder also contains the GUIDs.txt. 

### Changed

- This update will reset the [AcccessDisplay.LongInfoArray] config entry to defaults. Apologies for this, but it is necessary. 

### Fixed

- You should no longer be able to teleport while you are concocting witchcraft or singing with Artemis
- The amount of gold crowns you have now appears properly when getting player info. 

## [0.5.0] - 2026-01-18

### Added

- You can now change the mod's keyboard controls from [config.AccessModControls.KeyboardControls]. Check the readme to see how it works

- It is now possible to modify what information appears when actively getting target info, such as by pressing lt + cast, or ' on the keyboard. This can be done in config.AccessDisplay.LongInfoArray. Note that this array also applies to player information. 

### Changed

- - Actively getting target info using the  speak target info control now speaks distance by default. 

### Fixed

- Fixed a bug where the effect description announcements config entry was being ignored.

## [0.4.4] - 2026-01-12

### Fixed

- Fixed an issue with non ascii characters being substituted when converting camelcase to normal spaces     

## [0.4.3] - 2026-01-11

### Fixed

- Fixed a critical crash when cycling to an unconfigured beacon category.

### Changed

- Activating the mod layer (holding LT) no longer locks player movement.

## [0.4.2] - 2026-01-10

### Fixed

- Corrected audio file path in `data/` folder to ensure proper loading.

## [0.4.1] - 2026-01-10

### Fixed

- Ensured that important story objects correctly appear in tracking targets.

## [0.4.0] - 2026-01-04

### Added

- Improved smart tracking prioritization for harvestables when the player has access to the appropriate tools.
- Inspect points now receive higher priority in smart tracking.

### Fixed

- Multiple bugs related to scoring and display logic.
- Various inconsistencies in how targets are ranked and announced.

### Changed

- Further refined smart targeting behavior.

## [0.3.1] - 2026-01-03

### Fixed

- Multiple display issues related to target announcements.
- Traps with health are no longer incorrectly scored as enemies.
- Armor information is now correctly reported when selecting targets.
- Door reward info no longer displays incorrect rewards.
- Ship wheels now properly appear in the list of trackable targets.
- Enemy category switching is now handled internally on enemy death instead of forcing a category switch.

## [0.3.0] - 2025-12-30

### Added

- Ability to switch beacon categories and targets even when normal input would not be allowed.
- Teleportation to tracked objects while not in combat.
- Proper info display for garden plots.

### Changed

- Input handling relaxed to improve accessibility and usability in constrained states.

## [0.2.2] - 2025-12-29

### Added

- Completed NPC and hero animation translations into friendly, spoken strings.

## [0.2.1] - 2025-12-28

### Fixed

- Display strings that were not appearing as friendly text.
- Familiar resting points now correctly appear as targets.
- Missing tracked file added to version control.

## [0.2.0] - 2025-12-27

### Added

- Smart targeting system that sorts objects based on importance.
- Tracking automatically switches to the next target when an enemy is killed.
- Linked category support via `LinkedCategories` configuration.
- NPCs, items, boons, familiars, and equippable weapons are now trackable in appropriate categories.
- Keyboard controls for all major mod features.

### Changed

- Group initialization logic reworked to better support inherited and inactive objects.
- Main thread logic updated so beacon interval changes apply almost instantly.
- Category sorting and target info order made configurable.

### Fixed

- Codex info now correctly appears for all objects.
- Icons are now handled consistently.

## [0.1.2] - 2025-12-23

### Added

- Obstacle collision sounds and spoken announcements.
- Double-tap functionality for modifier controls to stop tracking.
- Beacon no longer plays while in menus or screens.
- Spoken announcements for target animations during combat and dialog.

### Changed

- ModControls system reworked for better reliability and responsiveness.

## [0.1.1] - 2025-12-18

### Added

- Detailed target info announcements including name, health, armor, distance, animation, and effects.
- Player self-info via Codex key while holding the modifier.
- Configurable category sorting and info ordering.

### Fixed

- Load issues by moving bank and thread initialization to `OnAnyLoad`.

### Changed

- Significant code refactoring in preparation for initial release.

## [0.1.0] - 2025-12-12

### Added

- Core audio tracking beacon system.
- Target closest controls and beacon toggle.
- Finalized controller mappings and spoken display text.
- Early animation announcements and friendly string translations.

## [0.0.1] - 2025-12-03

### Added

- Initial implementation of the accessibility tracking beacon.
- Basic target detection and distance-based sorting.

[unreleased]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/compare/0.6.0...HEAD
[0.6.0]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/compare/0.5.0...0.6.0
[0.5.0]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/compare/0.4.4...0.5.0
[0.4.4]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/compare/0.4.3...0.4.4
[0.4.3]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/compare/0.4.3...0.4.3
[0.4.3]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/compare/0.4.2...0.4.3
[0.4.2]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/compare/0.4.1...0.4.2
[0.4.1]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/compare/v0.4.1...0.4.1
[0.4.0]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/compare/v0.2.2...v0.3.0
[0.2.2]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/compare/v0.0.1...v0.1.0
[0.0.1]: https://github.com/flat-arther/FlatArther-HadesIIAccess-Public/releases/tag/v0.0.1
