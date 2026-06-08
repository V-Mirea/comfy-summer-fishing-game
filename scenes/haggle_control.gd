extends Control
class_name HaggleControl

@export var price_label: Label

signal offer_accepted(customer: Customer, price: int)
signal offer_declined(customer: Customer)

var customer: Customer
var price: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_customer_bartering(customer: Customer):
	self.customer = customer
	price = customer.fish_wanted.price
	price_label.text = "$%d" % price

func _on_accept_button_pressed():
	offer_accepted.emit(customer, price)

func _on_decline_button_pressed():
	offer_declined.emit(customer)
