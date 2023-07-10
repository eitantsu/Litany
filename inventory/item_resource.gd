extends Resource

# item resource, can be either regular item or equipable, or an instant one

class_name ItemResource

export(String) var iname
export(Texture) var texture
export(GlobalVariables.ItemTypes) var type
export(Dictionary) var properties
