
$ = require 'zepto'

touch = {}
touchTimer = null
tapTimer = null
swipeTimer = null
gesture = null
longTapTimer = null
longTapDelay = 750

swipeDirection = (x1, x2, y1, y2)->
	if Math.abs(x1 - x2) >= Math.abs(y1 - y2)
		if x1 - x2 > 0 then 'Left' else 'Right'
	else
		if y1 - y2 > 0 then 'Up' else 'Down'

longTap = ->
	longTapTimer = null
	if touch.last
		touch.el.trigger 'longTap'
		touch = {}

cancelLongTap = ->
	if longTapTimer then clearTimeout longTapTimer
	longTapTimer = null

cancelAll = ->
	if touchTimer then clearTimeout touchTimer
	if tapTimer then clearTimeout tapTimer
	if swipeTimer then clearTimeout swipeTimer
	if longTapTimer then clearTimeout longTapTimer
	touchTimer = tapTimer = swipeTimer = longTapTimer = null
	touch = {}

isPrimaryTouch = (e)->
	(event.pointerType == 'touch' or event.pointerType == event.MSPOINTER_TYPE_TOUCH) and
		event.isPrimary

isPointerEventType = (e, type)->
	e.type == 'pointer'+type or e.type.toLowerCase()=='mspointer'+type

$ ->
	now = null
	delta = null
	firstTouch = null
	_isPointerType = null
	deltaX = 0
	deltaY = 0
	isMouseDown = false
	hasTouch = false

	handleTouchStart = (e, _isPointerType)->
		if touchTimer then clearTimeout touchTimer
		now = Date.now()
		delta = now - (touch.last or now)
		if delta > 0 and delta <= 250 then touch.isDoubleTap = true

		touch.last = now
		longTapTimer = setTimeout longTap, longTapDelay
		if gesture and _isPointerType then gesture.addPointer e.pointerId

	handleTouchMove = (e)->
		deltaX += Math.abs(touch.x1 - touch.x2)
		deltaY += Math.abs(touch.y1 - touch.y2)
		if (touch.x2 and Math.abs(touch.x1 - touch.x2) > 30) or (touch.y2 and Math.abs(touch.y1 - touch.y2) > 30)
			swipeTimer = setTimeout(->
				if not touch.el then return
				touch.el.trigger 'swipe'
				touch.el.trigger('swipe'+swipeDirection(touch.x1, touch.x2, touch.y1, touch.y2))
			, 0)
			touch.swiped = true

	handleTouchEnd = ->
		if touch.swiped
			touch = {}
		else if 'last' of touch
			if deltaX < 30 and deltaY < 30
				if tapTimer then clearTimeout tapTimer
				tapTimer = setTimeout(->
					event = $.Event 'tap'
					event.cancelTouch = cancelAll
					touch.el.trigger event
					if touch.isDoubleTap
						if touch.el then touch.el.trigger 'doubleTap'
						touch = {}
					else
						touchTimer = setTimeout(->
							touchTimer = null
							if touch.el then touch.el.trigger 'singleTap'
							touch = {}
						, 250)
				, 0)
			else
				touch = {}
		deltaX = deltaY = 0

	if 'MSGesture' in window
		gesture = new MSGesture()
		gesture.target = document.body

	$(document).on('MSGestureEnd', (e)->

		swipeDirectionFromVelocity =
			if e.velocityX > 1 then 'Right'
			else if e.velocityX < -1 then 'Left'
			else if e.velocityY > 1 then 'Down'
			else if e.velocityY < -1 then 'Up'
			else null
		if swipeDirectionFromVelocity and touch.el
			touch.el.trigger('swipe')
			touch.el.trigger('swipe' + swipeDirectionFromVelocity)

	).on('touchstart MSPointerDown pointerdown', (e)->
		if (_isPointerType = isPointerEventType(e, 'down')) and not isPrimaryTouch(e) then return

		firstTouch = if _isPointerType then e else e.touches[0]
		if e.touches and e.touches.length == 1 and touch.x2
			touch.x2 = touch.y2 = undefined
		touch.el = $(if 'tagName' of firstTouch.target then firstTouch.target else firstTouch.target.parentNode)
		touch.x1 = firstTouch.pageX
		touch.y1 = firstTouch.pageY
		hasTouch = true
		handleTouchStart e, _isPointerType

	).on('mousedown', (e)->
		if hasTouch then return
		isMouseDown = true
		touch.el = $(if 'tagName' of e.target then e.target else e.target.parentNode)
		touch.x1 = e.pageX
		touch.y1 = e.pageY
		handleTouchStart e

	).on('touchmove MSPointerMove pointermove', (e)->
		if (_isPointerType = isPointerEventType(e, 'move')) and not isPrimaryTouch(e) or touch.swiped then return
		cancelLongTap()
		firstTouch = if _isPointerType then e else e.touches[0]
		touch.x2 = firstTouch.pageX
		touch.y2 = firstTouch.pageY
		hasTouch = true

		handleTouchMove e

	).on('mousemove', (e)->
		if hasTouch then return
		if not isMouseDown then return
		touch.x2 = e.pageX
		touch.y2 = e.pageY
		handleTouchMove e
	).on('touchend MSPointerUp pointerup', (e)->
		if (_isPointerType = isPointerEventType(e, 'up')) and not isPrimaryTouch(e) then return
		cancelLongTap()
		handleTouchEnd()
		hasTouch = true
	).on('mouseup', (e)->
		if hasTouch then return
		isMouseDown = false
		cancelLongTap()
		handleTouchEnd()
	).on('touchcancel MSPointerCancel pointercancel', cancelAll)

	$(window).on 'scroll', cancelAll

	$.map ['swipe', 'swipeLeft', 'swipeRight', 'swipeUp', 'swipeDown',
				 'doubleTap', 'tap', 'singleTap', 'longTap'], (eventName)->
		$.fn[eventName] = (cb)->
			this.on eventName, cb