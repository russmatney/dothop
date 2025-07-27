extends Node
# autoload PuzzleAnalyzer


var threads: Array[Thread] = []

var puzzle_def_id_to_analysis: Dictionary[String, PuzzleAnalysis] = {}
var inflight: Array[String] = []

func to_pretty() -> Variant:
	return {thread_count=len(threads), inflight_count=len(inflight), cached_analysis_count=puzzle_def_id_to_analysis.size()}

## ready ################################################

func _ready() -> void:
	Log.info({ready=self})

# a maybe useful helper
func analyze_all_puzzles() -> void:
	Log.info("Analyzing all PuzzleStore puzzles")
	if PuzzleStore == null:
		Log.error("PuzzleStore is null, cannot analyze puzzles.")
		return

	for puzzle_def: PuzzleDef in PuzzleStore.get_puzzles():
		if puzzle_def == null:
			Log.warn("PuzzleDef is null, skipping analysis.")
			continue
		analyze_puzzle(puzzle_def)

	Log.info("All puzzles have been queued for analysis", self)


## exit tree ################################################

# as if an autoload would ever leave the tree...
# jk godot warns about this after close, it's probably quite bad
func _exiting_tree() -> void:
	for th: Thread in threads:
		if th != null:
			# join thread to prevent it leaking
			Log.warn("waiting for puzzle analyzer thread to finish before exiting")
			th.wait_to_finish()

## process ################################################

var last_log := 0.0
var last_log_t := 5.0

## check in on any threads that are ready for deletion
func _process(delta: float) -> void:
	for th: Thread in threads:
		if th != null and th.is_started() and not th.is_alive():
			# join thread (to prevent leaking)
			th.wait_to_finish()

			# erase from local data
			threads.erase(th)
			inflight.erase(th.get_meta("puzzle_def_id"))
			Log.info("Thread finished + erased", self)

	if last_log < 0.0:
		if len(threads) > 0:
			Log.info("Puzzle Analyzer Update:", self)
		last_log = last_log_t
	else:
		last_log -= delta


## analyze puzzle ################################################

func analyze_puzzle(puzzle_def: PuzzleDef) -> void:
	if puzzle_def.get_id() in inflight:
		# ignore inflight requests, it's coming back soon
		return
	inflight.append(puzzle_def.get_id())

	var td: Thread = Thread.new()
	threads.append(td)
	td.set_meta("puzzle_def_id", puzzle_def.get_id())

	# start the thread to analyze the puzzle
	td.start(_analyze_puzzle_thread.bind(puzzle_def))

func _analyze_puzzle_thread(puzzle_def: PuzzleDef) -> void:
	Log.info("Analyzing puzzle:", puzzle_def)

	var puzz_state := PuzzleState.new(puzzle_def)
	var solve := PuzzleAnalysis.new({state=puzz_state}).analyze()
	puzzle_def.analysis = solve

	Log.info("Analysis complete for puzzle:", solve)
	# cache this thing
	puzzle_def_id_to_analysis[puzzle_def.get_id()] = solve

	Log.info("[Analyzer] NEW SOLVE STORED", self)
	Events.stats.fire_analysis_complete.call_deferred(puzzle_def)


## get_analysis ################################################

func get_analysis(puzzle_def: PuzzleDef) -> PuzzleAnalysis:
	if puzzle_def == null:
		Log.warn("PuzzleDef is null, cannot get analysis.")
		return null

	var id: String = puzzle_def.get_id()
	if not puzzle_def_id_to_analysis.has(id):
		return null

	return puzzle_def_id_to_analysis[id]
