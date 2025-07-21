# CHANGELOG


## Untagged


### 20 Jul 2025

- ([`2bf5f6a`](https://github.com/russmatney/dothop/commit/2bf5f6a)) rel: bump to v1.1.1 - Russell Matney

  > Updates the changelog, which unfortunately drops the v1.1.0 tag b/c i
  > forgot to push the tag on my other machine :eyeroll:


## v1.1.1


### 20 Jul 2025

- ([`2d9138b`](https://github.com/russmatney/dothop/commit/2d9138b)) wip: toying with camera _ready puzzle-node lookup - Russell Matney

  > It'd be nice if the camera could grab the puzzle-node without needing
  > setup elsewhere


### 19 Jul 2025

- ([`de70124`](https://github.com/russmatney/dothop/commit/de70124)) feat: link to puzzle browser on main menu - Russell Matney
- ([`d0b8d3d`](https://github.com/russmatney/dothop/commit/d0b8d3d)) feat: support a fallback_world on the puzzle node - Russell Matney
- ([`e4a77c0`](https://github.com/russmatney/dothop/commit/e4a77c0)) refactor: pull theme_data from world directly - Russell Matney

  > Moving away from the theme pandora entity, which should shrink down.
  > 
  > Also adds an AllTheDots theme_data and a new world called Extra Extra,
  > which includes a few more puzzles, including a few 2 hoppers and the
  > extra difficult one from cameron

- ([`db6a485`](https://github.com/russmatney/dothop/commit/db6a485)) chore: drop demo flag - Russell Matney
- ([`068c415`](https://github.com/russmatney/dothop/commit/068c415)) chore: drop unused next_set/world field - Russell Matney
- ([`20558e7`](https://github.com/russmatney/dothop/commit/20558e7)) refactor: puzzle_set -> world, plus event renaming - Russell Matney

  > Maybe dropping save/existing events this way?

- ([`55e334c`](https://github.com/russmatney/dothop/commit/55e334c)) rename: PuzzleSet -> PuzzleWorld - Russell Matney
- ([`f0ed108`](https://github.com/russmatney/dothop/commit/f0ed108)) chore: misc log clean up and what not - Russell Matney

  > Things back to working, now with 'GameDef'!
  > 
  > Hurting for a bit more of a refactor - we're relying on PuzzleSet
  > entities for game state/save data, when we probably want something less
  > global, and more game mode aware.
  > 
  > Plus i really want a PuzzleStore that has reasonable apis to pull
  > from. (But in what game-mode context? Is PuzzleStore game-mode dependent
  > or agnostic?)

- ([`8fed2df`](https://github.com/russmatney/dothop/commit/8fed2df)) refactor: move rest of GameDef into DHData, PuzzleDef - Russell Matney

  > Moved away from the extra GridCell class completely.

- ([`d8ae104`](https://github.com/russmatney/dothop/commit/d8ae104)) refactor: move camera code out of dothop puzzle - Russell Matney

  > Lots of complexity in the name of running the dothoppuzzle scene
  > directly. reminds me of the one-room-in-full-dungeon-map problem in
  > metsys - could write a little run-in-context helper if we need.

- ([`334749d`](https://github.com/russmatney/dothop/commit/334749d)) wip: game (sort of) playable again! - Russell Matney

  > Fixes the .puzz importer and reassigns psds to pandora PuzzleSets.

- ([`4d6777d`](https://github.com/russmatney/dothop/commit/4d6777d)) refactor: move other puzzle txts to .puzz, drop puzzle-set-data tres - Russell Matney
- ([`701cc5e`](https://github.com/russmatney/dothop/commit/701cc5e)) wip: support psd.setup, add shuffle input mapping - Russell Matney

  > The .puzz -> puzzle-set-data only saves/loads the @exported fields.
  > setup() is a quick workaround that will reparse the puzzle_defs if
  > needed.
  > 
  > We're not yet restoring the game state properly.

- ([`83d0a45`](https://github.com/russmatney/dothop/commit/83d0a45)) chore: drop game_def instance support - Russell Matney

  > Just a bunch of static funcs left now.

- ([`9116714`](https://github.com/russmatney/dothop/commit/9116714)) wip: removing game_def from PuzzleSet pandora entity - Russell Matney

  > Trying to restore the game state - looks like puzzle_set_datas don't
  > automatically load their puzzle_defs just yet.


### 18 Jul 2025

- ([`2409776`](https://github.com/russmatney/dothop/commit/2409776)) wip: more puzzle vs game scene ironing - Russell Matney

  > Lifts some puzzle-node signals to the game scene, cleans up a bunch of
  > signal connects. I suspect much of these can be moved to per-node
  > _ready() funcs - probably connecting signals right before add_child is
  > an anti-pattern.

- ([`6074816`](https://github.com/russmatney/dothop/commit/6074816)) wip: DotHopPuzzle clean up, and a quick reshuffle button - Russell Matney

  > warning! Things still quite broken at the moment!

- ([`52233d7`](https://github.com/russmatney/dothop/commit/52233d7)) wip: more gameDef-drop clean up - Russell Matney

  > things still quite broken in places!

- ([`6ac0603`](https://github.com/russmatney/dothop/commit/6ac0603)) wip: mid-refactor dropping GameDef completely - Russell Matney

  > Lots of things touch this, so this is a messy one. everything is broken!

- ([`f8a84de`](https://github.com/russmatney/dothop/commit/f8a84de)) feat: initial .puzz importer - Russell Matney

  > Refactoring puzzle parsing into an editor import plugin.

- ([`9d2b793`](https://github.com/russmatney/dothop/commit/9d2b793)) fix: another type cast crash - Russell Matney

### 17 Jul 2025

- ([`be359d7`](https://github.com/russmatney/dothop/commit/be359d7)) chore: some clojure clj-kondo cruft - Russell Matney
- ([`31dfa39`](https://github.com/russmatney/dothop/commit/31dfa39)) feat: attach world/puzzle i to puzzle datas - Russell Matney
- ([`65fc79d`](https://github.com/russmatney/dothop/commit/65fc79d)) feat: puzzle json now including puzzle shape and sum fields - Russell Matney
- ([`eefb5a0`](https://github.com/russmatney/dothop/commit/eefb5a0)) feat: StatLogger writing json and md puzzle data files - Russell Matney

  > A nice util for creating more accessible puzzle and json data. I expect
  > to consume the json from babashka to print docs and devlog posts.

- ([`cb670f8`](https://github.com/russmatney/dothop/commit/cb670f8)) wip: initial stat-logger via UI button - Russell Matney

### 16 Jul 2025

- ([`65fb659`](https://github.com/russmatney/dothop/commit/65fb659)) wip: move extra snow way level to extra - Russell Matney

  > only doing this to improve CI times.
  > 
  > We should add EXTRA as a new world after you watch/find a secret in the credits.

- ([`595e4b6`](https://github.com/russmatney/dothop/commit/595e4b6)) feat: ignore 'stuck-goal' choices - Russell Matney

  > players wouldn't logically choose to exit early, so we shouldn't
  > consider it a 'choice' when working with difficulty

- ([`eef16a6`](https://github.com/russmatney/dothop/commit/eef16a6)) chore: adds a table-like printer to support copy-pasting puzzle data - Russell Matney
- ([`697c349`](https://github.com/russmatney/dothop/commit/697c349)) fix: re-enable solve-all-puzzles-tests - Russell Matney
- ([`89fed8d`](https://github.com/russmatney/dothop/commit/89fed8d)) feat: calcing choices and turn counts per path - Russell Matney
- ([`23b4faf`](https://github.com/russmatney/dothop/commit/23b4faf)) wip: puzzle analysis refactor - Russell Matney

  > Adding supporting for choice and turn counts in the analysis, plus
  > getting some more useful types in here.


### 15 Jul 2025

- ([`c508554`](https://github.com/russmatney/dothop/commit/c508554)) feat: scale tweens on possible-move dots - Russell Matney
- ([`fee2fa8`](https://github.com/russmatney/dothop/commit/fee2fa8)) wip: tracking and emitting possible next moves - Russell Matney

### 14 Jul 2025

- ([`ef209a2`](https://github.com/russmatney/dothop/commit/ef209a2)) refactor: cleaner check_moves logic - Russell Matney
- ([`df573d1`](https://github.com/russmatney/dothop/commit/df573d1)) fix: update hopped-dot tracking test - Russell Matney
- ([`513ac53`](https://github.com/russmatney/dothop/commit/513ac53)) wip: refactoring into a Move monoid - Russell Matney

  > instead of a list of moves, we create one Move per hopper.


### 20 Jun 2025

- ([`c2f9eac`](https://github.com/russmatney/dothop/commit/c2f9eac)) wip: toying with some altered multi-hopper logic - Russell Matney
- ([`a355bbb`](https://github.com/russmatney/dothop/commit/a355bbb)) fix: use installed gdunit - Russell Matney
- ([`52cabaa`](https://github.com/russmatney/dothop/commit/52cabaa)) fix: out of bounds puzzle index fix - Russell Matney
- ([`18b732e`](https://github.com/russmatney/dothop/commit/18b732e)) ci: update godot-ci version - Russell Matney
- ([`400f3e3`](https://github.com/russmatney/dothop/commit/400f3e3)) fix: update gdunit action version - Russell Matney
- ([`adcdf10`](https://github.com/russmatney/dothop/commit/adcdf10)) refactor: puzzle analysis supports state-only runs - Russell Matney

  > The puzzle analysis now accepts are :node or :state param - pass in
  > either a DotHopPuzzle or a PuzzleState, and it'll use move() from either
  > to brute-force the puzzles.

- ([`29da073`](https://github.com/russmatney/dothop/commit/29da073)) refactor: remove node refs from PuzzleState - Russell Matney

  > Instead of handling nodes and calling methods in PuzzleState, we emit
  > signals. It's on the consumer (DotHopPuzzle) to connect to these from
  > Player and Dot nodes.

- ([`6c29623`](https://github.com/russmatney/dothop/commit/6c29623)) test: better PuzzleState test coverage - Russell Matney

  > Adds a few more assertions to make sure things are behaving as expected
  > - some larger puzzles, undos, and checking on moves vs apply moves.
  > 
  > Setting up some strong test coverage before starting to gut/refactor the
  > messy state funcs.


### 19 Jun 2025

- ([`342ef0a`](https://github.com/russmatney/dothop/commit/342ef0a)) fix: don't call node funcs on null nodes - Russell Matney

  > Add some guards, reorders some logic to run the game state updates
  > without calling DotHopPlayer or DotHopDot node funcs. These should be
  > kicked to signals instead.

- ([`688e569`](https://github.com/russmatney/dothop/commit/688e569)) refactor: pull apply_moves and rest of logic into PuzzleState - Russell Matney

  > Tests crashing b/c of PuzzleState node deps, but the DotHopPuzzle node
  > is now free of PuzzleState logic. Very close to running the game logic
  > without needing any nodes.

- ([`3373cd2`](https://github.com/russmatney/dothop/commit/3373cd2)) refactor: pull check_move into PuzzleState, add PuzzleState unit tests - Russell Matney

  > Fixes a few bugs and adds unit tests for basic PuzzleState funcs to be
  > sure things are working as expected.
  > 
  > Restores working puzzles, tho there are definitely some quirks - e.g.
  > emitting win too early.
  > 
  > Moves from reading grid directly to 'rebuilding' rows on request -
  > likely only relevant for testing.


### 18 Jun 2025

- ([`abab86e`](https://github.com/russmatney/dothop/commit/abab86e)) wip: dropping 'grid' in favor of coord->cell dict - Russell Matney

  > Mildly breaks everything! Tests failing, game logic needs to be fixed.

- ([`a0bde29`](https://github.com/russmatney/dothop/commit/a0bde29)) wip: moving away from string 'objs' in cells - Russell Matney
- ([`f0c3c01`](https://github.com/russmatney/dothop/commit/f0c3c01)) chore: add remove_nulls to bones.util - Russell Matney

### 17 Jun 2025

- ([`8f692a8`](https://github.com/russmatney/dothop/commit/8f692a8)) refactor: create cells when building state the first time - Russell Matney

  > The state's grid gets updated in place, but the cells don't - kind of
  > wonky.

- ([`a65dd99`](https://github.com/russmatney/dothop/commit/a65dd99)) refactor: split move into check_moves and apply_moves - Russell Matney

  > I think this is the command pattern? Nice to separate the data and the
  > execution of it.

- ([`b0559e7`](https://github.com/russmatney/dothop/commit/b0559e7)) refactor: break PuzzState into PuzzleState class - Russell Matney
- ([`0922d19`](https://github.com/russmatney/dothop/commit/0922d19)) refactor: pull more logic into PuzzState, use types to avoid warnings - Russell Matney

  > Ideally the analysis would run without any nodes - right now we're
  > strapped on top of the DotHopPuzzle node, itself.

- ([`980cde8`](https://github.com/russmatney/dothop/commit/980cde8)) fix: misc fixups after DotHopPuzzle refactor - Russell Matney

### 3 Jun 2025

- ([`cbd630c`](https://github.com/russmatney/dothop/commit/cbd630c)) build: setup dupe android build for local-prod tests - Russell Matney

  > Rather than edit the android export, we dupe it and make perma-tweaks
  > there.

- ([`3e22379`](https://github.com/russmatney/dothop/commit/3e22379)) fix: restore pandora compressed-read-error work-around - Russell Matney

  > For whatever reason the android release of the game does not build the
  > expected pandora data file as expected - this restores a workaround that
  > i lost when pandora was last updated. I ought to get this into a pandora
  > issue soon!

- ([`b657839`](https://github.com/russmatney/dothop/commit/b657839)) fix: don't run tween infinitely - Russell Matney

  > A bit of wip code that survived - slide_from_point should NOt set_loops()
  > to run forever.


### 2 Jun 2025

- ([`912fea2`](https://github.com/russmatney/dothop/commit/912fea2)) fix: disable non-production feature (?) - Russell Matney
- ([`5c5fd79`](https://github.com/russmatney/dothop/commit/5c5fd79)) wip: toying with dot-intro animation - Russell Matney

  > With @Camsbury!


### 30 May 2025

- ([`6aa9c6f`](https://github.com/russmatney/dothop/commit/6aa9c6f)) refactor: pull more dotHopPuzzle impl into PuzzState class - Russell Matney

  > Also cleans up the implementation a bit by leaning into the DotHopDot
  > type.

- ([`4710665`](https://github.com/russmatney/dothop/commit/4710665)) refactor: move ensure_cam to camera static func - Russell Matney

  > I like this pattern of nodes being responsible for themselves.

- ([`b004d55`](https://github.com/russmatney/dothop/commit/b004d55)) refactor: more sweeping rearrangement - Russell Matney

  > Grouping more scripts: core, audio dirs introduced.

- ([`6cc9a25`](https://github.com/russmatney/dothop/commit/6cc9a25)) docs: add docs/.nojekyll - Russell Matney

  > otherwise github ignores _sidebar.md, etc.

- ([`f17e2ff`](https://github.com/russmatney/dothop/commit/f17e2ff)) refactor: rename puzzle dir to 'dothop', move more things into 'puzzles' - Russell Matney

  > Re-orging the src dir a bit - trying to parse the DotHopPuzzle and
  > GameScene apart a bit.

- ([`9bd8fac`](https://github.com/russmatney/dothop/commit/9bd8fac)) feat: add version label to main menu - Russell Matney

  > Also bumps to v1.1.0! Targeting v2.0.0 for the next major release.

- ([`6aa7b73`](https://github.com/russmatney/dothop/commit/6aa7b73)) docs: more passable docs site - Russell Matney
- ([`f73e894`](https://github.com/russmatney/dothop/commit/f73e894)) docs: create changelog, add new version tag - Russell Matney

## v1.1.0


### 29 May 2025

- ([`470d12e`](https://github.com/russmatney/dothop/commit/470d12e)) chore: increment android release number - Russell Matney
- ([`937e42c`](https://github.com/russmatney/dothop/commit/937e42c)) feat: add floaty particles to rest of themes - Russell Matney

  > Not great, but it's something.

- ([`acda5fd`](https://github.com/russmatney/dothop/commit/acda5fd)) refactor: drop game_def_path usage - Russell Matney

  > Moving away from specifying these games - it seems only to be used for
  > the legend, which is pretty unnecessary at this point - really we just
  > need the puzzle shapes parsed.

- ([`441f351`](https://github.com/russmatney/dothop/commit/441f351)) refactor: rename dothop-n.txt files - Russell Matney
- ([`72fba57`](https://github.com/russmatney/dothop/commit/72fba57)) refactor: rename PuzzleScene -> DotHopPuzzle, wrap puzzle-set-paths - Russell Matney

  > Introduces a new custom resource, PuzzleSetData. this is a wrapper for
  > the (poorly named) dothop-one/two/three/etc.txt files. We now reference
  > these resources directly and use them to parse a GameDef.

- ([`10c3b34`](https://github.com/russmatney/dothop/commit/10c3b34)) wip: keeping pandora puzzle themes, simplifying puzzle-theme-data - Russell Matney

  > I was intending to drop some pandora bits, but after more thought and
  > some circular dependency issues, i've decided to just simplify it
  > instead. Pandora has nice visualization/UI features, and is a better
  > option to attach to nodes - e.g. the puzzlescene can reference a
  > PuzzleTheme, but not puzzle theme data

- ([`666dc05`](https://github.com/russmatney/dothop/commit/666dc05)) feat: floaty spring particles - Russell Matney
- ([`02812de`](https://github.com/russmatney/dothop/commit/02812de)) feat: some dot movement animations - Russell Matney

  > Adding some life to the otherwise static puzzles.


### 28 May 2025

- ([`529409b`](https://github.com/russmatney/dothop/commit/529409b)) chore: update CI godot version - Russell Matney

  > Also moves to invoking runtest via `sh` instead of chmodding the file.

- ([`11c8974`](https://github.com/russmatney/dothop/commit/11c8974)) fix: restore main menu logo - Russell Matney
- ([`814d275`](https://github.com/russmatney/dothop/commit/814d275)) deps: update bones and gd-plug - Russell Matney
- ([`9a11d6a`](https://github.com/russmatney/dothop/commit/9a11d6a)) deps: update gdfxr - Russell Matney
- ([`89a8bbe`](https://github.com/russmatney/dothop/commit/89a8bbe)) deps: update input_helper - Russell Matney
- ([`067bc7b`](https://github.com/russmatney/dothop/commit/067bc7b)) deps: update pandora - Russell Matney
- ([`a7703b5`](https://github.com/russmatney/dothop/commit/a7703b5)) deps: update AsepriteWizard - Russell Matney
- ([`0e4fd5a`](https://github.com/russmatney/dothop/commit/0e4fd5a)) deps: update log.gd - Russell Matney
- ([`f70fc4c`](https://github.com/russmatney/dothop/commit/f70fc4c)) deps: update gdunit - Russell Matney

  > GdUnit doesn't include .uid files in git, so those all get updated :eyeroll:


### 27 May 2025

- ([`7a413d6`](https://github.com/russmatney/dothop/commit/7a413d6)) chore: android app icon and feature graphic - Russell Matney

### 26 May 2025

- ([`d4e7463`](https://github.com/russmatney/dothop/commit/d4e7463)) chore: drop a bunch of .gdignored imports - Russell Matney
- ([`e3cb8f2`](https://github.com/russmatney/dothop/commit/e3cb8f2)) wip: puzzleScene themeData fallback - Russell Matney

### 23 May 2025

- ([`3ce6538`](https://github.com/russmatney/dothop/commit/3ce6538)) chore: misc export details - Russell Matney
- ([`47dd858`](https://github.com/russmatney/dothop/commit/47dd858)) feat: add app icon gen to boxart generation - Russell Matney
- ([`fadd501`](https://github.com/russmatney/dothop/commit/fadd501)) fix: restore click to move, clean up logs - Russell Matney

  > I declare drag-to-move fit to ship!

- ([`12ae34f`](https://github.com/russmatney/dothop/commit/12ae34f)) feat: initial drag-to-select-dot implementation - Russell Matney
- ([`9352f2a`](https://github.com/russmatney/dothop/commit/9352f2a)) wip: half-impl, towards drag-to-queue-dots - Russell Matney
- ([`bc6fc43`](https://github.com/russmatney/dothop/commit/bc6fc43)) fix: correct types that broke the player animation - Russell Matney

  > Also defers some audio setup so competing Music/Sounds autoloads wait
  > for bus setup before adjusting volume. (removing another warning).
  > 
  > Simplifies the puzzleScene `attempt_move` call.


### 22 May 2025

- ([`8142943`](https://github.com/russmatney/dothop/commit/8142943)) fix: move puzzle set unlocked to layer 5 - Russell Matney

  > The puzzle-set-unlocked jumbotron 'dismiss' button wasn't clickable b/c
  > the game's HUD layer was on top of it - bumping it to layer 5 ensures
  > the mobile-advance workaround.

- ([`83e8b64`](https://github.com/russmatney/dothop/commit/83e8b64)) chore: misc .tscn and .tres cruft - Russell Matney
- ([`ebbdd51`](https://github.com/russmatney/dothop/commit/ebbdd51)) fix: pandora fallback to read uncompressed data - Russell Matney

  > For some reason my pandora data does not seem to be compressing - adding
  > this fallback allows the data to be read on startup, which results in a
  > working android release build. woo!

- ([`5cd148f`](https://github.com/russmatney/dothop/commit/5cd148f)) fix: crash handling for missing pandora data - Russell Matney

  > Some handling for unexpected nulls that cause full game crashes.


### 16 May 2025

- ([`b9af41a`](https://github.com/russmatney/dothop/commit/b9af41a)) refactor: simplify parsing and types - Russell Matney

  > Moves away from dictionaries for the parsed result, at least at the top
  > level.
  > 
  > Drops parsing for a handful of unused sections (leftover from the puzzle
  > script parser impl, 'puzz'). Drops `Puzz` completely, moves it's public
  > func to static func on GameDef.

- ([`553fd7e`](https://github.com/russmatney/dothop/commit/553fd7e)) refactor: pull gnarly 'move' array into a class - Russell Matney

  > This was a crazy impl before - this leaves it more or less as-is but
  > moves away from implicit arrays of types, callables, and args and into a
  > more structured command pattern.

- ([`8961310`](https://github.com/russmatney/dothop/commit/8961310)) fix: play 'stuck' animation in direction when would-hit dotted - Russell Matney
- ([`3145503`](https://github.com/russmatney/dothop/commit/3145503)) fix: make sure we're fetching goal scenes - Russell Matney

  > Also drops a bunch of no-longer necessary warnings. Still a bunch that
  > are needed - maybe we'll get to more specific node types next.
  > 
  > Seems to be a bug when trying to move toward 'dotted' dots - it should
  > animate but it doesn't seem to.

- ([`8e2519e`](https://github.com/russmatney/dothop/commit/8e2519e)) fix: correct some type casts, update array null check - Russell Matney

  > Tests restored again after move away from untyped dictionary state obj.

- ([`c6f7a50`](https://github.com/russmatney/dothop/commit/c6f7a50)) wip: refactor puzzleScene algo from dicts to classes - Russell Matney

  > Things are quite broken! But the eventual result should be better for
  > long-term maintenance.

- ([`72d143a`](https://github.com/russmatney/dothop/commit/72d143a)) refactor: move to PuzzleThemeData static funcs to support fallbacks - Russell Matney

  > Restores broken tests - important before the dict refactor we're about
  > to launch into.


### 15 May 2025

- ([`04c9733`](https://github.com/russmatney/dothop/commit/04c9733)) wip: release build crashing on android! - Russell Matney

  > trying to dig into why.... only clue so far:
  > 
  > WARNING: Unable to initialize entity with id=17 from scene: got removed!
  >     at: push_warning (core/variant/variant_utility.cpp:1118)

- ([`b8fa084`](https://github.com/russmatney/dothop/commit/b8fa084)) feat: add Menu button to gameScene, restore return-to-main - Russell Matney

  > Registers the MainMenu with navi, adds a pause/menu button to the
  > GameScene.
  > 
  > DRYs up the calls to pause + show the menu via the DotHop autoload.
  > 
  > Again, doesn't look great, but we're driving toward fully functional on
  > mobile!

- ([`cb8c52c`](https://github.com/russmatney/dothop/commit/cb8c52c)) fix: restore pause menu - Russell Matney

  > Menus are now registered with Navi (so we're not hard-coding menus
  > within Bones/Navi). This registers the pause menu in the DotHop
  > autoload.

- ([`78baa11`](https://github.com/russmatney/dothop/commit/78baa11)) fix: avoid already connected error - Russell Matney
- ([`d1a11ca`](https://github.com/russmatney/dothop/commit/d1a11ca)) rough: add tappable button to jumbotron - Russell Matney

  > Doesn't look great, but prevents soft-locks on mobile, so we're shipping it.


### 14 May 2025

- ([`b3af4fa`](https://github.com/russmatney/dothop/commit/b3af4fa)) fix: dedupe uids - Russell Matney

  > Godot 4.4 uses uids now, which is a problem if you copy-pasted a bunch
  > of scenes in godot 4.2 and 4.3, creating a bunch of duplicate UIDs.
  > 
  > related: https://github.com/godotengine/godot/issues/102490
  > 
  > This recreates a bunch of scenes to get fresh uids, fixing bizarre
  > snowmen-in-springtime bugs.

- ([`b2c4efa`](https://github.com/russmatney/dothop/commit/b2c4efa)) fix: type 'safety' fix - Russell Matney

  > Yet again, a happy compiler does not imply a happy program.

- ([`25a4fc0`](https://github.com/russmatney/dothop/commit/25a4fc0)) refactor: pull dots from ThemeData, not Theme - Russell Matney

  > Moving from pandora to plain-old custom resources.


### 13 May 2025

- ([`17a5492`](https://github.com/russmatney/dothop/commit/17a5492)) chore: update to godot 4.4 - Russell Matney

  > All the .uids, some export tweaks (tried to export for android on osx)


### 15 Feb 2025

- ([`3930b26`](https://github.com/russmatney/dothop/commit/3930b26)) fix: static type fixes - tests passing again! - Russell Matney

### 1 Feb 2025

- ([`84309b3`](https://github.com/russmatney/dothop/commit/84309b3)) feat: no more type warnings! - Russell Matney

  > Still plenty of bugs tho

- ([`a28b47c`](https://github.com/russmatney/dothop/commit/a28b47c)) wip: nearly all the rest of the types - Russell Matney

  > Saving this Puzz parser for last - then we move on to ironing out these dictionaries.


### 31 Jan 2025

- ([`2cfc80d`](https://github.com/russmatney/dothop/commit/2cfc80d)) wip: more static types for ya! - Russell Matney

### 29 Jan 2025

- ([`f16de04`](https://github.com/russmatney/dothop/commit/f16de04)) wip: drop actionInputIcon in favor of bones's icon comp - Russell Matney
- ([`3582209`](https://github.com/russmatney/dothop/commit/3582209)) wip: more types, and towards dropping actionInputIcon - Russell Matney
- ([`a7cbcd6`](https://github.com/russmatney/dothop/commit/a7cbcd6)) wip: add luuuts of types - Russell Matney

  > kind of a pita

- ([`e4f18f6`](https://github.com/russmatney/dothop/commit/e4f18f6)) fix: prevent HUD buttons from focusing from directional inputs - Russell Matney

  > The undo/reset buttons were eating up/down inputs, causing a weird
  > hiccup when making some moves.

- ([`af64313`](https://github.com/russmatney/dothop/commit/af64313)) wip: add new puzzle from cameron - Russell Matney

  > warning: very hard!

- ([`e6e12b7`](https://github.com/russmatney/dothop/commit/e6e12b7)) deps: update input helper - Russell Matney
- ([`0a77115`](https://github.com/russmatney/dothop/commit/0a77115)) deps: update log.gd - Russell Matney
- ([`39f80ae`](https://github.com/russmatney/dothop/commit/39f80ae)) chore: update gdunit - Russell Matney

### 28 Jan 2025

- ([`b12b9ff`](https://github.com/russmatney/dothop/commit/b12b9ff)) fix: bunch of runtime bugs caused by our type 'safety' - Russell Matney

  > :smh:

- ([`b0e3fbc`](https://github.com/russmatney/dothop/commit/b0e3fbc)) wip: enforce most types in PuzzleScene.gd - Russell Matney

  > Need to refactor away from some dictionaries here, but otherwise this is
  > now cleaner and has type checking.

- ([`56d34fb`](https://github.com/russmatney/dothop/commit/56d34fb)) wip: replace PuzzleTheme with PuzzleThemeData - Russell Matney

  > Also enforcing static types everywhere.


### 20 Jan 2025

- ([`d922e53`](https://github.com/russmatney/dothop/commit/d922e53)) fix: update kenney-input-prompts refs - Russell Matney
- ([`5a2f284`](https://github.com/russmatney/dothop/commit/5a2f284)) chore: drop duped kenney-input-prompts - Russell Matney

  > Derp, don't need 2 of all these.

- ([`3494e18`](https://github.com/russmatney/dothop/commit/3494e18)) deps: bones updates - Russell Matney
- ([`4c31276`](https://github.com/russmatney/dothop/commit/4c31276)) deps: update input_helper, sound_manager - Russell Matney
- ([`3f32fbc`](https://github.com/russmatney/dothop/commit/3f32fbc)) deps: update gdunit - Russell Matney

### 2 Dec 2024

- ([`7d96b90`](https://github.com/russmatney/dothop/commit/7d96b90)) fix: skip when player.coord is null - Russell Matney

  > here's a gotcha! was dropping player input when coord was vector2.zero

- ([`ddd0734`](https://github.com/russmatney/dothop/commit/ddd0734)) feat: building and running on a local android device! - Russell Matney
- ([`74c647e`](https://github.com/russmatney/dothop/commit/74c647e)) chore: empty android export config - Russell Matney
- ([`c58a34d`](https://github.com/russmatney/dothop/commit/c58a34d)) feat: tap or click to move to dot/goal - Russell Matney

  > Hopefully this is reused everywhere - may lead to problems in the
  > two-player puzzles, but, we don't have any right now.

- ([`be75147`](https://github.com/russmatney/dothop/commit/be75147)) chore: bunch of theme tres/scene cruft - Russell Matney
- ([`2c7feef`](https://github.com/russmatney/dothop/commit/2c7feef)) feat: firing signal on dot click/tap - Russell Matney
- ([`c7d7b26`](https://github.com/russmatney/dothop/commit/c7d7b26)) feat: clickable undo/reset buttons - Russell Matney

  > Very rough and dupe-y for now, but they work.
  > 
  > Ought to clean up the gameScene vs puzzleScene vs Hud logic a bit.

- ([`ba1589d`](https://github.com/russmatney/dothop/commit/ba1589d)) fix: split out linux-godotsteam export - Russell Matney

  > Will need to get a 4.3 godotsteam binary locally as well

- ([`76f450c`](https://github.com/russmatney/dothop/commit/76f450c)) fix: move puzzleTheme data to a resource - Russell Matney

  > Pandora kept converting these arrays to type 'color'.... I should notify
  > about a bug, but i also shouldn't be using pandora for this anyway. This
  > starts to move off of pandora for themes by moving some of the data to
  > proper godot resources.

- ([`79e125c`](https://github.com/russmatney/dothop/commit/79e125c)) fix: update export name - Russell Matney
- ([`2186bb9`](https://github.com/russmatney/dothop/commit/2186bb9)) ci: update itch/steam deploy workflows - Russell Matney
- ([`e786287`](https://github.com/russmatney/dothop/commit/e786287)) fix: restore save/load, BREAKS save games! - Russell Matney

  > Unfortunately pandora introduced a breaking change, so the serialized
  > save-game events can't be deserialized. I don't care too much, y'all can
  > play through again if you want to.
  > 
  > Still not handling deserialization crashes, but this is at least a bit
  > safer.

- ([`f4ffbe5`](https://github.com/russmatney/dothop/commit/f4ffbe5)) fix: Trolls reference ui_undo - Russell Matney
- ([`e03a37b`](https://github.com/russmatney/dothop/commit/e03a37b)) fix: update U.call_in, restore U.button_disabled helpers - Russell Matney
- ([`02d79cd`](https://github.com/russmatney/dothop/commit/02d79cd)) fix: more dead addons/core references - Russell Matney
- ([`a38b7ff`](https://github.com/russmatney/dothop/commit/a38b7ff)) chore: drop addons/core, update misc refs/autoloads - Russell Matney
- ([`9ecd562`](https://github.com/russmatney/dothop/commit/9ecd562)) feat: add opts filter to bones/Util - Russell Matney

  > There was more to the core vs bones Util.gd diff - we'll see what else
  > we run into.

- ([`5879f27`](https://github.com/russmatney/dothop/commit/5879f27)) chore: drop core/assets - Russell Matney
- ([`6e59268`](https://github.com/russmatney/dothop/commit/6e59268)) chore: move credits, notifs, ui/comps into src - Russell Matney
- ([`b678d22`](https://github.com/russmatney/dothop/commit/b678d22)) chore: move core/assets/fonts refs to bones/fonts - Russell Matney
- ([`0fc423c`](https://github.com/russmatney/dothop/commit/0fc423c)) chore: drop addons/dj in favor of bones/dj - Russell Matney

  > Moves the MuteButtonList into src/menus

- ([`fb24ceb`](https://github.com/russmatney/dothop/commit/fb24ceb)) chore: port Trolls tweaks to bones/Trolls - Russell Matney
- ([`813c413`](https://github.com/russmatney/dothop/commit/813c413)) chore: fix input_helper, enable bones, update pandora data - Russell Matney
- ([`d730239`](https://github.com/russmatney/dothop/commit/d730239)) chore: not sure how this got duped - Russell Matney
- ([`ff62aad`](https://github.com/russmatney/dothop/commit/ff62aad)) deps: include kenney input prompts via bones - Russell Matney
- ([`a31a21f`](https://github.com/russmatney/dothop/commit/a31a21f)) deps: add bones - Russell Matney
- ([`013ffac`](https://github.com/russmatney/dothop/commit/013ffac)) deps: update log.gd - Russell Matney
- ([`c43db4b`](https://github.com/russmatney/dothop/commit/c43db4b)) deps: update gdunit - Russell Matney
- ([`4085391`](https://github.com/russmatney/dothop/commit/4085391)) deps: update input_helper - Russell Matney
- ([`3b2f4c4`](https://github.com/russmatney/dothop/commit/3b2f4c4)) deps: update pandora - Russell Matney
- ([`b354ecd`](https://github.com/russmatney/dothop/commit/b354ecd)) deps: update AsepriteWizard - Russell Matney

### 23 Oct 2024

- ([`7a429f3`](https://github.com/russmatney/dothop/commit/7a429f3)) fix: better unit test - Russell Matney

  > no need to expect all themes to be unlocked, at least one is fine


### 19 Oct 2024

- ([`55405d3`](https://github.com/russmatney/dothop/commit/55405d3)) wip: basic 'pumpkins' dot/dotted and wip theme - Russell Matney

  > Adds a quick Pumpkins theme with a pumpkin dot and dotted state.


### 31 Aug 2024

- ([`a10afc4`](https://github.com/russmatney/dothop/commit/a10afc4)) fix: readme badge urls - Russell Matney

  > Some how these were underscored instead of hyphenated?


### 30 Aug 2024

- ([`7819249`](https://github.com/russmatney/dothop/commit/7819249)) fix: use newer gdunit ci setup - Russell Matney
- ([`341c1f9`](https://github.com/russmatney/dothop/commit/341c1f9)) fix: attempt to use `which godot` - Russell Matney
- ([`853e6c7`](https://github.com/russmatney/dothop/commit/853e6c7)) fix: gdunit tests running again! - Russell Matney
- ([`29d58a4`](https://github.com/russmatney/dothop/commit/29d58a4)) deps: update gdfxr - Russell Matney
- ([`468d261`](https://github.com/russmatney/dothop/commit/468d261)) chore: upgrade to godot 4.3 - Russell Matney
- ([`fb2ee56`](https://github.com/russmatney/dothop/commit/fb2ee56)) chore: update pandora data format - Russell Matney
- ([`a9b77d6`](https://github.com/russmatney/dothop/commit/a9b77d6)) fix: remove .gdignore from pandora dir - Russell Matney

  > Apparently gdscript ignores .gdignores now!

- ([`b079197`](https://github.com/russmatney/dothop/commit/b079197)) deps: update gdunit - Russell Matney
- ([`3d693a0`](https://github.com/russmatney/dothop/commit/3d693a0)) deps: update input helper - Russell Matney
- ([`94ae1fd`](https://github.com/russmatney/dothop/commit/94ae1fd)) deps: update log.gd - Russell Matney
- ([`392ce6a`](https://github.com/russmatney/dothop/commit/392ce6a)) deps: update aespriteWizard - Russell Matney
- ([`5779e8b`](https://github.com/russmatney/dothop/commit/5779e8b)) deps: update pandora - Russell Matney

### 20 Jun 2024

- ([`1a42e1b`](https://github.com/russmatney/dothop/commit/1a42e1b)) fix: readme discord link - Russell Matney

### 17 Jun 2024

- ([`bf747fd`](https://github.com/russmatney/dothop/commit/bf747fd)) fix: don't prefer horizontal movement if abs(y > x) - Russell Matney
- ([`755bfa4`](https://github.com/russmatney/dothop/commit/755bfa4)) feat: support input gestures in Trolls - Russell Matney

  > Not too bad! just need to pass the event in a few places. Sometimes 2
  > moves fire quickly (e.g. down is interpreted as left then down) - i
  > think this can happen with the joystick as well - maybe a stronger delay
  > while moving would solve it?

- ([`b2cf65c`](https://github.com/russmatney/dothop/commit/b2cf65c)) chore: .gdignore in dirs, folder colors, touch inputs - Russell Matney
- ([`2b22308`](https://github.com/russmatney/dothop/commit/2b22308)) refactor: ignore rather than symlink to game-assets - Russell Matney

  > I'd been keeping these songs out of the repo via symlink, but that
  > doesn't fly with the ios builds. instead, just ignoring the symlinked
  > dir after copying it in.


### 16 Jun 2024

- ([`3618a1d`](https://github.com/russmatney/dothop/commit/3618a1d)) ios: basic export settings - Russell Matney

### 13 Jun 2024

- ([`c96f9c6`](https://github.com/russmatney/dothop/commit/c96f9c6)) deps: update gdfxr - Russell Matney

### 9 Jun 2024

- ([`cd10ce9`](https://github.com/russmatney/dothop/commit/cd10ce9)) chore: misc project churn - Russell Matney
- ([`df5d214`](https://github.com/russmatney/dothop/commit/df5d214)) deps: update gd-plug, drop gd-plug-ui - Russell Matney
- ([`fe60d84`](https://github.com/russmatney/dothop/commit/fe60d84)) deps: update sound manager and input helper - Russell Matney
- ([`3f605a9`](https://github.com/russmatney/dothop/commit/3f605a9)) deps: update log.gd - Russell Matney
- ([`61bd74a`](https://github.com/russmatney/dothop/commit/61bd74a)) deps: update aseprite wizard - Russell Matney
- ([`bcda3e9`](https://github.com/russmatney/dothop/commit/bcda3e9)) deps: update gdunit - Russell Matney

### 4 Jun 2024

- ([`4f65c5b`](https://github.com/russmatney/dothop/commit/4f65c5b)) chore: update funding links - Russell Matney

### 6 May 2024

- ([`7a6f623`](https://github.com/russmatney/dothop/commit/7a6f623)) license: source code now MIT Licensed - Russell Matney

### 25 Mar 2024

- ([`b8a33f4`](https://github.com/russmatney/dothop/commit/b8a33f4)) docs: init docsify site - Russell Matney

### 21 Mar 2024

- ([`7ea7498`](https://github.com/russmatney/dothop/commit/7ea7498)) revert: gdunit4 ci aborting, use old ci setup for now - Russell Matney

  > The action aborted via 134 and no tests ran, but it still reported that
  > it had succeeded. yeesh!

- ([`cc6330a`](https://github.com/russmatney/dothop/commit/cc6330a)) refactor: move to latest gdunit4 ci github action - Russell Matney
- ([`e475ed4`](https://github.com/russmatney/dothop/commit/e475ed4)) fix: make test script executable - Russell Matney
- ([`dee90fa`](https://github.com/russmatney/dothop/commit/dee90fa)) chore: drop core/log.gd, install log.gd via gd-plug - Russell Matney
- ([`9550c51`](https://github.com/russmatney/dothop/commit/9550c51)) chore: update pandora via gd-plug - Russell Matney

  > Everything expect the broken production data encryption.

- ([`244f54c`](https://github.com/russmatney/dothop/commit/244f54c)) chore: update sound_manager and input_helper via gd-plug - Russell Matney
- ([`f2fc656`](https://github.com/russmatney/dothop/commit/f2fc656)) chore: update Aseprite wizard via gd-plug - Russell Matney
- ([`7578cf7`](https://github.com/russmatney/dothop/commit/7578cf7)) chore: update gdunit4, install gd-plug-ui - Russell Matney
- ([`e54cadd`](https://github.com/russmatney/dothop/commit/e54cadd)) chore: basic gd-plug setup - Russell Matney

### 1 Mar 2024

- ([`385502a`](https://github.com/russmatney/dothop/commit/385502a)) chore: couple more boxarty image assets - Russell Matney

  > Steam announcements also require some image assets!


## v1.0.0


### 29 Feb 2024

- ([`853a217`](https://github.com/russmatney/dothop/commit/853a217)) chore: final achivement icons - Russell Matney
- ([`9a4cfa4`](https://github.com/russmatney/dothop/commit/9a4cfa4)) fix: use first_puzzle_icon for fallback cursor position - Russell Matney

  > This was deleted during yesterday's refactor, but now i get why it was
  > here! I ought to write tests for this scene, it's pretty hairy.

- ([`73fd190`](https://github.com/russmatney/dothop/commit/73fd190)) fix: hide puzzle cursor aggressively - Russell Matney

  > Hopefully this doesn't break anything - the puzzle cursor happily floats
  > to 0, 0 in some cases. this at least doesn't show it when that happens,
  > and seems to be fine.

- ([`f5b934e`](https://github.com/russmatney/dothop/commit/f5b934e)) chore: couple more playtester credits! - Russell Matney
- ([`ef5ee90`](https://github.com/russmatney/dothop/commit/ef5ee90)) chore: better last-puzzle hud message - Russell Matney
- ([`e56c480`](https://github.com/russmatney/dothop/commit/e56c480)) chore: couple more unlocked-world subheads - Russell Matney
- ([`8fa8692`](https://github.com/russmatney/dothop/commit/8fa8692)) chore: rearrange some deck chairs - Russell Matney

  > this puzzle progress panel is killing me

- ([`3ed7c73`](https://github.com/russmatney/dothop/commit/3ed7c73)) feat: achivements for 900/1000 dots - Russell Matney
- ([`8172f2e`](https://github.com/russmatney/dothop/commit/8172f2e)) chore: tweaking progress panel size - Russell Matney

  > This thing has a mind of its own

- ([`ec3cbc5`](https://github.com/russmatney/dothop/commit/ec3cbc5)) feat: bump required puzzle counts - Russell Matney

  > More puzzles, need more to unlock things!

- ([`8bca5fd`](https://github.com/russmatney/dothop/commit/8bca5fd)) feat: drop some easy space ones, add some harder ones - Russell Matney

  > Still don't feel like these space levels are hard enough - will have to
  > add some kind of harder world afterwords soon.

- ([`e4ec5f3`](https://github.com/russmatney/dothop/commit/e4ec5f3)) feat: two more medium snow levels - Russell Matney
- ([`3b0202c`](https://github.com/russmatney/dothop/commit/3b0202c)) feat: two more hard fall puzzles - Russell Matney
- ([`41ead4d`](https://github.com/russmatney/dothop/commit/41ead4d)) feat: add two hard puzzles to the beach - Russell Matney

  > And clean up/add variety to some existing ones.

- ([`e880650`](https://github.com/russmatney/dothop/commit/e880650)) feat: two more spring puzzles - Russell Matney

  > Plus drop some gaps in the later larger ones

- ([`13ce20c`](https://github.com/russmatney/dothop/commit/13ce20c)) feat: add three more puzzles to world one - Russell Matney
- ([`fd77328`](https://github.com/russmatney/dothop/commit/fd77328)) feat: add achivements for 100 * n to 800 - Russell Matney

  > includes icons and code.

- ([`9319bf2`](https://github.com/russmatney/dothop/commit/9319bf2)) chore: don't rotate unless width <= 6 - Russell Matney

  > Probably too low, but the very tall + thin layouts are bugging me, so
  > this is an aesthetic fix until i can find more fixes that look
  > better (improved camera zoom, maybe?)

- ([`6a3a2bd`](https://github.com/russmatney/dothop/commit/6a3a2bd)) feat: fade 'normal' state of buttons more - Russell Matney

  > The focused vs unfocused button states are now more distinct.

- ([`802404b`](https://github.com/russmatney/dothop/commit/802404b)) feat: more testers! - Russell Matney
- ([`8a7ade4`](https://github.com/russmatney/dothop/commit/8a7ade4)) credits: add godotsteam, special thanks - Russell Matney
- ([`ad38fad`](https://github.com/russmatney/dothop/commit/ad38fad)) fix: restore tests after complete/unlock refactor - Russell Matney
- ([`34d8814`](https://github.com/russmatney/dothop/commit/34d8814)) feat: space theme ufo player sprite - Russell Matney

### 28 Feb 2024

- ([`6958f03`](https://github.com/russmatney/dothop/commit/6958f03)) chore: some credit fixes - Russell Matney
- ([`b2cfab4`](https://github.com/russmatney/dothop/commit/b2cfab4)) wip: an unused float-a-bit animation - Russell Matney
- ([`b3e406b`](https://github.com/russmatney/dothop/commit/b3e406b)) feat: puzzle rotation - Russell Matney

  > This is cool, but alot of the 'wide' puzzles present pretty small when
  > they are rotated. Maybe could have some width/height cut-off or some
  > other solution to the aesthetic cost.

- ([`7876f2d`](https://github.com/russmatney/dothop/commit/7876f2d)) feat: show 'replay' vs 'start' if the puzzle has been completed - Russell Matney
- ([`cb840ad`](https://github.com/russmatney/dothop/commit/cb840ad)) feat: support replaying puzzle sets - Russell Matney
- ([`b5d0c53`](https://github.com/russmatney/dothop/commit/b5d0c53)) feat: next-puzzle is now the next-incomplete-puzzle - Russell Matney

  > Simplifies the on-win logic a bit - when a puzzle set is complete, we
  > nav to the world map, and when a puzzle is complete, we move to the next
  > incomplete puzzle.
  > 
  > The hud now shows how many puzzles are left to finish.

- ([`15d5365`](https://github.com/russmatney/dothop/commit/15d5365)) feat: add puzzle complete/total to worldmap puzzle label - Russell Matney
- ([`50b6555`](https://github.com/russmatney/dothop/commit/50b6555)) feat: unlock up to 3 levels per puzzle set at a time - Russell Matney

  > Bit of logic, but i think it's fine. who needs unit tests?

- ([`32f7bbb`](https://github.com/russmatney/dothop/commit/32f7bbb)) fix: go to credits when last puzzle complete - Russell Matney

  > regardless of if this puzzle completes the set or not

- ([`f478696`](https://github.com/russmatney/dothop/commit/f478696)) feat: display n-puzzles-to-unlock on locked puzzle sets - Russell Matney

  > Also dries up the calc_stats in DHData, and adds a quick
  > fade_in/fade_out to Anim.

- ([`c2f6b3a`](https://github.com/russmatney/dothop/commit/c2f6b3a)) fix: only call_in if node is still valid - Russell Matney
- ([`613766c`](https://github.com/russmatney/dothop/commit/613766c)) feat: rework puzzle-win logic - Russell Matney

  > performs calcs to properly mark puzzle-sets complete (important now that
  > puzzles can be skipped). Updates completion of the final puzzle with a
  > more specific note, and drops the intermediate puzzle-complete
  > events (puzzles are broken up by puzzle-unlock events now).
  > 
  > Perhaps we want to jump to the next incomplete level, or provide a menu
  > for selecting the next puzzle if the next one is already complete?

- ([`584bbec`](https://github.com/russmatney/dothop/commit/584bbec)) feat: options button for clearing all steam achievements - Russell Matney
- ([`fe04012`](https://github.com/russmatney/dothop/commit/fe04012)) feat: unlock puzzles based on puzzles completed - Russell Matney

  > Rather than a linear one-world-at-a-time approach, this allows for
  > unlocking the next world after fewer in the previous one.
  > 
  > Rearranges the on-win logic in the game_scene, pulling some stat calcs
  > out of the store functions. Maybe the achievements belong in the store?
  > but it doesn't seem like the ui-flow/jumbotrons do.

- ([`75731bd`](https://github.com/russmatney/dothop/commit/75731bd)) wip: add puzzle_to_unlock with first-pass at values - Russell Matney
- ([`5319526`](https://github.com/russmatney/dothop/commit/5319526)) refactor: give puzzleSetIDs better names - Russell Matney

  > Proper names, especially b/c the order here does not match the
  > 'numbers'.

- ([`b966ddc`](https://github.com/russmatney/dothop/commit/b966ddc)) feat: support scrolling unlocked worlds on the worldmap - Russell Matney

  > Fixes some focus grabbing and prevents access to locked puzzles, but
  > otherwise feel free to scroll through the worlds.

- ([`45bb6c4`](https://github.com/russmatney/dothop/commit/45bb6c4)) feat: default to the first next_puzzle_icon - Russell Matney

  > As we're going to be opening up multiple puzzles at a time, we set this
  > choose earlier levels rather than later ones.

- ([`e8286e5`](https://github.com/russmatney/dothop/commit/e8286e5)) fix: support interrupting the current sound - Russell Matney

  > Not precisely the same, but close enough to what i had before.

- ([`3f6244f`](https://github.com/russmatney/dothop/commit/3f6244f)) feat: better green-button-theme disabled state - Russell Matney
- ([`bbc49e7`](https://github.com/russmatney/dothop/commit/bbc49e7)) feat: sliders for music and sound volume - Russell Matney

  > Moves the sounds to playing via SoundManager - further DJ clean up can
  > come later.
  > 
  > One quirk is that the sounds now overlap rather than interrupting
  > each other - might be slightly annoying, hopefully there's a quick fix
  > around for this.

- ([`6d5d12d`](https://github.com/russmatney/dothop/commit/6d5d12d)) fix: leaf/space achievement mixup - Russell Matney

  > I ought to update the puzzle entity ids to prevent this kind of thing

- ([`d379375`](https://github.com/russmatney/dothop/commit/d379375)) export: update osx export to godotsteam template - Russell Matney

### 27 Feb 2024

- ([`97fc869`](https://github.com/russmatney/dothop/commit/97fc869)) fix: clear test achievement and no more achv. clearing - Russell Matney
- ([`aaec282`](https://github.com/russmatney/dothop/commit/aaec282)) feat: impl puzzle-complete, options, and dot-earned achievements - Russell Matney

  > Quick and dirty - would be nice to abstract out achievements, but first
  > we'll see if this much even works.

- ([`2b9afb8`](https://github.com/russmatney/dothop/commit/2b9afb8)) feat: achievement icons - Russell Matney
- ([`34d0477`](https://github.com/russmatney/dothop/commit/34d0477)) fix: support running with a non-godotsteam build - Russell Matney

  > Only do steam things when there is a 'Steam' singleton - this
  > works-around needing godot-steam to run unit tests in CI.

- ([`29d4467`](https://github.com/russmatney/dothop/commit/29d4467)) feat: godotsteam basic integration, including test achievement - Russell Matney

  > Adds a GodotSteam autoload, references to godot-steam templates, and
  > some handling for creating and dropping a test achievement. Working
  > pretty well! Expects to be run in a version of godot compiled with
  > godot-steam as a godot extension: https://github.com/CoaguCo-Industries/GodotSteam/releases/tag/v4.6

- ([`a99ad16`](https://github.com/russmatney/dothop/commit/a99ad16)) fix: drop pandora debug conditionals - Russell Matney

  > Pandora production releases don't seem to work. will have to investigate
  > further, but for now, just ship it.

- ([`2f7d702`](https://github.com/russmatney/dothop/commit/2f7d702)) feat: add more playtesters to the credits - Russell Matney
- ([`c56a55b`](https://github.com/russmatney/dothop/commit/c56a55b)) fix: scroll credits with joystick now working - Russell Matney
- ([`c7daa40`](https://github.com/russmatney/dothop/commit/c7daa40)) feat: space theme, swap player/target colors - Russell Matney

  > This goal is actually the same as the 'starfish' goal from the summer
  > theme.

- ([`7a6f04e`](https://github.com/russmatney/dothop/commit/7a6f04e)) fix: don't move puzzle cursor on hover, reselect on refocus - Russell Matney

  > Supports adding the cursor animation back when the mouse leaves the
  > next/prev buttons.

- ([`a81d939`](https://github.com/russmatney/dothop/commit/a81d939)) feat: brighter fall background - Russell Matney

  > Much more readable!

- ([`a4f93db`](https://github.com/russmatney/dothop/commit/a4f93db)) feat: spring, summer, winter player/dot/goal outlines - Russell Matney

  > Improves some visual clarity by adding outlines to players/dots/goals in
  > spring/summer/winter.

- ([`1ee1715`](https://github.com/russmatney/dothop/commit/1ee1715)) feat: redo Them Dots art at 16x16 - Russell Matney

  > Not sure quite how i feel about these dots yet

- ([`ff28971`](https://github.com/russmatney/dothop/commit/ff28971)) fix: readjust more progress panel sizes - Russell Matney

  > This progress panel size easily breaks - perhaps it needs a proper reset
  > in _ready() every time?

- ([`7ebca44`](https://github.com/russmatney/dothop/commit/7ebca44)) wip: stub some skipped-puzzle handling - Russell Matney
- ([`ce138a5`](https://github.com/russmatney/dothop/commit/ce138a5)) fix: support starting a 'selected' puzzle - Russell Matney

  > puzzle_idx was being reset before navigation


### 26 Feb 2024

- ([`4a086a7`](https://github.com/russmatney/dothop/commit/4a086a7)) feat: basic puzzle count on main menu - Russell Matney

  > Slightly brittle dot_count() impl on the puzzle_def - might want to tie
  > in the legend/mapping earlier, maybe even in the parser.


### 25 Feb 2024

- ([`851fd03`](https://github.com/russmatney/dothop/commit/851fd03)) fix: don't return before undoing both players - Russell Matney
- ([`dd457ad`](https://github.com/russmatney/dothop/commit/dd457ad)) fix and test: puzzle skipping data handling - Russell Matney

  > This is more or less working now. the data handling is getting a bit
  > complicated - the event state updates don't apply to the in-place
  > puzzle-sets, so refetching/syncing might be necessary in some cases...

- ([`6423271`](https://github.com/russmatney/dothop/commit/6423271)) feat: support Store.skip_puzzle - Russell Matney

  > A bit rough to need to recompute here - hopefully the data stays
  > managable.
  > 
  > Perhaps I should write some tests??

- ([`15bd41a`](https://github.com/russmatney/dothop/commit/15bd41a)) feat: add and managed skip is_active - Russell Matney

  > Skips are active by default, and are deactivated when the same puzzle
  > index is completed.

- ([`6ea2db7`](https://github.com/russmatney/dothop/commit/6ea2db7)) feat: refactor puzzle_set to support skipping, completing - Russell Matney

  > Sets up a more fine-grained marking of complete puzzles, plus some extra
  > data-base for skipping levels.
  > 
  > We'll probably want a flag on these skips for when they're not relevant
  > anymore (i.e. when the level gets proper completed).

- ([`f34b944`](https://github.com/russmatney/dothop/commit/f34b944)) fix: better progress-jumbo header - Russell Matney
- ([`83128d4`](https://github.com/russmatney/dothop/commit/83128d4)) feat: fixup control tweens in hud, animate reset puzzle - Russell Matney
- ([`878b16c`](https://github.com/russmatney/dothop/commit/878b16c)) fix: show controls at 0.5 instead of 0.1 - Russell Matney

  > Also refactors the hud's reaction to inputs to listen to proper puzzle
  > signals (like move_rejected and player_undo) rather than just trolley
  > inputs. this should give some better feedback to players when they
  > move-to-undo or can't move at all (i.e. stuck on the target).

- ([`be74248`](https://github.com/russmatney/dothop/commit/be74248)) feat: explicit set_focus worldmap impl - Russell Matney

  > Supports selecting a puzzle after 'pause' instead of a next/prev button.

- ([`eaf5da1`](https://github.com/russmatney/dothop/commit/eaf5da1)) fix: more focus tweaks - Russell Matney

  > The worldmap is still loading without grabbing focus - I'm not sure
  > what's the deal, so here's some more aggressive focus grabbing. This is
  > super annoying b/c it completely breaks the game if the user doesn't
  > have a mouse/screen-input to fix it. Probably should impl some fallback
  > so that arbitrary inputs check and find a focus if necessary.

- ([`d419e24`](https://github.com/russmatney/dothop/commit/d419e24)) feat: red/blue button states much more distinct - Russell Matney
- ([`20a5657`](https://github.com/russmatney/dothop/commit/20a5657)) feat: refactor worldmap menu for better ux - Russell Matney

  > - move prev/next buttons in-line with grid
  > - animate button and label when new puzzle/puzzle-set selected
  > - disable 'start' button when next/prev focused
  > - improve normal/focused button color distinction
  > - support mouse/focus enter/exit interaction on next/prev and puzzle icons
  > 
  > Overall, it's just much clearer how to select a puzzle/what the ui is
  > trying to be

- ([`3fa8185`](https://github.com/russmatney/dothop/commit/3fa8185)) fix: unpause when selecting a new theme - Russell Matney
- ([`c01cda8`](https://github.com/russmatney/dothop/commit/c01cda8)) fix: another step in the 'tutorial' world-1 - Russell Matney
- ([`a372574`](https://github.com/russmatney/dothop/commit/a372574)) fix: plain-text parser is a bit brittle! - Russell Matney

  > yikes, this completely broke the game. presumably the tests would have
  > failed?

- ([`f0a6354`](https://github.com/russmatney/dothop/commit/f0a6354)) fix: proper navi current_scene set and log - Russell Matney

  > Now that I know how to wait process_frames, things are starting to click
  > a bit. Though I don't think I really need to in this case...

- ([`e2cff63`](https://github.com/russmatney/dothop/commit/e2cff63)) fix: add more basic level 4 - hopefully better ramp up - Russell Matney

  > hopping over already-dotted dots is a key mechanic, so here's a minimal
  > level emphasizing that


### 23 Feb 2024

- ([`af42c0d`](https://github.com/russmatney/dothop/commit/af42c0d)) wip: logging puzzle stats in the main menu - Russell Matney
- ([`65ed077`](https://github.com/russmatney/dothop/commit/65ed077)) wip: some sunburst particles, maybe for an effect - Russell Matney
- ([`238b94d`](https://github.com/russmatney/dothop/commit/238b94d)) feat: nav to credits after completing last puzzle_set - Russell Matney
- ([`47a0cdd`](https://github.com/russmatney/dothop/commit/47a0cdd)) feat: fancy unlocked-something sunbursty jumbotron - Russell Matney

  > Maybe annoying to some, but my gut is to be loud about unlocks, so i'm
  > going for it

- ([`f3cc0f0`](https://github.com/russmatney/dothop/commit/f3cc0f0)) feat: support resizing puzzle_list icons and adding columns - Russell Matney

  > This was annoying, but i finally figured out i need to kill the
  > custom_minimum_size on the animated vbox to get it to shrink properly.
  > The panel still seems a bit too tall in some cases, but w/e.

- ([`ab12668`](https://github.com/russmatney/dothop/commit/ab12668)) fix: disable layout randomization in hard-coded tests - Russell Matney
- ([`35d46b6`](https://github.com/russmatney/dothop/commit/35d46b6)) feat: impl and enable slight level randomization - Russell Matney

  > Randomly reverses xs and/or ys on each level. keeping it fresh!

- ([`e67237e`](https://github.com/russmatney/dothop/commit/e67237e)) feat: if all puzzles complete, select first puzzle icon - Russell Matney

  > Also moves the start-button focus grab up to prevent the arbitrary wait

- ([`de32570`](https://github.com/russmatney/dothop/commit/de32570)) feat: puzzle progress animation tweaks - Russell Matney

  > - waits a frame and hides the panel before toasting
  > - locks the puzzle_num so it's not off by one
  > - delays move-cursor a bit to fix alignment (yucky hard-coded number)
  > - adds margin and animation disable to animatedvbox


### 22 Feb 2024

- ([`900604e`](https://github.com/russmatney/dothop/commit/900604e)) feat: demo export supporting first two puzzle sets - Russell Matney

  > Pandora and feature tags made this really easy!
  > 
  > - Duplicates the existing windows/linux/web exports, renames them 'demo',
  > adds a feature tag 'demo', and gives them proper dist/dothop-demo-* directories.
  > - adds a new property to the puzzle sets: allowed_in_demo
  > - filters puzzles by allowed_in_demo in Store/State when first loading,
  > but only when the allowed_in_demo feature tag is set

- ([`012c345`](https://github.com/russmatney/dothop/commit/012c345)) wip: rough progress panel toast - Russell Matney

  > Not quite getting the right height, and pretty brittle as an implementation....

- ([`8c25009`](https://github.com/russmatney/dothop/commit/8c25009)) wip: basic toast animation - Russell Matney
- ([`213134c`](https://github.com/russmatney/dothop/commit/213134c)) chore: move jumbotron to core/ui dir - Russell Matney
- ([`1499d32`](https://github.com/russmatney/dothop/commit/1499d32)) feat: show puzzle progress on pause menu - Russell Matney
- ([`ad50d1e`](https://github.com/russmatney/dothop/commit/ad50d1e)) feat: break PuzzleProgressPanel out of PuzzleComplete scene - Russell Matney
- ([`351818b`](https://github.com/russmatney/dothop/commit/351818b)) fix: 'types' were causing unit test failures - Russell Matney

  > half-baked type system strikes again!
  > 
  > Also renames vars that are now colliding. Trying to keep some stateless
  > functions around...

- ([`54fe791`](https://github.com/russmatney/dothop/commit/54fe791)) fix: readme clean up credits layout - Russell Matney
- ([`dd5af56`](https://github.com/russmatney/dothop/commit/dd5af56)) feat: add devlog, trailer, itch links to readme - Russell Matney

### 21 Feb 2024

- ([`0c3f41b`](https://github.com/russmatney/dothop/commit/0c3f41b)) fix: y-sort on winter theme - Russell Matney

  > Refactors the puzzle-scene to add players last (so they're on top of
  > dotted/dots anims), and enables y-sort on the winter dots/players. Could
  > have handled the ysort in the code.... but we'll see how different these
  > themes need to be first.

- ([`182b0d9`](https://github.com/russmatney/dothop/commit/182b0d9)) refactor: Solver -> PuzzleAnalysis - Russell Matney

  > Moves from an analysis dictionary to a stronger type.

- ([`7893484`](https://github.com/russmatney/dothop/commit/7893484)) fix: do not accept unsupported mouse input events - Russell Matney

  > These cause crashes further along, b/c we don't support rendering of
  > mouse controls.

- ([`5e14f49`](https://github.com/russmatney/dothop/commit/5e14f49)) fix: early return in move_puzzle_cursor if icon is null - Russell Matney

  > if the next/prev world buttons are clicked repeatedly, the icon can be
  > gone by the time the call_in timer fn is called, resulting in a crash
  > when we try to read .global_position from null.

- ([`41eb6ef`](https://github.com/russmatney/dothop/commit/41eb6ef)) feat: don't call super.render() - Russell Matney

  > The parent render func is just debug stuff, nothing we need to worry
  > about.

- ([`a4bf241`](https://github.com/russmatney/dothop/commit/a4bf241)) sound: add gong sound to 'new-puzzle-set-unlocked' moment - Russell Matney
- ([`258c182`](https://github.com/russmatney/dothop/commit/258c182)) feat: clamp to a minimum pitch/scale_note - Russell Matney

  > Avoids some odd sounds on the lowest end. Sticking with the same
  > movement sound!

- ([`cf72a58`](https://github.com/russmatney/dothop/commit/cf72a58)) fix: support string paths, not just preloaded sounds - Russell Matney
- ([`738183c`](https://github.com/russmatney/dothop/commit/738183c)) feat: add ben_burnes symlink, credits, new music assigned - Russell Matney

  > Also updates the readme and fixes the credits rendering (the credit line
  > and header are now different font sizes).

- ([`b711193`](https://github.com/russmatney/dothop/commit/b711193)) feat: extend themes to support a list of optional music tracks - Russell Matney

  > Only the first will be played, but a list seems to be better long term.
  > This allows tracks to be referenced that may not exist in the repo (e.g.
  > during CI builds). If no track in the list is present, the
  > background_music property is used as a fallback.

- ([`d231a45`](https://github.com/russmatney/dothop/commit/d231a45)) feat: add link to github at top of credits - Russell Matney
- ([`2acc65e`](https://github.com/russmatney/dothop/commit/2acc65e)) fix: remove 'Calls to action' itch links in credits - Russell Matney

  > Steam rejected the build because i included text (unclickable!) links to
  > some of the free assets used to make this game. Calling these 'calls to
  > action' is quiet a stretch, and the language in the rejection says it's
  > ok if it goes through steam wallet... for free assets? Eh, bunch of
  > corpo bullshit.

- ([`4b59adb`](https://github.com/russmatney/dothop/commit/4b59adb)) tweak: adjusted asteroid animation speeds - Russell Matney

  > Plus an improved bee sprite


### 20 Feb 2024

- ([`df123ea`](https://github.com/russmatney/dothop/commit/df123ea)) chore: drop a bunch of completed or old TODOs - Russell Matney

### 19 Feb 2024

- ([`4c0d5b1`](https://github.com/russmatney/dothop/commit/4c0d5b1)) fix: set dothop-six for winter puzzles - Russell Matney
- ([`3324eb7`](https://github.com/russmatney/dothop/commit/3324eb7)) feat: support changing the puzzle number in the editor - Russell Matney

### 18 Feb 2024

- ([`330d561`](https://github.com/russmatney/dothop/commit/330d561)) wip: basic texture particle effect - Russell Matney
- ([`88f508e`](https://github.com/russmatney/dothop/commit/88f508e)) fix: return player finished moving signal - Russell Matney
- ([`2df0ecf`](https://github.com/russmatney/dothop/commit/2df0ecf)) wip: very bad bee sprite. yuck. - Russell Matney
- ([`0f16577`](https://github.com/russmatney/dothop/commit/0f16577)) feat: snow dots are now snowmen and puzzles - Russell Matney
- ([`dc07898`](https://github.com/russmatney/dothop/commit/dc07898)) feat: add progress/complete jumbotrons back in - Russell Matney

  > Puzzles can now opt-in to showing progress via 'show_progress' metadata
  > on the puzzle itself.

- ([`23a770e`](https://github.com/russmatney/dothop/commit/23a770e)) test: assert on arbitrary puzzle metadata - Russell Matney

  > Now optionally parsing meta flags/strings per puzzle

- ([`bd0638f`](https://github.com/russmatney/dothop/commit/bd0638f)) refactor: add GameDef, PuzzleDef types, rename level -> puzzle - Russell Matney

  > Solidifies the parsed GameDef and PuzzleDef types, and moves from
  > 'level' to 'puzzle' naming across the board.
  > 
  > Should be able to get the analysis data on the PuzzleDef as well - these
  > types should help with misc clean up and sorting by difficulty, etc.


### 17 Feb 2024

- ([`7c71499`](https://github.com/russmatney/dothop/commit/7c71499)) misc: comment, drop noise - Russell Matney
- ([`0caa4fa`](https://github.com/russmatney/dothop/commit/0caa4fa)) feat: adjust transition, move animation into 'rebuild' - Russell Matney

  > This is finally feeling better - all the animation work is done in
  > 'rebuild' instead of spread across a few places. this sets up potential
  > for handing some state from the previous puzzle to the next.

- ([`0bc71ab`](https://github.com/russmatney/dothop/commit/0bc71ab)) feat: display solver analysis on editor - Russell Matney

  > With various fixes

- ([`120c3a9`](https://github.com/russmatney/dothop/commit/120c3a9)) feat: smoother camera, tween delays instead of timeout awaits - Russell Matney

  > Rather than a function evolving into a generator, we pass arbitrary
  > delays to the tweens themselves.

- ([`1ff36c7`](https://github.com/russmatney/dothop/commit/1ff36c7)) feat: puzzle editor rendering fixes and rearrangement - Russell Matney
- ([`236c905`](https://github.com/russmatney/dothop/commit/236c905)) feat: pull Anim into dothop/src, eat animation logic - Russell Matney

  > Pulls dothop puzzle-node animation details into src/Anim.gd, which
  > cleans up the gamescene/puzzlescene/dot/player impls a bit. Starting to
  > look nicer here!

- ([`2f9f9ad`](https://github.com/russmatney/dothop/commit/2f9f9ad)) wip: remove jumbotron from puzzle-complete flow - Russell Matney

  > Kind of liking the instant transition here

- ([`3631a99`](https://github.com/russmatney/dothop/commit/3631a99)) fix: better movement, fix stuck-movement bug - Russell Matney

  > If we don't use the proper 'og-position' here, the node.position can be
  > some non-grid location, and it ends up being where the player rests
  > after moving 'back'.

- ([`ca6ad15`](https://github.com/russmatney/dothop/commit/ca6ad15)) fix: remove extra node.create_tween() - Russell Matney
- ([`6d5055a`](https://github.com/russmatney/dothop/commit/6d5055a)) feat: toying with intro/outro anims - Russell Matney
- ([`6ac5b44`](https://github.com/russmatney/dothop/commit/6ac5b44)) refactor: pull centering logic into puzzle_node - Russell Matney

  > And simplify the dothopcam

- ([`70f216d`](https://github.com/russmatney/dothop/commit/70f216d)) feat: slide to/from point anims - Russell Matney

  > And an animation-friendly camera-centering fix

- ([`c39c7ff`](https://github.com/russmatney/dothop/commit/c39c7ff)) feat: dots/goals further dry up - Russell Matney
- ([`bf86325`](https://github.com/russmatney/dothop/commit/bf86325)) refactor: player animation dry up - Russell Matney

  > I suppose i sort of let this get out of hand!

- ([`7cd2182`](https://github.com/russmatney/dothop/commit/7cd2182)) chore: DRY up a bunch of animation code - Russell Matney

  > A bit buggy in some places, but we def don't need 400 extra lines here

- ([`91f2612`](https://github.com/russmatney/dothop/commit/91f2612)) wip: DRYing up per theme animations - Russell Matney

### 16 Feb 2024

- ([`a59bb06`](https://github.com/russmatney/dothop/commit/a59bb06)) fix: call init_game_state, add cam only when inside tree - Russell Matney

  > Puzzle solver tests were crashing b/c of changes to the puzzle_scene -
  > this fixes them so they can still run without being added to the scene
  > tree.

- ([`93aed4d`](https://github.com/russmatney/dothop/commit/93aed4d)) feat: waits for player to finish moving before emitting win - Russell Matney

  > Need to update the other player move impls. Hopefully this doesn't
  > introduce any bugs!


### 15 Feb 2024

- ([`80de25b`](https://github.com/russmatney/dothop/commit/80de25b)) chore: drop phantom camera - Russell Matney

  > This addon is great, but doesn't fit the use-case for dothop.

- ([`9ca105b`](https://github.com/russmatney/dothop/commit/9ca105b)) refactor: move backgrounds to fixed canvas layers - Russell Matney
- ([`82b0570`](https://github.com/russmatney/dothop/commit/82b0570)) wip: basic camera that centers on puzzles - Russell Matney
- ([`b07d326`](https://github.com/russmatney/dothop/commit/b07d326)) wip: debug toggle for printing followed nodes - Russell Matney
- ([`8aca086`](https://github.com/russmatney/dothop/commit/8aca086)) fix: prevent initially dotted nodes from being followed - Russell Matney

  > Towards resolving the weird camera off-center issues

- ([`90efd16`](https://github.com/russmatney/dothop/commit/90efd16)) fix: prevent puzzle scenes from loading twice - Russell Matney
- ([`7605d97`](https://github.com/russmatney/dothop/commit/7605d97)) feat: better dot/player debug logs - Russell Matney

### 14 Feb 2024

- ([`3cf3fba`](https://github.com/russmatney/dothop/commit/3cf3fba)) wip: weak background tweak - Russell Matney

  > These and the camera really aren't working :/

- ([`33618ad`](https://github.com/russmatney/dothop/commit/33618ad)) feat: working pcam on sub-viewport rendered puzzle scene - Russell Matney

  > Editor nearly useful - making it clear the phantom_camera and
  > backgrounds aren't well configured for most scenes!

- ([`bfa8357`](https://github.com/russmatney/dothop/commit/bfa8357)) feat: rendering selected puzzle via subviewport - Russell Matney

  > Looks pretty gross, but things are kind of working!

- ([`fc64702`](https://github.com/russmatney/dothop/commit/fc64702)) feat: rearrange dot/dotted/goal state in puzzle_set uis - Russell Matney
- ([`4eafffb`](https://github.com/russmatney/dothop/commit/4eafffb)) feat: add goal_icon textures for every theme - Russell Matney
- ([`5561986`](https://github.com/russmatney/dothop/commit/5561986)) feat: space player different color and 'moving' animation - Russell Matney
- ([`fd474ff`](https://github.com/russmatney/dothop/commit/fd474ff)) feat: fall theme using 'dotted' icon in ui - Russell Matney
- ([`1d402da`](https://github.com/russmatney/dothop/commit/1d402da)) feat: 'dotted' frame for each leaf in the fall theme - Russell Matney
- ([`0ac9b3d`](https://github.com/russmatney/dothop/commit/0ac9b3d)) feat: set random anim frames on dots - Russell Matney
- ([`6f1c28b`](https://github.com/russmatney/dothop/commit/6f1c28b)) refactor: theme handling within puzzleScene - Russell Matney

  > Rather than handling theme stuff in the gameScene, we let the
  > puzzleScene use themes directly, which is cleaner and sets up the
  > puzzle-set editor to more easily use the puzzleScene itself.
  > 
  > Also cleans up the theme.puzzle_scenes - generated shapes don't set
  > their owner in the editor to reduce the git-noise/churn when on what
  > should be fairly simple puzzle tscns

- ([`d4ea2b6`](https://github.com/russmatney/dothop/commit/d4ea2b6)) refactor: get themes from the store, not pandora - Russell Matney

  > A bit cleaner.

- ([`6f6d9c6`](https://github.com/russmatney/dothop/commit/6f6d9c6)) chore: remove unused code and controls - Russell Matney
- ([`22260d8`](https://github.com/russmatney/dothop/commit/22260d8)) fix: proper worldmap puzzle nav button disable - Russell Matney

  > Plus a fix to grabbing focus when all puzzles are 'complete'.

- ([`c239340`](https://github.com/russmatney/dothop/commit/c239340)) feat: better puzzle complete layout - Russell Matney

  > Larger fonts, larger buttons, smaller margins, etc.

- ([`4358933`](https://github.com/russmatney/dothop/commit/4358933)) fix: drop fall theme move sound - Russell Matney

  > This sound doesn't work as well as the default.


### 13 Feb 2024

- ([`dafc1c0`](https://github.com/russmatney/dothop/commit/dafc1c0)) feat: selecting and rendering themed puzzles on click - Russell Matney

  > tho, the backgrounds are completely blocking the ui after load :/

- ([`741cf09`](https://github.com/russmatney/dothop/commit/741cf09)) wip: logging the shape of the selected puzzle - Russell Matney

  > now, how best to render this thing? with the game scene of course!

- ([`788b38c`](https://github.com/russmatney/dothop/commit/788b38c)) wip: listing puzzles as icons in the editor - Russell Matney
- ([`8903b89`](https://github.com/russmatney/dothop/commit/8903b89)) wip: early PuzzleScriptEditor - Russell Matney

  > just pretty-printing puzzle_set entities

- ([`dfbcf7a`](https://github.com/russmatney/dothop/commit/dfbcf7a)) feat: slightly more interesting credits - Russell Matney

  > Creates a credit header with a bolder font applied to '# blah' prefixed
  > sections. Could really use some color here/text-effects to differentiate
  > here.

- ([`b3c25a1`](https://github.com/russmatney/dothop/commit/b3c25a1)) fix: resume worldmap music when naving back from game scene - Russell Matney

  > Was stopping music too aggressively here. of note - the next scene's
  > _ready fires before the current scene's _exit_tree! wut!

- ([`dc69294`](https://github.com/russmatney/dothop/commit/dc69294)) feat: update puzzle_num in hud on next puzzle rebuild - Russell Matney

  > Rather than inc when the current puzzle is complete, which feels odd

- ([`3f1e6ed`](https://github.com/russmatney/dothop/commit/3f1e6ed)) feat: confirmation dialogue theme - Russell Matney
- ([`af81818`](https://github.com/russmatney/dothop/commit/af81818)) fix: edit one control at a time, listen to _input() - Russell Matney

  > Better flow for updating controls - editing a second control will cancel
  > the first, if it's floating open. Better listening - _unhandled_input()
  > was causing movement inputs to also move the on-screen focus - using
  > _input() seems to prevent this.
  > 
  > Unfortunately still some issues here: InputHelper doesn't seem to
  > provide a way to 'move' a control, only 'swap' or 'assign to both',
  > which is annoying for the redundant movement helpers i have in
  > place (hjkl/wasd/arrows).

- ([`bdfe33a`](https://github.com/russmatney/dothop/commit/bdfe33a)) fix: prefer space over enter for ui_accept hints - Russell Matney
- ([`1801a84`](https://github.com/russmatney/dothop/commit/1801a84)) fix: move to queue_free - maybe fix a recurring error? - Russell Matney
- ([`dafd074`](https://github.com/russmatney/dothop/commit/dafd074)) fix: adjust hover font color - Russell Matney

  > Helps differentiate hovering buttons with the mouse vs 'focusing'
  > buttons with the keyboard/controller.

- ([`87d8c33`](https://github.com/russmatney/dothop/commit/87d8c33)) fix: actually disable buttons (incl. focus and mouse) - Russell Matney

  > disabling a button doesn't update the mouse or focus bits, so they are
  > still 'selectable' in the ui. This adds a helper to Util to clean up the
  > noise.

- ([`fadaa82`](https://github.com/russmatney/dothop/commit/fadaa82)) fix: resolution 1280x720, scale_mode back to fractional - Russell Matney
- ([`16d1bb8`](https://github.com/russmatney/dothop/commit/16d1bb8)) feat: wait longer before grabbing focus - Russell Matney

  > on the steam deck, the worldmap screen fails to grab focus, but it seems
  > to work fine on linux, even with a controller. maybe just some kind of
  > deferred timing issue? Here we call a bit later and hope it works.

- ([`57590d7`](https://github.com/russmatney/dothop/commit/57590d7)) fix: windows build disabled embed_pck - Russell Matney

  > Hoping this fixes the launch security issue

- ([`38278ba`](https://github.com/russmatney/dothop/commit/38278ba)) fix: kill jumbotron when navigating - Russell Matney

  > Adds a signal to navi -> hopefully we're using Navi for all navigation,
  > or maybe there's some godot-native signal we should be using for this...

- ([`87a96e8`](https://github.com/russmatney/dothop/commit/87a96e8)) puzz: rearrange final two winter levels - Russell Matney
- ([`823af74`](https://github.com/russmatney/dothop/commit/823af74)) fix: prevent crash when closing old jumbotron - Russell Matney
- ([`d720dbe`](https://github.com/russmatney/dothop/commit/d720dbe)) chore: larger puzz complete header - Russell Matney

  > Plus, clean up event printing log (don't log puzzle-complete events).


### 12 Feb 2024

- ([`6809f12`](https://github.com/russmatney/dothop/commit/6809f12)) fix: wider min-width on puzzles panel - Russell Matney
- ([`ab4932d`](https://github.com/russmatney/dothop/commit/ab4932d)) chore: drop unused font - Russell Matney
- ([`fb51aaf`](https://github.com/russmatney/dothop/commit/fb51aaf)) feat: re-order puzzle sets - Russell Matney

  > the order is now: dots, spring, summer, fall, winter, space
  > 
  > Also cleans up some old 'messages' from the raw puzzle files.

- ([`3680ebd`](https://github.com/russmatney/dothop/commit/3680ebd)) feat: include 'unlock' text on puzzleComplete screen - Russell Matney
- ([`3fcd9e8`](https://github.com/russmatney/dothop/commit/3fcd9e8)) feat: add some more winning phrases - Russell Matney
- ([`8766b15`](https://github.com/russmatney/dothop/commit/8766b15)) feat: use PuzzleComplete for PuzzleSetComplete as well - Russell Matney
- ([`a854305`](https://github.com/russmatney/dothop/commit/a854305)) feat: puzzleComplete jumbotron impled, animating some progress - Russell Matney
- ([`2486603`](https://github.com/russmatney/dothop/commit/2486603)) fix: add count for duplicate events - Russell Matney

  > Completing puzzles multiple times was resulting in duplicate events,
  > which could eventually blow up the save file size - this instead looks
  > for a matching event, updating a count field on it if found.

- ([`7e02893`](https://github.com/russmatney/dothop/commit/7e02893)) todo: completing a puzzle multiple times creates multiple save events - Russell Matney

  > Worth dealing with this sooner than later

- ([`1c9bfbc`](https://github.com/russmatney/dothop/commit/1c9bfbc)) feat: start worldmap on next-puzzle-to-complete - Russell Matney
- ([`86b0621`](https://github.com/russmatney/dothop/commit/86b0621)) feat: save puzzle complete events, remove pause nav confirmations - Russell Matney

  > These confirmations are no longer accurate - puzzle progress is saved
  > per-puzzle now.

- ([`3947924`](https://github.com/russmatney/dothop/commit/3947924)) feat: buttons for navigating between puzzle sets - Russell Matney

  > Also supporting starting on an arbitrarily selected puzzle.

- ([`57cbc2e`](https://github.com/russmatney/dothop/commit/57cbc2e)) feat: animated 'cursor' jumping to next level icon - Russell Matney
- ([`15622ae`](https://github.com/russmatney/dothop/commit/15622ae)) feat: distinguish completed/current/incomplete puzzles on world map - Russell Matney
- ([`31768d1`](https://github.com/russmatney/dothop/commit/31768d1)) chore: bunch of scene id churn - Russell Matney
- ([`07e92af`](https://github.com/russmatney/dothop/commit/07e92af)) test: coverage for PuzzleCompleted events - Russell Matney

  > A basic test asserting:
  > - the expected events are created
  > - puzzleSet.can_play_puzzle(index) works as expected

- ([`ed3228d`](https://github.com/russmatney/dothop/commit/ed3228d)) fix: assign script_path and generate event id - Russell Matney

  > Missed this bit of configuration that i depend on - was accidentally
  > creating puzzleset events, not puzzle events.

- ([`bde9246`](https://github.com/russmatney/dothop/commit/bde9246)) feat: PuzzleCompleted event and gamestate handling - Russell Matney

  > Extends the PuzzleSet model to track a max_completed_puzzle_index, and
  > adds a new event for updating that index.


### 9 Feb 2024

- ([`82f8eae`](https://github.com/russmatney/dothop/commit/82f8eae)) feat: macos export and steam vdf - Russell Matney
- ([`0a43615`](https://github.com/russmatney/dothop/commit/0a43615)) fix: rename DotHopTheme > PuzzleTheme, fix osx - Russell Matney

  > Getting the latest running on osx is a big pain every time lately, kind
  > of annoying.

- ([`41485dc`](https://github.com/russmatney/dothop/commit/41485dc)) misc: asset exports, scene id churn - Russell Matney
- ([`8af7ad4`](https://github.com/russmatney/dothop/commit/8af7ad4)) export: windows export and steam deploy vdf - Russell Matney

### 8 Feb 2024

- ([`292052e`](https://github.com/russmatney/dothop/commit/292052e)) fix: restore muting music - Russell Matney

  > A quick hack to restore the mute-music feature. SoundManager expects a
  > separate audio bus to exist, so here we create one for music and update
  > dj's mute impl to also mute using the SoundManager's music funcs.
  > 
  > oh and a bunch of updated node ids i guess.


### 7 Feb 2024

- ([`32e4910`](https://github.com/russmatney/dothop/commit/32e4910)) chore: comment todo - Russell Matney
- ([`7219647`](https://github.com/russmatney/dothop/commit/7219647)) wip: attempt to resume music when naving back to worldmap - Russell Matney
- ([`7ddad5c`](https://github.com/russmatney/dothop/commit/7ddad5c)) feat: showing theme-based icons for complete/incomplete puzzles - Russell Matney
- ([`cdfa5c8`](https://github.com/russmatney/dothop/commit/cdfa5c8)) feat: add player/dot/dotted icon textures to puzzle themes - Russell Matney

  > Then assign something for each. Feels like this maybe needs to be a list
  > rather than 1:1 - we have more than one dot texture per theme :/

- ([`603e3a6`](https://github.com/russmatney/dothop/commit/603e3a6)) feat: expand input map, support button-credit scroll - Russell Matney

  > The input map now supports playing with either joystick, and using
  > rb/lb/rt/lt to undo/restart.
  > 
  > the credits can now be scrolled with b/y instead of just up/down.
  > annoyingly the joystick up/down is not detected, but dpads work fine.

- ([`999b403`](https://github.com/russmatney/dothop/commit/999b403)) fix: jumbotron oversize fix, ui_accept input shown - Russell Matney
- ([`008b01d`](https://github.com/russmatney/dothop/commit/008b01d)) feat: jumbotron dismiss with a, not just b - Russell Matney
- ([`f9ef19b`](https://github.com/russmatney/dothop/commit/f9ef19b)) feat: refactor into song-per-theme, use SoundManager - Russell Matney

  > Now doing music via the SoundManager rather than DJ.

- ([`6eccf32`](https://github.com/russmatney/dothop/commit/6eccf32)) chore: drop unused script - Russell Matney
- ([`0da5daa`](https://github.com/russmatney/dothop/commit/0da5daa)) feat: add credits for song, sounds - Russell Matney
- ([`0966b7b`](https://github.com/russmatney/dothop/commit/0966b7b)) feat: play music on title, opts, worldmap screens - Russell Matney

  > Using that same song i use everywhere.

- ([`5c7dd7a`](https://github.com/russmatney/dothop/commit/5c7dd7a)) feat: drop unused sounds, some music tracks - Russell Matney
- ([`7981ec3`](https://github.com/russmatney/dothop/commit/7981ec3)) wip: very rough ascending pitch_scale - Russell Matney

  > Not finished at all, but more or less doing the thing.


### 6 Feb 2024

- ([`60a3927`](https://github.com/russmatney/dothop/commit/60a3927)) wip: first draft generator (by @camsbury) - Russell Matney

  > Comments out the 'short' bits for now, and this is working a bb repl!

- ([`d2e877a`](https://github.com/russmatney/dothop/commit/d2e877a)) feat: re-org worldmap to use one panel instead of two - Russell Matney

  > Cleaner worldmap. For now every world is traversible regardless of progress.

- ([`ddec351`](https://github.com/russmatney/dothop/commit/ddec351)) fix: more focus grabbing on start/opts menus - Russell Matney
- ([`32e6a2c`](https://github.com/russmatney/dothop/commit/32e6a2c)) fix: drop noisey logs - Russell Matney
- ([`00f5872`](https://github.com/russmatney/dothop/commit/00f5872)) feat: pause menu animating and grabbing focus - Russell Matney
- ([`8721560`](https://github.com/russmatney/dothop/commit/8721560)) feat: animated vbox, fade_in helpers - Russell Matney

  > Slightly animates some ui in places. Tries to reduce button-focus noise,
  > but it's still pretty annoying.

- ([`e4edcd3`](https://github.com/russmatney/dothop/commit/e4edcd3)) feat: quick hack to add sound to button-focus/press events - Russell Matney
- ([`6b57ab1`](https://github.com/russmatney/dothop/commit/6b57ab1)) chore: drop enter-input from assets, credits, readme - Russell Matney
- ([`04b591e`](https://github.com/russmatney/dothop/commit/04b591e)) refactor: move input-icon to kenney input-prompts - Russell Matney

  > Copies the existing vexed/enter-input icon comp to EnterInputIcon, then
  > refactors actionInputIcon to resolve to a texture rather than a key.
  > 
  > Drops mods for now - we may need to move from a textureRect to an hbox
  > to support multi-key inputs.

- ([`def50b7`](https://github.com/russmatney/dothop/commit/def50b7)) chore: move menus controls scenes into menus/controls - Russell Matney
- ([`b6d352c`](https://github.com/russmatney/dothop/commit/b6d352c)) chore: add kenney input prompts - Russell Matney

### 5 Feb 2024

- ([`fe744f1`](https://github.com/russmatney/dothop/commit/fe744f1)) feat: port dino/thanks into addons/core/credits - Russell Matney

  > And impl a rough credits setup for dothop, including most (all?) of the
  > creditors.

- ([`4660e55`](https://github.com/russmatney/dothop/commit/4660e55)) feat: proper hover state styles for buttons - Russell Matney
- ([`42a976d`](https://github.com/russmatney/dothop/commit/42a976d)) chore: move styles/ui comps from addons/core/ui to src/ui - Russell Matney
- ([`4942627`](https://github.com/russmatney/dothop/commit/4942627)) fix: better game state load log - Russell Matney
- ([`0cfb51c`](https://github.com/russmatney/dothop/commit/0cfb51c)) refactor: mute button explicit focus handling - Russell Matney

  > refactors the mute button list away from the ButtonList usage, so that
  > re-rendering and focus can be handled explicitly. prevents focus loss
  > when muting/unmuting. not perfect, but functional.

- ([`4144dd2`](https://github.com/russmatney/dothop/commit/4144dd2)) feat: modify pause menu from worldmap vs game - Russell Matney
- ([`d4a2d4d`](https://github.com/russmatney/dothop/commit/d4a2d4d)) feat: back to worldmap from pause menu - Russell Matney
- ([`38c944d`](https://github.com/russmatney/dothop/commit/38c944d)) fix: update hud control helpers when controls are changed - Russell Matney
- ([`ef2c9fa`](https://github.com/russmatney/dothop/commit/ef2c9fa)) feat: move global pause toggle to per-scene handling - Russell Matney

  > The global version is convenient, but allows for pausing on the title
  > and options screens, which is annoying. This moves to explicit support
  > in the worldmap and game scene, plus unpausing. note that we're marking
  > the event as handled to avoid immediately unpausing when pause is
  > pressed.

- ([`d8ea3f9`](https://github.com/russmatney/dothop/commit/d8ea3f9)) feat: main menu refactor - Russell Matney

  > Moves to a more explicit main menu (rather than using the button-list
  > style). This gives more control and overall is just simpler.
  > 
  > Sets the quit button to be red.

- ([`000a364`](https://github.com/russmatney/dothop/commit/000a364)) feat: pause menu with toggleable sections - Russell Matney

  > controls, themes, sound controls

- ([`bb51897`](https://github.com/russmatney/dothop/commit/bb51897)) refactor: break out and reuse ControlsPanel - Russell Matney

  > cleans up the options and pause menus. Drops quick-theme swapping for
  > now.


### 4 Feb 2024

- ([`3b9232b`](https://github.com/russmatney/dothop/commit/3b9232b)) feat: rough bg art on winter, spring, summer themes - Russell Matney
- ([`1663aee`](https://github.com/russmatney/dothop/commit/1663aee)) feat: move theme player/dots/goals into pandora arrays - Russell Matney

  > This sets up a way to create themes with multiple dot/player impls. it
  > also reveals that sounds right now are not tied to dots, but to
  > theme-puzzle-scenes.

- ([`2fe7b71`](https://github.com/russmatney/dothop/commit/2fe7b71)) fix: move to 'n dots left' label - Russell Matney
- ([`6c92030`](https://github.com/russmatney/dothop/commit/6c92030)) fix: move undo emit so the hud picks up 'direct' undos - Russell Matney

  > undos via controls (vs. moving 'backwards') were not updating the hud.

- ([`29ec008`](https://github.com/russmatney/dothop/commit/29ec008)) fix: don't include 'goal' in dot counts - Russell Matney
- ([`bdefd55`](https://github.com/russmatney/dothop/commit/bdefd55)) feat: more copy options after beating a puzzle - Russell Matney
- ([`e947808`](https://github.com/russmatney/dothop/commit/e947808)) fix: check out dot/dotted type again after timeout - Russell Matney
- ([`38f7d1d`](https://github.com/russmatney/dothop/commit/38f7d1d)) chore: rename DotHopTheme to DHTheme - Russell Matney

  > I wanted just 'Theme', but that class already exists :/

- ([`6df1e27`](https://github.com/russmatney/dothop/commit/6df1e27)) feat: stop music when exiting game scene - Russell Matney

  > Also support stopping music without knowing what song is playing.

- ([`358af1a`](https://github.com/russmatney/dothop/commit/358af1a)) feat: hop between puzzle-islands in more linear world-map - Russell Matney
- ([`6cb8b62`](https://github.com/russmatney/dothop/commit/6cb8b62)) feat: worldmap clean up and split - Russell Matney

### 2 Feb 2024

- ([`110c810`](https://github.com/russmatney/dothop/commit/110c810)) feat: each world as a rows of color rects - Russell Matney
- ([`189f11c`](https://github.com/russmatney/dothop/commit/189f11c)) wip: add children to puzzlemap shape - Russell Matney

  > also exposes the worldmap zoom factors

- ([`39af08b`](https://github.com/russmatney/dothop/commit/39af08b)) feat: include icon in generated puzzle map - Russell Matney

### 1 Feb 2024

- ([`ae1d30e`](https://github.com/russmatney/dothop/commit/ae1d30e)) tweak: delay/mix-up the on-focus map scaling - Russell Matney
- ([`4f8392c`](https://github.com/russmatney/dothop/commit/4f8392c)) wip: generated world map moving to per-puzzle-set markers - Russell Matney
- ([`0a2c829`](https://github.com/russmatney/dothop/commit/0a2c829)) feat: prevent repeat colors - Russell Matney
- ([`3e63a7d`](https://github.com/russmatney/dothop/commit/3e63a7d)) feat: center puzzle-maps on the y axis - Russell Matney
- ([`59eca76`](https://github.com/russmatney/dothop/commit/59eca76)) fix: don't forget to defer that add_child - Russell Matney
- ([`d17a6d2`](https://github.com/russmatney/dothop/commit/d17a6d2)) chore: a bunch of reimports, i guess? - Russell Matney

  > not sure why this is necessary, but it was automated, so :shrug: guess
  > i'll toggle it back when i'm on my other machine again.

- ([`119be6c`](https://github.com/russmatney/dothop/commit/119be6c)) fix: drop removed features from dj/plugin.gd - Russell Matney

  > These scenes were dropped, but i didn't clean up the plugin.gd at all :/

- ([`c050ec3`](https://github.com/russmatney/dothop/commit/c050ec3)) wip: towards generating a puzzle map - Russell Matney

  > - util add_color_rect gets a deferred=bool flag
  > 
  > - puzzle solver doesn't need to 'add_child' before analyzing, which
  >   makes it way cheaper and faster
  > 
  > - starts a PuzzleMap scene that pulls from new puzzle_set properties and
  >   computes puzzle_set dimensions (like max width/height)

- ([`dd81f28`](https://github.com/russmatney/dothop/commit/dd81f28)) wip: playing music when starting a puzzle - Russell Matney

  > unfortunately not stopping it, and layering more music if you keep
  > playing :)

- ([`2fe5d9e`](https://github.com/russmatney/dothop/commit/2fe5d9e)) feat: examples of overwriting - Russell Matney

  > These could be informed by @exports too if we want ui support.

- ([`430cf33`](https://github.com/russmatney/dothop/commit/430cf33)) feat: basic sound on player moves/blocked moves - Russell Matney
- ([`a4f6a0b`](https://github.com/russmatney/dothop/commit/a4f6a0b)) refactor: minimize DJ, move assets into dothop proper - Russell Matney

  > Towards figuring out what sound/music assets this game really needs

- ([`2169d46`](https://github.com/russmatney/dothop/commit/2169d46)) chore: add godot sound manager - Russell Matney

### 31 Jan 2024

- ([`1c1cce7`](https://github.com/russmatney/dothop/commit/1c1cce7)) fix: final puzzle is now solvable (heh) - Russell Matney
- ([`e936868`](https://github.com/russmatney/dothop/commit/e936868)) feat: add width/height to level_def and solver result - Russell Matney
- ([`27a93ee`](https://github.com/russmatney/dothop/commit/27a93ee)) feat: test for every puzzle, to be sure they're all solvable - Russell Matney

  > Turns out they're not!

- ([`e24174d`](https://github.com/russmatney/dothop/commit/e24174d)) feat: puzzle solver + analysis, with tests - Russell Matney

  > Couple recursive functions to build up a move-tree and then convert it
  > to a list of paths. Not too shabby! Some tweaks to the puzzleScene code:
  > 
  > - return true from puzzle.move() to indicate if a move was made
  > - set the state.win back to false when an 'undo' is performed
  > 
  > These helped the solver run, hopefully they won't get lost somewhere
  > along the way.


### 30 Jan 2024

- ([`413d8e4`](https://github.com/russmatney/dothop/commit/413d8e4)) wip: impling a puzzle solver - Russell Matney
- ([`edfc798`](https://github.com/russmatney/dothop/commit/edfc798)) fix: apparently the parser can't handle 1 line puzzles - Russell Matney
- ([`88a43ae`](https://github.com/russmatney/dothop/commit/88a43ae)) fix: restore dothop puzzle tests - Russell Matney

  > Similarly, nested test cases don't run. Or maybe it was b/c of the
  > inheritance? eh, these are better flattened anyway.

- ([`4e1834c`](https://github.com/russmatney/dothop/commit/4e1834c)) fix: restore parse tests - Russell Matney

  > Apparently these have not been running - seems that gdunit4 doesn't
  > support nested test cases, must have been a mistake on my part when i
  > switched from GUT

- ([`e252056`](https://github.com/russmatney/dothop/commit/e252056)) fix: drop hard-coded puzzle-count test - Russell Matney
- ([`1c59683`](https://github.com/russmatney/dothop/commit/1c59683)) puzzles: seven more snow levels - Russell Matney
- ([`a62dd6b`](https://github.com/russmatney/dothop/commit/a62dd6b)) chore: drop unused puzzlescript sections - Russell Matney

  > also adds back some dropped levels from the first world

- ([`9cdf44f`](https://github.com/russmatney/dothop/commit/9cdf44f)) puzzles: seven more spring levels - Russell Matney
- ([`538482b`](https://github.com/russmatney/dothop/commit/538482b)) puzzles: seven more beach puzzles - Russell Matney
- ([`0b89457`](https://github.com/russmatney/dothop/commit/0b89457)) fix: should be greater than 0, not 1 - Russell Matney
- ([`f0c816b`](https://github.com/russmatney/dothop/commit/f0c816b)) feat: confirmation dialogs, reset/unlock data buttons - Russell Matney

  > Improves but does not finish out some basic confirmation dialog styles.

- ([`fd37bb9`](https://github.com/russmatney/dothop/commit/fd37bb9)) feat: unlock-all-puzzles button on options menu - Russell Matney

  > plus misc menu clean up.

- ([`b1a0162`](https://github.com/russmatney/dothop/commit/b1a0162)) chore: phantom camera update - Russell Matney
- ([`bf1a5ca`](https://github.com/russmatney/dothop/commit/bf1a5ca)) feat: working event-y save-game feature - Russell Matney

  > The final change was to drop the reference property in favor of a string
  > entity_id. It's much weaker but it actually works. I suspect the
  > deserialized reference type was coming out as a string? Not really sure
  > what happened. A lingering concern is events failing to deserialize -
  > deleting the property seemed to break the deserialization :/
  > 
  > Anyway, happy to move forward with this for now.


### 29 Jan 2024

- ([`58ee70d`](https://github.com/russmatney/dothop/commit/58ee70d)) wip: more event-save-game refactor pseudo code - Russell Matney
- ([`4eb262a`](https://github.com/russmatney/dothop/commit/4eb262a)) wip: create events and sub-event categories - Russell Matney

  > A bunch of pandora entities and more implementation in place.

- ([`f91b2a1`](https://github.com/russmatney/dothop/commit/f91b2a1)) wip: breaks everything, mid-savegame refactor - Russell Matney
- ([`7e38f40`](https://github.com/russmatney/dothop/commit/7e38f40)) fix: free orphan nodes after test run - Russell Matney
- ([`c495ebf`](https://github.com/russmatney/dothop/commit/c495ebf)) chore: looser unit test on initial data - Russell Matney

  > It's enough to ensure it's playable

- ([`2fac169`](https://github.com/russmatney/dothop/commit/2fac169)) feat: switch space theme player to the goal-star - Russell Matney
- ([`6452861`](https://github.com/russmatney/dothop/commit/6452861)) fix: this puzzle was impossible - Russell Matney

  > ought to impl a solver to be sure this doesn't happen on accident.

- ([`a45b174`](https://github.com/russmatney/dothop/commit/a45b174)) fix: parser adding empty levels b/c of blank lines - Russell Matney

  > I'd solved this in dino's parser, finally hit it here.

- ([`fa5738f`](https://github.com/russmatney/dothop/commit/fa5738f)) note: big todo comment add re: data migrations - Russell Matney

  > I added 3 new puzzle sets, but they aren't showing up in game b/c the
  > save-game code only fetches puzzle_sets that were saved.
  > 
  > I'm realizing it'd be better to save user events than to save some
  > specific state of the data - it'll be simpler to have a list of events
  > like 'completed-puzzle-set {set=FALL}' that can be used to recreate a
  > working state - that'll be able to be reapplied to updated data, which
  > should reduce migration complexity. Plus those events will probably be
  > useful for other things, like achievements and records and such.

- ([`f5f0e07`](https://github.com/russmatney/dothop/commit/f5f0e07)) feat: rough intro puzzles for winter, spring, summer - Russell Matney

### 28 Jan 2024

- ([`4290026`](https://github.com/russmatney/dothop/commit/4290026)) fix: delete spring/summer *.import, resave all scenes - Russell Matney

  > Kind of a PITA - it seems like the editor uses paths to find assets, but
  > the game uses the uids, which were wrong b/c of my copy-pasting. yuck!

- ([`c6a28ed`](https://github.com/russmatney/dothop/commit/c6a28ed)) wip: spring and summer themes - Russell Matney

  > Feels like these should be working, but they're showing the winter theme
  > instead... no idea why

- ([`5733e71`](https://github.com/russmatney/dothop/commit/5733e71)) feat: winter theme, space and fall theme goal cleanups - Russell Matney

  > plus some new asteroid art


### 25 Jan 2024

- ([`a4002f6`](https://github.com/russmatney/dothop/commit/a4002f6)) fix: these settings seem to toggle when opened on mac - Russell Matney
- ([`f89366c`](https://github.com/russmatney/dothop/commit/f89366c)) fix: drop mac notif approach - Russell Matney

  > Not working that great, annoying when it crashes


### 24 Jan 2024

- ([`a4a46bd`](https://github.com/russmatney/dothop/commit/a4a46bd)) style: main menu cleanup, button focus styles fix - Russell Matney
- ([`e771a42`](https://github.com/russmatney/dothop/commit/e771a42)) feat: reset save data in options panel - Russell Matney
- ([`2a3c681`](https://github.com/russmatney/dothop/commit/2a3c681)) chore: misc notes and clean up - Russell Matney
- ([`a346e96`](https://github.com/russmatney/dothop/commit/a346e96)) test: checking that new properties don't break serialization - Russell Matney

  > I looked in pandora briefly for coverage for a case like this, and
  > pulled a test from there to work from.

- ([`616c417`](https://github.com/russmatney/dothop/commit/616c417)) test: basic savegame roundtrip - Russell Matney

  > Still a problem to solve here - how to make sure updated code/entities
  > aren't breaking existing save games. basically db migrations :/

- ([`10b6f73`](https://github.com/russmatney/dothop/commit/10b6f73)) feat: basic Store usage tests - Russell Matney

  > Basic tests for fetching/unlocking puzzle_sets, and fetching themes.

- ([`12fcd0e`](https://github.com/russmatney/dothop/commit/12fcd0e)) feat: unlocking the next puzzle-set when completing the previous - Russell Matney

  > Save/Load seems to be working! These puzzles are too hard to test tho.

- ([`535f473`](https://github.com/russmatney/dothop/commit/535f473)) feat: impl saveGame (untested) - Russell Matney

  > Reading and writing jsonified data to/from disk, and
  > serializing/deserializing it in the Store.

- ([`32bf1e0`](https://github.com/russmatney/dothop/commit/32bf1e0)) feat: basic Store impl with puzzle_sets and themes - Russell Matney
- ([`627770c`](https://github.com/russmatney/dothop/commit/627770c)) refactor: move game, levelGen, puzzle into puzzle/* - Russell Matney

  > And drop the 'DotHop' naming prefix.


### 23 Jan 2024

- ([`0fedd7e`](https://github.com/russmatney/dothop/commit/0fedd7e)) wip: towards savegame feats - Russell Matney
- ([`b3186f1`](https://github.com/russmatney/dothop/commit/b3186f1)) refactor: move parsers to parse - Russell Matney
- ([`56c6274`](https://github.com/russmatney/dothop/commit/56c6274)) feat: disable puzzle sets that aren't 'unlocked' - Russell Matney
- ([`9271706`](https://github.com/russmatney/dothop/commit/9271706)) feat: add puzzle set icon to puzzle list container - Russell Matney

  > It's something.

- ([`1a396ae`](https://github.com/russmatney/dothop/commit/1a396ae)) refactor: rename DotHopPuzzleSet -> PuzzleSet - Russell Matney

  > Also add an icon_texture to the PuzzleSet entity

- ([`a199000`](https://github.com/russmatney/dothop/commit/a199000)) feat: world map showing grid of puzzles per puzzle set - Russell Matney
- ([`ee56e68`](https://github.com/russmatney/dothop/commit/ee56e68)) feat: world map gui layout - Russell Matney

  > Rearranges and adds a floating list to be filled with per puzzle-set puzzles.

- ([`8969864`](https://github.com/russmatney/dothop/commit/8969864)) chore: update gdunit - Russell Matney
- ([`5128915`](https://github.com/russmatney/dothop/commit/5128915)) chore: set some gdunit config - Russell Matney

  > Trying to get these tests actually running


### 22 Jan 2024

- ([`9391cc0`](https://github.com/russmatney/dothop/commit/9391cc0)) refactor: rename NaviButtonList -> ButtonList - Russell Matney

  > Dropping this namespace, it's not helping much

- ([`366204e`](https://github.com/russmatney/dothop/commit/366204e)) feat: add new themes/styles to pause menu - Russell Matney

  > Also fix some broken worldmap/menu paths.

- ([`4ff578c`](https://github.com/russmatney/dothop/commit/4ff578c)) feat: world map recenters based on button focus - Russell Matney

  > Not too bad!

- ([`c53521a`](https://github.com/russmatney/dothop/commit/c53521a)) feat: basic position and scale tween for zoom effect - Russell Matney
- ([`b3ae8c6`](https://github.com/russmatney/dothop/commit/b3ae8c6)) feat: basic 2d world map adjusting to assigned marker - Russell Matney

  > Now to connect this to the button focus events

- ([`0e56f02`](https://github.com/russmatney/dothop/commit/0e56f02)) feat: red, blue buttons and a PaperHeroLabelTheme - Russell Matney

  > Getting the hang of theming...i think

- ([`cfda7c9`](https://github.com/russmatney/dothop/commit/cfda7c9)) fix: scale up base 9-patch textures - Russell Matney

  > Scaling these up allows the corners of the textures to scale as well,
  > which gives them the pixellated character we've been missing.

- ([`5d47b56`](https://github.com/russmatney/dothop/commit/5d47b56)) feat: controls panel styles - green edit button, paper label - Russell Matney
- ([`f0b124b`](https://github.com/russmatney/dothop/commit/f0b124b)) feat: green button scene with theme, world map buttons a bit nicer - Russell Matney
- ([`17d76e6`](https://github.com/russmatney/dothop/commit/17d76e6)) feat: paper panel theme - Russell Matney

  > Adding some paper bg - still not sure how to scale these 9 patch
  > corners, and the colors aren't working very well, but :shrug: it's more
  > interesting than it was.

- ([`aa8d0f5`](https://github.com/russmatney/dothop/commit/aa8d0f5)) feat: option menu using green board controls bg - Russell Matney

  > Experimenting with themes and nine-patch rects. Colors not working, but
  > things are a bit more interesting at least.

- ([`75e1b52`](https://github.com/russmatney/dothop/commit/75e1b52)) asset: add pixelfrog treasure-hunters for ui detail - Russell Matney

  > https://pixelfrog-assets.itch.io/treasure-hunters

- ([`998b978`](https://github.com/russmatney/dothop/commit/998b978)) refactor: cleaner menu naming - Russell Matney

  > No need to specify DotHop on everything now that we're split from dino.

- ([`fb307a6`](https://github.com/russmatney/dothop/commit/fb307a6)) refactor: create menu button and hero themes - Russell Matney

  > Rather than impling components with theme overwrites, we create some
  > themes to be more easily applied to one-off buttons/labels.

- ([`cd4f2f1`](https://github.com/russmatney/dothop/commit/cd4f2f1)) chore: update phantom camera - Russell Matney

### 21 Jan 2024

- ([`e9ebcb9`](https://github.com/russmatney/dothop/commit/e9ebcb9)) fix: no need to be so specific here - Russell Matney

### 19 Jan 2024

- ([`df9aaba`](https://github.com/russmatney/dothop/commit/df9aaba)) wip: mute buttons in controls - Russell Matney
- ([`5d7a645`](https://github.com/russmatney/dothop/commit/5d7a645)) wip: title screen, world map, controls tweaks and logo add - Russell Matney

### 18 Jan 2024

- ([`e9ac0ec`](https://github.com/russmatney/dothop/commit/e9ac0ec)) readme: add youtube badge - Russell Matney

### 16 Jan 2024

- ([`6794136`](https://github.com/russmatney/dothop/commit/6794136)) fix: re-order, simplify controls - Russell Matney

  > - just r for restart/reset (drop shift)
  > - move z ahead of ctrl-z for undo (cleaner when it shows up in the ui)

- ([`593bcaa`](https://github.com/russmatney/dothop/commit/593bcaa)) fix: better controls layout - Russell Matney

  > Plus some helpers to make it easier to edit this controls view (b/c
  > InputHelper is not a tool script).

- ([`b7570b6`](https://github.com/russmatney/dothop/commit/b7570b6)) feat: cleaner controls UI - Russell Matney

  > Only show the primary key for the current device, and update when the
  > device changes.

- ([`fd5dd56`](https://github.com/russmatney/dothop/commit/fd5dd56)) fix: display close button on jumbotron - Russell Matney

  > Also cleans up some device/input code. Could probably clean up the
  > controls panel a bit as well, to show only the active device and primary
  > button for each control.

- ([`481b5e2`](https://github.com/russmatney/dothop/commit/481b5e2)) feat: HUD control hints showing actual controls - Russell Matney

  > And moving between controller and keyboards settings!

- ([`6acc73f`](https://github.com/russmatney/dothop/commit/6acc73f)) fix: return to main from pause menu, drop empty levels - Russell Matney

  > Updates win condition to just return to main for now.

- ([`03b822e`](https://github.com/russmatney/dothop/commit/03b822e)) fix: remove noisey error message - Russell Matney
- ([`7e8256a`](https://github.com/russmatney/dothop/commit/7e8256a)) feat: some basic focus handling, nav to/from controls - Russell Matney

  > Controls Panel is only accessible from the main menu for now.

- ([`92035dd`](https://github.com/russmatney/dothop/commit/92035dd)) chore: i was dead wrong here - Russell Matney

  > Will have to come back and clean up the syntax to use the actual
  > constants.

- ([`ce14eba`](https://github.com/russmatney/dothop/commit/ce14eba)) feat: basic (tho buggy) control editing in place - Russell Matney
- ([`672784c`](https://github.com/russmatney/dothop/commit/672784c)) feat: displaying joypad inputs for controls - Russell Matney

  > Hardcodes a mapping from input joypad events (buttons and motions) to
  > controller axes and vexed's EnterInput font characters.

- ([`d940ab6`](https://github.com/russmatney/dothop/commit/d940ab6)) fix: stretch mode viewport - same view at different screen sizes - Russell Matney
- ([`34dcdb4`](https://github.com/russmatney/dothop/commit/34dcdb4)) feat: dynamically drop camera follow nodes - Russell Matney
- ([`1c7f435`](https://github.com/russmatney/dothop/commit/1c7f435)) chore: drop old camera plugin from dino - Russell Matney
- ([`99db180`](https://github.com/russmatney/dothop/commit/99db180)) feat: integrate phantom camera - very pleased! - Russell Matney
- ([`dc90734`](https://github.com/russmatney/dothop/commit/dc90734)) addon: add and enable phantom_camera - Russell Matney

### 15 Jan 2024

- ([`bfc6b46`](https://github.com/russmatney/dothop/commit/bfc6b46)) feat: latin kbd inputs, better action icon spacing - Russell Matney

  > wip: placeholders for joy button/motion inputs

- ([`94ff452`](https://github.com/russmatney/dothop/commit/94ff452)) feat: controls panel showing keyboard controls - Russell Matney
- ([`54f1740`](https://github.com/russmatney/dothop/commit/54f1740)) feat: ActionInputIcon label - Russell Matney

  > Set input_text to map to one of Vexed's Enter Input font characters.

- ([`fd09024`](https://github.com/russmatney/dothop/commit/fd09024)) wip: creating action rows per action - Russell Matney
- ([`a0cc51e`](https://github.com/russmatney/dothop/commit/a0cc51e)) chore: update vexed EnterInput font - Russell Matney

  > https://v3x3d.itch.io/enter-input

- ([`07879f1`](https://github.com/russmatney/dothop/commit/07879f1)) feat: dot hop steam badge, CI badges - Russell Matney
- ([`d7fe061`](https://github.com/russmatney/dothop/commit/d7fe061)) chore: update gdunit to latest - Russell Matney
- ([`aa77dae`](https://github.com/russmatney/dothop/commit/aa77dae)) wip: controls panel begins - Russell Matney
- ([`a764c8d`](https://github.com/russmatney/dothop/commit/a764c8d)) feat: enable input_helper, reduce noisey log - Russell Matney
- ([`994857a`](https://github.com/russmatney/dothop/commit/994857a)) addon: add godot input_helper - Russell Matney
- ([`55fe3d4`](https://github.com/russmatney/dothop/commit/55fe3d4)) fix: drop dino menu button - Russell Matney
- ([`c778032`](https://github.com/russmatney/dothop/commit/c778032)) chore: kill and ignore build-output dir content - Russell Matney
- ([`a041a58`](https://github.com/russmatney/dothop/commit/a041a58)) refactor: update boxart export to latest - Russell Matney

  > This was improved while creating the aseprite scripting devlog, so we
  > pull back some of those improvements here. Ideally these helpers would
  > get some shared package... i'm sitting on the name of whatever that is
  > for now.

- ([`77f0808`](https://github.com/russmatney/dothop/commit/77f0808)) chore: aseprite import meta files - Russell Matney
- ([`fde3da6`](https://github.com/russmatney/dothop/commit/fde3da6)) refactor: move bb code from src to bb dir - Russell Matney

  > A bit cleaner, and probably better to separate these things.

- ([`edf3502`](https://github.com/russmatney/dothop/commit/edf3502)) fix: set_focus when main menu launches - Russell Matney

### 14 Jan 2024

- ([`2d81df7`](https://github.com/russmatney/dothop/commit/2d81df7)) chore: add source-available copyright notice - Russell Matney

### 12 Jan 2024

- ([`dd49eca`](https://github.com/russmatney/dothop/commit/dd49eca)) fix: update boxart gen to support alternate base files - Russell Matney

  > Some of these are bg-less, others are logo-less.
  > 
  > We could instead add some toggling for bg/logo visibility to the script,
  > but this was quicker this morning.


### 11 Jan 2024

- ([`d045259`](https://github.com/russmatney/dothop/commit/d045259)) feat: resurrect HUD and updates - Russell Matney
- ([`c79145b`](https://github.com/russmatney/dothop/commit/c79145b)) feat: basic dothop web build and wip itch deploy - Russell Matney
- ([`bd741d1`](https://github.com/russmatney/dothop/commit/bd741d1)) feat: rough steam deploy, locally and via CI - Russell Matney
- ([`3950947`](https://github.com/russmatney/dothop/commit/3950947)) fix: set GODOT_BIN - Russell Matney
- ([`e123ab4`](https://github.com/russmatney/dothop/commit/e123ab4)) fix: switch to gdunit4 fix-load branch - Russell Matney
- ([`040c7fb`](https://github.com/russmatney/dothop/commit/040c7fb)) ci: run unit tests - Russell Matney
- ([`fac0c8e`](https://github.com/russmatney/dothop/commit/fac0c8e)) feat: game playable again! - Russell Matney

  > Moves Trolls to read ui_* inputs for movement rather than creating our
  > own - i think this is more typical.

- ([`2c6ea59`](https://github.com/russmatney/dothop/commit/2c6ea59)) feat: recreate puzzle sets and themes via pandora - Russell Matney
- ([`06bf7ee`](https://github.com/russmatney/dothop/commit/06bf7ee)) feat: start input map with basic pause button - Russell Matney
- ([`c8b088e`](https://github.com/russmatney/dothop/commit/c8b088e)) fix: delete recursive pandora code, game starts up now - Russell Matney

  > It appears i accidentally imported pandora into itself...

- ([`32edbfe`](https://github.com/russmatney/dothop/commit/32edbfe)) chore: pull notifs into core, drop hood - Russell Matney

  > Also pulls Puzz classes into src/, drops puzz.

- ([`95ded41`](https://github.com/russmatney/dothop/commit/95ded41)) refactor: move naviButtonList to ui/ButtonList - Russell Matney
- ([`d36c7b3`](https://github.com/russmatney/dothop/commit/d36c7b3)) chore: trim and consolidate Navi in core - Russell Matney
- ([`fe95683`](https://github.com/russmatney/dothop/commit/fe95683)) chore: move jumbotron from quest to core, drop quest addon - Russell Matney
- ([`1af5d3f`](https://github.com/russmatney/dothop/commit/1af5d3f)) refactor: move Trolley to core/Trolls and static class - Russell Matney
- ([`46173d8`](https://github.com/russmatney/dothop/commit/46173d8)) wip: drop a bunch of core and trolley - Russell Matney
- ([`91495c4`](https://github.com/russmatney/dothop/commit/91495c4)) imports: pull in Hood and Quest for notifs and jumbotron - Russell Matney

  > It's becoming clear these dino addons are kind of crazy.

- ([`b42d588`](https://github.com/russmatney/dothop/commit/b42d588)) chore: drop 'Hotel' usage - Russell Matney
- ([`1e9f17b`](https://github.com/russmatney/dothop/commit/1e9f17b)) import: addons and dothop code from dino - Russell Matney

  > A mess to be hacked down to size in following commits.

- ([`256bb55`](https://github.com/russmatney/dothop/commit/256bb55)) chore: gitignore, some readme badges - Russell Matney
- ([`6c800fd`](https://github.com/russmatney/dothop/commit/6c800fd)) chore: some modified assets, and final boxart script touches - Russell Matney

### 10 Jan 2024

- ([`ae7704f`](https://github.com/russmatney/dothop/commit/ae7704f)) addons: add gdfxr and enable it - Russell Matney
- ([`7d96241`](https://github.com/russmatney/dothop/commit/7d96241)) chore: bunch of aseprite auto-imports - Russell Matney
- ([`78c99da`](https://github.com/russmatney/dothop/commit/78c99da)) addons: enable pandora, gdunit, aseprite-wizard - Russell Matney
- ([`443fbce`](https://github.com/russmatney/dothop/commit/443fbce)) addons: add AsepriteWizard - Russell Matney
- ([`8980264`](https://github.com/russmatney/dothop/commit/8980264)) addons: add gdunit4 - Russell Matney
- ([`99d504d`](https://github.com/russmatney/dothop/commit/99d504d)) addons: add pandora - Russell Matney
- ([`bb82ee8`](https://github.com/russmatney/dothop/commit/bb82ee8)) init: create godot project, set icon + bootsplash - Russell Matney
- ([`4689e5a`](https://github.com/russmatney/dothop/commit/4689e5a)) feat: dothop boxart aseprite and pngs - Russell Matney
- ([`729f7c0`](https://github.com/russmatney/dothop/commit/729f7c0)) feat: impl export-all-boxart helper - Russell Matney
- ([`fdd09f1`](https://github.com/russmatney/dothop/commit/fdd09f1)) feat: add center_sprite, cast tonumber, support wide_base_logo - Russell Matney
- ([`2c8ea09`](https://github.com/russmatney/dothop/commit/2c8ea09)) feat: resizeSprite with lockRatio, then crop back down - Russell Matney

  > Won't work for all sizes, but it's working for my current base image and
  > the main-capsule. Ready to run for all of them!

- ([`aab5107`](https://github.com/russmatney/dothop/commit/aab5107)) feat: refactor into proper canvas resize - Russell Matney

  > Now extending the canvas without modifying the sprite at all.

- ([`2204c85`](https://github.com/russmatney/dothop/commit/2204c85)) wip: basic resizing via bb godot task - Russell Matney

  > next up: maintaining aspect ratio

- ([`8d96628`](https://github.com/russmatney/dothop/commit/8d96628)) feat: basic resize_canvas script working - Russell Matney
- ([`7417f1d`](https://github.com/russmatney/dothop/commit/7417f1d)) feat: base-logo, raw concept art, boxart gen wip refactor - Russell Matney

### 4 Jan 2024

- ([`2e6a1e4`](https://github.com/russmatney/dothop/commit/2e6a1e4)) wip: towards generating aseprite files - Russell Matney
- ([`2e8cdb5`](https://github.com/russmatney/dothop/commit/2e8cdb5)) chore: pull in bb helpers from dino/bb-godot - Russell Matney

  > Some renaming and cutting down - probably most of this should live in a
  > library somewhere, but it's not much.
