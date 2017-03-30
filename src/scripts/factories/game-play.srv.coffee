angular.module('vlg')

.factory 'GamePlayService', ['GameService', 'GameDataService', 'GameAudioService', 'GameConstant', (GameService, GameDataService, GameAudioService, GameConstant)->

  serviceObj = {}

  serviceObj.data = GameDataService
  serviceObj.audio = GameAudioService

  serviceObj.connect = ()->
    return GameService.connect()
  serviceObj.isConnected = ()->
    return GameService.isConnected()

  # @username: string
  # @password: string
  # @callback: function (success, error_code, error_message)
  serviceObj.login = (username, password, callback) ->
    if username and password
      GameService.$off 'login'
      if 0 != (statusCode = GameService.gameServer.login(username, password))
        if callback then callback false, -1, "发生系统错误"
      else
        GameService.$one 'login', (status) ->
          if status == 0
            GameDataService.loginName = username
            if callback then callback true, 0, ""
          else if status == 3 # user already online
            if callback then callback true, 3, ""
          else
            error_message = "发生未知错误"
            if status == 1 then error_message = "用户尚未注册"
            if status == 2 then error_message = "密码错误，请重试"
            if callback then callback false, status, error_message
    return

  # @roomType: string (putong|jiazu)
  # @roomId:   integer
  # @callback: function (success, error_code, error_message)
  serviceObj.enterRoom = (roomType, roomId, callback) ->
    resultCode = -999
    switch roomType
      when "putong" then resultCode = - GameService.gameServer.enterputong(roomId)
      when "jiazu"  then resultCode = - GameService.gameServer.enterjiazu(roomId)
      else resultCode = -999
    if resultCode != 0
      if callback then callback false, resultCode, "发生系统错误"
      return
    GameService.$one 'enterroom', (status)->
      if status != 0
        if callback then callback false, 1000 + status, "无法进入房间"
        return
      GameDataService.roomInfo.type = roomType
      GameDataService.roomInfo.id = roomId
      if callback then callback true, 0, ""

  # @callback: function (success, error_code, error_message)
  serviceObj.exitRoom = (callback) ->
    if 0 != GameService.gameServer.quitroom()
      if callback then callback false, -1, "发生系统错误"
      return
    GameDataService.roomPlayers.shangzuo.splice 0
    GameDataService.roomPlayers.shangmai.splice 0
    GameDataService.roomPlayers.guanzhong.splice 0
    GameDataService.currentSpeaker = null
    if callback then callback true, 0, ""

  serviceObj.getCurrentRoomShangzuoPlayers = () ->
    return GameDataService.roomPlayers.shangzuo
  serviceObj.getCurrentRoomShangmaiPlayers = () ->
    return GameDataService.roomPlayers.shangmai
  serviceObj.getCurrentRoomGuanzhongPlayers = () ->
    return GameDataService.roomPlayers.guanzhong

  serviceObj.doShangzuo = (callback) ->
    if 0 != GameService.gameServer.shangzuo()
      if callback then callback false, -1, "发生系统错误"
      return
    GameService.$one "shangzuo", (status)->
      if status != 0
        if callback then callback false, status, "发生未知错误(#{status})"
        return
      if callback then callback true, 0, ""
  serviceObj.doXiazuo = (callback) ->
    if 0 != GameService.gameServer.xiazuo()
      if callback then callback false, -1, "发生系统错误"
      return
    GameService.$one "xiazuo", (status)->
      if status != 0
        if callback then callback false, status, "发生未知错误(#{status})"
        return
      if callback then callback true, 0, ""
  serviceObj.doShangmai = (callback) ->
    if 0 != GameService.gameServer.shangmai()
      if callback then callback false, -1, "发生系统错误"
      return
    GameService.$one "shangmai", (status)->
      if status != 0
        if callback then callback false, status, "发生未知错误(#{status})"
        return
      if callback then callback true, 0, ""
  serviceObj.doXiamai = (callback) ->
    if 0 != GameService.gameServer.xiamai()
      if callback then callback false, -1, "发生系统错误"
      return
    GameService.$one "xiamai", (status)->
      if status != 0
        if callback then callback false, status, "发生未知错误(#{status})"
        return
      if callback then callback true, 0, ""

  serviceObj.isShangzuo = ()->
    return GameService.gameServer.isShangzuo()
  serviceObj.isShangmai = ()->
    return GameService.gameServer.isShangmai()

  # ========================================================================================
  # in game functions
  serviceObj.inGame = () ->
    return GameService.gameServer.inGame()
  serviceObj.isDead = (number) ->
    if not number then return GameService.gameServer.isDead()
    for n in GameDataService.diedList
      if n == number then return true
    return false
  serviceObj.kill = (number) ->
    result = (0 == GameService.gameServer.kill(number))
    if result
      GameDataService.killEnabled = false
      GameDataService.updatePlayerGameStatus()
    return result
  serviceObj.check = (number) ->
    result = (0 == GameService.gameServer.check(number))
    if result
      GameDataService.checkEnabled = false
      GameDataService.updatePlayerGameStatus()
    return result
  serviceObj.vote = (number) ->
    result = (0 == GameService.gameServer.vote(number))
    if result
      GameDataService.voteEnabled = false
      GameDataService.updatePlayerGameStatus()
    return result
  serviceObj.baofei = () ->
    result = (0 == GameService.gameServer.baofei())
    if result
      GameDataService.baofeiEnabled = false
    return result
  serviceObj.endSpeak = () ->
    result = (0 == GameService.gameServer.end_speak())
    return result

  serviceObj.amKiller = () ->
    return (GameDataService.gameInfo.role == GameConstant.ROLE_KILLER)
  serviceObj.amCop = () ->
    return (GameDataService.gameInfo.role == GameConstant.ROLE_COP)
  serviceObj.amVillager = () ->
    return (GameDataService.gameInfo.role == GameConstant.ROLE_VILLAGER)
  serviceObj.amDead = () ->
    return serviceObj.isDead()

  serviceObj.inVoteList = (player_number) ->
    if (not GameDataService.pkList) or (GameDataService.pkList.length == 0) then return true
    for n in GameDataService.pkList
      if player_number == n then return true
    return false

  # ========================================================================================

  serviceObj.startRecord = () ->
    GameService.gameServer.startrec()
  serviceObj.stopRecord = () ->
    GameService.gameServer.stoprec()

  # =========================================================================================

  serviceObj.const = GameConstant

  return serviceObj
]