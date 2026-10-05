extends Node
var upgrade_list : Array
signal minigame(hole)
signal minigame_finished()
signal new_wave()
signal buy(upgrade_id)
var minigame_initiated : bool = false
var minigames_completed : int = 0
var currency : int = 0
