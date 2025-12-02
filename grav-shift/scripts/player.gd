extends CharacterBody2D

@export var force = 2500
@export var maxSpeed = 350
@export var friction = 0.75
@export var gravity = 6000
@export var jump_strength = -1000
@export var fall_limit_y = 1500
@export var invert_gravity = 1

var acceleartion = Vector2.ZERO
var spawn_position = Vector2.ZERO

func _ready():
    spawn_position = global_position

func _process(delta):
    var direction = Input.get_axis("left", "right")
    acceleartion = Vector2(direction, 0) * force
    
    if is_on_floor():
        acceleartion.y = 0
    else:
        acceleartion.y = gravity    

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_strength
         
    velocity += acceleartion * delta
    
    if abs(velocity.x)> maxSpeed:
        velocity.x = sign(velocity.x) * maxSpeed
        
    if acceleartion.length() < 0.05:
        velocity.x *= friction
        
    if abs(velocity.x) > 0.05:
        if velocity.x < 0:
            $Sprite.scale.x = -1
        if velocity.x > 0:
            $Sprite.scale.x = 1
        if is_on_floor():
            $Sprite.play("run")
    elif  abs(velocity.x) < 0.05:
        # No hay movimiento horizontal, paramos las piernas
        $Sprite.stop()
        $Sprite.frame = 0

    move_and_slide()
    
    if global_position.y > fall_limit_y:
        respawn()

func respawn():
    global_position = spawn_position
    velocity = Vector2.ZERO
