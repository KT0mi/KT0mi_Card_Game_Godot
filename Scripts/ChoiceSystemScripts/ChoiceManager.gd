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
signal choice_resolved(request: ChoiceRequest)

var _pending: ChoiceRequest = null
var _queue: Array[ChoiceRequest] = []

func request_card(
	prompt: String,
	options: Array[CardInstance],
	requesting_player: Player,
	context: ChoiceContext = null,
) -> CardInstance:

	if options.is_empty():
		push_error(
			"ChoiceManager.request_card(): "
			+ "mandatory card choice has no legal options. "
			+ "Prompt: '%s'" % prompt
		)

		return null

	var cards: Array[CardInstance] = await request_cards(
		prompt,
		options,
		requesting_player,
		1,
		1,
		context,
	)

	# If request_cards() got this far, a valid response must contain
	# exactly one CardInstance.
	if cards.is_empty():
		push_error(
			"ChoiceManager.request_card(): "
			+ "card request resolved without a card."
		)

		return null

	return cards[0]

func request_cards(
	prompt: String,
	options: Array[CardInstance],
	requesting_player: Player,
	min_count: int = 1,
	max_count: int = 1,
	context: ChoiceContext = null,
) -> Array[CardInstance]:

	var empty_result: Array[CardInstance] = []

	if options.is_empty():
		if min_count > 0:
			push_error(
				"ChoiceManager.request_cards(): "
				+ "mandatory card choice has no legal options. "
				+ "Prompt: '%s'" % prompt
			)

		return empty_result

	if min_count < 0:
		push_error("ChoiceManager.request_cards(): min_count cannot be negative.")
		return empty_result

	if max_count < min_count:
		push_error(
			"ChoiceManager.request_cards(): max_count cannot be smaller than min_count."
		)
		return empty_result

	if min_count > options.size():
		push_error(
			"ChoiceManager.request_cards(): "
			+ "not enough options to satisfy mandatory selection."
		)
		return empty_result

	# max_count > options.size() doesn't make the choice impossible,
	# but it is almost certainly a caller mistake.
	if max_count > options.size():
		max_count = options.size()

	var request := CardChoiceRequest.new(
		prompt,
		options,
		min_count,
		max_count,
		requesting_player,
		context
	)

	var raw_selection: Array = await _queue_request(request)

	# This is the boundary where the generic UI response becomes
	# a guaranteed card array.
	return request.to_card_array(raw_selection)

func request(prompt: String, options: Array, requesting_player: Player, min_count: int = 1, max_count: int = 1, context : ChoiceContext = null) -> Array:
	print("ChoiceManager: Choice requested to player %s, adding to queue and activating next request." % "1" if requesting_player == GameState.player_one else "2")
	if options.size() < min_count:
		push_warning("ChoiceManager: 'options' array is empty, returning empty response")
		return []
	var req := ChoiceRequest.new(prompt, options, min_count, max_count, requesting_player, context)
	_queue.append(req)
	if _pending == null:
		_activate_next()
	return await req.resolved

func _queue_request(request: ChoiceRequest) -> Array:
	_queue.append(request)

	if _pending == null:
		_activate_next()

	return await request.resolved

func _activate_next() -> void:
	if _queue.is_empty():
		_pending = null
		return
	_pending = _queue.pop_front()
	#Having a deferred call guarantees that "await req.resolved" is already listening
	#Before the request is resolved so that I can avoid race-conditions
	var request := _pending
	_emit_request.call_deferred(request)

func _emit_request(request : ChoiceRequest) -> void:
	if request != _pending:
		return
		
	choice_requested.emit(request)

func submit(selected: Array) -> bool:
	if _pending == null:
		push_warning("ChoiceManager: submit() called with no pending request")
		return false
	if not _pending.is_valid(selected):
		push_warning("ChoiceManager: invalid selection for '%s' -- ignoring" % _pending.prompt)
		return false
	var resolved_req := _pending
	_pending = null
	
	choice_resolved.emit(resolved_req)
	
	resolved_req.resolved.emit(selected)
	
	#Only advance the queue
	#here if nothing already did -- otherwise this unconditionally wipes
	#out whatever the nested call just correctly activated.
	if _pending == null:
		_activate_next()
	
	return true


# --- Helpers -----------
func has_pending_request() -> bool:
	return _pending != null
