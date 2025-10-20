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
	Rime,
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

enum Status{
	Clear=0,
	Decay, #Tick damage, and reduces Vigor
	Daze, #Prevents Rush Stance, and reduces Brawn
	Fear, #Prevents Brace Stance, and reduces Wit
	Silence, #Prevents Channel Stance, and reduces Ambition
	Slow #Prevents Stance Change, and reduces Grace
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
