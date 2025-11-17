extends Node

enum Domains{
	Draconic=1,
	Primal,
	Construct,
	Cryptid,
	Pantheon,
	Sacred,
	Profane,
	Heroic,
	Fairytale,
	Haunting,
	Eldritch
}

enum Schools{
	Catalyst=0,
	Hearth,
	Deep,
	Storm,
	Geo,
	Grove,
	Blessing,
	Curse,
	Kinetic,
	Charm,
	Alchemy,
	Coven,
	Pact,
	Weird
}

enum Attributes{
	Brawn=0, #Physical Attack
	Vigor, #Physical Defense
	Wit, #Magical Attack
	Ambition, #Magical Defense
	Grace, #Speed
	Heart, #Health
	Prowess, #Status Attack
	Resolve #Status Defense
}

enum BuffableAttrs{
	None=-1,
	Brawn, #Physical Attack
	Vigor, #Physical Defense
	Wit, #Magical Attack
	Ambition, #Magical Defense
	Grace #Speed
}

enum Status{
	Clear=0,
	Decay, #Tick damage, and reduces Vigor at half
	Break, #Removes Guard from moves, and reduces Brawn at half
	Fixate, #Can only use Faeble's inherent Theme, and reduces Wit at half
	Silence, #Prevents Witch Spell usage, and reduces Ambition at half
	Slow #Removes Priority from moves, and reduces Grace at half
}

enum Ranges{
	Melee=0,
	Near,
	Far
}

enum Behaviors{
	Neutral=0,
	Playful,
	Shy,
	Aggressive
}

enum FaebleTags{
	Test=-1,
	Big,
	Small,
	Short,
	Tall,
	Long,
	Wide
}

enum Transitions {
	None=0,
	Accordion
}

enum Events{
	None=0,
	MoveNPC,
	MovePlayer,
	Message,
	Gossip,
	Interview,
	Battle,
	Item,
	Switch,
	Tally
}

enum ZoneTypes{
	Null=0,
	Near,
	Mid,
	Far,
	Onstreet,
	Upstreet,
	Downstreet,
	Uphill,
	Downhill,
}
