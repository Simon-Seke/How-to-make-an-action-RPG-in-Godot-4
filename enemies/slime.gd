extends CharacterBody2D

@export var speed = 20
@export var limit = 0.5
@export var endPoint: Marker2D = null
@onready var animations = $AnimationPlayer

var startPosition
var endPosition

var isDead: bool = false

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
	if isDead: return
	updateVelocity()
	move_and_slide()
	updateAnimation()

func knockback(playerPosition: Vector2):
	var knockbackDirection = (position - playerPosition).normalized() * 800
	velocity = knockbackDirection
	move_and_slide()

func _on_hurt_box_area_entered(area):
	if area == $hitBox: return
	var playerPosition = area.get_parent().get_parent().position
	knockback(playerPosition)
	$hitBox.set_deferred("monitorable", false)
	isDead = true
	animations.play("death")
	await animations.animation_finished
	queue_free()
