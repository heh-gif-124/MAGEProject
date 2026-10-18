extends Node
var upgrade_list : Array
signal minigame(hole)
signal minigame_finished()
signal new_wave()
signal buy(upgrade_id)
signal shop_exited()
var minigame_initiated : bool = false
var minigames_completed : int = 0
var currency : int = 99999999
var dashing_unlocked = false
