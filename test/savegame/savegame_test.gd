extends GdUnitTestSuite

# TODO support a dynamic `DATA_PATH` for testing on fixed savegames
# would also be useful to jump into a specific game state for testing/demos

func test_basic_round_trip():
	var data = {
		my_special="value",
		roundtrips=["flaw", "less", 3.0, "ly",
			{even="WITH", nested={data=true}}],
		# vectors don't roundtrip :/
		# vector=Vector3(2.0, 3.4, 1.0),
		# vec2=[Vector2(0.4, 21.0), Vector2(0.6, 0.7)],
		something=null,
		}

	SaveGame.save_game(get_tree(), data)

	var loaded = SaveGame.load_game(get_tree())

	assert_dict(loaded).is_equal(data)

# consider moving this test into pandora
func test_save_load_instance_with_new_property() -> void:
	var category = Pandora.create_category("Swords")
	var entity = Pandora.create_entity("Zweihander", category)
	var _property1 = Pandora.create_property(category, "ref", "reference")
	var _property2 = Pandora.create_property(category, "weight", "float")
	var instance = entity.instantiate()
	instance.set_reference("ref", entity)
	instance.set_float("weight", 10.3)
	var data = Pandora.serialize(instance)

	# add a property to the category after it has been serialized
	var _property3 = Pandora.create_property(category, "value", "float")

	var new_instance = Pandora.deserialize(data)

	assert_that(new_instance.get_reference("ref")).is_equal(entity)
	assert_that(new_instance.get_float("weight")).is_equal(10.3)

	# be sure it the new property is usable
	assert_that(new_instance.get_float("value")).is_equal(0.0)

# consider moving this test into pandora
func test_save_load_instance_with_deleted_entity() -> void:
	var category = Pandora.create_category("Swords")
	var entity = Pandora.create_entity("Zweihander", category)
	var _property1 = Pandora.create_property(category, "ref", "reference")
	var _property2 = Pandora.create_property(category, "weight", "float")
	var instance = entity.instantiate()
	instance.set_reference("ref", entity)
	instance.set_float("weight", 10.3)
	var data = Pandora.serialize(instance)

	Pandora.delete_entity(entity)

	var new_instance = Pandora.deserialize(data)

	# the entity for this instance was deleted!!
	assert_that(new_instance).is_null()
