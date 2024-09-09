extends Sprite2D

### IMPORTED FROM ANOTHER PROJECT ###

@onready var bar = $TimerBar

var percentage : float = 1.0
var target_percentage : float

const original_rate = 10 # 12
var curr_rate

var thresh_1 = .10
var thresh_1_rate = 3
var thresh_2 = .25
var thresh_2_rate = 5 # 7
var thresh_3 = .35
var thresh_3_rate = 8 # 10

var add_progress : float = .2

signal gameover

func _ready():
	curr_rate = original_rate
	target_percentage = percentage

func _process(delta):
	percentage -= curr_rate * delta / 100
	
	# Percentage
	if (percentage < 0):
		percentage = 0
		gameover.emit()
	if (percentage > 1):
		percentage = 1

	update_rate()
	
	target_percentage = lerp(target_percentage, percentage, 25 * delta)
	bar.set_scale(Vector2(target_percentage, 1))
	#bar.set_scale(Vector2(percentage, 1))

func update_rate():
	pass
	# Rate
	if (percentage < thresh_1 && curr_rate > thresh_1_rate):
		change_rate(thresh_1_rate)
	if (percentage < thresh_2 && curr_rate > thresh_2_rate):
		change_rate(thresh_2_rate)
	if (percentage < thresh_3 && curr_rate > thresh_3_rate):
		change_rate(thresh_3_rate)
	
	# Original rate
	if (percentage > thresh_3 && curr_rate < original_rate):
		change_rate(original_rate)

func add_time(num_letters):
	percentage += add_progress * num_letters
	
	update_rate()
	
func change_rate(to):
	curr_rate = to

func game_over():
	curr_rate = 0
	set_process(false)
	
func new_game():
	curr_rate = original_rate
	percentage = 1.0
	target_percentage = percentage
	set_process(true)

func pause():
	curr_rate = 0
	set_process(false)

func unpause():
	curr_rate = original_rate
	set_process(true)
	update_rate()
