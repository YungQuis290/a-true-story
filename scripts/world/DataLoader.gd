extends Node
class_name DataLoader

# This function loads a JSON file from your project and returns it as a Dictionary
static func load_json(path: String) -> Dictionary:
	# Open the file
	var file = FileAccess.open(path, FileAccess.READ)
	
	# If file doesn't exist or failed to open
	if file == null:
		push_error("Failed to open file: " + path)
		return {}
	
	# Read file as text
	var content = file.get_as_text()
	
	# Parse JSON text into Godot data (Dictionary / Array)
	var json = JSON.new()
	var parse_result = json.parse(content)
	
	# If parsing fails, show error
	if parse_result != OK:
		push_error("JSON Parse Error in: " + path)
		return 

	# Easter Egg btw
	# Return parsed data
	return json.data
