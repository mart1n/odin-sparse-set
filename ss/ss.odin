package sset

import "core:fmt"
import "core:mem"
import "core:runtime"
import "core:slice"

Entity :: distinct int

SSet :: struct($T: typeid) {
	// Sparse.
	// Stores the idx for  entities list. It's idx is the Entity Ids.
	entity_idx: []int,

	// Dense.
	// Stores the Entity Ids. Idx has no meaning, but must be valid idx stored in entity_idx.
	entities:   [dynamic]Entity,

	// Dense.
	// Stores component data. Aligned with entities list, such entities[n] has component data of components[n]
	components: [dynamic]T,
	size:       int,
	capacity:   int,
}

create :: proc($T: typeid, initial_capacity: Maybe(int) = nil) -> SSet(T) {
	return(
		SSet(T) {
			entity_idx = make([]int, initial_capacity),
			entities = make([dynamic]Entity, initial_capacity),
			components = make([dynamic]T, initial_capacity),
			size = 0,
			capacity = initial_capacity,
		} \
	)
}

destroy :: proc(set: ^SSet($T)) {
	delete(set.entity_idx)
	delete(set.entities)
	delete(set.components)
	set^ = {}
}

resize :: proc(set: ^SSet($T)) {
	fmt.printf("Resize, old: %d, new: %d\n", set.capacity, set.capacity * 2)
	new_capacity := set.capacity * 2

	// Increase capacity of the dynamic arrays
	builtin.resize(&set.entities, new_capacity)
	builtin.resize(&set.components, new_capacity)

	new_entity_idx := make([]int, new_capacity)
	for i in 0 ..< set.size {
		new_entity_idx[set.entities[i]] = i
	}

	delete(set.entity_idx)
	set.entity_idx = new_entity_idx
	set.capacity = new_capacity
}

insert :: proc(set: ^SSet($T), entity: Entity, value: T) -> bool {
	if set.size >= set.capacity / 2 {
		resize_set(set)
	}

	if contains(set, entity, value) {
		return false
	}

	set.entity_idx[entity] = set.size
	set.entities[set.size] = entity
	set.components[set.size] = value
	//append(&set.entities, entity)
	//append(&set.components, value)

	set.size += 1
	return true
}

remove :: proc(set: ^SSet($T), entity: Entity, value: T) -> bool {
	if !contains(set, entity, value) {
		return false
	}

	idx := set.entity_idx[entity]

	last_entity := pop(&set.entities)
	last_idx := set.entity_idx[last_entity]
	last_component := set.components[last_idx]

	set.entities[idx] = last_entity
	set.components[idx] = last_component
	set.entity_idx[last_entity] = idx

	set.size -= 1
	return true
}

// Provided Entity exists in set. Similar to contains, but doesn't check for value equality
exists :: proc(set: ^SSet($T), entity: Entity) -> bool {
	if len(set.components) == 0 {
		return false
	}

	idx := set.entity_idx[entity]
	return set.entities[idx] == entity
}

contains :: proc(set: ^SSet($T), entity: Entity, value: T) -> bool {
	if len(set.components) == 0 {
		return false
	}

	idx := set.entity_idx[entity]
	return set.entities[idx] == entity && set.components[idx] == value
}

clear_set :: proc(set: ^SSet($T)) {
	set.size = 0
	clear(&set.entities)
	clear(&set.components)
}

size :: proc(set: ^SSet($T)) -> int {
	return set.size
}

is_empty :: proc(set: ^SSet($T)) -> bool {
	return set.size == 0
}

iterate :: proc(set: ^SSet($T)) -> []T {
	return set.components[:set.size]
}

pprint :: proc(set: ^SSet($T)) {
	for i, idx in set.entity_idx {
		fmt.printf("Entity Id: %d place in the entities list is %d\n", idx, set.entity_idx[idx])
	}
	for i, idx in set.entities {
		fmt.printf("Entitites List Idx: %d points to Entity Id: %d\n", idx, i)
	}

	for i, idx in set.components {
		fmt.printf("Components List Idx: %d points to Component: %v\n", idx, i)
	}

}
