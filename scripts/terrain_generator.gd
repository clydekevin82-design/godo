extends Node3D

@export var terrain_size := 100
@export var chunk_size := 16
@export var terrain_height := 15.0
@export var noise_frequency := 0.05
@export var tree_density := 0.02
@export var building_count := 4

var noise: FastNoiseLite
var terrain_mesh: ArrayMesh
var terrain_material: StandardMaterial3D
var chunks := {}

func _ready() -> void:
	_setup_noise()
	_setup_material()
	_generate_terrain()
	_spawn_trees()
	_spawn_buildings()

func _setup_noise() -> void:
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = noise_frequency
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.5

func _setup_material() -> void:
	terrain_material = StandardMaterial3D.new()
	terrain_material.albedo_color = Color(0.85, 0.88, 0.92, 1)
	terrain_material.roughness = 1.0
	terrain_material.subsurf_scatter_enabled = true
	terrain_material.subsurf_scatter_strength = 0.6

func _generate_terrain() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Generate vertices with height variation
	var vertices := []
	for z in range(terrain_size + 1):
		for x in range(terrain_size + 1):
			var world_x = x - terrain_size / 2
			var world_z = z - terrain_size / 2
			var height = noise.get_noise_2d(world_x, world_z) * terrain_height
			
			# Add some minecraft-like stepping
			height = floor(height / 2.0) * 2.0
			
			vertices.append(Vector3(world_x, height, world_z))
	
	# Generate triangles
	for z in range(terrain_size):
		for x in range(terrain_size):
			var i = z * (terrain_size + 1) + x
			var i_next_row = (z + 1) * (terrain_size + 1) + x
			
			# Triangle 1
			st.set_normal(Vector3.UP)
			st.set_uv(Vector2(float(x) / terrain_size, float(z) / terrain_size))
			st.add_vertex(vertices[i])
			
			st.set_uv(Vector2(float(x + 1) / terrain_size, float(z) / terrain_size))
			st.add_vertex(vertices[i + 1])
			
			st.set_uv(Vector2(float(x) / terrain_size, float(z + 1) / terrain_size))
			st.add_vertex(vertices[i_next_row])
			
			# Triangle 2
			st.set_uv(Vector2(float(x + 1) / terrain_size, float(z) / terrain_size))
			st.add_vertex(vertices[i + 1])
			
			st.set_uv(Vector2(float(x + 1) / terrain_size, float(z + 1) / terrain_size))
			st.add_vertex(vertices[i_next_row + 1])
			
			st.set_uv(Vector2(float(x) / terrain_size, float(z + 1) / terrain_size))
			st.add_vertex(vertices[i_next_row])
	
	st.generate_normals()
	terrain_mesh = st.commit()
	
	# Create mesh instance
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = terrain_mesh
	mesh_instance.material_override = terrain_material
	add_child(mesh_instance)
	
	# Add collision
	var static_body = StaticBody3D.new()
	mesh_instance.add_child(static_body)
	
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = terrain_mesh.create_trimesh_shape()
	static_body.add_child(collision_shape)

func _spawn_trees() -> void:
	var tree_parent = Node3D.new()
	tree_parent.name = "Trees"
	add_child(tree_parent)
	
	for i in range(int(terrain_size * terrain_size * tree_density)):
		var x = randf_range(-terrain_size / 2.0, terrain_size / 2.0)
		var z = randf_range(-terrain_size / 2.0, terrain_size / 2.0)
		var y = get_terrain_height_at(x, z)
		
		if y > 2.0: # Only spawn on elevated terrain
			var tree = _create_low_poly_tree()
			tree.global_position = Vector3(x, y, z)
			tree_parent.add_child(tree)

func _spawn_buildings() -> void:
	var building_parent = Node3D.new()
	building_parent.name = "Buildings"
	add_child(building_parent)
	
	for i in range(building_count):
		var x = randf_range(-terrain_size / 3.0, terrain_size / 3.0)
		var z = randf_range(-terrain_size / 3.0, terrain_size / 3.0)
		var y = get_terrain_height_at(x, z)
		
		var building = _create_low_poly_building()
		building.global_position = Vector3(x, y, z)
		building.rotation.y = randf() * TAU
		building_parent.add_child(building)

func _create_low_poly_tree() -> Node3D:
	var tree = Node3D.new()
	
	# Trunk
	var trunk = MeshInstance3D.new()
	var trunk_mesh = CylinderMesh.new()
	trunk_mesh.top_radius = 0.3
	trunk_mesh.bottom_radius = 0.4
	trunk_mesh.height = 4.0
	trunk_mesh.radial_segments = 6
	trunk.mesh = trunk_mesh
	
	var trunk_mat = StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.3, 0.25, 0.2, 1)
	trunk_mat.roughness = 0.9
	trunk.material_override = trunk_mat
	trunk.position.y = 2.0
	tree.add_child(trunk)
	
	# Foliage (3 cones)
	var foliage_color = Color(0.15, 0.4, 0.25, 1)
	
	for i in range(3):
		var foliage = MeshInstance3D.new()
		var foliage_mesh = CylinderMesh.new()
		foliage_mesh.top_radius = 0.1
		foliage_mesh.bottom_radius = 2.0 - i * 0.3
		foliage_mesh.height = 2.5
		foliage_mesh.radial_segments = 6
		foliage.mesh = foliage_mesh
		
		var foliage_mat = StandardMaterial3D.new()
		foliage_mat.albedo_color = foliage_color
		foliage_mat.roughness = 0.8
		foliage.material_override = foliage_mat
		foliage.position.y = 3.5 + i * 1.5
		tree.add_child(foliage)
	
	return tree

func _create_low_poly_building() -> Node3D:
	var building = Node3D.new()
	
	var building_type = randi() % 3
	
	match building_type:
		0: # Simple cabin
			building = _create_cabin()
		1: # Tower structure
			building = _create_tower_building()
		2: # Warehouse
			building = _create_warehouse()
	
	return building

func _create_cabin() -> Node3D:
	var cabin = Node3D.new()
	
	# Main structure
	var walls = MeshInstance3D.new()
	var walls_mesh = BoxMesh.new()
	walls_mesh.size = Vector3(6, 4, 6)
	walls.mesh = walls_mesh
	
	var walls_mat = StandardMaterial3D.new()
	walls_mat.albedo_color = Color(0.4, 0.35, 0.3, 1)
	walls_mat.roughness = 0.9
	walls.material_override = walls_mat
	walls.position.y = 2.0
	cabin.add_child(walls)
	
	# Roof
	var roof = MeshInstance3D.new()
	var roof_mesh = PrismMesh.new()
	roof_mesh.size = Vector3(7, 2, 7)
	roof.mesh = roof_mesh
	
	var roof_mat = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.25, 0.2, 0.18, 1)
	roof_mat.roughness = 0.95
	roof.material_override = roof_mat
	roof.position.y = 5.0
	roof.rotation.y = PI / 2
	cabin.add_child(roof)
	
	return cabin

func _create_tower_building() -> Node3D:
	var tower = Node3D.new()
	
	# Base
	var base = MeshInstance3D.new()
	var base_mesh = BoxMesh.new()
	base_mesh.size = Vector3(4, 3, 4)
	base.mesh = base_mesh
	
	var base_mat = StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.35, 0.35, 0.4, 1)
	base_mat.roughness = 0.8
	base_mat.metallic = 0.3
	base.material_override = base_mat
	base.position.y = 1.5
	tower.add_child(base)
	
	# Tower body
	var body = MeshInstance3D.new()
	var body_mesh = CylinderMesh.new()
	body_mesh.top_radius = 1.2
	body_mesh.bottom_radius = 1.5
	body_mesh.height = 10.0
	body_mesh.radial_segments = 8
	body.mesh = body_mesh
	
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.3, 0.32, 0.35, 1)
	body_mat.roughness = 0.7
	body_mat.metallic = 0.4
	body.material_override = body_mat
	body.position.y = 8.0
	tower.add_child(body)
	
	# Top
	var top = MeshInstance3D.new()
	var top_mesh = CylinderMesh.new()
	top_mesh.top_radius = 0.3
	top_mesh.bottom_radius = 1.5
	top_mesh.height = 2.0
	top_mesh.radial_segments = 8
	top.mesh = top_mesh
	
	var top_mat = StandardMaterial3D.new()
	top_mat.albedo_color = Color(0.25, 0.3, 0.35, 1)
	top_mat.roughness = 0.6
	top_mat.metallic = 0.5
	top.material_override = top_mat
	top.position.y = 14.0
	tower.add_child(top)
	
	return tower

func _create_warehouse() -> Node3D:
	var warehouse = Node3D.new()
	
	# Main building
	var main = MeshInstance3D.new()
	var main_mesh = BoxMesh.new()
	main_mesh.size = Vector3(10, 5, 8)
	main.mesh = main_mesh
	
	var main_mat = StandardMaterial3D.new()
	main_mat.albedo_color = Color(0.45, 0.42, 0.4, 1)
	main_mat.roughness = 0.85
	main.material_override = main_mat
	main.position.y = 2.5
	warehouse.add_child(main)
	
	# Roof
	var roof = MeshInstance3D.new()
	var roof_mesh = BoxMesh.new()
	roof_mesh.size = Vector3(10.5, 0.5, 8.5)
	roof.mesh = roof_mesh
	
	var roof_mat = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.3, 0.28, 0.26, 1)
	roof_mat.roughness = 0.9
	roof.material_override = roof_mat
	roof.position.y = 5.25
	warehouse.add_child(roof)
	
	return warehouse

func get_terrain_height_at(x: float, z: float) -> float:
	var height = noise.get_noise_2d(x, z) * terrain_height
	return floor(height / 2.0) * 2.0
