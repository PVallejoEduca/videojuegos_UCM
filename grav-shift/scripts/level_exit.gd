extends Area2D

@export_file("*.tscn") var next_level_scene

var player_inside := false

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"): # minúsculas, igual que el grupo del Player
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
    if next_level_scene != "":
        print("Cambiando a escena: ", next_level_scene)
        get_tree().change_scene_to_file(next_level_scene)
    else:
        print("Salida de nivel activada, pero no hay escena asignada")
