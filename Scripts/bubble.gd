extends Line2D


#circle definition
var ptsNbr : int = 30
var radius : float = 50
var baseRadius :float = radius
var ptsDefaultArray = []

#ondulationSystem

# Called when the node enters the scene tree for the first time.
func _ready():
	
	updateWater()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	
	
	pass


func updateWater():
	
	points = []
	
	var v = Vector2(radius,0)
	
	for i in ptsNbr :
		
		add_point(v,i)
		
		v = v.rotated(2 * PI/ptsNbr)
		
		ptsDefaultArray.append(v)
		
	
	$Sprite2D.scale = Vector2(0.215,0.215) * (radius/baseRadius)
