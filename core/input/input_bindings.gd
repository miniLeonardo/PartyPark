class_name InputBindings
extends RefCounted
## Zentrale Tastenbelegung aller Eingabequellen (D18, D22).
## Gameplay-Code kennt nur die abstrakten Aktionen unten, nie echte Tasten.

const JUMP: StringName = &"jump"
const ACTION: StringName = &"action"
const PUSH: StringName = &"push"
const SPECIAL: StringName = &"special"
const CONFIRM: StringName = &"confirm"
const BACK: StringName = &"back"
const PAUSE: StringName = &"pause"
const TRIGGER: StringName = &"trigger"

## Aus dem Bewegungsvektor abgeleitete Menü-Richtungen, damit Menüs just_pressed nutzen können.
const NAV_UP: StringName = &"nav_up"
const NAV_DOWN: StringName = &"nav_down"
const NAV_LEFT: StringName = &"nav_left"
const NAV_RIGHT: StringName = &"nav_right"

const BUTTON_ACTIONS: Array[StringName] = [JUMP, ACTION, PUSH, SPECIAL, CONFIRM, BACK, PAUSE, TRIGGER]
const NAV_ACTIONS: Array[StringName] = [NAV_UP, NAV_DOWN, NAV_LEFT, NAV_RIGHT]

## Ab welchem Stickausschlag eine Menü-Richtung als gedrückt gilt.
const NAV_THRESHOLD: float = 0.55

## Gamepad nach Tastenposition (SDL3): A unten, B rechts, X links, Y oben.
const GAMEPAD: Dictionary = {
	JUMP: [JOY_BUTTON_A],
	CONFIRM: [JOY_BUTTON_A],
	ACTION: [JOY_BUTTON_B],
	BACK: [JOY_BUTTON_B],
	PUSH: [JOY_BUTTON_X],
	SPECIAL: [JOY_BUTTON_Y],
	PAUSE: [JOY_BUTTON_START],
	TRIGGER: [JOY_BUTTON_RIGHT_SHOULDER],
}

## Anzeigenamen für Tastatur-Tasten in Tastenhinweisen (physische Position, deutsches Layout).
const KEY_LABELS: Dictionary = {
	KEY_SPACE: "Leertaste",
	KEY_ESCAPE: "Esc",
	KEY_ENTER: "Enter",
	KEY_BACKSPACE: "Rücktaste",
	KEY_SEMICOLON: "Ö",
	KEY_APOSTROPHE: "Ä",
	KEY_KP_0: "Num 0",
	KEY_KP_1: "Num 1",
	KEY_KP_2: "Num 2",
	KEY_KP_3: "Num 3",
	KEY_KP_ADD: "Num +",
}

## Tastatur-Debugspieler, physische Tastenpositionen (unabhängig vom Layout).
const KEYBOARD_LEFT: Dictionary = {
	&"up": [KEY_W],
	&"down": [KEY_S],
	&"left": [KEY_A],
	&"right": [KEY_D],
	JUMP: [KEY_SPACE],
	CONFIRM: [KEY_SPACE],
	ACTION: [KEY_E],
	BACK: [KEY_E],
	PUSH: [KEY_F],
	SPECIAL: [KEY_Q],
	TRIGGER: [KEY_F],
	PAUSE: [KEY_ESCAPE],
}

const KEYBOARD_RIGHT: Dictionary = {
	&"up": [KEY_UP],
	&"down": [KEY_DOWN],
	&"left": [KEY_LEFT],
	&"right": [KEY_RIGHT],
	JUMP: [KEY_ENTER, KEY_KP_0],
	CONFIRM: [KEY_ENTER, KEY_KP_0],
	ACTION: [KEY_BACKSPACE, KEY_KP_2],
	BACK: [KEY_BACKSPACE, KEY_KP_2],
	PUSH: [KEY_SEMICOLON, KEY_KP_1],
	SPECIAL: [KEY_APOSTROPHE, KEY_KP_3],
	TRIGGER: [KEY_SEMICOLON, KEY_KP_1],
	PAUSE: [KEY_P, KEY_KP_ADD],
}
