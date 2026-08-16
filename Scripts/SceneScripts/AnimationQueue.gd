extends Node
##Autoload

##Serializes view-only steps (tweens, fx, etc.) so the player has feedback while
##Maintaining game logic and not making it wait.
##Actual game logic systems are not touched by this.

signal queue_started
signal queue_idle

var _steps: Array[Callable] = []
var _running : bool = false

func enqueue(step: Callable) -> void:
	_steps.append(step)
	if not _running:
		_run()

func is_busy() -> bool:
	return _running or not _steps.is_empty()

func clear() -> void:
	_steps.clear()  #drops not-yet-started steps; doesn't interrupt a mid-flight one

func _run() -> void:
	if _running:
		return
	_running = true
	queue_started.emit()
	while not _steps.is_empty():
		var step: Callable = _steps.pop_front()
		await step.call()
	_running = false
	queue_idle.emit()
