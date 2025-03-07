extends Resource
class_name Speaker

@export var speakerName:String
@export var speakerBust:Texture2D #Eventually make this an array of busts for different anims
@export var speakerEmotes:Dictionary 
#List by easily called emotions or emote tags, make sure to default if none
@export var speakerSound:AudioStream
@export var speakerStyle:StyleBox
