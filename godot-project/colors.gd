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

static var patterns: Array[Texture2D] = [
	load("res://pattern-square-red.png"), 
	load("res://pattern-square-green.png"), 
	load("res://pattern-square-blue.png"), 
	load("res://pattern-square-purple.png"), 
	load("res://pattern-square-yellow.png")
]
# Used in the thought bubbles and the player's hat
static var pattern_scales: Array[float] = [
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
