extends BaseScene

@onready var heartContainer = $CanvasLayer/heartsContainer
@onready var camera = $follow_cam
# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	camera.follow_node = player
	
	heartContainer.setMaxHearts(player.maxHealth)
	heartContainer.updateHearts(player.currentHealth)
	player.healthChanged.connect(heartContainer.updateHearts)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_inventory_gui_closed():
	get_tree().paused = false


func _on_inventory_gui_opened():
	get_tree().paused = true
