package sparse_set

import "core:fmt"
import "core:hash"
import "core:mem"
import "core:runtime"
import "core:slice"

Sparse_Set :: struct($T: typeid) {
	sparse:   []int,
	dense:    []T,
	size:     int,
	capacity: int,
}

create_sparse_set :: proc($T: typeid, initial_capacity: int) -> Sparse_Set(T) {
	return(
		Sparse_Set(T) {
			sparse = make([]int, initial_capacity),
			dense = make([]T, initial_capacity),
			size = 0,
			capacity = initial_capacity,
		} \
	)
}

destroy_sparse_set :: proc(set: ^Sparse_Set($T)) {
	delete(set.sparse)
	delete(set.dense)
	set^ = {}
}

hash_value :: proc(value: $T) -> u64 {
	value := value
	data := cast([^]u8)(&value)
	//data := [^]u8(&value)
	size := size_of(T)
	hash: u64 = 14695981039346656037 // FNV-1a offset basis
	//fmt.printf("DEBUG HASH DATA FOR: %v\n", value)
	for i in 0 ..< size {
		//fmt.println(u64(data[i]))
		hash ~= u64(data[i])
		hash *= 1099511628211 // FNV-1a prime
	}
	return hash
}

hash_index :: proc(value: $T, capacity: int) -> int {
	value := value
	//data := [^]u8(&value)
	d_ptr := cast([^]u8)(&value)
	sdata := slice.from_ptr(d_ptr, size_of(T))
	//fmt.printf("Length of hash slice: %d\n", len(sdata))
	//h := hash_value(value)
	h := hash.fnv64a(sdata)
	//h := hash.ginger16(sdata)
	//return int(h)
	return int(h % u64(capacity))
}

resize :: proc(set: ^Sparse_Set($T)) {
	fmt.printf("Resize, old: %d, new: %d\n", set.capacity, set.capacity * 2)
	new_capacity := set.capacity * 2
	new_sparse := make([]int, new_capacity)
	new_dense := make([]T, new_capacity)

	copy(new_dense, set.dense[:set.size])

	for i in 0 ..< set.size {
		value := new_dense[i]
		index := hash_index(value, new_capacity)
		fmt.printf("Resize hash, value: %v, hash: %d\n", value, index)
		new_sparse[index] = i
	}

	delete(set.sparse)
	delete(set.dense)
	set.sparse = new_sparse
	set.dense = new_dense
	set.capacity = new_capacity
}

insert :: proc(set: ^Sparse_Set($T), value: T) -> bool {
	if set.size >= set.capacity / 2 {
		resize(set)
	}

	index := hash_index(value, set.capacity)
	fmt.printf("Insert, value: %v, hash: %d\n", value, index)
	if contains(set, value) {
		return false
	}

	set.sparse[index] = set.size
	set.dense[set.size] = value
	set.size += 1
	return true
}

remove :: proc(set: ^Sparse_Set($T), value: T) -> bool {
	index := hash_index(value, set.capacity)
	fmt.printf("Remove, value: %v, hash: %d\n", value, index)
	if !contains(set, value) {
		return false
	}

	dense_index := set.sparse[index]
	last_element := set.dense[set.size - 1]
	last_index := hash_index(last_element, set.capacity)

	set.dense[dense_index] = last_element
	set.sparse[last_index] = dense_index
	set.size -= 1
	return true
}

contains :: proc(set: ^Sparse_Set($T), value: T) -> bool {
	if set.size == 0 {
		return false
	}
	index := hash_index(value, set.capacity)
	fmt.printf("Contains, value: %v, hash: %d\n", value, index)
	dense_index := set.sparse[index]
	//return dense_index < set.size && set.dense[dense_index] == value
	if dense_index < set.size {
		fmt.printf("Failed Contains, dense_index is larger or equal to set.size")
	}

	if set.dense[dense_index] != value {
		fmt.printf(
			"Failed Contains, values don't match. Set at index: %v vs value: %v\n",
			set.dense[dense_index],
			value,
		)
	}

	return dense_index < set.size && set.dense[dense_index] == value
}

clear :: proc(set: ^Sparse_Set($T)) {
	set.size = 0
}

size :: proc(set: ^Sparse_Set($T)) -> int {
	return set.size
}

is_empty :: proc(set: ^Sparse_Set($T)) -> bool {
	return set.size == 0
}

iterate :: proc(set: ^Sparse_Set($T)) -> []T {
	return set.dense[:set.size]
}
