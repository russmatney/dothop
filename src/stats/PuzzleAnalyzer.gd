extends Node
# autoload PuzzleAnalyzer


var analysis_threads: Array[Thread] = []

var puzzle_def_id_to_analysis: Dictionary[String, PuzzleAnalysis] = {}
var inflight: Array[String] = []

func to_pretty() -> Variant:
	return {thread_count=len(analysis_threads), inflight_count=len(inflight), cached_analysis_count=puzzle_def_id_to_analysis.size()}

## ready ################################################

func _ready() -> void:
	var puzs := PuzzleStore.get_puzzles()

	for puz in puzs:
		analyze_puzzle(puz)

	Log.info({ready=self})

## exit tree ################################################

# as if an autoload would ever leave the tree...
# jk godot warns about this after close, it's probably quite bad
func _exiting_tree() -> void:
	for th: Thread in analysis_threads:
		if th != null:
			# join thread to prevent it leaking
			Log.warn("waiting for puzzle analyzer thread to finish before exiting")
			th.wait_to_finish()

## process ################################################

## check in on any threads that are ready for deletion
func _process(_delta: float) -> void:
	for th: Thread in analysis_threads:
		if th != null and th.is_started() and not th.is_alive():
			# join thread (to prevent leaking)
			th.wait_to_finish()

			# erase from local data
			analysis_threads.erase(th)
			inflight.erase(th.get_meta("puzzle_def_id"))
			Log.info("Thread finished + erased", self)

## analyze puzzle ################################################

func analyze_puzzle(puzzle_def: PuzzleDef) -> void:
	var td: Thread = Thread.new()
	analysis_threads.append(td)

	if puzzle_def.get_id() in inflight:
		# ignore inflight requests, it's coming back soon
		return
	inflight.append(puzzle_def.get_id())
	td.set_meta("puzzle_def_id", puzzle_def.get_id())

	# start the thread to analyze the puzzle
	td.start(_analyze_puzzle_thread.bind(puzzle_def))

func _analyze_puzzle_thread(puzzle_def: PuzzleDef) -> void:
	Log.info("Analyzing puzzle:", puzzle_def)

	var puzz_state := PuzzleState.new(puzzle_def)
	var solve := PuzzleAnalysis.new({state=puzz_state}).analyze()

	Log.info("Analysis complete for puzzle:", solve)
	# cache this thing
	puzzle_def_id_to_analysis[puzzle_def.get_id()] = solve

	Log.info("[Analyzer] NEW SOLVE STORED", self)
	Events.stats.fire_analysis_complete(puzzle_def)


## get_analysis ################################################

func get_analysis(puzzle_def: PuzzleDef) -> PuzzleAnalysis:
	if puzzle_def == null:
		Log.warn("PuzzleDef is null, cannot get analysis.")
		return null

	var id: String = puzzle_def.get_id()
	if not puzzle_def_id_to_analysis.has(id):
		Log.warn("No analysis found for puzzle:", id)
		return null

	return puzzle_def_id_to_analysis[id]
