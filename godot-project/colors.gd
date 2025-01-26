extends Node

static var colors: Array[Color] = [
	Color('FF3535'),
	Color('00D347'), 
	Color('00AAFF'), 
	Color('B01DDA'), 
	Color('FFC900')
]
static var border_colors: Array[Color] = [
	Color('B40000'), 
	Color('1A9874'), 
	Color('005BD7'), 
	Color('6D029C'), 
	Color('E56F00')
]

static var patterns: Array[String] = [
	"res://pattern-square-red.png", 
	"res://pattern-square-green.png", 
	"res://pattern-square-blue.png", 
	"res://pattern-square-purple.png", 
	"res://pattern-square-yellow.png"
]
# Used in the thought bubbles
static var pattern_bubble_scales: Array[float] = [
	3,
	0.5,
	1,
	1.5,
	0.4,
]

# Used in the player's hat
static var pattern_hat_scales: Array[float] = [
	3,
	0.5,
	1,
	1.5,
	0.4,
]

# Used in the end screen charts
static var pattern_ui_scales: Array[float] = [
	1,
	3,
	5,
	8,
	4,
]
