extends ParallaxBackground

var speed_cloud: int = 30
var stop_position_cloud: float = 0.0
	
func _process(delta):
	var parallax_layer_cloud_left := $Layer_cloud_left
	var parallax_layer_cloud_right := $Layer_cloud_right
	var screen_size = get_viewport().size
	
	if parallax_layer_cloud_left.global_position.x <= stop_position_cloud:
		parallax_layer_cloud_left.motion_offset.x += speed_cloud * delta
	if parallax_layer_cloud_right.global_position.x >= stop_position_cloud:
		parallax_layer_cloud_right.motion_offset.x -= speed_cloud * delta
	
