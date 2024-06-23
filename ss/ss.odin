package sset

import "core:fmt"
import "core:hash"
import "core:mem"
import "core:runtime"
import "core:slice"

Entity :: distinct int

SSet :: struct($T: typeid) {
	// Sparse. Stores the idx for entity_list. It's idx is the Entity Ids.
	entity_idx: []int,

	// Dense. Stores the Entity Ids. Idx has no meaning, but must be valid idx stored in entity_indices.
	entities:   [dynamic]Entity,

	// Stores component data. Aligned with entity_list, such entity_list[n] has component data of components[n]
	components: [dynamic]T,
	size:       int,
	capacity:   int,
}

create :: proc($T: typeid, initial_capacity: int) -> SSet(T) {
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

insert :: proc(set: ^SSet($T), entity: int, value: T) -> bool {
	set.entity_idx[entity] = len(set.entities)
	append(set.entities, entity)
	append(set.components, value)
	return true
}
