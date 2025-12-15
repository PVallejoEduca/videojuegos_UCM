extends Control

@export_file("*.tscn") var first_level_scene: String = "res://scenes/world_1.tscn"

@onready var play_button: Button = $VBoxMain/Buttons/PlayButton
@onready var quit_button: Button = $VBoxMain/Buttons/QuitButton

func _ready() -> void:
    play_button.pressed.connect(_on_play_button_pressed)
    quit_button.pressed.connect(_on_quit_button_pressed)

func _on_play_button_pressed() -> void:
    if first_level_scene == "" or first_level_scene == null:
        push_error("first_level_scene no está configurado")
        return
    get_tree().change_scene_to_file(first_level_scene)

func _on_quit_button_pressed() -> void:
    get_tree().quit()
