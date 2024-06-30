package sparse_set

import "base:builtin"
import "core:fmt"
import "core:mem"
import "core:runtime"
import "core:slice"

Entity :: distinct uint

Set :: struct($T: typeid) {
	// Sparse.
	// Stores the idx for  entities list. It's idx is the Entity Ids.
	entity_idx: [dynamic]uint,

	// Dense.
	// Stores the Entity Ids. Idx has no meaning, but must be valid idx stored in entity_idx.
	entities:   [dynamic]Entity,

	// Dense.
	// Stores component data. Aligned with entities list, such entities[n] has component data of components[n]
	components: [dynamic]T,
	size:       uint, // How many entities exist in set
	capacity:   uint, // Length of entity_idx, our sparse array.
}

create :: proc($T: typeid, capacity: Maybe(uint) = nil) -> Set(T) {
	capacity := capacity.? or_else 10
	return(
		Set(T) {
			entity_idx = make([dynamic]uint, capacity),
			entities = make([dynamic]Entity),
			components = make([dynamic]T),
			size = 0,
			capacity = capacity,
		} \
	)
}

init :: proc(s: ^Set($T), capacity: Maybe(uint) = nil) {
	capacity := capacity.? or_else 10
	s.entity_idx = make([dynamic]uint, capacity)
	s.entities = make([dynamic]Entity)
	s.components = make([dynamic]T)
	s.size = 0
	s.capacity = capacity
}

destroy :: proc(set: ^Set($T)) {
	delete(set.entity_idx)
	delete(set.entities)
	delete(set.components)
	set^ = {}
}

insert :: proc(set: ^Set($T), entity: Entity, value: T) -> bool {
	entity_id := uint(entity)
	if entity_id >= set.capacity {
		fmt.printf("Resizing sparse array to: %d\n", entity_id + 1)
		resize(&set.entity_idx, int(entity_id + 1))
		set.capacity = entity_id + 1
	}

	if contains(set, entity) {
		return false
	}

	set.entity_idx[entity_id] = set.size
	append(&set.entities, entity)
	append(&set.components, value)

	set.size += 1
	return true
}

set :: proc(s: ^Set($T), entity: Entity, value: T) -> bool {
	if !contains(s, entity) {
		return insert(s, entity, value)
	}

	idx := s.entity_idx[entity]
	s.entities[idx] = entity
	s.components[idx] = value

	return true
}

get :: proc(set: ^Set($T), entity: Entity) -> (^T, bool) {
	if int(entity) > len(set.entity_idx) {
		fmt.printf("Invalid Entity. Out of range. Entity: %d\n", entity)
		return nil, false
	}

	if len(set.components) == 0 {
		return nil, false
	}

	idx := set.entity_idx[entity]
	if set.entities[idx] != entity {
		return nil, false
	}
	return &set.components[idx], true
}

remove :: proc(set: ^Set($T), entity: Entity) -> bool {
	if !contains(set, entity) {
		return false
	}

	idx := set.entity_idx[entity]

	last_entity := pop(&set.entities)
	last_idx := set.entity_idx[last_entity]
	last_component_d := set.components[last_idx]
	last_component := pop(&set.components)
	assert(
		last_component_d == last_component,
		"Set Bug. entities and components dynamic arrays are out of sync",
	)

	// Move the last entity into the hole created from removing an entity.
	// If the entity to remove is the last entity in the list, we're still tightly packed.
	if idx != last_idx {
		set.entities[idx] = last_entity
		set.components[idx] = last_component
		set.entity_idx[last_entity] = idx
	}

	// Remove it's index from the sparse array
	set.entity_idx[entity] = 0

	set.size -= 1
	return true
}

contains_entity :: proc(set: ^Set($T), entity: Entity) -> bool {
	if int(entity) >= len(set.entity_idx) {
		fmt.printf("Invalid Entity. Out of range. Entity: %d\n", entity)
		return false
	}
	if len(set.components) == 0 {
		return false
	}
	idx := set.entity_idx[entity]
	return set.entities[idx] == entity
}

// Similar to contains, but checks for value equality
contains_value :: proc(set: ^Set($T), entity: Entity, value: T) -> bool {
	if int(entity) >= len(set.entity_idx) {
		fmt.printf("Invalid Entity. Out of range. Entity: %d\n", entity)
		return false
	}

	if len(set.components) == 0 {
		return false
	}

	idx := set.entity_idx[entity]
	return set.entities[idx] == entity && set.components[idx] == value
}

contains :: proc {
	contains_entity,
	contains_value,
}

clear :: proc(set: ^Set($T)) {
	set.size = 0
	builtin.clear(&set.entities)
	builtin.clear(&set.components)
}

size :: proc(set: ^Set($T)) -> uint {
	return set.size
}

is_empty :: proc(set: ^Set($T)) -> bool {
	return set.size == 0
}

iterate :: proc(set: ^Set($T)) -> []T {
	return set.components[:set.size]
}

iterate_entities :: proc(set: ^Set($T)) -> []Entity {
	return set.entities[:]
}

pprint :: proc(set: ^Set($T)) {
	fmt.printf("\nSparse: %v\n", set.entity_idx)
	fmt.printf("\nEntities: %v\n", set.entities)
	fmt.printf("\nComponents: %v\n", set.components)
}
