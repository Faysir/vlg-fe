angular.module('vlg')

.factory 'GamePlayService', ['GameService', 'GameDataService', (GameService, GameDataService)->

  serviceObj = {}

  serviceObj.data = GameDataService

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
        callback false, -1, "发生系统错误"
      else
        GameService.$one 'login', (status) ->
          if status == 0
            callback true, 0, ""
          else if status == 3 # user already online
            callback true, 3, ""
          else
            error_message = "发生未知错误"
            if status == 1 then error_message = "用户尚未注册"
            if status == 2 then error_message = "密码错误，请重试"
            callback false, status, error_message
    return

  # @roomType: string (putong|jiazu)
  # @roomId:   integer
  # @callback: function (success, error_code, error_message)
  serviceObj.enterRoom = (roomType, roomId, callback) ->
    resultCode = -999
    switch roomType
      when "putong" then resultCode = GameService.gameServer.enterputong(roomId)
      when "jiazu"  then resultCode = GameService.gameServer.enterjiazu(roomId)
      else resultCode = 999
    if resultCode != 0
      callback false, resultCode, "发生系统错误"
      return
    GameService.$one 'enterroom', (status)->
      if status != 0
        callback false, 1000 + status, "无法进入房间"
        return
      callback true, 0, ""

  serviceObj.getCurrentRoomPlayers = () ->
    return

  return serviceObj
]