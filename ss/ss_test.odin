package sset

import "core:fmt"
import "core:testing"

// Unit Tests
Pos :: distinct struct {
	x: f64,
	y: f64,
}

e1 :Entity = 1
e2 :Entity = 2
e3 :Entity = 3
e4 :Entity = 4
e5 :Entity = 5
e6 :Entity = 6
e7 :Entity = 7
e8 :Entity = 8
e9 :Entity = 9
e10 :Entity = 10
el := []Entity{e1, e2, e3, e4, e5, e6, e7, e8, e9, e10}

@(test)
test_debug :: proc(t: ^testing.T) {
	set := create(Pos, 10)
	defer destroy(&set)
    insert(&set, e1, Pos{1, 1})
    insert(&set, e2, Pos{101, 201})
    pprint(&set)
}

@(test)
test_create_and_destroy :: proc(t: ^testing.T) {
	set := create(Pos, 10)
	testing.expect(t, set.capacity == 10, "Initial capacity should be 10")
	testing.expect(t, size(&set) == 0, "Initial size should be 0")
	destroy(&set)
	testing.expect(t, set.capacity == 0, "Capacity should be 0 after destruction")
}

@(test)
test_insert_and_contains :: proc(t: ^testing.T) {
	set := create(Pos, 10)
	defer destroy(&set)

	testing.expect(t, insert(&set, e1, Pos{10, 10}), "Should be able to insert 5")
	testing.expect(t, contains(&set, e1, Pos{10, 10}), "Set should contain 5")
	testing.expect(t, !contains(&set, e1, Pos{11, 10}), "Set should not contain 10")
	testing.expect(t, size(&set) == 1, "Size should be 1 after insertion")
}

@(test)
test_remove :: proc(t: ^testing.T) {
	set := create(Pos, 10)
	defer destroy(&set)

	insert(&set, e1, Pos{1, 1})
	insert(&set, e2, Pos{2, 2})
	testing.expect(t, remove(&set, e1, Pos{1, 1}), "Should be able to remove")
	testing.expect(t, !contains(&set, e1, Pos{1, 1}), "Set should not contain 5 after removal")
	testing.expect(t, contains(&set, e2, Pos{2, 2}), "Set should still contain 10")
	testing.expect(t, size(&set) == 1, "Size should be 1 after removal")
}

@(test)
test_clear :: proc(t: ^testing.T) {
	set := create(Pos, 10)
	defer destroy(&set)

	insert(&set, e1, Pos{1, 1})
	insert(&set, e2, Pos{2, 2})
	clear_set(&set)
	testing.expect(t, is_empty(&set), "Set should be empty after clear")
	testing.expect(t, size(&set) == 0, "Size should be 0 after clear")
}

@(test)
test_resize :: proc(t: ^testing.T) {
	set := create(Pos, 5)
	defer destroy(&set)

	for i in 0 ..= 9 {
		insert(&set, el[i], Pos{f64(i), f64(i)})
	}
	testing.expect(t, set.capacity > 4, "Capacity should have increased")
	testing.expect(t, size(&set) == 10, "All elements should be present")
	for i in 0 ..= 9 {
		testing.expect(
			t,
			contains(&set, el[i], Pos{f64(i), f64(i)}),
			fmt.tprintf("Set should contain %d", Pos{f64(i), f64(i)}),
		)
	}

    pprint(&set)
}

@(test)
test_iterate :: proc(t: ^testing.T) {
	set := create(Pos, 10)
	defer destroy(&set)


	for i in 0 ..= 4 {
		insert(&set, el[i], Pos{f64(i), f64(i)})
	}

	elements := iterate(&set)
	testing.expect(t, len(elements) == 5, "Iteration should return 5 elements")
	for element, idx in elements {
		fmt.println("Iterate: ", element)
		testing.expect(
			t,
			contains(&set, el[idx], element),
			fmt.tprintf("Iterated element %d should be in set", element),
		)
	}
}

