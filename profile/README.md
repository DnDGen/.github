# DnDGen

[![Theme Song](https://img.shields.io/badge/theme_song-Suno-ff69b4)](https://suno.com/s/bv8TJG5bYGeL21dp)

Random generators for Dungeons & Dragons 3.X: dice, treasure, characters, creatures, encounters, and whole dungeons.
Each generator is a C# library you can use in your own code, and you can try them all at [dndgen.com](http://dndgen.com/).

Random generators are hard to test, because a bug might only show up on one roll in thousands.
So DnDGen tests heavily: over 100,000 tests, plus stress tests that run each generator over and over, looking for the roll that breaks it.

## The Generators

| Repository | What it generates |
|---|---|
| [RollGen](https://github.com/DnDGen/DnDGen.RollGen) | Dice rolls, using the d20 system |
| [TreasureGen](https://github.com/DnDGen/DnDGen.TreasureGen) | Equipment and magic items |
| [CharacterGen](https://github.com/DnDGen/DnDGen.CharacterGen) | Fully equipped NPCs |
| [CreatureGen](https://github.com/DnDGen/DnDGen.CreatureGen) | Fleshed-out creatures, with hit points, templates, and advancement |
| [EncounterGen](https://github.com/DnDGen/DnDGen.EncounterGen) | Encounters |
| [DungeonGen](https://github.com/DnDGen/DnDGen.DungeonGen) | Dungeons |

## Behind the Scenes

| Repository | What it does |
|---|---|
| [Infrastructure](https://github.com/DnDGen/DnDGen.Infrastructure) | Core objects shared by the generators, including the Percentile and Collection selectors |
| [Stress](https://github.com/DnDGen/DnDGen.Stress) | Stress-tests random generators by running them over and over |
| [Web](https://github.com/DnDGen/DnDGen.Web) | The APIs and website at [dndgen.com](http://dndgen.com/) |

## Soundtrack

| | Track | Leitmotif | |
|---|---|---|---|
| <a href="https://github.com/DnDGen/.github/blob/main/theme-song/README.md"><img src="https://github.com/DnDGen/.github/raw/main/theme-song/cover.png" alt="Rogante Marendor album art" width="80"></a> | **Rogante Marendor** -DnDGen Main Theme- | *Rogante Marendor* | [Listen](https://suno.com/s/bv8TJG5bYGeL21dp) · [Lyrics and notes](https://github.com/DnDGen/.github/blob/main/theme-song/README.md) |
| <a href="https://github.com/DnDGen/DnDGen.Stress/blob/main/docs/theme-song/README.md"><img src="https://github.com/DnDGen/DnDGen.Stress/raw/main/docs/theme-song/cover.png" alt="Over and Over album art" width="80"></a> | **Over and Over** -DnDGen.Stress Theme- | | [Listen](https://suno.com/s/TLKVK477Efrel4u8) · [Lyrics and notes](https://github.com/DnDGen/DnDGen.Stress/blob/main/docs/theme-song/README.md) |
| <a href="https://github.com/DnDGen/DnDGen.RollGen/blob/main/docs/theme-song/README.md"><img src="https://github.com/DnDGen/DnDGen.RollGen/raw/main/docs/theme-song/cover.png" alt="Grollen album art" width="80"></a> | **Grollen** -DnDGen.RollGen Theme- | *Grollen* | [Listen](https://suno.com/s/RvnVPcPR4ZTGIEt7) · [Lyrics and notes](https://github.com/DnDGen/DnDGen.RollGen/blob/main/docs/theme-song/README.md) |
