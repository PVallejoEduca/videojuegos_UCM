extends Area2D

@export_file("*.tscn") var next_level_scene: String = ""

var player_inside := false
var activated := false

@onready var lever_off: Sprite2D = $LeverOff
@onready var lever_on: Sprite2D = $LeverOn
@onready var message_label: Label = $LevelMessage
@onready var level_sound: AudioStreamPlayer = $LevelCompleteSound
@onready var level_music: AudioStreamPlayer = get_node_or_null("../LevelMusic")

func _ready() -> void:
    # Estado inicial: palanca apagada visible, encendida oculta, sin mensaje
    if lever_off:
        lever_off.visible = true
    if lever_on:
        lever_on.visible = false
    if message_label:
        message_label.visible = false

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_inside = true
        print("Player ha entrado en LevelExit")

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_inside = false
        print("Player ha salido de LevelExit")

func _process(delta: float) -> void:
    if player_inside and Input.is_action_just_pressed("interact"):
        change_level()

func change_level() -> void:
    if activated:
        return

    if next_level_scene == "" or next_level_scene == null:
        print("Salida de nivel activada, pero no hay escena asignada")
        return

    activated = true

    if lever_off:
        lever_off.visible = false
    if lever_on:
        lever_on.visible = true

    if message_label:
        message_label.visible = true

    if level_sound and level_sound.stream:
        # Bajar un poco el volumen de la música de fondo
        if level_music:
            level_music.volume_db = -35.0

        level_sound.play()
        print("Reproduciendo sonido")
        await level_sound.finished
    else:
        print("No hay sonido asignado")
        await get_tree().create_timer(1.5).timeout

    print("Cambiando a escena: ", next_level_scene)
    get_tree().change_scene_to_file(next_level_scene)
