extends Control
class_name HaggleControl

@export var price_label: Label
@export var price_slider: HSlider

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
	price_slider.min_value = customer.fish_wanted.price
	price_slider.max_value = customer.fish_wanted.max_counter_offer
	price_slider.value = price_slider.min_value

func _on_accept_button_pressed():
	match customer.consider_offer(price, price_slider.max_value):
		Customer.Reaction.ACCEPT:
			offer_accepted.emit(customer, price)
		Customer.Reaction.ANGRY:
			offer_declined.emit(customer) # this signal tells the customer to leave. this might not be the right way to handle it.
		Customer.Reaction.DECLINE:
			customer.show_decline_bubble()
			price_slider.max_value = price

func _on_decline_button_pressed():
	offer_declined.emit(customer)

func _on_price_slider_value_changed(value):
	price = value
	price_label.text = "$%d" % price
