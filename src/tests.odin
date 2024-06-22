//+private file
package sparse_set

import "core:fmt"
import "core:testing"

// Unit Tests
Pos :: distinct struct {
	x: f64,
	y: f64,
}

@(test)
test_create_and_destroy :: proc(t: ^testing.T) {
	set := create_sparse_set(Pos, 10)
	testing.expect(t, set.capacity == 10, "Initial capacity should be 10")
	testing.expect(t, size(&set) == 0, "Initial size should be 0")
	destroy_sparse_set(&set)
	testing.expect(t, set.capacity == 0, "Capacity should be 0 after destruction")
}

@(test)
test_insert_and_contains :: proc(t: ^testing.T) {
	set := create_sparse_set(Pos, 10)
	defer destroy_sparse_set(&set)

	testing.expect(t, insert(&set, Pos{10, 10}), "Should be able to insert 5")
	testing.expect(t, contains(&set, Pos{10, 10}), "Set should contain 5")
	testing.expect(t, !contains(&set, Pos{11, 10}), "Set should not contain 10")
	testing.expect(t, size(&set) == 1, "Size should be 1 after insertion")
}

@(test)
test_remove :: proc(t: ^testing.T) {
	set := create_sparse_set(Pos, 10)
	defer destroy_sparse_set(&set)

	insert(&set, Pos{1, 1})
	insert(&set, Pos{2, 2})
	testing.expect(t, remove(&set, Pos{1, 1}), "Should be able to remove 5")
	testing.expect(t, !contains(&set, Pos{1, 1}), "Set should not contain 5 after removal")
	testing.expect(t, contains(&set, Pos{2, 2}), "Set should still contain 10")
	testing.expect(t, size(&set) == 1, "Size should be 1 after removal")
}

@(test)
test_clear :: proc(t: ^testing.T) {
	set := create_sparse_set(Pos, 10)
	defer destroy_sparse_set(&set)

	insert(&set, Pos{1, 1})
	insert(&set, Pos{2, 2})
	clear(&set)
	testing.expect(t, is_empty(&set), "Set should be empty after clear")
	testing.expect(t, size(&set) == 0, "Size should be 0 after clear")
}

@(test)
test_resize :: proc(t: ^testing.T) {
	set := create_sparse_set(Pos, 4)
	defer destroy_sparse_set(&set)

	for i in 1.0 ..= 10.0 {
		insert(&set, Pos{i, i})
	}
	testing.expect(t, set.capacity > 4, "Capacity should have increased")
	testing.expect(t, size(&set) == 10, "All elements should be present")
	for i in 1.0 ..= 10.0 {
		testing.expect(t, contains(&set, Pos{i, i}), fmt.tprintf("Set should contain %d", i))
	}
}

@(test)
test_iterate :: proc(t: ^testing.T) {
	set := create_sparse_set(Pos, 10)
	defer destroy_sparse_set(&set)

	for i in 1.0 ..= 5.0 {
		insert(&set, Pos{i, i})
	}

	elements := iterate(&set)
	testing.expect(t, len(elements) == 5, "Iteration should return 5 elements")
	for element in elements {
		testing.expect(
			t,
			contains(&set, element),
			fmt.tprintf("Iterated element %d should be in set", element),
		)
	}
}
