# CHANGELOG


## Untagged


## v1.1.3


### 27 Jul 2025

- ([`d1bf6732`](https://github.com/russmatney/dothop/commit/d1bf6732)) chore: update version number - Russell Matney
- ([`c36c892a`](https://github.com/russmatney/dothop/commit/c36c892a)) docs: changelog update - Russell Matney
- ([`53ef157b`](https://github.com/russmatney/dothop/commit/53ef157b)) fix: disconnect stats-update signals from icons - Russell Matney

  > Prevents a noisey error message x 12

- ([`7e975c8b`](https://github.com/russmatney/dothop/commit/7e975c8b)) fix: prefer to get theme from passed world instead of puzzle_node - Russell Matney

  > The puzzle_node is generally being removed anyway.
  > 
  > This func really needs some unit tests to capture all it's use-cases. Or
  > maybe we need to break out a few versions of it?

- ([`0f19782b`](https://github.com/russmatney/dothop/commit/0f19782b)) fix: update stats in-place when analysis completes - Russell Matney

  > We were missing the tracking of the current puzzle_node.

- ([`8c9fb658`](https://github.com/russmatney/dothop/commit/8c9fb658)) fix: first puzzle complete puzz_num fix - Russell Matney

  > Plus hopefully guarding against a sometimes crash on reset.


### 26 Jul 2025

- ([`461c3bb8`](https://github.com/russmatney/dothop/commit/461c3bb8)) fix: use Pumpkins in fall theme - Russell Matney

  > The fall theme has grown unreadable
  > this just swaps the pumpkin for the leaf
  > we can come back to expanding the leaf-focused world later

- ([`cdb46bf5`](https://github.com/russmatney/dothop/commit/cdb46bf5)) feat: move PuzzleDefs to Resources - Russell Matney

  > supporting serializing puzzle_defs might make it baked-in to skip
  > re-analyzing in-game.

- ([`efc63726`](https://github.com/russmatney/dothop/commit/efc63726)) refactor: rename GameScene -> WorldScene - Russell Matney

  > in some sense this is a scene to support the game implied by the
  > worldmap itself - perhaps all of this is 'classic-mode'. I'm optimistic
  > about 'modes' being composable - probably toggling them while playing is
  > a worthy ambition, design-wise.

- ([`53733e9d`](https://github.com/russmatney/dothop/commit/53733e9d)) fix: simpler on-win modes, animate 'focused' icons in puzzle editor - Russell Matney

  > It's not super clear what is focused right now, but this is a step
  > towards inputs getting lost/consumed by the ui.

- ([`8efe2ae4`](https://github.com/russmatney/dothop/commit/8efe2ae4)) feat: add TreadmillMode to rebuild the puzzle node on-win - Russell Matney

  > A quick 'mode' that just rebuilds whatever puzzle emits 'win'.

- ([`7722e24d`](https://github.com/russmatney/dothop/commit/7722e24d)) ui: update 'puzzle browser' btn to just 'puzzles' - Russell Matney

  > Much more inviting.

- ([`a230b8ea`](https://github.com/russmatney/dothop/commit/a230b8ea)) wip: logging the thread_count when it exists - Russell Matney

  > Looks like we're leaking a thread :cry:

- ([`c79be2b9`](https://github.com/russmatney/dothop/commit/c79be2b9)) fix: connect_deferred b/c animations need the main thread - Russell Matney

  > An interesting consequence of threads + event-bus.

- ([`8a70687a`](https://github.com/russmatney/dothop/commit/8a70687a)) chore: misc code clean up - Russell Matney

  > Breaking out some helpers to get a better sense of the
  > puzzle-set-editor.

- ([`d6701f7e`](https://github.com/russmatney/dothop/commit/d6701f7e)) refactor: PlayerInputHandler broken out of puzzle_node - Russell Matney

  > Arriving at some stronger systems and well-componentized things here.

- ([`9779f143`](https://github.com/russmatney/dothop/commit/9779f143)) fix: wait for all pending player moves to finish - Russell Matney

  > player_move_finished() was being called by the second (or third)-to-last
  > move in each puzzle (if you moved quickly), causing the on_win() to
  > emit/fire before the final-move animation had actually completed.
  > 
  > This adds a counter to inc/dec any inflight player moves - the last one
  > should dec back to zero.
  > 
  > Maybe there are some combo points or juice to award getting this
  > count up?

- ([`7df2fd6b`](https://github.com/russmatney/dothop/commit/7df2fd6b)) refactor: move classicMode to eventbus, drop PuzzleNodeExtender - Russell Matney
- ([`4c42b41a`](https://github.com/russmatney/dothop/commit/4c42b41a)) refactor: event-based theme changing - Russell Matney

  > a much nicer implementation!
  > Why should the ThemeButtonList 'call-down' to the game or puzzle_node?

- ([`40d5f61c`](https://github.com/russmatney/dothop/commit/40d5f61c)) refactor: move gameMusic, puzzleTransitions off of PuzzleNodeExtender - Russell Matney

  > the deferred 'exiting' event vs the attached and opt-in awaited
  > pre_remove_hook callables are nuanced. i wonder if i could simplify it
  > somehow, or if the hooks will ever need to be sequenced

- ([`99a6a62e`](https://github.com/russmatney/dothop/commit/99a6a62e)) feat: introduce Events.puzzle_node, GameSounds as first consumer - Russell Matney

  > Moving away from inheritance here - the puzzleNodeExtenders are a little
  > bit drier, but they are not composable with other things (e.g. UI
  > buttons for changing the theme).
  > 
  > Maybe this setup could be dried up with a helper expecting a
  > ready_event, a setup_node, and a list_nodes input?

- ([`9a48d9b2`](https://github.com/russmatney/dothop/commit/9a48d9b2)) fix: rebuild_puzzle class_mode fixup - Russell Matney

  > rebuild_puzzle has some crazy use-case combination - and after i got all
  > the complexity split out in the last puzzleScene refactor :smh:
  > 
  > it's something like container/world/num OR puzzle_node alone OR just a
  > new theme... could really use some unit tests and better val-sourcing
  > from the input options.

- ([`8cc65bc7`](https://github.com/russmatney/dothop/commit/8cc65bc7)) fix: don't analyze all puzzle sets at launch - Russell Matney

  > Removes some on-ready autoload puzzle analysis noise.

- ([`334489aa`](https://github.com/russmatney/dothop/commit/334489aa)) rename: lean into FEN from chess notation - Russell Matney

  > Also shares a thought re: deterministic puzzle ids

- ([`0b4d4094`](https://github.com/russmatney/dothop/commit/0b4d4094)) fix: PuzzleAnalyzer manage inflight requests - Russell Matney

  > The inflight bits were only half-implemented here.

- ([`c129c5e2`](https://github.com/russmatney/dothop/commit/c129c5e2)) fix: puzzle cache warm-up fix - Russell Matney

  > append_array to finally flatten these puzzles.

- ([`91a29d8d`](https://github.com/russmatney/dothop/commit/91a29d8d)) feat: Events, PuzzleStore, PuzzleAnalyzer autoloads - Russell Matney

  > fun PuzzleSetEditor bug - puzzle nodes are stacking infinitely


### 25 Jul 2025

- ([`e16d8c0e`](https://github.com/russmatney/dothop/commit/e16d8c0e)) fix: make it more clear this is an external link - Russell Matney
- ([`5cd0f9b5`](https://github.com/russmatney/dothop/commit/5cd0f9b5)) feat: add links to drg site, playtester site - Russell Matney
- ([`67f0d68a`](https://github.com/russmatney/dothop/commit/67f0d68a)) chore: misc import cruft - Russell Matney
- ([`8890c376`](https://github.com/russmatney/dothop/commit/8890c376)) feat: add changelog button to main menu - Russell Matney

  > You can now open up DotHop's changelog (on the docs site) from the main
  > menu.

- ([`90de9035`](https://github.com/russmatney/dothop/commit/90de9035)) deps: update log.gd - Russell Matney
- ([`01b8b6e3`](https://github.com/russmatney/dothop/commit/01b8b6e3)) deps: update phantom cam - Russell Matney
- ([`613f6160`](https://github.com/russmatney/dothop/commit/613f6160)) deps: update gdunit - Russell Matney
- ([`10c62582`](https://github.com/russmatney/dothop/commit/10c62582)) fix: serialize parsedGame on PuzzleSetData - Russell Matney

  > Exported games were crashing b/c the .puzz files were not parsable in
  > exported builds - this serialization is a step i hesitated to take when
  > first implementing the .puzz importer, but it turned out to be pretty
  > easy. We could probably serialize the PuzzleDefs and maybe the analysis
  > too... hmmmmmm.

- ([`566ab45c`](https://github.com/russmatney/dothop/commit/566ab45c)) feat: hide keyboard/controller comps when on mobile - Russell Matney

  > grateful for feature tags here.
  > 
  > Hides the editable controls in the ControlsPanel, and hide/show the
  > buttons/hints based on mobile in the HUD.

- ([`a2b0ae49`](https://github.com/russmatney/dothop/commit/a2b0ae49)) refactor: separating mobile/mouse and keyboard/controller hud buttons/hints - Russell Matney
- ([`64800193`](https://github.com/russmatney/dothop/commit/64800193)) jumbotron: click anywhere to dismiss, drop button input help - Russell Matney
- ([`8141b31e`](https://github.com/russmatney/dothop/commit/8141b31e)) chore: drop old camera, rearrange some scripts/scenes - Russell Matney

## v1.1.2


### 24 Jul 2025

- ([`2350c823`](https://github.com/russmatney/dothop/commit/2350c823)) chore: update version number - Russell Matney
- ([`2078928c`](https://github.com/russmatney/dothop/commit/2078928c)) docs: update changelog - Russell Matney
- ([`7cd76f90`](https://github.com/russmatney/dothop/commit/7cd76f90)) fix: prevent crash when assigning null to int - Russell Matney

  > :eyeroll:

- ([`f7c16afb`](https://github.com/russmatney/dothop/commit/f7c16afb)) fix: await puzzle transitions - Russell Matney

  > The transitions were not running for several reasons - this refactors to
  > support awaiting signals before removing the puzzle node from the
  > container.

- ([`bc9e2ae8`](https://github.com/russmatney/dothop/commit/bc9e2ae8)) refactor: intro PuzzleNodeExtender (name pending) - Russell Matney

  > Refactors more of the GameScene into smaller PuzzleNodeExtender
  > Components - these components are bits of logic around puzzle features
  > and lifecycle. The DotHopPuzzle now features a rebuild_puzzle(opts)
  > helper for creating and re-creating-with-minimal-input the puzzle node
  > itself, which removes a bunch of responsibility from the puzzle node
  > container/parent.

- ([`d36dafcc`](https://github.com/russmatney/dothop/commit/d36dafcc)) refactor: pull GameMusic and HUD refs out of GameScene - Russell Matney

  > Note this drops the puzzle-progress panel. (it's still there, just
  > depends on a HUD reference at the moment)

- ([`a9e2470a`](https://github.com/russmatney/dothop/commit/a9e2470a)) refactor: break sounds out of game scene - Russell Matney

  > love this reusable, self-contained node pattern!

- ([`e6416660`](https://github.com/russmatney/dothop/commit/e6416660)) wip: add return to main, clean up threads on nav - Russell Matney

  > This thread clean up blocks navigation until analysis is done! but
  > doesn't leak threads. TODO write a PuzzleAnalyzer autoload to own these
  > threads so we don't block in exit_tree like this.

- ([`79646a79`](https://github.com/russmatney/dothop/commit/79646a79)) feat: reasonable layout for puzzles in puzz-browser - Russell Matney

  > Tweaks the phantom-camera group follow margins to keep even large puzzles fully
  > in view

- ([`9c7de495`](https://github.com/russmatney/dothop/commit/9c7de495)) feat: drop in phantom camera - Russell Matney

  > Moving to a more fully-featured phantom camera - this'll at least let us
  > drop our scrappy camera positioning/centering code, which doesn't seem
  > to be working anyway.

- ([`3c862cc0`](https://github.com/russmatney/dothop/commit/3c862cc0)) deps: add phantom camera - Russell Matney

### 23 Jul 2025

- ([`6ba03f8c`](https://github.com/russmatney/dothop/commit/6ba03f8c)) fix: drop parameterized test setup - Russell Matney

  > This seems to have been crashing somewhere in gdunit, and we don't need
  > it anyway.

- ([`1e2df743`](https://github.com/russmatney/dothop/commit/1e2df743)) chore: better log.gd colors - Russell Matney
- ([`e655fb2d`](https://github.com/russmatney/dothop/commit/e655fb2d)) chore: update all GdUnit uids after update - Russell Matney
- ([`e521560e`](https://github.com/russmatney/dothop/commit/e521560e)) deps: update log.gd - Russell Matney
- ([`dfe95229`](https://github.com/russmatney/dothop/commit/dfe95229)) deps: update pandora - Russell Matney
- ([`6d447334`](https://github.com/russmatney/dothop/commit/6d447334)) deps: update input helper - Russell Matney
- ([`c338ecd7`](https://github.com/russmatney/dothop/commit/c338ecd7)) deps: update gdunit (uid-re-adds coming later) - Russell Matney
- ([`d82a483f`](https://github.com/russmatney/dothop/commit/d82a483f)) deps: update AsepriteWizard - Russell Matney

### 22 Jul 2025

- ([`49914026`](https://github.com/russmatney/dothop/commit/49914026)) fix: correct fall theme, fix camera zoom - Russell Matney

  > Time to bring in phantom camera, i think

- ([`8ebd1f63`](https://github.com/russmatney/dothop/commit/8ebd1f63)) feat: puzzle browser running analysis in the background - Russell Matney

  > No more blocking-forever to see the puzzle shapes! yay!

- ([`74f1d7bc`](https://github.com/russmatney/dothop/commit/74f1d7bc)) feat: run puzzle data export in background - Russell Matney

  > Uses threads to prevent locking the editor while the puzzle data export
  > runs.

- ([`f2eb65a9`](https://github.com/russmatney/dothop/commit/f2eb65a9)) fix: restore tests! - Russell Matney

  > - Skipping multi-hopper analysis (currently this loops forever)
  > - adding test puzzle_nodes to the tree to prevent crashes
  > - moving back to including a PuzzleState.Cell at every coord
  > - restore a poorly ported store test

- ([`5b21f558`](https://github.com/russmatney/dothop/commit/5b21f558)) fix: no more log.gd [/color] closing tags - Russell Matney

  > Apparently it's unreasonable to print bbcode with nested square braces,
  > which is unfortunate. Until i can dig in more, this swaps the array
  > wrappers with paren-pipes: (| |). Not sure i like them, but at least
  > rainbow delims are working.

- ([`bf4015a8`](https://github.com/russmatney/dothop/commit/bf4015a8)) feat: naive (untested) log.gd rainbow delimiters - Russell Matney

  > Quick feature that is great for readability! Will port this back to
  > log.gd soon.


### 21 Jul 2025

- ([`831f30c1`](https://github.com/russmatney/dothop/commit/831f30c1)) chore: update changelog - Russell Matney

  > Now with all included tags - I'd neglected to push the v1.1 tag before


### 20 Jul 2025

- ([`2bf5f6af`](https://github.com/russmatney/dothop/commit/2bf5f6af)) rel: bump to v1.1.1 - Russell Matney

  > Updates the changelog, which unfortunately drops the v1.1.0 tag b/c i
  > forgot to push the tag on my other machine :eyeroll:


## v1.1.1


### 20 Jul 2025

- ([`2d9138b2`](https://github.com/russmatney/dothop/commit/2d9138b2)) wip: toying with camera _ready puzzle-node lookup - Russell Matney

  > It'd be nice if the camera could grab the puzzle-node without needing
  > setup elsewhere


### 19 Jul 2025

- ([`de701245`](https://github.com/russmatney/dothop/commit/de701245)) feat: link to puzzle browser on main menu - Russell Matney
- ([`d0b8d3da`](https://github.com/russmatney/dothop/commit/d0b8d3da)) feat: support a fallback_world on the puzzle node - Russell Matney
- ([`e4a77c07`](https://github.com/russmatney/dothop/commit/e4a77c07)) refactor: pull theme_data from world directly - Russell Matney

  > Moving away from the theme pandora entity, which should shrink down.
  > 
  > Also adds an AllTheDots theme_data and a new world called Extra Extra,
  > which includes a few more puzzles, including a few 2 hoppers and the
  > extra difficult one from cameron

- ([`db6a485f`](https://github.com/russmatney/dothop/commit/db6a485f)) chore: drop demo flag - Russell Matney
- ([`068c415a`](https://github.com/russmatney/dothop/commit/068c415a)) chore: drop unused next_set/world field - Russell Matney
- ([`20558e77`](https://github.com/russmatney/dothop/commit/20558e77)) refactor: puzzle_set -> world, plus event renaming - Russell Matney

  > Maybe dropping save/existing events this way?

- ([`55e334c5`](https://github.com/russmatney/dothop/commit/55e334c5)) rename: PuzzleSet -> PuzzleWorld - Russell Matney
- ([`f0ed108f`](https://github.com/russmatney/dothop/commit/f0ed108f)) chore: misc log clean up and what not - Russell Matney

  > Things back to working, now with 'GameDef'!
  > 
  > Hurting for a bit more of a refactor - we're relying on PuzzleSet
  > entities for game state/save data, when we probably want something less
  > global, and more game mode aware.
  > 
  > Plus i really want a PuzzleStore that has reasonable apis to pull
  > from. (But in what game-mode context? Is PuzzleStore game-mode dependent
  > or agnostic?)

- ([`8fed2df9`](https://github.com/russmatney/dothop/commit/8fed2df9)) refactor: move rest of GameDef into DHData, PuzzleDef - Russell Matney

  > Moved away from the extra GridCell class completely.

- ([`d8ae104e`](https://github.com/russmatney/dothop/commit/d8ae104e)) refactor: move camera code out of dothop puzzle - Russell Matney

  > Lots of complexity in the name of running the dothoppuzzle scene
  > directly. reminds me of the one-room-in-full-dungeon-map problem in
  > metsys - could write a little run-in-context helper if we need.

- ([`334749d4`](https://github.com/russmatney/dothop/commit/334749d4)) wip: game (sort of) playable again! - Russell Matney

  > Fixes the .puzz importer and reassigns psds to pandora PuzzleSets.

- ([`4d6777de`](https://github.com/russmatney/dothop/commit/4d6777de)) refactor: move other puzzle txts to .puzz, drop puzzle-set-data tres - Russell Matney
- ([`701cc5ee`](https://github.com/russmatney/dothop/commit/701cc5ee)) wip: support psd.setup, add shuffle input mapping - Russell Matney

  > The .puzz -> puzzle-set-data only saves/loads the @exported fields.
  > setup() is a quick workaround that will reparse the puzzle_defs if
  > needed.
  > 
  > We're not yet restoring the game state properly.

- ([`83d0a450`](https://github.com/russmatney/dothop/commit/83d0a450)) chore: drop game_def instance support - Russell Matney

  > Just a bunch of static funcs left now.

- ([`91167144`](https://github.com/russmatney/dothop/commit/91167144)) wip: removing game_def from PuzzleSet pandora entity - Russell Matney

  > Trying to restore the game state - looks like puzzle_set_datas don't
  > automatically load their puzzle_defs just yet.


### 18 Jul 2025

- ([`2409776f`](https://github.com/russmatney/dothop/commit/2409776f)) wip: more puzzle vs game scene ironing - Russell Matney

  > Lifts some puzzle-node signals to the game scene, cleans up a bunch of
  > signal connects. I suspect much of these can be moved to per-node
  > _ready() funcs - probably connecting signals right before add_child is
  > an anti-pattern.

- ([`60748163`](https://github.com/russmatney/dothop/commit/60748163)) wip: DotHopPuzzle clean up, and a quick reshuffle button - Russell Matney

  > warning! Things still quite broken at the moment!

- ([`52233d78`](https://github.com/russmatney/dothop/commit/52233d78)) wip: more gameDef-drop clean up - Russell Matney

  > things still quite broken in places!

- ([`6ac06032`](https://github.com/russmatney/dothop/commit/6ac06032)) wip: mid-refactor dropping GameDef completely - Russell Matney

  > Lots of things touch this, so this is a messy one. everything is broken!

- ([`f8a84dec`](https://github.com/russmatney/dothop/commit/f8a84dec)) feat: initial .puzz importer - Russell Matney

  > Refactoring puzzle parsing into an editor import plugin.

- ([`9d2b7935`](https://github.com/russmatney/dothop/commit/9d2b7935)) fix: another type cast crash - Russell Matney

### 17 Jul 2025

- ([`be359d74`](https://github.com/russmatney/dothop/commit/be359d74)) chore: some clojure clj-kondo cruft - Russell Matney
- ([`31dfa39e`](https://github.com/russmatney/dothop/commit/31dfa39e)) feat: attach world/puzzle i to puzzle datas - Russell Matney
- ([`65fc79d1`](https://github.com/russmatney/dothop/commit/65fc79d1)) feat: puzzle json now including puzzle shape and sum fields - Russell Matney
- ([`eefb5a01`](https://github.com/russmatney/dothop/commit/eefb5a01)) feat: StatLogger writing json and md puzzle data files - Russell Matney

  > A nice util for creating more accessible puzzle and json data. I expect
  > to consume the json from babashka to print docs and devlog posts.

- ([`cb670f89`](https://github.com/russmatney/dothop/commit/cb670f89)) wip: initial stat-logger via UI button - Russell Matney

### 16 Jul 2025

- ([`65fb659b`](https://github.com/russmatney/dothop/commit/65fb659b)) wip: move extra snow way level to extra - Russell Matney

  > only doing this to improve CI times.
  > 
  > We should add EXTRA as a new world after you watch/find a secret in the credits.

- ([`595e4b6d`](https://github.com/russmatney/dothop/commit/595e4b6d)) feat: ignore 'stuck-goal' choices - Russell Matney

  > players wouldn't logically choose to exit early, so we shouldn't
  > consider it a 'choice' when working with difficulty

- ([`eef16a6e`](https://github.com/russmatney/dothop/commit/eef16a6e)) chore: adds a table-like printer to support copy-pasting puzzle data - Russell Matney
- ([`697c349e`](https://github.com/russmatney/dothop/commit/697c349e)) fix: re-enable solve-all-puzzles-tests - Russell Matney
- ([`89fed8d0`](https://github.com/russmatney/dothop/commit/89fed8d0)) feat: calcing choices and turn counts per path - Russell Matney
- ([`23b4faf2`](https://github.com/russmatney/dothop/commit/23b4faf2)) wip: puzzle analysis refactor - Russell Matney

  > Adding supporting for choice and turn counts in the analysis, plus
  > getting some more useful types in here.


### 15 Jul 2025

- ([`c5085548`](https://github.com/russmatney/dothop/commit/c5085548)) feat: scale tweens on possible-move dots - Russell Matney
- ([`fee2fa8e`](https://github.com/russmatney/dothop/commit/fee2fa8e)) wip: tracking and emitting possible next moves - Russell Matney

### 14 Jul 2025

- ([`ef209a28`](https://github.com/russmatney/dothop/commit/ef209a28)) refactor: cleaner check_moves logic - Russell Matney
- ([`df573d15`](https://github.com/russmatney/dothop/commit/df573d15)) fix: update hopped-dot tracking test - Russell Matney
- ([`513ac536`](https://github.com/russmatney/dothop/commit/513ac536)) wip: refactoring into a Move monoid - Russell Matney

  > instead of a list of moves, we create one Move per hopper.


### 20 Jun 2025

- ([`c2f9eac3`](https://github.com/russmatney/dothop/commit/c2f9eac3)) wip: toying with some altered multi-hopper logic - Russell Matney
- ([`a355bbb0`](https://github.com/russmatney/dothop/commit/a355bbb0)) fix: use installed gdunit - Russell Matney
- ([`52cabaaa`](https://github.com/russmatney/dothop/commit/52cabaaa)) fix: out of bounds puzzle index fix - Russell Matney
- ([`18b732e3`](https://github.com/russmatney/dothop/commit/18b732e3)) ci: update godot-ci version - Russell Matney
- ([`400f3e38`](https://github.com/russmatney/dothop/commit/400f3e38)) fix: update gdunit action version - Russell Matney
- ([`adcdf102`](https://github.com/russmatney/dothop/commit/adcdf102)) refactor: puzzle analysis supports state-only runs - Russell Matney

  > The puzzle analysis now accepts are :node or :state param - pass in
  > either a DotHopPuzzle or a PuzzleState, and it'll use move() from either
  > to brute-force the puzzles.

- ([`29da0736`](https://github.com/russmatney/dothop/commit/29da0736)) refactor: remove node refs from PuzzleState - Russell Matney

  > Instead of handling nodes and calling methods in PuzzleState, we emit
  > signals. It's on the consumer (DotHopPuzzle) to connect to these from
  > Player and Dot nodes.

- ([`6c296234`](https://github.com/russmatney/dothop/commit/6c296234)) test: better PuzzleState test coverage - Russell Matney

  > Adds a few more assertions to make sure things are behaving as expected
  > - some larger puzzles, undos, and checking on moves vs apply moves.
  > 
  > Setting up some strong test coverage before starting to gut/refactor the
  > messy state funcs.


### 19 Jun 2025

- ([`342ef0af`](https://github.com/russmatney/dothop/commit/342ef0af)) fix: don't call node funcs on null nodes - Russell Matney

  > Add some guards, reorders some logic to run the game state updates
  > without calling DotHopPlayer or DotHopDot node funcs. These should be
  > kicked to signals instead.

- ([`688e5699`](https://github.com/russmatney/dothop/commit/688e5699)) refactor: pull apply_moves and rest of logic into PuzzleState - Russell Matney

  > Tests crashing b/c of PuzzleState node deps, but the DotHopPuzzle node
  > is now free of PuzzleState logic. Very close to running the game logic
  > without needing any nodes.

- ([`3373cd23`](https://github.com/russmatney/dothop/commit/3373cd23)) refactor: pull check_move into PuzzleState, add PuzzleState unit tests - Russell Matney

  > Fixes a few bugs and adds unit tests for basic PuzzleState funcs to be
  > sure things are working as expected.
  > 
  > Restores working puzzles, tho there are definitely some quirks - e.g.
  > emitting win too early.
  > 
  > Moves from reading grid directly to 'rebuilding' rows on request -
  > likely only relevant for testing.


### 18 Jun 2025

- ([`abab86ed`](https://github.com/russmatney/dothop/commit/abab86ed)) wip: dropping 'grid' in favor of coord->cell dict - Russell Matney

  > Mildly breaks everything! Tests failing, game logic needs to be fixed.

- ([`a0bde29a`](https://github.com/russmatney/dothop/commit/a0bde29a)) wip: moving away from string 'objs' in cells - Russell Matney
- ([`f0c3c019`](https://github.com/russmatney/dothop/commit/f0c3c019)) chore: add remove_nulls to bones.util - Russell Matney

### 17 Jun 2025

- ([`8f692a8d`](https://github.com/russmatney/dothop/commit/8f692a8d)) refactor: create cells when building state the first time - Russell Matney

  > The state's grid gets updated in place, but the cells don't - kind of
  > wonky.

- ([`a65dd998`](https://github.com/russmatney/dothop/commit/a65dd998)) refactor: split move into check_moves and apply_moves - Russell Matney

  > I think this is the command pattern? Nice to separate the data and the
  > execution of it.

- ([`b0559e7c`](https://github.com/russmatney/dothop/commit/b0559e7c)) refactor: break PuzzState into PuzzleState class - Russell Matney
- ([`0922d199`](https://github.com/russmatney/dothop/commit/0922d199)) refactor: pull more logic into PuzzState, use types to avoid warnings - Russell Matney

  > Ideally the analysis would run without any nodes - right now we're
  > strapped on top of the DotHopPuzzle node, itself.

- ([`980cde8f`](https://github.com/russmatney/dothop/commit/980cde8f)) fix: misc fixups after DotHopPuzzle refactor - Russell Matney

### 3 Jun 2025

- ([`cbd630cb`](https://github.com/russmatney/dothop/commit/cbd630cb)) build: setup dupe android build for local-prod tests - Russell Matney

  > Rather than edit the android export, we dupe it and make perma-tweaks
  > there.

- ([`3e22379f`](https://github.com/russmatney/dothop/commit/3e22379f)) fix: restore pandora compressed-read-error work-around - Russell Matney

  > For whatever reason the android release of the game does not build the
  > expected pandora data file as expected - this restores a workaround that
  > i lost when pandora was last updated. I ought to get this into a pandora
  > issue soon!

- ([`b657839a`](https://github.com/russmatney/dothop/commit/b657839a)) fix: don't run tween infinitely - Russell Matney

  > A bit of wip code that survived - slide_from_point should NOt set_loops()
  > to run forever.


### 2 Jun 2025

- ([`912fea20`](https://github.com/russmatney/dothop/commit/912fea20)) fix: disable non-production feature (?) - Russell Matney
- ([`5c5fd796`](https://github.com/russmatney/dothop/commit/5c5fd796)) wip: toying with dot-intro animation - Russell Matney

  > With @Camsbury!


### 30 May 2025

- ([`6aa9c6fc`](https://github.com/russmatney/dothop/commit/6aa9c6fc)) refactor: pull more dotHopPuzzle impl into PuzzState class - Russell Matney

  > Also cleans up the implementation a bit by leaning into the DotHopDot
  > type.

- ([`4710665e`](https://github.com/russmatney/dothop/commit/4710665e)) refactor: move ensure_cam to camera static func - Russell Matney

  > I like this pattern of nodes being responsible for themselves.

- ([`b004d556`](https://github.com/russmatney/dothop/commit/b004d556)) refactor: more sweeping rearrangement - Russell Matney

  > Grouping more scripts: core, audio dirs introduced.

- ([`6cc9a251`](https://github.com/russmatney/dothop/commit/6cc9a251)) docs: add docs/.nojekyll - Russell Matney

  > otherwise github ignores _sidebar.md, etc.

- ([`f17e2fff`](https://github.com/russmatney/dothop/commit/f17e2fff)) refactor: rename puzzle dir to 'dothop', move more things into 'puzzles' - Russell Matney

  > Re-orging the src dir a bit - trying to parse the DotHopPuzzle and
  > GameScene apart a bit.

- ([`9bd8fac3`](https://github.com/russmatney/dothop/commit/9bd8fac3)) feat: add version label to main menu - Russell Matney

  > Also bumps to v1.1.0! Targeting v2.0.0 for the next major release.

- ([`6aa7b736`](https://github.com/russmatney/dothop/commit/6aa7b736)) docs: more passable docs site - Russell Matney
- ([`f73e8941`](https://github.com/russmatney/dothop/commit/f73e8941)) docs: create changelog, add new version tag - Russell Matney

## v1.1.0


### 29 May 2025

- ([`470d12e6`](https://github.com/russmatney/dothop/commit/470d12e6)) chore: increment android release number - Russell Matney
- ([`937e42cd`](https://github.com/russmatney/dothop/commit/937e42cd)) feat: add floaty particles to rest of themes - Russell Matney

  > Not great, but it's something.

- ([`acda5fd3`](https://github.com/russmatney/dothop/commit/acda5fd3)) refactor: drop game_def_path usage - Russell Matney

  > Moving away from specifying these games - it seems only to be used for
  > the legend, which is pretty unnecessary at this point - really we just
  > need the puzzle shapes parsed.

- ([`441f3517`](https://github.com/russmatney/dothop/commit/441f3517)) refactor: rename dothop-n.txt files - Russell Matney
- ([`72fba570`](https://github.com/russmatney/dothop/commit/72fba570)) refactor: rename PuzzleScene -> DotHopPuzzle, wrap puzzle-set-paths - Russell Matney

  > Introduces a new custom resource, PuzzleSetData. this is a wrapper for
  > the (poorly named) dothop-one/two/three/etc.txt files. We now reference
  > these resources directly and use them to parse a GameDef.

- ([`10c3b34c`](https://github.com/russmatney/dothop/commit/10c3b34c)) wip: keeping pandora puzzle themes, simplifying puzzle-theme-data - Russell Matney

  > I was intending to drop some pandora bits, but after more thought and
  > some circular dependency issues, i've decided to just simplify it
  > instead. Pandora has nice visualization/UI features, and is a better
  > option to attach to nodes - e.g. the puzzlescene can reference a
  > PuzzleTheme, but not puzzle theme data

- ([`666dc053`](https://github.com/russmatney/dothop/commit/666dc053)) feat: floaty spring particles - Russell Matney
- ([`02812de8`](https://github.com/russmatney/dothop/commit/02812de8)) feat: some dot movement animations - Russell Matney

  > Adding some life to the otherwise static puzzles.


### 28 May 2025

- ([`529409b7`](https://github.com/russmatney/dothop/commit/529409b7)) chore: update CI godot version - Russell Matney

  > Also moves to invoking runtest via `sh` instead of chmodding the file.

- ([`11c89746`](https://github.com/russmatney/dothop/commit/11c89746)) fix: restore main menu logo - Russell Matney
- ([`814d275d`](https://github.com/russmatney/dothop/commit/814d275d)) deps: update bones and gd-plug - Russell Matney
- ([`9a11d6a7`](https://github.com/russmatney/dothop/commit/9a11d6a7)) deps: update gdfxr - Russell Matney
- ([`89a8bbe2`](https://github.com/russmatney/dothop/commit/89a8bbe2)) deps: update input_helper - Russell Matney
- ([`067bc7bd`](https://github.com/russmatney/dothop/commit/067bc7bd)) deps: update pandora - Russell Matney
- ([`a7703b50`](https://github.com/russmatney/dothop/commit/a7703b50)) deps: update AsepriteWizard - Russell Matney
- ([`0e4fd5a4`](https://github.com/russmatney/dothop/commit/0e4fd5a4)) deps: update log.gd - Russell Matney
- ([`f70fc4c7`](https://github.com/russmatney/dothop/commit/f70fc4c7)) deps: update gdunit - Russell Matney

  > GdUnit doesn't include .uid files in git, so those all get updated :eyeroll:


### 27 May 2025

- ([`7a413d65`](https://github.com/russmatney/dothop/commit/7a413d65)) chore: android app icon and feature graphic - Russell Matney

### 26 May 2025

- ([`d4e7463d`](https://github.com/russmatney/dothop/commit/d4e7463d)) chore: drop a bunch of .gdignored imports - Russell Matney
- ([`e3cb8f22`](https://github.com/russmatney/dothop/commit/e3cb8f22)) wip: puzzleScene themeData fallback - Russell Matney

### 23 May 2025

- ([`3ce65387`](https://github.com/russmatney/dothop/commit/3ce65387)) chore: misc export details - Russell Matney
- ([`47dd858e`](https://github.com/russmatney/dothop/commit/47dd858e)) feat: add app icon gen to boxart generation - Russell Matney
- ([`fadd501b`](https://github.com/russmatney/dothop/commit/fadd501b)) fix: restore click to move, clean up logs - Russell Matney

  > I declare drag-to-move fit to ship!

- ([`12ae34f7`](https://github.com/russmatney/dothop/commit/12ae34f7)) feat: initial drag-to-select-dot implementation - Russell Matney
- ([`9352f2a9`](https://github.com/russmatney/dothop/commit/9352f2a9)) wip: half-impl, towards drag-to-queue-dots - Russell Matney
- ([`bc6fc43a`](https://github.com/russmatney/dothop/commit/bc6fc43a)) fix: correct types that broke the player animation - Russell Matney

  > Also defers some audio setup so competing Music/Sounds autoloads wait
  > for bus setup before adjusting volume. (removing another warning).
  > 
  > Simplifies the puzzleScene `attempt_move` call.


### 22 May 2025

- ([`81429437`](https://github.com/russmatney/dothop/commit/81429437)) fix: move puzzle set unlocked to layer 5 - Russell Matney

  > The puzzle-set-unlocked jumbotron 'dismiss' button wasn't clickable b/c
  > the game's HUD layer was on top of it - bumping it to layer 5 ensures
  > the mobile-advance workaround.

- ([`83e8b64a`](https://github.com/russmatney/dothop/commit/83e8b64a)) chore: misc .tscn and .tres cruft - Russell Matney
- ([`ebbdd515`](https://github.com/russmatney/dothop/commit/ebbdd515)) fix: pandora fallback to read uncompressed data - Russell Matney

  > For some reason my pandora data does not seem to be compressing - adding
  > this fallback allows the data to be read on startup, which results in a
  > working android release build. woo!

- ([`5cd148fb`](https://github.com/russmatney/dothop/commit/5cd148fb)) fix: crash handling for missing pandora data - Russell Matney

  > Some handling for unexpected nulls that cause full game crashes.


### 16 May 2025

- ([`b9af41a8`](https://github.com/russmatney/dothop/commit/b9af41a8)) refactor: simplify parsing and types - Russell Matney

  > Moves away from dictionaries for the parsed result, at least at the top
  > level.
  > 
  > Drops parsing for a handful of unused sections (leftover from the puzzle
  > script parser impl, 'puzz'). Drops `Puzz` completely, moves it's public
  > func to static func on GameDef.

- ([`553fd7ed`](https://github.com/russmatney/dothop/commit/553fd7ed)) refactor: pull gnarly 'move' array into a class - Russell Matney

  > This was a crazy impl before - this leaves it more or less as-is but
  > moves away from implicit arrays of types, callables, and args and into a
  > more structured command pattern.

- ([`8961310d`](https://github.com/russmatney/dothop/commit/8961310d)) fix: play 'stuck' animation in direction when would-hit dotted - Russell Matney
- ([`3145503a`](https://github.com/russmatney/dothop/commit/3145503a)) fix: make sure we're fetching goal scenes - Russell Matney

  > Also drops a bunch of no-longer necessary warnings. Still a bunch that
  > are needed - maybe we'll get to more specific node types next.
  > 
  > Seems to be a bug when trying to move toward 'dotted' dots - it should
  > animate but it doesn't seem to.

- ([`8e2519eb`](https://github.com/russmatney/dothop/commit/8e2519eb)) fix: correct some type casts, update array null check - Russell Matney

  > Tests restored again after move away from untyped dictionary state obj.

- ([`c6f7a500`](https://github.com/russmatney/dothop/commit/c6f7a500)) wip: refactor puzzleScene algo from dicts to classes - Russell Matney

  > Things are quite broken! But the eventual result should be better for
  > long-term maintenance.

- ([`72d143a4`](https://github.com/russmatney/dothop/commit/72d143a4)) refactor: move to PuzzleThemeData static funcs to support fallbacks - Russell Matney

  > Restores broken tests - important before the dict refactor we're about
  > to launch into.


### 15 May 2025

- ([`04c97338`](https://github.com/russmatney/dothop/commit/04c97338)) wip: release build crashing on android! - Russell Matney

  > trying to dig into why.... only clue so far:
  > 
  > WARNING: Unable to initialize entity with id=17 from scene: got removed!
  >     at: push_warning (core/variant/variant_utility.cpp:1118)

- ([`b8fa084c`](https://github.com/russmatney/dothop/commit/b8fa084c)) feat: add Menu button to gameScene, restore return-to-main - Russell Matney

  > Registers the MainMenu with navi, adds a pause/menu button to the
  > GameScene.
  > 
  > DRYs up the calls to pause + show the menu via the DotHop autoload.
  > 
  > Again, doesn't look great, but we're driving toward fully functional on
  > mobile!

- ([`cb8c52cf`](https://github.com/russmatney/dothop/commit/cb8c52cf)) fix: restore pause menu - Russell Matney

  > Menus are now registered with Navi (so we're not hard-coding menus
  > within Bones/Navi). This registers the pause menu in the DotHop
  > autoload.

- ([`78baa11b`](https://github.com/russmatney/dothop/commit/78baa11b)) fix: avoid already connected error - Russell Matney
- ([`d1a11cab`](https://github.com/russmatney/dothop/commit/d1a11cab)) rough: add tappable button to jumbotron - Russell Matney

  > Doesn't look great, but prevents soft-locks on mobile, so we're shipping it.


### 14 May 2025

- ([`b3af4fa6`](https://github.com/russmatney/dothop/commit/b3af4fa6)) fix: dedupe uids - Russell Matney

  > Godot 4.4 uses uids now, which is a problem if you copy-pasted a bunch
  > of scenes in godot 4.2 and 4.3, creating a bunch of duplicate UIDs.
  > 
  > related: https://github.com/godotengine/godot/issues/102490
  > 
  > This recreates a bunch of scenes to get fresh uids, fixing bizarre
  > snowmen-in-springtime bugs.

- ([`b2c4efa7`](https://github.com/russmatney/dothop/commit/b2c4efa7)) fix: type 'safety' fix - Russell Matney

  > Yet again, a happy compiler does not imply a happy program.

- ([`25a4fc05`](https://github.com/russmatney/dothop/commit/25a4fc05)) refactor: pull dots from ThemeData, not Theme - Russell Matney

  > Moving from pandora to plain-old custom resources.


### 13 May 2025

- ([`17a54922`](https://github.com/russmatney/dothop/commit/17a54922)) chore: update to godot 4.4 - Russell Matney

  > All the .uids, some export tweaks (tried to export for android on osx)


### 15 Feb 2025

- ([`3930b26d`](https://github.com/russmatney/dothop/commit/3930b26d)) fix: static type fixes - tests passing again! - Russell Matney

### 1 Feb 2025

- ([`84309b32`](https://github.com/russmatney/dothop/commit/84309b32)) feat: no more type warnings! - Russell Matney

  > Still plenty of bugs tho

- ([`a28b47c1`](https://github.com/russmatney/dothop/commit/a28b47c1)) wip: nearly all the rest of the types - Russell Matney

  > Saving this Puzz parser for last - then we move on to ironing out these dictionaries.


### 31 Jan 2025

- ([`2cfc80de`](https://github.com/russmatney/dothop/commit/2cfc80de)) wip: more static types for ya! - Russell Matney

### 29 Jan 2025

- ([`f16de043`](https://github.com/russmatney/dothop/commit/f16de043)) wip: drop actionInputIcon in favor of bones's icon comp - Russell Matney
- ([`35822095`](https://github.com/russmatney/dothop/commit/35822095)) wip: more types, and towards dropping actionInputIcon - Russell Matney
- ([`a7cbcd6b`](https://github.com/russmatney/dothop/commit/a7cbcd6b)) wip: add luuuts of types - Russell Matney

  > kind of a pita

- ([`e4f18f6c`](https://github.com/russmatney/dothop/commit/e4f18f6c)) fix: prevent HUD buttons from focusing from directional inputs - Russell Matney

  > The undo/reset buttons were eating up/down inputs, causing a weird
  > hiccup when making some moves.

- ([`af64313e`](https://github.com/russmatney/dothop/commit/af64313e)) wip: add new puzzle from cameron - Russell Matney

  > warning: very hard!

- ([`e6e12b74`](https://github.com/russmatney/dothop/commit/e6e12b74)) deps: update input helper - Russell Matney
- ([`0a77115d`](https://github.com/russmatney/dothop/commit/0a77115d)) deps: update log.gd - Russell Matney
- ([`39f80ae5`](https://github.com/russmatney/dothop/commit/39f80ae5)) chore: update gdunit - Russell Matney

### 28 Jan 2025

- ([`b12b9ff1`](https://github.com/russmatney/dothop/commit/b12b9ff1)) fix: bunch of runtime bugs caused by our type 'safety' - Russell Matney

  > :smh:

- ([`b0e3fbc8`](https://github.com/russmatney/dothop/commit/b0e3fbc8)) wip: enforce most types in PuzzleScene.gd - Russell Matney

  > Need to refactor away from some dictionaries here, but otherwise this is
  > now cleaner and has type checking.

- ([`56d34fb5`](https://github.com/russmatney/dothop/commit/56d34fb5)) wip: replace PuzzleTheme with PuzzleThemeData - Russell Matney

  > Also enforcing static types everywhere.


### 20 Jan 2025

- ([`d922e535`](https://github.com/russmatney/dothop/commit/d922e535)) fix: update kenney-input-prompts refs - Russell Matney
- ([`5a2f2842`](https://github.com/russmatney/dothop/commit/5a2f2842)) chore: drop duped kenney-input-prompts - Russell Matney

  > Derp, don't need 2 of all these.

- ([`3494e18a`](https://github.com/russmatney/dothop/commit/3494e18a)) deps: bones updates - Russell Matney
- ([`4c31276e`](https://github.com/russmatney/dothop/commit/4c31276e)) deps: update input_helper, sound_manager - Russell Matney
- ([`3f32fbcb`](https://github.com/russmatney/dothop/commit/3f32fbcb)) deps: update gdunit - Russell Matney

### 2 Dec 2024

- ([`7d96b900`](https://github.com/russmatney/dothop/commit/7d96b900)) fix: skip when player.coord is null - Russell Matney

  > here's a gotcha! was dropping player input when coord was vector2.zero

- ([`ddd0734b`](https://github.com/russmatney/dothop/commit/ddd0734b)) feat: building and running on a local android device! - Russell Matney
- ([`74c647eb`](https://github.com/russmatney/dothop/commit/74c647eb)) chore: empty android export config - Russell Matney
- ([`c58a34d1`](https://github.com/russmatney/dothop/commit/c58a34d1)) feat: tap or click to move to dot/goal - Russell Matney

  > Hopefully this is reused everywhere - may lead to problems in the
  > two-player puzzles, but, we don't have any right now.

- ([`be751474`](https://github.com/russmatney/dothop/commit/be751474)) chore: bunch of theme tres/scene cruft - Russell Matney
- ([`2c7feef1`](https://github.com/russmatney/dothop/commit/2c7feef1)) feat: firing signal on dot click/tap - Russell Matney
- ([`c7d7b26c`](https://github.com/russmatney/dothop/commit/c7d7b26c)) feat: clickable undo/reset buttons - Russell Matney

  > Very rough and dupe-y for now, but they work.
  > 
  > Ought to clean up the gameScene vs puzzleScene vs Hud logic a bit.

- ([`ba1589df`](https://github.com/russmatney/dothop/commit/ba1589df)) fix: split out linux-godotsteam export - Russell Matney

  > Will need to get a 4.3 godotsteam binary locally as well

- ([`76f450cd`](https://github.com/russmatney/dothop/commit/76f450cd)) fix: move puzzleTheme data to a resource - Russell Matney

  > Pandora kept converting these arrays to type 'color'.... I should notify
  > about a bug, but i also shouldn't be using pandora for this anyway. This
  > starts to move off of pandora for themes by moving some of the data to
  > proper godot resources.

- ([`79e125ce`](https://github.com/russmatney/dothop/commit/79e125ce)) fix: update export name - Russell Matney
- ([`2186bb90`](https://github.com/russmatney/dothop/commit/2186bb90)) ci: update itch/steam deploy workflows - Russell Matney
- ([`e7862879`](https://github.com/russmatney/dothop/commit/e7862879)) fix: restore save/load, BREAKS save games! - Russell Matney

  > Unfortunately pandora introduced a breaking change, so the serialized
  > save-game events can't be deserialized. I don't care too much, y'all can
  > play through again if you want to.
  > 
  > Still not handling deserialization crashes, but this is at least a bit
  > safer.

- ([`f4ffbe53`](https://github.com/russmatney/dothop/commit/f4ffbe53)) fix: Trolls reference ui_undo - Russell Matney
- ([`e03a37b0`](https://github.com/russmatney/dothop/commit/e03a37b0)) fix: update U.call_in, restore U.button_disabled helpers - Russell Matney
- ([`02d79cd2`](https://github.com/russmatney/dothop/commit/02d79cd2)) fix: more dead addons/core references - Russell Matney
- ([`a38b7ffc`](https://github.com/russmatney/dothop/commit/a38b7ffc)) chore: drop addons/core, update misc refs/autoloads - Russell Matney
- ([`9ecd5628`](https://github.com/russmatney/dothop/commit/9ecd5628)) feat: add opts filter to bones/Util - Russell Matney

  > There was more to the core vs bones Util.gd diff - we'll see what else
  > we run into.

- ([`5879f277`](https://github.com/russmatney/dothop/commit/5879f277)) chore: drop core/assets - Russell Matney
- ([`6e59268a`](https://github.com/russmatney/dothop/commit/6e59268a)) chore: move credits, notifs, ui/comps into src - Russell Matney
- ([`b678d225`](https://github.com/russmatney/dothop/commit/b678d225)) chore: move core/assets/fonts refs to bones/fonts - Russell Matney
- ([`0fc423c7`](https://github.com/russmatney/dothop/commit/0fc423c7)) chore: drop addons/dj in favor of bones/dj - Russell Matney

  > Moves the MuteButtonList into src/menus

- ([`fb24ceb8`](https://github.com/russmatney/dothop/commit/fb24ceb8)) chore: port Trolls tweaks to bones/Trolls - Russell Matney
- ([`813c4138`](https://github.com/russmatney/dothop/commit/813c4138)) chore: fix input_helper, enable bones, update pandora data - Russell Matney
- ([`d730239d`](https://github.com/russmatney/dothop/commit/d730239d)) chore: not sure how this got duped - Russell Matney
- ([`ff62aad8`](https://github.com/russmatney/dothop/commit/ff62aad8)) deps: include kenney input prompts via bones - Russell Matney
- ([`a31a21f5`](https://github.com/russmatney/dothop/commit/a31a21f5)) deps: add bones - Russell Matney
- ([`013ffac9`](https://github.com/russmatney/dothop/commit/013ffac9)) deps: update log.gd - Russell Matney
- ([`c43db4b5`](https://github.com/russmatney/dothop/commit/c43db4b5)) deps: update gdunit - Russell Matney
- ([`4085391f`](https://github.com/russmatney/dothop/commit/4085391f)) deps: update input_helper - Russell Matney
- ([`3b2f4c42`](https://github.com/russmatney/dothop/commit/3b2f4c42)) deps: update pandora - Russell Matney
- ([`b354ecd0`](https://github.com/russmatney/dothop/commit/b354ecd0)) deps: update AsepriteWizard - Russell Matney

### 23 Oct 2024

- ([`7a429f33`](https://github.com/russmatney/dothop/commit/7a429f33)) fix: better unit test - Russell Matney

  > no need to expect all themes to be unlocked, at least one is fine


### 19 Oct 2024

- ([`55405d32`](https://github.com/russmatney/dothop/commit/55405d32)) wip: basic 'pumpkins' dot/dotted and wip theme - Russell Matney

  > Adds a quick Pumpkins theme with a pumpkin dot and dotted state.


### 31 Aug 2024

- ([`a10afc48`](https://github.com/russmatney/dothop/commit/a10afc48)) fix: readme badge urls - Russell Matney

  > Some how these were underscored instead of hyphenated?


### 30 Aug 2024

- ([`78192498`](https://github.com/russmatney/dothop/commit/78192498)) fix: use newer gdunit ci setup - Russell Matney
- ([`341c1f95`](https://github.com/russmatney/dothop/commit/341c1f95)) fix: attempt to use `which godot` - Russell Matney
- ([`853e6c7b`](https://github.com/russmatney/dothop/commit/853e6c7b)) fix: gdunit tests running again! - Russell Matney
- ([`29d58a44`](https://github.com/russmatney/dothop/commit/29d58a44)) deps: update gdfxr - Russell Matney
- ([`468d2614`](https://github.com/russmatney/dothop/commit/468d2614)) chore: upgrade to godot 4.3 - Russell Matney
- ([`fb2ee56e`](https://github.com/russmatney/dothop/commit/fb2ee56e)) chore: update pandora data format - Russell Matney
- ([`a9b77d62`](https://github.com/russmatney/dothop/commit/a9b77d62)) fix: remove .gdignore from pandora dir - Russell Matney

  > Apparently gdscript ignores .gdignores now!

- ([`b079197a`](https://github.com/russmatney/dothop/commit/b079197a)) deps: update gdunit - Russell Matney
- ([`3d693a02`](https://github.com/russmatney/dothop/commit/3d693a02)) deps: update input helper - Russell Matney
- ([`94ae1fd1`](https://github.com/russmatney/dothop/commit/94ae1fd1)) deps: update log.gd - Russell Matney
- ([`392ce6a1`](https://github.com/russmatney/dothop/commit/392ce6a1)) deps: update aespriteWizard - Russell Matney
- ([`5779e8be`](https://github.com/russmatney/dothop/commit/5779e8be)) deps: update pandora - Russell Matney

### 20 Jun 2024

- ([`1a42e1be`](https://github.com/russmatney/dothop/commit/1a42e1be)) fix: readme discord link - Russell Matney

### 17 Jun 2024

- ([`bf747fdb`](https://github.com/russmatney/dothop/commit/bf747fdb)) fix: don't prefer horizontal movement if abs(y > x) - Russell Matney
- ([`755bfa47`](https://github.com/russmatney/dothop/commit/755bfa47)) feat: support input gestures in Trolls - Russell Matney

  > Not too bad! just need to pass the event in a few places. Sometimes 2
  > moves fire quickly (e.g. down is interpreted as left then down) - i
  > think this can happen with the joystick as well - maybe a stronger delay
  > while moving would solve it?

- ([`b2cf65c4`](https://github.com/russmatney/dothop/commit/b2cf65c4)) chore: .gdignore in dirs, folder colors, touch inputs - Russell Matney
- ([`2b223086`](https://github.com/russmatney/dothop/commit/2b223086)) refactor: ignore rather than symlink to game-assets - Russell Matney

  > I'd been keeping these songs out of the repo via symlink, but that
  > doesn't fly with the ios builds. instead, just ignoring the symlinked
  > dir after copying it in.


### 16 Jun 2024

- ([`3618a1de`](https://github.com/russmatney/dothop/commit/3618a1de)) ios: basic export settings - Russell Matney

### 13 Jun 2024

- ([`c96f9c69`](https://github.com/russmatney/dothop/commit/c96f9c69)) deps: update gdfxr - Russell Matney

### 9 Jun 2024

- ([`cd10ce90`](https://github.com/russmatney/dothop/commit/cd10ce90)) chore: misc project churn - Russell Matney
- ([`df5d2146`](https://github.com/russmatney/dothop/commit/df5d2146)) deps: update gd-plug, drop gd-plug-ui - Russell Matney
- ([`fe60d841`](https://github.com/russmatney/dothop/commit/fe60d841)) deps: update sound manager and input helper - Russell Matney
- ([`3f605a96`](https://github.com/russmatney/dothop/commit/3f605a96)) deps: update log.gd - Russell Matney
- ([`61bd74a1`](https://github.com/russmatney/dothop/commit/61bd74a1)) deps: update aseprite wizard - Russell Matney
- ([`bcda3e95`](https://github.com/russmatney/dothop/commit/bcda3e95)) deps: update gdunit - Russell Matney

### 4 Jun 2024

- ([`4f65c5b2`](https://github.com/russmatney/dothop/commit/4f65c5b2)) chore: update funding links - Russell Matney

### 6 May 2024

- ([`7a6f6236`](https://github.com/russmatney/dothop/commit/7a6f6236)) license: source code now MIT Licensed - Russell Matney

### 25 Mar 2024

- ([`b8a33f47`](https://github.com/russmatney/dothop/commit/b8a33f47)) docs: init docsify site - Russell Matney

### 21 Mar 2024

- ([`7ea74983`](https://github.com/russmatney/dothop/commit/7ea74983)) revert: gdunit4 ci aborting, use old ci setup for now - Russell Matney

  > The action aborted via 134 and no tests ran, but it still reported that
  > it had succeeded. yeesh!

- ([`cc6330aa`](https://github.com/russmatney/dothop/commit/cc6330aa)) refactor: move to latest gdunit4 ci github action - Russell Matney
- ([`e475ed49`](https://github.com/russmatney/dothop/commit/e475ed49)) fix: make test script executable - Russell Matney
- ([`dee90fad`](https://github.com/russmatney/dothop/commit/dee90fad)) chore: drop core/log.gd, install log.gd via gd-plug - Russell Matney
- ([`9550c511`](https://github.com/russmatney/dothop/commit/9550c511)) chore: update pandora via gd-plug - Russell Matney

  > Everything expect the broken production data encryption.

- ([`244f54c4`](https://github.com/russmatney/dothop/commit/244f54c4)) chore: update sound_manager and input_helper via gd-plug - Russell Matney
- ([`f2fc656c`](https://github.com/russmatney/dothop/commit/f2fc656c)) chore: update Aseprite wizard via gd-plug - Russell Matney
- ([`7578cf79`](https://github.com/russmatney/dothop/commit/7578cf79)) chore: update gdunit4, install gd-plug-ui - Russell Matney
- ([`e54cadd2`](https://github.com/russmatney/dothop/commit/e54cadd2)) chore: basic gd-plug setup - Russell Matney

### 1 Mar 2024

- ([`385502af`](https://github.com/russmatney/dothop/commit/385502af)) chore: couple more boxarty image assets - Russell Matney

  > Steam announcements also require some image assets!


## v1.0.0


### 29 Feb 2024

- ([`853a2171`](https://github.com/russmatney/dothop/commit/853a2171)) chore: final achivement icons - Russell Matney
- ([`9a4cfa43`](https://github.com/russmatney/dothop/commit/9a4cfa43)) fix: use first_puzzle_icon for fallback cursor position - Russell Matney

  > This was deleted during yesterday's refactor, but now i get why it was
  > here! I ought to write tests for this scene, it's pretty hairy.

- ([`73fd1907`](https://github.com/russmatney/dothop/commit/73fd1907)) fix: hide puzzle cursor aggressively - Russell Matney

  > Hopefully this doesn't break anything - the puzzle cursor happily floats
  > to 0, 0 in some cases. this at least doesn't show it when that happens,
  > and seems to be fine.

- ([`f5b934e2`](https://github.com/russmatney/dothop/commit/f5b934e2)) chore: couple more playtester credits! - Russell Matney
- ([`ef5ee90c`](https://github.com/russmatney/dothop/commit/ef5ee90c)) chore: better last-puzzle hud message - Russell Matney
- ([`e56c480e`](https://github.com/russmatney/dothop/commit/e56c480e)) chore: couple more unlocked-world subheads - Russell Matney
- ([`8fa86925`](https://github.com/russmatney/dothop/commit/8fa86925)) chore: rearrange some deck chairs - Russell Matney

  > this puzzle progress panel is killing me

- ([`3ed7c735`](https://github.com/russmatney/dothop/commit/3ed7c735)) feat: achivements for 900/1000 dots - Russell Matney
- ([`8172f2e2`](https://github.com/russmatney/dothop/commit/8172f2e2)) chore: tweaking progress panel size - Russell Matney

  > This thing has a mind of its own

- ([`ec3cbc54`](https://github.com/russmatney/dothop/commit/ec3cbc54)) feat: bump required puzzle counts - Russell Matney

  > More puzzles, need more to unlock things!

- ([`8bca5fdc`](https://github.com/russmatney/dothop/commit/8bca5fdc)) feat: drop some easy space ones, add some harder ones - Russell Matney

  > Still don't feel like these space levels are hard enough - will have to
  > add some kind of harder world afterwords soon.

- ([`e4ec5f34`](https://github.com/russmatney/dothop/commit/e4ec5f34)) feat: two more medium snow levels - Russell Matney
- ([`3b0202c1`](https://github.com/russmatney/dothop/commit/3b0202c1)) feat: two more hard fall puzzles - Russell Matney
- ([`41ead4d0`](https://github.com/russmatney/dothop/commit/41ead4d0)) feat: add two hard puzzles to the beach - Russell Matney

  > And clean up/add variety to some existing ones.

- ([`e8806502`](https://github.com/russmatney/dothop/commit/e8806502)) feat: two more spring puzzles - Russell Matney

  > Plus drop some gaps in the later larger ones

- ([`13ce20c6`](https://github.com/russmatney/dothop/commit/13ce20c6)) feat: add three more puzzles to world one - Russell Matney
- ([`fd773286`](https://github.com/russmatney/dothop/commit/fd773286)) feat: add achivements for 100 * n to 800 - Russell Matney

  > includes icons and code.

- ([`9319bf25`](https://github.com/russmatney/dothop/commit/9319bf25)) chore: don't rotate unless width <= 6 - Russell Matney

  > Probably too low, but the very tall + thin layouts are bugging me, so
  > this is an aesthetic fix until i can find more fixes that look
  > better (improved camera zoom, maybe?)

- ([`6a3a2bd3`](https://github.com/russmatney/dothop/commit/6a3a2bd3)) feat: fade 'normal' state of buttons more - Russell Matney

  > The focused vs unfocused button states are now more distinct.

- ([`802404b5`](https://github.com/russmatney/dothop/commit/802404b5)) feat: more testers! - Russell Matney
- ([`8a7ade47`](https://github.com/russmatney/dothop/commit/8a7ade47)) credits: add godotsteam, special thanks - Russell Matney
- ([`ad38fad9`](https://github.com/russmatney/dothop/commit/ad38fad9)) fix: restore tests after complete/unlock refactor - Russell Matney
- ([`34d88141`](https://github.com/russmatney/dothop/commit/34d88141)) feat: space theme ufo player sprite - Russell Matney

### 28 Feb 2024

- ([`6958f03e`](https://github.com/russmatney/dothop/commit/6958f03e)) chore: some credit fixes - Russell Matney
- ([`b2cfab46`](https://github.com/russmatney/dothop/commit/b2cfab46)) wip: an unused float-a-bit animation - Russell Matney
- ([`b3e406b1`](https://github.com/russmatney/dothop/commit/b3e406b1)) feat: puzzle rotation - Russell Matney

  > This is cool, but alot of the 'wide' puzzles present pretty small when
  > they are rotated. Maybe could have some width/height cut-off or some
  > other solution to the aesthetic cost.

- ([`7876f2d4`](https://github.com/russmatney/dothop/commit/7876f2d4)) feat: show 'replay' vs 'start' if the puzzle has been completed - Russell Matney
- ([`cb840ade`](https://github.com/russmatney/dothop/commit/cb840ade)) feat: support replaying puzzle sets - Russell Matney
- ([`b5d0c532`](https://github.com/russmatney/dothop/commit/b5d0c532)) feat: next-puzzle is now the next-incomplete-puzzle - Russell Matney

  > Simplifies the on-win logic a bit - when a puzzle set is complete, we
  > nav to the world map, and when a puzzle is complete, we move to the next
  > incomplete puzzle.
  > 
  > The hud now shows how many puzzles are left to finish.

- ([`15d53650`](https://github.com/russmatney/dothop/commit/15d53650)) feat: add puzzle complete/total to worldmap puzzle label - Russell Matney
- ([`50b65554`](https://github.com/russmatney/dothop/commit/50b65554)) feat: unlock up to 3 levels per puzzle set at a time - Russell Matney

  > Bit of logic, but i think it's fine. who needs unit tests?

- ([`32f7bbbb`](https://github.com/russmatney/dothop/commit/32f7bbbb)) fix: go to credits when last puzzle complete - Russell Matney

  > regardless of if this puzzle completes the set or not

- ([`f4786962`](https://github.com/russmatney/dothop/commit/f4786962)) feat: display n-puzzles-to-unlock on locked puzzle sets - Russell Matney

  > Also dries up the calc_stats in DHData, and adds a quick
  > fade_in/fade_out to Anim.

- ([`c2f6b3ab`](https://github.com/russmatney/dothop/commit/c2f6b3ab)) fix: only call_in if node is still valid - Russell Matney
- ([`613766c2`](https://github.com/russmatney/dothop/commit/613766c2)) feat: rework puzzle-win logic - Russell Matney

  > performs calcs to properly mark puzzle-sets complete (important now that
  > puzzles can be skipped). Updates completion of the final puzzle with a
  > more specific note, and drops the intermediate puzzle-complete
  > events (puzzles are broken up by puzzle-unlock events now).
  > 
  > Perhaps we want to jump to the next incomplete level, or provide a menu
  > for selecting the next puzzle if the next one is already complete?

- ([`584bbec7`](https://github.com/russmatney/dothop/commit/584bbec7)) feat: options button for clearing all steam achievements - Russell Matney
- ([`fe040125`](https://github.com/russmatney/dothop/commit/fe040125)) feat: unlock puzzles based on puzzles completed - Russell Matney

  > Rather than a linear one-world-at-a-time approach, this allows for
  > unlocking the next world after fewer in the previous one.
  > 
  > Rearranges the on-win logic in the game_scene, pulling some stat calcs
  > out of the store functions. Maybe the achievements belong in the store?
  > but it doesn't seem like the ui-flow/jumbotrons do.

- ([`75731bd4`](https://github.com/russmatney/dothop/commit/75731bd4)) wip: add puzzle_to_unlock with first-pass at values - Russell Matney
- ([`53195268`](https://github.com/russmatney/dothop/commit/53195268)) refactor: give puzzleSetIDs better names - Russell Matney

  > Proper names, especially b/c the order here does not match the
  > 'numbers'.

- ([`b966ddc3`](https://github.com/russmatney/dothop/commit/b966ddc3)) feat: support scrolling unlocked worlds on the worldmap - Russell Matney

  > Fixes some focus grabbing and prevents access to locked puzzles, but
  > otherwise feel free to scroll through the worlds.

- ([`45bb6c44`](https://github.com/russmatney/dothop/commit/45bb6c44)) feat: default to the first next_puzzle_icon - Russell Matney

  > As we're going to be opening up multiple puzzles at a time, we set this
  > choose earlier levels rather than later ones.

- ([`e8286e56`](https://github.com/russmatney/dothop/commit/e8286e56)) fix: support interrupting the current sound - Russell Matney

  > Not precisely the same, but close enough to what i had before.

- ([`3f6244fa`](https://github.com/russmatney/dothop/commit/3f6244fa)) feat: better green-button-theme disabled state - Russell Matney
- ([`bbc49e7d`](https://github.com/russmatney/dothop/commit/bbc49e7d)) feat: sliders for music and sound volume - Russell Matney

  > Moves the sounds to playing via SoundManager - further DJ clean up can
  > come later.
  > 
  > One quirk is that the sounds now overlap rather than interrupting
  > each other - might be slightly annoying, hopefully there's a quick fix
  > around for this.

- ([`6d5d12d6`](https://github.com/russmatney/dothop/commit/6d5d12d6)) fix: leaf/space achievement mixup - Russell Matney

  > I ought to update the puzzle entity ids to prevent this kind of thing

- ([`d3793752`](https://github.com/russmatney/dothop/commit/d3793752)) export: update osx export to godotsteam template - Russell Matney

### 27 Feb 2024

- ([`97fc8691`](https://github.com/russmatney/dothop/commit/97fc8691)) fix: clear test achievement and no more achv. clearing - Russell Matney
- ([`aaec2828`](https://github.com/russmatney/dothop/commit/aaec2828)) feat: impl puzzle-complete, options, and dot-earned achievements - Russell Matney

  > Quick and dirty - would be nice to abstract out achievements, but first
  > we'll see if this much even works.

- ([`2b9afb8c`](https://github.com/russmatney/dothop/commit/2b9afb8c)) feat: achievement icons - Russell Matney
- ([`34d0477a`](https://github.com/russmatney/dothop/commit/34d0477a)) fix: support running with a non-godotsteam build - Russell Matney

  > Only do steam things when there is a 'Steam' singleton - this
  > works-around needing godot-steam to run unit tests in CI.

- ([`29d4467c`](https://github.com/russmatney/dothop/commit/29d4467c)) feat: godotsteam basic integration, including test achievement - Russell Matney

  > Adds a GodotSteam autoload, references to godot-steam templates, and
  > some handling for creating and dropping a test achievement. Working
  > pretty well! Expects to be run in a version of godot compiled with
  > godot-steam as a godot extension: https://github.com/CoaguCo-Industries/GodotSteam/releases/tag/v4.6

- ([`a99ad161`](https://github.com/russmatney/dothop/commit/a99ad161)) fix: drop pandora debug conditionals - Russell Matney

  > Pandora production releases don't seem to work. will have to investigate
  > further, but for now, just ship it.

- ([`2f7d702a`](https://github.com/russmatney/dothop/commit/2f7d702a)) feat: add more playtesters to the credits - Russell Matney
- ([`c56a55ba`](https://github.com/russmatney/dothop/commit/c56a55ba)) fix: scroll credits with joystick now working - Russell Matney
- ([`c7daa40f`](https://github.com/russmatney/dothop/commit/c7daa40f)) feat: space theme, swap player/target colors - Russell Matney

  > This goal is actually the same as the 'starfish' goal from the summer
  > theme.

- ([`7a6f04e3`](https://github.com/russmatney/dothop/commit/7a6f04e3)) fix: don't move puzzle cursor on hover, reselect on refocus - Russell Matney

  > Supports adding the cursor animation back when the mouse leaves the
  > next/prev buttons.

- ([`a81d939a`](https://github.com/russmatney/dothop/commit/a81d939a)) feat: brighter fall background - Russell Matney

  > Much more readable!

- ([`a4f93db5`](https://github.com/russmatney/dothop/commit/a4f93db5)) feat: spring, summer, winter player/dot/goal outlines - Russell Matney

  > Improves some visual clarity by adding outlines to players/dots/goals in
  > spring/summer/winter.

- ([`1ee17150`](https://github.com/russmatney/dothop/commit/1ee17150)) feat: redo Them Dots art at 16x16 - Russell Matney

  > Not sure quite how i feel about these dots yet

- ([`ff289715`](https://github.com/russmatney/dothop/commit/ff289715)) fix: readjust more progress panel sizes - Russell Matney

  > This progress panel size easily breaks - perhaps it needs a proper reset
  > in _ready() every time?

- ([`7ebca447`](https://github.com/russmatney/dothop/commit/7ebca447)) wip: stub some skipped-puzzle handling - Russell Matney
- ([`ce138a59`](https://github.com/russmatney/dothop/commit/ce138a59)) fix: support starting a 'selected' puzzle - Russell Matney

  > puzzle_idx was being reset before navigation


### 26 Feb 2024

- ([`4a086a75`](https://github.com/russmatney/dothop/commit/4a086a75)) feat: basic puzzle count on main menu - Russell Matney

  > Slightly brittle dot_count() impl on the puzzle_def - might want to tie
  > in the legend/mapping earlier, maybe even in the parser.


### 25 Feb 2024

- ([`851fd037`](https://github.com/russmatney/dothop/commit/851fd037)) fix: don't return before undoing both players - Russell Matney
- ([`dd457adb`](https://github.com/russmatney/dothop/commit/dd457adb)) fix and test: puzzle skipping data handling - Russell Matney

  > This is more or less working now. the data handling is getting a bit
  > complicated - the event state updates don't apply to the in-place
  > puzzle-sets, so refetching/syncing might be necessary in some cases...

- ([`6423271b`](https://github.com/russmatney/dothop/commit/6423271b)) feat: support Store.skip_puzzle - Russell Matney

  > A bit rough to need to recompute here - hopefully the data stays
  > managable.
  > 
  > Perhaps I should write some tests??

- ([`15bd41ab`](https://github.com/russmatney/dothop/commit/15bd41ab)) feat: add and managed skip is_active - Russell Matney

  > Skips are active by default, and are deactivated when the same puzzle
  > index is completed.

- ([`6ea2db7f`](https://github.com/russmatney/dothop/commit/6ea2db7f)) feat: refactor puzzle_set to support skipping, completing - Russell Matney

  > Sets up a more fine-grained marking of complete puzzles, plus some extra
  > data-base for skipping levels.
  > 
  > We'll probably want a flag on these skips for when they're not relevant
  > anymore (i.e. when the level gets proper completed).

- ([`f34b944d`](https://github.com/russmatney/dothop/commit/f34b944d)) fix: better progress-jumbo header - Russell Matney
- ([`83128d47`](https://github.com/russmatney/dothop/commit/83128d47)) feat: fixup control tweens in hud, animate reset puzzle - Russell Matney
- ([`878b16cf`](https://github.com/russmatney/dothop/commit/878b16cf)) fix: show controls at 0.5 instead of 0.1 - Russell Matney

  > Also refactors the hud's reaction to inputs to listen to proper puzzle
  > signals (like move_rejected and player_undo) rather than just trolley
  > inputs. this should give some better feedback to players when they
  > move-to-undo or can't move at all (i.e. stuck on the target).

- ([`be742481`](https://github.com/russmatney/dothop/commit/be742481)) feat: explicit set_focus worldmap impl - Russell Matney

  > Supports selecting a puzzle after 'pause' instead of a next/prev button.

- ([`eaf5da1b`](https://github.com/russmatney/dothop/commit/eaf5da1b)) fix: more focus tweaks - Russell Matney

  > The worldmap is still loading without grabbing focus - I'm not sure
  > what's the deal, so here's some more aggressive focus grabbing. This is
  > super annoying b/c it completely breaks the game if the user doesn't
  > have a mouse/screen-input to fix it. Probably should impl some fallback
  > so that arbitrary inputs check and find a focus if necessary.

- ([`d419e24a`](https://github.com/russmatney/dothop/commit/d419e24a)) feat: red/blue button states much more distinct - Russell Matney
- ([`20a56578`](https://github.com/russmatney/dothop/commit/20a56578)) feat: refactor worldmap menu for better ux - Russell Matney

  > - move prev/next buttons in-line with grid
  > - animate button and label when new puzzle/puzzle-set selected
  > - disable 'start' button when next/prev focused
  > - improve normal/focused button color distinction
  > - support mouse/focus enter/exit interaction on next/prev and puzzle icons
  > 
  > Overall, it's just much clearer how to select a puzzle/what the ui is
  > trying to be

- ([`3fa8185d`](https://github.com/russmatney/dothop/commit/3fa8185d)) fix: unpause when selecting a new theme - Russell Matney
- ([`c01cda84`](https://github.com/russmatney/dothop/commit/c01cda84)) fix: another step in the 'tutorial' world-1 - Russell Matney
- ([`a3725749`](https://github.com/russmatney/dothop/commit/a3725749)) fix: plain-text parser is a bit brittle! - Russell Matney

  > yikes, this completely broke the game. presumably the tests would have
  > failed?

- ([`f0a63544`](https://github.com/russmatney/dothop/commit/f0a63544)) fix: proper navi current_scene set and log - Russell Matney

  > Now that I know how to wait process_frames, things are starting to click
  > a bit. Though I don't think I really need to in this case...

- ([`e2cff635`](https://github.com/russmatney/dothop/commit/e2cff635)) fix: add more basic level 4 - hopefully better ramp up - Russell Matney

  > hopping over already-dotted dots is a key mechanic, so here's a minimal
  > level emphasizing that


### 23 Feb 2024

- ([`af42c0da`](https://github.com/russmatney/dothop/commit/af42c0da)) wip: logging puzzle stats in the main menu - Russell Matney
- ([`65ed0777`](https://github.com/russmatney/dothop/commit/65ed0777)) wip: some sunburst particles, maybe for an effect - Russell Matney
- ([`238b94de`](https://github.com/russmatney/dothop/commit/238b94de)) feat: nav to credits after completing last puzzle_set - Russell Matney
- ([`47a0cddc`](https://github.com/russmatney/dothop/commit/47a0cddc)) feat: fancy unlocked-something sunbursty jumbotron - Russell Matney

  > Maybe annoying to some, but my gut is to be loud about unlocks, so i'm
  > going for it

- ([`f3cc0f03`](https://github.com/russmatney/dothop/commit/f3cc0f03)) feat: support resizing puzzle_list icons and adding columns - Russell Matney

  > This was annoying, but i finally figured out i need to kill the
  > custom_minimum_size on the animated vbox to get it to shrink properly.
  > The panel still seems a bit too tall in some cases, but w/e.

- ([`ab12668f`](https://github.com/russmatney/dothop/commit/ab12668f)) fix: disable layout randomization in hard-coded tests - Russell Matney
- ([`35d46b6a`](https://github.com/russmatney/dothop/commit/35d46b6a)) feat: impl and enable slight level randomization - Russell Matney

  > Randomly reverses xs and/or ys on each level. keeping it fresh!

- ([`e67237e7`](https://github.com/russmatney/dothop/commit/e67237e7)) feat: if all puzzles complete, select first puzzle icon - Russell Matney

  > Also moves the start-button focus grab up to prevent the arbitrary wait

- ([`de32570d`](https://github.com/russmatney/dothop/commit/de32570d)) feat: puzzle progress animation tweaks - Russell Matney

  > - waits a frame and hides the panel before toasting
  > - locks the puzzle_num so it's not off by one
  > - delays move-cursor a bit to fix alignment (yucky hard-coded number)
  > - adds margin and animation disable to animatedvbox


### 22 Feb 2024

- ([`900604e1`](https://github.com/russmatney/dothop/commit/900604e1)) feat: demo export supporting first two puzzle sets - Russell Matney

  > Pandora and feature tags made this really easy!
  > 
  > - Duplicates the existing windows/linux/web exports, renames them 'demo',
  > adds a feature tag 'demo', and gives them proper dist/dothop-demo-* directories.
  > - adds a new property to the puzzle sets: allowed_in_demo
  > - filters puzzles by allowed_in_demo in Store/State when first loading,
  > but only when the allowed_in_demo feature tag is set

- ([`012c345f`](https://github.com/russmatney/dothop/commit/012c345f)) wip: rough progress panel toast - Russell Matney

  > Not quite getting the right height, and pretty brittle as an implementation....

- ([`8c250099`](https://github.com/russmatney/dothop/commit/8c250099)) wip: basic toast animation - Russell Matney
- ([`213134c6`](https://github.com/russmatney/dothop/commit/213134c6)) chore: move jumbotron to core/ui dir - Russell Matney
- ([`1499d322`](https://github.com/russmatney/dothop/commit/1499d322)) feat: show puzzle progress on pause menu - Russell Matney
- ([`ad50d1e0`](https://github.com/russmatney/dothop/commit/ad50d1e0)) feat: break PuzzleProgressPanel out of PuzzleComplete scene - Russell Matney
- ([`351818b6`](https://github.com/russmatney/dothop/commit/351818b6)) fix: 'types' were causing unit test failures - Russell Matney

  > half-baked type system strikes again!
  > 
  > Also renames vars that are now colliding. Trying to keep some stateless
  > functions around...

- ([`54fe791a`](https://github.com/russmatney/dothop/commit/54fe791a)) fix: readme clean up credits layout - Russell Matney
- ([`dd5af56f`](https://github.com/russmatney/dothop/commit/dd5af56f)) feat: add devlog, trailer, itch links to readme - Russell Matney

### 21 Feb 2024

- ([`0c3f41b7`](https://github.com/russmatney/dothop/commit/0c3f41b7)) fix: y-sort on winter theme - Russell Matney

  > Refactors the puzzle-scene to add players last (so they're on top of
  > dotted/dots anims), and enables y-sort on the winter dots/players. Could
  > have handled the ysort in the code.... but we'll see how different these
  > themes need to be first.

- ([`182b0d99`](https://github.com/russmatney/dothop/commit/182b0d99)) refactor: Solver -> PuzzleAnalysis - Russell Matney

  > Moves from an analysis dictionary to a stronger type.

- ([`78934844`](https://github.com/russmatney/dothop/commit/78934844)) fix: do not accept unsupported mouse input events - Russell Matney

  > These cause crashes further along, b/c we don't support rendering of
  > mouse controls.

- ([`5e14f492`](https://github.com/russmatney/dothop/commit/5e14f492)) fix: early return in move_puzzle_cursor if icon is null - Russell Matney

  > if the next/prev world buttons are clicked repeatedly, the icon can be
  > gone by the time the call_in timer fn is called, resulting in a crash
  > when we try to read .global_position from null.

- ([`41eb6ef0`](https://github.com/russmatney/dothop/commit/41eb6ef0)) feat: don't call super.render() - Russell Matney

  > The parent render func is just debug stuff, nothing we need to worry
  > about.

- ([`a4bf2414`](https://github.com/russmatney/dothop/commit/a4bf2414)) sound: add gong sound to 'new-puzzle-set-unlocked' moment - Russell Matney
- ([`258c1825`](https://github.com/russmatney/dothop/commit/258c1825)) feat: clamp to a minimum pitch/scale_note - Russell Matney

  > Avoids some odd sounds on the lowest end. Sticking with the same
  > movement sound!

- ([`cf72a58a`](https://github.com/russmatney/dothop/commit/cf72a58a)) fix: support string paths, not just preloaded sounds - Russell Matney
- ([`738183ca`](https://github.com/russmatney/dothop/commit/738183ca)) feat: add ben_burnes symlink, credits, new music assigned - Russell Matney

  > Also updates the readme and fixes the credits rendering (the credit line
  > and header are now different font sizes).

- ([`b7111935`](https://github.com/russmatney/dothop/commit/b7111935)) feat: extend themes to support a list of optional music tracks - Russell Matney

  > Only the first will be played, but a list seems to be better long term.
  > This allows tracks to be referenced that may not exist in the repo (e.g.
  > during CI builds). If no track in the list is present, the
  > background_music property is used as a fallback.

- ([`d231a45c`](https://github.com/russmatney/dothop/commit/d231a45c)) feat: add link to github at top of credits - Russell Matney
- ([`2acc65e2`](https://github.com/russmatney/dothop/commit/2acc65e2)) fix: remove 'Calls to action' itch links in credits - Russell Matney

  > Steam rejected the build because i included text (unclickable!) links to
  > some of the free assets used to make this game. Calling these 'calls to
  > action' is quiet a stretch, and the language in the rejection says it's
  > ok if it goes through steam wallet... for free assets? Eh, bunch of
  > corpo bullshit.

- ([`4b59adbe`](https://github.com/russmatney/dothop/commit/4b59adbe)) tweak: adjusted asteroid animation speeds - Russell Matney

  > Plus an improved bee sprite


### 20 Feb 2024

- ([`df123ea4`](https://github.com/russmatney/dothop/commit/df123ea4)) chore: drop a bunch of completed or old TODOs - Russell Matney

### 19 Feb 2024

- ([`4c0d5b19`](https://github.com/russmatney/dothop/commit/4c0d5b19)) fix: set dothop-six for winter puzzles - Russell Matney
- ([`3324eb78`](https://github.com/russmatney/dothop/commit/3324eb78)) feat: support changing the puzzle number in the editor - Russell Matney

### 18 Feb 2024

- ([`330d5611`](https://github.com/russmatney/dothop/commit/330d5611)) wip: basic texture particle effect - Russell Matney
- ([`88f508eb`](https://github.com/russmatney/dothop/commit/88f508eb)) fix: return player finished moving signal - Russell Matney
- ([`2df0ecfe`](https://github.com/russmatney/dothop/commit/2df0ecfe)) wip: very bad bee sprite. yuck. - Russell Matney
- ([`0f165776`](https://github.com/russmatney/dothop/commit/0f165776)) feat: snow dots are now snowmen and puzzles - Russell Matney
- ([`dc07898a`](https://github.com/russmatney/dothop/commit/dc07898a)) feat: add progress/complete jumbotrons back in - Russell Matney

  > Puzzles can now opt-in to showing progress via 'show_progress' metadata
  > on the puzzle itself.

- ([`23a770e2`](https://github.com/russmatney/dothop/commit/23a770e2)) test: assert on arbitrary puzzle metadata - Russell Matney

  > Now optionally parsing meta flags/strings per puzzle

- ([`bd0638fd`](https://github.com/russmatney/dothop/commit/bd0638fd)) refactor: add GameDef, PuzzleDef types, rename level -> puzzle - Russell Matney

  > Solidifies the parsed GameDef and PuzzleDef types, and moves from
  > 'level' to 'puzzle' naming across the board.
  > 
  > Should be able to get the analysis data on the PuzzleDef as well - these
  > types should help with misc clean up and sorting by difficulty, etc.


### 17 Feb 2024

- ([`7c714997`](https://github.com/russmatney/dothop/commit/7c714997)) misc: comment, drop noise - Russell Matney
- ([`0caa4fa8`](https://github.com/russmatney/dothop/commit/0caa4fa8)) feat: adjust transition, move animation into 'rebuild' - Russell Matney

  > This is finally feeling better - all the animation work is done in
  > 'rebuild' instead of spread across a few places. this sets up potential
  > for handing some state from the previous puzzle to the next.

- ([`0bc71ab0`](https://github.com/russmatney/dothop/commit/0bc71ab0)) feat: display solver analysis on editor - Russell Matney

  > With various fixes

- ([`120c3a9e`](https://github.com/russmatney/dothop/commit/120c3a9e)) feat: smoother camera, tween delays instead of timeout awaits - Russell Matney

  > Rather than a function evolving into a generator, we pass arbitrary
  > delays to the tweens themselves.

- ([`1ff36c74`](https://github.com/russmatney/dothop/commit/1ff36c74)) feat: puzzle editor rendering fixes and rearrangement - Russell Matney
- ([`236c9059`](https://github.com/russmatney/dothop/commit/236c9059)) feat: pull Anim into dothop/src, eat animation logic - Russell Matney

  > Pulls dothop puzzle-node animation details into src/Anim.gd, which
  > cleans up the gamescene/puzzlescene/dot/player impls a bit. Starting to
  > look nicer here!

- ([`2f9f9ad6`](https://github.com/russmatney/dothop/commit/2f9f9ad6)) wip: remove jumbotron from puzzle-complete flow - Russell Matney

  > Kind of liking the instant transition here

- ([`3631a999`](https://github.com/russmatney/dothop/commit/3631a999)) fix: better movement, fix stuck-movement bug - Russell Matney

  > If we don't use the proper 'og-position' here, the node.position can be
  > some non-grid location, and it ends up being where the player rests
  > after moving 'back'.

- ([`ca6ad15c`](https://github.com/russmatney/dothop/commit/ca6ad15c)) fix: remove extra node.create_tween() - Russell Matney
- ([`6d5055ab`](https://github.com/russmatney/dothop/commit/6d5055ab)) feat: toying with intro/outro anims - Russell Matney
- ([`6ac5b44d`](https://github.com/russmatney/dothop/commit/6ac5b44d)) refactor: pull centering logic into puzzle_node - Russell Matney

  > And simplify the dothopcam

- ([`70f216d7`](https://github.com/russmatney/dothop/commit/70f216d7)) feat: slide to/from point anims - Russell Matney

  > And an animation-friendly camera-centering fix

- ([`c39c7ff0`](https://github.com/russmatney/dothop/commit/c39c7ff0)) feat: dots/goals further dry up - Russell Matney
- ([`bf863256`](https://github.com/russmatney/dothop/commit/bf863256)) refactor: player animation dry up - Russell Matney

  > I suppose i sort of let this get out of hand!

- ([`7cd21825`](https://github.com/russmatney/dothop/commit/7cd21825)) chore: DRY up a bunch of animation code - Russell Matney

  > A bit buggy in some places, but we def don't need 400 extra lines here

- ([`91f2612e`](https://github.com/russmatney/dothop/commit/91f2612e)) wip: DRYing up per theme animations - Russell Matney

### 16 Feb 2024

- ([`a59bb06f`](https://github.com/russmatney/dothop/commit/a59bb06f)) fix: call init_game_state, add cam only when inside tree - Russell Matney

  > Puzzle solver tests were crashing b/c of changes to the puzzle_scene -
  > this fixes them so they can still run without being added to the scene
  > tree.

- ([`93aed4df`](https://github.com/russmatney/dothop/commit/93aed4df)) feat: waits for player to finish moving before emitting win - Russell Matney

  > Need to update the other player move impls. Hopefully this doesn't
  > introduce any bugs!


### 15 Feb 2024

- ([`80de25bf`](https://github.com/russmatney/dothop/commit/80de25bf)) chore: drop phantom camera - Russell Matney

  > This addon is great, but doesn't fit the use-case for dothop.

- ([`9ca105be`](https://github.com/russmatney/dothop/commit/9ca105be)) refactor: move backgrounds to fixed canvas layers - Russell Matney
- ([`82b0570f`](https://github.com/russmatney/dothop/commit/82b0570f)) wip: basic camera that centers on puzzles - Russell Matney
- ([`b07d326d`](https://github.com/russmatney/dothop/commit/b07d326d)) wip: debug toggle for printing followed nodes - Russell Matney
- ([`8aca0869`](https://github.com/russmatney/dothop/commit/8aca0869)) fix: prevent initially dotted nodes from being followed - Russell Matney

  > Towards resolving the weird camera off-center issues

- ([`90efd16d`](https://github.com/russmatney/dothop/commit/90efd16d)) fix: prevent puzzle scenes from loading twice - Russell Matney
- ([`7605d979`](https://github.com/russmatney/dothop/commit/7605d979)) feat: better dot/player debug logs - Russell Matney

### 14 Feb 2024

- ([`3cf3fba5`](https://github.com/russmatney/dothop/commit/3cf3fba5)) wip: weak background tweak - Russell Matney

  > These and the camera really aren't working :/

- ([`33618ade`](https://github.com/russmatney/dothop/commit/33618ade)) feat: working pcam on sub-viewport rendered puzzle scene - Russell Matney

  > Editor nearly useful - making it clear the phantom_camera and
  > backgrounds aren't well configured for most scenes!

- ([`bfa8357d`](https://github.com/russmatney/dothop/commit/bfa8357d)) feat: rendering selected puzzle via subviewport - Russell Matney

  > Looks pretty gross, but things are kind of working!

- ([`fc647027`](https://github.com/russmatney/dothop/commit/fc647027)) feat: rearrange dot/dotted/goal state in puzzle_set uis - Russell Matney
- ([`4eafffbc`](https://github.com/russmatney/dothop/commit/4eafffbc)) feat: add goal_icon textures for every theme - Russell Matney
- ([`55619861`](https://github.com/russmatney/dothop/commit/55619861)) feat: space player different color and 'moving' animation - Russell Matney
- ([`fd474fff`](https://github.com/russmatney/dothop/commit/fd474fff)) feat: fall theme using 'dotted' icon in ui - Russell Matney
- ([`1d402daa`](https://github.com/russmatney/dothop/commit/1d402daa)) feat: 'dotted' frame for each leaf in the fall theme - Russell Matney
- ([`0ac9b3df`](https://github.com/russmatney/dothop/commit/0ac9b3df)) feat: set random anim frames on dots - Russell Matney
- ([`6f1c28b7`](https://github.com/russmatney/dothop/commit/6f1c28b7)) refactor: theme handling within puzzleScene - Russell Matney

  > Rather than handling theme stuff in the gameScene, we let the
  > puzzleScene use themes directly, which is cleaner and sets up the
  > puzzle-set editor to more easily use the puzzleScene itself.
  > 
  > Also cleans up the theme.puzzle_scenes - generated shapes don't set
  > their owner in the editor to reduce the git-noise/churn when on what
  > should be fairly simple puzzle tscns

- ([`d4ea2b6d`](https://github.com/russmatney/dothop/commit/d4ea2b6d)) refactor: get themes from the store, not pandora - Russell Matney

  > A bit cleaner.

- ([`6f6d9c68`](https://github.com/russmatney/dothop/commit/6f6d9c68)) chore: remove unused code and controls - Russell Matney
- ([`22260d88`](https://github.com/russmatney/dothop/commit/22260d88)) fix: proper worldmap puzzle nav button disable - Russell Matney

  > Plus a fix to grabbing focus when all puzzles are 'complete'.

- ([`c2393409`](https://github.com/russmatney/dothop/commit/c2393409)) feat: better puzzle complete layout - Russell Matney

  > Larger fonts, larger buttons, smaller margins, etc.

- ([`4358933a`](https://github.com/russmatney/dothop/commit/4358933a)) fix: drop fall theme move sound - Russell Matney

  > This sound doesn't work as well as the default.


### 13 Feb 2024

- ([`dafc1c0f`](https://github.com/russmatney/dothop/commit/dafc1c0f)) feat: selecting and rendering themed puzzles on click - Russell Matney

  > tho, the backgrounds are completely blocking the ui after load :/

- ([`741cf096`](https://github.com/russmatney/dothop/commit/741cf096)) wip: logging the shape of the selected puzzle - Russell Matney

  > now, how best to render this thing? with the game scene of course!

- ([`788b38c3`](https://github.com/russmatney/dothop/commit/788b38c3)) wip: listing puzzles as icons in the editor - Russell Matney
- ([`8903b897`](https://github.com/russmatney/dothop/commit/8903b897)) wip: early PuzzleScriptEditor - Russell Matney

  > just pretty-printing puzzle_set entities

- ([`dfbcf7a4`](https://github.com/russmatney/dothop/commit/dfbcf7a4)) feat: slightly more interesting credits - Russell Matney

  > Creates a credit header with a bolder font applied to '# blah' prefixed
  > sections. Could really use some color here/text-effects to differentiate
  > here.

- ([`b3c25a11`](https://github.com/russmatney/dothop/commit/b3c25a11)) fix: resume worldmap music when naving back from game scene - Russell Matney

  > Was stopping music too aggressively here. of note - the next scene's
  > _ready fires before the current scene's _exit_tree! wut!

- ([`dc692948`](https://github.com/russmatney/dothop/commit/dc692948)) feat: update puzzle_num in hud on next puzzle rebuild - Russell Matney

  > Rather than inc when the current puzzle is complete, which feels odd

- ([`3f1e6ed5`](https://github.com/russmatney/dothop/commit/3f1e6ed5)) feat: confirmation dialogue theme - Russell Matney
- ([`af818186`](https://github.com/russmatney/dothop/commit/af818186)) fix: edit one control at a time, listen to _input() - Russell Matney

  > Better flow for updating controls - editing a second control will cancel
  > the first, if it's floating open. Better listening - _unhandled_input()
  > was causing movement inputs to also move the on-screen focus - using
  > _input() seems to prevent this.
  > 
  > Unfortunately still some issues here: InputHelper doesn't seem to
  > provide a way to 'move' a control, only 'swap' or 'assign to both',
  > which is annoying for the redundant movement helpers i have in
  > place (hjkl/wasd/arrows).

- ([`bdfe33ad`](https://github.com/russmatney/dothop/commit/bdfe33ad)) fix: prefer space over enter for ui_accept hints - Russell Matney
- ([`1801a84b`](https://github.com/russmatney/dothop/commit/1801a84b)) fix: move to queue_free - maybe fix a recurring error? - Russell Matney
- ([`dafd074c`](https://github.com/russmatney/dothop/commit/dafd074c)) fix: adjust hover font color - Russell Matney

  > Helps differentiate hovering buttons with the mouse vs 'focusing'
  > buttons with the keyboard/controller.

- ([`87d8c339`](https://github.com/russmatney/dothop/commit/87d8c339)) fix: actually disable buttons (incl. focus and mouse) - Russell Matney

  > disabling a button doesn't update the mouse or focus bits, so they are
  > still 'selectable' in the ui. This adds a helper to Util to clean up the
  > noise.

- ([`fadaa827`](https://github.com/russmatney/dothop/commit/fadaa827)) fix: resolution 1280x720, scale_mode back to fractional - Russell Matney
- ([`16d1bb8f`](https://github.com/russmatney/dothop/commit/16d1bb8f)) feat: wait longer before grabbing focus - Russell Matney

  > on the steam deck, the worldmap screen fails to grab focus, but it seems
  > to work fine on linux, even with a controller. maybe just some kind of
  > deferred timing issue? Here we call a bit later and hope it works.

- ([`57590d70`](https://github.com/russmatney/dothop/commit/57590d70)) fix: windows build disabled embed_pck - Russell Matney

  > Hoping this fixes the launch security issue

- ([`38278ba8`](https://github.com/russmatney/dothop/commit/38278ba8)) fix: kill jumbotron when navigating - Russell Matney

  > Adds a signal to navi -> hopefully we're using Navi for all navigation,
  > or maybe there's some godot-native signal we should be using for this...

- ([`87a96e86`](https://github.com/russmatney/dothop/commit/87a96e86)) puzz: rearrange final two winter levels - Russell Matney
- ([`823af742`](https://github.com/russmatney/dothop/commit/823af742)) fix: prevent crash when closing old jumbotron - Russell Matney
- ([`d720dbe8`](https://github.com/russmatney/dothop/commit/d720dbe8)) chore: larger puzz complete header - Russell Matney

  > Plus, clean up event printing log (don't log puzzle-complete events).


### 12 Feb 2024

- ([`6809f129`](https://github.com/russmatney/dothop/commit/6809f129)) fix: wider min-width on puzzles panel - Russell Matney
- ([`ab4932d4`](https://github.com/russmatney/dothop/commit/ab4932d4)) chore: drop unused font - Russell Matney
- ([`fb51aaf8`](https://github.com/russmatney/dothop/commit/fb51aaf8)) feat: re-order puzzle sets - Russell Matney

  > the order is now: dots, spring, summer, fall, winter, space
  > 
  > Also cleans up some old 'messages' from the raw puzzle files.

- ([`3680ebdd`](https://github.com/russmatney/dothop/commit/3680ebdd)) feat: include 'unlock' text on puzzleComplete screen - Russell Matney
- ([`3fcd9e84`](https://github.com/russmatney/dothop/commit/3fcd9e84)) feat: add some more winning phrases - Russell Matney
- ([`8766b151`](https://github.com/russmatney/dothop/commit/8766b151)) feat: use PuzzleComplete for PuzzleSetComplete as well - Russell Matney
- ([`a854305e`](https://github.com/russmatney/dothop/commit/a854305e)) feat: puzzleComplete jumbotron impled, animating some progress - Russell Matney
- ([`24866030`](https://github.com/russmatney/dothop/commit/24866030)) fix: add count for duplicate events - Russell Matney

  > Completing puzzles multiple times was resulting in duplicate events,
  > which could eventually blow up the save file size - this instead looks
  > for a matching event, updating a count field on it if found.

- ([`7e02893c`](https://github.com/russmatney/dothop/commit/7e02893c)) todo: completing a puzzle multiple times creates multiple save events - Russell Matney

  > Worth dealing with this sooner than later

- ([`1c9bfbc3`](https://github.com/russmatney/dothop/commit/1c9bfbc3)) feat: start worldmap on next-puzzle-to-complete - Russell Matney
- ([`86b0621e`](https://github.com/russmatney/dothop/commit/86b0621e)) feat: save puzzle complete events, remove pause nav confirmations - Russell Matney

  > These confirmations are no longer accurate - puzzle progress is saved
  > per-puzzle now.

- ([`39479247`](https://github.com/russmatney/dothop/commit/39479247)) feat: buttons for navigating between puzzle sets - Russell Matney

  > Also supporting starting on an arbitrarily selected puzzle.

- ([`57cbc2ee`](https://github.com/russmatney/dothop/commit/57cbc2ee)) feat: animated 'cursor' jumping to next level icon - Russell Matney
- ([`15622ae0`](https://github.com/russmatney/dothop/commit/15622ae0)) feat: distinguish completed/current/incomplete puzzles on world map - Russell Matney
- ([`31768d18`](https://github.com/russmatney/dothop/commit/31768d18)) chore: bunch of scene id churn - Russell Matney
- ([`07e92af3`](https://github.com/russmatney/dothop/commit/07e92af3)) test: coverage for PuzzleCompleted events - Russell Matney

  > A basic test asserting:
  > - the expected events are created
  > - puzzleSet.can_play_puzzle(index) works as expected

- ([`ed3228d9`](https://github.com/russmatney/dothop/commit/ed3228d9)) fix: assign script_path and generate event id - Russell Matney

  > Missed this bit of configuration that i depend on - was accidentally
  > creating puzzleset events, not puzzle events.

- ([`bde9246f`](https://github.com/russmatney/dothop/commit/bde9246f)) feat: PuzzleCompleted event and gamestate handling - Russell Matney

  > Extends the PuzzleSet model to track a max_completed_puzzle_index, and
  > adds a new event for updating that index.


### 9 Feb 2024

- ([`82f8eaea`](https://github.com/russmatney/dothop/commit/82f8eaea)) feat: macos export and steam vdf - Russell Matney
- ([`0a436154`](https://github.com/russmatney/dothop/commit/0a436154)) fix: rename DotHopTheme > PuzzleTheme, fix osx - Russell Matney

  > Getting the latest running on osx is a big pain every time lately, kind
  > of annoying.

- ([`41485dc0`](https://github.com/russmatney/dothop/commit/41485dc0)) misc: asset exports, scene id churn - Russell Matney
- ([`8af7ad4a`](https://github.com/russmatney/dothop/commit/8af7ad4a)) export: windows export and steam deploy vdf - Russell Matney

### 8 Feb 2024

- ([`292052ec`](https://github.com/russmatney/dothop/commit/292052ec)) fix: restore muting music - Russell Matney

  > A quick hack to restore the mute-music feature. SoundManager expects a
  > separate audio bus to exist, so here we create one for music and update
  > dj's mute impl to also mute using the SoundManager's music funcs.
  > 
  > oh and a bunch of updated node ids i guess.


### 7 Feb 2024

- ([`32e49100`](https://github.com/russmatney/dothop/commit/32e49100)) chore: comment todo - Russell Matney
- ([`72196471`](https://github.com/russmatney/dothop/commit/72196471)) wip: attempt to resume music when naving back to worldmap - Russell Matney
- ([`7ddad5c1`](https://github.com/russmatney/dothop/commit/7ddad5c1)) feat: showing theme-based icons for complete/incomplete puzzles - Russell Matney
- ([`cdfa5c8d`](https://github.com/russmatney/dothop/commit/cdfa5c8d)) feat: add player/dot/dotted icon textures to puzzle themes - Russell Matney

  > Then assign something for each. Feels like this maybe needs to be a list
  > rather than 1:1 - we have more than one dot texture per theme :/

- ([`603e3a6c`](https://github.com/russmatney/dothop/commit/603e3a6c)) feat: expand input map, support button-credit scroll - Russell Matney

  > The input map now supports playing with either joystick, and using
  > rb/lb/rt/lt to undo/restart.
  > 
  > the credits can now be scrolled with b/y instead of just up/down.
  > annoyingly the joystick up/down is not detected, but dpads work fine.

- ([`999b4030`](https://github.com/russmatney/dothop/commit/999b4030)) fix: jumbotron oversize fix, ui_accept input shown - Russell Matney
- ([`008b01d6`](https://github.com/russmatney/dothop/commit/008b01d6)) feat: jumbotron dismiss with a, not just b - Russell Matney
- ([`f9ef19bb`](https://github.com/russmatney/dothop/commit/f9ef19bb)) feat: refactor into song-per-theme, use SoundManager - Russell Matney

  > Now doing music via the SoundManager rather than DJ.

- ([`6eccf327`](https://github.com/russmatney/dothop/commit/6eccf327)) chore: drop unused script - Russell Matney
- ([`0da5daa9`](https://github.com/russmatney/dothop/commit/0da5daa9)) feat: add credits for song, sounds - Russell Matney
- ([`0966b7b0`](https://github.com/russmatney/dothop/commit/0966b7b0)) feat: play music on title, opts, worldmap screens - Russell Matney

  > Using that same song i use everywhere.

- ([`5c7dd7a1`](https://github.com/russmatney/dothop/commit/5c7dd7a1)) feat: drop unused sounds, some music tracks - Russell Matney
- ([`7981ec33`](https://github.com/russmatney/dothop/commit/7981ec33)) wip: very rough ascending pitch_scale - Russell Matney

  > Not finished at all, but more or less doing the thing.


### 6 Feb 2024

- ([`60a3927d`](https://github.com/russmatney/dothop/commit/60a3927d)) wip: first draft generator (by @camsbury) - Russell Matney

  > Comments out the 'short' bits for now, and this is working a bb repl!

- ([`d2e877a4`](https://github.com/russmatney/dothop/commit/d2e877a4)) feat: re-org worldmap to use one panel instead of two - Russell Matney

  > Cleaner worldmap. For now every world is traversible regardless of progress.

- ([`ddec3517`](https://github.com/russmatney/dothop/commit/ddec3517)) fix: more focus grabbing on start/opts menus - Russell Matney
- ([`32e6a2c9`](https://github.com/russmatney/dothop/commit/32e6a2c9)) fix: drop noisey logs - Russell Matney
- ([`00f58726`](https://github.com/russmatney/dothop/commit/00f58726)) feat: pause menu animating and grabbing focus - Russell Matney
- ([`8721560c`](https://github.com/russmatney/dothop/commit/8721560c)) feat: animated vbox, fade_in helpers - Russell Matney

  > Slightly animates some ui in places. Tries to reduce button-focus noise,
  > but it's still pretty annoying.

- ([`e4edcd39`](https://github.com/russmatney/dothop/commit/e4edcd39)) feat: quick hack to add sound to button-focus/press events - Russell Matney
- ([`6b57ab18`](https://github.com/russmatney/dothop/commit/6b57ab18)) chore: drop enter-input from assets, credits, readme - Russell Matney
- ([`04b591ee`](https://github.com/russmatney/dothop/commit/04b591ee)) refactor: move input-icon to kenney input-prompts - Russell Matney

  > Copies the existing vexed/enter-input icon comp to EnterInputIcon, then
  > refactors actionInputIcon to resolve to a texture rather than a key.
  > 
  > Drops mods for now - we may need to move from a textureRect to an hbox
  > to support multi-key inputs.

- ([`def50b7b`](https://github.com/russmatney/dothop/commit/def50b7b)) chore: move menus controls scenes into menus/controls - Russell Matney
- ([`b6d352c5`](https://github.com/russmatney/dothop/commit/b6d352c5)) chore: add kenney input prompts - Russell Matney

### 5 Feb 2024

- ([`fe744f10`](https://github.com/russmatney/dothop/commit/fe744f10)) feat: port dino/thanks into addons/core/credits - Russell Matney

  > And impl a rough credits setup for dothop, including most (all?) of the
  > creditors.

- ([`4660e550`](https://github.com/russmatney/dothop/commit/4660e550)) feat: proper hover state styles for buttons - Russell Matney
- ([`42a976de`](https://github.com/russmatney/dothop/commit/42a976de)) chore: move styles/ui comps from addons/core/ui to src/ui - Russell Matney
- ([`4942627e`](https://github.com/russmatney/dothop/commit/4942627e)) fix: better game state load log - Russell Matney
- ([`0cfb51c7`](https://github.com/russmatney/dothop/commit/0cfb51c7)) refactor: mute button explicit focus handling - Russell Matney

  > refactors the mute button list away from the ButtonList usage, so that
  > re-rendering and focus can be handled explicitly. prevents focus loss
  > when muting/unmuting. not perfect, but functional.

- ([`4144dd2b`](https://github.com/russmatney/dothop/commit/4144dd2b)) feat: modify pause menu from worldmap vs game - Russell Matney
- ([`d4a2d4d0`](https://github.com/russmatney/dothop/commit/d4a2d4d0)) feat: back to worldmap from pause menu - Russell Matney
- ([`38c944d6`](https://github.com/russmatney/dothop/commit/38c944d6)) fix: update hud control helpers when controls are changed - Russell Matney
- ([`ef2c9fae`](https://github.com/russmatney/dothop/commit/ef2c9fae)) feat: move global pause toggle to per-scene handling - Russell Matney

  > The global version is convenient, but allows for pausing on the title
  > and options screens, which is annoying. This moves to explicit support
  > in the worldmap and game scene, plus unpausing. note that we're marking
  > the event as handled to avoid immediately unpausing when pause is
  > pressed.

- ([`d8ea3f92`](https://github.com/russmatney/dothop/commit/d8ea3f92)) feat: main menu refactor - Russell Matney

  > Moves to a more explicit main menu (rather than using the button-list
  > style). This gives more control and overall is just simpler.
  > 
  > Sets the quit button to be red.

- ([`000a3648`](https://github.com/russmatney/dothop/commit/000a3648)) feat: pause menu with toggleable sections - Russell Matney

  > controls, themes, sound controls

- ([`bb518971`](https://github.com/russmatney/dothop/commit/bb518971)) refactor: break out and reuse ControlsPanel - Russell Matney

  > cleans up the options and pause menus. Drops quick-theme swapping for
  > now.


### 4 Feb 2024

- ([`3b9232b1`](https://github.com/russmatney/dothop/commit/3b9232b1)) feat: rough bg art on winter, spring, summer themes - Russell Matney
- ([`1663aeec`](https://github.com/russmatney/dothop/commit/1663aeec)) feat: move theme player/dots/goals into pandora arrays - Russell Matney

  > This sets up a way to create themes with multiple dot/player impls. it
  > also reveals that sounds right now are not tied to dots, but to
  > theme-puzzle-scenes.

- ([`2fe7b717`](https://github.com/russmatney/dothop/commit/2fe7b717)) fix: move to 'n dots left' label - Russell Matney
- ([`6c920301`](https://github.com/russmatney/dothop/commit/6c920301)) fix: move undo emit so the hud picks up 'direct' undos - Russell Matney

  > undos via controls (vs. moving 'backwards') were not updating the hud.

- ([`29ec0089`](https://github.com/russmatney/dothop/commit/29ec0089)) fix: don't include 'goal' in dot counts - Russell Matney
- ([`bdefd55f`](https://github.com/russmatney/dothop/commit/bdefd55f)) feat: more copy options after beating a puzzle - Russell Matney
- ([`e947808c`](https://github.com/russmatney/dothop/commit/e947808c)) fix: check out dot/dotted type again after timeout - Russell Matney
- ([`38f7d1df`](https://github.com/russmatney/dothop/commit/38f7d1df)) chore: rename DotHopTheme to DHTheme - Russell Matney

  > I wanted just 'Theme', but that class already exists :/

- ([`6df1e276`](https://github.com/russmatney/dothop/commit/6df1e276)) feat: stop music when exiting game scene - Russell Matney

  > Also support stopping music without knowing what song is playing.

- ([`358af1a7`](https://github.com/russmatney/dothop/commit/358af1a7)) feat: hop between puzzle-islands in more linear world-map - Russell Matney
- ([`6cb8b62d`](https://github.com/russmatney/dothop/commit/6cb8b62d)) feat: worldmap clean up and split - Russell Matney

### 2 Feb 2024

- ([`110c810a`](https://github.com/russmatney/dothop/commit/110c810a)) feat: each world as a rows of color rects - Russell Matney
- ([`189f11c4`](https://github.com/russmatney/dothop/commit/189f11c4)) wip: add children to puzzlemap shape - Russell Matney

  > also exposes the worldmap zoom factors

- ([`39af08bf`](https://github.com/russmatney/dothop/commit/39af08bf)) feat: include icon in generated puzzle map - Russell Matney

### 1 Feb 2024

- ([`ae1d30ef`](https://github.com/russmatney/dothop/commit/ae1d30ef)) tweak: delay/mix-up the on-focus map scaling - Russell Matney
- ([`4f8392c0`](https://github.com/russmatney/dothop/commit/4f8392c0)) wip: generated world map moving to per-puzzle-set markers - Russell Matney
- ([`0a2c8297`](https://github.com/russmatney/dothop/commit/0a2c8297)) feat: prevent repeat colors - Russell Matney
- ([`3e63a7d1`](https://github.com/russmatney/dothop/commit/3e63a7d1)) feat: center puzzle-maps on the y axis - Russell Matney
- ([`59eca764`](https://github.com/russmatney/dothop/commit/59eca764)) fix: don't forget to defer that add_child - Russell Matney
- ([`d17a6d21`](https://github.com/russmatney/dothop/commit/d17a6d21)) chore: a bunch of reimports, i guess? - Russell Matney

  > not sure why this is necessary, but it was automated, so :shrug: guess
  > i'll toggle it back when i'm on my other machine again.

- ([`119be6c0`](https://github.com/russmatney/dothop/commit/119be6c0)) fix: drop removed features from dj/plugin.gd - Russell Matney

  > These scenes were dropped, but i didn't clean up the plugin.gd at all :/

- ([`c050ec32`](https://github.com/russmatney/dothop/commit/c050ec32)) wip: towards generating a puzzle map - Russell Matney

  > - util add_color_rect gets a deferred=bool flag
  > 
  > - puzzle solver doesn't need to 'add_child' before analyzing, which
  >   makes it way cheaper and faster
  > 
  > - starts a PuzzleMap scene that pulls from new puzzle_set properties and
  >   computes puzzle_set dimensions (like max width/height)

- ([`dd81f28f`](https://github.com/russmatney/dothop/commit/dd81f28f)) wip: playing music when starting a puzzle - Russell Matney

  > unfortunately not stopping it, and layering more music if you keep
  > playing :)

- ([`2fe5d9eb`](https://github.com/russmatney/dothop/commit/2fe5d9eb)) feat: examples of overwriting - Russell Matney

  > These could be informed by @exports too if we want ui support.

- ([`430cf333`](https://github.com/russmatney/dothop/commit/430cf333)) feat: basic sound on player moves/blocked moves - Russell Matney
- ([`a4f6a0bd`](https://github.com/russmatney/dothop/commit/a4f6a0bd)) refactor: minimize DJ, move assets into dothop proper - Russell Matney

  > Towards figuring out what sound/music assets this game really needs

- ([`2169d46d`](https://github.com/russmatney/dothop/commit/2169d46d)) chore: add godot sound manager - Russell Matney

### 31 Jan 2024

- ([`1c1cce72`](https://github.com/russmatney/dothop/commit/1c1cce72)) fix: final puzzle is now solvable (heh) - Russell Matney
- ([`e9368687`](https://github.com/russmatney/dothop/commit/e9368687)) feat: add width/height to level_def and solver result - Russell Matney
- ([`27a93ee2`](https://github.com/russmatney/dothop/commit/27a93ee2)) feat: test for every puzzle, to be sure they're all solvable - Russell Matney

  > Turns out they're not!

- ([`e24174dd`](https://github.com/russmatney/dothop/commit/e24174dd)) feat: puzzle solver + analysis, with tests - Russell Matney

  > Couple recursive functions to build up a move-tree and then convert it
  > to a list of paths. Not too shabby! Some tweaks to the puzzleScene code:
  > 
  > - return true from puzzle.move() to indicate if a move was made
  > - set the state.win back to false when an 'undo' is performed
  > 
  > These helped the solver run, hopefully they won't get lost somewhere
  > along the way.


### 30 Jan 2024

- ([`413d8e49`](https://github.com/russmatney/dothop/commit/413d8e49)) wip: impling a puzzle solver - Russell Matney
- ([`edfc7989`](https://github.com/russmatney/dothop/commit/edfc7989)) fix: apparently the parser can't handle 1 line puzzles - Russell Matney
- ([`88a43aec`](https://github.com/russmatney/dothop/commit/88a43aec)) fix: restore dothop puzzle tests - Russell Matney

  > Similarly, nested test cases don't run. Or maybe it was b/c of the
  > inheritance? eh, these are better flattened anyway.

- ([`4e1834c1`](https://github.com/russmatney/dothop/commit/4e1834c1)) fix: restore parse tests - Russell Matney

  > Apparently these have not been running - seems that gdunit4 doesn't
  > support nested test cases, must have been a mistake on my part when i
  > switched from GUT

- ([`e252056d`](https://github.com/russmatney/dothop/commit/e252056d)) fix: drop hard-coded puzzle-count test - Russell Matney
- ([`1c596833`](https://github.com/russmatney/dothop/commit/1c596833)) puzzles: seven more snow levels - Russell Matney
- ([`a62dd6b6`](https://github.com/russmatney/dothop/commit/a62dd6b6)) chore: drop unused puzzlescript sections - Russell Matney

  > also adds back some dropped levels from the first world

- ([`9cdf44ff`](https://github.com/russmatney/dothop/commit/9cdf44ff)) puzzles: seven more spring levels - Russell Matney
- ([`538482b0`](https://github.com/russmatney/dothop/commit/538482b0)) puzzles: seven more beach puzzles - Russell Matney
- ([`0b894574`](https://github.com/russmatney/dothop/commit/0b894574)) fix: should be greater than 0, not 1 - Russell Matney
- ([`f0c816b1`](https://github.com/russmatney/dothop/commit/f0c816b1)) feat: confirmation dialogs, reset/unlock data buttons - Russell Matney

  > Improves but does not finish out some basic confirmation dialog styles.

- ([`fd37bb9f`](https://github.com/russmatney/dothop/commit/fd37bb9f)) feat: unlock-all-puzzles button on options menu - Russell Matney

  > plus misc menu clean up.

- ([`b1a01622`](https://github.com/russmatney/dothop/commit/b1a01622)) chore: phantom camera update - Russell Matney
- ([`bf1a5ca7`](https://github.com/russmatney/dothop/commit/bf1a5ca7)) feat: working event-y save-game feature - Russell Matney

  > The final change was to drop the reference property in favor of a string
  > entity_id. It's much weaker but it actually works. I suspect the
  > deserialized reference type was coming out as a string? Not really sure
  > what happened. A lingering concern is events failing to deserialize -
  > deleting the property seemed to break the deserialization :/
  > 
  > Anyway, happy to move forward with this for now.


### 29 Jan 2024

- ([`58ee70dc`](https://github.com/russmatney/dothop/commit/58ee70dc)) wip: more event-save-game refactor pseudo code - Russell Matney
- ([`4eb262af`](https://github.com/russmatney/dothop/commit/4eb262af)) wip: create events and sub-event categories - Russell Matney

  > A bunch of pandora entities and more implementation in place.

- ([`f91b2a15`](https://github.com/russmatney/dothop/commit/f91b2a15)) wip: breaks everything, mid-savegame refactor - Russell Matney
- ([`7e38f402`](https://github.com/russmatney/dothop/commit/7e38f402)) fix: free orphan nodes after test run - Russell Matney
- ([`c495ebf2`](https://github.com/russmatney/dothop/commit/c495ebf2)) chore: looser unit test on initial data - Russell Matney

  > It's enough to ensure it's playable

- ([`2fac169e`](https://github.com/russmatney/dothop/commit/2fac169e)) feat: switch space theme player to the goal-star - Russell Matney
- ([`64528613`](https://github.com/russmatney/dothop/commit/64528613)) fix: this puzzle was impossible - Russell Matney

  > ought to impl a solver to be sure this doesn't happen on accident.

- ([`a45b174d`](https://github.com/russmatney/dothop/commit/a45b174d)) fix: parser adding empty levels b/c of blank lines - Russell Matney

  > I'd solved this in dino's parser, finally hit it here.

- ([`fa5738fb`](https://github.com/russmatney/dothop/commit/fa5738fb)) note: big todo comment add re: data migrations - Russell Matney

  > I added 3 new puzzle sets, but they aren't showing up in game b/c the
  > save-game code only fetches puzzle_sets that were saved.
  > 
  > I'm realizing it'd be better to save user events than to save some
  > specific state of the data - it'll be simpler to have a list of events
  > like 'completed-puzzle-set {set=FALL}' that can be used to recreate a
  > working state - that'll be able to be reapplied to updated data, which
  > should reduce migration complexity. Plus those events will probably be
  > useful for other things, like achievements and records and such.

- ([`f5f0e074`](https://github.com/russmatney/dothop/commit/f5f0e074)) feat: rough intro puzzles for winter, spring, summer - Russell Matney

### 28 Jan 2024

- ([`42900266`](https://github.com/russmatney/dothop/commit/42900266)) fix: delete spring/summer *.import, resave all scenes - Russell Matney

  > Kind of a PITA - it seems like the editor uses paths to find assets, but
  > the game uses the uids, which were wrong b/c of my copy-pasting. yuck!

- ([`c6a28ed7`](https://github.com/russmatney/dothop/commit/c6a28ed7)) wip: spring and summer themes - Russell Matney

  > Feels like these should be working, but they're showing the winter theme
  > instead... no idea why

- ([`5733e717`](https://github.com/russmatney/dothop/commit/5733e717)) feat: winter theme, space and fall theme goal cleanups - Russell Matney

  > plus some new asteroid art


### 25 Jan 2024

- ([`a4002f62`](https://github.com/russmatney/dothop/commit/a4002f62)) fix: these settings seem to toggle when opened on mac - Russell Matney
- ([`f89366c2`](https://github.com/russmatney/dothop/commit/f89366c2)) fix: drop mac notif approach - Russell Matney

  > Not working that great, annoying when it crashes


### 24 Jan 2024

- ([`a4a46bd3`](https://github.com/russmatney/dothop/commit/a4a46bd3)) style: main menu cleanup, button focus styles fix - Russell Matney
- ([`e771a429`](https://github.com/russmatney/dothop/commit/e771a429)) feat: reset save data in options panel - Russell Matney
- ([`2a3c681e`](https://github.com/russmatney/dothop/commit/2a3c681e)) chore: misc notes and clean up - Russell Matney
- ([`a346e967`](https://github.com/russmatney/dothop/commit/a346e967)) test: checking that new properties don't break serialization - Russell Matney

  > I looked in pandora briefly for coverage for a case like this, and
  > pulled a test from there to work from.

- ([`616c417c`](https://github.com/russmatney/dothop/commit/616c417c)) test: basic savegame roundtrip - Russell Matney

  > Still a problem to solve here - how to make sure updated code/entities
  > aren't breaking existing save games. basically db migrations :/

- ([`10b6f734`](https://github.com/russmatney/dothop/commit/10b6f734)) feat: basic Store usage tests - Russell Matney

  > Basic tests for fetching/unlocking puzzle_sets, and fetching themes.

- ([`12fcd0ef`](https://github.com/russmatney/dothop/commit/12fcd0ef)) feat: unlocking the next puzzle-set when completing the previous - Russell Matney

  > Save/Load seems to be working! These puzzles are too hard to test tho.

- ([`535f4738`](https://github.com/russmatney/dothop/commit/535f4738)) feat: impl saveGame (untested) - Russell Matney

  > Reading and writing jsonified data to/from disk, and
  > serializing/deserializing it in the Store.

- ([`32bf1e05`](https://github.com/russmatney/dothop/commit/32bf1e05)) feat: basic Store impl with puzzle_sets and themes - Russell Matney
- ([`627770c4`](https://github.com/russmatney/dothop/commit/627770c4)) refactor: move game, levelGen, puzzle into puzzle/* - Russell Matney

  > And drop the 'DotHop' naming prefix.


### 23 Jan 2024

- ([`0fedd7e9`](https://github.com/russmatney/dothop/commit/0fedd7e9)) wip: towards savegame feats - Russell Matney
- ([`b3186f1a`](https://github.com/russmatney/dothop/commit/b3186f1a)) refactor: move parsers to parse - Russell Matney
- ([`56c6274f`](https://github.com/russmatney/dothop/commit/56c6274f)) feat: disable puzzle sets that aren't 'unlocked' - Russell Matney
- ([`92717065`](https://github.com/russmatney/dothop/commit/92717065)) feat: add puzzle set icon to puzzle list container - Russell Matney

  > It's something.

- ([`1a396ae9`](https://github.com/russmatney/dothop/commit/1a396ae9)) refactor: rename DotHopPuzzleSet -> PuzzleSet - Russell Matney

  > Also add an icon_texture to the PuzzleSet entity

- ([`a1990005`](https://github.com/russmatney/dothop/commit/a1990005)) feat: world map showing grid of puzzles per puzzle set - Russell Matney
- ([`ee56e683`](https://github.com/russmatney/dothop/commit/ee56e683)) feat: world map gui layout - Russell Matney

  > Rearranges and adds a floating list to be filled with per puzzle-set puzzles.

- ([`89698645`](https://github.com/russmatney/dothop/commit/89698645)) chore: update gdunit - Russell Matney
- ([`5128915b`](https://github.com/russmatney/dothop/commit/5128915b)) chore: set some gdunit config - Russell Matney

  > Trying to get these tests actually running


### 22 Jan 2024

- ([`9391cc06`](https://github.com/russmatney/dothop/commit/9391cc06)) refactor: rename NaviButtonList -> ButtonList - Russell Matney

  > Dropping this namespace, it's not helping much

- ([`366204e3`](https://github.com/russmatney/dothop/commit/366204e3)) feat: add new themes/styles to pause menu - Russell Matney

  > Also fix some broken worldmap/menu paths.

- ([`4ff578c0`](https://github.com/russmatney/dothop/commit/4ff578c0)) feat: world map recenters based on button focus - Russell Matney

  > Not too bad!

- ([`c53521a6`](https://github.com/russmatney/dothop/commit/c53521a6)) feat: basic position and scale tween for zoom effect - Russell Matney
- ([`b3ae8c69`](https://github.com/russmatney/dothop/commit/b3ae8c69)) feat: basic 2d world map adjusting to assigned marker - Russell Matney

  > Now to connect this to the button focus events

- ([`0e56f022`](https://github.com/russmatney/dothop/commit/0e56f022)) feat: red, blue buttons and a PaperHeroLabelTheme - Russell Matney

  > Getting the hang of theming...i think

- ([`cfda7c95`](https://github.com/russmatney/dothop/commit/cfda7c95)) fix: scale up base 9-patch textures - Russell Matney

  > Scaling these up allows the corners of the textures to scale as well,
  > which gives them the pixellated character we've been missing.

- ([`5d47b568`](https://github.com/russmatney/dothop/commit/5d47b568)) feat: controls panel styles - green edit button, paper label - Russell Matney
- ([`f0b124bb`](https://github.com/russmatney/dothop/commit/f0b124bb)) feat: green button scene with theme, world map buttons a bit nicer - Russell Matney
- ([`17d76e6c`](https://github.com/russmatney/dothop/commit/17d76e6c)) feat: paper panel theme - Russell Matney

  > Adding some paper bg - still not sure how to scale these 9 patch
  > corners, and the colors aren't working very well, but :shrug: it's more
  > interesting than it was.

- ([`aa8d0f50`](https://github.com/russmatney/dothop/commit/aa8d0f50)) feat: option menu using green board controls bg - Russell Matney

  > Experimenting with themes and nine-patch rects. Colors not working, but
  > things are a bit more interesting at least.

- ([`75e1b523`](https://github.com/russmatney/dothop/commit/75e1b523)) asset: add pixelfrog treasure-hunters for ui detail - Russell Matney

  > https://pixelfrog-assets.itch.io/treasure-hunters

- ([`998b9782`](https://github.com/russmatney/dothop/commit/998b9782)) refactor: cleaner menu naming - Russell Matney

  > No need to specify DotHop on everything now that we're split from dino.

- ([`fb307a68`](https://github.com/russmatney/dothop/commit/fb307a68)) refactor: create menu button and hero themes - Russell Matney

  > Rather than impling components with theme overwrites, we create some
  > themes to be more easily applied to one-off buttons/labels.

- ([`cd4f2f1d`](https://github.com/russmatney/dothop/commit/cd4f2f1d)) chore: update phantom camera - Russell Matney

### 21 Jan 2024

- ([`e9ebcb97`](https://github.com/russmatney/dothop/commit/e9ebcb97)) fix: no need to be so specific here - Russell Matney

### 19 Jan 2024

- ([`df9aabac`](https://github.com/russmatney/dothop/commit/df9aabac)) wip: mute buttons in controls - Russell Matney
- ([`5d7a645b`](https://github.com/russmatney/dothop/commit/5d7a645b)) wip: title screen, world map, controls tweaks and logo add - Russell Matney

### 18 Jan 2024

- ([`e9ac0eca`](https://github.com/russmatney/dothop/commit/e9ac0eca)) readme: add youtube badge - Russell Matney

### 16 Jan 2024

- ([`6794136e`](https://github.com/russmatney/dothop/commit/6794136e)) fix: re-order, simplify controls - Russell Matney

  > - just r for restart/reset (drop shift)
  > - move z ahead of ctrl-z for undo (cleaner when it shows up in the ui)

- ([`593bcaac`](https://github.com/russmatney/dothop/commit/593bcaac)) fix: better controls layout - Russell Matney

  > Plus some helpers to make it easier to edit this controls view (b/c
  > InputHelper is not a tool script).

- ([`b7570b6e`](https://github.com/russmatney/dothop/commit/b7570b6e)) feat: cleaner controls UI - Russell Matney

  > Only show the primary key for the current device, and update when the
  > device changes.

- ([`fd5dd568`](https://github.com/russmatney/dothop/commit/fd5dd568)) fix: display close button on jumbotron - Russell Matney

  > Also cleans up some device/input code. Could probably clean up the
  > controls panel a bit as well, to show only the active device and primary
  > button for each control.

- ([`481b5e20`](https://github.com/russmatney/dothop/commit/481b5e20)) feat: HUD control hints showing actual controls - Russell Matney

  > And moving between controller and keyboards settings!

- ([`6acc73f4`](https://github.com/russmatney/dothop/commit/6acc73f4)) fix: return to main from pause menu, drop empty levels - Russell Matney

  > Updates win condition to just return to main for now.

- ([`03b822e4`](https://github.com/russmatney/dothop/commit/03b822e4)) fix: remove noisey error message - Russell Matney
- ([`7e8256a0`](https://github.com/russmatney/dothop/commit/7e8256a0)) feat: some basic focus handling, nav to/from controls - Russell Matney

  > Controls Panel is only accessible from the main menu for now.

- ([`92035dd7`](https://github.com/russmatney/dothop/commit/92035dd7)) chore: i was dead wrong here - Russell Matney

  > Will have to come back and clean up the syntax to use the actual
  > constants.

- ([`ce14ebad`](https://github.com/russmatney/dothop/commit/ce14ebad)) feat: basic (tho buggy) control editing in place - Russell Matney
- ([`672784ce`](https://github.com/russmatney/dothop/commit/672784ce)) feat: displaying joypad inputs for controls - Russell Matney

  > Hardcodes a mapping from input joypad events (buttons and motions) to
  > controller axes and vexed's EnterInput font characters.

- ([`d940ab66`](https://github.com/russmatney/dothop/commit/d940ab66)) fix: stretch mode viewport - same view at different screen sizes - Russell Matney
- ([`34dcdb46`](https://github.com/russmatney/dothop/commit/34dcdb46)) feat: dynamically drop camera follow nodes - Russell Matney
- ([`1c7f4357`](https://github.com/russmatney/dothop/commit/1c7f4357)) chore: drop old camera plugin from dino - Russell Matney
- ([`99db180b`](https://github.com/russmatney/dothop/commit/99db180b)) feat: integrate phantom camera - very pleased! - Russell Matney
- ([`dc90734d`](https://github.com/russmatney/dothop/commit/dc90734d)) addon: add and enable phantom_camera - Russell Matney

### 15 Jan 2024

- ([`bfc6b466`](https://github.com/russmatney/dothop/commit/bfc6b466)) feat: latin kbd inputs, better action icon spacing - Russell Matney

  > wip: placeholders for joy button/motion inputs

- ([`94ff452c`](https://github.com/russmatney/dothop/commit/94ff452c)) feat: controls panel showing keyboard controls - Russell Matney
- ([`54f17404`](https://github.com/russmatney/dothop/commit/54f17404)) feat: ActionInputIcon label - Russell Matney

  > Set input_text to map to one of Vexed's Enter Input font characters.

- ([`fd090246`](https://github.com/russmatney/dothop/commit/fd090246)) wip: creating action rows per action - Russell Matney
- ([`a0cc51ec`](https://github.com/russmatney/dothop/commit/a0cc51ec)) chore: update vexed EnterInput font - Russell Matney

  > https://v3x3d.itch.io/enter-input

- ([`07879f17`](https://github.com/russmatney/dothop/commit/07879f17)) feat: dot hop steam badge, CI badges - Russell Matney
- ([`d7fe061e`](https://github.com/russmatney/dothop/commit/d7fe061e)) chore: update gdunit to latest - Russell Matney
- ([`aa77dae2`](https://github.com/russmatney/dothop/commit/aa77dae2)) wip: controls panel begins - Russell Matney
- ([`a764c8d7`](https://github.com/russmatney/dothop/commit/a764c8d7)) feat: enable input_helper, reduce noisey log - Russell Matney
- ([`994857a3`](https://github.com/russmatney/dothop/commit/994857a3)) addon: add godot input_helper - Russell Matney
- ([`55fe3d44`](https://github.com/russmatney/dothop/commit/55fe3d44)) fix: drop dino menu button - Russell Matney
- ([`c7780322`](https://github.com/russmatney/dothop/commit/c7780322)) chore: kill and ignore build-output dir content - Russell Matney
- ([`a041a584`](https://github.com/russmatney/dothop/commit/a041a584)) refactor: update boxart export to latest - Russell Matney

  > This was improved while creating the aseprite scripting devlog, so we
  > pull back some of those improvements here. Ideally these helpers would
  > get some shared package... i'm sitting on the name of whatever that is
  > for now.

- ([`77f08089`](https://github.com/russmatney/dothop/commit/77f08089)) chore: aseprite import meta files - Russell Matney
- ([`fde3da61`](https://github.com/russmatney/dothop/commit/fde3da61)) refactor: move bb code from src to bb dir - Russell Matney

  > A bit cleaner, and probably better to separate these things.

- ([`edf35021`](https://github.com/russmatney/dothop/commit/edf35021)) fix: set_focus when main menu launches - Russell Matney

### 14 Jan 2024

- ([`2d81df79`](https://github.com/russmatney/dothop/commit/2d81df79)) chore: add source-available copyright notice - Russell Matney

### 12 Jan 2024

- ([`dd49eca1`](https://github.com/russmatney/dothop/commit/dd49eca1)) fix: update boxart gen to support alternate base files - Russell Matney

  > Some of these are bg-less, others are logo-less.
  > 
  > We could instead add some toggling for bg/logo visibility to the script,
  > but this was quicker this morning.


### 11 Jan 2024

- ([`d045259a`](https://github.com/russmatney/dothop/commit/d045259a)) feat: resurrect HUD and updates - Russell Matney
- ([`c79145b1`](https://github.com/russmatney/dothop/commit/c79145b1)) feat: basic dothop web build and wip itch deploy - Russell Matney
- ([`bd741d1e`](https://github.com/russmatney/dothop/commit/bd741d1e)) feat: rough steam deploy, locally and via CI - Russell Matney
- ([`3950947f`](https://github.com/russmatney/dothop/commit/3950947f)) fix: set GODOT_BIN - Russell Matney
- ([`e123ab44`](https://github.com/russmatney/dothop/commit/e123ab44)) fix: switch to gdunit4 fix-load branch - Russell Matney
- ([`040c7fbb`](https://github.com/russmatney/dothop/commit/040c7fbb)) ci: run unit tests - Russell Matney
- ([`fac0c8ed`](https://github.com/russmatney/dothop/commit/fac0c8ed)) feat: game playable again! - Russell Matney

  > Moves Trolls to read ui_* inputs for movement rather than creating our
  > own - i think this is more typical.

- ([`2c6ea598`](https://github.com/russmatney/dothop/commit/2c6ea598)) feat: recreate puzzle sets and themes via pandora - Russell Matney
- ([`06bf7eec`](https://github.com/russmatney/dothop/commit/06bf7eec)) feat: start input map with basic pause button - Russell Matney
- ([`c8b088e6`](https://github.com/russmatney/dothop/commit/c8b088e6)) fix: delete recursive pandora code, game starts up now - Russell Matney

  > It appears i accidentally imported pandora into itself...

- ([`32edbfe3`](https://github.com/russmatney/dothop/commit/32edbfe3)) chore: pull notifs into core, drop hood - Russell Matney

  > Also pulls Puzz classes into src/, drops puzz.

- ([`95ded418`](https://github.com/russmatney/dothop/commit/95ded418)) refactor: move naviButtonList to ui/ButtonList - Russell Matney
- ([`d36c7b33`](https://github.com/russmatney/dothop/commit/d36c7b33)) chore: trim and consolidate Navi in core - Russell Matney
- ([`fe956832`](https://github.com/russmatney/dothop/commit/fe956832)) chore: move jumbotron from quest to core, drop quest addon - Russell Matney
- ([`1af5d3f2`](https://github.com/russmatney/dothop/commit/1af5d3f2)) refactor: move Trolley to core/Trolls and static class - Russell Matney
- ([`46173d8d`](https://github.com/russmatney/dothop/commit/46173d8d)) wip: drop a bunch of core and trolley - Russell Matney
- ([`91495c43`](https://github.com/russmatney/dothop/commit/91495c43)) imports: pull in Hood and Quest for notifs and jumbotron - Russell Matney

  > It's becoming clear these dino addons are kind of crazy.

- ([`b42d5880`](https://github.com/russmatney/dothop/commit/b42d5880)) chore: drop 'Hotel' usage - Russell Matney
- ([`1e9f17b2`](https://github.com/russmatney/dothop/commit/1e9f17b2)) import: addons and dothop code from dino - Russell Matney

  > A mess to be hacked down to size in following commits.

- ([`256bb557`](https://github.com/russmatney/dothop/commit/256bb557)) chore: gitignore, some readme badges - Russell Matney
- ([`6c800fdc`](https://github.com/russmatney/dothop/commit/6c800fdc)) chore: some modified assets, and final boxart script touches - Russell Matney

### 10 Jan 2024

- ([`ae7704fa`](https://github.com/russmatney/dothop/commit/ae7704fa)) addons: add gdfxr and enable it - Russell Matney
- ([`7d96241b`](https://github.com/russmatney/dothop/commit/7d96241b)) chore: bunch of aseprite auto-imports - Russell Matney
- ([`78c99dac`](https://github.com/russmatney/dothop/commit/78c99dac)) addons: enable pandora, gdunit, aseprite-wizard - Russell Matney
- ([`443fbce9`](https://github.com/russmatney/dothop/commit/443fbce9)) addons: add AsepriteWizard - Russell Matney
- ([`8980264d`](https://github.com/russmatney/dothop/commit/8980264d)) addons: add gdunit4 - Russell Matney
- ([`99d504da`](https://github.com/russmatney/dothop/commit/99d504da)) addons: add pandora - Russell Matney
- ([`bb82ee8b`](https://github.com/russmatney/dothop/commit/bb82ee8b)) init: create godot project, set icon + bootsplash - Russell Matney
- ([`4689e5a2`](https://github.com/russmatney/dothop/commit/4689e5a2)) feat: dothop boxart aseprite and pngs - Russell Matney
- ([`729f7c09`](https://github.com/russmatney/dothop/commit/729f7c09)) feat: impl export-all-boxart helper - Russell Matney
- ([`fdd09f19`](https://github.com/russmatney/dothop/commit/fdd09f19)) feat: add center_sprite, cast tonumber, support wide_base_logo - Russell Matney
- ([`2c8ea09f`](https://github.com/russmatney/dothop/commit/2c8ea09f)) feat: resizeSprite with lockRatio, then crop back down - Russell Matney

  > Won't work for all sizes, but it's working for my current base image and
  > the main-capsule. Ready to run for all of them!

- ([`aab51076`](https://github.com/russmatney/dothop/commit/aab51076)) feat: refactor into proper canvas resize - Russell Matney

  > Now extending the canvas without modifying the sprite at all.

- ([`2204c859`](https://github.com/russmatney/dothop/commit/2204c859)) wip: basic resizing via bb godot task - Russell Matney

  > next up: maintaining aspect ratio

- ([`8d96628c`](https://github.com/russmatney/dothop/commit/8d96628c)) feat: basic resize_canvas script working - Russell Matney
- ([`7417f1df`](https://github.com/russmatney/dothop/commit/7417f1df)) feat: base-logo, raw concept art, boxart gen wip refactor - Russell Matney

### 4 Jan 2024

- ([`2e6a1e40`](https://github.com/russmatney/dothop/commit/2e6a1e40)) wip: towards generating aseprite files - Russell Matney
- ([`2e8cdb57`](https://github.com/russmatney/dothop/commit/2e8cdb57)) chore: pull in bb helpers from dino/bb-godot - Russell Matney

  > Some renaming and cutting down - probably most of this should live in a
  > library somewhere, but it's not much.
