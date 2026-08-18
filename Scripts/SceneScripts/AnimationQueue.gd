extends Node
##Autoload

##Serializes view-only steps (tweens, fx, etc.) PER GROUP, not globally.
##Steps enqueued under the same group run strictly in order (one at a time).
##Steps in DIFFERENT groups run concurrently -- that's what lets unrelated
##cards animate at the same time instead of queuing behind each other.
##Actual game logic systems are never touched by this.

signal queue_started(group: StringName)
signal queue_idle(group: StringName)
signal all_idle

class _Group:
	var steps: Array[Callable] = []
	var running: bool = false

var _groups: Dictionary = {} # StringName -> _Group

func enqueue(step: Callable, group: StringName = &"default") -> void:
	var g: _Group = _groups.get(group)
	if g == null:
		g = _Group.new()
		_groups[group] = g
	g.steps.append(step)
	if not g.running:
		_run(group, g)

func is_group_busy(group: StringName) -> bool:
	var g: _Group = _groups.get(group)
	return g != null and (g.running or not g.steps.is_empty())

func is_busy() -> bool:
	for g: _Group in _groups.values():
		if g.running or not g.steps.is_empty():
			return true
	return false

func clear(group: StringName = &"") -> void:
	if group == &"":
		for g: _Group in _groups.values():
			g.steps.clear()
	else:
		var g: _Group = _groups.get(group)
		if g:
			g.steps.clear()

func _run(group: StringName, g: _Group) -> void:
	if g.running:
		return
	g.running = true
	queue_started.emit(group)
	while not g.steps.is_empty():
		var step: Callable = g.steps.pop_front()
		await step.call()
	g.running = false
	queue_idle.emit(group)
	if not is_busy():
		all_idle.emit()
