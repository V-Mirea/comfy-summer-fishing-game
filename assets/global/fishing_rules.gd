class_name FishingRules
extends RefCounted

#holds all the math here stateless so we can just use a static class

const PERFECT_POINTS: float = 2.0
const GOOD_POINTS: float = 1.0
const BAD_POINTS: float = 0.0
const MISS_POINTS: float = -1.0
const MISS_THRESHOLD_RATIO: float = 0.2

# bait upgrade
# value increases chance, 1 is guarantee
static func get_fishing_roll_chance() -> float:
	return 0.2 + UpgradeDatabase.get_value(Upgrade.UpgradeType.BAIT)

# reel upgrade
# time in seconds, keep in mind for reel
static func get_bite_window() -> float:
	return 1.0 + UpgradeDatabase.get_value(Upgrade.UpgradeType.REEL)

# reel upgrade
# so reel is performiing double duty, maybe ill do some other math to sort of split this up but right now value is face
static func get_bubble_lifetime_multiplier() -> float:
	return 1.0 + UpgradeDatabase.get_value(Upgrade.UpgradeType.REEL)

# line upgrade
# first step in all calculation grabs, this step gives the t which is the factor of how close we get to the lerp step
# realistically we should go from 0->0.5? we'll see how we like to tune this
static func _get_line_t() -> float:
	return UpgradeDatabase.get_value(Upgrade.UpgradeType.LINE)

static func _get_miss_points() -> float:
	return lerp(MISS_POINTS, BAD_POINTS, _get_line_t())

static func _get_bad_points() -> float:
	return lerp(BAD_POINTS, GOOD_POINTS, _get_line_t())

static func _get_good_points() -> float:
	return lerp(GOOD_POINTS, PERFECT_POINTS, _get_line_t())

# rod upgrade
# should go from 0->2.0
# base quality is the equipment half of the total score, the
# other 2.5 comes from the fishing game. driven entirely by rod's value now, also having random .5 variance
# heavily weighted to be at its max 0.5 about 20% of the time to not feel impossible to get a perfect fish; maybe rod value also increases this 
static func get_base_quality() -> float:
	var rod_value: float = UpgradeDatabase.get_value(Upgrade.UpgradeType.ROD)
	var bonus := 0.5 if randf() < 0.2 else randf_range(0.0, 0.5)
	return rod_value + bonus

#we convert the raw amounts of perf/good/bad/miss into a number that we can easily use. this number is pit against
# the total possible max, which is perf * numbubbles in pattern. based on that, we
# determine if the fish is caught, as well as what score the player got.
static func _get_raw_score(score_data: Dictionary) -> float:
	return score_data["perfects"] * PERFECT_POINTS \
		+ score_data["goods"] * _get_good_points() \
		+ score_data["bads"] * _get_bad_points() \
		+ score_data["misses"] * _get_miss_points()

static func did_catch_fish(score_data: Dictionary) -> bool:
	var total: int = score_data["total"]
	if total <= 0:
		return true
	if score_data["misses"] >= ceili(total / 2.0):
		return false
	var max_possible := total * PERFECT_POINTS
	return _get_raw_score(score_data) >= max_possible * MISS_THRESHOLD_RATIO

static func get_minigame_quality(score_data: Dictionary) -> float:
	var max_possible: float = score_data["total"] * PERFECT_POINTS
	if max_possible <= 0.0:
		return 0.0
	var clamped := maxf(_get_raw_score(score_data), 0.0)
	return (clamped / max_possible) * 2.5

static func calculate_total_quality(score_data: Dictionary) -> int:
	var combined := get_base_quality() + get_minigame_quality(score_data)
	return clampi(roundi((combined / 5.0) * 100.0), 0, 100)
