package sset

import "base:builtin"
import "core:fmt"
import "core:mem"
import "core:runtime"
import "core:slice"

Entity :: distinct int

SSet :: struct($T: typeid) {
	// Sparse.
	// Stores the idx for  entities list. It's idx is the Entity Ids.
	entity_idx:    [dynamic]int,

	// Dense.
	// Stores the Entity Ids. Idx has no meaning, but must be valid idx stored in entity_idx.
	entities:      [dynamic]Entity,

	// Dense.
	// Stores component data. Aligned with entities list, such entities[n] has component data of components[n]
	components:    [dynamic]T,
	size:          int, // How many entities exist in set
	sparse_length: int, // Length of entity_idx, our sparse array.
}

create :: proc($T: typeid, length: Maybe(int) = nil) -> SSet(T) {
	length := length.? or_else 10
	return(
		SSet(T) {
			entity_idx = make([dynamic]int, length),
			entities = make([dynamic]Entity),
			components = make([dynamic]T),
			size = 0,
			sparse_length = length,
		} \
	)
}

destroy :: proc(set: ^SSet($T)) {
	delete(set.entity_idx)
	delete(set.entities)
	delete(set.components)
	set^ = {}
}

insert :: proc(set: ^SSet($T), entity: Entity, value: T) -> bool {
	entity_id := int(entity)
	if entity_id >= set.sparse_length {
		fmt.printf("Resizing sparse array to: %d\n", entity_id + 1)
		resize(&set.entity_idx, entity_id + 1)
		set.sparse_length = entity_id + 1
	}

	if contains(set, entity) {
		return false
	}

	set.entity_idx[entity] = set.size
	append(&set.entities, entity)
	append(&set.components, value)

	set.size += 1
	return true
}

set :: proc(set: ^SSet($T), entity: Entity, value: T) -> bool {
	if !contains(set, entity) {
		return insert(set, entity, value)
	}

	idx := set.entity_idx[entity]
	set.entities[idx] = entity
	set.components[idx] = value

	set.size += 1
	return true
}
remove :: proc(set: ^SSet($T), entity: Entity) -> bool {
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
		"SSet Bug. entities and components dynamic arrays are out of sync",
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

contains_entity :: proc(set: ^SSet($T), entity: Entity) -> bool {
	if len(set.components) == 0 {
		return false
	}
	idx := set.entity_idx[entity]
	return set.entities[idx] == entity
}

// Similar to contains, but checks for value equality
contains_value :: proc(set: ^SSet($T), entity: Entity, value: T) -> bool {
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

clear :: proc(set: ^SSet($T)) {
	set.size = 0
	builtin.clear(&set.entities)
	builtin.clear(&set.components)
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
	fmt.printf("\nSparse: %v\n", set.entity_idx)
	fmt.printf("\nEntities: %v\n", set.entities)
	fmt.printf("\nComponents: %v\n", set.components)
}
