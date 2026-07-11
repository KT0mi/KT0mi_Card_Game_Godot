class_name CancellableEvent extends GameEvent
var cancelled: bool = false
func cancel() -> void: cancelled = true
