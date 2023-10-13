extends Node3D

var MarchingTable = preload("res://MarchingTables.gd")

var cube_points = []
var shouldUpdate = true
var last_instance: RID
var instance :RID
var mesh_instance:RID
var chunk_transform:Transform3D
@export var map_size = 10
var map_step =1
@export var isoLevel = 0.5
@export var material:Material

# Called when the node enters the scene tree for the first time.
func _ready():

	#var temp_x = []
	#for x in map_size + 1:
	#	temp_x.append( Vector4(1,1,1,1))
	
	#var temp_y = []
	#for x in map_size + 1:
	#	temp_y.append(temp_x)
	
	#for z in map_size +1 :
	#	self.cube_points.append(temp_y)
	
	for x in range(map_size + 1):
		var temp = []
		for y in range(map_size + 1):
			var temp_z = []
			for z in  range(map_size + 1):
				temp_z.append(Vector4(x,y,z,1))
			temp.append(temp_z)
		self.cube_points.append(temp)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
	
func update():
	draw()
	if shouldUpdate == false:
		return
	var last_instance
	var surftool = SurfaceTool.new()
	#get a copy of the last instance
	if instance:
		last_instance = instance
	surftool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var vert = 0
	for y in map_size:
		for x in map_size:
			for z in map_size:
				var cubeCorner0 = self.cube_points[x][y][z]
				var cubeCorner1 = self.cube_points[x+1][y][z]
				var cubeCorner2 = self.cube_points[x + 1][y][z + 1]
				var cubeCorner3 = self.cube_points[x][y][z + 1]
				var cubeCorner4 = self.cube_points[x][y+1][z]
				var cubeCorner5 = self.cube_points[x+1][y+1][z]
				var cubeCorner6 = self.cube_points[x+1][y+1][z + 1]
				var cubeCorner7 = self.cube_points[x][y+1][z + 1]
				
				var  cubeCorners = [cubeCorner0,cubeCorner1,cubeCorner2,cubeCorner3,cubeCorner4,cubeCorner5,cubeCorner6,cubeCorner7]			
				var cubeIndex:int = 0
				if cubeCorner0.w <= self.isoLevel:
					cubeIndex |= 1
				if cubeCorner1.w <= self.isoLevel:
					cubeIndex |= 2
				if cubeCorner2.w <= self.isoLevel:
					cubeIndex |= 4
				if cubeCorner3.w <= self.isoLevel:
					cubeIndex |= 8
				if cubeCorner4.w <= self.isoLevel:
					cubeIndex |= 16
				if cubeCorner5.w <= self.isoLevel:
					cubeIndex |= 32
				if cubeCorner6.w <= self.isoLevel:
					cubeIndex |= 64	
				if cubeCorner7.w <= self.isoLevel:
					cubeIndex |= 128
				var index = 0

				while index <= 16 and MarchingTable.triangulation[cubeIndex][index] != -1:
					var a0 = MarchingTable.cornerIndexAFromEdge[MarchingTable.triangulation[cubeIndex][index]]
					var b0 = MarchingTable.cornerIndexBFromEdge[MarchingTable.triangulation[cubeIndex][index]]
					var a1 = MarchingTable.cornerIndexAFromEdge[MarchingTable.triangulation[cubeIndex][index + 1]]
					var b1 = MarchingTable.cornerIndexBFromEdge[MarchingTable.triangulation[cubeIndex][index + 1]]
					var a2 = MarchingTable.cornerIndexAFromEdge[MarchingTable.triangulation[cubeIndex][index + 2]]
					var b2 = MarchingTable.cornerIndexBFromEdge[MarchingTable.triangulation[cubeIndex][index + 2]]
					index += 3
					var vertA = interpolateVerts(cubeCorners[a0]* map_step,cubeCorners[b0] *map_step) 
					var vertB = interpolateVerts(cubeCorners[a1]* map_step,cubeCorners[b1] * map_step) 
					var vertC = interpolateVerts(cubeCorners[a2]* map_step,cubeCorners[b2] * map_step) 

					surftool.add_vertex(vertA)
					surftool.add_vertex(vertB)
					surftool.add_vertex(vertC)
					
					surftool.add_index(vert+2)
					surftool.add_index(vert+1)
					surftool.add_index(vert)
					vert += 3
	surftool.generate_normals()
	var mesh_data = surftool.commit_to_arrays()
	if vert != 0:
		instance = RenderingServer.instance_create()
		mesh_instance = RenderingServer.mesh_create()
		RenderingServer.instance_set_base(instance,mesh_instance)
		RenderingServer.instance_set_scenario(instance,get_world_3d().scenario)
	
		chunk_transform.origin = Vector3(0,0,0)
		RenderingServer.instance_set_transform(instance,chunk_transform)
		RenderingServer.mesh_add_surface_from_arrays(mesh_instance,RenderingServer.PRIMITIVE_TRIANGLES,mesh_data)
		RenderingServer.mesh_surface_set_material(mesh_instance,0,material)

		#remove the last instance
		#this prevents blinking
		if last_instance:
			RenderingServer.free_rid(last_instance)
	shouldUpdate = false

					
func interpolateVerts(left:Vector4, right:Vector4):
	#var t = (isoLevel - left.w) / (right.w - left.w)
	var t = 0.5
	var result = left + t * (right - left)
	return Vector3(result.x,result.y,result.z)

func draw():
	for y in map_size + 1:
		
		for x in map_size +1 :
			var point_begin = Vector3(x  * map_step,y * map_step, 0)
			var point_end = Vector3(x  * map_step,y * map_step, (map_size + 1) *map_step)
			DebugDraw3D.draw_line(point_begin,point_end,Color.RED)
		for z  in map_size +1:
			var point_begin = Vector3(0,y * map_step, z * map_step)
			var point_end = Vector3((map_size + 1) *map_step,y * map_step, z* map_step)
			DebugDraw3D.draw_line(point_begin,point_end,Color.RED)		
	for x in map_size + 1: 
		for y in map_size + 1:
			for z in map_size +1:
				if self.cube_points[x][y][z].w == 1:
					DebugDraw3D.draw_sphere(Vector3(x * map_step,y * map_step,z * map_step),0.1,Color.BLUE)			


func _on_add_sphere_set_flag(pos:Vector3):
	var x = pos.x / map_step
	var y = pos.y / map_step
	var z = pos.z / map_step

	if x <0 or x > map_size:
		return
	if y <0 or y > map_size:
		return
	if z <0 or z > map_size:
		return
		
	var origin = Vector3(x,y,z)
	for i in range(x-1,x+1):
		if i < 0 || i > map_size +1:
			continue
		for j in range(y-1,y+1):
			if j < 0 || j > map_size +1:
				continue
			for k in range(z-1,z+1):
				if k < 0 || k > map_size +1:
					continue
				if self.cube_points[x][y][z].w == 0.4:
					continue
				var dist = origin.distance_to(Vector3(i,j,k))
				if dist <=0.5:
					self.cube_points[x][y][z].w = 0.4
					self.shouldUpdate = true
					

