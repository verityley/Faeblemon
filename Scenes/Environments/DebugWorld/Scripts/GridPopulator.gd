extends Node3D

@export var locationDatabase:TileMap
var testMat = preload("res://Scenes/Environments/DebugWorld/Assets/TestMat.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	Populate()


func Populate():
	
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
			
			self.add_child(meshInstance)

