extends KinematicBody2D

# Health
signal health_changed(value)

export var max_health: int = 100
var health: int = 0

# Attack
export var bullet_damage: int
export var bullet_speed: float
export var attack_rate: float

var bullet = preload("../PlayerBullet.tscn")

# Key
signal obtained_key(value)

var have_key: bool = false

# Movement Variables
export var maxSpeed: int = 50
export var rotation_speed: float = 0.03
var velocity = Vector2.ZERO
var rotation_dir = 0
var speed = 0

func _ready():
	health = max_health
	
	get_node("Attack_Rate").wait_time = attack_rate
	emit_signal("health_changed", health)
	emit_signal("obtained_key", have_key)

func _physics_process(delta: float) -> void:
	get_input()
	rotation = lerp_angle(rotation, rotation_dir * rotation_speed, delta)
	velocity = move_and_slide(velocity)
	
	speed = lerp(speed, 0, 0.05)
	speed = clamp(speed, 0, maxSpeed)
	
	# collisions
	check_gate_collision()
	
	
func get_input() -> void:
	if Input.is_action_pressed("row_left"):
		rotation_dir += 1
		speed = maxSpeed
	if Input.is_action_pressed("row_right"):
		rotation_dir -= 1
		speed = maxSpeed
		
	velocity = Vector2(0, -speed).rotated(rotation)
	
	
func check_gate_collision():
	var collision: KinematicCollision2D = get_last_slide_collision()
	if collision !=  null:
		if collision.collider.name == "Gate":
			if have_key:
				collision.collider.set_unlocked(true)

func obtained_key():
	have_key = true
	emit_signal("obtained_key", have_key)

func take_damage(amount: int):
	health -= amount
	health = clamp(health, 0, 100)
	emit_signal("health_changed", health)

func _on_Attack_Rate_timeout() -> void:
	var new_bullet = bullet.instance()
	new_bullet.position = get_node("Center").global_position
	#new_bullet.position.y -= 50
	new_bullet.bullet_speed = bullet_speed
	new_bullet.bullet_damage = bullet_damage
	get_parent().add_child(new_bullet)
