extends CharacterBody2D

@export var speed = 20
@export var limit = 0.5
@export var endPoint: Marker2D
@onready var animations = $AnimatedSprite2D

var startPosition
var endPosition

func _ready():
	startPosition = position
	endPosition = endPoint.global_position

func changeDirection():
	var tmpEnd = endPosition
	endPosition = startPosition
	startPosition = tmpEnd

func updateVelocity():
	var moveDirection = endPosition - position
	if moveDirection.length() < limit:
		changeDirection()
	velocity = moveDirection.normalized()*speed

func updateAnimation():
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
	else:
		var direction = "walkDown"
		if velocity.x < 0: direction = "walkLeft"
		elif velocity.x > 0: direction = "walkRight"
		elif velocity.y < 0: direction = "walkUp"
		animations.play(direction)

func _physics_process(delta):
	updateVelocity()
	move_and_slide()
	updateAnimation()
