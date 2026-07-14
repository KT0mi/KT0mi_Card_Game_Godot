extends Node
##Autoload

#Suspends current game flow until choice is supplied with an ordinary await.

#Requests are serialized through an internal queue. Without this, if a
#second request() call happens while one is still pending -- e.g. from a
#missing `await` somewhere letting two effects race, or two abilities
#genuinely needing input at once -- the second call would silently
#overwrite _pending, permanently orphaning whatever was waiting on the
#first (its coroutine never resumes: no error, no crash, just a card that
#quietly stops resolving forever). The queue means the second request just
#waits its turn instead.

signal choice_requested(request: ChoiceRequest)

var _pending: ChoiceRequest = null
var _queue: Array[ChoiceRequest] = []

func request(prompt: String, options: Array, requesting_player: Player, min_count: int = 1, max_count: int = 1) -> Array:
	print("ChoiceManager: Choice requested to player %s, adding to queue and activating next request." % "1" if requesting_player == GameState.player_one else "2")
	var req := ChoiceRequest.new(prompt, options, min_count, max_count, requesting_player)
	_queue.append(req)
	if _pending == null:
		_activate_next()
	return await req.resolved

func _activate_next() -> void:
	if _queue.is_empty():
		_pending = null
		return
	_pending = _queue.pop_front()
	choice_requested.emit(_pending)

func submit(selected: Array) -> bool:
	if _pending == null:
		push_warning("ChoiceManager: submit() called with no pending request")
		return false
	if not _pending.is_valid(selected):
		push_warning("ChoiceManager: invalid selection for '%s' -- ignoring" % _pending.prompt)
		return false
	var resolved_req := _pending
	_pending = null
	resolved_req.resolved.emit(selected)
	
	#Only advance the queue
	#here if nothing already did -- otherwise this unconditionally wipes
	#out whatever the nested call just correctly activated.
	if _pending == null:
		_activate_next()
	
	return true
