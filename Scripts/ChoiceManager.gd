extends Node
##Autoload

#Suspends current game flow until choice is supplied with an ordinary await

signal choice_requested(request: ChoiceRequest)

var _pending: ChoiceRequest = null

func request(prompt: String, options: Array, min_count: int = 1, max_count: int = 1) -> Array:
	var req := ChoiceRequest.new(prompt, options, min_count, max_count)
	_pending = req
	choice_requested.emit(req)
	var result: Array = await req.resolved
	_pending = null
	return result

func submit(selected: Array) -> bool:
	if _pending == null:
		push_warning("ChoiceManager: submit() called with no pending request")
		return false
	if not _pending.is_valid(selected):
		push_warning("ChoiceManager: invalid selection for '%s' -- ignoring" % _pending.prompt)
		return false
	_pending.resolved.emit(selected)
	return true
