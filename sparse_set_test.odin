package sparse_set

import "core:fmt"
import "core:testing"

// Unit Tests
Pos :: distinct struct {
	x: f64,
	y: f64,
}

e0: Entity = 0
e1: Entity = 1
e2: Entity = 2
e3: Entity = 3
e4: Entity = 4
e5: Entity = 5
e6: Entity = 6
e7: Entity = 7
e8: Entity = 8
e9: Entity = 9
e10: Entity = 10

@(test)
test_debug :: proc(t: ^testing.T) {
	set := create(Pos, 10)
	defer destroy(&set)
	insert(&set, e1, Pos{1, 1})
	insert(&set, e2, Pos{101, 201})
	pprint(&set)
}

@(test)
test_create_and_get :: proc(t: ^testing.T) {
	set := create(Pos, 20)
	defer destroy(&set)
	testing.expect(t, size(&set) == 0, "Initial size should be 0")
	testing.expect(t, len(set.entities) == 0, "length should be 0 after destruction")

	testing.expect(t, insert(&set, e1, Pos{10, 10}), "Should be able to insert")
	v, _ := get(&set, e1)
	testing.expect(t, v^ == Pos{10, 10}, "Insert value should match Get value")
}

@(test)
test_create_and_destroy_explicit_length :: proc(t: ^testing.T) {
	set := create(Pos, 20)
	testing.expect(t, len(set.entity_idx) == 20, "Initial length should be 10")
	testing.expect(t, size(&set) == 0, "Initial size should be 0")
	destroy(&set)
	testing.expect(t, len(set.entities) == 0, "length should be 0 after destruction")
}

@(test)
test_create_and_destroy_default_length :: proc(t: ^testing.T) {
	set := create(Pos)
	testing.expect(t, len(set.entity_idx) == 10, "Initial length should be 10")
	testing.expect(t, size(&set) == 0, "Initial size should be 0")
	destroy(&set)
	testing.expect(t, len(set.entities) == 0, "length should be 0 after destruction")
}

@(test)
test_insert_and_contains :: proc(t: ^testing.T) {
	set := create(Pos)
	defer destroy(&set)

	testing.expect(t, insert(&set, e1, Pos{10, 10}), "Should be able to insert")
	testing.expect(t, contains(&set, e1), "Set should contain entity")
	testing.expect(t, contains(&set, e1, Pos{10, 10}), "Set should contain entity and value")
	testing.expect(t, !contains(&set, e1, Pos{11, 10}), "Set should not contain bad value")
	testing.expect(t, !contains(&set, e2), "Set should not contain invalid entity")
	testing.expect(t, size(&set) == 1, "Size should be 1 after insertion")
	testing.expect(t, insert(&set, e3, Pos{300, 10}), "Should be able to insert 2nd")
	testing.expect(t, size(&set) == 2, "Size should be 2 after another insertion")
}

@(test)
test_out_of_order_insert :: proc(t: ^testing.T) {
	ss := create(Pos)
	defer destroy(&ss)

	testing.expect(t, insert(&ss, e10, Pos{100, 100}), "Should be able to insert")
	testing.expect(t, insert(&ss, e2, Pos{20, 20}), "Should be able to insert")
	testing.expect(t, insert(&ss, e8, Pos{80, 80}), "Should be able to insert")
	testing.expect(t, insert(&ss, e3, Pos{30, 30}), "Should be able to insert")
	testing.expect(t, insert(&ss, e5, Pos{50, 50}), "Should be able to insert")
	testing.expect(t, insert(&ss, e1, Pos{10, 10}), "Should be able to insert")
	testing.expect(t, insert(&ss, e4, Pos{40, 40}), "Should be able to insert")
	testing.expect(t, insert(&ss, e7, Pos{70, 70}), "Should be able to insert")
	testing.expect(t, insert(&ss, e9, Pos{90, 90}), "Should be able to insert")
	testing.expect(t, insert(&ss, e6, Pos{60, 60}), "Should be able to insert")

	pprint(&ss)


	testing.expect(t, contains(&ss, e10, Pos{100, 100}), "ss should contain entity/value")
	testing.expect(t, contains(&ss, e9, Pos{90, 90}), "ss should contain entity/value")
	testing.expect(t, contains(&ss, e8, Pos{80, 80}), "ss should contain entity/value")
	testing.expect(t, contains(&ss, e7, Pos{70, 70}), "ss should contain entity/value")
	testing.expect(t, contains(&ss, e6, Pos{60, 60}), "ss should contain entity/value")
	testing.expect(t, contains(&ss, e5, Pos{50, 50}), "ss should contain entity/value")
	testing.expect(t, contains(&ss, e4, Pos{40, 40}), "ss should contain entity/value")
	testing.expect(t, contains(&ss, e3, Pos{30, 30}), "ss should contain entity/value")
	testing.expect(t, contains(&ss, e2, Pos{20, 20}), "ss should contain entity/value")
	testing.expect(t, contains(&ss, e1, Pos{10, 10}), "ss should contain entity/value")


	testing.expect(t, set(&ss, e5, Pos{500, 500}), "ss should contain entity/value")
	testing.expect(t, set(&ss, e6, Pos{600, 600}), "ss should contain entity/value")

	testing.expect(t, contains(&ss, e6, Pos{600, 600}), "ss should contain entity/value")
	testing.expect(t, contains(&ss, e5, Pos{500, 500}), "ss should contain entity/value")
}
@(test)
test_set_and_contains :: proc(t: ^testing.T) {
	ss := create(Pos)
	defer destroy(&ss)

	testing.expect(t, set(&ss, e1, Pos{10, 10}), "Should be able to set entity value")
	testing.expect(t, contains(&ss, e1), "ss should contain entity")
	testing.expect(t, contains(&ss, e1, Pos{10, 10}), "ss should contain entity and value")

	// Reset to new value
	testing.expect(t, set(&ss, e1, Pos{1000, 1000}), "Should be able to set entity value")
	testing.expect(t, contains(&ss, e1, Pos{1000, 1000}), "ss should contain entity and value")
}

@(test)
test_remove :: proc(t: ^testing.T) {
	set := create(Pos)
	defer destroy(&set)

	insert(&set, e1, Pos{1, 1})
	insert(&set, e2, Pos{2, 2})
	insert(&set, e3, Pos{3, 3})
	insert(&set, e4, Pos{4, 4})
	testing.expect(t, remove(&set, e1), "Should be able to remove e1")
	testing.expect(t, !contains(&set, e1), "Set should not contain entity after remove")

	// Brute force check
	for e, idx in set.entities {
		testing.expect(t, e != e1, "set.entities list should not contain entity after remove")
	}

	testing.expect(t, contains(&set, e2, Pos{2, 2}), "Set should still contain entity 2")
	testing.expect(t, size(&set) == 3, "Size should be 1 after removal")

	testing.expect(t, remove(&set, e3), "Should be able to remove e3")
	testing.expect(t, !contains(&set, e3), "Set should not contain e3 after remove")

	testing.expect(t, contains(&set, e2), "Set should still contain entity 2")
	testing.expect(t, contains(&set, e4, Pos{4, 4}), "Set should still contain entity 4")

	testing.expect(t, !remove(&set, e1), "Should not be able to remove e1 a 2nd time")
}

@(test)
test_clear :: proc(t: ^testing.T) {
	set := create(Pos, 10)
	defer destroy(&set)

	insert(&set, e1, Pos{1, 1})
	insert(&set, e2, Pos{2, 2})
	clear(&set)
	testing.expect(t, is_empty(&set), "Set should be empty after clear")
	testing.expect(t, size(&set) == 0, "Size should be 0 after clear")
}

@(test)
test_resize_from_zero :: proc(t: ^testing.T) {
	set := create(Pos, 1)
	defer destroy(&set)

	for i in 0 ..= 10 {
		e := Entity(i)
		insert(&set, e, Pos{f64(i), f64(i)})
	}
	testing.expect(t, len(set.entities) > 4, "length should have increased")
	testing.expect(t, size(&set) == 11, "All elements should be present")
	for i in 0 ..= 10 {
		e := Entity(i)
		testing.expect(
			t,
			contains(&set, e, Pos{f64(i), f64(i)}),
			fmt.tprintf("Set should contain %d", Pos{f64(i), f64(i)}),
		)
	}

}

@(test)
test_resize_from_100 :: proc(t: ^testing.T) {
	set := create(Pos, 100)
	defer destroy(&set)

	for i in 1 ..= 100 {
		e := Entity(i)
		insert(&set, e, Pos{f64(i), f64(i)})
	}
	testing.expect(t, len(set.entities) > 98, "length should have increased")
	testing.expect(t, size(&set) == 100, "All elements should be present")
	for i in 1 ..= 100 {
		e := Entity(i)
		testing.expect(
			t,
			contains(&set, e, Pos{f64(i), f64(i)}),
			fmt.tprintf("Set should contain %d", Pos{f64(i), f64(i)}),
		)
	}

}

@(test)
test_iterate :: proc(t: ^testing.T) {
	set := create(Pos, 10)
	defer destroy(&set)


	for i in 1 ..= 5 {
		e := Entity(i)
		insert(&set, e, Pos{f64(i), f64(i)})
	}

	elements := iterate(&set)
	testing.expect(t, len(elements) == 5, "Iteration should return 5 elements")
	for element, idx in elements {
		e := Entity(idx + 1)
		fmt.println("Iterate: ", element)
		testing.expect(
			t,
			contains(&set, e, element),
			fmt.tprintf("Iterated element %d should be in set", element),
		)
	}
}
