extends CharacterBody2D

@onready var invert_sound = $InvertGravitySound
@onready var death_sound = $DeathGravitySound

@export var force = 2500
@export var maxSpeed = 350
@export var friction = 0.75
@export var gravity = 6000
@export var jump_strength = -1000
@export var fall_limit_y = 1500
@export var top_limit_y = -200 

var acceleration = Vector2.ZERO
var spawn_position = Vector2.ZERO
# 1 suelo abajo, -1 suelo arriba
var gravity_direction := 1 


func _ready():
    spawn_position = global_position
    up_direction = Vector2.UP

func _process(delta):
    var direction = Input.get_axis("left", "right")
    acceleration = Vector2(direction, 0) * force

    # Invertir gravedad con la acción "invert_gravity" (barra espaciadora)
    if Input.is_action_just_pressed("invert_gravity"):
        toggle_gravity()
    
    # Gravedad según la dirección actual
    if is_on_floor():
        acceleration.y = 0
    else:
        acceleration.y = gravity * gravity_direction    

    # Salto, siempre “alejándose del suelo”
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_strength * gravity_direction
         
    # Movimiento horizontal + límites
    velocity += acceleration * delta
    
    if abs(velocity.x) > maxSpeed:
        velocity.x = sign(velocity.x) * maxSpeed

    if acceleration.length() < 0.05:
        velocity.x *= friction
        
    # Animaciones y giro horizontal
    if abs(velocity.x) > 0.05:
        if velocity.x < 0:
            $Sprite.scale.x = -1
        elif velocity.x > 0:
            $Sprite.scale.x = 1
        if is_on_floor():
            $Sprite.play("run")
    else:
        $Sprite.stop()
        $Sprite.frame = 0

    move_and_slide()
    
    # Límite de caída por abajo y por arriba
    if global_position.y > fall_limit_y or global_position.y < top_limit_y:
        respawn()

func respawn():
    global_position = spawn_position
    velocity = Vector2.ZERO
    
    # Reproducir sonido de inversión de gravedad
    if death_sound:
        death_sound.play()

    # Si estaba invertido, volver a gravedad normal al reaparecer
    if gravity_direction == -1:
        gravity_direction = 1
        up_direction = Vector2.UP
        $Sprite.scale.y = abs($Sprite.scale.y)


func toggle_gravity():
    # Reproducir sonido de inversión de gravedad
    if invert_sound:
        invert_sound.play()

    # Cambiamos la dirección de la gravedad
    gravity_direction *= -1

    # Cambiamos la dirección "arriba" del CharacterBody2D
    up_direction *= -1

    # Volteamos el sprite en vertical para que quede boca abajo o al derecho
    $Sprite.scale.y *= -1

    # Opcional reset vertical para evitar tirones
    velocity.y = 0
