extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var death_anim: AnimatedSprite2D = $Death
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
var gravity_direction = 1 
var is_dead = false

func _ready():
    spawn_position = global_position
    up_direction = Vector2.UP
    death_anim.visible = false

func _process(delta):
    # Si está en animación de muerte, no aceptamos input
    if is_dead:
        move_and_slide()
        return

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

    # Salto, siempre alejándose del suelo
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
            sprite.scale.x = -1
        elif velocity.x > 0:
            sprite.scale.x = 1
        if is_on_floor():
            sprite.play("run")
    else:
        sprite.stop()
        sprite.frame = 0

    move_and_slide()

    # Comprobar si hemos chocado con un hazard (pinchos, sierras, etc)
    check_hazard_collisions()

    # Caer fuera de pantalla sigue siendo muerte instantánea sin animación extra
    if not is_dead and (global_position.y > fall_limit_y or global_position.y < top_limit_y):
        respawn()

func respawn():
    global_position = spawn_position
    velocity = Vector2.ZERO

    # Reset gravedad a normal
    if gravity_direction == -1:
        gravity_direction = 1
        up_direction = Vector2.UP

    # Reset visual
    sprite.scale.y = abs(sprite.scale.y)
    is_dead = false

    death_anim.stop()
    death_anim.visible = false

    sprite.visible = true
    sprite.stop()
    sprite.frame = 0

func toggle_gravity():
    # Reproducir sonido de inversión de gravedad
    if invert_sound:
        invert_sound.play()

    gravity_direction *= -1
    up_direction *= -1

    sprite.scale.y *= -1
    velocity.y = 0
    
func check_hazard_collisions() -> void:
    if is_dead:
        return

    # Recorremos todas las colisiones de este frame
    for i in range(get_slide_collision_count()):
        var collision = get_slide_collision(i)
        var collider = collision.get_collider()
        if collider and collider.is_in_group("hazard"):
            die_on_hazard()
            return    # con una vez basta

func die_on_hazard() -> void:
    if is_dead:
        return

    is_dead = true
    velocity = Vector2.ZERO

    # Sonido de muerte si existe el nodo
    if death_sound:
        death_sound.play()

    # Posicionar animación de muerte donde está el player
    death_anim.global_position = global_position
    death_anim.scale = sprite.scale

    sprite.visible = false
    death_anim.visible = true

    # Reproducir animación de muerte y esperar a que termine
    if death_anim.sprite_frames:
        death_anim.play() # usa la animación "default"
        await death_anim.animation_finished

    # Al terminar la animación, respawn
    respawn()
