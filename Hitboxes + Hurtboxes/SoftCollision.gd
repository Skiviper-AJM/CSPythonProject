extends Area2D

# Function to check if the entity is currently colliding with another area
func is_colliding():
	var areas = get_overlapping_areas()
	return areas.size() > 0

# Function to calculate the direction the entity should be pushed in when colliding with another area
func get_push_vector():
	var areas = get_overlapping_areas()
	var push_vector = Vector2.ZERO

	# If there's a collision, determine the push direction
	if is_colliding():
		var area = areas[0]
		push_vector = area.global_position.direction_to(global_position)
		push_vector = push_vector.normalized()
	
	return push_vector
