extends Node
class_name CharacterLoader

# This function loads a character file and returns structured data
static func load_character(path: String) -> Dictionary:
	# Use DataLoader to read JSON
	var data = DataLoader.load_json(path)
	
	# If data is empty, something failed
	if data.is_empty():
		push_error("Character load failed: " + path)
		return {}
	
	# ---- OPTIONAL: Validate important fields ----
	if not data.has("core_attributes"):
		push_error("Missing core_attributes in: " + path)
	
	if not data.has("combat_state"):
		push_error("Missing combat_state in: " + path)
	
	return data