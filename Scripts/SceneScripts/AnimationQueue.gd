extends Node
##Autoload
##
## Serializes presentation-only steps (tweens, FX) per GROUP, not globally.
## Steps within the same group run strictly in order. Different groups run
## concurrently. Game logic (GameActions, DamagePipeline, TriggerSystem)
## never awaits this -- it's purely a view-layer cache/queue.
##
## Usage:
##   AnimationQueue.enqueue(func() -> void:
##       var tween := node.create_tween()
##       tween.tween_property(node, "position", target, 0.2)
##       await tween.finished
##   , "card:123")

signal queue_started(group: StringName)
signal group_idle(group: StringName)
signal all_idle

class _Group:
	var steps: Array[Callable] = []
	var running: bool = false

var _groups: Dictionary = {}  # StringName -> _Group

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

func _run(group: StringName, g: _Group) -> void:
	if g.running:
		return
	g.running = true
	queue_started.emit(group)
	while not g.steps.is_empty():
		var step: Callable = g.steps.pop_front()
		await step.call()
	g.running = false
	group_idle.emit(group)
	if not is_busy():
		all_idle.emit()
