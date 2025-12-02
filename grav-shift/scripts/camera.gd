extends Node2D

@export var player_path: NodePath
@export var camera_speed = 4
@export var left_limit_x = 0.0

var target_pos = 0

func _process(delta):
    var player = get_node(player_path) as CharacterBody2D
    
    target_pos = player.position.x - 576

    if target_pos < left_limit_x:
        target_pos = left_limit_x

    position.x = lerp(position.x, target_pos, delta * camera_speed)
    
