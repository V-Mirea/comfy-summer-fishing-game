extends Node

# fishing 6am-4pm, selling 4pm-10pm, buying = no time.
# scene managers tell us when to start/stop; we announce time + phase changes back.
# DONT set process_mode here, leaving it default means _process is skipped
# while get_tree().paused, so the clock freezes for free during the pause menu and
# the fish caught popup (both set paused = true).

enum Phase { FISHING, SELLING, OFF } # OFF is for disabled during menu and buying
enum Clock { STOPPED, RUNNING }

const DAY_START := 6 * 60 # 6:00 am
const FISHING_END := 16 * 60 # 4:00 pm
const SELLING_END := 22 * 60 # 10:00 pm
const TICK_MINUTES := 10 # adjustable update tick indicators, so we update clock every 10 min intervals
const REAL_SECS_PER_TICK := 3.0
# in testing, adjust this ^ tick to something like like .5 or 1.0 if you want to make it go faster to see phase changes easier etc

signal time_changed(minutes: int) # hud + day tint listen
signal phase_changed(phase: Phase) # hud visibility / tint
signal fishing_day_over # fired at 4pm
signal selling_day_over # fired at 10pm

var minutes: int = DAY_START # minutes since midnight, always a multiple of 10
var tick_accum: float = 0.0 # real seconds banked toward the next tick
var phase: Phase = Phase.OFF
var clock: Clock = Clock.STOPPED

func _process(delta: float) -> void:
	if clock != Clock.RUNNING:
		return
	tick_accum += delta
	while tick_accum >= REAL_SECS_PER_TICK:
		tick_accum -= REAL_SECS_PER_TICK
		_advance_tick()
		if clock != Clock.RUNNING:
			return # hit a phase boundary, stop banking

func _advance_tick() -> void:
	minutes += TICK_MINUTES
	var cap := FISHING_END if phase == Phase.FISHING else SELLING_END
	if minutes >= cap:
		minutes = cap
		clock = Clock.STOPPED
		tick_accum = 0.0
		time_changed.emit(minutes)
		if phase == Phase.FISHING:
			fishing_day_over.emit()
		else:
			selling_day_over.emit()
		return
	time_changed.emit(minutes)

# fishing scene calls this on _ready, which also doubles as the daily reset
func begin_fishing_day() -> void:
	minutes = DAY_START
	tick_accum = 0.0
	phase = Phase.FISHING
	clock = Clock.STOPPED
	phase_changed.emit(phase)
	time_changed.emit(minutes)

# called after the character finishes walking to the dock at start of day
func start_clock() -> void:
	clock = Clock.RUNNING

# selling scene calls this on _ready. minutes are already at 4pm from fishing,
# carried across the scene swap since we're an autoload. don't reset them.
func begin_selling() -> void:
	tick_accum = 0.0
	phase = Phase.SELLING
	clock = Clock.RUNNING
	phase_changed.emit(phase)

func stop_clock() -> void:
	clock = Clock.STOPPED

# buying / main menu. hides the hud time label and parks the clock.
func set_phase_off() -> void:
	clock = Clock.STOPPED
	phase = Phase.OFF
	phase_changed.emit(phase)

# leave-early button: jump straight to 4pm. doesnt emit fishing_day_over since
# the fishing manager does the transition itself
func skip_to_fishing_end() -> void:
	minutes = FISHING_END
	clock = Clock.STOPPED
	tick_accum = 0.0
	time_changed.emit(minutes)
