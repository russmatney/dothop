@tool
extends DotHopDot

@onready var anim = $AnimatedSprite2D

## ready ###########################################################

func _ready():
	super._ready()
	Anim.slide_in(self)

## render ###########################################################

func render():
	super.render()

	if anim != null:
		anim.play("goal")
