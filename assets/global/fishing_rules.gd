class_name FishingRules
extends RefCounted

#holds all the math here stateless so we can just use a static class

const PERFECT_POINTS: float = 2.0
const GOOD_POINTS: float = 1.0
const BAD_POINTS: float = 0.0
const MISS_POINTS: float = -1.0
const MISS_THRESHOLD_RATIO: float = 0.2

static func get_fishing_roll_chance() -> float:
	var bait_level := PlayerManager.get_upgrade_level(Upgrade.UpgradeType.BAIT)
	return .2 + (bait_level/5 * .2)

# goes from 0 -> 2.5, the other 2.5 wlil come from catching the fish portion
# at level 0, you can randomly go from 0->0.5, max level is 2 -> 2.5. this means youre responsible for 2.0 of the whole score
#however, the  random .5 is heavily weighted to be the max value, 20% of the time.
# we can change this weight based on some upgrades later on (probably rod)
# weights are the following:
# rod (6) + reel (2) + line (1) + bait (1)
static func get_base_quality() -> float:
	var rod_level := PlayerManager.get_upgrade_level(Upgrade.UpgradeType.ROD)
	var reel_level := PlayerManager.get_upgrade_level(Upgrade.UpgradeType.REEL)
	var line_level := PlayerManager.get_upgrade_level(Upgrade.UpgradeType.LINE)
	var bait_level := PlayerManager.get_upgrade_level(Upgrade.UpgradeType.BAIT)
	var weighted_sum := (float(rod_level) / 4) * 6 \
					  + (float(reel_level) / 4) * 2 \
					  + (float(line_level) / 4) \
					  + (float(bait_level) / 4)
	#currently dividing by 4 as a predetermined "max level". we might want todefined a max level per upgrade
	var bonus := 0.5 if randf() < 0.2 else randf_range(0.0, 0.5)
	return weighted_sum * (2.0 / 10.0) + bonus

#we convert the raw amounts of perf/good/bad/miss into a number that we can easily use. this number is pit against
# the total possible max, which is perf * numbubbles in pattern. based on that, we
# determine if the fish is caught, as well as what score the player got.
static func _get_raw_score(score_data: Dictionary) -> float:
	return score_data["perfects"] * PERFECT_POINTS \
		+ score_data["goods"] * GOOD_POINTS \
		+ score_data["bads"] * BAD_POINTS \
		+ score_data["misses"] * MISS_POINTS

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
