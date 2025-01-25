extends StaticBody2D

@export var PlanteFinal : Node2D
@export var PlanteScale : float = 0.001
@export var waterCap : float = 4
var waterHeld : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#PlanteFinal.position = position
	PlanteFinal.scale = Vector2(PlanteScale,PlanteScale)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	$Label.text = str(int(waterHeld)) + " / " + str(int(waterCap))
	
	PlanteFinal.scale = Vector2(PlanteScale,PlanteScale)
	
	pass

func startAnim():
	if (waterHeld >= waterCap) :
		$AnimationPlayer.play('GrowPlant')
