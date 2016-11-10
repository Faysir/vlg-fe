angular.module('vlg')

.factory 'GamePlayService', ['GameService', (GameService)->

  serviceObj = {}

  # @username: string
  # @password: string
  # @callback: function (success, error_code, error_message)
  serviceObj.login = (username, password, callback) ->
    if username and password
      GameService.$off 'login'
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
      if 0 != (statusCode = GameService.gameServer.login(username, password))
        GameService.$off 'login'
        callback false, -1, "发生系统错误"
    return

  return serviceObj
]