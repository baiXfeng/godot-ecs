# godot-ecs
Lightweight ecs framework wirtten with gdscript.

![](ecs.png)

# Features

- Lightweight and high-performance.
- Components support serialization and deserialization.
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
world.add_system("s3", ecs_system.new())

# add command
world.add_command("my_command", ecs_command)

# send notification
world.notify("my_notification", with_param)
world.notify("my_command", with_param)

# view components
var component_list = world.view("c1")
for c in component_list:
	# get component from entity
	var entity = c.entity()
	var c1 = entity.get_component("c1")
	var c2 = entity.get_component("c2")
	var c3 = entity.get_component("c3")
	# get entity's all components
	var all_components = entity.get_components()

# multi view components
for dict in world.multi_view(["c1", "c2", "c3"])
	print(dict)
	
# serialize components
var serialize_dict = {}
for c in component_list:
	var e: ecs_entity = c.entity()
	var all_components = e.get_components()
	var entity_data = {}
	for cc in all_components:
		var data = {}
		cc.save( data )
		entity_data[ cc.name() ] = data
	var entity_id = e.id()
	serialize_dict[ entity_id ] = entity_data

printt("this is entity serialize data", serialize_dict)

```
