extends RefCounted

class_name Fish

enum FishType { GUPPY, CATFISH, WHATEVER}

var type: FishType
var quality: int # 0 - 100?
var base_price: int # this will probably be automatically calculated from type/quality
