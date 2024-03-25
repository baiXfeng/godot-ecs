# godot-ecs
Light ecs framework wirtten with gdscript.

# Features

- Lightweight and high-performance.
- Independent of Node components, can run standalone in memory.
- Components and systems support serialization and deserialization.
- Easy to use.

# How To Use

- Copy the 'ecs' directory to any location within your Godot project.
- Begin your ECS coding journey with the following code:

```

# create ecs world
var world = ecs_world.new()

# create entity
var e = world.create_entity()

# add component
e.add_component("c1", ecs_component.new())
e.add_component("c2", ecs_component.new())
e.add_component("c3", ecs_component.new())

# add system
world.add_system("s1", ecs_system.new())
world.add_system("s2", ecs_system.new())
world.add_system("s2", ecs_system.new())

# run system
world.on_physics_process("s1", delta)
world.on_process("s1", delta)

# fetch components
var component_list = world.fetch_components("c1")
for c in component_list:
	# get component from entity
	var entity = c.entity()
	var c1 = entity.get_component("c1")
	var c2 = entity.get_component("c2")
	var c3 = entity.get_component("c3")
	# get entity's all components
	var all_components = entity.get_components()
	
# serialize components
var component_serialize_dict = {}
for c in component_list:
	var all_components = c.entity().get_components()
	var entity_data = {}
	for cc in all_components:
	  var data = {}
		cc.save(data)
		entity_data[ data.ecs_name ] = data
	var entity_id = c.entity().id()
	component_serialize_dict[ entity_id ] = entity_data
printt("this is entity serialize data", component_serialize_dict)

```
