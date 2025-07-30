extends Resource
class_name Title

@export var titleName:String
@export var titleID:int
@export_enum("Brawn","Vigor","Wit","Ambition","Grace","Heart") var positiveStat:int
@export_enum("Brawn","Vigor","Wit","Ambition","Grace","Heart") var negativeStat:int
@export var titleBonus:int = 2
