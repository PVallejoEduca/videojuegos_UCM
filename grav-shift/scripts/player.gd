extends CharacterBody2D

@export var force = 2500
@export var maxSpeed = 350
@export var friction = 0.75

var acceleartion = Vector2.ZERO
var velocity1 = Vector2.ZERO

func _process(delta):
    var direction = Input.get_axis("left", "right")
    acceleartion = Vector2(direction, 0) * force
    
    velocity += acceleartion * delta
    
    if velocity.length() > maxSpeed:
        velocity = velocity.normalized() * maxSpeed
        
    if acceleartion.length() < 0.05:
        velocity *= friction
    
    position += velocity * delta
