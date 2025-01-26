extends Node

var mainMenu = preload("res://Main Menu.tscn")
var level = preload("res://LevelScene.tscn")

var victory := false

var Checkpoint := Vector2(0,0)

var KeyboardControlREf = {"move_right" : 0, "move_left" : 0, "Up" : 0, "down" : 0, "jump" : 0, "shoot1" : 0 , "shoot2" : 1 , "shoot3" : 2 }
