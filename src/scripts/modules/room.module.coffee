angular.module('vlg')

.controller('roomCtl', ['$scope', '$state', '$stateParams', 'GamePlayService', 'DialogService', ($scope, $state, $stateParams, game, dialog) ->

#  roomType = $stateParams.roomType
#  roomId = $stateParams.roomId

  MAX_PLAYER_COUNT = 16
  SPEAK_TIME_LIMIT = 15

  speakTimer = 0

  $scope.content =
    players: []
    currentSpeaker: null
    currentSpeakerName: null
    leftSpeakTime: 0
    leftSpeakTimeString: ""

  # each of messageList is an array with element as object:
  #   content: array[object]
  #     style: [ng-style object]
  #     content: [string]
  $scope.content.messageList =
    chatting: []
    progress: []

  # @message is an object:
  #   content: string | array
  #     [array item]:
  #       style: [ng-style object]
  #       content: [string]
  _pushMessage = (type, message) ->
    if (typeof message) == "string"
      message = { content: message }
    if (typeof message.content) == "string"
      message.content = [{ content: message.content }]
    for contentItem, i in message.content
      message.content[i] = $.extend {
        content: ""
        style: {}
      }, contentItem
    $scope.content.messageList[type].push message
    return

  _pushChattingMessage = (message) ->
    _pushMessage "chatting", message
  _pushProgressMessage = (message) ->
    _pushMessage "progress", message

  # @message: [string]
  pushProgressPlain = (message) ->
    _pushProgressMessage message

  _updatePlayers = ()->
    playerList = game.data.roomPlayers.shangzuo.slice(0, MAX_PLAYER_COUNT)
    while playerList.length < MAX_PLAYER_COUNT then playerList.push({invalid:true})
    $scope.content.players = playerList

  $scope.$on '$roomPlayersLoaded', ()->
    _updatePlayers()
    $scope.$apply()
  _updatePlayers()

  $scope.exitRoom = () ->
    if game.isShangzuo()
      dialog.alert "请先下座"
      return
    game.exitRoom (success, errorCode, errorMessage) ->
      if not success
        dialog.alert("无法退出房间，#{errorMessage}")
        return
      $state.go "hall"

  $scope.doShangzuo = ()->
    if game.isShangzuo() then return
    game.doShangzuo (success, errorCode, errorMessage)->
      if not success
        dialog.alert "操作失败，#{errorMessage}"
        return

  $scope.doXiazuo = ()->
    if not game.isShangzuo() then return
    game.doXiazuo (success, errorCode, errorMessage)->
      if not success
        dialog.alert "操作失败，#{errorMessage}"
        return

  $scope.doShangmai = ()->
    if game.isShangmai() then return
    game.doShangmai (success, errorCode, errorMessage)->
      if not success
        dialog.alert "操作失败，#{errorMessage}"
        return

  $scope.doXiamai = ()->
    if not game.isShangmai() then return
    game.doXiamai (success, errorCode, errorMessage)->
      if not success
        dialog.alert "操作失败，#{errorMessage}"
        return

  _onSpeakerEnd = () ->
    game.stopRecord()
    currentSpeakerName = $scope.content.currentSpeakerName
    $scope.content.currentSpeakerName = null
    $scope.content.leftSpeakTime = 0
    $scope.content.leftSpeakTimeString = ""
    if speakTimer > 0 then clearInterval speakTimer
    if currentSpeakerName then pushProgressPlain "玩家#{currentSpeakerName}发言完毕"
  $scope.$on '$speakerChanged', () ->
    $scope.content.currentSpeaker = game.data.currentSpeaker
    if $scope.content.currentSpeaker
      _onSpeakerEnd()
      $scope.content.currentSpeakerName = $scope.content.currentSpeaker.name
      $scope.content.leftSpeakTime = game.data.currentSpeakTimeLimit
      $scope.content.leftSpeakTimeString = "#{$scope.content.leftSpeakTime}"
      speakTimer = setInterval (()->
        $scope.content.leftSpeakTime -= 1
        $scope.content.leftSpeakTimeString = "#{$scope.content.leftSpeakTime}"
        $scope.$apply()
      ), 1000
      game.startRecord()
      pushProgressPlain "玩家#{$scope.content.currentSpeakerName}正在发言"
    else
      _onSpeakerEnd()
    $scope.$apply()
    return

  return
])

.directive('roomContentBox', [() ->
  return {
    restrict: 'C'
    templateUrl: './pages/room/content-box.directive.html'
    scope:
      messageList: "=massages"
  }
])