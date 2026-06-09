extends CanvasLayer

@export var upgrades_list: ItemList
@export var cart_list: ItemList

signal cart_price_changed(new_price: int)

var upgrades_available: Array[Upgrade]
var shopping_cart: Array[Upgrade] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	## add some hardcoded upgrades for testing
	## BUG: items will be readded at the start of every day. 
	##  This implemenation does not take into account which items were already bought
	var new_upgrade = Upgrade.new()
	new_upgrade.type = Upgrade.UpgradeType.ROD
	new_upgrade.price = 300
	new_upgrade.level = 1
	upgrades_available.append(new_upgrade)
	
	new_upgrade = Upgrade.new()
	new_upgrade.type = Upgrade.UpgradeType.SHOP_LEVEL
	new_upgrade.price = 700
	new_upgrade.level = 3
	upgrades_available.append(new_upgrade)
	
	new_upgrade = Upgrade.new()
	new_upgrade.type = Upgrade.UpgradeType.LINE
	new_upgrade.price = 230
	new_upgrade.level = 2
	upgrades_available.append(new_upgrade)
	
	new_upgrade = Upgrade.new()
	new_upgrade.type = Upgrade.UpgradeType.REEL
	new_upgrade.price = 50
	new_upgrade.level = 1
	upgrades_available.append(new_upgrade)
	
	new_upgrade = Upgrade.new()
	new_upgrade.type = Upgrade.UpgradeType.REEL
	new_upgrade.price = 75
	new_upgrade.level = 2
	upgrades_available.append(new_upgrade)
	
	upgrades_list.clear()
	for upgrade in upgrades_available:
		upgrades_list.add_item("%s (%d) - $%d" % [Upgrade.UpgradeType.keys()[upgrade.type], upgrade.level, upgrade.price])

func calculate_cart_price() -> int:
	var total_price: int = 0
	for upgrade in shopping_cart:
		total_price += upgrade.price
	return total_price

func add_item_to_cart(index: int):
	var list_item_selected = upgrades_list.get_item_text(index)
	upgrades_list.remove_item(index)
	cart_list.add_item(list_item_selected)
	
	var item_selected = upgrades_available[index]
	upgrades_available.remove_at(index)
	shopping_cart.append(item_selected)
	
	cart_price_changed.emit(calculate_cart_price())
	
func remove_item_from_cart(index: int):
	var list_item_selected = cart_list.get_item_text(index)
	cart_list.remove_item(index)
	upgrades_list.add_item(list_item_selected)
	
	var item_selected = shopping_cart[index]
	shopping_cart.remove_at(index)
	upgrades_available.append(item_selected)
	
	cart_price_changed.emit(calculate_cart_price())

func _on_shop_opened():
	get_tree().paused = true
	visible = true

func _on_upgrades_list_item_selected(index):
	add_item_to_cart(index)

func _on_cart_list_item_selected(index):
	remove_item_from_cart(index)
	
func _on_purchase_button_pressed():
	var total_price = calculate_cart_price()
		
	if total_price <= PlayerManager.data.money:
		## add upgrades to inv
		
		PlayerManager.spend_money(total_price)
		cart_price_changed.emit(0)
		for i in range(shopping_cart.size() - 1, -1, -1):
			cart_list.remove_item(i)
			shopping_cart.remove_at(i)

func _on_exit_button_pressed():
	get_tree().paused = false
	visible = false
	
	# iterate through the list backwards to avoid issues when removing an item from the beginning
	for i in range(shopping_cart.size() - 1, -1, -1):
		remove_item_from_cart(i)
