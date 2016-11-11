angular.module('vlg')

.factory('GameService', [()->

  # callback list

  _callbacks =
    "roomputong_playernum": []
    "roomjiazu_playernum": []
    "enterroom": []
    "login": []
    "roomplayer": []
    "speaker": []
    "open": []
    "close": []
    "error": []
    "shangzuo": []
    "xiazuo": []
    "shangmai": []
    "xiamai": []
    "gamestart": []
    "speakover": []

  _validateEventExpression = (eventExpr)->
    if (typeof eventExpr != "string") or (eventExpr.length == 0)
      throw "Event is not valid"
    eventExprSplited = eventExpr.split('.')
    eventClass =  if (eventExprSplited.length > 1) then eventExprSplited.slice(1).join(".") else null
    eventName = eventExprSplited[0]
    if not (eventName in Object.keys(_callbacks))
      throw "Event name is not valid"
    return {
      eventClass: eventClass
      eventName: eventName
    }

  _callEvent = (eventExpr, args...)->
    eventExprParsed = _validateEventExpression(eventExpr)
    eventName = eventExprParsed.eventName
    eventClass = eventExprParsed.eventClass
    for c in _callbacks[eventName]
      if (!eventClass) or (eventClass == c.eventClass)
        if not c._del_flag
          if c.once
            c._del_flag = true
          c.f.apply(gameServer, args)
    if _callbacks[eventName].length > 0
      for i in [(_callbacks[eventName].length - 1)..0]
        if _callbacks[eventName][i]._del_flag
          _callbacks[eventName].splice(i,1)
    return

  # GameServer initialize

  on_roomputong_playernum = (player_num)->
    _callEvent("roomputong_playernum", player_num)
    return

  on_roomjiazu_playernum = (player_num)->
    _callEvent("roomjiazu_playernum", player_num)
    return

  on_enterroom = (status)->
    _callEvent("enterroom", status)
    return

  on_login = (status)->
    _callEvent("login", status)
    return

  on_roomplayer = (players, status)->
    _callEvent("roomplayer", players, status)
    return

  on_speaker = (speaker_player_id)->
    _callEvent("speaker", speaker_player_id)
    return

  on_open = (evt)->
    _callEvent("open", evt)
    return

  on_close = (evt)->
    _callEvent("close", evt)
    return

  on_error = (evt)->
    _callEvent("error", evt)
    return

  on_shangzuo = (status)->
    _callEvent("shangzuo", status)
    return

  on_xiazuo = (status)->
    _callEvent("xiazuo", status)
    return

  on_shangmai = (status)->
    _callEvent("shangmai", status)
    return

  on_xiamai = (status)->
    _callEvent("xiamai", status)
    return

  on_gamestart = ()->
    _callEvent("gamestart")
    return

  on_speakover = ()->
    _callEvent("speakover")
    return


  game_server_callback = {}
  game_server_callback.onlogin = on_login
  game_server_callback.onputong = on_roomputong_playernum
  game_server_callback.onjiazu = on_roomjiazu_playernum
  game_server_callback.onenterroom = on_enterroom
  game_server_callback.onroomplayer = on_roomplayer
  game_server_callback.onspeaker = on_speaker
  game_server_callback.onopen = on_open
  game_server_callback.onclose = on_close
  game_server_callback.onerror = on_error
  game_server_callback.onshangzuo = on_shangzuo
  game_server_callback.onxiazuo = on_xiazuo
  game_server_callback.onshangmai = on_shangmai
  game_server_callback.onxiamai = on_xiamai
  game_server_callback.ongamestart = on_gamestart
  game_server_callback.onspeakover = on_speakover

  gameServer = new GameServer(game_server_callback);

  #construct the service

  serviceObj = {}

  serviceObj.$on = (eventExpr, callbackFunc) ->
    if (typeof callbackFunc != "function")
      throw "Callback is not valid"
    eventExprParsed = _validateEventExpression(eventExpr)
    callbackObject =
      eventClass: eventExprParsed.eventClass
      eventName: eventExprParsed.eventName
      once: false
      f: callbackFunc
    _callbacks[callbackObject.eventName].push(callbackObject)
    return

  serviceObj.$one = (eventExpr, callbackFunc) ->
    if (typeof callbackFunc != "function")
      throw "Callback is not valid"
    eventExprParsed = _validateEventExpression(eventExpr)
    callbackObject =
      eventClass: eventExprParsed.eventClass
      eventName: eventExprParsed.eventName
      once: true
      f: callbackFunc
    _callbacks[callbackObject.eventName].push(callbackObject)
    return

  serviceObj.$off = (eventExpr) ->
    eventExprParsed = _validateEventExpression(eventExpr)
    eventName = eventExprParsed.eventName
    eventClass = eventExprParsed.eventClass
    if eventClass
      for i in [(_callbacks[eventName].length - 1)..0]
        if _callbacks[eventName][i].eventClass == eventClass
          _callbacks[eventName].splice(i,1)
    else
      _callbacks[eventName].splice(0)
    return

  serviceObj.$trigger = (args...) ->
    eventExpr = args[0]
    _validateEventExpression(eventExpr)
    setTimeout (()->
      _callEvent.apply(undefined, args)
    ), 0

  serviceObj.isConnected = ()->
    return gameServer.isConnected()

  serviceObj.connect = ()->
    return gameServer.connect()

  serviceObj.gameServer = gameServer

  return serviceObj
])