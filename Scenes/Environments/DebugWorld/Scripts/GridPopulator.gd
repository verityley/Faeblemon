@tool
extends EditorScript

@export var locationDatabase:TileMap
var testMat = preload("res://Scenes/Environments/DebugWorld/Assets/TestMat.tres")
var populated:bool = false
@export var gridNode:Node
@export var deleteAll:bool = false

# Called when the node enters the scene tree for the first time.
func _run():
	gridNode = get_scene()
	locationDatabase = get_scene().get_node("TileMap")
	if deleteAll == false:
		Populate()
	else:
		for mesh in gridNode.get_children():
			if mesh is MeshInstance3D:
				mesh.queue_free()
		gridNode.populated = false


func Populate():
	if gridNode.populated == true:
		for mesh in gridNode.get_children():
			if mesh is MeshInstance3D:
				mesh.queue_free()
		gridNode.populated = false
	
	for layer in range(locationDatabase.get_layers_count()):
		for tile in locationDatabase.get_used_cells(layer):
			var tileCoords:Vector3i = Vector3i(tile.x, layer, tile.y+layer)
			var tileMesh = locationDatabase.get_cell_tile_data(layer, tile).get_custom_data("3DTile")
			#print(tileMesh)
			var meshInstance = MeshInstance3D.new()
			
			meshInstance.mesh = tileMesh
			meshInstance.material_override = testMat
			meshInstance.position = tileCoords
			meshInstance.scale = Vector3(0.5, 0.5, 0.5)
			#print(meshInstance.position)
			
			gridNode.add_child(meshInstance)
			meshInstance.owner = get_scene()
			populated = true
	
	gridNode.locationDatabase = locationDatabase

