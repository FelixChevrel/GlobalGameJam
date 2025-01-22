extends Line2D


#circle definition
var ptsNbr : int = 30
var radius : float = 50
var baseRadius :float = radius
var ptsDefaultArray = []

#ondulationSystem
var rotationSpeed : float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	
	updateWater()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (rotationSpeed != 0):
		
		$".".rotation += delta * rotationSpeed
	else :
		$".".rotation += delta * 0.5
	
	
	pass


func updateWater():
	
	points = []
	
	var v = Vector2(radius,0)
	
	for i in ptsNbr :
		
		
		add_point(v,i)
		
		v = v.rotated(2 * PI/ptsNbr)
		
		ptsDefaultArray.append(v)
		
	
	$Sprite2D.scale = Vector2(0.215,0.215) * (radius/baseRadius)
